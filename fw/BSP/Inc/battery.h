/*
 * battery.h - 电池电压采样 (PB1 / ADC1_IN9) 与电量百分比
 *
 * 电池  : 4S Li-ion, 14.8V 标称 / 16.8V 充满 / 12.0V 空电
 * 分压  : R7=110k(上) + R8=24k(下), 分压比≈0.1791  [2026-10-08 据原理图更正, 原写 R22=100k/0.1935 有误]
 *           满电 16.8V -> VBAT_SENSE≈3.01V (不饱和)
 *           空电 12.0V -> VBAT_SENSE≈2.15V
 * 输出  : 电量 0~100% 同步刷新到 TJC 屏幕全部电量显示 (tjc_set_bat)
 */
#ifndef BATTERY_H
#define BATTERY_H

#include <stdint.h>

/* ADC 初始化: 配置 ADC1 + PB1/IN9 模拟输入 + 校准; 在 main 里先调用一次 */
void battery_init(void);

/* 周期刷新: 采样电压 -> 计算电量百分比 -> 同步到屏幕; 建议放入主循环周期调用 */
void battery_poll(void);

/* 读取最近一次计算出的电量百分比 (0~100) —— 内部物理值, 供低电告警判据用 */
int  battery_get_pct(void);
/* [v98] 屏显用百分比: 内部物理值 + 界面余量(>=95% 显示 100%, <=1% 显示 1%, 顶部拉伸)。
   屏上所有电量文字/圆点都用这个值; 低电告警仍用内部物理百分比, 二者互不影响。*/
uint8_t battery_get_disp_pct(void);
/* [v50] 最近一次采样是否有效: 1=有效; 0=未接电池或读数异常(<5V 已丢弃)
   用于 selftest 判电池故障 —— 不可用 battery_get_pct()>=0(恒真) */
uint8_t battery_valid(void);
/* 低电级别 (T-09): 0=正常 1=提示(<=20%) 2=警告(<=10%) 3=耗尽前(<=3%) -- [v47] 改判电量百分比 */
uint8_t battery_get_level(void);
/* [v93] 滤波后电池真实电压(mV, 0=尚未采样): 低电末端预警按电压判定 */
uint16_t battery_get_volt_mv(void);

#endif /* BATTERY_H */