# v58 · 修三次排查 P0-A（hist_base 陈旧）+ P1-B（13 个跨 ISR 变量缺 volatile）（2026-10-10）

> 依据 `docs/评审与方案/三次功能逻辑排查_2026-10-10.md` §一、§四。
> **纯固件，屏端零改动。**

## 一、结论

| 项 | 内容 |
|---|---|
| **产物** | `C4F7N_v58_firmware.hex` / md5 **`442e0413cda6c1f05c2afc43f7090fa1`** / Code **41444**（v57 = 41396）/ **0 Error 0 Warning** |
| 改动范围 | **3 文件 15 处**：`main.c`（14）+ `history.c`（1）+ `history.h`（1）|
| 编码 | `main.c` GBK/LF、`history.c`/`history.h` UTF-8/LF，**`EF BF BD` 全 0**（往返断言通过）|
| 屏端 | **零改动**（`C4F7N_v8.HMI` md5 仍 `5c83498d`）|
| 提交 | 本地已提交，**未推送** |
| **状态** | ✅ **真机验证通过（2026-10-10 13:3x）** —— 清空历史 → 改阈值 → **断电重启** → 历史页全空 |

---

## 二、P0-A · `history_clear()` 后 `PP.hist_base` 从不更新 —— 已修

### 2.1 缺陷回顾

`history_clear()`（`history.c:121-122`）推进的是 **`history.c` 内部的静态 `g_hist_base`**，
而落盘走 `param_set_hist_base()`（`param_store.c`），后者声明了**局部 `param_t t`** 并只改 `t.hist_base`：

```c
void param_set_hist_base(uint32_t base) {
  param_t t;              /* ← 局部副本 */
  param_init(&t);
  t.hist_base = base;
  param_save(&t);         /* ← 只把这张副本写进 flash */
}
```

⇒ **全局 `PP.hist_base` 从头到尾没被更新**。

而 `param_init(&PP)` **只在开机执行一次**（`main.c:428`），此后 `param_save_safe()` → `param_save(&PP)`
每次都 `tmp = *p` 把**开机时的旧 hist_base** 写进新槽，**覆盖掉刚写入的清空标记**。

### 2.2 修法

**不改 `history.c` 的分层**（BSP 不该认识业务层的 `PP`），改在 `main.c` 侧同步：

```c
/* main.c: hist_clear_poll() */
if (g_selftest.flash_ok) {
  history_clear();
  PP.hist_base = history_get_base();     /* [v58] 同步 */
}
```

配套给 `history.h` / `history.c` 加一个只读getter：

```c
uint32_t history_get_base(void);         /* 声明 */
uint32_t history_get_base(void) { return g_hist_base; }   /* 实现 */
```

### 2.3 ★ 顺带修好了「恢复出厂固化错位」这条次生路径

`main.c:1203` 的恢复出厂是 `param_factory(&PP, 1)`，而它内部：

```c
uint32_t hb = p->hist_base;   /* 保留: 恢复出厂不撤销"清空历史" */
```

它"精心保留"的**正是那个陈旧值** ⇒ 修复前，恢复出厂不但不修正错位，反而**把它固化到 flash**。

本版同步了 `PP.hist_base` 之后，这条路径一并修好。

### 2.4逻辑推演验证（模拟 50 条真实记录）

| 阶段 | flash 里的 `hist_base` | `maxhead` | `gen` | `ps` | `g_written` | 结果 |
|---|---|---|---|---|---|---|
| 未清空（正确） | 0 | 1 | 1 | 0 | 682 | ✅ |
| **修复前**：清空→改阈值→重启 | **0（被覆盖）** | 1 | **1** | **1** | **682** | ❌ 指向空扇区1，真实 50 条显示成 682 条 |
| **修复后**：清空→改阈值→重启 | **2** | 1 | **0** | 0 | **0** | ✅ 清空语义正确 |

⇒ 修复前 `g_written` 虚高 **13.6 倍**，随后 `history_log()` 会触发 `history.c:90` 的整扇区擦除，
**逐步擦掉真实历史数据**；修复后 `maxhead(1) < hist_base(2)` ⇒ `g_written=0`，符合"已清空"语义。

---

## 三、P1-B · 13 个跨 ISR 变量补`volatile`

