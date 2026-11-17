/*
 * battery.c - 电池电压采样 (PB1 / ADC1_IN9) 转换为电量百分比
 */
#include "battery.h"
#include "adc.h"            /* hadc1: 由 CubeMX 生成的 adc.c MX_ADC1_Init 初始化 */
#include "tjc_cmd.h"
#include "hmi_callback.h"      /* [v61] hmi_get_page() */
#include "stm32f1xx_hal.h"

/* ---------- 电池电压采样参数 ---------- */

#define BAT_REF_V      3.30f
#define VREFINT_V      1.20f             /* STM32 internal ref V */             /* STM32 ADC 参考电压 V */
#define BAT_R_TOP_K    110.0f            /* R 上分压电阻 kΩ (实测值) */
#define BAT_R_BOT_K    24.0f             /* R 下分压电阻 kΩ */
#define BAT_DIV_RATIO  (BAT_R_BOT_K / (BAT_R_TOP_K + BAT_R_BOT_K)) /* VBAT_SENSE = 电压 * 分压比 */
#define BAT_EMPTY_V    12.0f             /* 空电 (4S Li-ion, 3.0V/节) */   /* [v46] 仅留参考: 百分比换算已改 BAT_CURVE 查表 */
#define BAT_FULL_V     16.3f             /* 满电显示基准(4S): 2026-09-28 实测充满 16.44V, 扣二极管压降后电池平衡点 ~16.3V; 理论 16.8V(4.2V/节) 因 SS34 直充压降达不到, 16.44 记录备查 */   /* [v46] 仅留参考: 百分比换算已改 BAT_CURVE 查表; [v98] 曲线表顶部锚改 16.40V */
#define BAT_N_SAMP     20                /* 每次电压采样次数 (软件 ADC 均值) */
#define BAT_FILT_FACT  0.3f              /* 一阶低通滤波系数 0~1, 越小越平滑 (0.08→0.3: 收敛 7.5s→~1s) */
#define BAT_HYST_PCT   0.6f              /* 显示量化滞回(%): 取整边界外扩量, 吸收充电末期电压摆动(修 98/99 跳, 2026-09-28) */
#define BAT_CALIB_K    1.009f            /* 测量单点校准: 万用表 16.42V vs 固件 16.28V(显示99%反推), 分压电阻标称 vs 实际比值偏差(~0.9%), 全量程比例修正 */

/* ---------- 低电三级阈值 (T-09/D5, 2026-09-28 确认) ----------
 * 4S 锂电安全放电下限约 3.2~3.3V/节, 三级都在其上, 正常使用中电量永远到不了 0%。
 * EN 未接 MCU: 无自动断电能力, 3 级 = 持续催促模式(硬件补 EN 线后可升级真关机)。 */
/* [v47] 改为按【电量百分比】触发(方案A): 查表后电压阈值折算过来是 6%/1%/0%,
 * 后两档挤在一起会失去预警意义; 百分比与屏上显示直接对应, 用户看到 20 就是真的 20。
 * ⚠️ 旧电压阈值(BAT_WARN_V 13.5 / BAT_ALARM_V 13.0 / BAT_SHUTDOWN_V 12.6)已停用,
 *    仅在下方 battery_get_level() 的注释里留档, 便于回溯。
 * 降级滞回 BAT_LV_HYST: 升档即时, 降档需回落超过 3%, 防临界抖动反复变色/重播音效。 */
#define BAT_LV1_PCT     20                /* 1=提示  <=20% 橙"电量低请充电"        */
#define BAT_LV2_PCT     10                /* 2=警告  <=10% 红"电量低请更换电池"    */
#define BAT_LV3_PCT      3                /* 3=耗尽前 <=3%  红"电量耗尽请立即充电" */
#define BAT_LV_HYST      3                /* 降档滞回(%): 升档即时, 降档需回落超过此值 */
#define BAT_SLEW_LIMIT 3                 /* 每次 poll 电量变化上限(%)，抑制瞬时负载(报警喇叭)拉低读数 */

