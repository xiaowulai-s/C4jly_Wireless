# C4F7N 便携式检漏仪 · 项目交接文档（HANDOVER）

> ## ⚡ 当前交付基线（2026-10-29）
>
> | 项 | 值 |
> |---|---|
> | 固件 | **`V1.0-b98`**，`main.c` md5 `69be0a3d1f00eddb65eb068cc5a1a82f`，产物 hex md5 `6ec3c1142b28b95ac4db9f45d5908f54`，⏳ **部分真机验证**（满电 100% 已通过；Total RO 53636 / ROM 53748）|
> | 固件 HEX | `C4F7N_Demo/MDK-ARM/C4F7N_Demo/C4F7N_Demo.hex` md5 `d5d396733f4a97cf974a1a553be10f5f` |
> | 屏端 | **`C4F7N_v12.HMI`** md5 `2cd86542fee35fd9006055e6206909f4`（53635680 B），✅ 用户经 TJC 编辑器打开并保存验证 |
> | 屏页 ID | 0主页 / 1历史 / 2设置 / 3初始化 / 4keybdB / 5厂家设置（★ **屏页 ID ≠ `.pa` 槽号**）|
> | 屏口 | USART3(PB10/PB11) **115200**；屏端 `Program.s` 已配 `baud=115200` |
> | 进页屏障 | `HMI_PAGE_SETTLE_MS = 60u` |
> | 参数版本 | `PARAM_VERSION = 4u`（含 `man_b` / `man_k` 手动补偿字段）|
> | 编译校验 | `node _link_check.js`（从 `.uvprojx` 读清单全量 `-c` + **链接**，需 `dangerouslyDisableSandbox:true`）|
> | 回退基线 | `main.c.v92_已验证`（= 当前）· `main.c.v91_已验证`（含诊断计数版）|
> | 详细记录 | `docs/变更记录/v79_92_厂家页手动补偿与屏固链路收口_2026-10-15.md`（本批）· [v65~v78](docs/变更记录/v65_78_屏端镜像收敛与滑动翻页改造_2026-10-14.md)（10-14）|
>
> **本批（10-15）新增**：厂家页手动补偿 `cal_b` / `cal_k`（键盘输入 + 手动值优先 + 20% 二次确认）——
> 固件 v79~v92 **改 8 版才收口**，八版根因链见变更记录与 `AGENTS.md` §4.5 / `HANDOVER.md` §10.6 七条硬约束。
> 屏包全量归档至移动云盘 `D:\移动云盘同步盘\C4F7N检漏仪\`（98 文件 2.6 GB）。
>
> ⚠️ **本文件 §1.3/§1.4/§5.1/§6.3/§7.1/§8.1 已于 10-15 推至当前基线**；
> 更早章节（§11 待确认项清单等）仍含 09-18~09-20 的历史产物引用，**属历史记录，不改**。
> ⚠️ **`.HMI` 屏包不入库**（`.gitignore` 含 `*.HMI`），仓库不是屏包备份源，**须另行备份**（见 `README.md` §屏包与固件归档）。

---

> **读者**：接手本项目继续开发的 AI（零上下文）。
> **用途**：让接手者在不依赖历史对话的前提下，能理解系统、编译/打包、联调、加功能、长期维护。
> **项目根**：`d:\Demo\C4jly\`
> **最后更新**：2026-10-15（厂家页手动补偿 `cal_b`/`cal_k` 落地，固件 v79~v92 收口 + 屏端 v12 增补补偿控件；§1.3/§1.4/§5.1/§6.3/§7.1/§8.1/§8.6/§10.3/§10.6 已推至当前基线。10-14 及更早详见 `docs/变更记录/`，早期修正溯源见 `docs/交接/HANDOVER_2026-09-18.md`）
> **配套文档**：`README.md`（总览）、`DOCS.md`（导航）、`C4F7N_Demo/README.md`（固件）、`C4F7N_Demo/待确认项清单.md`（待确认项）、`tjc-hmi-toolkit/*.md`（屏端工具链）

## 阅读约定

| 标记 | 含义 |
|---|---|
| ✅ | 已确认（有实测/编译/工具证据） |
| 🟡 | 代码已实现且编译通过，**但未真机验证** |
| ⬜ | 待确认 / 待实施（决策未落地或缺硬件验证） |
| ⚠️ | 高风险或易踩坑，务必先读「第 10 章 硬性限制」 |

---

## 1. 项目概览

### 1.1 产品定位

用于 **GIS / 高压断路器 / 环网柜** 等环保绝缘气体（**C4F7N / Novec 4710，全氟异丁腈**）的**便携式泄漏检测仪**。

### 1.2 系统构成

| 部件 | 型号/规格 | 说明 |
|---|---|---|
| 主控 MCU | **STM32F103RCT6**（LQFP64，256KB Flash / 48KB RAM） | HAL 库，**AC6 (ARMCLANG 6.24)** 工具链（见 §4.4） |
| 传感器 | **GC5G1 NDIR** 全氟异丁腈传感模组 | UART 数字帧输出 |
| 显示 | **TJC 7 寸 USART HMI，1024×600** | 淘晶驰串口屏（TJC X5），工程 `.HMI` |
| 存储 | **W25Q64**（SPI Flash，8MB / 2048 扇区） | 参数 + 历史数据 |
| 电池 | 锂电池（14.8V / 16.8V），分压采样 | PB1(ADC1_IN9)，R22=100k / R23=24k |

### 1.3 当前状态（2026-10-15）

| 项 | 状态 | 证据 |
|---|---|---|
| 固件编译 | ✅ **0 Error / main.c 0 Warning**（全工程仅剩 HAL 库 1 个既有警告），`PRODUCT_FW_VERSION="V1.0-b98"`，`_link_check.js` 37/37 链接通过 |
| 屏端工程 | ✅ `C4F7N_v12.HMI`，**6 页**（0主页/1历史/2设置/3初始化/4keybdB/5厂家）全部通过（`pages ok=6 bad=0`）；`audit_hmi` 6 处与基线一致零新增；固件引用对象**零悬空** | `verify_all_pages.exe` / `audit_hmi.js` / `_fw_obj_xcheck.js` |
| 整机真机联调 | ✅ **v42~v92 全部真机验证通过**。含标定链路/阈值闭环/按键音/初始化页/报警/历史页、电量链路三真机闭环、低电三级按百分比、零点标定两步确认、硬件 IWDG、顶栏镜像方案B + 圆点直写、**滑动翻页入屏信号（v78）** | `docs/变更记录/` 逐版记录 + `开发进度表.md` §一 |
| 厂家页手动补偿（新增） | ✅ **v79~v92 已真机全项通过**：改 b/k → 点校B/校K → **一次即生效**；断电重启值保留；k 改动超 20% 需二次确认（按「值有没有变」判定，无时间窗口）| 详见 §8.6 |
| 编码整理 | ✅ `C4F7N_Demo` 源文件 `EF BF BD` 残留 **0**。⚠️ **混合编码**（`main.c`/`param_store.h`=GBK/LF、`param_store.c`=GBK/纯CRLF、`protocol.h`/`hmi_callback.*`=UTF-8/LF），改写前必须逐文件判定，见 §10.1 | `docs/编码治理/C4F7N_中文注释乱码修复报告.md` |
| 屏包备份 | ✅ `.HMI` 不入库；**云盘主备份 `D:\移动云盘同步盘\C4F7N检漏仪\`**（98 文件 / 2.6 GB，逐文件 md5 与源零不一致）| `README.md` §屏包与固件归档 |

### 1.4 关键产物

> ★ **屏固必须配套**：v12 屏含厂家页手动补偿控件，**必须配 `V1.0-b79` 及以后的固件**。

| 产物 | 路径 |
|---|---|
| **当前固件 HEX** | `C4F7N_Demo/MDK-ARM/C4F7N_Demo/C4F7N_Demo.hex`（**v98 产物**，md5 `6ec3c1142b28b95ac4db9f45d5908f54`，151235 B，Keil Rebuild 0 Error 0 Warning）|
| **当前源码基线** | `C4F7N_Demo/Core/Src/main.c` md5 `69be0a3d1f00eddb65eb068cc5a1a82f`；`PRODUCT_FW_VERSION = "V1.0-b98"`；回退快照 `main.c.v97_已验证`（v97：`main.c.v96_已验证`）|
| 本地回退快照（不入库） | `C4F7N_Demo/Core/Src/main.c.v*_已验证`（v76~v92 共 17 个，`.gitignore` 已排除）|
| 固件 HEX（归档轮次） | `tjc-hmi-toolkit/C4F7N/C4F7N_v41~v63_firmware.hex`（19 个）；更早的 v4~v40 已于 2026-10-14 删除 |
| Keil 工程 / CubeMX | `C4F7N_Demo/MDK-ARM/C4F7N_Demo.uvprojx` / `C4F7N_Demo/C4F7N_Demo.ioc` |
| **当前屏端工程** | `tjc-hmi-toolkit/C4F7N/C4F7N_v12.HMI`（6 页，md5 `2cd86542fee35fd9006055e6206909f4`，53635680 B）|
| 屏端编译产物 | `tjc-hmi-toolkit/C4F7N/C4F7N_v*.tft`（17 个；需在 USART HMI Editor 打开 `.HMI` 后另存导出，**无法程序化生成**）|
| 屏端历史版本 | `tjc-hmi-toolkit/C4F7N/C4F7N_v1~v11.HMI`（+ 39 个实验件 `v4_fix*`/`v9_*`/`_v100_*`）；旧命名轨 `C4F7N_HMI_v18~v100` 已于 2026-09-24 移出仓库 |
| 屏包备份（本地 / 云盘） | `D:\Demo\C4jly\屏包备份\` / `D:\移动云盘同步盘\C4F7N检漏仪\`（**`.HMI` 一律不入库**）|

> **本表基线日期 2026-10-15**。屏固**配套关系**是硬约束：换屏必须同步确认固件是否 ≥ 配套版本。
> 屏页 ID 与 `.pa` 槽号的对应见 §5.1；**固件侧 `hmi_on_page_enter(p)` 的 p 在「历史↔设置」上与屏页 ID 互换**，见 §10.2。

---

## 2. 仓库与目录地图

### 2.1 顶层结构

```
d:\Demo\C4jly\
├── README.md                      # 项目总览（UTF-8）
├── DOCS.md                        # 文档导航 / 硬件连接速查
├── docs/c4f7n_full_dataflow_detail.html# 全链路数据流详图
├── GC5G1(C4F7N)...V2.2.pdf        # 传感器规格书（命门参考）
│
├── C4F7N_Demo/                    # ★ 主控固件工程
├── tjc-hmi-toolkit/               # ★ 屏端程序化生成工具链
├── C4F7N_Hardware/               # 产品/硬件/规格文档 + KiCad 工程（原 `C4F7N_LeakDetector/`）
└── HMI/                           # 早期屏工程与开发资源（v17b 等）
```

> **2026-09-24 目录调整**：`led/` → **`text_demo/`**；`C4F7N_LeakDetector-output/`（KiCad elibz/epro）与 `C4F7N_HMI_v3/`（屏端改版试验）**已移除**。

### 2.2 固件工程 `C4F7N_Demo/`

```
C4F7N_Demo/
├── Core/                 # ★ CubeMX 管辖：仅可改 USER CODE 段
│   ├── Inc/  main.h usart.h gpio.h adc.h spi.h stm32f1xx_it.h
│   └── Src/  main.c(=应用主体) usart.c gpio.c adc.c spi.c stm32f1xx_it.c
├── Drivers/              # CubeMX 生成（HAL + CMSIS），勿手改
├── BSP/                  # 自管：设备驱动
│   ├── Inc|Src/  sensor.*  battery.*  pump.*  w25q16.*  history.*  param_store.*
├── Middleware/           # 自管：通信协议
│   ├── Inc|Src/  tjc_cmd.*  hmi_callback.*  hmi_get.*  c4f7n_hmi_protocol.h
├── MDK-ARM/              # Keil 工程 + startup + 产物
│   ├── C4F7N_Demo.uvprojx
│   ├── C4F7N_Demo/       # Keil 输出（.hex/.axf）
│   └── build/            # eIDE 输出（.hex/.axf）
├── .eide/eide.yml        # eIDE 工程配置
├── C4F7N_Demo.ioc        # CubeMX 工程
├── README.md             # 固件总览/接线/约束
└── 待确认项清单.md       # ★ 未验证项与已决定待实施项
```

**关键文件职责**

| 文件 | 职责 |
|---|---|
| `Core/Src/main.c` | 应用主体：`main()`、`app_refresh()`(250ms)、`HAL_UART_RxCpltCallback()`、全部 HMI 回调 `hmi_on_*()` |
| `Core/Src/usart.c` | **USART3 初始化（9600 8N1，PB10/PB11）— 串口屏**；USART1（115200，PA9/PA10）保留为预留 |
| `Core/Src/adc.c` / `spi.c` | ADC1(IN9/PB1) 电池采样 / SPI1(W25Q64) |
| `BSP/Src/sensor.c` | GC5G1 UART4 帧解析、标定换算、在线判定（**UART4 在本文件手工配置，不在 .ioc**） |
| `BSP/Src/history.c` | W25Q64 环形历史存储（写入/读取/分页/统计） |
| `BSP/Src/param_store.c` | `param_t` 非易失存取（CRC + 版本） |
| `Middleware/Src/tjc_cmd.c` | MCU→屏指令封装（自动追加 `FF FF FF` 帧尾） |
| `Middleware/Src/hmi_callback.c` | 屏→MCU 命令码分发 `switch` |
| `Middleware/Src/hmi_get.c` | `get` 应答帧解析（回读屏端数值） |
| `Middleware/Inc/c4f7n_hmi_protocol.h` | **协议单一事实源**：命令码 / 对象名 / 指令宏 / 颜色 |

### 2.3 屏端工具链 `tjc-hmi-toolkit/`

```
tjc-hmi-toolkit/
├── gen_hmi2.js          # 通用生成器：config.json → .pa 页面块
├── lib/                 # Node 解析库
│   ├── page.js          #   .pa 解析/构建（parse/get/build/set/marker）
│   ├── stamp.js         #   块 stamp（CRC32 ^ K 表）
│   ├── container.js     #   .HMI 容器读写
│   └── png.js / rgb565.js
├── seeds/               # 控件种子 .pa（tpl_am1_pas / tpl_s1/s3/s4/s5 / jd_pas）
├── tools/               # 打包与验证（.NET 自包含，勿单独移动 exe）
│   ├── hmipack-tjc.exe      # 打包器：模板 + 资源目录 → .HMI
│   ├── verify_all_pages.exe # 全页验证（引擎级）
│   ├── check-page.exe       # 单页验证（需精确页名）
│   ├── extract-pas.exe      # 从 .HMI 提取 .pa
│   ├── extract-res.exe      # 提取资源
│   └── dump-main.exe / dump-main-c.exe
├── template/am1_1024x600.HMI  # 基础模板（X5 1024×600）
├── C4F7N/               # ★ 目标工程
│   ├── C4F7N_v12.HMI  #   ★ 当前交付屏工程（10-15，6 页 verify ok=6 bad=0，含厂家页手动补偿控件）
│   ├── C4F7N_v11.HMI  #   上一版（10-14：顶栏镜像收敛 + 各页 load 补 printh 4N + 滑动翻页）
│   ├── C4F7N_v4_fix2.HMI#   历史已验证基线（09-18，6 页 check=33 OK + 真机通过）
│   ├── C4F7N_v*.HMI   #   历史产物 v1~v12 + v4_fix*/v9_*/_v100_* 实验件（备份见云盘归档）
│   ├── _v12_work/ 等  #   页面块工作目录（临时，用后即清）
│   ├── C4F7N_HMI_v*.HMI #   旧命名轨历史产物（v18 … v100）
│   ├── *.js             #   一次性脚本（_dump_obj.js / _dump_rtc.js / _chk_p2r.js …）
│   └── base.HMI         #   ⚠️ 4 页空白容器，不可作打包模板（见 §5.3）
├── README.md / FORMAT.md / TOOLS.md / SCRIPTS.md / AI_HMI_工作流.md
```

> ⚠️ `SCRIPTS.md` 为 2026-08-25 早期文档，其中 `print` / `endif` 等说法**已被推翻**；脚本语言以 **`AI_HMI_工作流.md` §4** 为准（见 §5.4）。

### 2.4 产品与硬件 `C4F7N_Hardware/`

| 内容 | 说明 |
|---|---|
| `01_样件采购清单.md` ~ `08_数据导出方案.md` | BOM / 台架验证 / 元件对照 / 连接清单 / 手动重建指引 / 设计基线 / 原理图指南 / 导出方案 |
| `tjc-project/` | 屏端**规格设计**（`01_project_spec.md`…`08_alarm_config.json`、`09_pages/*.json`、`11_scripts/*.hmi`、`13_build/STM32_HMI_接口文档.md`、`14_下载烧录指南.md`） |
| `Software/` | 参考版固件骨架（早期 CubeMX 版） |
| `tools/` | HMI 搭建清单、KiCad/立创导出脚本 |
| `*.kicad_sch/.kicad_pro`、`C4F7N_MainBoard.json` | 硬件原理图工程 |
| `2026-08-28_工作日志.md` | 历史工作记录 |

### 2.5 早期资源 `HMI/`

旧屏工程（`C4F7N_HMI_v17b.HMI`、`DEMO*.HMI`、官方样例）、`XRD_TFT/` 触控配置、`extracted/`。**当前开发不以此为主**，仅作参考。

---

## 3. 系统架构与数据流

### 3.1 分层架构（固件）

```
┌─────────────────────────────────────────────────────────┐
│  Core/  (CubeMX)  main.c ── 应用编排 + HMI 回调实现       │
├─────────────────────────────────────────────────────────┤
│  Middleware/  协议层：c4f7n_hmi_protocol.h(单一事实源)    │
│               tjc_cmd(发) / hmi_callback(收) / hmi_get(回读)│
├─────────────────────────────────────────────────────────┤
│  BSP/  设备层：sensor / battery / pump / w25q16 /        │
│               history / param_store                      │
├─────────────────────────────────────────────────────────┤
│  Drivers/  HAL + CMSIS（CubeMX 生成）                     │
└─────────────────────────────────────────────────────────┘
```

### 3.2 物理链路

| 链路 | 外设 | 引脚 | 参数 | 用途 |
|---|---|---|---|---|
| MCU ↔ 屏 | **USART3** | PB10(TX)/PB11(RX) | **9600 8N1**，RX 中断 | 命令/回读 |
| MCU ↔ 传感器 | **UART4** | PC10(TX)/PC11(RX) | **9600 8N1**，RX 中断 | GC5G1 数字帧上报 |
| MCU ↔ Flash | **SPI1** | SCK=PA5 / MISO=PA6 / MOSI=PA7 / CS=PA4 | — | W25Q64 |
| 电池采样 | **ADC1_IN9** | PB1 | 分压 R22=100k / R23=24k | 电量估算 |
| 调试/烧录 | **SWD** | PA13(SWDIO)/PA14(SWCLK) | — | ST-Link |
| 晶振 | HSE | PD0(OSC_IN)/PD1(OSC_OUT) | — | 72MHz 系统时钟 |

> ⚠️ **UART4 不在 `.ioc` 登记**，由 `BSP/Src/sensor.c` 手工配置（含 `__HAL_RCC_UART4_CLK_ENABLE`）。CubeMX 重生成不会覆盖它，但改动时注意别依赖 `.ioc`。

### 3.3 主循环与调用链

```
main()
 ├─ HAL_Init / SystemClock_Config(72MHz)
 ├─ MX_GPIO_Init / MX_USART1_UART_Init / MX_USART3_UART_Init / MX_SPI1_Init / MX_ADC1_Init
 ├─ sensor_init(); battery_init(); pump_init()
 ├─ w25q16_init(); history_init(); param_init(&PP)
 ├─ sensor_set_cal(PP.cal_k, PP.cal_b)
 ├─ HAL_UART_Receive_IT(&huart3, &rx_byte, 1)   ← 开启 1 字节接收中断
 ├─ tjc_page(6)   ← v18：切独立初始化页；1.5s/2.5s 后各补发一次（防屏冷启动吞指令，§8.5）
 ├─ app_apply_threshold(); rtc_time_start_sync()
 ├─ iwdg_enable()
 └─ while(1){ iwdg_feed(); app_refresh(); HAL_Delay(250); }
        └─ app_refresh()  每 250ms
             ├─ rtc_time_sync_poll()        屏 RTC 同步轮询
             ├─ 初始化页锁页判定：g_page_init && (g_skip || !g_warm) → tjc_page(0) 解锁进主页
             ├─ battery_poll()              电量 → 屏
             ├─ 阈值 get 回读超时处理（500ms）
             ├─ sensor_read_ppm() → g_ppm / g_peak / g_min
             ├─ 60 点滑动平均 → g_avg_run
             ├─ 报警判定 g_alarm(0正常/1低报/2高报/3超量程)
             ├─ 蜂鸣（buzzer_en，进入报警响 1 声 + 每 2s 复响）
             ├─ 曲线页新点 add（实时追加）
             ├─ 每 1s → history_log(g_ppm) 落盘 W25Q64（仅"测试中" g_test=1 时写）
             ├─ 每 2s → refill_table() 无条件重绘历史表 + 统计
             │         （MCU 收不到屏端「进页 0x42」事件，靠事件触发会导致历史页恒空）
             └─ 写屏：浓度/峰值/环境占位/最大最小/阈值/状态/色条/状态圆点
```

> ⚠️ **上电竞态（2026-09-20 已修，§8.5）**：TJC 屏冷启动需 1~3s，MCU 上电首发指令会被吞；按复位键只重启 MCU（屏已带电就绪）所以二次发送成功。修复 = 屏端 `Program.s` 上电加载页改页6（fix6）+ 固件延时补发（v18）。

### 3.4 人机交互链路（双向）

```
[屏] 按钮 printh NN  ──USART3──▶ [MCU] HAL_UART_RxCpltCallback
                                       ├─ hmi_get_feed(b)? 是→ hmi_get_response()  (get 应答)
                                       └─ 否→ hmi_on_rx_byte(b) → 分发到 hmi_on_*()
[屏] ◀── obj.attr=... + FF FF FF ── [MCU] tjc_cmd.c
```

**回读（get）机制**：屏端数字框绑定对象（如 `h`/`l`），MCU 主动 `get h.val` → 屏回送根帧（`0x70`/`0x71` 帧头）→ `hmi_get_feed()` 逐字节组帧 → `hmi_get_response()` 消费 → 写 `PP.thr_hi/thr_lo` + `param_save()`。`g_thr_pending` 标记待回读目标，超时 500ms 放弃（防阻塞）。

---

## 4. 固件（STM32）说明

### 4.1 模块清单与接口

| 模块 | 关键接口 | 说明 |
|---|---|---|
| `sensor.c` | `sensor_init/read_ppm/read_raw/read_voltage/set_cal/get_cal/has_new/online` | GC5G1 帧解析；`SIM_MODE` 宏可开假数据（默认关） |
| `battery.c` | `battery_init/battery_poll/battery_get_pct` | ADC 分压 → 电量 % |
| `pump.c` | `pump_init/set/toggle/get` | `PUMP_HAS_CTL=0` 时为软件状态位（默认关） |
| `w25q16.c` | `w25q16_init` + 读写/擦除 | SPI Flash 底层 |
| `history.c` | `history_init/log/available/read_one/read_page/page_count/wall_time_seconds` | 环形历史（详见 §7.3） |
| `param_store.c` | `param_init/load_defaults/save/factory` | 参数非易失（详见 §7.1） |
| `tjc_cmd.c` | `tjc_set_val/txt/pco/pic/vis/page/wave_add/wave_cls/dim/beep/get` | 发指令 + 帧尾 |
| `hmi_callback.c` | `hmi_on_rx_byte` + 各 `hmi_on_*` | 命令分发 |
| `hmi_get.c` | `hmi_get_feed/value/is_string/reset` | get 应答解析 |

### 4.2 关键状态（`Core/Src/main.c`）

| 变量 | 含义 |
|---|---|
| `g_ppm` / `g_peak` / `g_min` | 当前浓度 / 峰值 / 最小值 |
| `g_avg_run` | 60 点滑动平均浓度 |
| `g_thr_hi` / `g_thr_lo` | 高/低报警阈值（镜像自 `PP`） |
| `g_alarm` | 0=正常 1=低报 2=高报 3=超量程 |
| `g_page` / `g_view` / `g_tbl_page` | 当前页 / 历史视图(0曲线 1数据表) / 数据表页码 |
| `g_param`(别名 `PP`) | 参数结构体（见 §7.1） |
| `g_thr_pending` / `g_thr_pend_t` | 阈值回读状态与超时起点 |
| `g_sync_st`(0=秒值探测/1=读镜像/2=完成) / `g_time_sync_idx` / `g_sync_rtc[6]` / `g_wall_epoch` / `g_wall_tick` | 屏 RTC 校时状态机与时间基准（见 §9） |
| `g_test` / `g_test_t0` / `g_sess_*` | 测试中标志与本次统计；**历史只在测试中落盘** |
| `rx_byte` | USART3 接收字节 |
| `ZERO_CAL_THRESHOLD_PPM`（宏=20） | 零点标定允许阈值（**MCU 固定，不屏端配置**） |

### 4.3 外设配置（`.ioc` 实测）

- MCU：`STM32F103RCT6`，LQFP64，CubeMX 6.18.1
- 已登记 IP：`ADC1`、`NVIC`、`RCC`、`SPI1`、`SYS`、`USART1`、`USART3`（共 7）
- 引脚：PA4(GPIO_Out, W25Q64 CS)、PA5/6/7(SPI1)、PA9/10(USART1)、PB1(ADC1_IN9)、PB10/PB11(USART3 屏)、PA13/14(SWD)、PD0/PD1(HSE)
- 屏串口 **USART3（PB10/PB11 @9600 + NVIC 使能）已于 2026-09-16 补登进 `.ioc`**，ADC1（IN9，239.5 周期采样）同步补登；USART1（PA9/PA10，115200）保留为预留。`IWDG` 为**软件自给式**（`HAL_GetTick` 超时 + `NVIC_SystemReset`，无 `HAL_IWDG_Init`），无须登记。
- 优先级分组：`NVIC_PRIORITYGROUP_4`

### 4.4 编译与烧录

**Keil MDK（当前实际使用）**

```powershell
$uv4  = "D:\KEIL\UV4\UV4.exe"          # 官方 MDK（MDK Plus 5.43），含 AC5 + AC6
$proj = "D:\Demo\C4jly\C4F7N_Demo\MDK-ARM\C4F7N_Demo.uvprojx"
$log  = "D:\Demo\C4jly\C4F7N_Demo\MDK-ARM\build_out.log"
if (Test-Path $log) { Remove-Item $log -Force }
Start-Process -FilePath $uv4 -ArgumentList "-j0","-b",$proj,"-o",$log -Wait -PassThru
Get-Content $log    # 期望 exit=0 且 0 Error(s), 0 Warning(s)
```

- 工具链：**ARM Compiler 6 (ARMCLANG V6.24)**。`.uvprojx` 内 `pArmCC=6240000::V6.24::ARMCLANG`、`uAC6=1`
- ⚠️ **必须用 `D:\KEIL\UV4\UV4.exe`**。`C:\Keil_v5\UV4\UV4.exe` 只装了 AC5、无 ARMCLANG，用它编译会报 `ARM-Compiler 'V6.24' is not available` 并中止。**不要**把 `.uvprojx` 的编译器改回 AC5
- 产物：`MDK-ARM/C4F7N_Demo/C4F7N_Demo.hex`、`.axf`
- 当前基线（2026-09-18 实测）：**0 Error / 0 Warning**，`Code=32214 RO-data=738 RW-data=64 ZI-data=2496`
- 当前基线（2026-09-20 v18 实测）：**0 Error / 0 Warning**，`Code=32678`（独立初始化页 + 上电补发，09-20 17:19）
- ⚠️ **UV4 批处理备忘（2026-09-20 实测）**：注册表 `HKLM\SOFTWARE\WOW6432Node\Keil\Products\MDK` 的 `Path` 指向 `D:\KEIL\ARM`（工具链子目录），UV4.exe 在 `D:\KEIL\UV4\UV4.exe`；PowerShell `&` 不会等待 UV4（GUI 子系统），用 `Start-Process -Wait` 或轮询 `Get-Process UV4`；本次出现**编译完成后 UV4 收尾挂起**（产物已完整落盘，结果以 `-o` 日志 / `build_log.htm` 为准），挂起进程需任务管理器/taskkill 结束，否则占用工程影响下次编译
- 注：早期 AC5 下的 40 个 `#1-D last line of file ends without a newline` 警告在 AC6 下不再出现

**eIDE（VSCode 内，备用）**：eIDE 识别 `.eide/eide.yml`，构建输出到 `MDK-ARM/build/`。用 `srcDirs` 扫描 `Core/Src`、`BSP/Src`、`Middleware/Src`，新增文件无需手工登记。

**烧录（硬件前提）**

| 项 | 要求 |
|---|---|
| 接口 | SWD（ST-Link），**必须接 RESET 引脚**，保证烧录后自动运行 |
| BOOT0 | **必须拉低接 GND**（否则进 System Bootloader） |
| NRST | 10kΩ 上拉 3.3V + 100nF 到地（RC 复位） |
| 供电 | AMS1117-3.3 LDO，每个 VDD 就近 100nF 去耦，主干 10µF |
| 屏侧 | 同步下载对应 `.HMI`（屏串口/USB 下载） |

---

## 5. 屏端 HMI 工程

### 5.1 页面结构（基线 `C4F7N_v12.HMI`，6 页，1024×600）

> 下表为 2026-10-15 对 `C4F7N_v12.HMI` 的**实测**结果。
> ⚠️ **屏页 ID ≠ `.pa` 槽号** —— TJC 的页面 ID = 编辑器页面列表顺序，`.pa` 文件名只是资源槽号，
> 用槽号推 `page N` 必错。固件 `hmi_on_page_enter(p)` 的 p 是 0主页/1设置/2历史，
> 与屏页 ID **在「历史↔设置」上互换**。

| 屏页 ID | `.pa` 槽号 | 页名 | 对象数 | 内容 |
|---|---|---|---|---|
| 0 | `4.pa` | **主页** | 38 | 浓度主显、峰值/平均/状态、色条 `dvr`、三状态圆点 `pc*d_f`、顶部标题 `p0t`；含 `tm0` 与时间镜像 |
| 1 | `0.pa` | **历史曲线** | 125 | 左右双栏 24 行数据表（`tt0..tt23`/`np0..np23`/`sn0..sn23`）+ 统计面板 + 翻页 `bup`/`bdn`/`pg` + 时间镜像 `rY..rsec` + `tm0` |
| 2 | `5.pa` | **设置** | 74 | 高/低阈值 `h`、零点/量程标定 `c0`/`c1`、恢复出厂 `cf`、静音/测试、单位；含 `tm0` 与时间镜像 |
| 3 | `6.pa` | **初始化** | 29 | 倒计时 `pst_i`/自检结果、跳过按钮 `lg_i`；含 `tm0` 与时间镜像 |
| 4 | `1.pa` | **keybdB** | 28 | **键盘页**（数值框 `key=2` 绑定，**不可删**）；确定键 `b210` 的 up 末尾**写死 `printh 11`**（阈值语义，见 §10.6）；`load` **不发**页号通知 |
| 5 | `2.pa` | **厂家设置** | 50 | 标定按钮 `c0`/`c1`/`cf` + 状态/结果行 `cst_f`/`crs_f` + **手动补偿 `cb`/`ck`/`bcb`/`bck` + 公式 `cfc`**（v79~v92 新增）|

> 时间镜像刷新范围：`tm0` 事件脚本在各页执行 `rY.val=rtc0 … rsec.val=rtc5`；
> **只有 keybdB 不刷新**（保持现状，勿改）。
>
> ★ **切页通知 `printh 4N` 写在每页 `load` 事件首行**（40/41/42/43/45）——
> 按钮切页、**滑动翻页**、固件主动 `page` 三条途径全覆盖。
> 滑动翻页（页对象 `left`/`right` 由 255 改为页号，官方称"划动翻页"）
> 由屏端引擎**直接切页、不执行任何控件事件**，只在目标页 `load` 里跑 ⇒ 见 §10.2。
>
> ⚠️ **跨页重名规则**：TJC 的 `obj.txt=...` 只作用于**当前显示页**上的同名对象。
> 「同名跨页」是本工程实现顶栏同步的手段 —— 固件每个刷新周期**无条件重发**，哪页在前台就更新哪页。
> 因此 `tm0` / `rY`~`rsec` / `pc0b,pc0,pc0d` / `pc1b,pc1,pc1d` / `pc2b,pc2,pc2d` / `p0t` / `dvr` 都是**刻意重名**。
> 但「装饰性 / 功能唯一」的对象**绝不能重名** —— 已修实例：主页标题横幅原名 `pg`，
> 与历史页页码 `pg` 撞名被 `refill_table()` 每 2s 覆盖，2026-09-18 改名 `ptitle`。

> ⚠️ 删除 `keybdB` 会导致编译报 `key 初始值无效:键盘页面丢失`。

### 5.2 对象命名约定

- 全部使用**短对象名**（`objname`），固件侧以 `OBJ_*` 宏引用（见 §6.3）。
- **顶栏跨页同步**：主页/设置/历史/关于共用同名对象，实现状态自动同步：
  - 胶囊：`pc0`(探头) / `pc1`(泵) / `pc2`(电量)；副本页后缀 `_s1`/`_s2`/`_s3`
  - 圆点：`pc0d` / `pc1d` / `pc2d`（及 `_s1/_s2/_s3`）
  - 附属：`lg`、`p0t`、`dvr`、时钟 `rY/rM/rD/rH/rMi`（绑定 RTC 变量 `rtc0..rtc5`）
- 时间显示：右上胶囊正下方，`YYYY-MM-DD HH:MM:SS` 格式，**右对齐到 x=1000**；使用 num 控件绑定 RTC 变量（TJC num 控件不支持补零，已接受现状）。

### 5.3 构建流程（当前推荐做法）

```powershell
cd d:\Demo\C4jly\tjc-hmi-toolkit

# 1) 提取页面块（模板必须用"当前在用的" .HMI）
.\tools\extract-pas.exe .\C4F7N\C4F7N_v4.HMI .\C4F7N\_v4fix

# 2) 修改 .pa / Program.s（用 lib/page.js 做 parse→build 字节级往返，见 §5.5）

# 3) 回打包：<模板.HMI> <资源目录> <输出.HMI>
.\tools\hmipack-tjc.exe .\C4F7N\C4F7N_v4.HMI .\C4F7N\_v4fix .\C4F7N\C4F7N_vXX.HMI
#    成功标志：末尾 "RESULT: opens, N resources"，且每页 "stamp ... check=33 ok"

# 4) 引擎级验证
.\tools\verify_all_pages.exe .\C4F7N\C4F7N_vXX.HMI   # 期望 pages ok=6 bad=0
```

> ⚠️ **模板必须是当前在用的 `.HMI`**（现为 `C4F7N_v4.HMI`），它会提供图片/字库等全部非页面资源。
> `base.HMI` 是 **4 页空白容器**，用它打包会得到与实物不符的错误工程 —— 这正是 `C4F7N_v5.HMI` 报「索引超出数组界限 + 宽高问题」的原因之一，**不可再作模板**。
> 不确定时先用**副本**试打包 + verify，再发布正式产物。

### 5.4 TJC 脚本语言支持度（务必遵守）

| 写法 | 支持 | 备注 |
|---|---|---|
| `page N` | ✅ | 页面跳转 |
| `obj.val=N` / `obj.txt="..."` / `obj.x/y/pic=N` | ✅ | 文本必须 GBK |
| `if(cond)` | ✅ | **必须接 `{ }`；无 `endif`、无 `else`** |
| `print` / `cls` / `obj.bco=` | ❌ | 编译报「变量名称无效」 |
| `obj.val-=N` 复合赋值 | ❌ | 展开为 `obj.val=obj.val-N` |
| `else` / `endif` | ❌ | 用独立 `if(cond){ }` 块替代 |

**其他脚本硬约束**
- 单行 **≤15 字节（GBK）**，≥16 被当 attr 解析 → 崩溃「索引超出数组界限」。
- `txt` 不允许空字符串，空文本写 `" "`。
- 事件槽号 `codesXXX-N` 的 **N 必须等于该槽后脚本行数**（仅适用于程序化产出；GUI 手工保存的槽号可不等于行数，勿误报）。
- 逻辑语句必须写在事件槽内，不能放顶层。
- 全局变量在 `Program.s` 声明（如 `int ptq=0,pkq=0,utp=0,us=0,btp=0,bs=0,cfs=0,cft=0`）。
- 按钮 `val` 是**按下状态标志**，不可存自定义状态 → 自定义状态用全局变量。

### 5.5 屏端开发的最大陷阱（必读）

> **GUI 手工保存的页面不可反向重建。**
> 把 USART HMI 手工编辑保存的 `.pa` 逆向成 config、再经 `gen_hmi2` 全属性模式重建，会按值重算数字属性字节宽度，导致 GUI 打开报「多个索引超出了数组界限」、切页报「未将对象引用设置到对象的实例」。`verify_all_pages` **查不出**此问题。

**正确做法**：
1. 用 `lib/page.js` 的 `parse → build` **字节级往返**，保持已有对象 raw 逐字节不变；
2. 新增对象采用「**种子克隆**」（复用 `seeds/`、`template`、已验种子如 `tpl_am1_pas` 的 `bt1`、`t0`、`n0`）；
3. 页级脚本用 `setCodes` **增量合并**，不整段覆盖；
4. 手动注入控件时**必须同步重算** `endx = x+w-1`、`endy = y+h-1`（否则矩形退化 → 引擎越界）。

**其他屏端经验**
- `btn53` 种子默认 `sta=0`（隐藏），克隆后必须显式 `sta=1`；`btn53` 不渲染 `pic` 图片，只用 `bco`+`txt`。
- 数字控件 `key=255` 是「无键盘」正常值；`key=2` 才是绑定键盘页。
- 导航图标未选中 `#7D93AD`，选中 `#3A8FB7`。
- 打包前先杀掉 USART HMI 进程（会锁文件/回写缓存）。
- 最终判定必须用 `D:\USART HMI\USART HMI.exe` **实际打开编译**；引擎验证通过 ≠ GUI 可开。

---

## 6. 通信协议（单一事实源：`c4f7n_hmi_protocol.h`）

### 6.1 屏 → MCU 命令码（`printh NN`，单字节）

| 码 | 宏 | 含义 |
|---|---|---|
| `0x00` | `HMI_CMD_NONE` | 保留 |
| `0x01` | `HMI_CMD_PEAK_RESET` | 峰值复位 |
| `0x11` | `HMI_CMD_THR_HI` | 高报阈值回读触发 |
| `0x12` | `HMI_CMD_THR_LO` | 低报阈值回读触发 |
| `0x13` | `HMI_CMD_UNIT_TOG` | 单位切换（ppm ⇄ g/年） |
| `0x14` | `HMI_CMD_BUZ_TOG` | 蜂鸣器开关 |
| `0x15` | `HMI_CMD_CAL_ZERO` | 零点标定 |
| `0x16` | `HMI_CMD_CAL_SPAN` | 量程标定 |
| `0x17` | `HMI_CMD_CAL_FAC` | 恢复出厂 |
| `0x18` | `HMI_CMD_PUMP_TOG` | 泵/测试 启停切换 |
| `0x21` | `HMI_CMD_VIEW_CURVE` | 切曲线视图 |
| `0x22` | `HMI_CMD_VIEW_DATA` | 切数据表视图 |
| `0x23` | `HMI_CMD_TBL_NEXT` | 下一页 |
| `0x24` | `HMI_CMD_TEST_TOGGLE`（原名 `HMI_CMD_EXPORT`） | 测试 启停切换（2026-09-18 由 CSV 导出复用为本命令） |
| `0x25` | `HMI_CMD_TBL_PREV` | 上一页 |
| `0x40`~`0x43` | `HMI_CMD_PAGE0..3_ENTER` | 进入页 0~3 通知 |

> 注：① 早期曾规划 `0x31/0x32`（零点阈值屏端读写），**已撤销**，改为 MCU 固定宏 `ZERO_CAL_THRESHOLD_PPM=20`。② **下表为全量历史命令表（含已移除项）**：`0x13` 单位切换、`0x21/0x22` 曲线/数据视图切换（`HMI_CMD_UNIT_TOG/VIEW_CURVE/VIEW_DATA` 宏**当前代码已删除**）随 v2「移除单位切换/曲线视图」一并作废；`0x24` 现为测试启停（见上）。当前协议头 `hmi_cmd_t` 实有的枚举以此为准（见 §6 引用的 `c4f7n_hmi_protocol.h`）。

### 6.2 MCU → 屏指令（逐条追加 `FF FF FF` 帧尾）

| 宏 | 生成指令 |
|---|---|
| `HMI_CMD_SET_VAL(obj,v)` | `obj.val=数字` |
| `HMI_CMD_SET_TXT(obj,t)` | `obj.txt="文本"`（GBK） |
| `HMI_CMD_SET_PCO(obj,c)` | `obj.pco=色` |
| `HMI_CMD_SET_PIC(obj,id)` | `obj.pic=id` |
| `HMI_CMD_SET_VIS(obj,v)` | `vis obj,0/1` |
| `HMI_CMD_SET_BAT(obj,pct)` | `obj.txt="电量 N%"` |
| `HMI_CMD_PAGE(n)` | `page n` |
| `HMI_CMD_WAVE_ADD(ch,v)` | `add ch,v` |
| `HMI_CMD_WAVE_CLS(ch)` | `cls ch` |
| `HMI_CMD_DIM(v)` | `dim=v` |
| `HMI_CMD_BEEP()` | `beep 1` |
| `HMI_CMD_GET(obj,prop)` | `get obj.prop` |

**色条颜色（RGB565 十进制）**：绿 `9771`、橙 `62689`、红 `59944`。

### 6.3 关键对象名（固件 `OBJ_*` ⇄ 屏端 `objname`）

| 宏 | objname | 用途 |
|---|---|---|
| `OBJ_CONC` / `OBJ_PEAK` | `cc` / `pv` | 浓度 / 峰值（`vvs=2`，val=42 显示 0.42） |
| `OBJ_BADGE_AVG` | `ba` | 平均徽标 txt |
| `OBJ_STRIP` | `ps` | 色条 pco |
| `OBJ_FLOW` / `OBJ_ENV_TEMP` / `OBJ_ENV_HUMI` | `pf` / `et` / `eh` | 流量 / 环境温度 / 湿度（占位 `--`） |
| `OBJ_CONC_MAX` / `OBJ_CONC_MIN` | `cma` / `cmn` | 浓度最大 / 最小 |
| `OBJ_ALARM_TXT` | `ald` | 报警等级文本 |
| `OBJ_THR_CUR` | `thv` | 当前高/低阈值文本 |
| `OBJ_THR_HI_VAL` / `OBJ_THR_LO_VAL` | `h` / `l` | 阈值数字框（`key=2` 绑键盘页） |
| `OBJ_UNIT_BTN` / `OBJ_CONC_SUB` | `u` / `pu` | 单位按钮 / 副标题 |
| `OBJ_BUZ_BTN` | `bb` | 蜂鸣器按钮 |
| `OBJ_CAL0_BTN` / `OBJ_CAL1_BTN` | `c0` / `c1` | 零点 / 量程标定按钮 |
| `OBJ_STAT_MAX/AVG/MIN/DUR/CNT` | `mx`/`av`/`mn`/`du`/`ct` | 历史统计 |
| `OBJ_WAVE` | `wv` | 波形控件 |
| `OBJ_TBL_TIME_BASE` / `OBJ_TBL_PPM_BASE` / `OBJ_TBL_SN_BASE` | `tt` / `np` / `sn` | 表时间/浓度/序号（`tt0..tt23`、`np0..np23`、`sn0..sn23`；屏上**左右双栏各 12 行**） |
| `OBJ_TBL_PAGE` | `pg` | 页指示（翻页按钮为 `bup`=上一页 → `printh 25`、`bdn`=下一页 → `printh 23`）。⚠️ `pg` **必须全库唯一**：`refill_table()` 每 2s 无条件写入它；主页同名横幅已改名 `ptitle` |
| 顶栏 | `pc0/pc1/pc2`, `pc0d/pc1d/pc2d`(+`_s1.._s3`), `bat` | 状态胶囊与圆点 |
| 圆点图片 | `PIC_DOT_GREEN=5` / `GRAY=4` / `AMBER=3` / `RED=6` | 见 §6.4 |
| **★ 厂家页手动补偿（v79~v92）** | | |
| `OBJ_CAL_B_VAL` / `OBJ_CAL_K_VAL` | `cb` / `ck` | 零点/增益补偿数值框（`type=54`、`key=2`、`vscope=1`）。⚠️ **数值控件只能写 `.val`，写 `.txt` 被忽略** |
| — | `bcb` / `bck` | 「校B」/「校K」按钮，up 事件发 `printh D5` / `printh 5A` / `printh 21|22`（**三字节握手**）|
| `OBJ_CAL_RS_F` | `crs_f` | 厂家页结果/提示行（`cal_report()` 与 `man_report()` **共用**，见 §10.6）|
| — | `cbv`/`ckv`/`cbv2`/`ckv2` / `cfc` | 标签（零点补偿b/增益补偿k/ppm/%）+ 静态公式 `ppm = raw x k/1000 + b` |

> ★ **`.HMI` 一律不入库**（`.gitignore` 含 `*.HMI`），屏包备份见 `README.md` §屏包与固件归档。

### 6.4 状态圆点阈值

- 电量：`>= 50%` 绿，`>= 20%` 琥珀，`< 20%` 红（`BAT_DOT_WARN_PCT=50`、`BAT_DOT_LOW_PCT=20`）
- 探头/泵：在线/运行 → 绿，离线/停止 → 灰

### 6.5 新增一条命令的标准流程

1. 在 `c4f7n_hmi_protocol.h` 增加命令码宏（唯一事实源）。
2. `hmi_callback.c` 的 `switch` 增加分支 → 调用新的 `hmi_on_xxx()`。
3. `hmi_callback.h` 声明回调；`main.c` 实现。
4. 屏端按钮事件加 `printh <码>`（注意脚本行 ≤15B、用 `{}` 无 else）。
5. 若需回读屏端值：`tjc_get(obj,"val")` + `g_thr_pending` 模式 + 超时兜底。
6. 重新编译固件 + 重打包屏端 + 双向验证。

---

## 7. 参数持久化与存储

### 7.1 参数结构（`BSP/Inc/param_store.h`，⚠️ 该文件是 **GBK/LF**）

```c
#define PARAM_MAGIC    0xC4F74A55u
#define PARAM_VERSION  4u      /* v4: [v79] 加 man_b/man_k(厂家页手动补偿, 与标定值分离) */

