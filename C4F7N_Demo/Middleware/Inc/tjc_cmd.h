/*
 * tjc_cmd.h - 屏幕指令发送封装 (MCU -> HMI)
 * 用法: 在应用层调用 tjc_set_val / tjc_set_txt / tjc_page ... 即自动追加帧尾并发送。
 */
#ifndef TJC_CMD_H
#define TJC_CMD_H

#include <stdint.h>

void tjc_send_raw(const char *cmd);                 /* 发送"指令文本"并自动加 0xFF 0xFF 0xFF */
void tjc_set_val(const char *obj, int val);
void tjc_set_var(const char *name, int v);           /* 写屏端全局变量(Program.s 的 int): name=v */
void tjc_set_txt(const char *obj, const char *txt);
void tjc_set_bat(int pct, int page);              /* [v61] page: 0主页/1设置/2历史/5厂家/其它=初始化页 */                          /* 更新全部电量显示 (0~100) */
void tjc_set_pco(const char *obj, uint32_t color);
void tjc_set_bco(const char *obj, uint32_t color);   /* [v42] 改控件背景色: 文本控件 txt 为空格时只有 bco 能整块填充 */
void tjc_pic(const char *obj, uint16_t picid);      /* 切换控件图片: obj.pic=id */
void tjc_vis(const char *obj, uint8_t vis);             /* 控件可见性 vis obj,0/1 */
void tjc_page(uint8_t n);
void tjc_dim(uint8_t v);
void tjc_alarm_on(void);
void tjc_alarm_off(void);
void tjc_lowbatt_play(void);   /* 低电提示音: play 1,<LOWBATT>,0 单次 (T-09) */
void tjc_get(const char *obj, const char *prop);    /* 主动读回: get obj.prop + 帧尾 */

#endif /* TJC_CMD_H */