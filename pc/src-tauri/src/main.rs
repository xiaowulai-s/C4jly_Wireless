//! C4F7N 产测工具 (PC factory tester) — Tauri 2 backend.
//!
//! Layers: protocol.rs (codec, frozen vectors) -> ble.rs (transport) ->
//! commands below (Tauri API) -> ui/ (vanilla JS frontend).
//! Ledger: local SQLite (prodtest records per SN).

#![cfg_attr(not(debug_assertions), windows_subsystem = "windows")]

mod ble;
mod protocol;

use std::sync::Arc;
use std::time::Duration;

use ble::{BleSession, LinkEvent};
use serde_json::json;
use tauri::{AppHandle, Emitter, Manager, State};
use tokio::sync::Mutex;

pub struct AppState {
    pub session: Arc<Mutex<BleSession>>,
    pub ledger: std::sync::Mutex<rusqlite::Connection>,
    pub poller_running: std::sync::Mutex<bool>,
}

/* ---------------- scan / connect ---------------- */

#[tauri::command]
async fn ble_scan() -> Result<Vec<ble::ScanHit>, String> {
    ble::scan(Duration::from_secs(8)).await
}

#[tauri::command]
async fn ble_connect(
    state: State<'_, AppState>,
    app: AppHandle,
    id: String,
    name: String,
) -> Result<(), String> {
    {
        let mut s = state.session.lock().await;
        s.connect(&id).await?;
    }
    let _ = app.emit("link", json!({"up": true, "name": name}));
    spawn_poller(app.clone());
    Ok(())
}

#[tauri::command]
async fn ble_diag() -> Result<serde_json::Value, String> {
    Ok(ble::diag().await)
}

#[tauri::command]
async fn ble_disconnect(state: State<'_, AppState>, app: AppHandle) -> Result<(), String> {
    state.session.lock().await.disconnect().await;
    let _ = app.emit("link", json!({"up": false}));
    Ok(())
}

#[tauri::command]
async fn ble_is_connected(state: State<'_, AppState>) -> Result<bool, String> {
    Ok(state.session.lock().await.is_connected())
}

/* ---------------- poller: notifications + heartbeat ---------------- */

fn spawn_poller(app: AppHandle) {
    // guard: only one poller at a time (checked inside the task)
    let app = app.clone();
    tauri::async_runtime::spawn(async move {
        let mut last_hb = tokio::time::Instant::now();
        loop {
            tokio::time::sleep(Duration::from_millis(120)).await;
            let events = {
                let state = app.state::<AppState>();
                let mut s = state.session.lock().await;
                if !s.is_connected() {
                    let _ = app.emit("link", json!({"up": false}));
                    break;
                }
                // 5s heartbeat keeps the 15s device-side watchdog happy
                if last_hb.elapsed() > Duration::from_secs(5) {
                    last_hb = tokio::time::Instant::now();
                    if let Ok(f) = protocol::build_frame(protocol::cmd::HEARTBEAT, &[]) {
                        let _ = s.send_raw(&f).await;
                    }
                }
                s.pump()
            };
            for ev in events {
                match ev {
                    LinkEvent::Sample(s) => {
                        let _ = app.emit("sample", serde_json::to_value(s).unwrap_or_default());
                    }
                    LinkEvent::Response(_) | LinkEvent::Up => {}
                    LinkEvent::Down => {
                        let _ = app.emit("link", json!({"up": false}));
                    }
                }
            }
        }
        let st = app.state::<AppState>();
        let mut p = st.poller_running.lock().unwrap();
        *p = false;
    });
}

/* ---------------- request-response commands ---------------- */

async fn request_ack(
    state: &State<'_, AppState>,
    frame: Result<Vec<u8>, String>,
    cmd: u8,
) -> Result<(), String> {
    let f = frame?;
    let mut s = state.session.lock().await;
    let pf = s.request(&f, cmd).await?;
    match ack_code(&pf) {
        Ok(_) => Ok(()),
        Err(code) => Err(format!("NACK 0x{code:02X}")),
    }
}

fn ack_code(pf: &protocol::ParsedFrame) -> Result<(), u8> {
    if pf.payload.is_empty() {
        return Ok(());
    }
    let c = pf.payload[0];
    if c == protocol::err::OK || c == 1 {
        Ok(())
    } else {
        Err(c)
    }
}

fn rd32le(p: &[u8], o: usize) -> u32 {
    if p.len() < o + 4 {
        return 0;
    }
    (p[o] as u32) | ((p[o + 1] as u32) << 8) | ((p[o + 2] as u32) << 16) | ((p[o + 3] as u32) << 24)
}

