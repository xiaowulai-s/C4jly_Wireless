/// Typed message models for protocol v1 commands (spec: docs/协议v1.md §4).
library;

import 'dart:convert' show ascii;
import 'dart:typed_data';

import 'package:crypto/crypto.dart' as crypto;

import 'frame.dart';

// ---- 0x01 heartbeat ----

class HeartbeatRequest {
  HeartbeatRequest();
  Uint8List encode() => buildFrame(Cmd.heartbeat, _u32(protoVersion));
  static HeartbeatRequest decode(Uint8List p) => HeartbeatRequest();
}

class HeartbeatResponse {
  HeartbeatResponse({
    required this.battery,
    required this.deviceState,
    required this.fwMajor,
    required this.fwMinor,
    required this.paramVer,
  });
  final int battery;
  final int deviceState;
  final int fwMajor;
  final int fwMinor;
  final int paramVer;

  factory HeartbeatResponse.decode(Uint8List p) {
    if (p.length < 8) throw const ProtocolException('heartbeat resp too short');
    return HeartbeatResponse(
      battery: p[4],
      deviceState: p[5],
      fwMajor: p[6],
      fwMinor: p[7],
      paramVer: p[8],
    );
  }
  Uint8List encode() => buildFrame(Cmd.heartbeat, [
        ..._u32(protoVersion),
        battery,
        deviceState,
        fwMajor,
        fwMinor,
        paramVer,
        0, 0, 0, 0,
      ]);
}

// ---- 0x10 realtime (device -> app, 1Hz) ----

class RealtimeFrame {
  RealtimeFrame({
    required this.concPpm,
    required this.tempC,
    required this.peakPpm,
    required this.battery,
    required this.deviceState,
    required this.thrHiPpm,
    required this.uptimeS,
  });
  final double concPpm;
  final double tempC;
  final double peakPpm;
  final int battery;
  final int deviceState;
  final double thrHiPpm;
  final int uptimeS;

  bool get pumpOn => deviceState & DevState.pumpOn != 0;
  bool get alarming => deviceState & DevState.alarming != 0;
  bool get muted => deviceState & DevState.muted != 0;

  factory RealtimeFrame.decode(Uint8List p) {
    if (p.length < 14) throw const ProtocolException('realtime too short');
    return RealtimeFrame(
      concPpm: rdU16(p, 0) / 10.0,
      tempC: rdU16(p, 2) / 10.0,
      peakPpm: rdU16(p, 4) / 10.0,
      battery: p[6],
      deviceState: p[7],
      thrHiPpm: rdU16(p, 8) / 10.0,
      uptimeS: rdU32(p, 10),
    );
  }
  Uint8List encode() => buildFrame(Cmd.realtime, [
        ..._u16((concPpm * 10).round()),
        ..._u16((tempC * 10).round()),
        ..._u16((peakPpm * 10).round()),
        battery,
        deviceState,
        ..._u16((thrHiPpm * 10).round()),
        ..._u32(uptimeS),
      ]);
}

// ---- 0x11/0x12 param read/write ----

class ParamReadRequest {
  ParamReadRequest(this.paramId);
  final int paramId;
  Uint8List encode() => buildFrame(Cmd.paramRead, _u16(paramId));
}

class ParamValue {
  ParamValue(this.paramId, this.value);
  final int paramId;
  final int value;
  factory ParamValue.decode(Uint8List p) {
    if (p.length < 6) throw const ProtocolException('param resp too short');
    return ParamValue(rdU16(p, 0), rdU32(p, 2));
  }
  Uint8List encode(int cmd) => buildFrame(cmd, [..._u16(paramId), ..._u32(value)]);
}

class ParamWriteRequest {
  ParamWriteRequest(this.paramId, this.value);
  final int paramId;
  final int value;
  Uint8List encode() => buildFrame(Cmd.paramWrite, [..._u16(paramId), ..._u32(value)]);
}

// ---- 0x20/0x21 pump & mute ----

class PumpCommand {
  PumpCommand(this.on);
  final bool on;
  Uint8List encode() => buildFrame(Cmd.pump, [on ? 1 : 0]);
  static PumpCommand decode(Uint8List p) => PumpCommand(p[0] == 1);
}

