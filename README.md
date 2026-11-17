# C4F7N 便携式检漏仪（全氟异丁腈）

> 用于 GIS / 高压断路器 / 环网柜等环保绝缘气体（C4F7N / NOVEC 4710）泄漏检测的便携式检漏仪。
> 主控：STM32F103RCT6　|　传感器：GC5G1 NDIR 全氟异丁腈传感模组　|　屏幕：TJC 7寸 USART HMI 1024×600

***

## 目录架构

```
C4jly/
├── AGENTS.md                     # ★ AI/人工协作硬约束（源码 GBK 编码、编译工具链、TJC 限制、改动纪律）
├── DOCS.md                       # 文档导航（快速入口 / 硬件连接速查 / 当前屏工程版本指针）
├── 开发进度表.md                  # 分模块进度与待办（按优先级）
├── HANDOVER.md                   # ★ 权威交接文档（仓库地图、协议、设计决策、避坑清单）
│
├── docs/                         # ★ 过程文档 + 图纸（2026-09-24 归集，原来 22 份平铺在根目录）
│   ├── 变更记录/                  #   逐版变更与验证记录
│   │                             #   v7（★ 按键音效）/ v6（h 阈值三方闭环）/ v5（页号语义对齐）/
│   │                             #   fix13（手动改版检查）/ fix12（★ 标定链路重构）/ fix11（键盘回读·时间刷新）
│   ├── 评审与方案/                #   标定逻辑评审 / 标定与恢复出厂内部流程 / fix12 实施方案 /
│   │                             #   HMI 工程结构审计报告 / 字库瘦身方案 / 项目目录整理方案
│   ├── 交接/                     #   HANDOVER_2026-09-18（当日快照）/ HANDOVER_PROMPT（提示词）/
│   │                             #   PROMPT_历史表时间列 / T-04_T25 真机验证清单 / 未实现功能清单_待确认
│   ├── 编码治理/                 #   C4F7N_中文注释乱码修复报告（GBK/UTF-8 治理方法与证据）
│   └── 图纸与资料（直接放 docs/ 下，2026-09-24 从根目录收进来）
│       C4.dwg · 面板.dwg · 面板.bak              # 结构件图纸
│       C4F7N_Demo.pdf                           # 固件说明
│       docs/GC5G1(C4F7N)全氟异丁腈传感器V2.2.pdf      # 传感器规格书
│       docs/JHLK100-HQ4 C4F7N混合气体检漏仪说明书 2024.01.03.pdf
│       docs/KLVP1泵.pdf · docs/SCH_Schematic1_2026-09-14.pdf
│       docs/TJC1060X570.HMI                          # 10.6″ 另一型号样例（与当前 7″ 1024×600 不同）
│       docs/c4f7n_full_dataflow_detail.html          # 数据流图
│
├── C4F7N_Demo/                   # ★ 主控固件工程（STM32F103RCT6）
│   ├── Core/                     #   CubeMX 管辖：main.*（应用主体）、usart/gpio/adc/spi
│   ├── Drivers/                  #   HAL + CMSIS（CubeMX 生成，勿手改）
│   ├── BSP/                      #   自管驱动：sensor / battery / pump / w25q16 / history / param_store / selftest
│   ├── Middleware/               #   自管通信：tjc_cmd / hmi_callback / hmi_get / 协议唯一事实源
│   ├── .eide/                    #   eIDE 工程配置（eide.yml）
│   ├── .ioc / .mxproject         #   CubeMX 工程（重生成用）
│   ├── MDK-ARM/                  #   Keil 工程 + startup + 编译产物（.hex）
│   ├── README.md                 #   固件总览 + 进度 + 接线 + 约束注意事项
│   └── 待确认项清单.md            #   未核实项（传感器帧 / 分区 / RTC / 泵引脚等）
│
├── tjc-hmi-toolkit/              # ★ 屏幕程序化生成工具链（AI 辅助；约 1.5G）
│   ├── C4F7N/                    #   目标工程：config_c4f7n*.json、C4F7N_v1~v12.HMI（当前轨，**最新 v12**）
│   │                             #   ⚠️ `.HMI`/`.tft` 均被 .gitignore 排除，备份见下方「屏包与固件归档」
│   │                             #   ⚠️ 旧命名轨 C4F7N_HMI_v18~v100 归档已于 2026-09-24 **移出仓库**
│   │                             #   → 现在 `D:\Demo\C4jly-archive\Archiving\`（1448 文件 / 2.0 GiB，md5 全量校验过）
│   ├── gen_hmi2.js               #   config.json → .pa 页面块
│   ├── lib/                      #   page / stamp / container / png / rgb565（Node）
│   ├── seeds/ template/          #   控件模板 / 基础 HMI 模板
│   ├── tools/                    #   hmipack-tjc / verify_all_pages / check-page / extract-* (.NET)
│   └── README.md / FORMAT.md / TOOLS.md / SCRIPTS.md / AI_HMI_工作流.md
│
├── C4F7N_Hardware/               # 产品规格 / 硬件设计 / 集成文档（原 `C4F7N_LeakDetector/`）
│   ├── 01_样件采购清单.md ~ 08_数据导出方案.md   # BOM / 台架 / 连接 / 设计基线 / 导出
│   ├── *.kicad_pro / *.kicad_sch / *.json        # 原理图工程（文件名仍保留旧称）
│   ├── C4F7N_HMI_搭建清单.md / C4F7N_HMI_视觉稿*.html  # 屏端搭建清单与视觉稿
│   ├── export_connections.py / generate_*.py     # KiCad / EasyEDA 导出脚本
│   ├── tjc-project/              #   屏幕工程规格（01~14 + 13_build 接口文档/接入教程）
│   └── README.md                 #   产品总览
│                                 #   注：原 `tools/`、`Software/` 两个子目录已于 2026-09-24 移除
│
├── HMI/                          # 早期屏幕工程与开发资源（当前开发不以此为主）
│   ├── C4F7N_HMI_v17b.HMI / DEMO*.HMI / 官方样例
│   ├── extracted/ images/ image/ #   已提取资源（.zi / 图片）
│   ├── auto/                     #   屏幕 GUI 自动化脚本 + 调试截图
│   └── XRD_TFT/ TFT/ ICON/       #   触控/变量配置、图标资源
│
├── text_demo/                    # 独立 CubeMX 点灯/按键验证工程（原 `led/`，前身 test_btn_led/ 已删）
│                                 # ⚠️ 与主控固件无关，纯验证用
│
├── 屏包备份/                      # ⚠️ 本地屏包备份（**已在 .gitignore 排除，不是源码**）
│   ├── C4F7N_屏端_v12_*.HMI       #   当前使用版（md5 2cd86542…，配固件 V1.0-b98）
│   ├── C4F7N_屏端_v11_*.HMI       #   上一版备份
│   └── README.md                 #   屏页 ID 对照 / 屏固配套 / 恢复步骤
│
└── _archive/                     # ⚠️ 本地归档（**已在 .gitignore 排除，不是源码**；2026-09-24 归集）
    ├── backups/                  #   14 个回退快照：编码治理、Flash/USART/IOC、fix11/fix12、RTC、
    │                             #   初始化计数、skip 守卫、getfeed 等
    ├── hmi_build/                #   HMI 组装工作目录（extract-pas → 改 .pa → hmipack 回打包）
    ├── hmi_audit/                #   HMI 结构审计解包产物
    ├── trash/                    #   上轮清理的暂存区（**待删**，见 `docs/评审与方案/项目目录整理方案`）
    └── old-skills/               #   已废弃的 `.trae` skill
```

