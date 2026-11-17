/*
 * sensor.c - C4F7N 便携式检漏仪传感器驱动 (GC5G1 NDIR, 数字 UART 主动上报)
 *
 * 功能概述:
 *   1) 配置 PC11(RX)/PC10(TX) 为 USART4 复用, 9600 8N1
 *   2) 开启接收中断, 逐字节缓冲, 按帧头识别并解析浓度
 *   3) sensor_read_ppm() 返回最近一帧浓度
 *
 * 依赖: STM32 HAL, 已配置好系统时钟(72MHz)。
 * 帧格式为文本行 (行尾带 ppm 数值), 以厂家资料为准, 改 SENSOR_* 宏即可。
 */
#include "sensor.h"
#include "stm32f1xx_hal.h"

/* 接收缓冲 + 状态 */
static uint8_t  line[SENSOR_LINE_MAX];
static uint16_t lint = 0;   /* 当前行长度计数 */
static uint8_t  g_warmup = 1;   /* 预热中标志(收到有效帧前保持) */
static float    g_ppm_now = 0.0f;
static uint32_t s_init_ms = 0;   /* sensor_init() tick (forces min init window) */
static volatile uint8_t g_new = 0;
static volatile uint32_t g_last_frame_ms = 0;
static volatile uint32_t g_last_line_ms = 0;   /* 最近一次成功收到行的时刻 tick(HAL_GetTick) */
#define PROBE_ONLINE_TIMEOUT_MS  3000u          /* 超过此时长无帧 => 视为"未连接" */

/* 标定接口: 由原始值经 k/b 系数校准为 ppm  ppm_out = raw*cal_k/1000 + cal_b
 *   cal_k: 0.001 斜率系数 (默认 1000 = 1.000, 即不校准)
 *   cal_b: ppm 偏移 (默认 0, 无偏移) */
static int32_t s_cal_k = 1000;
static int32_t s_cal_b = 0;
void sensor_set_cal(int32_t k, int32_t b) { s_cal_k = k; s_cal_b = b; }
void sensor_get_cal(int32_t *k, int32_t *b) { if(k)*k=s_cal_k; if(b)*b=s_cal_b; }

/* 返回最近一帧浓度 (单位 ppm 数值):
 * 注意: 当前帧格式(文本行, 行尾 ppm)为当前实现, 以 GC5G1 实际协议为准
 * 确认后统一改 SENSOR_* 宏即可。 */
static void parse_frame(void)
{
  /* 文本行解析: 行 = [空白] 数字 [空白] "ppm"(不区分大小写); 其余字符忽略 */
  char buf[SENSOR_LINE_MAX + 2];
  int L = 0;
  int i, e, ns;

  for (i = 0; i < lint && L < (int)sizeof(buf) - 1; i++) {
    char c = (char)line[i];
    if (c == '\r') continue;
    if (c >= 'A' && c <= 'Z') c = (char)(c + ('a' - 'A'));
    buf[L++] = c;
  }
  buf[L] = 0;
  while (L > 0 && (buf[L-1] == ' ' || buf[L-1] == '\t')) buf[--L] = 0;
  if (L < 3) return;
  e = L;
  if (!(buf[e-1] == 'm' && buf[e-2] == 'p' && buf[e-3] == 'p')) return;
  e -= 3;
  while (e > 0 && (buf[e-1] == ' ' || buf[e-1] == '\t')) e--;
  ns = e;
  while (ns > 0) {
    char c1 = buf[ns-1];
    if ((c1 >= '0' && c1 <= '9') || c1 == '.') ns--; else break;
  }
  if (ns == e) return;
  { long ip = 0; int i2, ndec = 0, seen_dot = 0;
    for (i2 = ns; i2 < e; i2++) {
      char c2 = buf[i2];
      if (c2 == '.') { seen_dot = 1; continue; }
      if (c2 >= '0' && c2 <= '9') {
        ip = ip * 10L + (long)(c2 - '0');
        if (seen_dot) ndec++;
      }
    }
    /* 手写整数+小数解析（避 strtod），如 "850.5" -> 850.5 */
    g_ppm_now = (float)ip;
    while (ndec > 0) { g_ppm_now /= 10.0f; ndec--; }
    if (g_ppm_now < 0.0f) g_ppm_now = 0.0f;   /* 超量程不封顶 */
  }
  g_warmup = 0;
  g_new = 1;
  g_last_frame_ms = HAL_GetTick();
}

