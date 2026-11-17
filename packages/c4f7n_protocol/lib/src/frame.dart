/// C4F7N Wireless Protocol v1.0 - frame codec (spec: docs/协议v1.md)
///
/// Frame: A5 5A | LEN | CMD | PAYLOAD | CRC_L CRC_H
/// CRC16-MODBUS over CMD+PAYLOAD, little-endian on wire.
library;

import 'dart:typed_data';

/// Protocol version (0x00000100 = v1.0)
const int protoVersion = 0x00000100;

/// BLE UUIDs (frozen 2026-11-14)
const String kServiceUuid = '48B5C976-CAE8-4BA4-9D6C-F560D9958777';
const String kCharWriteUuid = '48B5C976-CAE8-4BA5-9D6C-F560D9958777';
const String kCharNotifyUuid = '48B5C976-CAE8-4BA6-9D6C-F560D9958777';

/// Command bytes
class Cmd {
  static const int maint = 0x00; // v1.1 maintenance family (sub-op in payload[0])
  static const int heartbeat = 0x01;
  static const int realtime = 0x10;
  static const int paramRead = 0x11;
  static const int paramWrite = 0x12;
  static const int pump = 0x20;
  static const int mute = 0x21;
  static const int zeroCal = 0x30;
  static const int factoryCal = 0x31;
  static const int historyRead = 0x40;
  static const int historyDelete = 0x41;
  static const int selftest = 0x50;
  static const int event = 0x60;
  static const int factoryAuth = 0x7A;
}

/// v1.1 maintenance sub-ops (payload[0] of CMD 0x00)
class MaintOp {
  static const int snRead = 0x01;
  static const int snWrite = 0x02; // factory session required
  static const int authHashSet = 0x03; // factory session required
}

/// NACK error codes
class Err {
  static const int crc = 0x01;
  static const int unknownCmd = 0x02;
  static const int noPermission = 0x03;
  static const int valueRange = 0x04;
  static const int busy = 0x05;
  static const int storage = 0x06;
  static const int badLen = 0x07;
  static const int needConfirm = 0x81; // ACK semantic, 0x31 only
}

/// param_id table (aligned with param_store.h v4)
class ParamId {
  static const int thrHi = 0x0001; // u16 ppm, alarm threshold
  static const int thrLo = 0x0002; // u16 ppm, reserved
  static const int calK = 0x0003; // i32, per-mille slope
  static const int calB = 0x0004; // i32 ppm
  static const int manB = 0x0005; // i32 ppm, -200..200
  static const int manK = 0x0006; // i32 per-mille, 100..10000
  static const int buzzerEn = 0x0007; // u8 0/1
  static const int deviceId = 0x0008; // u16 hex suffix
  static const int histBase = 0x0009; // u32 readonly
  static const int calTs = 0x000A; // u32 readonly
  static const int calRaw0 = 0x000B; // i32 readonly
}

/// device_state bits
class DevState {
  static const int pumpOn = 0x01;
  static const int alarming = 0x02;
  static const int muted = 0x04;
  static const int histFull = 0x08;
  static const int paramReset = 0x10;
}

/// event_id for CMD 0x60
class EventId {
  static const int alarmStart = 1;
  static const int alarmEnd = 2;
  static const int lowBattery = 3;
  static const int bleRestored = 4;
  static const int histFull = 5;
  static const int pumpError = 6;
  static const int mcuLinkError = 7;
}

/// CRC16-MODBUS: poly 0x8005 (reflected 0xA001), init 0xFFFF, no final xor.
int crc16Modbus(List<int> data) {
  var c = 0xFFFF;
  for (final b in data) {
    c ^= b;
    for (var i = 0; i < 8; i++) {
      if (c & 1 != 0) {
        c = (c >> 1) ^ 0xA001;
      } else {
        c >>= 1;
      }
    }
  }
  return c;
}

/// Build a complete frame: A5 5A LEN CMD PAYLOAD CRC
Uint8List buildFrame(int cmd, [List<int> payload = const []]) {
  if (payload.length > 239) {
    throw ArgumentError('payload too long: ${payload.length} > 239');
  }
  final body = <int>[cmd, ...payload];
  final crc = crc16Modbus(body);
  final f = Uint8List(body.length + 5); // head(2)+len(1)+body(n)+crc(2)
  f[0] = 0xA5;
  f[1] = 0x5A;
  f[2] = body.length;
  f.setRange(3, 3 + body.length, body);
  f[f.length - 2] = crc & 0xFF;
  f[f.length - 1] = (crc >> 8) & 0xFF;
  return f;
}

/// Parse one frame from a buffer.
/// Returns [frame, bytesConsumed] or null if incomplete.
/// Throws ProtocolException on bad header/CRC/length.
(ParsedFrame, int)? tryParseFrame(List<int> buf, {int offset = 0}) {
  // find header
  var i = offset;
  while (i + 1 < buf.length && !(buf[i] == 0xA5 && buf[i + 1] == 0x5A)) {
    i++;
  }
  if (i + 3 > buf.length) return null;
  final len = buf[i + 2];
  if (len < 1) throw const ProtocolException('bad LEN');
  final total = len + 5; // head(2)+len(1)+body(len)+crc(2)
  if (buf.length - i < total) return null;
  final body = buf.sublist(i + 3, i + 3 + len);
  final crc = buf[i + 3 + len] | (buf[i + 4 + len] << 8);
  final calc = crc16Modbus(body);
  if (crc != calc) throw const ProtocolException('CRC mismatch');
  return (
    ParsedFrame(cmd: body[0], payload: Uint8List.fromList(body.sublist(1))),
    i + total,
  );
}

class ParsedFrame {
  ParsedFrame({required this.cmd, required this.payload});
  final int cmd;
  final Uint8List payload;
}

class ProtocolException implements Exception {
  const ProtocolException(this.message);
  final String message;
  @override
  String toString() => 'ProtocolException: $message';
}

// ---- little-endian readers/writers ----

int rdU16(List<int> b, int o) => b[o] | (b[o + 1] << 8);
int rdU32(List<int> b, int o) =>
    b[o] | (b[o + 1] << 8) | (b[o + 2] << 16) | (b[o + 3] << 24);
int rdI32(List<int> b, int o) => rdU32(b, o).toSigned(32);

double rdF32(List<int> b, int o) {
  final bd = ByteData.sublistView(Uint8List.fromList(b), o, o + 4);
  return bd.getFloat32(0, Endian.little);
}

void wrU16(List<int> b, int o, int v) {
  b[o] = v & 0xFF;
  b[o + 1] = (v >> 8) & 0xFF;
}

void wrU32(List<int> b, int o, int v) {
  b[o] = v & 0xFF;
  b[o + 1] = (v >> 8) & 0xFF;
  b[o + 2] = (v >> 16) & 0xFF;
  b[o + 3] = (v >> 24) & 0xFF;
}

void wrF32(List<int> b, int o, double v) {
  final bd = ByteData(4);
  bd.setFloat32(0, v, Endian.little);
  b.setRange(o, o + 4, bd.buffer.asUint8List());
}