typedef struct {
  uint32_t magic;      /* 有效性校验 */
  uint32_t version;
  /* --- 标定区（两点式解算，cal_do_span 会写） --- */
  int32_t  cal_k;      /* 斜率 0.001 定点, 默认 1000 (=1.000 无增益), 范围 100~10000 */
  int32_t  cal_b;      /* 偏移 ppm, 默认 0 */
  int32_t  cal_raw0;   /* 零点标定时的原始读数; = PARAM_RAW0_NONE(0x7FFFFFFF) 表示未标定 */
  uint32_t cal_ts;     /* 标定时刻 epoch(秒); 0 = 未标定 */
  /* --- 历史区 --- */
  uint32_t hist_base;  /* 历史有效数据的起始代数(逻辑清空的起算点) */
  /* --- [v79] 厂家页手动补偿区：与标定值【分离存放】，恢复出厂一并清零 --- */
  int32_t  man_b;      /* 手动零点补偿 ppm, 0=未手动(哨兵), 范围 ±200 */
  int32_t  man_k;      /* 手动增益补偿 千分比, 0=未手动(哨兵), 范围 100~10000 */
  /* --- 通用配置 --- */
  uint16_t thr_hi;     /* 高报阈值 ppm */
  uint16_t thr_lo;     /* 低报阈值 ppm */
  uint8_t  buzzer_en;  /* 蜂鸣器 1=开 */
  uint8_t  cal_valid;  /* 1 = 已标定 */
  uint16_t _rsv;       /* 对齐保留 */
  uint32_t crc;        /* 数据区 XOR 旋转校验 */
} param_t;
```

- **换算公式（钳位在所有修正之后、只发生一次）**：
  `ppm = clamp(raw * cal_k/1000 + cal_b, 0, SENSOR_FS_PPM=1500)`（`BSP/Src/sensor.c:114`）
- **生效值合成**：`man_eff_k/b()` = 手动值非 0 即有效，否则回落标定值。
  ⚠️ **`man_b==0` 是「未手动」哨兵** ⇒ 想「强制归零」需另加 valid 标志位，当前做不到。
- **量程标定手动值优先**：`cal_do_span()` 里 `if (!PP.man_k) PP.cal_k = k;`
  ⇒ 已有手动 k 时，量程标定只解 b 做零点平移，不覆盖用户手调的比例。
- **屏上 k 显示百分比**：内部千分比 ÷ 10（屏上填 `91` ⇒ 内部 `910`）。
  ⚠️ **别在屏上填 910**，会变成 9100 ⇒ 读数放大 10 倍且不被范围钳位拦住。
- 默认值：`cal_k=1000, cal_b=0, man_b=0, man_k=0, thr_hi=500, thr_lo=100, buzzer_en=1, cal_valid=0`
- 接口：`param_init()`（上电，无效则填默认并写回 + 置「参数区失效」标志）、`param_save()`（追加式写 102 槽，写满才擦扇区）、`param_factory()`（恢复出厂，走 `dump_defaults()` 清零新字段）
- ⚠️ **改 `param_t` 必须同步 `PARAM_VERSION`**（本项目 v3→v4），否则 `param_load` 版本校验不过，新字段是随机值。

### 7.2 W25Q64 扇区规划（8MB = 2048 × 4KB）

| 区域 | 地址 | 内容 |
|---|---|---|
| 扇区 0 | `0x000000` | 标定 + 设置（整扇区擦写，低频） |
| 扇区 1~2047 | `0x001000 ~ 0x7FF000` | **历史环形区**（≈8.38MB） |

> ✅ 已实施（2026-09-16）：已换用 **W25Q64**（8MB/2048 扇区），`HIST_SECTORS` 511 → 2047（详见 `待确认项清单.md` W1~W3）。

### 7.3 历史记录（`BSP/Inc/history.h`）

- 记录格式：**6 字节（大端）** = `u32 时间戳(秒)` + `u16 ppm`
- 扇区结构：`head[4B 代数 seq] + data[4092B]`，每扇区 `HIST_CAP = (4096-4)/6 = 682` 点
- 寻址：全局单调序号 `idx`；`sector=(idx/CAP)%N`，`off=idx%CAP`；每扇区首点先擦除并写 `head` 代数（磨损均衡）
- 参数：`HIST_PERIOD_MS=1000`（~1s 落盘，**仅"测试中" `g_test=1` 时写**）、`HIST_SECTORS=2047`、`HIST_CAP=682`、`HIST_TBL_ROWS=24`（表格每页 24 条，屏上**左右双栏各 12 行**）
- 接口：`history_log/available/read_one/read_window/read_recent/page_count/read_page/wall_time_seconds/export_window`
- 时间基准：`wall_time_seconds()`（当前为屏 RTC 同步得到的 epoch + `HAL_GetTick` 补偿；见 §9）
- **上电恢复（`g_written` 是纯 RAM 变量，必须重建）**：`history_init()` 扫全部扇区 head，取**最大代数 `seq`** → 物理扇区 `seq % HIST_SECTORS` → 从该扇区第 0 点起数到第一个空点（ts 全 `0xFF`）得 `sz` → `g_written = seq * HIST_CAP + sz`。若一个有效 head 都没有则 `g_written = 0`。
  - ⚠️ **判据陷阱（2026-09-18 已修）**：`found` 必须由「head ≠ `SEQ_EMPTY`(0xFFFFFFFF)」决定，**不能**用 `h > maxhead` 兼作判据 —— 首个环形扇区 `seq = 0`、而 `maxhead` 初值也是 0，`0 > 0` 不成立会被判成"无数据"，导致累计记录 < `HIST_CAP`(682，约 11 分钟采样) 时上电后 `g_written` 恢复成 0（表现为**重启后历史表全空**），且此后每轮都从 `idx=0` 覆写同一扇区、`seq` 恒为 0，**永久无法自愈**。
  - **序号列必须计入页码偏移**：`gi = (page-1) * HIST_TBL_ROWS + i`（`0` = 最新），`recnum = total - gi`，`ser = ((recnum-1) % 9999) + 1`。漏掉 `(page-1)` 项会让每页都从 `total` 重新起算，翻页后序号停在最新一组（2026-09-18 已修）。

### 7.4 配置单一事实源原则

- **配置只存 MCU（W25Q64）**，屏端不存储镜像，避免双端冲突。
- 进设置页时由 MCU **回推**当前配置到屏（`hmi_on_page_enter(p==1)` → `app_apply_threshold()` + 蜂鸣器文案），保证屏显与 MCU 一致。
- 屏端按钮只发命令码，**不自持状态、不自切文案**（文案由 MCU 回写，如单位按钮）。

---

## 8. 已实现功能与现状

### 8.1 功能清单

> ★ **验证状态基线 2026-10-15：v42~v92 全部真机验证通过。**
> 逐版证据见 `docs/变更记录/` 与 `开发进度表.md` §一。

| 功能 | 实现 | 验证状态 |
|---|---|---|
| 浓度实时采集与显示 | `sensor_read_ppm` → `OBJ_CONC` | ✅ 真机（读数合理且随气体变化）|
| 峰值/最小值/滑动平均 | `g_peak`/`g_min`/`g_avg_run`(60 点) | ✅ 真机 |
| 高中低三级报警 + 超量程 | `g_alarm` + 色条 + 状态文本 | ✅ 真机 |
| 蜂鸣报警 | 进入报警响 1 声 + 每 2s 复响，受 `buzzer_en` | ✅ 真机 |
| 电池电量显示 | ADC 分压 → 5 处电量显示 + 圆点变色 | ✅ 真机（13.51V → 10%；满电 16.42V → 100%）|
| 单位切换 ppm ⇄ g/年 | **已移除**（2026-09-18 定）：仅保留 ppm 为唯一单位。`hmi_on_unit_toggle`/`app_apply_unit`/`GY_PER_PPM` 已全部删除，代码零引用；`unit_mode` 字段**已随 `PARAM_VERSION` 3→4 从 `param_t` 中彻底移除**（实测 `param_store.h/.c` 内 `unit_mode` 出现 0 次） | — |
| 高/低阈值设置与持久化 | 屏端数字框 → `get` 回读 → `PP.thr_*` → `param_save` | ✅ 真机 |
| 零点标定（两步确认） | 浓度 ≥ `CAL_ZERO_MAX_PPM(50)` 则拒标；需 3 秒内再按一次 | ✅ 真机（洁净空气下）|
| 量程标定（两点式） | 校验标定前显示值在 `SENSOR_SPAN_PPM ±10%`；用 `cal_raw0`+当前读数联合解 `k`/`b`；**有手动 k 时只解 b** | 🟡 **需 1000ppm 标气，至今未做** |
| 恢复出厂（双步确认） | 屏端 `cfs/cft` 双步 → `printh 0x17` → MCU 恢复默认 + `NVIC_SystemReset()` | ✅ 真机 |
| **★ 厂家页手动补偿 b / k（v79~v92）** | 屏端键盘输入 → `get` 回读 → 范围钳位（二次确认）→ `PP.man_b/man_k` → 落盘；生效值与标定值**分离存放**，手动值优先 | ✅ 真机（改值→校B/校K→**一次即生效**；断电重启保留）|
| 进设置页回推配置 | `hmi_on_page_enter(p==1)`（阈值 + 标定状态） | ✅ 真机 |
| 历史曲线 / 数据表 / 统计 | 数据表 24 条/页（左右双栏各 12 行）分页：序号 `sn*` + 时间 `tt*` + 浓度 `np*`；最大/平均/最小/时长/点数 | ✅ 真机（含断电后历史保留、每秒更新 v55）|
| 屏 RTC 时间同步 | 三阶段状态机：秒值活性探测 → `tjc_get` 读 `rY/rM/rD/rH/rMi/rsec` → 合理性校验 + 失败无限重试 → epoch → `HAL_GetTick` 补偿 | ✅ 真机（预热页时间不再闪 v37）|
| 切页入屏通知 | 每页 `load` 首行 `printh 4N`，覆盖按钮/滑动翻页/固件主动三条途径 | ✅ 真机（v78）|
| 看门狗 | `iwdg_enable/feed`（软件自给式，约 4s；`.ioc` 亦登记 IWDG） | ✅ 已确认（2026-09-09）|
| CSV 导出 | **本阶段移除**（2026-09-18 定）：该功能从未实现，屏端无导出按钮；`0x24` 命令位已复用为「开始测试/停止测试」切换（宏改名 `HMI_CMD_TEST_TOGGLE`）。见 §12 操作手册与待确认项清单 E1/E2 | — |
| 流量 / 环境温湿度 / T90 | **流量显示本阶段移除**（2026-09-18 定：屏端无 `pf` 对象，`OBJ_FLOW` 宏与写屏行已删）；温湿度 / T90 仍占位 `--` 或固定值 | ⬜ 温湿度/T90 未接入 |

### 8.2 已知缺陷 / 遗留

| 项 | 说明 |
|---|---|
| ~~传感器帧格式未验证~~ → ✅ 2026-09-18 真机功能级确认 | 文本行协议解析读数正常且随气体变化（定性对）；定量准确性待标气。注意 `sensor.h` 的 `AA 55+2B` 二进制宏为废弃占位，勿据此判协议（见 `待确认项清单.md` S1/S4、D1） |
| 时间戳精度 | ✅ 2026-09-18 已改造（三阶段校时 + 民用历精确换算）。**遗留**：6 项镜像为逐项读取（跨约 1.5s），跨秒边界理论上可能差 1 秒；`HAL_GetTick` 与屏 RTC 的长期累积误差未评估 |
| 旧记录时间列为 1970 | 校时成功前写入的历史记录时间戳退化为"开机秒数"。**不可追溯修正**，只能被新记录逐步覆盖；如需清空须格式化历史区 |
| 修复前的存量历史内容不可信 | 上电恢复缺陷（见 §8.4 第 8 项）期间，每轮上电都从 `idx=0` **就地覆写同一扇区**，flash 现存内容是新旧混杂。修复后计数能正确恢复，但**旧记录数值不可当准**；要干净基线须擦除历史环（破坏性，需用户确认） |
| 报警无闩锁 | 浓度回落后自动恢复「正常」，突发泄漏可能被漏记（已决定待实施 D2） |
| 屏端时间不补零 | TJC num 控件不支持补零，当前显示如 `9:2`（已接受现状） |
| 时间设置页页名异常 | `3.pa`（时间设置页）页名无法按 GBK 正常解码（2026-09-18 实测为 `鲷緉`），建议后续修正 |
| 桌面比对发现 F1~F3（2026-09-18，未动码） | F1 满量程：规格书 0~3000PPM vs `SENSOR_FS_PPM=1500`；F2 预热：规格 ≥2min vs 代码 5s+首帧退出（预热期可能误报警）；F3 超量程报警等级 3 不可达（`read_ppm()` 已钳位 FS，`main.c` `> FS` 永假）。详见 `待确认项清单.md` §10 |
| 量程/预热/单位收口（2026-09-18） | **量程定为 1500**（规格书为所有型号最大量程，本款 0-1500）；量程标定参考气 `SENSOR_SPAN_PPM=1000`（已确认配套标气 1000ppm）；**单位切换已移除，仅 ppm**；**预热遮罩实由 `g_warm`/`BOOT_INIT_MS=60000u`（main.c）控制 60s**，`sensor_warmup()` 无调用方；g/年 换算 `GY_PER_PPM` 代码零引用 |

### 8.3 最近完成（2026-09-11）

1. **main.c 显示字符串修复**：13 处中文文案（`g/年`、`ppm 浓度实时值`、`状态 正常/低报/高报/超量程`、`失败`/`执行` 等）修复为正确 GBK。
2. **main.c 注释乱码清理**：106 行损坏注释（103 行 `EF BF BD` 不可逆损坏 + 3 行 UTF-8 混入）重建为正确中文；校验：损坏字节 0、非法 GBK 行 0、**注释外代码流字节级完全一致**、编译 0 Error。
3. 屏端 `v93.HMI`：恢复出厂双步确认（`Program.s` 全局变量 `cfs/cft`）、6 页 `check=33 OK`。

### 8.4 最近完成（2026-09-18）

1. **历史表左右双栏顺序修正**：屏端版面为「对象下标偶=左列、奇=右列，行号=下标/2」，固件原把记录序 `i` 直接当对象下标 → 左列显示第 1,3,5… 条。改为 `i<12 → 2i`（左列）、`i≥12 → 2(i−12)+1`（右列）。位置：`main.c refill_table()`。
2. **历史表时间列恒为 1970 修正**：`g_wall_epoch` 恒为 0 → `rtc_wall_seconds()` 退化为"开机秒数"，落盘即 1970。根因是原实现**只在开机跑一轮、2 秒超时即永久放弃**，而屏端此时常未就绪。改为三阶段状态机 `g_sync_st`（秒值活性探测 → 读 6 项镜像 → 合理性校验 + 失败无限重试）。活性探测专门排除屏端镜像对象的设计初值 `2026-01-01 00:00:00`。
3. **历史页翻页按钮不可见修正**：`bup`/`bdn`（id 7/8，位于 760/880,470 110×32）落在右侧统计面板 `p2R`（id 34，不透明 `bco=8551`，范围 760..999×84..507）之内；TJC 按 id 递增绘制、id 大者在上 → 按钮被完全盖住。改 `0.pa` 中 `p2R` 的 `h 424→384`、`endy 507→467`，按钮在原位（y=470..501）露出；面板内最靠下的子项 `prst` 底边 449，仍完整容纳。
4. 产物与证据：固件 `tjc-hmi-toolkit/C4F7N/C4F7N_v5_firmware.hex`（AC6 编译 0 Error / 0 Warning，Code=32214）；屏工程 `tjc-hmi-toolkit/C4F7N/C4F7N_v4_fix.HMI`（打包 `RESULT: opens, 65 resources`，6 页 `check=33 OK`，`pages ok=6 bad=0`，独立回读确认 `p2R h=384 endy=467`）。
5. ⚠️ 上述 3 项在本轮**真机验证中确认生效**（时间列已能显示屏端实时时间）；但**此前已落盘的旧记录时间列仍为 1970**（不可追溯，见 §8.2）。

**同日第二轮（真机验证后暴露出的问题）**

6. **序号列翻页后不随页码变化**：`refill_table()` 用 `recnum = total - i`，而 `i` 只是**页内行号**（0..23），未计页码偏移 → 不管翻到第几页都从 `total` 重新起算，序号永远停在"最新一组"，与按页正确取值的时间/浓度列错位。改为 `gi = (page-1) * HIST_TBL_ROWS + i`。**数值校验**（每页 24 条 / 共 48 条）：修复前第 2 页序号与第 1 页完全相同（精确复现用户现象）；修复后两页连续、覆盖 1..48 无重复无缺失。
7. **`pg` 跨页重名**：主页 `pg`（x=40 y=110 **930×40**）实为**顶部标题横幅**（文本 `C4F7N · 全氟异丁腈`），历史页 `pg`（x=640 y=474 110×24）才是页码。`refill_table()` 每 2s 无条件写 `pg.txt` → 切到主页时会把标题横幅改成页码。**修复**：主页横幅改名 `ptitle`（改名前已校验该名全库不存在、且两页脚本均未引用 `pg`），历史页页码仍叫 `pg`，**固件与协议头无需改名**。全库重名复查：固件每 2s 无条件写入的名字现已**零重名**。
8. **重启后历史表全空**：`history_init()` 中 `if (h != SEQ_EMPTY && h > maxhead) { …; found = 1; }` —— 首个环形扇区 `seq = 0` 而 `maxhead` 初值同为 0 → `0 > 0` 不成立 → 被判"无数据" → `g_written` 恢复成 0 → `available = 0` → 表格全空；且**自锁**（此后每轮都从 `idx=0` 覆写同一扇区，`seq` 恒为 0，永不自愈）。触发条件：累计记录 < `HIST_CAP`(682)。改为 `if (h != SEQ_EMPTY) { if (!found || h > maxhead) maxhead = h; found = 1; }`。**模型验证**：写入 100 条时原实现恢复 0（❌ 全空）而修复版恢复 100（✓）；700 / 1500 条两者一致（无回归）。⚠️ **该缺陷在 v5/v6 等此前所有固件版本中同样存在**，非本轮引入。
9. 产物与证据：固件 `tjc-hmi-toolkit/C4F7N/C4F7N_v7_firmware.hex`（AC6 **0 Error / 0 Warning**，Code=32234；与 v6 差 149 字节）；屏工程 `tjc-hmi-toolkit/C4F7N/C4F7N_v4_fix2.HMI`（打包 `RESULT: opens, 65 resources`、6 页 `check=33 OK`、`pages ok=6 bad=0`，独立回读确认 `p2R h=384 endy=467`、`pg` 仅存在于 `0.pa`、`ptitle` 仅存在于 `4.pa`）。编码安全：`history.c` 为 **UTF-8**，用 UTF-8 补丁并做"非 ASCII 投影多重集合"校验（**原有中文行零丢失**）。
10. ✅ **第 6~8 项已于 2026-09-18 真机验证通过**（烧 `C4F7N_v7_firmware.hex` + `C4F7N_v4_fix2.HMI`）：翻页后序号随时间/浓度一致变更、主页标题横幅不再被页码覆盖、**断电重启后仍能显示重启前的历史**（序号从上次编号继续，不再从 0001 重来）。至此本轮 **6 项修复（第 1~3 项 + 第 6~8 项）全部经真机确认**。

### 8.5 最近完成（2026-09-20）：独立初始化页与上电竞态双路修复

1. **独立初始化页落地（一/二轮，fix5 + v17）**：新增屏端页6「初始化」（24 对象：顶栏 chips `*_i` 副本、RTC 时间镜像、`tm0_i`、预热文案 `prewarm_i`、左上角隐藏跳过按钮 `skip`→`printh 07`）；主页移除全屏预热覆盖层 `OBJ_PREWARM`（回 40 对象，用户确认）。固件 v17：上电 `tjc_page(6)` 锁页，预热结束（`BOOT_INIT_MS=60000u`）或收到 `HMI_CMD_INIT_SKIP=0x07` 后 `tjc_page(0)` 仅切一次；协议头新增 `0x07` 与初始化页 chips 宏。0E/0W Code=32650（09-20 16:15，hex 94,130B）。
2. **「必须按复位键才进页6」根因定位（三轮）**：**上电竞态** —— MCU 上电 ~0.2s 一次性发 `tjc_page(6)`，TJC 屏冷启动需 1~3s，首发指令被吞；按复位只重启 MCU（屏不重启），第二次发送时屏已就绪故成功。
3. **双路修复（用户确认「两者都做」）**：
   - 屏端 `v4_fix6`：以 fix5 为模板走 `hmipack-tjc` 官方管线替换 `Program.s`，上电加载页 `page 0`→`page 6`（单字节补丁 `0x30`→`0x36` @块内偏移 829/0x33D，与 fix5 全容器恰 1 字节差异取证）；7 页 `check=33 OK`。
   - 固件 `v18`：`main.c`（L299）首发后 `HAL_Delay(1500)` 补发 + `HAL_Delay(1000)` 再补发，共 3 次发送（0s/1.5s/2.5s）覆盖屏就绪前 ~2.6s 窗口；全部位于 `iwdg_enable()` 之前。设计前提已取证：`6.pa` 解析证实页6 头部 `codesload-0` 为空、`tm0_i`（300ms）仅刷 RTC 显示，60s 预热锁全在 MCU 侧（`g_warm`/`g_skip`/`g_page_init`）→ **重发 `page 6` 重入无副作用**。⚠️ 实施发现 `main.c` EOL 为 **LF**（非 CRLF），GBK 补丁脚本（`_fw18_patch.js`：iconv-lite 读写 + 锚点必须唯一命中否则中止）须动态检测 EOL。
4. **编译与归档**：v18 = 0 Error / 0 Warning，Code=32678（09-20 17:19），`tjc-hmi-toolkit/C4F7N/C4F7N_v18_firmware.hex` 94,191B（曾误放项目根目录，已按惯例归位并 SHA256 比对一致）。⚠️ UV4 批处理挂起备忘见 §4.4；`.tft` 需在 USART HMI Editor GUI 另存导出（见 §10.3）。
5. **交付口径**：v18 + fix6 为最新已构建，**待 T-25 真机**（不按复位键直接冷上电验证，见 §11.2）；验证前已验证基线仍为 v7 + fix2。

### 8.6 最近完成（2026-10-15）：厂家页手动补偿 cal_b / cal_k —— v79~v92

**功能**：厂家设置页（屏页 ID 5 / `2.pa`）新增「零点补偿 b」与「增益补偿 k」，
屏端键盘输入 → 固件经 `get` 回读校验 → 落盘 → 推屏。

- **屏端控件**：`cb`/`ck`（数值控件 `type=54`、`key=2`、`vscope=1`）、
  `cbv`/`ckv`/`cbv2`/`ckv2`（标签）、`bcb`/`bck`（按钮，发 `D5 5A 21`/`D5 5A 22`）、
  `cfc`（静态公式 `ppm = raw x k/1000 + b`）。**新增控件走 hmipack 正规路线**，非二进制改写。
- **固件侧**：协议头加 `0x21`/`0x22`；`param_t` 加 `man_b`/`man_k`（`PARAM_VERSION` 3→4）；
  独立回读通道（不与阈值共用 `g_get_busy`）；量程标定改为**手动值优先**。
- **范围**：`b` ±200 ppm、`k` 0.1x~10.0x（屏上显示百分比 = 内部千分比 ÷ 10）。
- **二次确认**：k 变化 >20% 需再按一次校K，判据是**「读回值 == 暂存值」**（无时间窗口）。
- **真机验证**：改 b/k → 点校B/校K → **一次即生效**；断电重启值保留；越界拒绝并回推原值。

⚠️ **这个功能从 v79 到 v92 花了 8 版才收口**，根因链见 `.workbuddy/memory/2026-10-15.md`。
四条关键教训已升格为 §10.6 的硬约束，**接手者改这条链路前务必先读**。

---

## 9. 关键设计决策与理由（勿轻易推翻）

| 决策 | 理由 |
|---|---|
| **配置单一事实源 = MCU** | 屏端不存配置，避免双端不同步；进页由 MCU 回推 |
| **零点阈值固定为 MCU 宏（20ppm）** | 原计划屏端可配（`0x31/0x32`），后撤销以简化协议与防误操作 |
| **恢复出厂二次确认在屏端实现** | 纯屏端 `cfs/cft` 双步（无 else），避免 MCU 侧额外状态机 |
| **标定失败用「失败」文案并保持** | MCU 直接下发文本，用户再点一次复位为「执行」 |
| **时间同步用屏 RTC（方案A）** | 无硬件 RTC 电池；上电从屏读时间 → epoch → `HAL_GetTick` 每秒补偿。**2026-09-18 改版**：加"秒值活性探测"（读 `rsec` 两次比对秒值是否变化，排除屏端设计初值 `2026-01-01 00:00:00`）、合理性校验、失败无限重试（原实现 2s 超时即永久放弃 → 时间列恒 1970） |
| **历史曲线实时追加，非 SD 卡导入** | 屏 SD 卡位于设备背面被外壳遮挡不可用，且 TJC 无「从 SD 回填曲线」指令 → 由 MCU 侧 W25Q64 承担 |
| **放弃全局圆角 r6px** | 图片槽位不足（仅 4 个空闲且为 28 高窄条），与按钮 40/44/50 高不匹配 → 接受直角 |
| **导航按钮用 `btn53`** | 兼容性优于 `btn98`（`btn53` 不渲染 pic，只用 bco+txt） |
| **滑块控件不带事件脚本** | 会崩溃 |
| **屏端开发转向「手工页增量修改」** | `gen_hmi2` 全量重建会破坏 GUI 手工保存页（见 §5.5） |
| **历史表每 2s 无条件重绘** | MCU 收不到屏端「进页 `0x42`」事件，若仅靠进页事件触发 `refill_table()` 会导致历史页恒空（连旧数据也不显示）；故在 `app_refresh()` 内定时重绘 |
| **翻页按钮靠改面板几何露出（不改对象顺序）** | TJC 绘制顺序由对象 id 决定，按钮 id 小于面板无法置顶；改面板高度是最小改动，且不动既有对象 id 与脚本 |
| **序号必须计入页码偏移** | 序号表示"全局第几条"，与页无关；`i` 只是页内行号。漏掉 `(page-1)*HIST_TBL_ROWS` 会让每页序号都停在最新一组（2026-09-18 已修） |
| **`g_written` 恢复判据只认「head 非空」** | 代数 `seq` 从 0 开始；"是否已有数据"与"哪个扇区最新"是两件事，不能合并进同一个比较表达式（`0 > 0` 陷阱，2026-09-18 已修） |
| **跨页同名只适用于「状态类」对象** | 顶栏同步依赖固件周期性无条件重发同名对象；但装饰性/功能唯一对象一旦重名就会被误写（`pg` 实例）。新增页内对象务必先做全库重名扫描 |

---

## 10. 硬性限制与避坑清单 ⚠️

### 10.1 编码类（最容易造成不可逆损伤）

| 约束 | 说明 |
|---|---|
| ⚠️ **本工程源码是「混合编码」，不可统一假设** | 2026-09-18 逐文件严格判定：**UTF-8（6 个）** `history.c`、`history.h`、`battery.c`、`hmi_callback.c`、`hmi_callback.h`、`c4f7n_hmi_protocol.h`；**GBK（18 个）** `main.c`、`sensor.c/h`、`tjc_cmd.c/h`、`hmi_get.c/h`、`usart.c`、`adc.c`、`spi.c`、`param_store.c/h`、`pump.c/h`、`w25q16.c/h`、`battery.h`、`stm32f1xx_it.c`。**改写前必须逐文件判定真实编码**，方向用错会把中文写坏且**不可逆**（可用 `TextDecoder('utf-8',{fatal:true})` 试解 + 严格 UTF-8 通过性快速判别） |
| 中文字符串字面量必须 GBK | armcc 按系统代码页解析中文字面量；若为 UTF-8 → `#53 expected a ":"` / `#8 missing closing quote`。本工程中文 UI 文案集中在 `main.c`（GBK）并多用 `\xNN` 转义，故上述 6 个 UTF-8 文件能编过；**要在 UTF-8 文件里新增中文字符串字面量前，必须先转 GBK** |
| **禁用 Write/Edit 等 UTF-8 工具改写含中文源文件** | 必须先写 UTF-8 临时文件，再以 UTF-8 读入、**GBK 写出**转回 |
| PowerShell 读写 GBK 文件必须 `[System.Text.Encoding]::GetEncoding(936)` | 读/写都要；操作前**先确认源文件实际编码** |
| 编码二次毒化**不可逆** | 错误假设会造成整文件中文变 `0xFFFD`/乱码，只能整文件重建 |
| 文档类 `.md` 为 UTF-8 | 不受上述约束（如本文件、各 README） |
| 中文注释乱码检查要点 | 用 `txt.raw.length` 与 `txt_maxl.value` 直接比较，**勿**把 latin1 重编码成 GBK 再算（会虚高误报） |

