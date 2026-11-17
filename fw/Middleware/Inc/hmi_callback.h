/*
 * hmi_callback.h - 屏幕交互命令码分发回调接口
 * 用户在 tjc_cmd.c 或应用层实现这些弱回调, 放入实际业务逻辑。
 */
#ifndef HMI_CALLBACK_H
#define HMI_CALLBACK_H

#include <stdint.h>

/* 每收到 1 字节命令码调用 (RX 中断上下文) */
void hmi_on_rx_byte(uint8_t b);

/* 各交互动作回调 (用户/应用层实现) */
void hmi_on_hist_clear(void);   /* 历史页按钮: 清空历史记录(两段确认, 主循环执行) */
void hmi_on_thr_hi_inc(void);
void hmi_on_thr_hi_dec(void);
void hmi_on_thr_hi_set(void);
void hmi_on_cal_b_set(void);         /* [v79] 厂家页: 键盘改 cal_b 完成 -> 请 MCU 回读 cb.val */
void hmi_on_cal_k_set(void);         /* [v79] 厂家页: 键盘改 cal_k 完成 -> 请 MCU 回读 ck.val */
void man_push_if_factory(void);      /* [v79] 进厂家页时推一次生效值(由 main 在 p==5 时调用) */    /* 屏幕键盘改完高报阈值: 请求回读 h.val */
void hmi_on_buz_mute(void);                /* 首页临时静音: 只停本次报警 */
void hmi_on_cal_zero(void);
/* [v62] 硬件零点校准 / 15ppm 下限(向 UART4 下发厂商指令) */
void hmi_on_sensor_zero_hw(void);
void hmi_on_sensor_lo15(void);
void hmi_on_cal_span(void);
void hmi_on_cal_factory(void);
void hmi_on_tbl_page(int delta);    /* ±1 翻页 */
void hmi_on_page_enter(int p);      /* 进入页 0..5 [v61] */
/* [v61] 取当前页号(0主页/1设置/2历史/5厂家; 0xFF=未定, 初始化页另由 g_page_init 判定)
 *  供 tjc_set_bat 按页选电量 chip 名用 —— 避免向屏发本页不存在的对象名。 */
uint8_t hmi_get_page(void);
void hmi_on_test_toggle(void);  /* 测试 启停切换 (原 CSV 导出位 0x24 复用) */
void hmi_on_init_skip(void);   /* 跳过初始化: 从初始化页进入主页 */

#endif /* HMI_CALLBACK_H */