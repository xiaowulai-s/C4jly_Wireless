/*
 * device_id.h - 设备唯一编号 (SN) 的持久化
 *
 * 位置: STM32F103RCT6 内部 Flash 最后一�? (0x0803F800, 2KB)
 *   - �? W25Q64(参数�?/历史�?) 完全独立, 不受"恢复出厂"影响
 *     (SN 属出厂标�?, 不应被恢复出厂重�?)
 *   - 代码区当前约 39KB, 距该页有 200KB+ 余量
 * 策略: 首次上电若无有效记录 -> �? MCU 96bit 唯一 ID 派生(逐机唯一)并落�?;
 *       之后上电只读, 供屏端设置页"产品编号"行显示�?
 * 背景: 2026-09-30 接口审计 P1-3 �? 屏端 sn 行原为写死的 "SN-C4F7N-260001"�?
 */
#ifndef DEVICE_ID_H
#define DEVICE_ID_H

#include <stdint.h>
#include "product_info.h"   /* 量产配置�?: PRODUCT_SN / PRODUCT_FW_VERSION / PRODUCT_SN_FORCE_WRITE */

#define DEVICE_ID_ADDR    0x0803F800u   /* 最后一页起�? (RCT6 = 256KB Flash) */
#define DEVICE_ID_SN_MAX  24u           /* SN 缓冲�?(含结�? NUL) */

/* 上电调用一�?: 读有效记�?; 无效则生�? + 落盘。之�? device_id_get() 可用 */
void        device_id_init(void);

/* 返回形如 "SN-C4F7N-1A2B3C4D"; 未初始化时返�? "SN-UNKNOWN" */
const char *device_id_get(void);

/* v1.1 wireless: burn a new SN over the BLE bridge (factory session required).
 * Rules: 8..24 chars, kept NUL-terminated; validates against rec rules;
 * returns 1 ok / 0 fail. Restart (or re-init) recommended afterwards. */
int         device_id_set_sn(const char *sn);

/* v1.1 wireless: factory auth hash lives in the same id page (rewritten
 * together with SN so one never clobbers the other).
 *   get: 1 = provisioned (out filled), 0 = not provisioned
 *   set: requires a valid SN record on the page (erases + rewrites both) */
#define DEVICE_ID_AUTH_LEN  32u
int         device_id_auth_hash_get(uint8_t out[DEVICE_ID_AUTH_LEN]);
int         device_id_auth_hash_set(const uint8_t hash[DEVICE_ID_AUTH_LEN]);

#endif /* DEVICE_ID_H */