### 10.2 屏端脚本类

- 单行 **≤15 字节（GBK）**；≥16 → 引擎当 attr → 「索引超出数组界限」
- `if(cond)` **必须接 `{}`**，**无 `else` / 无 `endif`**
- 不支持 `print` / `cls` / `obj.bco=` 赋值；不支持复合赋值 `+=`/`-=`
- `txt` 非空（空写 `" "`）
- 事件槽号 **N = 槽后脚本行数**（清空归 0）；GUI 手工保存的槽号可不等于行数，勿误报
- 对象 **id 唯一且连续 0..n-1**；`make_subset` 后必须重排 id
- 按钮 `val` 是按下状态标志，不能存业务状态 → 用全局变量
- TJC **不允许在 if 条件中做运算**（如 `%`），需先算入系统变量

### 10.3 HMI 构建类

- `.HMI` 必须由 **`hmipack-tjc.exe`** 打包（容器尾部校验和算法未破解，勿手工改）
- `.tft`（烧屏镜像）**不是** HMI 容器格式：无法程序化修补/生成，必须在 **USART HMI Editor GUI** 打开 `.HMI` 后另存导出（2026-09-20 fix5/fix6 交付流程实测）
- 打包**模板必须用当前在用的 `.HMI`**（现为 `C4F7N_v12.HMI`，**6 页**）；`base.HMI` 是 4 页空白容器，**严禁使用**（用它打包会得到错误工程）；旧基线（`v4`/`v8` 等）打包会**丢页**。**只把要改的资源放进工作目录**，其余资源会被逐字节保留；`Program.s` 也可放进工作目录并改变长度（实测输出 `replaced Program.s`）
- ⚠️ **`.HMI` 禁二进制改写**（10-13 三连败：报"文件已受损"／厂家页消失／丢页，数据层校验全绿但**编辑器打不开**）。新增控件只能走 `hmipack` 正规路线：解包 → 脚本改 `.pa` → 以**当前在用**的 `.HMI` 作模板回打包；动手前先做 `parse→build` 往返逐字节自检。**唯一真判据 = 用户用 TJC 编辑器能打开并保存。**
- 改 `objname` 属**变长记录**（`page.js` 的 `set()` 对字符串按新值长度重建）→ 页块总长随之变化，必须走 `hmipack` 回打包 + `verify_all_pages` 复验；改名前先做**全库重名扫描**（避免制造新的跨页覆盖）
- **不要单独移动 `tools/` 下的 exe**（依赖同目录 DLL：`achmiface.dll` 等）
- 打包前**杀 USART HMI 进程**（锁文件/回写缓存）
- 验证**用副本**（GUI 打开会把缓存写回 `.HMI`）
- 手工注入控件必须同步 `endx/endy = x+w-1 / y+h-1`
- `keybdB` 页必须保留；`btn53` 种子需显式 `sta=1`
- 图片引用 `picc/picc2` 不可设为 65535
- `verify_all_pages` 只查结构，**不查**脚本行长度/槽号/跨页引用/注释边界