#[tauri::command]
async fn cmd_pump(state: State<'_, AppState>, on: bool) -> Result<bool, String> {
    let f = protocol::pump(on)?;
    let mut s = state.session.lock().await;
    let pf = s.request(&f, protocol::cmd::PUMP).await?;
    Ok(pf.payload.first().copied().unwrap_or(0) == 1)
}

#[tauri::command]
async fn cmd_mute(state: State<'_, AppState>, mute: bool) -> Result<bool, String> {
    let f = protocol::mute(mute)?;
    let mut s = state.session.lock().await;
    let pf = s.request(&f, protocol::cmd::MUTE).await?;
    Ok(pf.payload.first().copied().unwrap_or(0) == 1)
}

#[tauri::command]
async fn cmd_read_threshold(state: State<'_, AppState>) -> Result<f32, String> {
    let f = protocol::param_read(0x0001)?;
    let mut s = state.session.lock().await;
    let pf = s.request(&f, protocol::cmd::PARAM_READ).await?;
    if pf.payload.len() >= 6 {
        Ok(rd32le(&pf.payload, 2) as f32 / 10.0)
    } else {
        Err("bad threshold response".into())
    }
}

#[tauri::command]
async fn cmd_write_threshold(state: State<'_, AppState>, ppm_x10: u32) -> Result<(), String> {
    request_ack(&state, protocol::param_write(0x0001, ppm_x10), protocol::cmd::PARAM_WRITE)
        .await
}

#[tauri::command]
async fn cmd_zero_cal_prepare(state: State<'_, AppState>) -> Result<serde_json::Value, String> {
    let f = protocol::zero_cal_step(1)?;
    let mut s = state.session.lock().await;
    let pf = s.request(&f, protocol::cmd::ZERO_CAL).await?;
    let rd16 = |o: usize| -> u16 {
        (pf.payload.get(o).copied().unwrap_or(0) as u16)
            | ((pf.payload.get(o + 1).copied().unwrap_or(0) as u16) << 8)
    };
    Ok(json!({ "conc_ppm": rd16(0) as f32 / 10.0, "stable": rd16(2) == 1 }))
}

#[tauri::command]
async fn cmd_zero_cal_confirm(state: State<'_, AppState>) -> Result<bool, String> {
    let f = protocol::zero_cal_step(2)?;
    let mut s = state.session.lock().await;
    let pf = s.request(&f, protocol::cmd::ZERO_CAL).await?;
    Ok(pf.payload.first().copied().unwrap_or(0) == 1)
}

#[tauri::command]
async fn cmd_factory_cal(
    state: State<'_, AppState>,
    op: u8,
    confirm: bool,
    value: f32,
) -> Result<u8, String> {
    let f = protocol::factory_cal(op, confirm, value)?;
    let mut s = state.session.lock().await;
    let pf = s.request(&f, protocol::cmd::FACTORY_CAL).await?;
    Ok(pf.payload.first().copied().unwrap_or(0))
}

#[tauri::command]
async fn cmd_selftest(state: State<'_, AppState>) -> Result<serde_json::Value, String> {
    let f = protocol::build_frame(protocol::cmd::SELFTEST, &[])?;
    let mut s = state.session.lock().await;
    let pf = s.request(&f, protocol::cmd::SELFTEST).await?;
    let bits = rd32le(&pf.payload, 0);
    Ok(json!({ "bits": bits, "all_ok": bits & 0x3F == 0x3F }))
}

#[tauri::command]
async fn cmd_factory_reset(state: State<'_, AppState>) -> Result<(), String> {
    request_ack(
        &state,
        protocol::factory_cal(0x05, true, 0.0),
        protocol::cmd::FACTORY_CAL,
    )
    .await
}

/* ---------------- factory session / SN / auth hash ---------------- */

#[tauri::command]
async fn cmd_factory_auth(state: State<'_, AppState>, password: String) -> Result<bool, String> {
    let f = protocol::factory_auth(&password)?;
    let mut s = state.session.lock().await;
    let pf = s.request(&f, protocol::cmd::FACTORY_AUTH).await?;
    Ok(pf.payload.first().copied().unwrap_or(0) == 1)
}

