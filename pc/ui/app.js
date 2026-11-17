/* C4F7N 产测工具 frontend (Tauri v2 invoke/event API, withGlobalTauri) */
const { invoke } = window.__TAURI__.core;
const { listen } = window.__TAURI__.event;

const $ = (id) => document.getElementById(id);
const log = (el, msg, cls = '') => {
  const t = new Date().toTimeString().slice(0, 8);
  const line = document.createElement('span');
  line.className = cls;
  line.textContent = `[${t}] ${msg}\n`;
  $(el).appendChild(line);
  $(el).scrollTop = $(el).scrollHeight;
};
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

/* ---------- link state ---------- */
let authed = false;
let sessionSn = null;
function connected() {
  return $('link-badge').className.includes('on');
}

listen('link', (e) => {
  const up = e.payload.up;
  const b = $('link-badge');
  b.textContent = up ? `已连接 ${e.payload.name || ''}` : '未连接';
  b.className = 'badge ' + (up ? 'on' : 'off');
  if (!up) {
    authed = false;
    updateFacEnabled();
    log('conn-log', '链路断开', 'err');
  }
  $('flow-btn').disabled = !up;
});
listen('sample', (e) => {
  const s = e.payload;
  $('conc').textContent = s.conc_ppm.toFixed(1);
  $('peak').textContent = s.peak_ppm.toFixed(1);
  $('bat').textContent = s.battery;
  $('pump').textContent = s.state & 1 ? '运行' : '停止';
  const alarming = (s.state & 2) !== 0 && !(s.state & 4);
  $('alarm').textContent = alarming ? '报警' : '正常';
  $('alarm').style.color = alarming ? '#c62828' : '#0f6e56';
});

/* ---------- diagnostics ---------- */
$('diag-btn').onclick = async () => {
  try {
    const d = await invoke('ble_diag');
    log('conn-log', '诊断: ' + JSON.stringify(d));
  } catch (err) {
    log('conn-log', '诊断失败: ' + err, 'err');
  }
};

/* ---------- scan / connect ---------- */
$('scan-btn').onclick = async () => {
  const btn = $('scan-btn');
  btn.disabled = true;
  btn.textContent = '扫描中（约 8 秒）…';
  $('scan-status').textContent = '';
  $('scan-list').innerHTML = '';
  log('conn-log', '扫描开始（8 秒）…');
  try {
    const hits = await invoke('ble_scan');
    log('conn-log', `扫描完成：找到 ${hits.length} 台`);
    hits.forEach((h) =>
      log('conn-log', `  · ${h.name} rssi=${h.rssi} id=${h.id}`));
    $('scan-status').textContent = `找到 ${hits.length} 台设备`;
    for (const h of hits) {
      const li = document.createElement('li');
      li.innerHTML = `<b>${h.name}</b><span>${h.rssi} dBm</span>`;
      const btn2 = document.createElement('button');
      btn2.textContent = '连接';
      btn2.onclick = async () => {
        btn2.disabled = true;
        btn2.textContent = '连接中…';
        log('conn-log', `开始连接 ${h.name} (id=${h.id})`);
        $('scan-status').textContent =
          '连接中…（手机 App 需先断开：设备只接受 1 个连接）';
        try {
          await invoke('ble_connect', { id: h.id, name: h.name });
          log('conn-log', '✅ 连接成功', 'ok');
          $('scan-status').textContent = '✅ 已连接 ' + h.name;
        } catch (err) {
          $('scan-status').textContent = '';
          log('conn-log', '连接失败：' + err, 'err');
          alert('连接失败：' + err + '\n\n常见原因：① 手机 App 还连着（先断开）② 设备未上电');
          btn2.disabled = false;
          btn2.textContent = '连接';
        }
      };
      li.appendChild(btn2);
      $('scan-list').appendChild(li);
    }
    if (hits.length === 0) {
      $('scan-status').textContent =
        '没找到设备：确认 ESP32 已上电、手机 App 已断开、电脑蓝牙已开启';
      log('conn-log', '没找到任何 C4F7N 设备', 'err');
    }
  } catch (err) {
    $('scan-status').textContent = '';
    log('conn-log', '扫描失败：' + err, 'err');
    alert('扫描失败：' + err + '\n\n排查：电脑蓝牙是否已开启？');
  }
  btn.disabled = false;
  btn.textContent = '扫描附近设备';
};

