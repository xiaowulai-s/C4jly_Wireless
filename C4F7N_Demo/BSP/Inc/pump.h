/*
 * pump.h - 泵 / 检测测试开关控制 (手动开关, 默认关)
 *
 * 硬件: KLVP1E-SB12L 12V 无刷隔膜气泵 (卡默尔)
 *   - 红线=VCC(12V)  黑线=GND
 *   - 白/蓝线=PWM 调速 (10~30kHz, 幅值 5V; 0~10%占空=停, 11%~100%=调速)
 *   - 黄线=FG 转速反馈 (开漏, SB系列 6 脉冲/转)
 * 当前硬件未接入: 全部置 0 时仅以软件状态位维护启停, 供界面/命令码使用。
 * 接入硬件后 (2026-09-28 据手册更正: 无使能线, 启停由 PWM 占空比 0~10% 实现):
 *   1) 填 PWM 定时器(已定: PB6 = TIM4_CH1, 无 remap)并置 PUMP_HAS_PWM=1 —— 启停/调速都由它承担
 *   2) FG 首版不接(2026-09-28 决定); 将来接时: 接到外部中断引脚并置 PUMP_HAS_FG=1, 中断里调 pump_feedback_isr()
 *   (原 PUMP_HAS_CTL 启停线方案作废: KLVP1 无使能线)
 */
#ifndef PUMP_H
#define PUMP_H

#include <stdint.h>

/* 初始化: 配置硬件资源(若已配), 默认关 */
void pump_init(void);

/* 置泵状态: 1=运行(测试中) 0=停止 */
void pump_set(int on);

/* 翻转泵状态 */
void pump_toggle(void);

/* 读取当前泵状态: 1=运行 0=停止 */
int  pump_get(void);

/* 设置转速档位(占空比 0~100). 未接 PWM 硬件时仅存软件值, 供上层/将来使用 */
void pump_set_duty(uint8_t duty_percent);

/* 读取经 FG 计算得到的转速(转/分); 未接 FG 返回 -1 表示不可用 */
int  pump_get_rpm_ff(void);

/* FG 中断回调: 每次 FG 跳变由用户中断里调用 (未接 FG 时无需调用) */
void pump_feedback_isr(void);

#endif /* PUMP_H */