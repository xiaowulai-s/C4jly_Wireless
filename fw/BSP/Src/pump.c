/*
 * pump.c - 泵 / 检测测试开关控制 (手动开关, 默认关)
 *
 * 硬件: KLVP1E-SB12L 12V 无刷隔膜气泵 (卡默尔), 功耗 <=2W。
 * 硬件接口实为两路(2026-09-28 据手册 p5 "电机控制" 更正: KLVP1 无使能线, 4 线制 Vcc/GND/PWM/FG):
 *   1) PWM 调速+启停 (10~30kHz) -> PB6 = TIM4_CH1; **启停由占空比实现: 0~10% 不转, 11~100% 调速**
 *      (全速接法 = PWM 线接 Vcc; 本设计用 PWM 0% 停转, 无需独立使能线)
 *   2) FG 转速反馈(开漏)   -> 首版不接(2026-09-28 决定, 接线后再置 PUMP_HAS_FG=1 并配 EXTI)
 * PUMP_HAS_CTL 永不启用(保留定义以防换泵); 启停由 PUMP_HAS_PWM 的 CCR=0 承担。
 */
#include "pump.h"
#include "stm32f1xx_hal.h"
#include "gpio.h"

/* ---------- 硬件接口占位 ---------- */
/* 1) 启停/电源控制输出 -- KLVP1 无此线, 启停由 PWM 0% 实现; 以下为历史占位, 永不启用 */
#define PUMP_CTL_PORT_GPIO  GPIOA
#define PUMP_CTL_PIN        GPIO_PIN_15
#define PUMP_CTL_ON_HIGH    1          /* 高电平开泵; 若低有效改为 0 */
#define PUMP_HAS_CTL        0          /* 1=已配置控制输出 */

/* 2) PWM 调速 (KLVP1 白/蓝线, PWM 10~30kHz 幅值 5V, 需外部电平匹配)
 *    引脚已定: **PB6 = TIM4_CH1**(无 remap 默认映射); 接线后需 CubeMX 配 TIM4 CH1 + PWM 幅值电平转换(3.3V->5V) */
#define PUMP_PWM_TIM        TIM4       /* 已定 2026-09-28: PB6 = TIM4_CH1(无 remap), 用户确认 */
#define PUMP_PWM_CH_HANDLE  (&htim4)   /* PWM 句柄(本文件私有) */
#define PUMP_PWM_CH         TIM_CHANNEL_1   /* 已定: CH1@PB6 */
#define PUMP_PWM_ARR        3599u      /* TIM4 时基: 72MHz(APB1=36MHz x2)/20kHz - 1 = 3599 */
#define PUMP_HAS_PWM        1          /* 2026-09-28 启用: PB6 = TIM4_CH1 @20kHz */

/* 3) FG 转速反馈 (KLVP1 黄线, 开漏, SB系列 6 脉冲/转) */
#define PUMP_FG_PORT_GPIO   GPIOA
#define PUMP_FG_PIN         GPIO_PIN_14
#define PUMP_FG_PULSES_PER_REV 6       /* SB系列 6 脉冲/转; SD系列为 1 */
#define PUMP_HAS_FG         0          /* 1=已配置 FG 反馈 (外部中断) */

#define PUMP_FG_SAMPLE_MS   1000       /* FG 频率采样窗口, 未启用中断时为 0 */

static TIM_HandleTypeDef htim4;    /* PWM 句柄(本文件私有, 手工配置 TIM4) */
static int      g_pump_on = 0;         /* 软件状态位, 默认关 */
static uint8_t  g_duty    = 100;       /* 转速档位(占空比), 默认满速 */
static uint32_t g_fg_freq_ticks = 0;   /* 最近 FG 采样的脉冲计数 */

static void pump_write_hw(void)
{
#if PUMP_HAS_CTL
  GPIO_PinState s;
  if (PUMP_CTL_ON_HIGH)
    s = g_pump_on ? GPIO_PIN_SET : GPIO_PIN_RESET;
  else
    s = g_pump_on ? GPIO_PIN_RESET : GPIO_PIN_SET;
  HAL_GPIO_WritePin(PUMP_CTL_PORT_GPIO, PUMP_CTL_PIN, s);
#else
  (void)0;
#endif
}

/* PWM 硬件初始化 (2026-09-28 配置): PB6=TIM4_CH1 AF 复用, 20kHz, PWM1 模式(高有效).
 * 手工配置(未走 CubeMX, 因工程混合编码禁止重生成): .ioc 不登记 TIM4, 本函数为唯一真源. */