### 10.4 固件/CubeMX 类

- 编译必须用 **`D:\KEIL\UV4\UV4.exe`**（含 AC6 V6.24）；`C:\Keil_v5\UV4\UV4.exe` 只有 AC5，会报 `ARM-Compiler 'V6.24' is not available` 并中止。**不要**把 `.uvprojx` 改回 AC5
- CubeMX 生成器须保持：**Keep user code ✅ / Delete previously generated files ✗**
- 重生成后复查 2 处易丢配置：① 源文件列表含 `Core/Src` 的 `usart.c/gpio.c/adc.c/spi.c`；② `stm32f1xx_hal_conf.h` 的 `HAL_ADC_MODULE_ENABLED` 启用
- 重生成可能把 `main.c` 编码改回 UTF-8 → 需再转 GBK
- 自管代码一律放 `BSP/`（驱动）或 `Middleware/`（通信），勿塞 `Core/Src`
- `UART4` 在 STM32F1 中宏名为 `UART4`（非 `USART4`），时钟宏 `__HAL_RCC_UART4_CLK_ENABLE`

### 10.5 硬件类

- **BOOT0 必须拉低接 GND**；NRST 需 RC 复位电路（10kΩ 上拉 + 100nF）
- SWD **必须接 RESET 引脚**（保证烧录后自动运行）
- 3.3V 用 LDO（AMS1117-3.3），VDD 就近 100nF 去耦 + 主干 10µF

