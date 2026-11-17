/*
 * hmi_get.c - 解析屏幕 `get` 指令应答帧。
 *
 * TJC `get obj.prop` 回包:
 *   - 值(2或4字节整形): 0x70 <value-LE> 0xFF 0xFF 0xFF
 *   - 字符串:           0x71 <bytes...> 0xFF 0xFF 0xFF
 * 本模块在 RX 字节流里缓冲一帧, 提取数值, 供阈值回读使用。
 *
 * 返回三态(重要):
 *   1 = 一帧解析完成, 可读 hmi_get_value()
 *   0 = 非帧字节, 调用方应交给命令分发器
 *  -1 = 帧中间字节, 调用方【必须丢弃】, 不得当命令分发
 *
 * 历史 bug(已修): 早期只用 0/1 两态, 帧中间的字节也返回 0,
 * 调用方遂将其交给命令分发器。而 get 应答的数值字节恰好是
 * 0x01..0x07 等业务命令码(如秒值 7 -> 0x07 跳过初始化跳页),
 * 导致校时读秒值时把自己读数当成命令执行。故改三态。
 */
#include "hmi_get.h"
#include <string.h>

/* 简单状态机: 等待 0x70/0x71 起始符, 收满后解析 */
static uint8_t  g_rx_buf[64];
static uint8_t  g_idx = 0;
static uint8_t  g_expect = 0;   /* 期望剩余数据字节数 0=等待起始符 */
static uint8_t  g_str = 0;

void hmi_get_reset(void) {
  g_idx = 0; g_expect = 0; g_str = 0;
}

/* 返回三态: 1=帧完成, 0=非帧字节(可分发), -1=帧中间字节(须丢弃) */
int hmi_get_feed(uint8_t b) {
  if (g_expect == 0) {
    if (b == 0x70) { g_str = 0; g_expect = 4; g_idx = 0; return -1; }      /* 4字节数值, 帧头 */
    else if (b == 0x71) { g_str = 1; g_expect = 0xFE; g_idx = 0; return -1; } /* 字符串帧头 */
    return 0;   /* 与任何帧无关 -> 允许调用方当命令分发 */
  }
  if (g_expect == 0xFE) { /* 字符串模式 */
    if (g_idx < sizeof(g_rx_buf)) g_rx_buf[g_idx++] = b;
    /* 遇 3 个 0xFF 视为结束 */
    if (g_idx >= 3 && g_rx_buf[g_idx-1]==0xFF && g_rx_buf[g_idx-2]==0xFF && g_rx_buf[g_idx-3]==0xFF) {
      g_expect = 0;
      return 1; /* 字符串: g_rx_buf[0..g_idx-4] 为内容 */
    }
    return -1;  /* 帧内容字节, 丢弃 */
  }
  /* 数值模式: 收 g_expect 个字节后收帧尾 */
  g_rx_buf[g_idx++] = b;
  g_expect--;
  if (g_expect == 0) { g_expect = 0xFD; return -1; } /* 等帧尾 */
  if (g_expect == 0xFD) { /* 帧尾1 */
    if (b == 0xFF) { g_expect = 0xFC; return -1; }
    hmi_get_reset(); return -1;   /* 异常帧: 冲刷但不外泄 */
  }
  if (g_expect == 0xFC) { /* 帧尾2 */
    if (b == 0xFF) { int r = 1; hmi_get_reset(); return r; }
    hmi_get_reset(); return -1;   /* 异常帧: 冲刷但不外泄 */
  }
  return -1;
}

/* 取最近解析的数值 (4字节小端) */
uint32_t hmi_get_value(void) {
  return (uint32_t)g_rx_buf[0]
       | ((uint32_t)g_rx_buf[1]) << 8
       | ((uint32_t)g_rx_buf[2]) << 16
       | ((uint32_t)g_rx_buf[3]) << 24;
}
uint8_t hmi_get_is_string(void) { return g_str; }

/*
 * 用法(在 hmi_on_rx_byte 之前先喂 get 解析器) —— 注意必须是三态判定:
 *   void HAL_UART_RxCpltCallback(...){
 *     int r = hmi_get_feed(rx_byte);
 *     if (r > 0) {                       // 一帧完成
 *        if (!hmi_get_is_string()) tjc_set_val(OBJ_THR_HI_VAL, hmi_get_value());
 *     } else if (r == 0) {               // 与任何帧无关的字节
 *        hmi_on_rx_byte(rx_byte);        // 才允许走命令码分发
 *     }
 *     // r < 0: 帧中间字节, 丢弃
 *   }
 *
 * 反例(曾经的 bug): 写成 `if (hmi_get_feed(b)) ... else hmi_on_rx_byte(b);`
 *   会把帧中间字节也送给命令分发器, 而 get 应答的数值正好落在业务命令码上。
 */