//! C4F7N protocol v1.1 frame codec (Rust port of packages/c4f7n_protocol).
//! Test vectors frozen from the Dart implementation (spec docs/协议v1.md §7).

pub const HEAD: [u8; 2] = [0xA5, 0x5A];

pub mod cmd {
    pub const MAINT: u8 = 0x00;
    pub const HEARTBEAT: u8 = 0x01;
    pub const REALTIME: u8 = 0x10;
    pub const PARAM_READ: u8 = 0x11;
    pub const PARAM_WRITE: u8 = 0x12;
    pub const PUMP: u8 = 0x20;
    pub const MUTE: u8 = 0x21;
    pub const ZERO_CAL: u8 = 0x30;
    pub const FACTORY_CAL: u8 = 0x31;
    pub const HISTORY_READ: u8 = 0x40;
    pub const HISTORY_DELETE: u8 = 0x41;
    pub const SELFTEST: u8 = 0x50;
    pub const EVENT: u8 = 0x60;
    pub const FACTORY_AUTH: u8 = 0x7A;
}

pub mod mop {
    pub const SN_READ: u8 = 0x01;
    pub const SN_WRITE: u8 = 0x02;
    pub const AUTH_HASH: u8 = 0x03;
}

pub mod err {
    pub const OK: u8 = 0x01;
    pub const CRC: u8 = 0x01;
    pub const UNKNOWN: u8 = 0x02;
    pub const NO_PERM: u8 = 0x03;
    pub const RANGE: u8 = 0x04;
    pub const BUSY: u8 = 0x05;
    pub const STORAGE: u8 = 0x06;
    pub const BAD_LEN: u8 = 0x07;
    pub const NEED_CONFIRM: u8 = 0x81;
}

pub const PROTO_VERSION: u32 = 0x0000_0100;

/// CRC-16/MODBUS (poly 0xA001, init 0xFFFF)
pub fn crc16(data: &[u8]) -> u16 {
    let mut c: u16 = 0xFFFF;
    for &b in data {
        c ^= b as u16;
        for _ in 0..8 {
            c = if c & 1 != 0 { (c >> 1) ^ 0xA001 } else { c >> 1 };
        }
    }
    c
}

/// LEN = cmd + payload; total = LEN + 5. payload max 239.
pub fn build_frame(cmd: u8, payload: &[u8]) -> Result<Vec<u8>, String> {
    if payload.len() > 239 {
        return Err(format!("payload too long: {}", payload.len()));
    }
    let mut out = Vec::with_capacity(payload.len() + 7);
    out.extend_from_slice(&HEAD);
    out.push((payload.len() + 1) as u8);
    out.push(cmd);
    out.extend_from_slice(payload);
    let crc = crc16(&out[3..]);
    out.push((crc & 0xFF) as u8);
    out.push((crc >> 8) as u8);
    Ok(out)
}

#[derive(Debug, Clone, PartialEq)]
pub struct ParsedFrame {
    pub cmd: u8,
    pub payload: Vec<u8>,
}

/// Frame-aware reader over a byte stream: buffers, resyncs on header,
/// emits exactly one complete frame per call when available.
#[derive(Default)]
pub struct FrameReader {
    buf: Vec<u8>,
}

impl FrameReader {
    pub fn feed(&mut self, bytes: &[u8]) -> Vec<ParsedFrame> {
        self.buf.extend_from_slice(bytes);
        let mut out = Vec::new();
        loop {
            // resync to header
            let mut skip = 0usize;
            while skip + 1 < self.buf.len()
                && !(self.buf[skip] == HEAD[0] && self.buf[skip + 1] == HEAD[1])
            {
                skip += 1;
            }
            if skip > 0 {
                self.buf.drain(0..skip);
            }
            if self.buf.len() < 3 {
                break;
            }
            let len = self.buf[2] as usize;
            let total = len + 5;
            if self.buf.len() < total {
                break;
            }
            let body: Vec<u8> = self.buf[4..total - 2].to_vec(); // excludes cmd
            let crc = (self.buf[total - 2] as u16) | ((self.buf[total - 1] as u16) << 8);
            let calc = crc16(&self.buf[3..total - 2]); // over cmd + payload
            let cmd = self.buf[3];
            self.buf.drain(0..total);
            if crc != calc {
                continue; // drop bad-CRC frame
            }
            out.push(ParsedFrame {
                cmd,
                payload: body,
            });
        }
        if self.buf.len() > 245 {
            self.buf.clear(); // paranoia
        }
        out
    }
}

/* ---------------- typed helpers ---------------- */

