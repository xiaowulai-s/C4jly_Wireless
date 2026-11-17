//! BLE transport (btleplug) + frame routing to the frontend.
//!
//! Windows: notification MTU is managed by the OS stack (usually 247+);
//! we just write without response and subscribe to the notify char.
//! Notifications are drained by a spawned task into a channel; `pump()`
//! (called from the Tauri polling loop) drains it without blocking.

use std::collections::HashMap;
use std::str::FromStr;
use std::time::Duration;

use btleplug::api::{
    BDAddr, Central, Characteristic, CharPropFlags, Manager as _, Peripheral as _, ScanFilter,
    WriteType,
};
use btleplug::platform::{Adapter, Manager, Peripheral, PeripheralId};
use serde_json::json;
use futures::StreamExt;
use tokio::sync::mpsc;
use uuid::Uuid;

use crate::protocol::{self, FrameReader, ParsedFrame};

pub const SERVICE_UUID: Uuid = Uuid::from_u128(0x48B5C976_CAE8_4BA4_9D6C_F560D9958777);
pub const WRITE_UUID: Uuid = Uuid::from_u128(0x48B5C976_CAE8_4BA5_9D6C_F560D9958777);
pub const NOTIFY_UUID: Uuid = Uuid::from_u128(0x48B5C976_CAE8_4BA6_9D6C_F560D9958777);

#[derive(Clone, serde::Serialize)]
pub struct ScanHit {
    pub id: String,
    pub name: String,
    pub rssi: i16,
}

#[derive(Clone, serde::Serialize)]
pub struct RealtimeSample {
    pub conc_ppm: f32,
    pub temp_c: f32,
    pub peak_ppm: f32,
    pub battery: u8,
    pub state: u8,
    pub thr_ppm: f32,
    pub uptime_s: u32,
}

pub enum LinkEvent {
    Up,
    Down,
    Sample(RealtimeSample),
    Response(ParsedFrame),
}

type NotifRx = mpsc::Receiver<Vec<u8>>;

/// Windows WinRT keeps a per-adapter device cache: a freshly created
/// Adapter knows nothing about devices found by another instance.
/// So scan() and connect() MUST share one long-lived Adapter.
static ADAPTER: tokio::sync::OnceCell<Adapter> = tokio::sync::OnceCell::const_new();

async fn shared_adapter() -> Result<&'static Adapter, String> {
    ADAPTER
        .get_or_try_init(|| async {
            let manager = Manager::new().await.map_err(|e| format!("ble manager: {e}"))?;
            let adapters = manager
                .adapters()
                .await
                .map_err(|e| format!("ble adapters: {e}"))?;
            adapters.first().cloned().ok_or_else(|| {
                "no BLE adapter found on this PC (蓝牙未开启?)".to_string()
            })
        })
        .await
}

pub struct BleSession {
    peripheral: Option<Peripheral>,
    write_char: Option<Characteristic>,
    notif_rx: Option<NotifRx>,
    reader: FrameReader,
    pending: HashMap<u8, mpsc::Sender<ParsedFrame>>,
}

pub async fn scan(timeout: Duration) -> Result<Vec<ScanHit>, String> {
    let adapter = shared_adapter().await?;
    adapter
        .start_scan(ScanFilter::default())
        .await
        .map_err(|e| format!("scan start: {e}"))?;
    tokio::time::sleep(timeout).await;
    let _ = adapter.stop_scan().await;

    let mut hits = Vec::new();
    for p in adapter.peripherals().await.unwrap_or_default() {
        if let Ok(true) = p.is_connected().await {
            continue;
        }
        let Ok(Some(props)) = p.properties().await else { continue };
        let name = props.local_name.clone().unwrap_or_default();
        if name.starts_with("C4F7N-") {
            hits.push(ScanHit {
                id: p.id().to_string(),
                name,
                rssi: props.rssi.unwrap_or(0),
            });
        }
    }
    hits.sort_by(|a, b| b.rssi.cmp(&a.rssi));
    Ok(hits)
}

