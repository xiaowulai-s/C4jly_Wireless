/*
 * _patch_main_wireless.js - patch fw/Core/Src/main.c (GBK/LF) for wireless.c.
 *
 * Anchors MUST be unique; script aborts otherwise (patch discipline per
 * AGENTS.md: dynamic EOL detection + iconv-lite, no blind rewrite).
 */
const fs = require('fs');
const path = require('path');
const iconv = require(path.join('D:', 'Demo', 'C4JianLouYi', 'tjc-hmi-toolkit', 'node_modules', 'iconv-lite'));

const FILE = path.join('D:', 'Demo', 'C4JianLouYi', 'C4F7N_Wireless', 'fw', 'Core', 'Src', 'main.c');
const raw = fs.readFileSync(FILE);

/* detect EOL */
let crlf = 0, lf = 0;
for (let i = 0; i < raw.length; i++) {
  if (raw[i] === 13) crlf++;
  else if (raw[i] === 10 && raw[i - 1] !== 13) lf++;
}
const EOL = crlf > lf ? '\r\n' : '\n';
console.log('EOL:', EOL === '\r\n' ? 'CRLF' : 'LF', `(crlf=${crlf} lf-only=${lf})`);

const text = iconv.decode(raw, 'gbk');
if (text.includes('\uFFFD')) {
  console.error('ABORT: U+FFFD after GBK decode - file is not clean GBK');
  process.exit(1);
}

let out = text;
let patched = 0;

function insertAfter(anchor, insert, tag) {
  const n = out.split(anchor).length - 1;
  if (n !== 1) {
    console.error(`ABORT: anchor not unique (${n}): ${tag}`);
    process.exit(1);
  }
  if (out.includes(insert.trim().split(EOL)[0])) {
    console.log(`SKIP (already patched): ${tag}`);
    patched++;
    return;
  }
  out = out.replace(anchor, anchor + insert);
  patched++;
  console.log(`OK: ${tag}`);
}

/* 1. include */
insertAfter(
  `#include "device_id.h"`,
  EOL + `#include "wireless.h"`,
  'include wireless.h'
);

/* 2. wl_* hooks after hmi_on_buz_mute */
const HOOKS = [
  '',
  '/* ---- wireless bridge hooks (used by Middleware/wireless.c) ----',
  ' *    ASCII-only comments: these touch main.c statics, all logic stays here.',
  ' *    Zero-cal: sets g_cal_req; real result lands in cal_ts via the',
  ' *    existing cal machine (async). Span/factory flows reused as-is. ---- */',
  'uint16_t wl_get_thr(void) { return g_thr_hi; }',
  'void wl_set_thr(uint16_t v) { PP.thr_hi = v; thr_commit(); }',
  'uint8_t wl_get_state(void) {',
  '  uint8_t s = 0;',
  '  if (pump_get()) s |= 1u;',
  '  if (g_alarm >= 2) s |= 2u;',
  '  if (g_mute) s |= 4u;',
  '  return s;',
  '}',
  'void wl_set_mute(uint8_t m) { g_mute = m ? 1u : 0u; }',
  'uint8_t wl_get_mute(void) { return g_mute ? 1u : 0u; }',
  'float wl_get_ppm(void) { return g_ppm; }',
  'float wl_get_peak(void) { return g_peak; }',
  'void wl_req_zero_cal(void) { g_cal_req = CAL_REQ_ZERO; }',
  'void wl_req_span_cal(void) { g_cal_req = CAL_REQ_SPAN; }',
  'uint8_t wl_cal_busy(void) { return (g_cal0_owner != CAL_REQ_NONE) ? 1u : 0u; }',
  'void wl_set_man(int32_t b, int32_t k) {',
  '  PP.man_b = b; PP.man_k = k;',
  '  param_save(&g_param);',
  '  sensor_set_cal(man_eff_k(), man_eff_b());',
  '}',
  'void wl_factory_params(void) {',
  '  param_factory(&g_param, 1);',
  '  thr_commit();',
  '  sensor_set_cal(man_eff_k(), man_eff_b());',
  '  g_mute = 0;',
  '}',
  'uint8_t wl_get_bat(void) { return battery_get_disp_pct(); }',
  'uint32_t wl_get_uptime_s(void) { return HAL_GetTick() / 1000u; }',
].join(EOL);
insertAfter(
  `void hmi_on_buz_mute(void) { g_mute = !g_mute; }`,
  EOL + HOOKS,
  'wl_* hooks'
);

/* 3. init after USART3 init */
insertAfter(
  `  MX_USART3_UART_Init();    /* serial screen USART3 */`,
  EOL + `  Wireless_Init();          /* ESP32 bridge on USART2 (PA2/PA3) */`,
  'Wireless_Init() call'
);

/* 4. poll in main loop: anchor = "#endif" + iwdg_feed (unique pair) */
const LOOP_ANCHOR = `#endif` + EOL + `    iwdg_feed();`;
insertAfter(
  LOOP_ANCHOR,
  EOL + `    Wireless_Poll();       /* wireless frames + 1Hz report */`,
  'Wireless_Poll() call'
);

if (patched < 4) {
  console.error('ABORT: not all patches applied');
  process.exit(1);
}

const buf = iconv.encode(out, 'gbk');
/* verify round-trip has no mojibake */
const check = iconv.decode(buf, 'gbk');
if (check.includes('\uFFFD')) {
  console.error('ABORT: GBK round-trip produced U+FFFD');
  process.exit(1);
}
fs.writeFileSync(FILE, buf);
console.log('patched OK:', FILE, `(${buf.length} bytes)`);
