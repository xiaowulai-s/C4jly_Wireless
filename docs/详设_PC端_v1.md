# C4F7N 无线版 · 分端详设 · PC 端 v1

> 关联：`产品架构总纲_v2.md` §M3 · 现有实现：`pc/`（Tauri 2 + Rust + btleplug，vanilla JS UI）
> 日期：2026-11-15 · 安装包：`dist/C4F7N_ProdTest_v0.1.0_setup.exe`

---

## 一、技术架构（已实现）

```
ui/ (vanilla HTML/JS, Tauri WebView)
   │ invoke / listen
src-tauri/src/
├── main.rs        # Tauri 命令层（scan/connect/厂家命令/台账）
├── ble.rs         # btleplug 会话：共享 Adapter、通知泵、请求-响应路由
├── protocol.rs    # 协议 v1.1 Rust 实现（7/7 冻结向量测试，与 Dart 互验）
└── ledger         # SQLite（rusqlite bundled）：%APPDATA%/C4F7N/prodtest.db
```

**已实现命令**：ble_scan / ble_diag / ble_connect / ble_disconnect / cmd_pump / cmd_mute / cmd_read_threshold / cmd_write_threshold / cmd_zero_cal_prepare / cmd_zero_cal_confirm / cmd_factory_cal / cmd_selftest / cmd_factory_reset / cmd_factory_auth / cmd_sn_read / cmd_sn_write / cmd_auth_hash_set / ledger_add / ledger_list

**关键实现教训**（沉淀给后续维护）：
1. `withGlobalTauri: true` 必须开启，否则前端全局 API 缺失、脚本静默崩溃；
2. btleplug Windows：**全程必须复用同一个 Adapter 实例**（WinRT 设备缓存按实例隔离）；
3. 连接要韧性：retry 3 次 + `is_connected` 兜底 + 失败强制 `disconnect()` 释放陈旧 GATT 会话（否则设备停广播、后续扫描为空）；
4. discover 前给 800ms 稳定期 + 重试 3 次（弱 RSSI 下 Unreachable 高发）。

## 二、产线工作流（一键产测，已实现 5 步）

```
上电 → ①自检 → ②零点校准（稳定判断） → ③阈值写入 → ④泵往返 → ⑤静音 → 判定 PASS/FAIL → 入台账
```
- 判定 FAIL 时：台账记录失败步骤与原因，设备不放行出厂；
- 产测流程与设备型号/阈值配置应可配置化（当前硬编码 50 ppm 阈值 → 待参数化）。

## 三、本轮新增功能设计

### 1. 出厂标定证书 PDF（F2）
- 产测 PASS 后自动生成：`证书编号（年+流水）、SN、标定日期、标定点值、示值误差、有效期、操作员`；
- 数据来源：产测记录 + 设备 cert_block（param 0x0011~0x0013）；
- 实现：Rust 端 `printpdf`/`rust_xlsxwriter` 同族库，或复用台账导出 HTML→打印；证书 PDF 同时打印一份给客户、存档一份进台账。

### 2. 批产队列模式（产线效率）
- UI 增加"连续产测"模式：读完 SN → 自动跑 5 步 → PASS 自动归档 + 提示换下一台 → 计数统计（今日产量/良率）；
- 失败设备标红并提示复测/返修分流；
- 支持 CSV 导出当日批次。

### 3. 售后诊断包（F6 第一代）
- "提取诊断包"命令：经 BLE 读出 SN + 固件版本 + param 全表（厂家会话）+ 维护计数 + 最近 20 条事件 → 打包 `C4F7N_diag_<SN>_<日期>.json`；
- 厂家收到文件 → PC 工具"导入分析"页：参数逐项展示 + 与标准值比对 + 修改建议；
- 零云端依赖，微信传输即可完成售后闭环。

### 4. USB-CDC 传输层（产线主通道）
- `Transport` trait（已规划）：`scan / connect / send / notifications`，BLE 与 SerialPort 双实现；
- USB-CDC 固件上线后，产线用 USB 线直连（免蓝牙配对干扰，速度更快更稳）；
- 前端不感知差异。

### 5. OTA 烧写入口（F4 联动）
- PC 端选择固件包（.bin + 元信息）→ 经 BLE/CDC 执行 0x70 命令族推流 → 校验 + 切换 → 读回版本确认；
- OTA 属高危操作：仅厂家会话 + 二次确认 + 失败自动回滚提示。

### 6. 产线对接预留（MES/ERP）
- 台账表结构已含 sn/ts/steps/verdict/note → 增加批次号/工单号字段；
- 导出接口先做 CSV，HTTP 推送（MES webhook）放 R4。

## 四、发布与运维

- 版本：0.1.0（NSIS 安装包 + portable exe 双形态，dist 归档惯例已建立）；
- 数据迁移：rusqlite `user_version` 惯例，与 App 端 sqflite 同思路；
- 自动更新（未来）：Tauri updater 插件 + 云端版本清单（R4）。
