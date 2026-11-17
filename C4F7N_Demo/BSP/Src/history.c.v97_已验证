/*
 * history.c - 历史浓度记录与存储 (W25Q64, 方案A 一芯两用)
 *
 * 记录格式: 每条 6B 记录: [ts u32 时间][ppm u16]；含 head u32 与序号 seq,
 *   采用环形覆盖写 + 扇区擦除(磨损均衡)；结束判据: ts 4 字节全 0xFF 或
 *
 * 时间戳: [v52 订正] 早前注释写"无外部 RTC 时 = HAL_GetTick()/1000(上电计时)" 已过时——
 *   实际 wall_time_seconds() 转调 main.c 的 rtc_wall_seconds(), 即【屏 RTC 同步得到的真实时钟】
 *   (固件为唯一时间源, 只读屏 RTC 不写)。未完成校时时才退化为开机秒计数。
 */
#include "history.h"
#include "w25q16.h"
#include "param_store.h"
#include "stm32f1xx_hal.h"

#define SECTOR_ADDR(i) ((uint32_t)(HIST_SECTOR_START + (i)) * (uint32_t)W25Q16_SECTOR_SIZE)
#define REC_ADDR(off)  ((uint32_t)(4u + (off) * HIST_REC_SIZE))
#define HEAD_ADDR      0u
#define SEQ_EMPTY      0xFFFFFFFFu
#define TS_EMPTY_MASK  0xFFFFFFFFu   /* 空白 = 时间戳全 FF */

static uint32_t g_written;   /* 已写记录数(用于全盘扫描) */
static uint32_t g_last_ms;   /* 节流 */
static uint32_t g_hist_base; /* 有效数据的起始代数(逻辑清空的起算点), 详见 history_clear() */

static void rec_decode(const uint8_t *b, hist_rec_t *r) {
  r->ts  = ((uint32_t)b[0] << 24) | ((uint32_t)b[1] << 16) | ((uint32_t)b[2] << 8) | b[3];
  r->ppm = ((uint16_t)b[4] << 8) | b[5];
}
static void rec_encode(const hist_rec_t *r, uint8_t *b) {
  b[0] = (uint8_t)(r->ts >> 24); b[1] = (uint8_t)(r->ts >> 16);
  b[2] = (uint8_t)(r->ts >> 8);  b[3] = (uint8_t)r->ts;
  b[4] = (uint8_t)(r->ppm >> 8); b[5] = (uint8_t)r->ppm;
}
static int rec_is_empty(const uint8_t *b) {   /* ts 全 FF = 空点 */
  return b[0] == 0xFF && b[1] == 0xFF && b[2] == 0xFF && b[3] == 0xFF;
}

void history_init(void)
{
  uint32_t i, sz = 0, maxhead = 0;
  uint8_t  b[6];
  int      found = 0;

  g_hist_base = param_get_hist_base();   /* 逻辑清空的起算代数(参数区读出) */

  for (i = 0; i < HIST_SECTORS; i++) {
    w25q16_read(SECTOR_ADDR((uint16_t)i), b, 4);
    uint32_t h = ((uint32_t)b[0] << 24) | ((uint32_t)b[1] << 16) | ((uint32_t)b[2] << 8) | b[3];
    /* head != SEQ_EMPTY(0xFFFFFFFF) 即为有效扇区, 直接纳入比较。
       不能再用 "h > maxhead" 兼作 found 判据: 首个环形扇区的代数 seq = 0,
       而 maxhead 初值同为 0 -> "0 > 0" 不成立, 会被误判为"无任何历史数据",
       使累计记录数 < HIST_CAP(682) 时上电后 g_written 被恢复成 0,
       表现为重启后历史表全空, 且此后每轮都从 idx=0 覆写同一扇区(seq 恒为 0), 永久无法自愈。 */
    if (h != SEQ_EMPTY) {
      if (!found || h > maxhead) maxhead = h;
      found = 1;
    }
  }
  if (!found || maxhead < g_hist_base) { g_written = 0; }   /* [v52] 删去 v51 加的 g_hist_suspicious 观测标志(只置不读=死变量), 保留原判定 */
  else {
    uint32_t gen = maxhead - g_hist_base;              /* 本代(相对代数, 从 0 起) */
    uint32_t ps = (gen % HIST_SECTORS);                /* 物理扇区 = 相对代数 mod N */
    for (sz = 0; sz < HIST_CAP; sz++) {               /* 扫描已写点数(找第一个空点) */
      w25q16_read(SECTOR_ADDR((uint16_t)ps) + REC_ADDR(sz), b, HIST_REC_SIZE);
      if (rec_is_empty(b)) break;
    }
    /* [v97] 自校验: 推算出的【最新片】首点若是空的, 说明代数推算与实际不符
     *   (典型: 参数区 hist_base 错位一代 => ps 指向错误扇区;
     *    或掉电落在"擦片"与"写 head+首点"之间 => 该片有 head 无数据)。
     *   此时若照算 g_written, 历史页会显示【有页数但表格全空】(页数按虚高的
     *   g_written 算, 读取却指向空区), 且后续每写一条都在擦下一片真实数据。
     *   => 先退回上一代的片重试; 仍无数据则判定为无有效历史(g_written=0),
     *      宁可显示"无数据", 也不显示错的页数(同"参数失效可见化"取向)。*/
    if (sz == 0u && gen > 0u) {
      uint32_t ps2 = ((gen - 1u) % HIST_SECTORS);      /* 上一代的片 */
      for (sz = 0; sz < HIST_CAP; sz++) {
        w25q16_read(SECTOR_ADDR((uint16_t)ps2) + REC_ADDR(sz), b, HIST_REC_SIZE);
        if (rec_is_empty(b)) break;
      }
      if (sz == 0u) g_written = 0;                    /* 仍无数据 => 无有效历史 */
      else          g_written = (gen - 1u) * HIST_CAP + sz;
    } else {
      g_written = gen * HIST_CAP + sz;
    }
  }
  g_last_ms = HAL_GetTick();
}

