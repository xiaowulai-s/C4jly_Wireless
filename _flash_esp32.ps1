# _flash_esp32.ps1 - one-shot ESP32 bridge flash + monitor
# Usage (from any directory):
#   powershell -ExecutionPolicy Bypass -File D:\Demo\C4JianLouYi\C4F7N_Wireless\_flash_esp32.ps1 COM5
#   (port defaults to COM5; first arg overrides)
param(
    [string]$Port = "COM5"
)

$ErrorActionPreference = "Continue"

# --- IDF environment (paths verified 2026-11-14; D-drive legacy paths are gone) ---
$env:IDF_PATH            = "C:\Software\Espressif\frameworks\esp-idf-v5.4.1"
$env:IDF_TOOLS_PATH      = "C:\Software\Espressif"
$env:IDF_PYTHON_ENV_PATH = "C:\Software\Espressif\python_env\idf5.4_py3.11_env"
$env:ESP_ROM_ELF_DIR     = "C:\Software\Espressif\tools\esp-rom-elfs\20241011\"
Remove-Item Env:MSYSTEM -ErrorAction SilentlyContinue
Remove-Item Env:IDF_TARGET -ErrorAction SilentlyContinue   # IDE 扩展残留的旧目标会覆盖 sdkconfig
$env:PATH = "C:\Software\Espressif\python_env\idf5.4_py3.11_env\Scripts;" +
            "C:\Software\Espressif\tools\cmake\3.30.2\bin;" +
            "C:\Software\Espressif\tools\ninja\1.12.1;" +
            "C:\Software\Espressif\tools\xtensa-esp-elf\esp-14.2.0_20241119\xtensa-esp-elf\bin;" +
            "C:\Software\Git\cmd;$env:PATH"

# --- must run inside the project dir (CMakeLists.txt lives here) ---
Set-Location "D:\Demo\C4JianLouYi\C4F7N_Wireless\esp32"
Write-Host ">> project: $PWD  port: $Port" -ForegroundColor Cyan

# --- sanity checks before long build ---
if (-not (Test-Path "CMakeLists.txt")) { Write-Host "FAIL: not in esp32 dir" -ForegroundColor Red; exit 1 }
if (-not (Get-ChildItem "C:\Software\Espressif\frameworks\esp-idf-v5.4.1\tools\idf.py")) { Write-Host "FAIL: IDF missing" -ForegroundColor Red; exit 1 }

# --- flash + monitor ---
& python "$env:IDF_PATH\tools\idf.py" -p $Port flash monitor