### 10.6 ★★ 通信与并发类（v79~v92 用 8 版换来的，**改链路前必读**）

**① `g_get_busy` 是 get 通道的唯一所有权，回包不带身份 ⇒ 路由判据必须是
「谁【确实发出过 get 且还没收到回包】」（`g_thr_wait` / `g_mank_wait`），
绝不是「谁有请求在等」（`g_thr_hi_req` / `g_manb_req`）。**
两者单通道时等价，双通道并存时**完全分不清** ⇒ 间歇性错值，极难联想到「路由」。
（v79 用了错判据，靠「补偿分支排在阈值之前」打补丁；v87 改对判据后不再需要排序。）

**② UART 的 TX 只允许来自一个上下文（主循环）。**
`HAL_UART_Transmit` 阻塞但**可被中断抢占** ⇒ ISR 里发串口会与主循环的报文**在线上交织**
⇒ 屏端命令解析器错位并**吞掉后续字节**，含用户下一次按键的三字节握手
⇒ 表现为「**要点好几次才生效**」。
★ 加剧因素：握手层对**裸命令码是"绝不执行"**（`hmi_callback.c:86-92`）
⇒ **丢一个字节 = 丢一次操作**，链路层没有任何容错。

**③ 多通道轮询函数里，「本通道的收尾（超时清旗标）」与「对外可见的上报」
必须排在所有「让出给别的通道」的 `early-return` 之前。**
放错位置 ⇒ **死锁 + 静默**（不是报错，是什么都不发生），且症状常退化成
「比修之前更没反应」，像新版本引入的回归。
★ 加任何 `early-return` 前先问：**它会不会让后面的收尾/上报永远走不到？**

