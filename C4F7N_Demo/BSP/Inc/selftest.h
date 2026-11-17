/*
 * selftest.h - 启动自检 (D3)
 * 上电遮罩期内一次性检测关键外设, 结果供显示层决定状态圆点/文案。
 * 失败仅将对应圆点置灰, 不打断功能、不新增交互流程。
 */
#ifndef SELFTEST_H
#define SELFTEST_H

#include <stdint.h>

/* 自检结果位 */
typedef struct {
  uint8_t flash_ok;   /* W25Q64 读 JEDEC ID 通过(0xEF4017) */
  uint8_t sensor_ok;  /* GC5G1 首帧/在线 有效 */
  uint8_t batt_ok;    /* 电池采样有效(非 <5V 无效读数) */
} selftest_t;

/* 运行一次自检(通常在 param_init 之后、首次周期刷新前调用), 顶层清零后逐项填充 */
void selftest_run(selftest_t *r);

#endif /* SELFTEST_H */