/// diagnostics for the connection card: adapter count + cache size
pub async fn diag() -> serde_json::Value {
    let mut out = serde_json::Map::new();
    match Manager::new().await {
        Err(e) => {
            out.insert("error".into(), json!(format!("manager: {e}")));
        }
        Ok(m) => match m.adapters().await {
            Err(e) => {
                out.insert("error".into(), json!(format!("adapters: {e}")));
            }
            Ok(list) => {
                out.insert("adapters".into(), json!(list.len()));
                if shared_adapter().await.is_ok() {
                    let n = shared_adapter()
                        .await
                        .unwrap()
                        .peripherals()
                        .await
                        .map(|v| v.len())
                        .unwrap_or(0);
                    out.insert("adapter_cache_devices".into(), json!(n));
                } else {
                    out.insert("adapter_cache_devices".into(), json!("init failed"));
                }
            }
        },
    }
    serde_json::Value::Object(out)
}

impl BleSession {
    pub fn new() -> Self {
        Self {
            peripheral: None,
            write_char: None,
            notif_rx: None,
            reader: FrameReader::default(),
            pending: HashMap::new(),
        }
    }

    pub async fn connect(&mut self, id: &str) -> Result<(), String> {
        let adapter = shared_adapter().await?;
        let pid = PeripheralId::from(
            BDAddr::from_str(id).map_err(|e| format!("bad device id: {e}"))?);
        // lookup with one short re-scan retry (adapter cache may have lost
        // the device if the app restarted between scan and connect)
        let p = match adapter.peripheral(&pid).await {
            Ok(p) => p,
            Err(_) => {
                let _ = adapter.start_scan(ScanFilter::default()).await;
                tokio::time::sleep(Duration::from_secs(3)).await;
                let _ = adapter.stop_scan().await;
                adapter
                    .peripheral(&pid)
                    .await
                    .map_err(|_| {
                        "peripheral lookup: 未找到设备（请先在①里扫描一次再点连接）".to_string()
                    })?
            }
        };
        // resilient connect:
        //  - if Windows already holds a GATT session (stale from an earlier
        //    attempt), reuse it instead of failing with Unreachable
        //  - otherwise retry 3x; on NotConnected force-disconnect first to
        //    release any stale OS-level session, then trust is_connected
        let mut ok = matches!(p.is_connected().await, Ok(true));
        let mut last_err = String::new();
        if !ok {
            for _ in 0..3 {
                match p.connect().await {
                    Ok(()) => {
                        ok = true;
                        break;
                    }
                    Err(e) => {
                        if matches!(p.is_connected().await, Ok(true)) {
                            ok = true;
                            break;
                        }
                        last_err = e.to_string();
                        let _ = p.disconnect().await; // force-release stale session
                        tokio::time::sleep(Duration::from_millis(1200)).await;
                    }
                }
            }
        }
        if !ok {
            return Err(format!(
                "connect: {last_err}（已尝试强制释放陈旧会话；请重启 ESP32 并把电脑蓝牙开关拨一次后重试）"
            ));
        }
        tokio::time::sleep(Duration::from_millis(800)).await; // let GATT settle
        // service discovery with retries: weak RSSI often yields
        // GattCommunicationStatus::Unreachable on the first try
        let mut derr = String::new();
        let mut disc_ok = false;
        for _ in 0..3 {
            match p.discover_services().await {
                Ok(()) => {
                    disc_ok = true;
                    break;
                }
                Err(e) => {
                    derr = e.to_string();
                    tokio::time::sleep(Duration::from_secs(1)).await;
                }
            }
        }
        if !disc_ok {
            // release the OS-level session or the device stops advertising
            let _ = p.disconnect().await;
            return Err(format!(
                "discover: {derr}（连接已建立但服务发现失败；信号弱时易发生，请把设备移近电脑再试）"
            ));
        }

        let mut wc: Option<Characteristic> = None;
        let mut nc: Option<Characteristic> = None;
        for svc in p.services() {
            if svc.uuid != SERVICE_UUID {
                continue;
            }
            for c in &svc.characteristics {
                if c.uuid == WRITE_UUID {
                    wc = Some(c.clone());
                } else if c.uuid == NOTIFY_UUID {
                    nc = Some(c.clone());
                }
            }
        }
        let wc = wc.ok_or("protocol v1 GATT service not found")?;
        let nc = nc.ok_or("protocol v1 GATT service not found")?;
        if !nc.properties.contains(CharPropFlags::NOTIFY) {
            return Err("notify char missing NOTIFY flag".into());
        }
        p.subscribe(&nc).await.map_err(|e| format!("subscribe: {e}"))?;
        let mut stream = p.notifications().await.map_err(|e| format!("notif: {e}"))?;
        let (tx, rx) = mpsc::channel::<Vec<u8>>(64);
        tokio::spawn(async move {
            while let Some(d) = stream.next().await {
                if tx.send(d.value).await.is_err() {
                    break;
                }
            }
        });

        self.peripheral = Some(p);
        self.write_char = Some(wc);
        self.notif_rx = Some(rx);
        self.reader = FrameReader::default();
        self.pending.clear();
        Ok(())
    }