/* ---------- [v46] 电量曲线: 分段线性查表 (取代原 12.0~16.3V 线性换算) ----------
 *
 * 为何要改: 原线性映射把一条直线穿过锂电池"缓降->陡降"的放电曲线, 中低段严重虚高。
 *   实测证据 (2026-10-08): 万用表测 13.76V 时屏显 42%, 而 4S 真实放电曲线 13.76V 约合 15%
 *   => 虚高约 27 个百分点 => "显示 30% 就关机" 实为真实仅剩 5~8% (电池真没电, 不是死机)。
 *
 * ⚠️⚠️ 本表与【电池型号 + 负载】强相关, 换电池后必须重新标定!
 *   标定流程见 docs/评审与方案/电量曲线修正方案_2026-10-08.md 第 6 节(含实测记录表)。
 *   要点: 满电静置 2h -> 每 5min 记电压 -> 放至关机 -> 用"时间 x 平均电流(约 0.5A)"换算 SOC
 *         -> 填 8~12 点 -> 3 点校验 (100% / 50% / <=10%)。
 *   ⚠️ 必须用【含泵的典型负载】标定: 负载越大端电压越低、曲线整体下移;
 *      若按静默低负载标定, 用户实际开泵时会再次被突然关机。取向: 宁可低估, 不可高估。
 *
 * 注: [v47] 低电三级已改按【电量百分比】触发(见 BAT_LV1/LV2/LV3_PCT), 不再判电压,
 *     因此换电池重新标定本表时, 低电告警时点会自动跟随新曲线, 无需另行调整。
 */
typedef struct { float v; uint8_t pct; } bat_curve_pt_t;

static const bat_curve_pt_t BAT_CURVE[] = {
    /* [v98] 换新电池(14.8V/16.8V 充/10000mAh/4S2P 18650) => 换用【通用 4S 保守曲线】,
     *   去掉一切针对旧电池(7800mAh 4S3P, 已到寿命末期)的补偿。三条锚点原则:
     *   ① 顶部锚 16.40V=100%: 本板是 SS34 单肖特基直充(压降~0.45V), 电池永远充不到 16.8V,
     *      旧表把 100% 放在 16.60V(不可达) => 旧固件物理满电时永远只显示 97%。
     *      ★ 真机实测(2026-10-29, 新电池 10000mAh 4S2P), 三种工况均显示 100%:
     *        16.43V(接适配器) / 16.40V(断开适配器静置) / 16.37V(开机带载, 最保守工况)。
     *        16.37V 比静置低 30mV = 泵负载内阻压降, 证明它是使用中的真实读数。
     *        ⇒ 顶部锚 16.40V 与静置实测仅差 0~10mV, 锚点选得准;
     *        ⇒ 屏显 100% 窗口 = [16.30V, +inf), 最差点(开机带载)余量 70mV,
     *          临界负载压降 100mV(实测仅 30mV), 组内阻再涨 3 倍仍撑得住。
     *      顶部 16.40~16.20V 密集布点(每点 2%), 避免满电区曲线过陡导致读数抖动。
     *   ② 工作区(16.20V 以下)比 docs 实测真实曲线低 2~3 个百分点(保守取向:
     *      宁可显示偏低, 不可高估) —— 覆盖型号/内阻(4S2P 并联少、内阻高)/负载三重不确定。
     *   ③ 底部锚 11.70V=0%: 高于 PCM 保护板实测断电点 11.21V 约 0.49V,
     *      归零时电池仍有电, 不会出现"显示 0% 却突然断电"。
     *   百分比严格单调递减(旧表 12.00/11.50 两点同为 1%, 末端失去分辨率, 已修正)。
     *   ⚠️ 本表为【通用曲线, 未按新电池实测标定】。换电池后实测流程见
     *      docs/评审与方案/电量曲线修正方案_2026-10-08.md §6, 标定后覆盖本表即可。*/
    {16.40f, 100},  {16.36f,  98},  {16.32f,  96},  {16.28f,  94},
    {16.24f,  92},  {16.20f,  90},  {16.10f,  85},  {16.00f,  83},
    {15.90f,  82},  {15.80f,  80},  {15.70f,  78},  {15.60f,  77},
    {15.40f,  67},  {15.20f,  57},  {15.00f,  47},  {14.80f,  39},
    {14.60f,  31},  {14.40f,  25},  {14.20f,  21},  {14.00f,  17},
    {13.80f,  13},  {13.70f,  11},  {13.60f,   9},  {13.40f,   5},
    {13.20f,   2},  {12.40f,   1},  {11.70f,   0},
};
#define BAT_CURVE_N  (sizeof(BAT_CURVE) / sizeof(BAT_CURVE[0]))

