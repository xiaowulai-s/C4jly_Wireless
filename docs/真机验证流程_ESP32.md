# ESP32-S3 真机验证流程（手把手）

> 适用：手头一台 ESP32-S3 开发板 + 一台 Android 手机（已装 `dist/C4F7N_Sim_debug.apk` 或 `C4F7N_App_user_debug.apk`）
> 产物：`dist/C4F7N_ESP32_bridge_v1.bin`（源码 `esp32/`，已编译通过）
> 日期：2026-11-14

---

## 阶段 A：只烧 ESP32（不接 STM32）——验证"广播/连接/透传链路"

### A0. 准备

1. USB **数据线**连接开发板（DevKitC 有两个口：标 **USB** 的口走板载 USB-Serial-JTAG，Win10/11 免驱动；标 **UART** 的口是 CP210x/CH343 转换，可能要装驱动）。优先用 **USB 口**；
2. 确认串口号：设备管理器 → 端口(COM & LPT) → 记下 `COMx`（插入/拔出对比出现消失的那个）。

### A1. 烧录（PowerShell，环境已在本机验证）

```powershell
$env:IDF_PATH="C:\Software\Espressif\frameworks\esp-idf-v5.4.1"
$env:IDF_TOOLS_PATH="C:\Software\Espressif"
$env:IDF_PYTHON_ENV_PATH="C:\Software\Espressif\python_env\idf5.4_py3.11_env"
$env:ESP_ROM_ELF_DIR="C:\Software\Espressif\tools\esp-rom-elfs\20241011\"
Remove-Item Env:MSYSTEM -ErrorAction SilentlyContinue
$env:PATH="C:\Software\Espressif\python_env\idf5.4_py3.11_env\Scripts;C:\Software\Espressif\tools\cmake\3.30.2\bin;C:\Software\Espressif\tools\ninja\1.12.1;C:\Software\Espressif\tools\xtensa-esp-elf\esp-14.2.0_20241119\xtensa-esp-elf\bin;C:\Software\Git\cmd;$env:PATH"
Set-Location "D:\Demo\C4JianLouYi\C4F7N_Wireless\esp32"
python "$env:IDF_PATH\tools\idf.py" -p COMx flash monitor
```

- `COMx` 换成你的实际串口号；
- **连不上时**：按住板上 **BOOT** 键 → 点按 **RST** → 松开 BOOT 再回车重试；
- `monitor` 里期望看到：

```
I (xxx) main: C4F7N bridge up
I (xxx) ble_gatt: stack synced, advertising as C4F7N-0001
I (xxx) uart_bridge: uart1 tx=17 rx=18 @115200
```

退出 monitor：`Ctrl+]`。

### A2. 手机侧验证广播 + 连接（二选一）

**方式 1（推荐先做）：nRF Connect（或任意 BLE 调试 App）**
1. 扫描 → 应出现 **`C4F7N-0001`**；
2. Connect → 应看到 Service `48B5C976-CAE8-4BA4-...` 下两个特征（...A5 可写、...A6 可通知）；
3. 点 ...A6 的 **订阅（向下箭头）**；
4. 在 ...A5 写一帧十六进制：`A5 5A 02 20 01 D9 B0`（泵开命令，CRC 已按协议算好）；
5. ✅ 预期：...A6 **立刻回推一条通知**（无 STM32 时 UART 空发，帧会进 UART 但无回包——**此时 A6 无回推也属正常**，见阶段 B 环回测试）。

**方式 2：装好 `C4F7N_App_user_debug.apk` 的手机**
1. App → 设备页 → 刷新 → 出现 `C4F7N-0001` → 点连接；
2. ✅ 预期：状态变"已连接"；浓度区**无数据跳动是正常的**（还没有 STM32 提供 0x10 帧）——本阶段只验证"扫描/连接/订阅"三件事。

### A3. 环回测试（不接 STM32 也能验证整条透传链路）★推荐

1. 用杜邦线把 ESP32 的 **GPIO17(TX) 与 GPIO18(RX) 短接**（自发自收）；
2. 手机 App 或 nRF Connect 向 ...A5 写上面那帧泵命令；
3. ✅ 预期：...A6 **立刻回推同一帧**（BLE→UART→环回→UART→BLE 全链路通了）；
4. 这一步通过 = 透传网桥固件完全工作，接 STM32 后即整链路闭环。

---

## 阶段 B：接 STM32（全链路闭环，里程碑 M1）

### B0. 前置

1. STM32 烧录 `dist/C4F7N_fw_wireless_v1.hex`（ST-Link / Keil 均可）；
2. ⚠️ **接线是 USART2，不是老方案的 USART1**：

| ESP32-S3 | STM32F103 |
|---|---|
| GPIO17 (TX) | **PA3 (USART2_RX)** |
| GPIO18 (RX) | **PA2 (USART2_TX)** |
| GND | GND（必须共地） |
| 5V | 主板 5V 轨（经板载 LDO） |

3. 通电前先确认 PA2/PA3 上没有焊其他外设。

### B1. 上电观察

1. ESP32 monitor：应持续打印 1Hz 到来的 UART 数据（无报错）；
2. 手机 App 连接 `C4F7N-XXXX` → **浓度大数字开始实时跳动、曲线滚动**；
3. ✅ 这一刻 = **里程碑 M1 达成**。

### B2. 全功能走查（按 `开发进度表.md` §真机清单）

| 验证项 | 操作 | 预期 |
|---|---|---|
| 实时数据 | 观察 1 分钟 | 1Hz 刷新无断流 |
| 泵控制 | App 开泵/关泵（往返各 2 次） | 状态正确回显（含"关泵"） |
| 静音 | 触发报警后点静音 | 设备侧蜂鸣停；App 断开 15s 后自动恢复报警 |
| 阈值修改 | 设置页改阈值 + 二次确认 | 设备保存；重启后仍生效 |
| 零点校准 | 设置页向导两步 | 校准成功，标定时间戳变化 |
| 历史回放 | 设置页 → 设备历史 | 能读到落盘点（1Hz 累积） |
| 任务+报告 | 开始检测→结束→导出 PDF | 报告可分享打开 |
| 断线重连 | 杀 ESP32 电源再上电 | App 自动重连，数据恢复 |
| 报警自治 | App 断开后制造超限 | 设备本地蜂鸣照常（不依赖 App） |
| 厂家端 | factory APK → 登录（任意口令，旁路期）→ 写 b/k | >20% 触发二次确认；写入生效 |

---

## 常见问题速查

| 症状 | 原因/处理 |
|---|---|
| `Failed to connect` 烧录失败 | 进不了下载模式：按住 BOOT 再复位；或换了 UART 口需装驱动 |
| 扫描不到 `C4F7N-0001` | monitor 是否打印 "advertising"；手机位置/权限（App 首扫会请求"附近的设备"权限） |
| 连接后无浓度数据 | 阶段 A 属正常（无 STM32）；阶段 B 检查 TX/RX 是否交叉（ESP32 TX→STM32 RX）、共地 |
| 泵/静音无响应 | 检查接线交叉 + monitor 是否有 uart overflow 告警 |
| App 显示连接但 15s 后掉线 | STM32 侧没在发帧：查 hex 是否为本无线版（非屏版 b98），查 PA2/PA3 |
