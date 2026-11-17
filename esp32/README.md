# C4F7N BLE Bridge（ESP32-S3 固件）

> 传输层透传网桥：手机 BLE ↔ UART ↔ STM32。**零业务解析**（协议 v1 帧仅用于切分通知，内容不解读）。
> 规格：`docs/无线版开发方案与路线图_v1.md` §6 · 协议：`docs/协议v1.md` §4.6/§5

## 行为

1. 开机即广播 `C4F7N-XXXX`（menuconfig 可配），含 128-bit 服务 UUID；
2. 手机连接后协商 MTU 517，订阅 notify 特征即可收到 1Hz 实时帧；
3. 手机写入 write 特征 → 原样转发 UART（Write Without Response）；
4. UART 收到完整帧（`A5 5A + LEN`）→ 恰好一条帧发一条 BLE notify；非帧流 30ms 空闲后原样透传（透明兜底）；
5. 断连后 200ms 自动恢复广播（App 端自动重连即可恢复）；
6. UART 静默 >20s 打印告警日志（STM32 掉线排查用）。

## 接线（外挂验证阶段）

| ESP32-S3 | STM32 | 说明 |
|---|---|---|
| GPIO17 (TX) | PB7 (USART1_RX) | menuconfig 可改 |
| GPIO18 (RX) | PB6 (USART1_TX) | menuconfig 可改 |
| GND | GND | 必须共地 |
| 5V | 主板 5V 轨 | 走板载 LDO，勿直接接 3.3V 轨拖载 |

波特率 115200-8N1。

## 构建 / 烧录（ESP-IDF v5.4）

### 本机已验证的环境变量（2026-11-14 编译通过，PowerShell）

> 背景：Espressif/Keil 安装目录曾从 D 盘迁移到 C 盘（`C:\Software\Espressif`），
> `idf_cmd_init.bat` 失效；venv 的 `pyvenv.cfg` 已手工修正为 C 盘路径；
> IDF 仓库曾被删过 `components/bootloader/Kconfig.log`（已 git restore）；
> `idf.py` 拒绝在 Git Bash(MSYS) 下运行，必须用 PowerShell/cmd 原生环境。

```powershell
$env:IDF_PATH="C:\Software\Espressif\frameworks\esp-idf-v5.4.1"
$env:IDF_TOOLS_PATH="C:\Software\Espressif"
$env:IDF_PYTHON_ENV_PATH="C:\Software\Espressif\python_env\idf5.4_py3.11_env"
$env:ESP_ROM_ELF_DIR="C:\Software\Espressif\tools\esp-rom-elfs\20241011\"
Remove-Item Env:MSYSTEM -ErrorAction SilentlyContinue
$env:PATH="C:\Software\Espressif\python_env\idf5.4_py3.11_env\Scripts;C:\Software\Espressif\tools\cmake\3.30.2\bin;C:\Software\Espressif\tools\ninja\1.12.1;C:\Software\Espressif\tools\xtensa-esp-elf\esp-14.2.0_20241119\xtensa-esp-elf\bin;C:\Software\Git\cmd;$env:PATH"
Set-Location "D:\Demo\C4JianLouYi\C4F7N_Wireless\esp32"
python "$env:IDF_PATH\tools\idf.py" set-target esp32s3   # 首次
python "$env:IDF_PATH\tools\idf.py" build
python "$env:IDF_PATH\tools\idf.py" -p COMx flash monitor
```

产物：`build/c4f7n_bridge.bin`（已归档 `../dist/C4F7N_ESP32_bridge_v1.bin`）。

### 通用步骤

`sdkconfig.defaults` 已按 NimBLE-only 预配（禁用 Bluedroid、单连接、MTU 517、8MB Flash）。

## 联调顺序（Phase 2 任务 2-1）

1. 先不接 STM32：烧录后用手机 App 扫描 → 应出现 `C4F7N-0001`；
2. 接上 STM32 USART1（**先实测 PB6/PB7 空闲与 3.3V 电平**，风险 R4）；
3. STM32 侧无线协议模块（`fw/` 工程 wireless.c）就绪后，App ↔ ESP32 ↔ STM32 全链路闭环；
4. 验证项：连接/浓度 1Hz 刷新/泵与静音控制往返/断连重连/报警自治（App 断开后设备侧仍报警）。

## 已知边界

- PC 直连（方案 §8 的 USB-CDC 通道）Phase 4 实现：临时方案是 ESP32-S3 的 USB-Serial-JTAG 口看日志；正式方案可上 TinyUSB CDC 复用同一透传逻辑。
- 广播名与设备编号（param 0x0008）的一致性由出厂烧写保证，固件侧不做校验。