void history_log(uint16_t ppm)
{
  uint32_t now = HAL_GetTick();
  uint32_t idx, sector, off;
  uint8_t  b[HIST_REC_SIZE];
  hist_rec_t rec;

  if (g_written > 0 && (now - g_last_ms) < HIST_PERIOD_MS) return;   /* 节流 */
  g_last_ms = now;

  idx    = g_written;
  sector = (idx / HIST_CAP) % HIST_SECTORS;
  off    = idx % HIST_CAP;

  if (off == 0) {                                    /* 新扇区首点: 整扇区擦除 + 写 head 代数 */
    uint32_t seq = idx / HIST_CAP + g_hist_base;     /* head 存"绝对代数", 上电据此判有效 */
    uint8_t  hb[4] = { (uint8_t)(seq>>24), (uint8_t)(seq>>16), (uint8_t)(seq>>8), (uint8_t)seq };
    w25q16_erase_sector(SECTOR_ADDR(sector));
    w25q16_write(SECTOR_ADDR(sector) + HEAD_ADDR, hb, 4);
  }
  rec.ts  = wall_time_seconds();
  rec.ppm = ppm;
  rec_encode(&rec, b);
  w25q16_write(SECTOR_ADDR(sector) + REC_ADDR(off), b, HIST_REC_SIZE);
  g_written++;
}

/*
 * 逻辑清空历史记录。
 *   历史区的"有效条数"完全由各扇区头里的代数 seq 推导, flash 里没有独立计数;
 *   若逐个擦除 2046 个扇区需 ~92 秒, 故改为"逻辑清空":
 *     把有效数据的起算代数 hist_base 推到 (当前最大代数 + 1),
 *     上电扫描时 maxhead < hist_base -> 视为无数据, g_written = 0。
 *   只写一次参数扇区(~50ms)。旧数据物理上仍在 flash, 但会被后续写入逐步覆盖。
 *   注意: 本函数必须在主循环(非中断)上下文调用 —— 内部含阻塞 flash 写。
 */
void history_clear(void)
{
  uint32_t i, maxhead = 0;
  uint8_t  b[4];
  int      found = 0;

  for (i = 0; i < HIST_SECTORS; i++) {
    w25q16_read(SECTOR_ADDR((uint16_t)i), b, 4);
    uint32_t h = ((uint32_t)b[0] << 24) | ((uint32_t)b[1] << 16) | ((uint32_t)b[2] << 8) | b[3];
    if (h != SEQ_EMPTY) { if (!found || h > maxhead) maxhead = h; found = 1; }
  }
  if (found) {
    g_hist_base = maxhead + 1u;        /* 下一代起重新计数 */
    param_set_hist_base(g_hist_base);
  }
  g_written = 0;
  g_last_ms = HAL_GetTick();
}

/* [v58] 导出起算代数: P0-A 修复需要它把 PP.hist_base 同步到最新值 */
uint32_t history_get_base(void) { return g_hist_base; }

uint32_t history_available(void)
{
  return (g_written > HIST_RING_CAP) ? HIST_RING_CAP : g_written;
}