static void pump_pwm_hw_init(void)
{
  GPIO_InitTypeDef g = {0};
  TIM_OC_InitTypeDef oc = {0};

  __HAL_RCC_TIM4_CLK_ENABLE();
  __HAL_RCC_GPIOB_CLK_ENABLE();
  g.Pin   = GPIO_PIN_6;
  g.Mode  = GPIO_MODE_AF_PP;
  g.Speed = GPIO_SPEED_FREQ_HIGH;
  HAL_GPIO_Init(GPIOB, &g);

  PUMP_PWM_CH_HANDLE->Instance = TIM4;
  PUMP_PWM_CH_HANDLE->Init.Prescaler         = 0;
  PUMP_PWM_CH_HANDLE->Init.CounterMode       = TIM_COUNTERMODE_UP;
  PUMP_PWM_CH_HANDLE->Init.Period            = PUMP_PWM_ARR;
  PUMP_PWM_CH_HANDLE->Init.ClockDivision     = TIM_CLOCKDIVISION_DIV1;
  PUMP_PWM_CH_HANDLE->Init.AutoReloadPreload = TIM_AUTORELOAD_PRELOAD_DISABLE;
  HAL_TIM_Base_Init(PUMP_PWM_CH_HANDLE);

  oc.OCMode     = TIM_OCMODE_PWM1;
  oc.Pulse      = 0;                       /* 上电停转(0~10% 不转区) */
  oc.OCPolarity = TIM_OCPOLARITY_HIGH;
  oc.OCFastMode = TIM_OCFAST_DISABLE;
  HAL_TIM_PWM_ConfigChannel(PUMP_PWM_CH_HANDLE, &oc, PUMP_PWM_CH);
  HAL_TIM_PWM_Start(PUMP_PWM_CH_HANDLE, PUMP_PWM_CH);
}

void pump_init(void)
{
#if PUMP_HAS_CTL
  GPIO_InitTypeDef g = {0};
  g.Pin   = PUMP_CTL_PIN;
  g.Mode  = GPIO_MODE_OUTPUT_PP;
  g.Speed = GPIO_SPEED_FREQ_LOW;
  __HAL_RCC_GPIOA_CLK_ENABLE();        /* 端口时钟按实际端口调整 */
  HAL_GPIO_Init(PUMP_CTL_PORT_GPIO, &g);
  pump_write_hw();
#else
  (void)0;
#endif
#if PUMP_HAS_PWM
  pump_pwm_hw_init();                  /* PB6/TIM4_CH1 @20kHz, 上电 CCR=0(停转) */
#endif
}

void pump_set(int on)
{
  if (on) {
    g_pump_on = 1;
#if PUMP_HAS_PWM
    __HAL_TIM_SET_COMPARE(PUMP_PWM_CH_HANDLE, PUMP_PWM_CH,
                          (uint32_t)((g_duty * PUMP_PWM_ARR) / 100));
#endif
  } else {
    g_pump_on = 0;
#if PUMP_HAS_PWM
    __HAL_TIM_SET_COMPARE(PUMP_PWM_CH_HANDLE, PUMP_PWM_CH, 0);
#endif
  }
  pump_write_hw();
}

int  pump_get(void)  { return g_pump_on; }
void pump_toggle(void){ pump_set(!g_pump_on); }

void pump_set_duty(uint8_t duty_percent)
{
  if (duty_percent > 100) duty_percent = 100;   /* KLVP1 建议 >=11% 才起转 */
  g_duty = duty_percent;
#if PUMP_HAS_PWM
  if (g_pump_on)
    __HAL_TIM_SET_COMPARE(PUMP_PWM_CH_HANDLE, PUMP_PWM_CH,
                          (uint32_t)((g_duty * PUMP_PWM_ARR) / 100));
#endif
}

/* FG 中断回调: 每来一个上升沿调用, 统计脉冲数 */
void pump_feedback_isr(void)
{
#if PUMP_HAS_FG
  if (g_pump_on) g_fg_freq_ticks++;
#endif
}

/* 返回转速(转/分); 未接 FG 返回 -1 (调用方需采样间隔重置 g_fg_freq_ticks) */
int pump_get_rpm_ff(void)
{
#if PUMP_HAS_FG
  if (PUMP_FG_SAMPLE_MS == 0) return -1;
  /* RPM = 每秒脉冲数 * 60 / 每转脉冲数 */
  return (int)((double)g_fg_freq_ticks * 1000.0 / (double)PUMP_FG_SAMPLE_MS
               * 60.0 / (double)PUMP_FG_PULSES_PER_REV);
#else
  return -1;
#endif
}