/* 电压(V) -> 电量百分比(0~100), 线性插值; 超出表两端则钳位 */
static uint8_t battery_v_to_pct(float v) {
    uint16_t i;
    if (v >= BAT_CURVE[0].v) return BAT_CURVE[0].pct;
    if (v <= BAT_CURVE[BAT_CURVE_N - 1u].v) return 0u;
    for (i = 1u; i < BAT_CURVE_N; i++) {
        if (v >= BAT_CURVE[i].v) {
            const float dv = BAT_CURVE[i].v - BAT_CURVE[i - 1u].v;
            const float dp = (float)(BAT_CURVE[i].pct - BAT_CURVE[i - 1u].pct);
            /* [v98] 原式 (uint8_t)((v-prev)/dv*dp) 是 C 未定义行为:
             *   表按电压降序排列 => dv<0 且 dp<0, 乘积恒为负数, 负 float 转 uint8_t 未定义。
             *   ARM 上实测走 __aeabi_f2iz(向零截断) + uxtb 回绕 => 结果恒比数学正确值高 1 个百分点
             *   (例: 13.63V 数学值 11%, 二进制算出 12%)。改为 float 计算 + 四舍五入 + 钳位,
             *   顺带把全量程拉低 1 个百分点 —— 正是要的保守方向。*/
            const float p = (float)BAT_CURVE[i - 1u].pct
                           + ((v - BAT_CURVE[i - 1u].v) / dv) * dp;
            if (p < 0.0f)   return 0u;
            if (p > 100.0f) return 100u;
            return (uint8_t)(p + 0.5f);
        }
    }
    return 0u;
}

static float g_vdda = BAT_REF_V;  /* measured VDDA (replace 3.3 assumption) */
static int g_batt_pct = 100;             /* 当前电量 0~100 (滤波+取整后) */
static int g_last_sent = -1;             /* 上次已同步到屏幕的电量; -1=首次强制发送 */
static float g_filt_pct = 100.0f;        /* 低通滤波中间量 (0~100 浮点) */
static int  g_filt_first = 1;            /* 首采直通: 上电立即显示真实电量, 不做爬坡 */
static uint8_t g_batt_valid = 0;         /* [v50] 最近一次采样是否有效(未接/读数异常 -> 0) */
static float g_filt_v = 0.0f;            /* 电压低通(供 battery_get_level 判定, 与 pct 滤波同系数) */

/* ADC 初始化: hadc1 由 MX_ADC1_Init(PB1/ADC1_IN9) 完成 */
/* Measure VDDA via internal VREFINT(~1.20V), remove 3.3V assumption error.
 * v36: 由 init 一次改为每 poll 重测 —— VDDA 随负载漂移(3.3V 轨 ~145mV), 一次校准
 * 会导致同一 VIN 在不同负载态读数差 4%+; VREFINT 周期重测即为此设计。 */
static float battery_read_vdda(void) {
  ADC_ChannelConfTypeDef sChannel = {0};
  uint32_t sum = 0; int k;
  ADC1->CR2 |= ADC_CR2_TSVREFE;             /* enable temp-sensor/VREFINT */
  sChannel.Channel      = ADC_CHANNEL_17;
  sChannel.Rank         = 1;
  sChannel.SamplingTime = ADC_SAMPLETIME_239CYCLES_5;
  HAL_ADC_ConfigChannel(&hadc1, &sChannel);
  for (k = 0; k < 8; k++) {
    HAL_ADC_Start(&hadc1);
    HAL_ADC_PollForConversion(&hadc1, 10);
    sum += HAL_ADC_GetValue(&hadc1);
    HAL_ADC_Stop(&hadc1);
  }
  ADC1->CR2 &= ~ADC_CR2_TSVREFE;            /* disable VREFINT */
  sChannel.Channel = ADC_CHANNEL_9;         /* restore battery chan IN9 */
  HAL_ADC_ConfigChannel(&hadc1, &sChannel);
  float avg = (float)sum / 8.0f;
  if (avg < 20.0f) return BAT_REF_V;        /* invalid sample, fallback 3.30 */
  return 4095.0f * VREFINT_V / avg;         /* VDDA = 4095*1.20 / VREF_adc */
}