void sensor_init(void)
{
  s_init_ms = HAL_GetTick();
  GPIO_InitTypeDef gpio = {0};

  __HAL_RCC_UART4_CLK_ENABLE();
  __HAL_RCC_GPIOC_CLK_ENABLE();

  /* PC11 = USART4_RX (输入浮动), PC10 = USART4_TX (AF 推挽) */
  gpio.Pin   = GPIO_PIN_10;
  gpio.Mode  = GPIO_MODE_AF_PP;
  gpio.Speed = GPIO_SPEED_FREQ_HIGH;
  HAL_GPIO_Init(GPIOC, &gpio);

  gpio.Pin   = GPIO_PIN_11;
  gpio.Mode  = GPIO_MODE_INPUT;
  gpio.Pull  = GPIO_PULLUP;
  HAL_GPIO_Init(GPIOC, &gpio);

  /* 9600 8N1 raw: UART4 on APB1(36MHz) => USARTDIV = 36000000/9600 = 3750 */
  UART4->BRR = (uint16_t)(36000000u / 9600u);
  /* [v62] 补 TE: 原先只有 RE, UART4 只能收不能发; PC10(TX) 在上方已配成 AF_PP,
   *   这里只需开发送使能即可下发厂商标定/配置指令。 */
  UART4->CR1 = USART_CR1_UE | USART_CR1_TE | USART_CR1_RE | USART_CR1_RXNEIE;

  /* RXNE IRQ already enabled in CR1 above */

  /* 使能 UART4 全局中断 + NVIC */
  HAL_NVIC_SetPriority(UART4_IRQn, 1, 0);
  HAL_NVIC_EnableIRQ(UART4_IRQn);
}

float sensor_read_ppm(void) {
  if (g_ppm_now == 0.0f) return 0.0f;   /* preheat: no first frame -> report 0, never 1500 */
  /* 返回原始值经 MCU 软件校准 (固定偏移 + 固定斜率) */
  float v = (float)(((int64_t)g_ppm_now * s_cal_k) / 1000 + s_cal_b);
  if (v < 0.0f) v = 0.0f;
  else if (v > SENSOR_FS_PPM) v = SENSOR_FS_PPM;
  return v;
}
float sensor_read_raw(void) { return g_ppm_now; }   /* 原始浓度, 未做校准 */
float sensor_read_voltage(void) { return 0.0f; }   /* 数字方案无电压 */
int   sensor_has_new(void) { uint8_t n; __disable_irq(); n = g_new; g_new = 0; __enable_irq(); return n; }

/* 探头在线判定: 最近一次有效帧距今未超时 => 在线 */
int sensor_online(void) {
  uint32_t now, last;
  __disable_irq(); last = g_last_line_ms; __enable_irq();
  if (last == 0) return 0;                       /* 从未收到过帧 */
  now = HAL_GetTick();
  return (now - last) < PROBE_ONLINE_TIMEOUT_MS;
}
int sensor_warmup(void) {
  if (g_warmup) return 1;                                      /* still in sensor warmup */
  return (int)((HAL_GetTick() - s_init_ms) < SENSOR_INIT_MS);  /* force min init window */
}

/* ---- [v62] vendor downlink commands (bytes confirmed by user 2026-10-12) ----
 * ZERO_HW  23 57 31 36 36 21          : send ONLY when no test gas present
 * LO15_A/B 11 bytes each, send A then B : sensor then clamps 0..15ppm to 0
 * Arrays are defined here (not in sensor.h) because sensor.h is included by 4 TUs. */
const uint8_t SENSOR_CMD_ZERO_HW[SENSOR_CMD_ZERO_HW_LEN] = {
  0x23, 0x57, 0x31, 0x36, 0x36, 0x21
};

const uint8_t SENSOR_CMD_LO15_A[SENSOR_CMD_LO15_LEN] = {
  0x23, 0x57, 0x38, 0x31, 0x35, 0x30, 0x30, 0x32, 0x35, 0x39, 0x21
};

const uint8_t SENSOR_CMD_LO15_B[SENSOR_CMD_LO15_LEN] = {
  0x23, 0x57, 0x38, 0x36, 0x30, 0x30, 0x31, 0x35, 0x35, 0x44, 0x21
};

/* [v62] 下发一帧厂商指令(阻塞)
 * 9600 8N1 下 11 字节约需 11.5ms, 与 tjc_send_raw 同为阻塞风格。
 * ★ 只在主循环调用: UART4 发送不依赖中断, 但阻塞期间不能进 ISR 轮询。
 * 用法: sensor_send_cmd(SENSOR_CMD_LO15_A, sizeof(SENSOR_CMD_LO15_A)); */
void sensor_send_cmd(const uint8_t *buf, uint8_t len)
{
  uint8_t i;
  if (buf == 0 || len == 0u) return;
  for (i = 0u; i < len; i++) {
    while ((UART4->SR & USART_SR_TXE) == 0u) { }
    UART4->DR = buf[i];
  }
  while ((UART4->SR & USART_SR_TC) == 0u) { }   /* 等最后一位真正移出 */
}

/* 逐字节处理, 遇换行结束 (以 \n 分隔) */
static void feed_byte(uint8_t b)
{
  if (b == '\n') {
    if (lint > 0) parse_frame();
    lint = 0;
    g_last_line_ms = HAL_GetTick();
    return;
  }
  if (b == '\r') return;
  if (lint >= SENSOR_LINE_MAX) return;
  line[lint++] = b;
}

void sensor_uart4_irq_handler(void)
{
  if (UART4->SR & USART_SR_RXNE) {
    feed_byte((uint8_t)(UART4->DR & 0xFF));
  }
  /* 读 DR 已清 RXNE; RXNE 中断保持使能, 无需手动重挂 */
}