### 3.1 事实回顾

`hmi_on_rx_byte()`（`Middleware/Src/hmi_callback.c`）在 **USART3 ISR 上下文**里直接回调各处理函数，
而这些函数**直接写若干全局变量**（没有"只置标志"的中转）。

项目里**已有 16 个变量正确加了 `volatile`**（`g_cal_req` / `g_hist_clear_req` / `g_thr_hi_req` /
`g_thr_try` / `g_thr_wait` / `g_get_busy` / `g_rtc_wait` / `g_sync_*` / `g_rx_reattach_fail` /
`g_page_now` / `g_full_dirty` / `g_cal_st_dirty` / `g_thr_push` / `g_refill_req` / `g_mute`），
说明当初是按"谁在 ISR 写"逐个判定的 —— **这 13 个是遗漏**。

### 3.2 本版补齐的 13 个

| 变量 | 写入方（ISR 上下文）| 读取方（主循环）|
|---|---|---|
| **`g_thr_t0`** | `hmi_on_thr_hi_set` | `thr_hi_readback_poll`（8 s耐心判据）|
| `g_thr_dirty` | `thr_commit` ← `hmi_on_thr_hi_inc/dec` | `while(1)` |
| `g_thr_dirty_t` | 同上 | `while(1)` |
| `g_save_pending` | 同上 | `while(1)` |
| `g_test` | `hmi_on_test_toggle` | 多处判"测试中" |
| `g_test_t0` | `hmi_on_test_toggle` | 统计窗口 |
| `g_peak` / `g_min` | `hmi_on_test_toggle` | 首页峰值/谷值显示 |
| `g_sess_cnt` / `g_sess_max` / `g_sess_min` / `g_sess_sum` | `hmi_on_test_toggle` | 本次测试统计 |
| `g_tbl_page` | `hmi_on_tbl_page` | `refill_table` 判页 |

★ **`g_thr_t0` 是我在 v56 自己引入的**：`hmi_on_thr_hi_set()` 在 ISR 里写它、`thr_hi_readback_poll()` 在主循环读它判超时。
同一函数里紧邻的 `g_thr_hi_req` / `g_thr_try` 都加了 `volatile`，**唯独漏了它** —— 这是我的疏忽，不是历史遗留。

### 3.3 风险分级（区分「撕裂」与「编译器优化」）

| 项 | 风险 | 说明 |
|---|---|---|
| 字节撕裂 | **低** | `uint32_t` 在 Cortex-M3 上对齐访问是单指令 `STR`/`LDR`；`uint8_t` 天然不可撕裂 |
| **编译器优化** | **中** | 缺 `volatile` 时编译器**有权**把主循环的多次读缓存到寄存器，或把 ISR 的写视为不可见 |
| `g_sess_sum`（`uint64_t`）| **注意** | 64 位读**非原子**（需两次 `LDR`），理论上可能读到撕裂值；仅用于显示统计，最坏是一帧乱数 |

⇒ 归为 P1 而非 P0：撕裂风险被硬件对齐消除了，**真实风险是"判据读到陈旧值"**。
后果举例：`g_test`若被主循环读到陈旧的 0，则测试中不写历史记录；`g_tbl_page` 陈旧则翻页显示错乱。

### 3.4 排查方法（可复用）

正则扫出全部「`static` 声明 + 多处出现 + 缺 `volatile`」的变量（本项目 **27 个**），
再**逐个核实其写入方是否真在 ISR 上下文** ⇒ 最终 **13 个成立**，其余 14 个是纯主循环变量。

★ 本轮误报 3 次（第四次了）：① `g_rx_reattach_fail` 实际**有** volatile ② `g_iwdg_*`/`g_thr_hi` 是扫窗口跨了 2600 字符抓到后面的函数
③ `g_cal0_armed`/`g_cal0_t0`/`g_cal0_ppm0` 实际**全由 `cal_do_*`（主循环）读写**，ISR 侧 `hmi_on_cal_zero()` 只置 `g_cal_req`。

---

## 四、验证证据