#[tauri::command]
async fn cmd_sn_read(state: State<'_, AppState>) -> Result<String, String> {
    let f = protocol::sn_read()?;
    let mut s = state.session.lock().await;
    let pf = s.request(&f, protocol::cmd::MAINT).await?;
    if pf.payload.len() >= 2 && pf.payload[0] == protocol::mop::SN_READ {
        Ok(String::from_utf8_lossy(&pf.payload[1..]).trim().to_string())
    } else {
        Err("bad SN response".into())
    }
}

#[tauri::command]
async fn cmd_sn_write(state: State<'_, AppState>, sn: String) -> Result<(), String> {
    request_ack(&state, protocol::sn_write(&sn), protocol::cmd::MAINT).await
}

#[tauri::command]
async fn cmd_auth_hash_set(state: State<'_, AppState>, password: String) -> Result<(), String> {
    request_ack(
        &state,
        protocol::auth_hash_set(&password),
        protocol::cmd::MAINT,
    )
    .await
}

/* ---------------- ledger (SQLite) ---------------- */

#[tauri::command]
fn ledger_add(
    state: State<'_, AppState>,
    sn: String,
    steps: String,
    verdict: String,
    note: String,
) -> Result<i64, String> {
    let conn = state.ledger.lock().unwrap();
    conn.execute(
        "INSERT INTO prodtest(sn, ts, steps, verdict, note) VALUES(?1, ?2, ?3, ?4, ?5)",
        rusqlite::params![
            sn,
            chrono_now_secs(),
            steps,
            verdict,
            note
        ],
    )
    .map(|n| n as i64)
    .map_err(|e| e.to_string())
}

#[tauri::command]
fn ledger_list(state: State<'_, AppState>, sn: Option<String>) -> Result<Vec<serde_json::Value>, String> {
    let conn = state.ledger.lock().unwrap();
    let mut stmt = conn
        .prepare("SELECT id, sn, ts, steps, verdict, note FROM prodtest ORDER BY id DESC LIMIT 500")
        .map_err(|e| e.to_string())?;
    let rows = stmt
        .query_map([], |r| {
            Ok(json!({
                "id": r.get::<_, i64>(0)?,
                "sn": r.get::<_, String>(1)?,
                "ts": r.get::<_, i64>(2)?,
                "steps": r.get::<_, String>(3)?,
                "verdict": r.get::<_, String>(4)?,
                "note": r.get::<_, String>(5)?,
            }))
        })
        .map_err(|e| e.to_string())?;
    let mut out = Vec::new();
    for r in rows {
        let v = r.map_err(|e| e.to_string())?;
        if let Some(want) = &sn {
            if v["sn"].as_str() != Some(want.as_str()) {
                continue;
            }
        }
        out.push(v);
    }
    Ok(out)
}

fn chrono_now_secs() -> i64 {
    std::time::SystemTime::now()
        .duration_since(std::time::UNIX_EPOCH)
        .map(|d| d.as_secs() as i64)
        .unwrap_or(0)
}

fn main() {
    let ledger = rusqlite::Connection::open(ledger_path()).expect("open ledger db");
    ledger
        .execute(
            "CREATE TABLE IF NOT EXISTS prodtest(
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                sn TEXT NOT NULL,
                ts INTEGER NOT NULL,
                steps TEXT NOT NULL,
                verdict TEXT NOT NULL,
                note TEXT NOT NULL DEFAULT ''
            )",
            [],
        )
        .expect("create table");

    tauri::Builder::default()
        .manage(AppState {
            session: Arc::new(Mutex::new(BleSession::new())),
            ledger: std::sync::Mutex::new(ledger),
            poller_running: std::sync::Mutex::new(false),
        })
        .invoke_handler(tauri::generate_handler![
            ble_scan,
            ble_diag,
            ble_connect,
            ble_disconnect,
            ble_is_connected,
            cmd_pump,
            cmd_mute,
            cmd_read_threshold,
            cmd_write_threshold,
            cmd_zero_cal_prepare,
            cmd_zero_cal_confirm,
            cmd_factory_cal,
            cmd_selftest,
            cmd_factory_reset,
            cmd_factory_auth,
            cmd_sn_read,
            cmd_sn_write,
            cmd_auth_hash_set,
            ledger_add,
            ledger_list
        ])
        .run(tauri::generate_context!())
        .expect("error running tauri app");
}

fn ledger_path() -> std::path::PathBuf {
    let mut dir = std::env::var("APPDATA")
        .map(std::path::PathBuf::from)
        .unwrap_or_else(|_| std::path::PathBuf::from("."));
    dir.push("C4F7N");
    let _ = std::fs::create_dir_all(&dir);
    dir.join("prodtest.db")
}
