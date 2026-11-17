/*
 * hmi_callback.c - 屏幕 -> MCU 数据接收与命令码分发
 *
 * 屏幕交互在按钮 up 事件用 `printh NN` 发 1 字节命令码。MCU 在
 * HAL_UART_RxCpltCallback 里逐字节解析: 命中命令码表即回调对应处理函数。
 *
 * 说明:
 * - 屏幕仅发 1 字节命令码(无帧尾), 因此逐字节转发给分发器即可。
 * - 阈值键盘(0x11)只发码, 值在屏内 h; 收到后由主循环 tjc_get 回读 h.val 并采纳。
 *   (低报阈值屏端调节已于 2026-09-22 取消: l 控件与 0x04/0x05 一并删除)
 */
#include "hmi_callback.h"
/* [v63c] 诊断统计: 定义在 main.c 的 #if !HMI_DIAG 内, 故声明也须同守卫,
 *        否则 HMI_DIAG=1 时链接报 undefined symbol。 */
#if !HMI_DIAG
void hmi_diag_note(uint8_t b);
#endif

#include "stm32f1xx_hal.h"
#include "c4f7n_hmi_protocol.h"

/* ===== [v62i] 双脉冲确认 =====
 * 背景: 本函数逐字节匹配命令码, 屏口噪声字节等于某码即会执行。
 * 0x1A(硬件零点)会把传感器零点归零 —— 【有气体时执行后果严重】, 且用户实测
 * 噪声会让按钮在「待确认/已下发」间无限切换。因此这两个码加双脉冲门控:
 *   第 1 次只记时刻; 200~2000ms 内来第 2 次才认账。
 * 屏端仍发单字节 printh 1A, 用户真实双击(两次点击各含一次 codesup)天然满足。
 * ★ 在 USART3 ISR 上下文执行, HAL_GetTick() 只读 tick 是安全的。
 * ★ 必须用 uint32_t 存 tick: HAL_GetTick() 是开机毫秒数, 十几秒后就超出
 *   uint8_t 范围, 截断会让 dt 完全失真(实测真实双击也会被拒)。 */
static uint32_t s_dbl_zw   = 0;   /* 0x1A 上次命中时刻 */
static uint8_t  s_dbl_zw_v = 0;   /* 上次命中是否有效(0=无记录) */
static uint32_t s_dbl_lo15 = 0;
static uint8_t  s_dbl_lo15_v = 0;

/* ===== [v63] 握手状态 =====
 * armed=1 表示上一个字节是 0xD5, 当前字节才可以当命令分发。
 * ★ 必须每次收到任意字节都重新判定: 若不是受保护命令, armed 要清掉,
 *   否则一次误收 D5 之后, 紧随的噪声字节仍会被当命令。 */
static uint8_t  s_guard_armed = 0;
static const uint8_t s_guard_list[] = {
  HMI_CMD_HIST_CLEAR, HMI_CMD_INIT_SKIP,
  HMI_CMD_CAL_ZERO,   HMI_CMD_CAL_SPAN, HMI_CMD_CAL_FAC,
  HMI_CMD_SENSOR_ZERO_HW, HMI_CMD_SENSOR_LO15,
  /* [v84] 厂家页手动改补偿(0x21/0x22): 屏端发 D5 5A 21/22,
   *   必须在此白名单里, 否则握手层会把第三字节当"非受保护命令"直接丢弃,
   *   switch 收不到 => 表现为「校B/校K 点了没反应」。*/
  HMI_CMD_CAL_B_SET,  HMI_CMD_CAL_K_SET
};
#define GUARD_N  (sizeof(s_guard_list) / sizeof(s_guard_list[0]))

static uint8_t guard_needs(uint8_t b)
{
  uint8_t i;
  for (i = 0u; i < (uint8_t)GUARD_N; i++) if (s_guard_list[i] == b) return 1u;
  return 0u;
}
static uint8_t dbl_gate(uint32_t *last, uint8_t *valid)
{
  uint32_t now = HAL_GetTick();
  uint32_t dt;
  if (!*valid) { *last = now; *valid = 1u; return 0u; }   /* 第 1 次: 只记时刻 */
  dt = now - *last;
  if (dt >= HMI_DBL_LO_MS && dt <= HMI_DBL_HI_MS) {
    *valid = 0u;                    /* 消费掉, 下次需重新起对 */
    return 1u;
  }
  *last = now;                      /* 超出窗口: 重新起对 */
  return 0u;
}