> **09-21 仓库清理**：根目录 ~65 个调试临时件（`_p6all.txt` 等）、临时构建副本 `_buildcheck/`、
> 会话脚本（`transc.js` / `sigs*.ps1` / `disasm.txt`）已移出仓库（本地留存于 `D:\Demo\_c4jly_trash_20260921\`），
> 并把相应模式写入 `.gitignore`。备份目录与调试件**不再进仓库**。

## 屏包与固件归档（★ `.HMI` 不在 Git 里 —— 仓库不是屏包的备份源）

`.gitignore` 第 112 行有 `*.HMI`，**屏工程文件一律不进仓库**。本地与云盘各留一份：

| 位置 | 内容 | 说明 |
|---|---|---|
| **云盘（主备份）** | **`D:\移动云盘同步盘\C4F7N检漏仪\`** | 98 个文件 / 2.6 GB：屏包 HMI ×60、编译产物 TFT ×17、固件 hex ×20，另有 `说明.md` 与 `文件清单_md5.txt`（逐文件与源比对，零不一致） |
| 本地 | `D:\Demo\C4jly\屏包备份\` | 当前版 v12 + 上一版 v11 + README（已 gitignore） |
| 工作目录 | `D:\Demo\C4jly\tjc-hmi-toolkit\C4F7N\` | 52 个 `.HMI` + 17 个 `.tft` + 19 个 `*firmware.hex`（源头） |

云盘客户端：移动云盘桌面端 `D:\yidongyunpan\mCloud\mCloud.exe`，**同步目录 `D:\移动云盘同步盘\`**，
自动同步间隔 300 秒（把文件放进该目录即会上传）。

**当前配套版本**：屏 `C4F7N_v12.HMI`（md5 `2cd86542fee35fd9006055e6206909f4`）
+ 固件 `V1.0-b98`。v12 屏含厂家页手动补偿控件，**必须配 `V1.0-b79` 及以后的固件**。

> 屏固恢复时注意：屏口是 **USART3 @ 115200**（源码注释里的 9600 是错的）；
> 各页 `load` 里的 `printh 4N` 是切页通知来源，**不要删**（滑动翻页靠它）。

### 下载（供访客）

屏包与固件**不进 Git**（单个 `.HMI` 30~51 MB、`.tft` 24~45 MB，`.gitignore` 含 `*.HMI` / `*.tft`）。
访客请从移动云盘分享链接下载，**无需登录**：

| 内容 | 链接 |
|---|---|
| **全部归档**（屏包 HMI ×60、编译产物 TFT ×17、固件 hex ×20，合计 2.6 GB） | 🔗 **[移动云盘分享](https://yun.139.com/shareweb/#/w/i/2yrhLF2Q2BArn)** |
| 当前使用版 `C4F7N_v12.HMI`（53.6 MB，md5 `2cd86542fee35fd9006055e6206909f4`） | 🔗 同上（归档内 `屏包_HMI\C4F7N_v12.HMI`） |
| 当前固件 `C4F7N_当前_V1.0-b98.hex`（148 KB） | 🔗 同上（归档内 `固件_hex\C4F7N_当前_V1.0-b95.hex`，**待更新为 b98**） |

> **打开方式**：移动云盘分享链接。网页端直接打开即可；若提示「复制内容打开移动云盘 PC 客户端」，
> 说明该分享是以客户端为主的口径，装了移动云盘桌面端（`D:\yidongyunpan\mCloud\`）体验更顺。
>
> **校验**：下载后请用归档内的 `文件清单_md5.txt` 核对 md5 —— 98 个文件均有记录。
>
> ⚠️ **分享链接不便回收**：任何拿到链接的人都能下载，且难以限制范围。
> 需要收回时，到移动云盘取消该分享后回来把本节的链接删掉。
> 若只想开放当前版本，在客户端里单独分享 `C4F7N_v12.HMI` 与 `C4F7N_当前_V1.0-b98.hex`（约 54 MB），不要把全部 2.6 GB 归档开放出去。


## 各主要工作区说明

| 工作区                   | 定位                                                         |
| --------------------- | ---------------------------------------------------------- |
| `C4F7N_Demo/`         | **主控固件**：STM32 + 屏通信、传感器采集、电池、泵、存储、标定/设置。Keil(`MDK-ARM`) / eIDE 产出 `.hex` |
| `tjc-hmi-toolkit/`    | **屏幕程序化生成**：JSON 配置 → 自动生成/校验 `.HMI` 工程与界面脚本；当前屏工程与固件 hex 都在这里       |
| `C4F7N_Hardware/`     | **产品与硬件**：规格、BOM、连接、台架方案、设计基线、KiCad 原理图、屏端规格文档（原 `C4F7N_LeakDetector/`） |
| `HMI/`                | 早期屏幕工程源文件与 GUI 自动化开发资源（参考用）                                     |
| `text_demo/`          | 独立点灯/按键验证工程，与主控固件无关（原 `led/`）                                        |
| `docs/`               | **过程文档归集 + 图纸资料**：变更记录 / 评审与方案 / 交接 / 编码治理（2026-09-24 从根目录收进来）     |
| `_archive/`           | 本地归档：14 个回退快照 + HMI 组装工作目录 + 审计解包产物；**已在 `.gitignore` 排除，不是源码** |
| `DOCS.md`             | 全项目文档导航、硬件连接速查、**当前屏工程版本指针**                                    |

> **2026-09-24 目录调整**：`C4F7N_LeakDetector/` → **`C4F7N_Hardware/`**、`led/` → **`text_demo/`**；
> `C4F7N_LeakDetector-output/`（KiCad elibz/epro）与 `C4F7N_HMI_v3/`（屏端改版试验）**已移除**。
> 过程文档统一收进 `docs/`，历史归档集中到 `_archive/`（工作区 4.7 G → 2.7 G）。

> **要烧录哪个文件** → 看 [`DOCS.md`](./DOCS.md) §0 与 [`HANDOVER.md`](./HANDOVER.md) §1.4（文档基线与磁盘实测产物分开标注，未验证产物会明确标记）。
>
> ✅ **当前状态（2026-10-29）：交付口径 = 屏 `tjc-hmi-toolkit/C4F7N/C4F7N_v12.HMI` + 固件 `V1.0-b98`**
>
> | 项 | 值 |
> |---|---|
> | 屏包 | md5 **`2cd86542fee35fd9006055e6206909f4`** / 53635680 B（含 v8 基线的 `pst_i` + `lb`/`lb_i` + `pc2_i` + 设置页 `fw`/`sn`，**加**：各页 `load` 首行 `printh 4N`（滑动翻页入屏信号，v78）+ 厂家页手动补偿控件 `cb`/`ck`/`bcb`/`bck`/公式 `cfc`（v79~v92）；核验 `pages ok=6 bad=0` / 页 ID 未漂移 / T-28 无异常 / 固件引用对象零悬空；⚠️ **`.HMI` 一律不入库**，见上方「屏包与固件归档」小节）|
> | 固件 | **`PRODUCT_FW_VERSION = "V1.0-b98"`** / `main.c` md5 `69be0a3d1f00eddb65eb068cc5a1a82f` / 产物 hex md5 `6ec3c1142b28b95ac4db9f45d5908f54`（Keil Rebuild，0 Error 0 Warning）/ Total RO **53636** / Total ROM **53748** / USART3=115200 |
> | 验证 | **v42~v92 全部真机验证通过**（v92 = 厂家页手动补偿 cal_b/cal_k 收口）；**v98 换新电池电量曲线：满电显示 100% 已真机通过**（实测 16.39~16.40V → 屏显 100%，旧固件同点仅 97%），其余待真机 |
>
> **v50~v59 逐版要点**
>
> | 版 | 内容 |
> |---|---|
> | v50 | 修 2 个 P0：电池自检判据恒真（加 `g_batt_valid` / `battery_valid()`）/ 零点标定在洁净空气（raw=0）报「非法值」（`raw <= 0` → `< 0`）；文案「电池检测异常」→「电池采样异常」 |
> | v51 | 修 2 个 P1：`get` 应答通道串扰（新增 `g_get_busy` 单一所有权）/ 电量限幅改**只限跌** |
> | v52 | 序号语义澄清（`%9999` 是屏端 4 位容量折中，非计数错误）/ 删死代码 / 时间基准注释订正。**首轮排查收口** |
> | v53 | 修 2 条 P0：**补 `HAL_UART_ErrorCallback`**（USART3 一次 ORE 即永久失联）+ **首次启用硬件 IWDG**（改工程文件 `.uvprojx`，PRESC=32/RELOAD=4000，窗口 2.13~4.27 s）|
> | v54 | 修「开始测试 + 切历史页 ⇒ 重启」（根因：`HAL_UART_Transmit` 100 ms 超时**逐次叠加**，78 次 = 7.8 s ≫ 窗口）→ 超时改 20 ms + `refill_table` 循环内喂狗 |
> | v55 | 撤销 v54 多余的降频层（用户反馈「5 秒更新一次、一次五条」），恢复**每秒更新**，喂狗加密到每 2 行 |
> | v56 | 修 2 条 P1：阈值按键被静默丢弃（放弃判据改墙钟 `THR_HI_PATIENCE_MS=8000u`）/ 看门狗**完全移出 ISR**（反汇编铁证：`hmi_on_page_enter` 零 `BL`）|
> | v57 | 接收重挂自愈（`app_refresh` 每 250 ms 重试到 `HAL_OK`）/ 取消静音立即恢复鸣响。**二次排查收口** |
> | v58 | 修 **P0-A `hist_base` 陈旧**（清空历史后任意参数保存会覆盖清空标记 ⇒ 历史错乱 + 逐步擦除）+ **13 个跨 ISR 变量补 `volatile`** |
> | v59 | 修 **P0-B 参数区静默失效**：改为「让丢失可见」（独立扇区存失效标志 + POST 页橙色提示「参数已重置，请重新设置阈值」）|
>
> **三次功能逻辑排查**（逐条带文件行号依据，报告见 `docs/评审与方案/`）：首轮 12 项 + 二次 6 项 + 三次 8 项。
> 其中查出**前三轮全漏的 3 条数据丢失缺陷**（P0-A `hist_base` 陈旧 / P0-B 102 槽写满擦扇区 / P1-A 同扇区耦合）——
> 它们只在**掉电 / 长期使用 / 清空后改设置**这类**跨会话场景**下显形，运行一次设备看不出任何异常。
> 09-24 整机联调通过（v23）后逐版真机演进：v24/v25（串口减压 L1+L3，**操作延迟消失**）→ v26/v27（T-15 POST + Flash 故障禁写）→ v28（**T-13 泵 PWM 真机闭环**：PB6/TIM4_CH1，启停受控）→ v29~v33（满电基准 16.3V / **T-09 低电三级** / 电量量化滞回 + 满电特判 / 测量校准 1.009）→ v34（标定结果显示）→ v35（零点阈值 50ppm）→ v36（VDDA 每轮重测）→ **v37/v38（预热期电量文本冻结修复 + 固件切页登记页面状态）+ 屏 v8（预热页时间不闪）→ v39（初始化页电量 chip 回收为 `pc2_i`，4 页命名对称 + `tjc_set_bat` 第 4 项）—— 09-30 真机验证通过**。
> 09-22 起编译链路已打通（`UV4.exe` 须**经 shell(cmd) 启动**；直接 `CreateProcess` 会 `EACCES`，**与 Keil GUI 是否运行无关** —— 旧结论已更正），v19~v23 逐版有编译日志归档。
> 同日完成仓库整理（过程文档归集 `docs/`、目录改名、`Archiving/` 2.0 GiB 移出仓库，工作区 4.7 G → 2.7 G）并推送 GitHub（`78f0cac`）。
> ~~此前（09-18 起）交付口径为 `C4F7N_v7_firmware.hex` + `C4F7N_v4_fix2.HMI`（仅历史页链路），其间 v8~v23 / fix3~v7b 均未真机~~ —— 已于 2026-09-24 被 **v23 + v7b** 取代。

> 详细文档索引、硬件接线速查 → 见 **[`DOCS.md`](./DOCS.md)**