void battery_init(void) {
  g_vdda = battery_read_vdda();   /* v36 起 poll 每轮重测, 此处首测仅为首采前的有效基准 */
  /* 此处做首次采样并校准基准 */
  battery_poll();
}

/* 读取 ADC -> 取平均 -> 还原为电池电压 (V) */
static float battery_read_voltage(void) {
  uint32_t sum = 0;
  int k;
  for (k = 0; k < BAT_N_SAMP; k++) {          /* 多次采样取平均, 抑制噪声 */
    HAL_ADC_Start(&hadc1);
    HAL_ADC_PollForConversion(&hadc1, 10);   /* 10ms 超时 */
    sum += HAL_ADC_GetValue(&hadc1);
    HAL_ADC_Stop(&hadc1);
  }
  /* VBAT_SENSE = Vref*adc/4095;  电压 = VBAT_SENSE/分压比 */
  return (((float)sum / (float)BAT_N_SAMP) * g_vdda / 4095.0f) / BAT_DIV_RATIO * BAT_CALIB_K;
}

/* [v98] 屏显百分比: 在内部物理百分比上叠加【界面余量】, 让用户体验友好。
 *   规则(仅影响显示, 不影响低电告警判据 —— 告警仍用 battery_get_level() 的内部百分比):
 *     >=95%  -> 100%  : 逼近满电显示百分百(满电前约 0.12V 就到顶, 避免永远卡 97/98)
 *     <=1%   -> 1%    : 永不显示 0%(用户看到 0% 会以为设备已耗尽而恐慌)
 *     其余    -> 原值  : 中段与物理值完全一致, 读数可信
 *   注: 顶部曾试过 90~94 段做 x2 拉伸, 但那会把 1 个内部百分点放大成 2 个显示百分点,
 *   反而在满电区制造读数抖动(实测跨度 3~7), 故最终只用硬封顶 + 下限保底。
 *   顶部跳变只有"从 100% 掉到 94%"这一次(离开满电时), 非来回抖。*/
uint8_t battery_get_disp_pct(void) {
  int p = g_batt_pct;
  if (p >= 95) return 100u;
  if (p <= 1)  return 1u;
  return (uint8_t)p;
}

int battery_get_pct(void) {
  return g_batt_pct;
}

/* [v50] 最近一次电池采样是否有效: 1=有效 0=未接/读数异常(v<5V 已丢弃)
   注: 判据不能用 battery_get_pct()>=0 —— 它返回 int 恒 >=0, 该判据恒真(P0-A) */
uint8_t battery_valid(void) {
  return g_batt_valid;
}

/* 低电级别: [v47] 改按【电量百分比 g_filt_pct】判定(不是电压)
 * 低通已防抖, 消费端(low_batt_poll)另有 1s 持续确认。
 * 升档即时(宁可早提醒); 降档需回落超过 BAT_LV_HYST, 防临界抖动。
 * 旧判据留档: g_filt_v <= 13.5/13.0/12.6V (v46 前的 BAT_WARN_V/ALARM_V/SHUTDOWN_V),
 * 在 v46 分段查表下分别只对应 6%/1%/0%, 故改为按百分比。 */
/* [v93] 对外暴露滤波后真实电压(mV): 供低电末端预警按【电压】判定,
 *   而非按百分比 —— 曲线末端必然不准, 电压才是可直接信任的量。*/
uint16_t battery_get_volt_mv(void) {
  if (g_filt_v <= 0.0f) return 0u;
  return (uint16_t)(g_filt_v * 1000.0f + 0.5f);
}