**④ 新增走三字节握手 `D5 5A NN` 的命令码，必须同时改三处**：
① 协议头 `hmi_cmd_t` 枚举 ② `hmi_on_rx_byte()` 的 `switch` case
③ ★**`s_guard_list[]` 白名单**。
漏第 ③ 处 ⇒ 握手层判「非受保护命令」直接 `return`，`switch` 根本走不到，
症状是「点了完全没反应」且**无任何日志**。（v84 真机 bug。）

**⑤ 「点几次才生效」类症状 ⇒ 先怀疑链路层丢消息，别急着改业务判据。**
若**同一操作在不同分支下都要多次**，问题不在分支逻辑里，而在更底层的链路。
排查顺序固定为：① 命令有没有到达（加计数/诊断）→ ② 回包有没有回来 → ③ 分支判据对不对。
★ 跳过 ① 直接改 ③ 会连续多版原地打转（v84~v90 连续 7 版都栽在③ 上）。

**⑥ 抄既有实现当骨架时，要连「状态初始化」那一半一起抄。**
反例：`man_readback_poll()` 抄了阈值版的耐心判据 `now - t0 >= 8000`，
却漏了阈值版在**请求到达时**就 `g_thr_t0 = HAL_GetTick()` 这一半
⇒ `t0` 永远是 0 ⇒ **get 从未发出过**，功能 100% 失效且不报错。（v86。）

**⑦ 时间窗口是「把用户反应时间当设计参数」的反模式。**
能用「数据是否变化」表达的确认，就不要用「时间」表达（v90 已改为按值判定）。

---

## 11. 待办与下一步

> 详细清单见 `C4F7N_Demo/待确认项清单.md`（S/W/T/E/H/P/A/D 系列）。以下按优先级给任务卡。

### 11.1 P0 · 真机联调前的命门项（必须最先完成）

> ✅ **2026-09-18 收口**：T-01/T-02 已真机功能级确认（浓度读数合理且随气体变化 → 文本行协议/9600 8N1/主动上报与实机兼容）；T-03 定量部分（标气比对、`GY_PER_PPM=0.458` 依据、满量程 F1）仍待验证。下表保留作溯源。
> ✅ **2026-09-18 补充收口**：**满量程定 1500**（规格书为所有型号最大量程）、量程标定参考气 **1000ppm**、**单位切换移除（仅 ppm）+ g/年 `GY_PER_PPM` 删除**、**预热遮罩核实为 `g_warm`/`BOOT_INIT_MS=60000u`（main.c）**——均已在代码与本节同步（见 §8.2、§11.1.2/11.1.3）。

| # | 任务 | 验收标准 | 涉及文件 |
|---|---|---|---|
| T-01 | **核实 GC5G1 上报帧格式**（帧头/帧长/偏移/字节序/校验） | 实机读到正确 ppm | `BSP/Inc/sensor.h`（`SENSOR_FRM_*`）、`BSP/Src/sensor.c` |
| T-02 | 核实波特率 / 上报节奏 / 预热行为 | 在线判定不误报、预热期不误报 | `sensor.c`（`PROBE_ONLINE_TIMEOUT_MS`）、`main.c` |
| T-03 | 核实量程与单位系数（`SENSOR_FS_PPM=1500`、仅 ppm；原 `1ppm≈0.458 g/年` 已删） | 量程定 1500 已确认；仅 ppm | `sensor.h`、`main.c` |

> **为什么是命门**：`sensor.h` 源码注释明确写着帧格式为「**占位假设**」。若与实机不符 → 读不到数据或读数全错 → 报警 / 历史 / 曲线 / 标定**全部连带失效**。
> **通用原则**：先隔离、后定位。UI/曲线/历史链路可先用 `SIM_MODE`（假数据）跑通，再切真实数据，把问题锁定在传感器侧。

#### 11.1.1 T-01 核实上报帧格式

> ⚠️ **2026-09-18 修正（重要）**：传感器解析**已改为文本行协议** —— `BSP/Src/sensor.c:37 parse_frame()` 按行解析，要求行形如 `[空白] 数字 [空白] "ppm"`（大小写不敏感、忽略 `\r`），数值用手写整数+小数解析（规避 `strtod` 在该工具链返回 0）。
> 下面「当前代码假设」表描述的是**已废弃的二进制帧方案**（`AA 55 + 2B 小端`）；`sensor.h` 中的 `SENSOR_FRM_HEAD0/HEAD1`、`SENSOR_PPM_OFFSET` 宏仍在文件中，但**已不被解析逻辑使用**，勿据此误判协议。
> 下方"抓包 → 与规格书逐字段比对"的**方法仍然有效**，但比对目标应改为**文本行格式**（行内容/单位后缀/小数位/上报节奏）。另：`SENSOR_FS_PPM` 已由 1000 调为 **1500.0f**。

**当前代码假设**（`BSP/Inc/sensor.h` + `BSP/Src/sensor.c` 实读）—— ⚠️ **已废弃，见上方说明**

| 项 | 当前值 | 位置 |
|---|---|---|
| 帧头 | `0xAA` + `0x55` | `SENSOR_FRM_HEAD0` / `SENSOR_FRM_HEAD1` |
| 浓度字段偏移 | 2（帧头之后） | `SENSOR_PPM_OFFSET` |
| 浓度字节数 | 2 | `SENSOR_PPM_BYTES` |
| 字节序 | **小端** | `parse_frame()`：`<< (8*i)` |
| 帧长上限 | 16 | `SENSOR_FRM_MAXLEN` |
| 解析触发 | **收满 4 字节即解析**，不等整帧 | `feed_byte()`：`fidx == OFFSET+BYTES` |
| 校验 | **无** | — |
| 值域 | 钳位 0 ~ 1000 ppm | `parse_frame()` |
| 同步方式 | 状态机 `synced` / `fidx`，遇 HEAD0 起帧、等 HEAD1 | `feed_byte()` |

**排查步骤**

1. **抓原始数据**（关键第一步）
   - 断开 MCU，把传感器 TX 接 **USB-TTL 转接板 → PC**，波特率先按 **9600 8N1**，用串口助手（`sscom`/`XCOM`，开 hex + 时间戳）记录 **≥60s** 原始字节（覆盖上电瞬态与稳定段）。
   - 若不便断开：用示波器/逻辑分析仪夹 UART4 的 **PC11(RX)** 线，导出时序并解码。
2. **对照规格书** `docs/GC5G1(C4F7N)全氟异丁腈传感器V2.2.pdf`，逐字段确认：帧头、帧总长、浓度字段偏移、字节序、是否有校验（和 / CRC / 异或）、是否含温湿度或状态字段。
3. **填写比对表**：

   | 项 | 代码假设 | 实机观测 | 是否一致 |
   |---|---|---|---|
   | 帧头 | `AA 55` | | |
   | 帧总长 | ≤16 | | |
   | 浓度偏移 | 2 | | |
   | 字节序 | 小端 | | |
   | 校验 | 无 | | |

4. **不一致时的改法**
   - **帧头不同** → 改 `sensor.h` 的 `SENSOR_FRM_HEAD0/HEAD1`。
   - **偏移/字节数不同** → 改 `SENSOR_PPM_OFFSET` / `SENSOR_PPM_BYTES`。
   - **大端** → 改 `parse_frame()`：`v = ((uint16_t)frm[O] << 8) | frm[O+1]`。
   - **必须收满整帧**（例如带校验尾） → 把 `feed_byte()` 的触发条件从 `fidx == OFFSET+BYTES` 改为**固定帧长**，并在 `parse_frame()` 内加校验判断。
   - **浓度需二次换算**（原始值需 ÷10 / ×比例 / 有小数位） → 在 `parse_frame()` 归一化，或调整 `SENSOR_FS_PPM`。
5. **隔离验证**：先取消 `sensor.h` 中 `/* #define SIM_MODE 1 */` 的注释，用假数据跑通 UI/曲线/历史/统计链路；再切回真实数据，确认剩余问题仅在传感器侧。
6. **验收**：洁净空气静置 → 读数接近 0；通入已知浓度标气 → 偏差在允许范围内。

#### 11.1.2 T-02 核实波特率 / 上报节奏 / 预热行为

**当前代码假设**

| 项 | 当前值 | 位置 |
|---|---|---|
| 波特率 | **9600 8N1** | `sensor_init()`：`huart4.Init.BaudRate` |
| 通信方式 | 主动上报，**无主询问** | 代码中无发送逻辑 |
| 在线判定 | **3s 内无帧 → 离线** | `PROBE_ONLINE_TIMEOUT_MS = 3000` |
| 预热处理 | **上电 60s 初始化遮罩**（`g_warm`）：`BOOT_INIT_MS=60000u`，遮罩期内 `g_ppm=0`/`g_alarm=0`，屏显「--/初始化」（2026-09-18 核实，实由 main.c 控制，与 `sensor_warmup()` 无关） | `main.c`（`g_warm`/`g_boot_ms`/`BOOT_INIT_MS`） |
| 接收方式 | RXNE 中断 + 直读 `DR`（**非** `HAL_UART_Receive_IT`） | `sensor_uart4_irq_handler()` |
| 中断优先级 | UART4_IRQn = 1,0 | `sensor_init()` |

**排查步骤**

1. **波特率**：抓包若为乱码，依次试 `4800 / 9600 / 19200 / 38400 / 57600 / 115200`，直到能稳定识别 `0xAA 0x55` 帧头 → 改 `huart4.Init.BaudRate`。
2. **上报节奏**：从串口助手时间戳记录相邻帧间隔（平均 + 最大）。若最大间隔 > 3000ms → 调大 `PROBE_ONLINE_TIMEOUT_MS`（建议 ≥ 最大间隔 × 2）。
3. **是否需握手/询问**：若上电后长时间**无任何数据**，可能是传感器需 MCU 先发询问帧。当前代码无发送逻辑 → 需按规格书补定时 `HAL_UART_Transmit` 询问（注意与 RXNE 中断的并发处理）。
4. **预热行为**：规格书要求预热 ≥2min；**当前实现为上电 60s 遮罩**（`g_warm`/`BOOT_INIT_MS=60000u`，遮罩期 `g_ppm=0`/`g_alarm=0`、屏显初始化）。真机确认：若需匹配规格 2min，将 `BOOT_INIT_MS` 调至 `120000u`（main.c）即可。**预热期不记录历史**（`main.c` 历史写入条件含 `!g_warm`，为现有合理设计，已确认保持）。
5. **验收**：上电 → 探头圆点由灰转绿；拔掉 TX 线 3s → 转灰。

#### 11.1.3 T-03 核实量程与单位系数

**当前代码假设**

| 项 | 当前值 | 位置 |
|---|---|---|
| 满量程 | **1500 ppm**（2026-09-18 复核：代码实为 `1500.0f`） | `SENSOR_FS_PPM` |
| 量程标定浓度 | 1000 ppm | `SENSOR_SPAN_PPM`（`hmi_on_cal_span` 用 ±10% 判据） |
| 单位换算 | **已移除**（仅 ppm，2026-09-18 定）；原 `GY_PER_PPM=0.458` 已无代码引用 | 无（已删） |
| 标定斜率钳位 | 100 ~ 10000 | `SENSOR_CAL_K_MIN/MAX` |
| 换算公式 | `ppm = raw * cal_k/1000 + cal_b` | `sensor.c` / `param_store.h` |

**排查步骤**