/* ---------- live controls ---------- */
$('pump-btn').onclick = async () => {
  try {
    const on = await invoke('cmd_pump', { on: true });
    log('fac-log', '泵开启 ' + (on ? '成功' : '失败'), on ? 'ok' : 'err');
    const off = await invoke('cmd_pump', { on: false });
    log('fac-log', '泵关闭 ' + (off ? '成功' : '失败'), off ? 'ok' : 'err');
  } catch (err) { log('fac-log', '泵控制失败：' + err, 'err'); }
};
$('mute-btn').onclick = async () => {
  try {
    await invoke('cmd_mute', { mute: true });
    log('fac-log', '静音下发成功', 'ok');
  } catch (err) { log('fac-log', '静音失败：' + err, 'err'); }
};

/* ---------- factory session ---------- */
function updateFacEnabled() {
  document.querySelectorAll('.fac').forEach((b) => (b.disabled = !(connected() && authed)));
  $('authhash-btn').disabled = !(connected() && authed && sessionSn);
}
$('auth-btn').onclick = async () => {
  try {
    authed = await invoke('cmd_factory_auth', { password: $('pwd').value });
    $('auth-status').textContent = authed ? '✅ 厂家会话已开启' : '❌ 认证失败';
    updateFacEnabled();
  } catch (err) {
    $('auth-status').textContent = '❌ ' + err;
  }
};
const facBtns = document.querySelectorAll('.fac');
facBtns[0].onclick = async () => {
  try {
    const r = await invoke('cmd_zero_cal_prepare');
    log('fac-log', `零点读数 ${r.conc_ppm.toFixed(1)} ppm，稳定=${r.stable}`);
    if (!r.stable) { log('fac-log', '读数不稳定，中止', 'err'); return; }
    const ok = await invoke('cmd_zero_cal_confirm');
    log('fac-log', '零点校准 ' + (ok ? '完成' : '失败'), ok ? 'ok' : 'err');
  } catch (err) { log('fac-log', '零点校准异常：' + err, 'err'); }
};
facBtns[1].onclick = async () => {
  try {
    const r = await invoke('cmd_selftest');
    log('fac-log', `自检 bits=0x${r.bits.toString(16)} 全部正常=${r.all_ok}`, r.all_ok ? 'ok' : 'err');
  } catch (err) { log('fac-log', '自检异常：' + err, 'err'); }
};
facBtns[2].onclick = async () => {
  if (!confirm('确认恢复出厂参数？')) return;
  try {
    await invoke('cmd_factory_reset');
    log('fac-log', '已恢复出厂', 'ok');
  } catch (err) { log('fac-log', '恢复出厂失败：' + err, 'err'); }
};

/* ---------- one-key prodtest flow ---------- */
$('sn-read-btn').onclick = async () => {
  try {
    sessionSn = await invoke('cmd_sn_read');
    $('sn').value = sessionSn;
    log('flow-log', '当前 SN: ' + sessionSn, 'ok');
    updateFacEnabled();
  } catch (err) { log('flow-log', '读 SN 失败：' + err, 'err'); }
};

async function step(name, fn) {
  const li = document.createElement('li');
  li.textContent = name + ' …';
  $('flow-steps').appendChild(li);
  try {
    await fn();
    li.textContent = `✓ ${name}`;
    li.className = 'pass';
    return true;
  } catch (err) {
    li.textContent = `✗ ${name} — ${err}`;
    li.className = 'fail';
    log('flow-log', `步骤失败：${name} — ${err}`, 'err');
    return false;
  }
}

