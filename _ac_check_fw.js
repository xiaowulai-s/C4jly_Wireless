'use strict';
// _ac_check_fw.js - armclang single-file check for the wireless fw fork
// (same flags as ../_ac_check.js but cwd points at C4F7N_Wireless/fw/MDK-ARM)
var cp = require('child_process');
var fs = require('fs');
var path = require('path');

var AC = 'C:/Software/KeilC51/ARM/ARMCLANG/bin/armclang.exe';
var MDK = 'D:/Demo/C4JianLouYi/C4F7N_Wireless/fw/MDK-ARM';
var INC = [
  '-I../Core/Inc', '-I../Drivers/STM32F1xx_HAL_Driver/Inc',
  '-I../Drivers/STM32F1xx_HAL_Driver/Inc/Legacy',
  '-I../Drivers/CMSIS/Device/ST/STM32F1xx/Include',
  '-I../Drivers/CMSIS/Include', '-I../Middleware/Inc', '-I../Middleware/Src',
  '-I../BSP/Inc', '-I../BSP/Src', '-I./C4F7N_Demo'
].join(' ');
var BASE = '--target=arm-arm-none-eabi -mcpu=cortex-m3 -c -D__MICROLIB -DUSE_HAL_DRIVER -DSTM32F103xE';

var files = process.argv.slice(2);
if (!files.length) {
  files = ['../Middleware/Src/wireless.c', '../Middleware/Inc/wireless.h', '../Core/Src/main.c'];
}
if (!fs.existsSync(AC)) { console.error('armclang not found: ' + AC); process.exit(1); }

var bad = 0;
files.forEach(function (f) {
  var r = cp.spawnSync('"' + AC + '" ' + BASE + ' ' + INC + ' -o ' +
    path.join(require('os').tmpdir(), '_acchk_fw.o') + ' "' + f + '"',
    { cwd: MDK, encoding: 'utf8', shell: true, timeout: 60000 });
  var out = ((r.stdout || '') + (r.stderr || '')).trim();
  var name = f.split(/[\\/]/).pop();
  if (r.status === 0 && !out) {
    console.log('PASS ' + name);
  } else {
    bad++;
    console.log('FAIL ' + name + ' (status=' + r.status + ')');
    if (out) console.log(out);
  }
});
process.exit(bad ? 1 : 0);
