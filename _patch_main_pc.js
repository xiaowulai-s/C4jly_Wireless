// _patch_main_pc.js - fix main.rs lifetime/async issues
const fs = require('fs');
const f = 'D:/Demo/C4JianLouYi/C4F7N_Wireless/pc/src-tauri/src/main.rs';
let s = fs.readFileSync(f, 'utf8');
const before = s;

s = s.replace('mod ble;\nmod ledger;\nmod protocol;', 'mod ble;\nmod protocol;');

s = s.replace(
`#[tauri::command]
fn ble_is_connected(state: State<AppState>) -> bool {
    // sync quick check; sessions behind async mutex -> just report cached flag
    state.session.blocking_lock().is_connected()
}`,
`#[tauri::command]
async fn ble_is_connected(state: State<'_, AppState>) -> bool {
    state.session.lock().await.is_connected()
}`);

s = s.replace('fn spawn_poller(app: AppHandle, state: State<AppState>) {', 'fn spawn_poller(app: AppHandle) {');
s = s.replace('spawn_poller(app.clone(), state.clone());', 'spawn_poller(app.clone());');
s = s.replace(
`    tauri::async_runtime::spawn(async move {
        let mut last_hb = tokio::time::Instant::now();`,
`    let state = app.state::<AppState>();
    tauri::async_runtime::spawn(async move {
        let mut last_hb = tokio::time::Instant::now();`);

s = s.replace('fn ledger_add(\n    state: State<AppState>,', 'fn ledger_add(\n    state: State<\'_, AppState>,');
s = s.replace('fn ledger_list(state: State<AppState>, sn: Option<String>)', 'fn ledger_list(state: State<\'_, AppState>, sn: Option<String>)');

if (s === before) { console.error('no change applied'); process.exit(1); }
fs.writeFileSync(f, s);
console.log('main.rs patched');
