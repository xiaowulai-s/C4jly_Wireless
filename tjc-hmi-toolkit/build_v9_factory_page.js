'use strict';
// build_v9_factory_page.js —— 在 C4F7N_v9.HMI 里新增「厂家设置」页(资源槽 7.pa / 页ID=5)
//
// 做法:
//   1) 从 4.pa(主页) 克隆页对象 + p0/p0t/dvr/lg + 三组胶囊(含底图与圆点) + 时间镜像 11 个 -> 改名为 *_f
//   2) 从 5.pa(设置) 克隆标定区 8 个对象(czl/csl/cfl/c0/c1/cf/cst_s1/crs_s1) -> 前 6 个保持同名, 后 2 个改名 cst_f/crs_f
//   3) 设置页额外搬设备信息 3 个(itt/fw/sn)并改名 _f
//   4) 新增「返回设置」按钮 bk(跳 page 2)
//   5) 从 5.pa 删除 8 个标定对象 + 给 fw 加长按 5 秒跳 page 5 的脚本
//
// 铁律: 读入编码 = 写出编码; 改前断言 parse->build 字节级往返一致; 改后重parse 做结构化断言。
var fs = require('fs');
var path = require('path');
var P = require('./lib/page.js');

var WORK = 'D:/Demo/C4jly/tjc-hmi-toolkit/work_v9/';
var gbk = new TextDecoder('gbk');
function dec(s) { try { return gbk.decode(Buffer.from(String(s), 'latin1')); } catch (e) { return String(s); } }
function gbkRaw(str) { var b = Buffer.from(str, 'latin1'); return Buffer.from(b.toString('latin1'), 'latin1'); }
// GBK 编码 -> 写入 attr 用的 latin1 串
var iconv = null;
try { iconv = require('iconv-lite'); } catch (e) { console.error('!! 缺 iconv-lite'); process.exit(1); }
function G(str) { return iconv.encode(str, 'gbk').toString('latin1'); }

// ---------- 通用 ----------
function findAttr(o, k) { return o.items.find(function (i) { return i.kind === 'attr' && i.key === k; }); }
function objName(o) { var a = findAttr(o, 'objname'); return a ? dec(String(a.value).replace(/\0+$/, '')) : ''; }
function setStr(o, k, val) { var a = findAttr(o, k); if (!a) throw new Error('no attr ' + k); var raw = Buffer.from(iconv.encode(val, 'gbk')); a.raw = raw; a.value = raw.toString('latin1'); }
function cloneObj(o, renames) {
  var items = [];
  o.items.forEach(function (it) {
    if (it.kind === 'end') items.push({ kind: 'end' });
    else if (it.kind === 'mark') items.push({ kind: 'mark', text: it.text });
    else items.push({ kind: 'attr', key: it.key, raw: Buffer.from(it.raw), value: it.value });
  });
  var c = { items: items, len: o.len };
  if (renames) setStr(c, 'objname', renames);
  return c;
}
function findObj(p, name) { var r = null; p.objs.forEach(function (o) { if (objName(o) === name) r = o; }); return r; }
function roundtripOK(p) { var a = P.build(p.name, p.objs.slice(), p.head); var p2 = P.parse(a); var b = P.build(p2.name, p2.objs.slice(), p2.head); return b.equals(a); }

// ---------- 读基线 ----------
var home = P.parse(fs.readFileSync(WORK + '4.pa'));   // 主页
var sett = P.parse(fs.readFileSync(WORK + '5.pa'));   // 设置
console.log('基线 4.pa objs=' + home.objs.length + '  5.pa objs=' + sett.objs.length);
if (!roundtripOK(home)) throw new Error('4.pa 往返失败');
if (!roundtripOK(sett)) throw new Error('5.pa 往返失败');
console.log('基线往返自检 OK');

