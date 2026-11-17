/*
 * device_id.h - 设备唯一编号 (SN) 的持久化
 *
 * 位置: STM32F103RCT6 内部 Flash 最后一页 (0x0803F800, 2KB)
 *   - 与 W25Q64(参数区/历史区) 完全独立, 不受"恢复出厂"影响
 *     (SN 属出厂标识, 不应被恢复出厂重置)
 *   - 代码区当前约 39KB, 距该页有 200KB+ 余量
 * 策略: 首次上电若无有效记录 -> 用 MCU 96bit 唯一 ID 派生(逐机唯一)并落盘;
 *       之后上电只读, 供屏端设置页"产品编号"行显示。
 * 背景: 2026-09-30 接口审计 P1-3 — 屏端 sn 行原为写死的 "SN-C4F7N-260001"。
 */
#ifndef DEVICE_ID_H
#define DEVICE_ID_H

#include <stdint.h>
#include "product_info.h"   /* 量产配置区: PRODUCT_SN / PRODUCT_FW_VERSION / PRODUCT_SN_FORCE_WRITE */

#define DEVICE_ID_ADDR    0x0803F800u   /* 最后一页起始 (RCT6 = 256KB Flash) */
#define DEVICE_ID_SN_MAX  24u           /* SN 缓冲区(含结尾 NUL) */

/* 上电调用一次: 读有效记录; 无效则生成 + 落盘。之后 device_id_get() 可用 */
void        device_id_init(void);

/* 返回形如 "SN-C4F7N-1A2B3C4D"; 未初始化时返回 "SN-UNKNOWN" */
const char *device_id_get(void);

#endif /* DEVICE_ID_H */
