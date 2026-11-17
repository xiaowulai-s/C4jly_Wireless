/*
 * device_id.c - �? device_id.h
 *
 * 记录布局(32 字节, 自然对齐�? padding):
 *   magic(4) + sn[24] + xorv(4)
 * STM32F1 �? Flash �? 16bit 半字编程, 故以 uint16 视图逐半字写�?
 */
#include "device_id.h"
#include "stm32f1xx_hal.h"
#include <stdio.h>
#include <string.h>

#define ID_MAGIC   0x4E533031u        /* 内部有效性标�? */

/* [v45 / N5] 编译期长度检�?: PRODUCT_SN 超过屏端可显上限会被静默截断 ->
 * 此处超长直接编译报错(typedef 负数组长�?)。改 product_info.h �? SN 时若报错即为此因�? */
typedef char product_sn_len_ok[(sizeof(PRODUCT_SN) - 1u) <= PRODUCT_SN_DISPLAY_MAX ? 1 : -1];
/* 96bit 唯一 ID 基址直接�? CMSIS �? UID_BASE (stm32f103xe.h, 0x1FFFF7E8) —�? 勿再自定�?, �? -Wmacro-redefined */

typedef struct {
  uint32_t magic;
  char     sn[DEVICE_ID_SN_MAX];
  uint32_t xorv;
} dev_id_t;

static dev_id_t s_rec;
static int      s_ready = 0;

/* 简易校�?: 旋转异或, �? param_t �? crc 思路一�?(省代�?) */
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
    /* --- 宏里指定了编�?(量产逐台配置) --- */
    if (flash_ok && strcmp(flash->sn, PRODUCT_SN) == 0) {
      memcpy(&s_rec, flash, sizeof(s_rec));      /* 与设备内一�?: 不动 Flash */
      s_ready = 1;
      return;
    }
#if !PRODUCT_SN_FORCE_WRITE
    if (flash_ok) {                              /* 策略 0: 保护设备内已有编�? */
      memcpy(&s_rec, flash, sizeof(s_rec));
      s_ready = 1;
      return;
    }
#endif
    want = PRODUCT_SN;
  } else {
    /* --- 宏留�?: 用设备内已有记录, 无记录则�? MCU 96bit UID 派生 --- */
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

/* raw byte writer used by the v1.1 block (page must already be erased) */
static int wl_style_write(uint32_t addr, const uint8_t *data, uint32_t n) {
    uint32_t i;
    if (HAL_FLASH_Unlock() != HAL_OK) return 0;
    for (i = 0; i < n; i += 2u) {
        uint16_t hw = (uint16_t)(data[i] |
                        (i + 1u < n ? (uint16_t)(data[i + 1u] << 8) : 0u));
        if (HAL_FLASH_Program(FLASH_TYPEPROGRAM_HALFWORD, addr + i, hw) != HAL_OK) {
            HAL_FLASH_Lock();
            return 0;
        }
    }
    HAL_FLASH_Lock();
    return 1;
}
/* v1.1 wireless bridge: SN burn + factory auth hash (ASCII only)
 * auth hash record sits 0x40 bytes into the id page, same erase unit */
#define AUTH_MAGIC   0x314C5743u   /* C W L 1 little-endian */
#define AUTH_ADDR    (DEVICE_ID_ADDR + 0x40u)
#define AUTH_LEN     DEVICE_ID_AUTH_LEN

typedef struct {
    uint32_t magic;
    uint8_t  hash[AUTH_LEN];
    uint32_t xorv;
} auth_rec_t;

static uint32_t auth_xor(const auth_rec_t *r) {
    uint32_t x = r->magic;
    for (uint32_t i = 0; i < AUTH_LEN; i++) x = (x << 1 | x >> 31) ^ r->hash[i];
    return x;
}

int device_id_auth_hash_get(uint8_t out[AUTH_LEN]) {
    const auth_rec_t *p = (const auth_rec_t *)AUTH_ADDR;
    if (p->magic != AUTH_MAGIC) return 0;
    if (p->xorv != auth_xor(p)) return 0;
    memcpy(out, p->hash, AUTH_LEN);
    return 1;
}

/* one erase serves both records: rewrite SN then hash */
int device_id_auth_hash_set(const uint8_t hash[AUTH_LEN]) {
    dev_id_t keep;
    auth_rec_t a;
    memcpy(&keep, (const dev_id_t *)DEVICE_ID_ADDR, sizeof(keep));
    if (!rec_valid(&keep)) return 0;          /* SN must exist first */
    memset(&a, 0, sizeof(a));
    a.magic = AUTH_MAGIC;
    memcpy(a.hash, hash, AUTH_LEN);
    a.xorv = auth_xor(&a);
    if (!flash_write_rec(&keep)) return 0;    /* erase + SN + lock */
    wl_style_write(AUTH_ADDR, (const uint8_t *)&a, sizeof(a));
    return 1;
}

int device_id_set_sn(const char *sn) {
    dev_id_t r;
    auth_rec_t keep;
    size_t n;
    if (sn == NULL) return 0;
    n = strlen(sn);
    if (n < 8u || n >= DEVICE_ID_SN_MAX) return 0;
    memset(&r, 0, sizeof(r));
    r.magic = ID_MAGIC;
    memcpy(r.sn, sn, n + 1u);
    r.xorv = rec_xor(&r);
    /* preserve auth hash across the page erase */
    memcpy(&keep, (const auth_rec_t *)AUTH_ADDR, sizeof(keep));
    if (!flash_write_rec(&r)) return 0;       /* erase + SN + lock */
    wl_style_write(AUTH_ADDR, (const uint8_t *)&keep, sizeof(keep));
    memcpy(&s_rec, &r, sizeof(s_rec));
    s_ready = 1;
    return 1;
}
