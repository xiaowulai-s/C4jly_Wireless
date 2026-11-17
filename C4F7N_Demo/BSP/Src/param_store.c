/*
 * param_store.c - 标定参数与阈值的持久化存取 (W25Q64 扇区内追加式写)
 *
 * v3 变更: 由「整扇区擦写」改为「追加式写」——
 *   单条记录 40B, 每扇区 102 槽, param_save 只写下一个空槽;
 *   写满才擦一次扇区。掉电最多丢最后一条, 旧记录仍在, 不会静默回默认值。
 */
#include "param_store.h"

/* [v97] 全局参数实例(真名 g_param, 定义在 main.c; main.c 里的 PP 是它的别名宏)。
 *   param_set_hist_base() 需要改它, 以保证全局与 flash 恒同源。*/
extern param_t g_param;
#include "w25q16.h"
#include <string.h>

/* 默认参数: 传感器直出浓度时 MCU 不做校准 (恒等变换) => k=1000(=1.000), b=0 */
#define DEFAULT_CAL_K   1000
#define DEFAULT_CAL_B   0

static void dump_defaults(param_t *p);

/* 计算 CRC (XOR 旋转, 增强校验; 存取时计算并比对) */
static uint32_t calc_crc(const param_t *p) {
  const uint8_t *b = (const uint8_t*)p;
  uint32_t c = 0, i;
  /* crc 字段在末尾, 排除它 */
  uint32_t len = sizeof(param_t) - sizeof(uint32_t);
  for (i = 0; i < len; i++) { c ^= b[i]; c = (c << 1) | (c >> 31); }
  return c;
}

/* 整条记录是否全为 0xFF (空白槽) */
static int rec_is_blank(const uint8_t *b, uint32_t n) {
  uint32_t i;
  for (i = 0; i < n; i++) if (b[i] != 0xFF) return 0;
  return 1;
}

/* ---- [v59] 参数区失效标志: 独立扇区, 跨擦除窗口存活 ---- */
static uint8_t param_flag_read(void) {
  uint32_t w[2];
  w25q16_read(PARAM_FLAG_ADDR, (uint8_t*)w, sizeof(w));
  return (w[0] == PARAM_FLAG_MAGIC && w[1] == PARAM_FLAG_SET) ? 1u : 0u;
}
static void param_flag_set(uint8_t on) {
  uint32_t w[1];
  if (on && !param_flag_read()) w25q16_erase_sector(PARAM_FLAG_ADDR);  /* 首置需擦: magic 区初始全 FF */
  w[0] = PARAM_FLAG_MAGIC;
  w25q16_write(PARAM_FLAG_ADDR, (const uint8_t*)w, sizeof(w));
  w[0] = on ? PARAM_FLAG_SET : 0u;
  w25q16_write(PARAM_FLAG_ADDR + sizeof(uint32_t), (const uint8_t*)w, sizeof(w));
}
uint8_t param_reset_flag(void) { return param_flag_read(); }

/* 找第一个空白槽; 返回 PARAM_SLOTS 表示该扇区已写满 */
static uint32_t find_free_slot(void) {
  uint32_t s;
  uint8_t b[sizeof(param_t)];
  for (s = 0; s < PARAM_SLOTS; s++) {
    w25q16_read(PARAM_FLASH_ADDR + s * sizeof(param_t), b, sizeof(b));
    if (rec_is_blank(b, sizeof(b))) return s;
  }
  return PARAM_SLOTS;
}

static void dump_defaults(param_t *p)
{
  memset(p, 0, sizeof(*p));
  p->magic     = PARAM_MAGIC;
  p->version   = PARAM_VERSION;
  p->cal_k     = DEFAULT_CAL_K;
  p->cal_b     = DEFAULT_CAL_B;
  p->cal_raw0  = (int32_t)PARAM_RAW0_NONE;
  p->cal_ts    = 0;
  p->hist_base = 0;
  p->thr_hi    = 500;
  p->thr_lo    = 100;
  p->buzzer_en = 1;
  p->cal_valid = 0;
  p->_rsv      = 0;
  p->crc       = calc_crc(p);
}

void param_load_defaults(param_t *p) { dump_defaults(p); }

void param_init(param_t *p)
{
  int32_t s;
  /* 从最后一槽往前找最新一条有效记录 */
  for (s = (int32_t)PARAM_SLOTS - 1; s >= 0; s--) {
    w25q16_read(PARAM_FLASH_ADDR + (uint32_t)s * sizeof(param_t), (uint8_t*)p, sizeof(param_t));
    if (p->magic == PARAM_MAGIC && p->version == PARAM_VERSION &&
        p->crc == calc_crc(p)) {
      return;                       /* 命中最新有效记录 */
    }
  }
  /* 全部无效 -> 默认并写回(擦干净重来)
   * [v59] P0-B: 这里【静默】填默认值会让用户误以为参数还在(阈值回到 500/100、
   *   标定回到 1000/0 => 浓度失准)。故置「失效标志」, 由上层在 POST 页提示。
   *   标志写在独立扇区, 不会被本次擦除影响。 */
  param_flag_set(1u);
  dump_defaults(p);
  w25q16_erase_sector(PARAM_FLASH_ADDR);
  w25q16_write(PARAM_FLASH_ADDR, (const uint8_t*)p, sizeof(param_t));
}

void param_save(const param_t *p)
{
  param_t tmp = *p;
  uint32_t slot;

  tmp.magic   = PARAM_MAGIC;
  tmp.version = PARAM_VERSION;
  tmp.crc     = calc_crc(&tmp);

  slot = find_free_slot();
  if (slot >= PARAM_SLOTS) {        /* 已写满 102 槽 -> 擦扇区后从首槽重来 */
    w25q16_erase_sector(PARAM_FLASH_ADDR);
    slot = 0;
  }
  w25q16_write(PARAM_FLASH_ADDR + slot * sizeof(param_t),
               (const uint8_t*)&tmp, sizeof(tmp));
  /* [v59] 参数已重新落盘 => 清除失效标志(P0-B)。用户语义: 重新设过参数就算处理过了。 */
  if (param_flag_read()) param_flag_set(0u);
}

void param_factory(param_t *p, int save_now)
{
  uint32_t hb = p->hist_base;   /* 保留: 恢复出厂不撤销"清空历史" */
  dump_defaults(p);
  p->hist_base = hb;
  if (save_now) param_save(p);
}

uint32_t param_get_hist_base(void)
{
  param_t t;
  param_init(&t);
  return t.hist_base;
}

void param_set_hist_base(uint32_t base)
{
  /* [v97] 必须改【全局 g_param】而不是局部副本 t:
   *   参数区是追加式写(param_save 写下一个空槽), param_init 从后往前找最新 => 后写者胜出。
   *   旧实现用局部 t(从 flash 读出的旧副本)落盘, 而 param_save_safe() 用全局 g_param 落盘,
   *   两者数据源不同 => 后者会把陈旧的 hist_base 写回去, 清空标记被静默回退,
   *   开机恢复时代数算偏一代 => 历史页【有页数但表格全空】, 且真实历史被逐步擦光。
   *   改为直接改全局再落盘, 全局与 flash 恒同源, 不可能被覆盖。*/
  g_param.hist_base = base;
  param_save(&g_param);
}
