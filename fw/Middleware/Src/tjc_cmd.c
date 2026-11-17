/*
 * tjc_cmd.c - 屏幕指令发送封装
 *
 * 依赖:
 *   - huart1 (USART1) 由 CubeMX 生成, 在此引用 extern
 *   - HAL_UART_Transmit 阻塞发送
 */
#include "tjc_cmd.h"
#include "c4f7n_hmi_protocol.h"
#include "stm32f1xx_hal.h"
#include <string.h>
#include <stdio.h>

extern UART_HandleTypeDef huart3;    /* serial screen USART3 */

/* 发送"指令文本 + 0xFF 0xFF 0xFF" */
void tjc_send_raw(const char *cmd) {
  uint8_t frame[64];
  uint16_t len = 0;
  while (cmd[len] && len < (sizeof(frame) - 3)) len++;
  memcpy(frame, cmd, len);
  frame[len++] = 0xFF;
  frame[len++] = 0xFF;
  frame[len++] = 0xFF;
   /* 超时 100 -> 20 ms: @115200 下最长帧(61B) 只需约 5.3 ms, 20 ms 已有 3.8 倍余量。 
   *   原 100 ms 在屏端异常时会【逐次叠加】—— refill_table 一次调用有 78 次发送,
   *   最坏 78x100 = 7800 ms, 远超 IWDG 窗口(最快 LSI 2133 ms) => 切历史页即被复位。
   *   降到 20 ms 后同样情况最坏 78x20 = 1560 ms, 落在窗口内。
   *   注意: 这是【单次】超时, 正常发送不受影响(5.3 ms << 20 ms)。 */
  HAL_UART_Transmit(&huart3, frame, len, 20);
}

void tjc_set_val(const char *obj, int val) {
  char cmd[32];
  HMI_CMD_SET_VAL(obj, val);
  tjc_send_raw(cmd);
}

/* 写屏端全局变量(Program.s 里声明的 int): 发送 "name=value" + 帧尾 */
void tjc_set_var(const char *name, int v) {
  char cmd[32];
  HMI_CMD_SET_VAR(name, v);
  tjc_send_raw(cmd);
}

void tjc_set_txt(const char *obj, const char *txt) {
  char cmd[64];
  HMI_CMD_SET_TXT(obj, txt);
  tjc_send_raw(cmd);
}

/* 更新 5 页顶栏电量显示 (主页/设置页/历史页/初始化页/厂家页 chip) */
/* 改为 5 页全推 —— 「按当前页选名」有致命前提: 固件 g_page_now 必须与屏端实际页一致。
 * 但实测厂家页返回键 bk 只发 `page 2` 不发 printh 4x(该页只有 load 发 printh 45, 即只有进页通知),
 * 退出后 g_page_now 永远停在 5 => 一直往 pc2_f 发, pc2_s1 收不到
 * => 症状「进厂家页再退出, 电量显示 0%, 要切屏才恢复」。同理初始化页/厂家页色条不更新。
 * 屏端出页可能不通知, 故不再依赖 g_page_now。代价: 每轮多约 80B, @115200 约 7ms。
 * 不存在的对象名屏端静默忽略, 对页数变化无副作用。 */
void tjc_set_bat(int pct, int page) {
  char cmd[40];
  (void)page;    /* 不再按页选名, 保留形参以兼容既有调用点 */
  static const char *const all[5] = {
    OBJ_BAT_CHIP,     /* 主页 pc2 */
    OBJ_BAT_CHIP_P1,  /* 设置页 pc2_s1 */
    OBJ_BAT_CHIP_P2,  /* 历史页 pc2_s2 */
    OBJ_BAT_CHIP_I,   /* 初始化页 pc2_i */
    OBJ_BAT_CHIP_F    /* 厂家页 pc2_f */
  };
  unsigned k;
  for (k = 0; k < 5; k++) {
    HMI_CMD_SET_BAT(all[k], pct);
    tjc_send_raw(cmd);
  }
}

void tjc_set_pco(const char *obj, uint32_t color) {
  char cmd[32];
  HMI_CMD_SET_PCO(obj, color);
  tjc_send_raw(cmd);
}

/* 改控件"背景色"。 
 * 由来: 顶栏色条 dvr 是"文本控件 + txt=' '(单个空格) + h=2", 而 pco 是文字前景色
 *       (空格无笔画 -> 无从着色), 故推 pco 真机表现为"颜色恒定不变"; 必须改用 bco。 */
void tjc_set_bco(const char *obj, uint32_t color) {
  char cmd[32];
  HMI_CMD_SET_BCO(obj, color);
  tjc_send_raw(cmd);
}

void tjc_pic(const char *obj, uint16_t picid) {
  char cmd[32];
  HMI_CMD_SET_PIC(obj, picid);
  tjc_send_raw(cmd);
}

void tjc_vis(const char *obj, uint8_t vis) {
  char cmd[24];
  HMI_CMD_SET_VIS(obj, vis);
  tjc_send_raw(cmd);
}

void tjc_page(uint8_t n) {
  char cmd[16];
  HMI_CMD_PAGE(n);
  tjc_send_raw(cmd);
}

void tjc_dim(uint8_t v) {
  char cmd[16];
  HMI_CMD_DIM(v);
  tjc_send_raw(cmd);
}

void tjc_alarm_on(void) {
  char cmd[16];
  HMI_CMD_ALARM_ON();
  tjc_send_raw(cmd);
}

void tjc_alarm_off(void) {
  char cmd[16];
  HMI_CMD_ALARM_OFF();
  tjc_send_raw(cmd);
}

void tjc_lowbatt_play(void) {
  char cmd[16];
  HMI_CMD_LOWBATT_PLAY();
  tjc_send_raw(cmd);
}

void tjc_get(const char *obj, const char *prop) {
  char cmd[32];
  HMI_CMD_GET(obj, prop);
  tjc_send_raw(cmd);
}