class MuteCommand {
  MuteCommand(this.mute);
  final bool mute;
  Uint8List encode() => buildFrame(Cmd.mute, [mute ? 1 : 0]);
  static MuteCommand decode(Uint8List p) => MuteCommand(p[0] == 1);
}

class StateAck {
  StateAck(this.state);
  final bool state;
  factory StateAck.decode(Uint8List p) => StateAck(p.isNotEmpty && p[0] == 1);
  Uint8List encode(int cmd) => buildFrame(cmd, [state ? 1 : 0]);
}

// ---- 0x30 zero calibration (two-step) ----

class ZeroCalStep {
  ZeroCalStep.prepare() : step = 1;
  ZeroCalStep.confirm() : step = 2;
  final int step;
  Uint8List encode() => buildFrame(Cmd.zeroCal, [step]);
}

class ZeroCalPrepareResult {
  ZeroCalPrepareResult({required this.concPpm, required this.stable});
  final double concPpm;
  final bool stable;
  factory ZeroCalPrepareResult.decode(Uint8List p) => ZeroCalPrepareResult(
        concPpm: rdU16(p, 0) / 10.0,
        stable: rdU16(p, 2) == 1,
      );
  Uint8List encode() => buildFrame(Cmd.zeroCal,
      [..._u16((concPpm * 10).round()), ..._u16(stable ? 1 : 0), ..._u32(0)]);
}

// ---- 0x31 factory calibration ----

class FactoryCalOp {
  static const int calSlope = 0x01;
  static const int calOffset = 0x02;
  static const int writeManB = 0x03;
  static const int writeManK = 0x04;
  static const int factoryReset = 0x05;
}

class FactoryCalRequest {
  FactoryCalRequest(this.op, {this.confirm = false, this.value = 0});
  final int op;
  final bool confirm;
  final double value;
  Uint8List encode() => buildFrame(Cmd.factoryCal, [
        op,
        confirm ? 1 : 0,
        ..._f32(value),
      ]);
}

class FactoryCalResult {
  FactoryCalResult(this.result);
  final int result; // 1=ok, 0x81=need confirm, else NACK code
  bool get ok => result == 1;
  bool get needConfirm => result == Err.needConfirm;
  factory FactoryCalResult.decode(Uint8List p) =>
      FactoryCalResult(p.isNotEmpty ? p[0] : 0);
  Uint8List encode() => buildFrame(Cmd.factoryCal, [result, 0]);
}

// ---- 0x40/0x41 history ----

class HistoryReadRequest {
  HistoryReadRequest(this.startIdx, this.maxN);
  final int startIdx;
  final int maxN; // <= 32
  Uint8List encode() => buildFrame(Cmd.historyRead, [
        ..._u32(startIdx),
        ..._u16(maxN),
      ]);
}

class HistPoint {
  HistPoint(this.ts, this.ppm);
  final int ts; // epoch seconds
  final int ppm;
}

class HistoryBatch {
  HistoryBatch(this.points);
  final List<HistPoint> points;
  bool get isLast => points.isEmpty;
  factory HistoryBatch.decode(Uint8List p) {
    if (p.isEmpty) throw const ProtocolException('hist batch empty');
    final n = p[0];
    final pts = <HistPoint>[];
    for (var i = 0; i < n; i++) {
      final o = 1 + i * 6;
      pts.add(HistPoint(rdU32(p, o), rdU16(p, o + 4)));
    }
    return HistoryBatch(pts);
  }
  Uint8List encode() {
    final payload = <int>[points.length];
    for (final pt in points) {
      payload..addAll(_u32(pt.ts))..addAll(_u16(pt.ppm));
    }
    return buildFrame(Cmd.historyRead, payload);
  }
}

class HistoryDeleteRequest {
  HistoryDeleteRequest();
  Uint8List encode() => buildFrame(Cmd.historyDelete, [0xAA]);
}

// ---- 0x50 selftest ----