// ---------- 1) 组装新页 ----------
var HEAD_FROM_HOME = [
  // [源对象名, 新名或 null 表示同名]
  ['主页', '厂家设置'],           // 页对象(type121) 改名
  ['p0', 'p0'], ['p0t', 'p0t'], ['dvr', 'dvr'], ['lg', 'lg'],
  ['pc0b', 'pc0b_f'], ['pc0', 'pc0_f'], ['pc0d', 'pc0d_f'],
  ['pc1b', 'pc1b_f'], ['pc1', 'pc1_f'], ['pc1d', 'pc1d_f'],
  ['pc2b', 'pc2b_f'], ['pc2', 'pc2_f'], ['pc2d', 'pc2d_f'],
  ['rY', 'rY_f'], ['sY1', 'sY1_f'], ['rM', 'rM_f'], ['sY2', 'sY2_f'],
  ['rD', 'rD_f'], ['sSp', 'sSp_f'], ['rH', 'rH_f'], ['sCl', 'sCl_f'],
  ['rMi', 'rMi_f'], ['sCl2', 'sCl2_f'], ['rsec', 'rsec_f'],
];
var CAL_FROM_SETT = [
  ['itt', 'itt_f'], ['sn', 'sn_f'], ['fw', 'fw_f'],
  ['czl', 'czl_f'], ['csl', 'csl_f'], ['cfl', 'cfl_f'],
  ['c0', 'c0'], ['c1', 'c1'], ['cf', 'cf'],              // 三个按钮保持同名(报文零改动)
  ['cst_s1', 'cst_f'], ['crs_s1', 'crs_f'],
];

var newObjs = [];
HEAD_FROM_HOME.forEach(function (pair) {
  var src = findObj(home, pair[0]);
  if (!src) throw new Error('主页缺对象 ' + pair[0]);
  newObjs.push(cloneObj(src, pair[1] !== pair[0] ? pair[1] : null));
});
CAL_FROM_SETT.forEach(function (pair) {
  var src = findObj(sett, pair[0]);
  if (!src) throw new Error('设置页缺对象 ' + pair[0]);
  newObjs.push(cloneObj(src, pair[1] !== pair[0] ? pair[1] : null));
});

// 编号: 新页对象 id 依次 0..N（与其他页一致：主页页对象 id=0）
newObjs.forEach(function (o, i) {
  var a = findAttr(o, 'id');
  if (a) {
    var nw = Buffer.alloc(a.raw.length);
    if (nw.length === 1) nw.writeUInt8(i & 255, 0);
    else if (nw.length === 2) nw.writeUInt16LE(i & 0xffff, 0);
    else nw.writeUInt32LE(i >>> 0, 0);
    a.raw = nw; a.value = i;
  }
});

// 「返回设置」按钮: 复制设置页的 cf(type98) 换名字与坐标, 脚本改为 page 2
var cfSrc = findObj(sett, 'cf');
var bk = cloneObj(cfSrc, 'bk');
setStr(bk, 'txt', '返回设置');
(function () {
  var a = findAttr(bk, 'x'); var nw = Buffer.alloc(a.raw.length); nw.writeUInt16LE(700, 0); a.raw = nw; a.value = 700;
  var b = findAttr(bk, 'y'); var nw2 = Buffer.alloc(b.raw.length); nw2.writeUInt16LE(110, 0); b.raw = nw2; b.value = 110;
  var c = findAttr(bk, 'w'); var nw3 = Buffer.alloc(c.raw.length); nw3.writeUInt16LE(140, 0); c.raw = nw3; c.value = 140;
  var d = findAttr(bk, 'txt_maxl'); var nw4 = Buffer.alloc(d.raw.length); nw4.writeUInt16LE(20, 0); d.raw = nw4; d.value = 20;
})();
// 清掉 cf 的脚本(cfs/cft 两段确认 + printh), 换成无条件 page 2
// ★ codesXX-N 的 N 是该事件下的脚本行数, 必须与实际行数一致, 否则事件不执行。
(function () {
  var kept = bk.items.filter(function (it) { return it.kind !== 'mark'; });
  // codesdown-0 = 空(按下不响应), codesup-1 = page 2
  ['codesdown-0', 'codesup-1', 'page 2'].forEach(function (L) {
    if (Buffer.byteLength(L, 'latin1') >= 16) throw new Error('脚本行超 16B: ' + L);
    kept.push({ kind: 'mark', text: L });
  });
  bk.items = kept;
})();
newObjs.push(bk);