pub fn param_read(id: u16) -> Result<Vec<u8>, String> {
    build_frame(cmd::PARAM_READ, &[(id & 0xFF) as u8, (id >> 8) as u8])
}

pub fn param_write(id: u16, v: u32) -> Result<Vec<u8>, String> {
    let mut p = [(id & 0xFF) as u8, (id >> 8) as u8, 0, 0, 0, 0];
    p[2] = (v & 0xFF) as u8;
    p[3] = ((v >> 8) & 0xFF) as u8;
    p[4] = ((v >> 16) & 0xFF) as u8;
    p[5] = ((v >> 24) & 0xFF) as u8;
    build_frame(cmd::PARAM_WRITE, &p)
}

pub fn pump(on: bool) -> Result<Vec<u8>, String> {
    build_frame(cmd::PUMP, &[if on { 1 } else { 0 }])
}

pub fn mute(m: bool) -> Result<Vec<u8>, String> {
    build_frame(cmd::MUTE, &[if m { 1 } else { 0 }])
}

pub fn zero_cal_step(step: u8) -> Result<Vec<u8>, String> {
    build_frame(cmd::ZERO_CAL, &[step])
}

pub fn factory_cal(op: u8, confirm: bool, value: f32) -> Result<Vec<u8>, String> {
    let mut p = [op, if confirm { 1 } else { 0 }, 0, 0, 0, 0];
    p[2..6].copy_from_slice(&value.to_le_bytes());
    build_frame(cmd::FACTORY_CAL, &p)
}

pub fn sn_read() -> Result<Vec<u8>, String> {
    build_frame(cmd::MAINT, &[mop::SN_READ])
}

pub fn sn_write(sn: &str) -> Result<Vec<u8>, String> {
    if sn.is_empty() || sn.len() > 24 {
        return Err("SN must be 1..24 chars".into());
    }
    let mut p = vec![mop::SN_WRITE];
    p.extend_from_slice(sn.as_bytes());
    build_frame(cmd::MAINT, &p)
}

pub fn auth_hash_set(password: &str) -> Result<Vec<u8>, String> {
    let mut p = vec![mop::AUTH_HASH];
    p.extend_from_slice(&sha256(password));
    build_frame(cmd::MAINT, &p)
}

pub fn factory_auth(password: &str) -> Result<Vec<u8>, String> {
    build_frame(cmd::FACTORY_AUTH, &sha256(password))
}

/// Minimal SHA-256 (FIPS 180-4), used for the factory auth digest.
pub fn sha256(msg: &str) -> [u8; 32] {
    const K: [u32; 64] = [
        0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1, 0x923f82a4,
        0xab1c5ed5, 0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3, 0x72be5d74, 0x80deb1fe,
        0x9bdc06a7, 0xc19bf174, 0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc, 0x2de92c6f,
        0x4a7484aa, 0x5cb0a9dc, 0x76f988da, 0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7,
        0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967, 0x27b70a85, 0x2e1b2138, 0x4d2c6dfc,
        0x53380d13, 0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85, 0xa2bfe8a1, 0xa81a664b,
        0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070, 0x19a4c116,
        0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
        0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208, 0x90befffa, 0xa4506ceb, 0xbef9a3f7,
        0xc67178f2,
    ];
    let mut msg = msg.as_bytes().to_vec();
    let bitlen = (msg.len() as u64) * 8;
    msg.push(0x80);
    while msg.len() % 64 != 56 {
        msg.push(0);
    }
    msg.extend_from_slice(&bitlen.to_be_bytes());

    let mut h: [u32; 8] = [
        0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a, 0x510e527f, 0x9b05688c, 0x1f83d9ab,
        0x5be0cd19,
    ];
    for chunk in msg.chunks(64) {
        let mut w = [0u32; 64];
        for i in 0..16 {
            w[i] = u32::from_be_bytes([
                chunk[i * 4],
                chunk[i * 4 + 1],
                chunk[i * 4 + 2],
                chunk[i * 4 + 3],
            ]);
        }
        for i in 16..64 {
            let s0 = w[i - 15].rotate_right(7) ^ w[i - 15].rotate_right(18) ^ (w[i - 15] >> 3);
            let s1 = w[i - 2].rotate_right(17) ^ w[i - 2].rotate_right(19) ^ (w[i - 2] >> 10);
            w[i] = w[i - 16]
                .wrapping_add(s0)
                .wrapping_add(w[i - 7])
                .wrapping_add(s1);
        }
        let (mut a, mut b, mut c, mut d, mut e, mut f, mut g, mut hh) =
            (h[0], h[1], h[2], h[3], h[4], h[5], h[6], h[7]);
        for i in 0..64 {
            let s1 = e.rotate_right(6) ^ e.rotate_right(11) ^ e.rotate_right(25);
            let ch = (e & f) ^ ((!e) & g);
            let t1 = hh
                .wrapping_add(s1)
                .wrapping_add(ch)
                .wrapping_add(K[i])
                .wrapping_add(w[i]);
            let s0 = a.rotate_right(2) ^ a.rotate_right(13) ^ a.rotate_right(22);
            let maj = (a & b) ^ (a & c) ^ (b & c);
            let t2 = s0.wrapping_add(maj);
            hh = g;
            g = f;
            f = e;
            e = d.wrapping_add(t1);
            d = c;
            c = b;
            b = a;
            a = t1.wrapping_add(t2);
        }
        h[0] = h[0].wrapping_add(a);
        h[1] = h[1].wrapping_add(b);
        h[2] = h[2].wrapping_add(c);
        h[3] = h[3].wrapping_add(d);
        h[4] = h[4].wrapping_add(e);
        h[5] = h[5].wrapping_add(f);
        h[6] = h[6].wrapping_add(g);
        h[7] = h[7].wrapping_add(hh);
    }
    let mut out = [0u8; 32];
    for i in 0..8 {
        out[i * 4..i * 4 + 4].copy_from_slice(&h[i].to_be_bytes());
    }
    out
}