/* 每收一字节进来一次 */
void hmi_on_rx_byte(uint8_t b) {
  /* ===== [v63] 双字节握手 ===== */
  /* 三字节握手: 0xD5 -> 0x5A -> 命令码, 缺一不可 */
  if (b == HMI_GUARD_PREFIX)  { s_guard_armed = 1u; return; }
  if (b == HMI_GUARD_PREFIX2) { if (s_guard_armed == 1u) { s_guard_armed = 2u; return; }
                                s_guard_armed = 0u; return; }
  if (s_guard_armed == 2u) {
    s_guard_armed = 0u;                    /* 只认第三个字节 */
    if (!guard_needs(b)) return;           /* 握手后不是受保护命令 => 丢弃 */
#if !HMI_DIAG
    hmi_diag_note(b);                     /* 通过握手: 计入统计(仍受总闸约束) */
#endif
  } else {
    if (guard_needs(b)) {
      s_guard_armed = 0u;                 /* 裸码到达: 清握手标志 + 计数, 绝不执行 */
#if !HMI_DIAG
      hmi_diag_note(b);
#endif
      return;
    }
    s_guard_armed = 0u;                   /* 其他字节: 握手链断 */
  }
  /* [v62j] 危险命令总闸: 关闭时只统计不执行(见协议头说明) */
#if !HMI_DANGER_ENABLE
  if (b == HMI_CMD_SENSOR_ZERO_HW) { return; }   /* 统计已在握手层完成 */
  if (b == HMI_CMD_SENSOR_LO15)   { return; }   /* 统计已在握手层完成 */
#else
  /* [v62i] 危险命令先过双脉冲门控 */
  if (b == HMI_CMD_SENSOR_ZERO_HW) { if (dbl_gate(&s_dbl_zw, &s_dbl_zw_v))   hmi_on_sensor_zero_hw(); return; }
  if (b == HMI_CMD_SENSOR_LO15)   { if (dbl_gate(&s_dbl_lo15, &s_dbl_lo15_v)) hmi_on_sensor_lo15();   return; }
#endif
  switch (b) {
    case HMI_CMD_HIST_CLEAR:   hmi_on_hist_clear();   break;   /* 清空历史: 只置标志, 主循环落盘 */
    case HMI_CMD_THR_HI_INC:   hmi_on_thr_hi_inc();   break;
    case HMI_CMD_THR_HI_DEC:   hmi_on_thr_hi_dec();   break;
    case HMI_CMD_BUZZER_MUTE:  hmi_on_buz_mute();     break;
    case HMI_CMD_CAL_ZERO:     hmi_on_cal_zero();     break;
    case HMI_CMD_CAL_SPAN:     hmi_on_cal_span();     break;
    case HMI_CMD_CAL_FAC:      hmi_on_cal_factory();  break;
    case HMI_CMD_TBL_NEXT:      hmi_on_tbl_page(1);  break;
    case HMI_CMD_TBL_PREV:      hmi_on_tbl_page(-1); break;
    case HMI_CMD_TEST_TOGGLE:  hmi_on_test_toggle(); break;
    case HMI_CMD_INIT_SKIP:    hmi_on_init_skip();  break;
    case HMI_CMD_THR_HI_SET:   hmi_on_thr_hi_set(); break;
    case HMI_CMD_CAL_B_SET:    hmi_on_cal_b_set(); break;    /* [v79] 手动改零点补偿 */
    case HMI_CMD_CAL_K_SET:    hmi_on_cal_k_set(); break;    /* [v79] 手动改增益补偿 */   /* 键盘改阈值 -> 回读 h.val */
    case HMI_CMD_PAGE0_ENTER:
    case HMI_CMD_PAGE1_ENTER:
    case HMI_CMD_PAGE2_ENTER:
    case HMI_CMD_PAGE3_ENTER:
    case HMI_CMD_PAGE5_ENTER:   /* [v60] 厂家页: 页对象 load 发 printh 45, 非导航按钮 */
      hmi_on_page_enter((int)b - (int)HMI_CMD_PAGE0_ENTER); break;
    default:                   /* 忽略与 0xFF 帧尾冲突等无关字节 */ break;
  }
}