var newPage = { name: G('厂家设置'), objs: newObjs, head: home.head };
if (!roundtripOK(newPage)) throw new Error('新页往返失败');
console.log('新页往返 OK, objs=' + newObjs.length);

fs.writeFileSync(WORK + '7.pa', P.build(newPage.name, newPage.objs, newPage.head));
console.log('WROTE 7.pa  bytes=' + fs.statSync(WORK + '7.pa').size);

// ---------- 2) 设置页: 删 8 个标定对象 + fw 加长按 ----------
var DEL = ['czl', 'csl', 'cfl', 'c0', 'c1', 'cf', 'cst_s1', 'crs_s1'];
var before = sett.objs.length;
sett.objs = sett.objs.filter(function (o) { return DEL.indexOf(objName(o)) < 0; });
console.log('设置页删除 ' + DEL.length + ' 个对象: ' + before + ' -> ' + sett.objs.length);
DEL.forEach(function (n) { if (findObj(sett, n)) throw new Error('删除失败 ' + n); });

// fw 加长按脚本 —— 官方标准做法: 定时器到期即触发, 不读计数值
// (wiki:「使用按钮实现长按功能 需配合定时器使用」tm0.en=1 / tm0.en=0 / 定时事件里 tm0.en=0 + page)
// ★ 所有脚本行必须 <16 字节, 否则会被 lib/page.js 的 L>=16 启发式误判为 attr(见 skill 铁律)
var fw = findObj(sett, 'fw');
if (!fw) throw new Error('设置页缺 fw');
(function () {
  var cleaned = fw.items.filter(function (it) {
    if (it.kind !== 'mark') return true;
    var t = String(it.text);
    return !/^codes(down|up)-/.test(t);   // 丢掉旧脚本声明
  });
  [
    'codesdown-1', 'tmr1.en=1',
    'codesup-1', 'tmr1.en=0'
  ].forEach(function (L) {
    if (Buffer.byteLength(L, 'latin1') >= 16) throw new Error('脚本行超 16B: ' + L);
    cleaned.push({ kind: 'mark', text: L });
  });
  fw.items = cleaned;
})();

// 设置页新增长按专用定时器 tmr1 (tim=5000ms, en=0)
// ★ 必须清空克隆来的 tm0 定时事件(rY.val=rtc0 等时钟刷新) —— 那是主页 tm0 的职责,
//   重复执行既无意义又会让 codesTimer-N 的声明行数对不上。
var tmSrc = findObj(sett, 'tm0');
if (!tmSrc) throw new Error('设置页缺 tm0');
var tmr1 = cloneObj(tmSrc, 'tmr1');
(function () {
  var a = findAttr(tmr1, 'tim'); var n = Buffer.alloc(a.raw.length); n.writeUInt16LE(5000, 0); a.raw = n; a.value = 5000;
  var b = findAttr(tmr1, 'en');  var n2 = Buffer.alloc(b.raw.length); n2.writeUInt8(0, 0); b.raw = n2; b.value = 0;
  // 删掉所有旧脚本 mark, 换成两条
  var kept = tmr1.items.filter(function (it) { return it.kind !== 'mark'; });
  ['codesTimer-2', 'tmr1.en=0', 'page 5'].forEach(function (L) {
    if (Buffer.byteLength(L, 'latin1') >= 16) throw new Error('脚本行超 16B: ' + L);
    kept.push({ kind: 'mark', text: L });
  });
  tmr1.items = kept;
})();
// 编号: 追加到末尾
(function () {
  var maxId = 0;
  sett.objs.forEach(function (o) { var a = findAttr(o, 'id'); if (a) maxId = Math.max(maxId, a.value | 0); });
  var a = findAttr(tmr1, 'id');
  if (a) { var n = Buffer.alloc(a.raw.length); if (n.length === 1) n.writeUInt8((maxId + 1) & 255, 0); else n.writeUInt16LE((maxId + 1) & 0xffff, 0); a.raw = n; a.value = maxId + 1; }
})();
sett.objs.push(tmr1);
console.log('设置页新增定时器 tmr1 (tim=5000 en=0)');