class SelftestResult {
  SelftestResult(this.resultBits, this.errCodes);
  final int resultBits; // bit0 sensor, bit1 storage, bit2 pump, bit3 battery, bit4 oled, bit5 ble
  final List<int> errCodes;
  bool get allOk => resultBits == 0x3F;
  factory SelftestResult.decode(Uint8List p) => SelftestResult(
        rdU32(p, 0),
        p.sublist(4, 8),
      );
  Uint8List encode() => buildFrame(Cmd.selftest, [..._u32(resultBits), ...errCodes]);
}

// ---- 0x60 event ----

class EventFrame {
  EventFrame(this.eventId, this.timestampS);
  final int eventId;
  final int timestampS;
  factory EventFrame.decode(Uint8List p) =>
      EventFrame(p[0], rdU32(p, 4));
  Uint8List encode() =>
      buildFrame(Cmd.event, [eventId, 0, 0, 0, ..._u32(timestampS)]);
}

// ---- 0x7A factory auth (v1.1: SHA-256 of the password, 32 bytes) ----

class FactoryAuthRequest {
  FactoryAuthRequest(this.password);
  final String password;
  Uint8List encode() =>
      buildFrame(Cmd.factoryAuth, _sha256(password)); // 32B digest
}

/// v1.1 auth-hash provisioning (CMD 0x00 / sub 0x03, factory session):
/// burns SHA-256(password) into the device; afterwards 0x7A compares it.
class AuthHashSetRequest {
  AuthHashSetRequest(this.password);
  final String password;
  Uint8List encode() => buildFrame(
      Cmd.maint, [MaintOp.authHashSet, ..._sha256(password)]);
}

// ---- v1.1 maintenance: SN read / write (CMD 0x00) ----

class SnReadRequest {
  Uint8List encode() => buildFrame(Cmd.maint, [MaintOp.snRead]);
}

/// response: [sub, ...SN ascii]
class SnData {
  SnData(this.sn);
  final String sn;
  static SnData? decode(Uint8List p) {
    if (p.length < 2 || p[0] != MaintOp.snRead) return null;
    return SnData(String.fromCharCodes(p.sublist(1)).trim());
  }
}

class SnWriteRequest {
  SnWriteRequest(String sn) : sn = sn {
    if (sn.isEmpty ||
        sn.length > 24 ||
        !RegExp(r'^[ -~]+$').hasMatch(sn)) {
      throw ArgumentError('SN must be 1..24 printable ASCII chars');
    }
  }
  final String sn; // ASCII, 1..24 chars
  Uint8List encode() =>
      buildFrame(Cmd.maint, [MaintOp.snWrite, ...asciiBytes(sn)]);
}

Uint8List asciiBytes(String s) => Uint8List.fromList(s.codeUnits);

class FactoryAuthResult {
  FactoryAuthResult(this.ok);
  final bool ok;
  factory FactoryAuthResult.decode(Uint8List p) =>
      FactoryAuthResult(p.isNotEmpty && p[0] == 1);
  Uint8List encode() => buildFrame(Cmd.factoryAuth, [ok ? 1 : 0]);
}

// ---- generic ACK/NACK ----

class Ack {
  const Ack(this.ok, this.errCode);
  const Ack.ok()
      : ok = true,
        errCode = 0;
  const Ack.fail(this.errCode) : ok = false;
  final bool ok;
  final int errCode; // 0 when ok

  /// Interpret a response frame: empty payload = plain OK;
  /// payload[0]==1 = OK; anything else = NACK code.
  factory Ack.fromFrame(ParsedFrame f) {
    if (f.payload.isEmpty) return const Ack.ok();
    if (f.payload[0] == 1) return const Ack.ok();
    return Ack.fail(f.payload[0]);
  }
  Uint8List encode(int cmd) => buildFrame(cmd, [ok ? 1 : errCode]);
}

// ---- helpers ----

List<int> _u16(int v) => [v & 0xFF, (v >> 8) & 0xFF];
List<int> _u32(int v) =>
    [v & 0xFF, (v >> 8) & 0xFF, (v >> 16) & 0xFF, (v >> 24) & 0xFF];
List<int> _f32(double v) {
  final bd = ByteData(4)..setFloat32(0, v, Endian.little);
  return bd.buffer.asUint8List();
}

Uint8List _sha256(String s) =>
    crypto.sha256.convert(ascii.encode(s)).bytes as Uint8List;