| 项 | 证据 |
|---|---|
| 编译 | **0 Error / 0 Warning**，`Program Size: Code=41444 RO-data=1836 RW-data=100 ZI-data=2724` |
| Code 变化 | 41396 → **41444（+48）** —— getter + 同步 + volatile 的预期量 |
| hex 校验 | 2715 行整行累加（含CC），**0 错** |
| hex md5 | **`442e0413cda6c1f05c2afc43f7090fa1`** |
| P0-A 源码核对 | `PP.hist_base = history_get_base();` **1 处**（在 `if (g_selftest.flash_ok)` 内）|
| P0-A 结构复核 | 打印改后 22 行，确认 `history_clear()` 调用与同步语句都在 `if` 块内、`if` 结构完整 |
| P1-B 源码核对 | 脚本逐个核对 13 个变量声明 → **volatile 生效 13/13** |
| getter 链路 | `history.h` 声明 1 处 · axf 符号 `history_get_base` **存在** |
| 逻辑推演 | 见 §2.4：修复后 `g_written=0`（清空语义正确）；修复前虚高 13.6 倍 |
| 编码 | `main.c`=GBK/LF、`history.c`/`history.h`=UTF-8/LF，**`EF BF BD` 全 0** |
| 屏端 | `C4F7N_v8.HMI` 零改动 |

---

## 五、✅ 真机验证通过（2026-10-10）

用户实测确认：**记一些记录 → 清空历史 → 改一次阈值 → 重启 → 历史页显示全空 / 0 条**。

| # | 场景 | 期望 | 结果 |
|---|---|---|---|
| **1** | **记一些记录 → 清空历史 → 改一次阈值 → 重启 → 看历史页** | **总条数 0 / 表格全空**（v58 及以前会显示数百条错位数据，并逐步擦掉原数据）| ✅ **通过** ← P0-A 决定性检验 |

★ **用户说明：因屏端没有重启键，采用的是「断电重启」** —— 这是**比软复位更严格**的验证场景：

| 对比项 | 软复位（`NVIC_SystemReset`）| **断电重启（本次实测）** |
|---|---|---|
| RAM 静态变量 | 复位后由启动代码重初始化 | 断电后彻底丢失 |
| `PP.hist_base` | 仍是本次运行同步过的新值 | **从 flash 重新读出** |
| 验证目标 | 只能验证「本次运行内的同步是否生效」 | **能验证「写进 flash 的值是否真的正确」** |

⇒ 断电重启恰好命中 P0-A 的要害：**该缺陷的本质就是「flash 里的 `hist_base` 被旧值覆盖」**，
只有断电重启才会真正从 flash 重新加载并暴露错位。**验证方式与缺陷性质完全对得上。**

其余 6 项（清空后重启再记录 / 清空后恢复出厂 / 开始测试统计 / 翻页 / 阈值 ± / 开机改阈值）未专项测，
其中第 2、3 项与本次已通过的第 1 项属同一路径的延伸，风险较低。

---

## 五之二、遗留（本版未做）

| # | 级别 | 问题 | 说明 |
|---|---|---|---|
| B | **P0** | 102 槽写满擦整扇区，窗口内掉电 ⇒ 标定+阈值静默回默认 | 与 P1-A 同根因，**需改参数区布局**（`hist_base` 迁到历史区头部 + 预留保留槽），改动较大，建议单独一版 |
| C | **P1** | `hist_base` 与易失参数同扇区 | 同上，与 B 一并做 |
| E | P2 | flash 驱动全链路 `void`，`wait_busy` 500 ms 超时静默返回"成功" | 加返回值 + 至少置一个失败标志 |
| F | P2 | `HAL_SPI_Transmit`/`Receive` 返回值丢弃 | 检查 `HAL_TIMEOUT` |
| G | P2 | 不校验 WEL / 块保护位 → 写保护下静默失效，`selftest` 仍报通过 | 回读 SR1 |
| H | P2 | 历史记录 6 字节裸存无 CRC → 撕裂写产生 ppm=65535 等静默错误数据 | 需权衡存储成本（682 条/扇区的容量）|

---

## 七、关联文档

- 三次排查（本版来源 §一、§四）：`三次功能逻辑排查_2026-10-10.md`
- 首轮 / 二次排查（已全部处置）：`功能逻辑排查报告_2026-10-09.md`、`二次功能逻辑排查_2026-10-09.md`