$('flow-btn').onclick = async () => {
  const sn = $('sn').value.trim();
  if (!sn) { alert('请先读取或填写 SN'); return; }
  $('flow-steps').innerHTML = '';
  const results = [];
  let verdict = 'PASS';

  const r1 = await step('自检', async () => {
    const r = await invoke('cmd_selftest');
    if (!r.all_ok) throw new Error('bits=0x' + r.bits.toString(16));
    results.push('自检:OK');
  });
  if (!r1) verdict = 'FAIL';

  const r2 = await step('零点校准（两步）', async () => {
    const p = await invoke('cmd_zero_cal_prepare');
    if (!p.stable) throw new Error(`读数 ${p.conc_ppm.toFixed(1)} ppm 不稳定`);
    if (p.conc_ppm > 50) throw new Error(`读数 ${p.conc_ppm.toFixed(1)} ppm 超出零点上限`);
    const ok = await invoke('cmd_zero_cal_confirm');
    if (!ok) throw new Error('设备拒绝');
    results.push('零点校准:OK');
  });
  if (!r2) verdict = 'FAIL';

  const r3 = await step('阈值写入 50 ppm', async () => {
    await invoke('cmd_write_threshold', { ppmX10: 500 });
    results.push('阈值:OK');
  });
  if (!r3) verdict = 'FAIL';

  const r4 = await step('泵控制往返', async () => {
    const on = await invoke('cmd_pump', { on: true });
    if (!on) throw new Error('开泵无回显');
    await sleep(300);
    const off = await invoke('cmd_pump', { on: false });
    if (off) throw new Error('关泵无回显');
    results.push('泵控制:OK');
  });
  if (!r4) verdict = 'FAIL';

  const r5 = await step('静音下发', async () => {
    await invoke('cmd_mute', { mute: true });
    results.push('静音:OK');
  });
  if (!r5) verdict = 'FAIL';

  log('flow-log', `产测完成：${verdict}（${results.length}/5 项通过）`, verdict === 'PASS' ? 'ok' : 'err');

  try {
    await invoke('ledger_add', {
      sn, steps: results.join('; '), verdict, note: '',
    });
    log('flow-log', '产测记录已入库', 'ok');
  } catch (err) {
    log('flow-log', '入库失败：' + err, 'err');
  }
};

/* ---------- SN write / auth hash ---------- */
$('authhash-btn').onclick = async () => {
  const pwd = $('pwd').value;
  if (!pwd) { alert('先填写厂家口令'); return; }
  if (!confirm(`将 SHA-256("${pwd}") 烧入设备？此后认证必须使用该口令。`)) return;
  try {
    await invoke('cmd_auth_hash_set', { password: pwd });
    log('flow-log', '认证哈希已烧写（SN 同页重写保留）', 'ok');
  } catch (err) { log('flow-log', '烧写失败：' + err, 'err'); }
};

$('ledger-btn').onclick = async () => {
  try {
    const rows = await invoke('ledger_list', { sn: null });
    log('flow-log', `产测记录 ${rows.length} 条（最新 3 条）:`);
    rows.slice(0, 3).forEach((r) =>
      log('flow-log', `  #${r.id} ${r.sn} ${r.verdict} ${new Date(r.ts * 1000).toISOString().slice(0, 19)}`));
  } catch (err) { log('flow-log', '查询失败：' + err, 'err'); }
};

/* startup self-check: script actually running? */
window.addEventListener('DOMContentLoaded', () => {
  if (!window.__TAURI__) {
    document.body.innerHTML =
      '<pre style="padding:20px;color:#c62828">致命错误：Tauri API 未注入（__TAURI__ 缺失）。请使用重新构建的安装包。</pre>';
  }
});