1. **满量程**：已定为 **1500**（2026-09-18，规格书为所有型号最大量程）；`SENSOR_FS_PPM=1500.0f`。
2. **量程标定浓度**：已确认配套标气 **1000 ppm**（2026-09-18）；`SENSOR_SPAN_PPM=1000`，注意 `hmi_on_cal_span()` 的 ±10% 判据随之变化。
3. **g/年 换算**：**本阶段移除单位切换，仅保留 ppm**（2026-09-18 定）。`GY_PER_PPM=0.458` 已从代码删除、无引用；如后续仍需 g/年，再按 C4F7N 摩尔质量/体积浓度→质量泄漏率模型重新推导并标注出处。
4. **标定链路验证**：执行零点/量程标定 → 确认 `PP.cal_k / cal_b` 写入 W25Q64 → **断电重启后读数保持一致**（验证 `param_save()` + `sensor_set_cal()` 闭环）。
5. **验收**：标气实测偏差在允许范围内（单位为 ppm）。

#### 11.1.4 P0 所需工具 / 材料

| 类别 | 清单 |
|---|---|
| 抓包 | USB-TTL 转接板、串口助手（hex + 时间戳）、示波器或逻辑分析仪 |
| 参考 | GC5G1 规格书 PDF、已知浓度标气（或洁净空气作零点参考） |
| 烧录 | ST-Link（SWD）、装配完成的板子、对应版本屏端 `.HMI` |

### 11.2 P1 · 功能闭环

| # | 任务 | 验收标准 | 涉及 |
|---|---|---|---|
| T-04 | **真机联调全链路**：烧 **当前固件 `V1.0-b98`** + 屏下载 **`C4F7N_v12.HMI`**，双向验证各页 | 🔄 屏端历史页链路（含断电重启）已全部通过；其余页与标定/报警等仍待验证 | `C4F7N_v7_firmware.hex` + `C4F7N_v4_fix2.HMI` |
| T-05 | 验证标定交互：零点/量程成功与失败文案、恢复出厂双步 + 立即重启 | 「失败」保持、「执行」复位、重启生效。**代码层已核对**：标定按钮在设置页 `c0`(0x15)/`c1`(0x16)/`cf`(0x17，双步确认)，命令→`hmi_callback.c`→`main.c hmi_on_cal_*`→保存→屏反馈 `OBJ_CAL0/1_BTN` 全闭合（2026-09-18） | `main.c` `hmi_on_cal_*`、屏端脚本 |
| T-06 | 验证进设置页回推（阈值/蜂鸣器；**单位已移除**） | 断电重启后屏显与 MCU 一致。**2026-09-20 新增 hi≥lo 钳制**（`hmi_on_thr_hi_dec` 下限取 `PP.thr_lo`、`hmi_on_thr_lo_inc` 上限取 `PP.thr_hi`，防阈值倒挂） | `main.c` `hmi_on_page_enter`、`hmi_on_thr_*` |
| T-07 | 报警闩锁（防漏检，D2） | 高报后保持直到人工复位 | `main.c` 报警判定 |
| T-08 | 时间戳精确化 | ✅ 2026-09-18 已完成校时状态机改造（`g_sync_st`，民用历精确换算），并**真机确认新记录时间 = 屏端当前时间** | `main.c` 校时状态机 |
| T-09 | 低电保护（D5）：提示 + 临界关泵/关机 | ✅ **v30 已实现三级提示**（13.5/13.0/12.6V + lb 文案 + 音效 id=5；EN 未接 MCU，无自动断电 = 持续催促；lb 控件待添加） | `battery.c`、`main.c` |
| T-25 | **独立初始化页真机验证**（09-20 新增）：（09-20 当时的 `v18_firmware` + `v4_fix6.HMI`；**当前基线已推进到 `V1.0-b94` + `C4F7N_v12.HMI`**）（`.tft` 先在 USART HMI Editor GUI 导出），**不按复位键直接冷上电** | 上电直接进页6（预热文案 + 顶栏 chips）；60s 预热结束自动进主页0；点左上角隐藏按钮（`printh 07`）跳过进主页0；均只切一次；主页无残留预热覆盖层。✅ **2026-09-24 真机验证通过**（0E/0W Code=32678 + 7 页 check=33） | `main.c` 上电锁页/补发、`6.pa`、`Program.s` |

### 11.3 P2 · 存储与产品化

| # | 任务 | 验收标准 | 涉及 |
|---|---|---|---|
| T-10 | ✅ 已完成（2026-09-16）换用 **W25Q64**（`HIST_SECTORS` 511→2047） | 容量提升、扇区注释同步 | `history.h`、`param_store.h` 注释 |
| T-11 | 泵真实 GPIO（D4）：控制 + 状态回读 | 可真正启停并反馈。**2026-09-18 已升级为 PWM+FG 三线制封装**（按 KLVP1E-SB12L 12V 无刷：`PUMP_CTL` 启停GPIO + `PUMP_PWM_TIM/CH` 调速 + `PUMP_FG_*` 转速反馈「开漏 6 脉冲/转」），`PUMP_HAS_CTL/PWM/FG=0` 时走软件态；新增 `pump_set_duty/pump_get_rpm_ff/pump_feedback_isr`。硬件接线后置开关为 1 | `pump.h/c` |
| T-12 | ~~CSV 导出通道（E1/E2）~~ → **本阶段移除**（2026-09-18 定）；`0x24` 复用为测试启停 | 不再开发 | 无 |
| T-13 | 启动自检 POST（D3） | 失败在屏上提示 | `main.c` |
| T-14 | 浓度数字滤波（D6） | 读数更稳 | `main.c` |
| T-15 | ~~流量接入~~（本阶段移除，2026-09-18 定）＋ 环境温湿度/T90 接入（H2~H3） | 温湿度/T90 由占位改为真实值；流量不再开发 | `main.c`、屏端对象 |

### 11.4 收尾

| # | 任务 |
|---|---|
| T-16 | 修正时间设置页（`3.pa`）页名乱码 |
| T-17 | 清理历史备份文件（见 §14.2） |
| T-18 | 修复注释中 `#1-D last line of file ends without a newline` 警告（40 处，可选） |

---

## 12. 常见任务操作手册

### 12.1 改一条固件逻辑

1. 确认目标文件编码为 GBK（含中文）。
2. 用 GBK 安全方式修改（禁止 UTF-8 工具直写）。
3. 编译：§4.4 Keil 命令 → 确认 0 Error。
4. 记录改动与验证结果。

### 12.2 加一个新屏端控件

1. 从 `seeds/` 克隆种子（如 `tpl_am1_pas/bt1` → `btn53`，`tpl_s5/t0` → `text`，`tpl_s1/n0` → `num`）。
2. 用 `lib/page.js` 的 `parse → build` 增量追加，**保持既有对象 raw 不变**。
3. 设置 `objname`（与固件 `OBJ_*` 对齐）、`x/y/w/h` 并**重算 `endx/endy`**、`txt_maxl`（=GBK 字节长）。
4. 若需事件脚本：`{}` 语法、每行 ≤15B、无 else。
5. 重打包 + `verify_all_pages` + GUI 打开编译验证。

### 12.3 加一条通信命令

见 §6.5。

### 12.4 重新打包屏端并验证

见 §5.3。

### 12.5 烧录与上电检查

见 §4.4（SWD + BOOT0 拉低 + RESET 接线）。

---

## 13. 与用户协作的偏好与流程约定

接手者请**严格遵循**以下约定（可显著减少返工）：

| 类别 | 约定 |
|---|---|
| 语言 | 全程使用**中文**（含代码注释、文档、回复） |
| 改动方式 | **最小改动优先**，不做未被要求的重构/优化；不做"顺手改" |
| 文件保存 | 修改**另存为新文件**，不覆盖原件；历史版本保留（如 `.HMI` 版本号递增、`.bak` 备份） |
| 需求澄清 | 面对模糊需求时，**一次只问一个问题**，追问到对目标有 95% 把握再给方案 |
| 不确定时 | **先问、不臆造**；宁可标注「待核实」也不编造 |
| 交付节奏 | 一组改动完成后**批量提交**（不每步一提交） |
| 每步交付 | 必须给出**验证报告**：改了什么 + 如何验证 + 结果（编译/工具/对比证据） |
| 任务跟踪 | 用 Markdown 列表 + 状态图标 **⬜待处理 / 🔄进行中 / ✅已完成**，含模块、优先级、描述、日期 |
| 完成归档 | 已完成任务归档到单独文档，并与主文档**双向链接** |
| 方案沟通 | 给出方案时用**选项对比**（含推荐项与理由、权衡），而非单一定论 |

---

## 14. 附录

### 14.1 术语表

| 术语 | 含义 |
|---|---|
| C4F7N | 全氟异丁腈（Novec 4710），环保绝缘气体 |
| GC5G1 | NDIR 传感模组型号（全氟异丁腈） |
| TJC | 淘晶驰（串口屏厂商），兼容 Nextion 指令风格 |
| `.pa` | TJC 页面块（含对象表与属性/脚本记录） |
| `.HMI` | TJC 工程容器（私有格式，非 ZIP） |
| `.zi` | 字库资源 |
| `printh NN` | TJC 脚本指令：串口发送 1 字节 |
| `get` 回读 | MCU 主动读取屏端控件值（`get obj.prop`），屏回根帧 |
| 顶栏 | 各页共用的状态区（探头/泵/电量胶囊与圆点） |
| stamp | `.HMI` 块校验字段（CRC32 ^ K 表） |

### 14.2 备份文件说明

| 文件 | 来源 | 可否删除 |
|---|---|---|
| `Core/Src/main.c.bak_serial` | 2026-09-18 序号页码偏移 + `pg` 唯一性注释改动前的备份 | 确认无回滚需求后可删 |
| `BSP/Src/history.c.bak_recover` | 2026-09-18 `history_init()` 上电恢复缺陷修复前的备份 | 确认无回滚需求后可删 |
| `Core/Src/main.c.bak_sync_order` | 2026-09-18 校时状态机 + 表格双栏顺序改造前的备份 | 确认无回滚需求后可删 |
| `Core/Src/main.c.bak_before_comment_clean` | 2026-09-11 注释乱码清理前的备份（内容：含乱码注释、显示字符串已修复） | 确认无回滚需求后可删 |
| `Core/Src/main.c.strfix.bak` | 字符串修复阶段备份 | 同上 |
| `Core/Src/main.c.rev2.bak`、`Middleware/*.rev2.bak`、`BSP/*.rev2.bak` | 更早的 rev2 备份 | 同上 |
| `Core/Src/main.c.bak`、`*.h.bak`、`uvprojx.bak/.bak2` | 历史备份 | 同上 |

> 建议：真机联调通过后统一归档或删除，避免目录膨胀。

### 14.3 参考文档索引（按目录细化）

> 说明：`C4F7N_Hardware/` 是**产品规格与硬件文档的总汇**（编号文档 + `tjc-project/` 规格设计 + `Software/` 参考骨架 + KiCad 工程），共约 60 个文件；`09_pages/*.json`、`11_scripts/*.hmi` 等内容内含逐页/逐控件明细，实际信息条目远多于文件数。

#### 14.3.1 顶层与固件

| 主题 | 文档 |
|---|---|
| 项目总览 | `README.md` |
| 文档导航 / 硬件连接速查 | `DOCS.md` |
| 全链路数据流详图 | `docs/c4f7n_full_dataflow_detail.html` |
| 固件总览 / 接线 / 约束 | `C4F7N_Demo/README.md` |
| **未验证项 / 已决定待实施项**（S/W/T/E/H/P/A/D 系列） | `C4F7N_Demo/待确认项清单.md` |
| 传感器规格书 | `docs/GC5G1(C4F7N)全氟异丁腈传感器V2.2.pdf` |

#### 14.3.2 屏端工具链 `tjc-hmi-toolkit/`

| 主题 | 文档 |
|---|---|
| 工具链总览（快速上手 / 核心概念 / 硬约束） | `README.md` |
| **AI 辅助工作流（脚本语言支持度以此为准）** | `AI_HMI_工作流.md` |
| `.HMI` / `.pa` 格式规范 | `FORMAT.md` |
| 工具用法明细（hmipack / verify / extract 等） | `TOOLS.md` |
| 脚本陷阱（**早期文档，`print`/`endif` 等说法已过时**） | `SCRIPTS.md` |

#### 14.3.3 产品 / 硬件 / 规格 `C4F7N_Hardware/`

**（1）根级编号文档**

| 编号 | 文档 | 内容 |
|---|---|---|
| 01 | `01_样件采购清单.md` | BOM 采购 |
| 02 | `02_台架验证方案.md` | 台架测试方案 |
| 03 | `03_立创元件对照表.md` | 元件对照 |
| 04 | `04_连接清单.md` | **接线/连接清单** |
| 05 | `05_手动重建指引.md` | 手动重建步骤 |
| 06 | `06_设计基线_v1.0.md` / `.html` | **设计基线** |
| 07 | `07_原理图绘制指南.html` | 原理图指南 |
| 08 | `08_数据导出方案.md` | 数据导出方案 |
| — | `README.md` | 产品总览 |
| — | `2026-08-28_工作日志.md` | 历史工作记录 |

**（2）`tjc-project/` — 屏端规格设计（JSON/MD 单一来源）**

| 编号 | 文档 | 内容 |
|---|---|---|
| 01 | `01_project_spec.md` | 产品规格（功能/页面/交互） |
| 02 | `02_project.json` | 工程元数据（分辨率/模板/字库） |
| 03 | `03_device.json` | 目标屏硬件定义 |
| 04 | `04_page_map.json` | 页索引与导航图 |
| 05 | `05_component_map.json` | 每页控件清单 |
| 06 | `06_variables.json` | 全局变量表 |
| 07 | `07_serial_protocol.json` | **MCU↔屏 串口协议** |
| 08 | `08_alarm_config.json` | 报警阈值配置 |
| 09 | `09_pages/p0_main.json`、`p1_settings.json`、`p2_curve.json`、`p3_about.json` | 逐页控件明细 |
| 10 | `10_assets/{background,button,font,icon}/README.md` | 资源规范 |
| 11 | `11_scripts/global.hmi`、`p0_main.hmi`、`p1_settings.hmi`、`p2_curve.hmi`、`p3_about.hmi` | 页面脚本草案 |
| 12 | `12_validation_report.md` | 验证报告 |
| 13 | `13_build/STM32_HMI_接口文档.md`、`STM32_HMI_接入教程.md`、`README.md`、`validation_summary.json` | **接口文档 / 接入教程 / 构建记录** |
| 14 | `14_下载烧录指南.md` | **烧录指南** |
| — | `tools/tjc_validator.py` | 屏端规格校验脚本 |
| — | `C4F7N_HMI_视觉稿_1024x600.html` | UI 视觉稿 |

**（3）`Software/` — 早期参考固件骨架（CubeMX 版）**

| 文档 | 内容 |
|---|---|
| `Software/README.md` | 骨架说明 |
| `Software/Core/Src/main.c`、`Core/Inc/*.h`、`Core/Src/tjc_cmd.c`、`hmi_callback.c`、`hmi_get.c` | 参考实现（**当前主线以 `C4F7N_Demo/` 为准**） |
| `Software/c4f7n_hmi_protocol.h`、`C4F7N_Hardware.ioc` | 参考协议 / 工程配置 |

**（4）`tools/` — 设计与导出脚本**

| 文档 | 内容 |
|---|---|
| `tools/C4F7N_HMI_搭建清单.md` | HMI 搭建清单 |
| `tools/C4F7N_HMI_视觉稿_1024x600.html` / `_v2.html` | 视觉稿（两版） |
| `tools/export_connections.py`、`generate_kicad.py`、`generate_easyeda.py` | 连接/EDA 导出脚本 |

**（5）KiCad / EDA 工程**

