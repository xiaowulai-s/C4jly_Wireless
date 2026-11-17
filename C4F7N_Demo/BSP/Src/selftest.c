/*
 * selftest.c - 启动自检实现 (D3)
 * 全部为非破坏性只读检测, 不调用有副作用动作。
 */
#include "selftest.h"
#include "w25q16.h"
#include "sensor.h"
#include "battery.h"

#define W25Q64_JEDEC_ID 0xEF4017u   /* W25Q64 期望 ID */

void selftest_run(selftest_t *r) {
  if (r == 0) return;
  r->flash_ok  = (w25q16_read_id() == W25Q64_JEDEC_ID);
  r->sensor_ok = sensor_online();
  /* [v50] 原判据 (battery_get_pct() >= 0) 恒真 —— 该函数返回 int 必然 >=0,
     导致电池故障永远检测不到、POST 恒显「自检通过」(P0-A)。
     改判 battery_valid(): 由 battery_poll() 在丢弃 <5V 无效读数时置 0。 */
  r->batt_ok   = battery_valid();
}
