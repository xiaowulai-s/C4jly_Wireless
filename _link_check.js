// v62 全量编译 + 链接校验(不依赖 UV4)
// 范围严格限定为 C4F7N_Demo.uvprojx 里 <FilePath> 列出的源文件 —— 驱动目录里
// 有一批 *_template.c 是 HAL 示例, 工程并不编译, 扫进去会假报错。
var fs = require('fs');
var path = require('path');
var cp = require('child_process');
var MDK = 'D:/Demo/C4jly/C4F7N_Demo/MDK-ARM';
var CC = 'D:/KEIL/ARM/ARMCLANG/Bin/armclang.exe';
var INC = [
  '-I../Core/Inc',
  '-I../Drivers/STM32F1xx_HAL_Driver/Inc',
  '-I../Drivers/STM32F1xx_HAL_Driver/Inc/Legacy',
  '-I../Drivers/CMSIS/Device/ST/STM32F1xx/Include',
  '-I../Drivers/CMSIS/Include',
  '-I../Middleware/Inc', '-I../Middleware/Src',
  '-I../BSP/Inc', '-I../BSP/Src',
  '-I./C4F7N_Demo'
].join(' ');
var BASE = ['--target=arm-arm-none-eabi', '-mcpu=cortex-m3', '-D__MICROLIB', '-DUSE_HAL_DRIVER', '-DSTM32F103xE'];

function sh(cmd) {
  try { return cp.execSync(cmd, { cwd: MDK, encoding: 'latin1', stdio: ['ignore', 'pipe', 'pipe'] }); }
  catch (e) { return (e.stdout || '') + (e.stderr || ''); }
}

var x = fs.readFileSync(path.join(MDK, 'C4F7N_Demo.uvprojx'), 'utf8');
var all = (x.match(/<FilePath>([^<]+)<\/FilePath>/g) || []).map(function (s) {
  return s.replace(/<\/?FilePath>/g, '').replace(/\\/g, '/');
});
// ★ 只编 C 源文件 —— 工程里还有 startup_stm32f103xe.s(汇编), 交给 armasm, 不走 armclang
var srcs = all.filter(function (f) { return /\.c$/i.test(f); });
var asms = all.filter(function (f) { return !/\.c$/i.test(f); });
console.log('工程声明: ' + all.length + ' 项  → C 源 ' + srcs.length + ' 个, 汇编 ' + asms.length + ' 个(' + asms.join(', ') + ')\n');

var OBJDIR = path.join(MDK, '_v62link');
fs.rmSync(OBJDIR, { recursive: true, force: true });
fs.mkdirSync(OBJDIR, { recursive: true });

var objs = [], errCnt = 0, warnCnt = 0;
srcs.forEach(function (f) {
  var n = path.basename(f).replace(/\.c$/, '');
  var o = '_v62link/' + n + '.o';
  var out = sh('"' + CC + '" ' + BASE.join(' ') + ' -c ' + INC + ' -o ' + o + ' ' + f + ' 2>&1');
  var errs = (out.match(/error:/g) || []).length;
  var warns = (out.match(/warning:/g) || []).length;
  errCnt += errs; warnCnt += warns;
  if (errs) {
    console.log('  [FAIL] ' + n + '  ' + errs + ' error');
    out.split('\n').filter(function (l) { return /error:/.test(l); }).slice(0, 3).forEach(function (l) {
      console.log('         ' + l.trim().slice(0, 110));
    });
  } else {
    if (warns) console.log('  [ ok ] ' + n + '  (' + warns + ' warning)');
  }
  if (fs.existsSync(path.join(MDK, o))) objs.push(o);
});

console.log('\n编译: ' + objs.length + '/' + srcs.length + ' 产出 .o   error ' + errCnt + '   warning ' + warnCnt);
if (errCnt) { console.log('\n★ 有编译错误, 终止'); process.exit(1); }

// 链接(不带 startup 与库, 只验证符号自洽)
var linkOut = sh('"' + CC + '" ' + BASE.join(' ') + ' ' + objs.join(' ') + ' -o _v62link/out.axf 2>&1');
var lerr = (linkOut.match(/error:/g) || []).length;
var undef = (linkOut.match(/undefined symbol/g) || []).length;
console.log('链接: ' + (lerr ? '★ ' + lerr + ' error' : '通过') + '   undefined symbol: ' + undef);
if (lerr || undef) {
  linkOut.split('\n').forEach(function (l) { if (l.trim()) console.log('  | ' + l.trim().slice(0, 150)); });
  process.exit(1);
}
console.log('\n✓ 编译与链接均通过');