if (!roundtripOK(sett)) throw new Error('设置页改后往返失败');
console.log('设置页往返 OK');
fs.writeFileSync(WORK + '5.pa', P.build(sett.name, sett.objs, sett.head));
console.log('WROTE 5.pa  bytes=' + fs.statSync(WORK + '5.pa').size);

// ---------- 4) 声明行数自检(codesXX-N 的 N 必须等于该事件下的实际行数) ----------
// 不加这道检查, 声明数对不上时屏端【静默不执行该事件】, 现象是"按钮点了没反应"。
function checkCodes(p, tag) {
  var bad = [];
  p.objs.forEach(function (o) {
    var seen = {};     // eventKey -> 已声明的行数
    var cnt = {};      // eventKey -> 实际行数
    var cur = null;
    o.items.forEach(function (it) {
      if (it.kind !== 'mark') return;
      var t = String(it.text);
      var m = /^codes([A-Za-z]+)-(\d+)$/.exec(t);
      if (m) { cur = m[1]; seen[cur] = parseInt(m[2], 10); cnt[cur] = 0; return; }
      if (cur) cnt[cur]++;
    });
    Object.keys(seen).forEach(function (k) {
      if (seen[k] !== cnt[k]) bad.push(tag + '/' + (objName(o) || '(page)') + ' codes' + k + '-N=' + seen[k] + ' 实际=' + cnt[k]);
    });
  });
  return bad;
}
var bad7 = checkCodes(newPage, '7.pa');
var bad5 = checkCodes(sett, '5.pa');
// 只报我改过的对象(clone 来的 c0/c1/cf 若本来就对不上, 报出来也不改)
console.log('声明行数自检 7.pa: ' + (bad7.length ? bad7.join(' | ') : 'OK'));
console.log('声明行数自检 5.pa: ' + (bad5.length ? bad5.join(' | ') : 'OK'));

// ---------- 5) main.HMI: 资源表末尾追加 7.pa ----------
// ★ 注意: 条目格式是 [8B ext][8B name]（已用 0x2e69='.i' 等逐条验证）
// ★ main.HMI 原长 96+48*16=864 恰好用满, 加一条必须扩容 16B（hmipack 会重定位后续块）
var mh = fs.readFileSync(WORK + 'main.HMI');
var cnt = mh.readUInt32LE(28);
var need = 96 + (cnt + 1) * 16;
console.log('main.HMI 资源数=' + cnt + ' size=' + mh.length + ' 需扩到=' + need);
if (96 + cnt * 16 > mh.length) throw new Error('资源表声明数与文件长度不符');

var slot = 96 + cnt * 16;
if (need > mh.length) {
  var grown = Buffer.alloc(need);
  mh.copy(grown, 0);
  mh = grown;
}
var ent = Buffer.alloc(16);
Buffer.from('pa\0\0\0\0\0\0', 'latin1').copy(ent, 0);      // ext
Buffer.from('7.pa\0\0\0\0', 'latin1').copy(ent, 8);        // name
mh.writeUInt32LE(cnt + 1, 28);
ent.copy(mh, slot);
fs.writeFileSync(WORK + 'main.HMI', mh);

// 复核: 页ID 表
var pa = 0, mh2 = fs.readFileSync(WORK + 'main.HMI');
var c2 = mh2.readUInt32LE(28);
for (var i = 0; i < c2; i++) {
  var o = 96 + i * 16;
  var ext = mh2.subarray(o, o + 8).toString('latin1').replace(/\0.*$/, '');
  var nm = mh2.subarray(o + 8, o + 16).toString('latin1').replace(/\0.*$/, '');
  if (ext === 'pa') { console.log('  页ID=' + pa + '  <- ' + ext + nm); pa++; }
}
console.log('main.HMI: cnt=' + cnt + ' -> ' + (cnt + 1) + ' size=' + mh2.length + '  => 共 ' + pa + ' 页, 新页页ID=' + (pa - 1));