uint32_t history_total(void)
{
  return g_written;   /* 累计写入总条数(单调递增, 环形覆盖仍计数) */
}

int history_read_one(uint32_t idx, hist_rec_t *r)
{
  uint32_t avail = history_available();
  uint32_t gi, sector, off;
  uint8_t  b[HIST_REC_SIZE];

  if (idx >= avail) return 0;
  gi     = g_written - avail + idx;          /* 环形回绕: idx 归一化到已写范围 */
  sector = (gi / HIST_CAP) % HIST_SECTORS;
  off    = gi % HIST_CAP;
  w25q16_read(SECTOR_ADDR(sector) + REC_ADDR(off), b, HIST_REC_SIZE);
  if (rec_is_empty(b)) { r->ts = 0; r->ppm = 0; return 0; }
  rec_decode(b, r);
  return 1;
}

/* 按秒取, 取最近 seconds 条记录(从0算=全部记录) */
uint16_t history_read_window(uint32_t seconds, hist_rec_t *out, uint16_t max_n)
{
  uint32_t n = (seconds >= HIST_PERIOD_MS) ? (seconds / HIST_PERIOD_MS) : 1u;
  uint32_t avail = history_available();
  uint16_t cnt = 0;

  if (n > max_n) n = max_n;
  if (n > avail) n = avail;
  if (n == 0) return 0;
  { uint32_t start = avail - n;   /* 取最近 n 条, 越界保护 */
    for (; cnt < (uint16_t)n; cnt++) { if (!history_read_one(start + cnt, &out[cnt])) break; }
  }
  return cnt;
}

/* 按秒取, 取最近 seconds 条记录(从0算=全部) */
uint16_t history_read_recent(uint32_t seconds, hist_rec_t *out, uint16_t max_n)
{
  uint32_t n = (seconds >= HIST_PERIOD_MS) ? (seconds / HIST_PERIOD_MS) : 1u;
  uint32_t avail = history_available();
  uint16_t cnt = 0;

  if (n > max_n) n = max_n;
  if (n > avail) n = avail;
  if (n == 0) return 0;
  { uint32_t i;
    for (i = 0; i < n; i++) {       /* idx 越大越新 */
      if (!history_read_one(n - 1 - i, &out[cnt])) break;
      cnt++;
    }
  }
  return cnt;
}

uint16_t history_page_count(uint16_t per)
{
  uint32_t avail = history_available();
  if (avail == 0) return 1;
  return (uint16_t)((avail + per - 1u) / per);
}

/* 第 page 页(1=最新), 行0=最新记录; 返回本页有效行数 */
uint16_t history_read_page(uint32_t page, hist_rec_t *out, uint16_t per)
{
  uint32_t avail = history_available();
  uint16_t pc, row;
  uint16_t cnt = 0;

  if (avail == 0) return 0;
  pc = history_page_count(per);
  if (page < 1) page = 1;
  if (page > pc) page = pc;

  for (row = 0; row < per; row++) {
    /* 最新在 avail-1; 页1行0=最新; 页 page 行 row = avail - ((page-1)*per + row) - 1 */
    uint32_t offset_from_latest = (page - 1u) * per + row;
    if (offset_from_latest >= avail) break;
    uint32_t idx = avail - 1u - offset_from_latest;   /* 全局序号以最旧为0 */
    if (!history_read_one(idx, &out[cnt])) break;
    cnt++;
  }
  return cnt;
}

uint32_t rtc_wall_seconds(void);   /* defined in main.c */
uint32_t wall_time_seconds(void)
{
  return rtc_wall_seconds();   /* MCU 同步的屏 RTC 真实时钟; 未经校时, 退化为开机秒 */
}


/* 预留 CSV 导出; 无空闲导出通道(USART1=屏, UART4=传感器), 当前不实际发送 */
#define HIST_EXPORT_PUT(c) ((void)(c))

void history_export_window(uint32_t seconds)
{
  hist_rec_t r;
  uint32_t n = (seconds >= HIST_PERIOD_MS) ? (seconds / HIST_PERIOD_MS) : 1u;
  uint32_t avail = history_available();
  uint32_t i;

  if (n > avail) n = avail;
  for (i = 0; i < n; i++) {
    if (!history_read_one(i, &r)) break;
    /* TODO: 预留导出通道口, CSV, 格式 "ts,ppm" */
    HIST_EXPORT_PUT((char)(r.ts >> 24));
    HIST_EXPORT_PUT((char)(r.ts));
    HIST_EXPORT_PUT((char)(r.ppm >> 8));
    HIST_EXPORT_PUT((char)(r.ppm & 0xFF));
  }
}