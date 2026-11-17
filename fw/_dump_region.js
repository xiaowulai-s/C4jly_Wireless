'use strict';
// _dump_region.js —— 按 GBK 正确解码打印 main.c 指定行区间
var fs = require('fs');
var iconv = require('iconv-lite');
var file = process.argv[2];
var a = parseInt(process.argv[3], 10), b = parseInt(process.argv[4], 10);
var txt = iconv.decode(fs.readFileSync(file), 'gbk');
var lines = txt.split(/\r?\n/);
for (var i = a; i <= b && i <= lines.length; i++) {
  console.log(String(i).padStart(5) + '| ' + lines[i - 1]);
}