uint8_t battery_get_level(void) {
  static uint8_t lv = 0;
  float p;
  if (g_filt_v <= 0.0f) return lv;                     /* 尚未采样 */
  p = g_filt_pct;
  if      (p <= (float)BAT_LV3_PCT)                   lv = 3;
  else if (p <= (float)BAT_LV2_PCT)                   lv = 2;
  else if (p <= (float)BAT_LV1_PCT)                   lv = 1;
  else if (p >= (float)(BAT_LV1_PCT + BAT_LV_HYST))   lv = 0;   /* 回落需越过 23% 才降回正常 */
  return lv;                                           /* 区间内保持当前档(滞回) */
}

/* 周期刷新: 采样电压 -> 百分比 -> 同步到屏幕所有电量显示 */
void battery_poll(void) {
  g_vdda = battery_read_vdda();   /* v36: 每轮重测 VDDA 跟随负载漂移(修 50%->65% 跳变), ~2ms */
  float   v   = battery_read_voltage();
  int     pct;

  if (v < 5.0f) { g_batt_valid = 0; return; }   /* [v50] 无效读数(未接/异常) 丢弃, 不更新, 但记录标志 */
  g_batt_valid = 1;         /* [v50] 本次读数有效 */
  pct = (int)battery_v_to_pct(v);   /* [v46] 分段查表(见 BAT_CURVE); 低电三级仍按真实电压判定, 不受影响 */

  if (pct < 0)   pct = 0;
  if (pct > 100) pct = 100;

  /* 低通滤波: 抑制 86/87/88 附近的临界波动; 首采直通(不做爬坡) */
  if (g_filt_first) { g_filt_pct = (float)pct; g_filt_v = v; g_filt_first = 0; }
  else { g_filt_pct += ((float)pct - g_filt_pct) * BAT_FILT_FACT; g_filt_v += (v - g_filt_v) * BAT_FILT_FACT; }
  /* 显示量化滞回(2026-09-28): 取整边界外扩 BAT_HYST_PCT, 吸收充电末期电压摆动
   * (充电电流波动 -> SS34 压降波动约 +/-25mV), 修复 98/99 来回跳;
   * 代价: 放电读数滞后约 0.6% 才降一格, 充电爬升台阶化 */
  { static int shown = -1;
    if (shown < 0) shown = (int)(g_filt_pct + 0.5f);                       /* 首采直通 */
    else if (pct >= 100 && g_filt_pct > 99.5f) shown = 100;                /* 满电特判: 常规升格需>shown+1.1=100.1, 滤波上限100永远达不到, 不特判则满电卡99 */
    else if (g_filt_pct > (float)shown + 0.5f + BAT_HYST_PCT) shown++;     /* 升格: 越过上边界 */
    else if (g_filt_pct < (float)shown - 0.5f - BAT_HYST_PCT) shown--;     /* 降格: 跌破下边界 */
    g_batt_pct = shown;
  }

  /* [v51] 限幅只限跌, 不限涨: 原实现上下双向各限 3%, 会把充电时的上升沿也压住,
   *   使显示比真实值偏低最多 3% 且恢复缓慢(滞回门槛 0.5+0.6=1.1%/格)。
   *   抑制瞬时负载跌落的初衷只需"限跌"即可达成(报警喇叭造成的是跌不是涨)。 */
  { static int last_pct = -1;
    if (last_pct >= 0 && (g_batt_pct - last_pct) < -BAT_SLEW_LIMIT)
      g_batt_pct = last_pct - BAT_SLEW_LIMIT;   /* 只限跌 */
    last_pct = g_batt_pct;
  }

  /* 无条件推送: 每 poll 都下发 chip, 消除滞回/切页造成的"几秒才更新" (方案A) */
  /* [v61] 改为按页选 chip 名: 主页 pc2 / 设置 pc2_s1 / 历史 pc2_s2 / 厂家 pc2_f / 初始化 pc2_i */
  tjc_set_bat((int)battery_get_disp_pct(), (int)hmi_get_page());
  g_last_sent = g_batt_pct;
}