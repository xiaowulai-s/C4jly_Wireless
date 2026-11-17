'use strict';
// _ac_check.js —— 本地语法/编译校验（armclang 单文件 -c）
//
// ★ 为什么有这个：本机 UV4.exe 被系统禁止执行（Permission denied，Node spawn /
//   Bash / PS / 沙箱内外全失败），此前每次改固件都要麻烦用户在 Keil GUI 里 Rebuild。
//   但 armclang.exe 【可以直接调用】—— 用它做单文件编译即可在本地发现问题。
//
// 用法: node _ac_check.js [文件...]        不给文件则查全部 v62 改动文件
var cp = require('child_process');
var fs = require('fs');
var path = require('path');

var AC = 'D:/KEIL/ARM/ARMCLANG/Bin/armclang.exe';
var MDK = 'D:/Demo/C4jly/C4F7N_Demo/MDK-ARM';
var INC = [
  '-I../Core/Inc', '-I../Drivers/STM32F1xx_HAL_Driver/Inc',
  '-I../Drivers/STM32F1xx_HAL_Driver/Inc/Legacy',
  '-I../Drivers/CMSIS/Device/ST/STM32F1xx/Include',
  '-I../Drivers/CMSIS/Include', '-I../Middleware/Inc', '-I../Middleware/Src',
  '-I../BSP/Inc', '-I../BSP/Src', '-I./C4F7N_Demo'
].join(' ');
var BASE = '--target=arm-arm-none-eabi -mcpu=cortex-m3 -c -D__MICROLIB -DUSE_HAL_DRIVER -DSTM32F103xE';

var DEFAULT = [
  '../BSP/Src/sensor.c', '../BSP/Inc/sensor.h', '../Core/Src/main.c',
  '../Middleware/Src/tjc_cmd.c', '../Middleware/Src/hmi_callback.c',
  '../BSP/Src/battery.c', '../Middleware/Inc/tjc_cmd.h',
  '../Middleware/Inc/c4f7n_hmi_protocol.h', '../Middleware/Inc/hmi_callback.h'
];
var files = process.argv.slice(2);
if (!files.length) files = DEFAULT;

if (!fs.existsSync(AC)) { console.error('★ 找不到 armclang: ' + AC); process.exit(1); }

var bad = 0;
files.forEach(function (f) {
  var r = cp.spawnSync('"' + AC + '" ' + BASE + ' ' + INC + ' -o ' + path.join(require('os').tmpdir(), '_acchk.o') + ' "' + f + '"',
    { cwd: MDK, encoding: 'utf8', shell: true, timeout: 60000 });
  var out = ((r.stdout || '') + (r.stderr || '')).trim();
  var name = f.split(/[\\/]/).pop();
  if (!out) {
    console.log('  [OK]   ' + name);
  } else {
    bad++;
    console.log('  [FAIL] ' + name);
    out.split('\n').slice(0, 6).forEach(function (l) { console.log('         ' + l.trim()); });
  }
});

console.log(bad ? '\n✗ ' + bad + ' 个文件编译失败' : '\n✓ 全部 ' + files.length + ' 个文件编译通过');
process.exit(bad ? 1 : 0);