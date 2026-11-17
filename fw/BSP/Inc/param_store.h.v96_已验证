/*
 * param_store.h - 标定参数与设置项的非易失存取 (W25Q64)
 *
 * 扇区规划 (W25Q64: 2048x4KB = 8MB):
 *   [0x00000] 第 0 扇区 (4KB)      : 标定 + 设置 (本模块)
 *       v3 起改为「扇区内追加式写」: 单条 sizeof(param_t)=40B, 每扇区 102 槽,
 *       顺序写到下一个空槽, 写满 102 次才擦一次扇区。
 *       好处: (1) 掉电最多丢最后一条, 旧记录仍在 -> 标定不会静默丢失;
 *             (2) 擦除频率降约 100 倍, 写入寿命充足。
 *   [0x01000..0x7FF000] 扇区1~2047  : 历史数据 (约8.38MB; 6字节/点 -> 139万点)
 */
#ifndef PARAM_STORE_H
#define PARAM_STORE_H

#include <stdint.h>

/* ---- 参数结构 (保存到 W25Q64) ---- */
#define PARAM_MAGIC           0xC4F74A55u  /* 有效标志 */
#define PARAM_VERSION         4u           /* v4: [v79] 加 man_b/man_k(厂家页手动补偿, 与标定值分离)
                                               v3: 两点标定(cal_raw0)+cal_ts+hist_base */

#define PARAM_SECTOR_SIZE     4096u
#define PARAM_SLOTS           (PARAM_SECTOR_SIZE / sizeof(param_t))   /* 102 */
#define PARAM_RAW0_NONE       0x7FFFFFFF   /* cal_raw0 哨兵: 未做过零点标定 */

typedef struct {
  uint32_t magic;          /* 有效性校验 */
  uint32_t version;

  /* 标定 (两点式): ppm_out = raw * cal_k/1000 + cal_b
   *   零点标定只记下点 cal_raw0; 量程标定时用 raw0/raw1 联合解出 k 与 b */
  int32_t  cal_k;          /* 斜率  0.001 定点, 默认 1000 (=1.000, 无增益) */
  int32_t  cal_b;          /* 偏移  ppm,       默认 0   (无偏置)   */
  int32_t  cal_raw0;       /* 零点标定时的原始读数; = PARAM_RAW0_NONE 表示未标定 */
  uint32_t cal_ts;         /* 标定时刻 epoch(秒); 0 = 未标定 */

  /* 历史区 */
  uint32_t hist_base;      /* 历史有效数据的起始代数(逻辑清空的起算点) */

  /* [v79] 厂家页手动补偿(与上面的标定值分离): 屏端键盘输入, 与标定值互不覆盖
   *   man_k/man_b 为 0 表示未手动设定, 此时生效值 = cal_k/cal_b.
   *   手动值优先: 做量程标定时若 man_k 有效, 只用 cal_b 做零点平移, 不覆盖 man_k。 */
  int32_t  man_b;          /* 手动零点补偿 ppm, 0=未手动(范围 ±200) */
  int32_t  man_k;          /* 手动增益补偿 千分比, 0=未手动(范围 100~10000) */

  /* 设置 */
  uint16_t thr_hi;         /* 高报阈值 ppm */
  uint16_t thr_lo;         /* [v96] 低报阈值 —— 已停用(保留占位, 不参与任何判断)。
                             *   刻意不删: 删字段要升 PARAM_VERSION, 会让已出厂设备
                             *   param_load 版本校验失败 => 丢掉用户已做的标定与阈值。 */
  uint8_t  buzzer_en;      /* 蜂鸣器开关 1=开 */
  uint8_t  cal_valid;      /* 1 = 已标定 */
  uint16_t _rsv;           /* 对齐保留 */

  uint32_t crc;            /* 数据区 XOR 旋转校验 */
} param_t;

#define PARAM_FLASH_ADDR    0x000000u   /* W25Q64 0 扇区 */

/* 初始化: 从后往前找最新一条有效记录; 全部无效则填默认值并写回 */
void    param_load_defaults(param_t *p);
void    param_init(param_t *p);

/* 追加式写: 写入下一个空槽(不擦除); 写满 102 槽才擦扇区重来 */
void    param_save(const param_t *p);

/* 恢复出厂: 填默认值, 但**保留 hist_base**(即不撤销"清空历史") */
void    param_factory(param_t *p, int save_now);

/* 历史区起始代数的读写 (供 history.c 逻辑清空使用) */
uint32_t param_get_hist_base(void);
void     param_set_hist_base(uint32_t base);

/* ---- [v59] 参数区失效标志 (P0-B: 让「静默丢参数」变成「可见」) ----
 *
 * 背景: param_save() 写满 102 槽后会擦整个扇区(最坏约 400ms)。若在该窗口内掉电,
 *   下次上电 param_init() 倒序扫 102 槽全部失配 -> 走 dump_defaults() 静默填出厂默认值。
 *   对燃气检漏仪而言危害不在「参数没了」, 而在【用户不知道参数没了】——
 *   阈值悄悄回到 500/100、标定系数回到 1000/0(浓度失准), 而操作者以为一切正常。
 *
 * 本项目的取舍(2026-10-10 用户裁定): 历史数据与参数区【都可丢弃】, 恢复出厂后重设即可,
 *   故**不做备份区/保留槽/双副本**(那些方案是为了保住数据, 在本前提下是过度设计);
 *   改为保证「丢失一定被看见」。
 *
 * 标志必须【跨擦除窗口存活】, 故不能放在扇区 0(会被一起擦掉),
 *   单独占用扇区 2047 的前 8 字节(该扇区原属历史环形区末端;
 *   历史数据已声明可弃, 占用零代价 —— 见 history.h 的 HIST_SECTORS 已改为 2046)。
 *
 * 标志结构(两个 u32, 与 param_t 无关):
 *   [0..3]  magic  = PARAM_FLAG_MAGIC
 *   [4..7]  有效标记 = PARAM_FLAG_SET
 * 采用「magic + 标记」双字段而非单字段: 避免扇区初始全 0xFF 被误判为「已置标志」。
 *
 * 生命周期: param_init() 走默认值分支时置位 -> 用户重设参数(param_save)时清零。
 */
#define PARAM_FLAG_ADDR        0xFFE000u   /* W25Q64 扇区 2047 起始(0x7FF*4096) */
#define PARAM_FLAG_MAGIC       0x464C4732u /* 'FLG2' */
#define PARAM_FLAG_SET         0x5A5A5A5Au

/* 读: 1 = 参数区曾经失效(当前值是出厂默认, 需重新设置); 0 = 正常 */
uint8_t     param_reset_flag(void);
/* 内部用: 置位/清位(不对外暴露, 由 param_init/param_save 内部调用) */

#endif /* PARAM_STORE_H */
