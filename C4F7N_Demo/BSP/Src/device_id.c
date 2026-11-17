/*
 * device_id.c - 见 device_id.h
 *
 * 记录布局(32 字节, 自然对齐无 padding):
 *   magic(4) + sn[24] + xorv(4)
 * STM32F1 的 Flash 按 16bit 半字编程, 故以 uint16 视图逐半字写。
 */
#include "device_id.h"
#include "stm32f1xx_hal.h"
#include <stdio.h>
#include <string.h>

#define ID_MAGIC   0x4E533031u        /* 内部有效性标志 */

/* [v45 / N5] 编译期长度检查: PRODUCT_SN 超过屏端可显上限会被静默截断 ->
 * 此处超长直接编译报错(typedef 负数组长度)。改 product_info.h 的 SN 时若报错即为此因。 */
typedef char product_sn_len_ok[(sizeof(PRODUCT_SN) - 1u) <= PRODUCT_SN_DISPLAY_MAX ? 1 : -1];
/* 96bit 唯一 ID 基址直接用 CMSIS 的 UID_BASE (stm32f103xe.h, 0x1FFFF7E8) —— 勿再自定义, 会 -Wmacro-redefined */

typedef struct {
  uint32_t magic;
  char     sn[DEVICE_ID_SN_MAX];
  uint32_t xorv;
} dev_id_t;

static dev_id_t s_rec;
static int      s_ready = 0;

/* 简易校验: 旋转异或, 与 param_t 的 crc 思路一致(省代码) */
static uint32_t rec_xor(const dev_id_t *r) {
  uint32_t x = r->magic;
  const uint8_t *p = (const uint8_t *)r->sn;
  uint32_t i;
  for (i = 0; i < DEVICE_ID_SN_MAX; i++) x = (x << 1 | x >> 31) ^ p[i];
  return x;
}

static int rec_valid(const dev_id_t *r) {
  if (r->magic != ID_MAGIC)      return 0;
  if (r->xorv  != rec_xor(r))    return 0;
  if (strlen(r->sn) < 8u)        return 0;   /* 至少 "SN-xxxx" */
  return 1;
}

/* 擦最后一页并写回 32B 记录; 成功返回 1 */
static int flash_write_rec(const dev_id_t *r) {
  const uint16_t *hw = (const uint16_t *)r;
  FLASH_EraseInitTypeDef e;
  uint32_t page_err = 0;
  uint32_t i;

  if (HAL_FLASH_Unlock() != HAL_OK) return 0;

  memset(&e, 0, sizeof(e));
  e.TypeErase   = FLASH_TYPEERASE_PAGES;
  e.PageAddress = DEVICE_ID_ADDR;
  e.NbPages     = 1u;
  if (HAL_FLASHEx_Erase(&e, &page_err) != HAL_OK) { HAL_FLASH_Lock(); return 0; }

  for (i = 0; i < (uint32_t)(sizeof(dev_id_t) / 2u); i++) {
    if (HAL_FLASH_Program(FLASH_TYPEPROGRAM_HALFWORD,
                          DEVICE_ID_ADDR + i * 2u, hw[i]) != HAL_OK) {
      HAL_FLASH_Lock();
      return 0;
    }
  }
  HAL_FLASH_Lock();
  return 1;
}

void device_id_init(void) {
  const dev_id_t *flash = (const dev_id_t *)DEVICE_ID_ADDR;
  int flash_ok = rec_valid(flash);
  char gen[DEVICE_ID_SN_MAX];
  const char *want;

  if (PRODUCT_SN[0] != '\0') {
    /* --- 宏里指定了编号(量产逐台配置) --- */
    if (flash_ok && strcmp(flash->sn, PRODUCT_SN) == 0) {
      memcpy(&s_rec, flash, sizeof(s_rec));      /* 与设备内一致: 不动 Flash */
      s_ready = 1;
      return;
    }
#if !PRODUCT_SN_FORCE_WRITE
    if (flash_ok) {                              /* 策略 0: 保护设备内已有编号 */
      memcpy(&s_rec, flash, sizeof(s_rec));
      s_ready = 1;
      return;
    }
#endif
    want = PRODUCT_SN;
  } else {
    /* --- 宏留空: 用设备内已有记录, 无记录则由 MCU 96bit UID 派生 --- */
    if (flash_ok) {
      memcpy(&s_rec, flash, sizeof(s_rec));
      s_ready = 1;
      return;
    }
    {
      const uint32_t *uid = (const uint32_t *)UID_BASE;
      uint32_t v = uid[0] ^ uid[1] ^ uid[2];
      snprintf(gen, sizeof(gen), "SN-C4F7N-%08X", (unsigned)(v & 0xFFFFFFFFu));
      want = gen;
    }
  }

  /* --- 写入设备(MCU 内部 Flash 末页) --- */
  memset(&s_rec, 0, sizeof(s_rec));
  s_rec.magic = ID_MAGIC;
  strncpy(s_rec.sn, want, sizeof(s_rec.sn) - 1u);
  s_rec.xorv = rec_xor(&s_rec);
  if (flash_write_rec(&s_rec)) s_ready = 1;
}

const char *device_id_get(void) {
  return s_ready ? s_rec.sn : "SN-UNKNOWN";
}