/* ---------------- tests (frozen vectors) ---------------- */

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn crc_vector_123456789() {
        assert_eq!(crc16(b"123456789"), 0x4B37);
    }

    #[test]
    fn frame1_pump_on() {
        assert_eq!(
            build_frame(cmd::PUMP, &[1]).unwrap(),
            vec![0xA5, 0x5A, 0x02, 0x20, 0x01, 0xD9, 0xB0]
        );
    }

    #[test]
    fn frame2_threshold_read() {
        assert_eq!(
            param_read(0x0001).unwrap(),
            vec![0xA5, 0x5A, 0x03, 0x11, 0x01, 0x00, 0x20, 0x55]
        );
    }

    #[test]
    fn frame_reader_emits_one_frame_per_complete() {
        let mut r = FrameReader::default();
        let f1 = build_frame(cmd::PUMP, &[1]).unwrap();
        let f2 = param_read(0x0001).unwrap();
        let mut bytes = Vec::new();
        bytes.extend(&f1);
        bytes.extend(&[0x00, 0x13]); // garbage before next header
        bytes.extend(&f2);
        let frames = r.feed(&bytes);
        assert_eq!(frames.len(), 2);
        assert_eq!(frames[0].cmd, cmd::PUMP);
        assert_eq!(frames[1].cmd, cmd::PARAM_READ);
    }

    #[test]
    fn frame_reader_resync_on_crc_error() {
        let mut r = FrameReader::default();
        let mut f = build_frame(cmd::PUMP, &[1]).unwrap();
        f[5] ^= 0xFF; // corrupt CRC
        let f2 = param_read(0x0001).unwrap();
        let mut bytes = Vec::new();
        bytes.extend(&f);
        bytes.extend(&f2);
        let frames = r.feed(&bytes);
        assert_eq!(frames.len(), 1);
        assert_eq!(frames[0].cmd, cmd::PARAM_READ);
    }

    #[test]
    fn sha256_known_vector() {
        // SHA-256("abc")
        assert_eq!(
            hex(&sha256("abc")),
            "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad"
        );
    }

    #[test]
    fn auth_and_sn_frames_parse() {
        let (pf, _) = one(serde_frame(factory_auth("pw1").unwrap()));
        assert_eq!(pf.cmd, cmd::FACTORY_AUTH);
        assert_eq!(pf.payload.len(), 32);
        let (pf2, _) = one(serde_frame(sn_write("C4F7N-0001").unwrap()));
        assert_eq!(pf2.payload[0], mop::SN_WRITE);
        assert_eq!(String::from_utf8_lossy(&pf2.payload[1..]), "C4F7N-0001");
    }

    fn serde_frame(f: Vec<u8>) -> Vec<u8> {
        f
    }
    fn one(bytes: Vec<u8>) -> (ParsedFrame, ()) {
        let mut r = FrameReader::default();
        let frames = r.feed(&bytes);
        assert_eq!(frames.len(), 1);
        (frames.into_iter().next().unwrap(), ())
    }

    fn hex(b: &[u8]) -> String {
        b.iter().map(|x| format!("{:02x}", x)).collect()
    }
}