    pub async fn disconnect(&mut self) {
        if let Some(p) = &self.peripheral {
            let _ = p.disconnect().await;
        }
        self.peripheral = None;
        self.write_char = None;
        self.notif_rx = None;
        self.pending.clear();
    }

    pub fn is_connected(&self) -> bool {
        self.peripheral.is_some()
    }

    pub async fn send_raw(&mut self, frame: &[u8]) -> Result<(), String> {
        let p = self.peripheral.as_ref().ok_or("not connected")?;
        let c = self.write_char.as_ref().ok_or("not connected")?;
        p.write(c, frame, WriteType::WithoutResponse)
            .await
            .map_err(|e| format!("write: {e}"))
    }

    /// request-response with 2s timeout and one retry (spec §4.2)
    pub async fn request(&mut self, frame: &[u8], cmd: u8) -> Result<ParsedFrame, String> {
        for _ in 0..2 {
            let (tx, mut rx) = mpsc::channel(1);
            self.pending.insert(cmd, tx);
            self.send_raw(frame).await?;
            match tokio::time::timeout(Duration::from_secs(2), rx.recv()).await {
                Ok(Some(pf)) => return Ok(pf),
                _ => {
                    self.pending.remove(&cmd);
                }
            }
        }
        Err("device not responding (no ACK within 2s)".into())
    }

    /// non-blocking drain of notification bytes -> routed LinkEvents
    pub fn pump(&mut self) -> Vec<LinkEvent> {
        let mut events = Vec::new();
        let rx = match self.notif_rx.as_mut() {
            Some(r) => r,
            None => return events,
        };
        let mut frames = Vec::new();
        while let Ok(bytes) = rx.try_recv() {
            frames.extend(self.reader.feed(&bytes));
        }
        for pf in frames {
            events.push(self.route(pf));
        }
        events
    }

    fn route(&mut self, pf: ParsedFrame) -> LinkEvent {
        match pf.cmd {
            protocol::cmd::REALTIME => LinkEvent::Sample(parse_realtime(&pf.payload)),
            c => {
                if let Some(tx) = self.pending.remove(&c) {
                    let _ = tx.try_send(pf.clone());
                }
                LinkEvent::Response(pf)
            }
        }
    }
}

pub fn parse_realtime(p: &[u8]) -> RealtimeSample {
    let rd16 = |o: usize| -> u16 {
        (p.get(o).copied().unwrap_or(0) as u16)
            | ((p.get(o + 1).copied().unwrap_or(0) as u16) << 8)
    };
    let rd32 = |o: usize| -> u32 {
        p.get(o..o + 4)
            .map(|s| {
                (s[0] as u32)
                    | ((s[1] as u32) << 8)
                    | ((s[2] as u32) << 16)
                    | ((s[3] as u32) << 24)
            })
            .unwrap_or(0)
    };
    RealtimeSample {
        conc_ppm: rd16(0) as f32 / 10.0,
        temp_c: rd16(2) as f32 / 10.0,
        peak_ppm: rd16(4) as f32 / 10.0,
        battery: p.get(6).copied().unwrap_or(0),
        state: p.get(7).copied().unwrap_or(0),
        thr_ppm: rd16(8) as f32 / 10.0,
        uptime_s: rd32(10),
    }
}