| 文件 | 内容 |
|---|---|
| `C4F7N_Hardware.kicad_pro`、`C4F7N_MainBoard.kicad_sch`、`C4F7N_MainBoard.json` | 原理图工程与网表 |
| `C4F7N_Hardware.zip`、`C4F7N_KiCad_v2.zip` | 打包快照 |

#### 14.3.4 早期屏端资源 `HMI/`

| 内容 | 说明 |
|---|---|
| `HMI/C4F7N_HMI_v17b.HMI` | 早期屏工程（v17b） |
| `HMI/DEMO*.HMI`、`串口屏文件.HMI`、`tjc_sample.HMI`、`touchScreen.HMI` | 演示/官方样例 |
| `HMI/extracted/`、`images/` | 已提取资源（`.zi` / 图片） |
| `HMI/XRD_TFT/` | 触控/变量配置文件（`.bin`） |
| `HMI/auto/` | GUI 自动化脚本与调试截图（根 README 提及，本 LS 未展开） |

> **当前开发不以 `HMI/` 为主**，仅作参考。

#### 14.3.5 EDA 输出 `C4F7N_LeakDetector-output/`（⚠️ 该目录已于 2026-09-24 移除）

| 文件 | 内容 |
|---|---|
| `C4F7N_Hardware.epro`、`.elibz` | 立创 EDA 工程/库导出 |
| `C4F7N_KiCad_v2.epro`、`.elibz` | 立创 EDA（KiCad v2 版）导出 |
| `_logs/chamelon.log` | 转换日志 |

### 14.4 版本演进（屏端）

**旧命名轨（`C4F7N_HMI_v*.HMI`）**：
`v17b → v18 → … → v83 → v84(基线) → v85 … v88(时间显示) → v89(补零尝试) → v90(零点阈值行) → v91/v92(恢复出厂双步，else 失败) → v93(双步确认最终版) → v93_pr / v93_thrsync / v94_printhfix → v97_thrB → … → v100`

**新命名轨（`C4F7N_v*.HMI`，当前在用）**：
`v1 → v2 → v3 → v4(在用基线) → v5(⚠️ 由 config + base.HMI 重建，错误过多，**弃用**) → v4_fix(09-18 一轮：`0.pa` 的 `p2R` 高度修复) → v4_fix2(09-18 二轮：再加 `4.pa` 主页横幅 `pg`→`ptitle`；**已验证基线**) → v4_fix3 / v4_fix4(⚠️ 09-20 迭代，未验证) → **v4_fix5(09-20：以 fix4 为模板新增独立初始化页 `6.pa`〔24 对象〕+ 主页移除预热覆盖层回 40 对象，7 页 check=33)** → **v4_fix6(09-20 三轮：`Program.s` 上电加载页 `page 0`→`page 6` 单字节补丁 @829/0x33D，与 fix5 恰 1 字节差异，当前交付)**

**固件 hex 命名轨（`C4F7N_v*_firmware.hex`）**：
`v4_firmware / v4_simtest → v5_firmware(09-18 一轮：补 `rsec` 镜像名 + 无条件 `refill_table`) → v6_firmware(09-18 二轮：补序号页码偏移 + `pg` 唯一性注释) → v7_firmware(09-18 三轮：补 `history_init()` 上电恢复缺陷；**已验证基线**) → v8~v16_firmware(⚠️ 09-20 迭代，未见编译/真机记录) → **v17_firmware(09-20：上电锁页6 + 预热结束/`0x07` 跳过进主页0 仅一次 + 移除 `OBJ_PREWARM` 驱动，Code=32650，已被 v18 取代)** → **v18_firmware(09-20 三轮：首发后 1.5s/2.5s 各补发一次 `tjc_page(6)` 规避上电竞态，Code=32678，当前交付)**

**教训**：v91/v92 用 `else` 编译失败（TJC 不支持）；`btn.val` 不能存自定义状态 → v93 改用 `Program.s` 全局变量 `cfs/cft`。
**教训（2026-09-18）**：`C4F7N_v5.HMI` 的失败不是"改错了对象"，而是**打包容器用错**（`base.HMI` 是 4 页空白容器）＋ **误把 `config_c4f7n.json` 当成 v4 工程的源**（该 config 并非由 v4 导出，二者对象集不一致）。屏端工程的**真源就是 `.HMI` 本身**：正确做法是 `extract-pas` 提取 → 增量改 `.pa` → 用**同一个 `.HMI` 作模板**回打包。

---

### 14.5 参考骨架（`C4F7N_Hardware/Software/`）与主线（`C4F7N_Demo/`）差异

> **定位**：`Software/` 是**早期骨架 / 设计参考**（配套 `C4F7N_HMI_v18.HMI`），其 `main.c` 中业务函数**几乎全是 TODO**。主线 `C4F7N_Demo/` 是其后演进出的完整实现。**新开发一律以主线为准**；`Software/` 仅用于：① 回溯原始设计意图；② 核对协议/指令宏的早期定义；③ 参考 CubeMX 接入说明。

#### （1）目录与工程结构

| 维度 | 参考骨架 `Software/` | 主线 `C4F7N_Demo/` |
|---|---|---|
| 分层 | 全部塞在 `Core/Inc` + `Core/Src`（4 对文件） | `Core`(CubeMX) / `BSP`(设备驱动) / `Middleware`(通信) 三层 |
| 协议头位置 | 工程根 `Software/c4f7n_hmi_protocol.h` | `Middleware/Inc/c4f7n_hmi_protocol.h` |
| BSP 模块 | **无**（sensor/battery/pump/w25q16/history/param_store 全部缺失） | 6 个模块齐全 |
| 构建 | 说明为 CubeMX → MDK/IDE | Keil `MDK-ARM/C4F7N_Demo.uvprojx` + eIDE `.eide/eide.yml` |

#### （2）CubeMX 配置（`.ioc`）

| 项 | 参考骨架 | 主线 |
|---|---|---|
| 外设 IP | 仅 `USART1 / NVIC / SYS`（3 个） | `USART1 / SPI1 / ADC1 / IWDG / NVIC / RCC / SYS`（7 个） |
| 引脚 | PA9/PA10/PD0/PD1（4 个） | 新增 PA4(W25Q64 CS)、PA5~PA7(SPI1)、PB1(ADC_IN9)、PA13/PA14(SWD) |
| 存储 / 电池 / 泵 / 看门狗 | 无 | 全部具备 |

> ⚠️ 两者 `.ioc` 的 MCU 均为 **STM32F103RCT6**（`Software/README.md` 第 35 行写 "F103C8T6" 属**笔误**）。

#### （3）命令码表差异（**不兼容**）

| 码 | 参考骨架 | 主线 |
|---|---|---|
| `0x11`~`0x17` | 高/低阈值、单位、蜂鸣、零点/量程/恢复出厂 | **相同** |
| `0x18` | — | **新增** `HMI_CMD_PUMP_TOG`（泵/测试启停） |
| `0x21` | `RANGE_10M`（曲线 10 分钟） | **改为** `VIEW_CURVE`（切曲线视图） |
| `0x22` | `RANGE_1H`（曲线 1 小时） | **改为** `VIEW_DATA`（切数据表视图） |
| `0x23` | `RANGE_24H`（曲线 24 小时） | **改为** `TBL_NEXT`（下一页） |
| `0x24` | `EXPORT` | `EXPORT`（码位相同） |
| `0x25` | — | **新增** `TBL_PREV`（上一页） |
| `0x40`~`0x43` | — | **新增** `PAGE0~3_ENTER`（进页通知） |

> **结论**：用参考骨架的命令码表去驱动主线屏端（v93）会导致**曲线/翻页/泵功能错乱**。

#### （4）对象名 / 指令宏 / 常量差异

| 类别 | 参考骨架 | 主线 |
|---|---|---|
| 对象名数量 | 约 20 个（`cc pv ba ps p9 pf pt pth h l u bb c0 c1 mx av mn du ct pst wv`） | **50+**：新增环境(`et/eh`)、最大最小(`cma/cmn`)、报警文本(`ald`)、阈值文本(`thv`)、副标题(`pu`)、顶栏胶囊/圆点(`pc0~pc2`,`pc0d~pc2d`+`_s1~_s3`,`bat`)、历史表格(`p2D ht hc tt* np* pg`)、视图切换(`sw0/sw1`)、曲线附件(`ctt leg alarm p2L p2R`)、电量系列 |
| 指令宏 | 9 条（`SET_VAL/TXT/PCO/PAGE/WAVE_ADD/WAVE_CLS/DIM/BEEP/GET`） | **12 条**，新增 `SET_PIC` / `SET_VIS` / `SET_BAT` |
| 颜色常量 | `C_STRIP_GREEN/ORANGE/RED` | **相同** |
| 圆点图片 / 电量阈值 | 无 | 新增 `PIC_DOT_*`(3/4/5/6)、`BAT_DOT_WARN_PCT/LOW_PCT` |

#### （5）通信层实现差异

| 文件 | 差异 |
|---|---|
| `tjc_cmd.c` | 骨架**缺少** `tjc_set_bat` / `tjc_pic` / `tjc_vis`；其余（`send_raw`/`set_val`/`set_txt`/`set_pco`/`page`/`wave_add`/`wave_cls`/`dim`/`beep`/`get`）逻辑一致 |
| `hmi_callback.c` | 骨架分发 **12 个码**（含 `hmi_on_range`）；主线分发 **19 个码**，去掉 range，改为 `hmi_on_view` / `hmi_on_tbl_page` / `hmi_on_page_enter` / `hmi_on_pump_toggle` |
| `hmi_get.c` | **基本一致**（`0x70` 数值 / `0x71` 字符串帧解析），主线沿用 |

#### （6）应用层（`main.c`）差异

| 维度 | 参考骨架（111 行，骨架） | 主线（667 行，实现） |
|---|---|---|
| 业务函数 | **全为 TODO / 空实现** | 完整实现 |
| 传感器 | 仅声明 `sensor_read_ppm()` 为 TODO | `BSP/sensor.c`：UART4 帧解析 + 标定换算 + 在线判定 + `SIM_MODE` |
| 报警映射 | 硬编码 `1000/500/100` | 动态阈值 `g_thr_hi/lo` + 超量程 `g_ppm > SENSOR_FS_PPM`（量程 1500，见 F3：`read_ppm()` 钳位 FS 使超量程分支实际不可达） |
| 单位换算 | TODO | **已移除**（2026-09-18 定：仅 ppm；`GY_PER_PPM`/`unit_mode` 全套已删，后者为废弃死字段） |
| 标定 | 3 个 TODO | 零点/量程实现 + **防误操作校验** + 按钮「失败/执行」交互 + W25Q64 持久化 |
| 恢复出厂 | TODO | 恢复默认 + **立即 `NVIC_SystemReset()`** |
| 阈值持久化 | 无（仅发 `tjc_get`，回包**未消费**） | `g_thr_pending` + `hmi_get_response()` + `param_save()` 闭环 |
| 存储 | 无 | W25Q64：参数(扇区 0) + 环形历史(扇区 1~2047)，每 1s 落盘 |
| 历史曲线 | 每次刷新**无条件** `tjc_wave_add(0,...)` | `sensor_has_new()` 触发 + `refill_curve()` 读最近 ≤672 点 + 统计 |
| 时间 | 无 | 屏 RTC 同步（方案A）+ `HAL_GetTick` 补偿 |
| 看门狗 | 无 | `iwdg_enable/feed`（约 4s） |
| 电池 / 泵 | 无 | ADC 电量 + 5 处显示；泵软件位 / GPIO |
| 进页回推 | 无 | `hmi_on_page_enter(p==1)` 回推阈值 + 蜂鸣器 |
| 状态圆点 | 无 | `hmi_update_status_chips()` 多页同步 |
| 蜂鸣 | `tjc_beep` 接口存在但**未被调用** | 进入报警响 1 声 + 每 2s 复响（受 `buzzer_en`） |

#### （7）可复用性判断

| 内容 | 可否复用 |
|---|---|
| `hmi_get.c`（get 应答解析） | ✅ 可直接复用（两者一致） |
| `tjc_cmd.c` 指令拼装 + 帧尾逻辑 | ✅ 逻辑一致，主线已扩展 |
| 指令宏 / 颜色常量（相同部分） | ✅ 可参考 |
| 命令码表 | ❌ **不可移植**（`0x21~0x23` 语义已改） |
| 对象名表 | ❌ 主线已大幅扩展，以主线为准 |
| `main.c` / `hmi_callback.c` | ❌ 骨架状态，**勿回退** |
| `Software/README.md` 的 CubeMX 接入流程（方式 A/B） | 🟡 流程可参考，但注意其 `.ioc` 仅 3 个外设、无 SPI/ADC/IWDG |

---

*本文档为交接用途，若与代码不一致，**以代码与 `待确认项清单.md` 为准**，并请更新本文档。*

> **2026-09-18 批量修正说明**：本次已把 `docs/交接/HANDOVER_2026-09-18.md` 第 7 节的 10 条修正合并进本文档，涉及 §0/§1.2/§1.3/§1.4/§2.3/§3.3/§4.2/§4.4/§5.1/§5.3/§6.3/§7.3/§8.1/§8.2/§8.4/§9/§10.3/§10.4/§11.1.1/§11.2/§11.4/§14.2/§14.4。
> 修正要点：① 编译工具链改为 **AC6 V6.24 @ `D:\KEIL\UV4`**（原"仅 AC5 / 编译被阻塞"的结论作废）；② 历史表 **24 条/页、左右双栏**（`tt/np/sn` 各 0..23）；③ 屏端工程切到 `C4F7N_v4_fix.HMI`，页 0 = 历史曲线；④ 打包模板必须用当前在用 `.HMI`（`base.HMI` 不可用）；⑤ 传感器为**文本行协议**；⑥ 校时状态机 `g_sync_st`；⑦ 历史表每 2s 无条件重绘。
> `开发进度表.md` 已在同日按同法同步。

> **2026-09-18 第二轮修正说明**（真机验证后）：本轮改动 §1.3（真机联调状态 → 「部分已开始」）、§1.4（交付产物 → `C4F7N_v7_firmware.hex` + `C4F7N_v4_fix2.HMI`）、§5.1（`4.pa` 横幅 `pg`→`ptitle`；新增「跨页重名规则」）、§6.3（`pg` 唯一性）、§7.3（`history_init` 上电恢复机制 + 两处陷阱）、§8.2、§8.4（追加第 6~10 项）、§9（+3 条决策）、§10.1（**混合编码实测清单**）、§10.3、§14.2、§14.4。
> 本轮核心新增事实：① 源码是**混合编码**（6 UTF-8 / 18 GBK），改写前必须逐文件判定；② 历史表序号必须计入页码偏移；③ TJC 跨页同名**只适用于状态类对象**（`pg` 实例）；④ `g_written` 上电恢复判据只认「head 非空」。

> **2026-09-20 批量修正说明**：本次已把独立初始化页（T-25）三轮成果与上电竞态双路修复合并进本文档，涉及 §1.3/§1.4/§3.3/§4.4/§5.1/§8.5（新增）/§10.3/§11.2/§14.4。修正要点：① 交付口径切换为 v18+fix6（验证口径仍为 v7+fix2）；② 「按复位键才进页6」根因（上电竞态）与双路修复；③ UV4 批处理挂起备忘；④ `.tft` 须 GUI 导出；⑤ 打包模板红线（用旧基线会丢页6）。

> **2026-09-18 第三轮修正说明（真机验证收口）**：§1.3（真机联调 → 「已开始」，屏端历史页链路全部通过）、§8.4 第 10 项（改为 ✅ 真机验证通过）、§11.1.3（满量程复核为 **1500 ppm**）、§11.2（T-04 更新烧录组合与状态；T-08 标为真机确认）。至此 2026-09-18 本轮 **6 项修复全部经真机确认**。
