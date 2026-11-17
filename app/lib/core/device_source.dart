import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:c4f7n_protocol/c4f7n_protocol.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

/// Connection states exposed to UI.
enum LinkState { disconnected, scanning, connecting, connected }

/// Realtime sample used by UI chart.
class Sample {
  Sample(this.t, this.conc);
  final DateTime t;
  final double conc;
}

/// Discovered device during scan.
class ScanHit {
  ScanHit(this.remoteId, this.name, this.rssi);
  final String remoteId;
  final String name;
  final int rssi;
}

/// Abstract data source: real BLE now, mock for development, cloud later.
abstract class DeviceDataSource {
  Stream<Sample> get samples;
  Stream<bool> get linkEvents; // true = connected, false = lost
  Future<void> connect();
  Future<void> disconnect();
  Future<bool> setPump(bool on); // returns resulting device state
  Future<bool> setMute(bool mute); // returns resulting device state
  Future<int?> readThreshold();
  Future<bool> writeThreshold(int ppmX10);

  // ---- Phase 3 additions ----

  /// Device flash history: read [count] points from [start] (oldest first).
  Future<List<HistPoint>> readHistory(int start, int count);

  /// Zero-point calibration step 1: prepare (current reading + stability).
  Future<({double concPpm, bool stable})> calPrepare();

  /// Zero-point calibration step 2: confirm execution.
  Future<bool> calConfirm();

  /// Factory calibration / compensation (0x31). Returns raw result code:
  /// 1=ok, 0x81=need confirm, else NACK code.
  Future<int> factoryCal(int op, {bool confirm = false, double value = 0});

  /// Factory session authentication (0x7A).
  Future<bool> factoryAuth(String password, String deviceIdHex);

  /// Device self-test (0x50).
  Future<SelftestResult> selftest();
}

/// In-memory fake device: same behaviour as the simulator scenarios.
class MockDeviceSource implements DeviceDataSource {
  final _samples = StreamController<Sample>.broadcast();
  final _link = StreamController<bool>.broadcast();
  Timer? _timer;
  final _rng = math.Random();
  double _conc = 3.2;
  int _tick = 0;
  bool _pumpOn = false;
  bool _muted = false;

  final List<Sample> _history = [];

  @override
  Stream<Sample> get samples => _samples.stream;

  @override
  Stream<bool> get linkEvents => _link.stream;

  @override
  Future<void> connect() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    _link.add(true);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _tick++;
      // ramp: quiet for 20s, then climb past threshold
      if (_tick < 20) {
        _conc = 3.0 + _rng.nextDouble() * 0.6;
      } else {
        _conc += 0.7 + _rng.nextDouble() * 0.4;
        if (_conc > 150) _conc = 3.0;
      }
      final s = Sample(DateTime.now(), _conc);
      _history.add(s);
      if (_history.length > 300) _history.removeAt(0);
      _samples.add(s);
    });
  }

  @override
  Future<void> disconnect() async {
    _timer?.cancel();
    _link.add(false);
  }

  @override
  Future<bool> setPump(bool on) async {
    _pumpOn = on;
    return _pumpOn;
  }

  @override
  Future<bool> setMute(bool mute) async {
    _muted = mute;
    return _muted;
  }

  @override
  Future<int?> readThreshold() async => 500;

  @override
  Future<bool> writeThreshold(int ppmX10) async => true;

  List<Sample> get history => List.unmodifiable(_history);

  @override
  Future<List<HistPoint>> readHistory(int start, int count) async {
    final end = math.min(start + count, _history.length);
    if (start >= end) return const [];
    return _history
        .sublist(start, end)
        .map((s) => HistPoint(s.t.millisecondsSinceEpoch ~/ 1000, (s.conc * 10).round()))
        .toList();
  }

  @override
  Future<({double concPpm, bool stable})> calPrepare() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return (concPpm: _conc, stable: true);
  }

  @override
  Future<bool> calConfirm() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return true;
  }

  @override
  Future<int> factoryCal(int op, {bool confirm = false, double value = 0}) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    if ((op == FactoryCalOp.writeManB || op == FactoryCalOp.writeManK) && !confirm) {
      return Err.needConfirm;
    }
    return 1;
  }

  @override
  Future<bool> factoryAuth(String password, String deviceIdHex) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return password.isNotEmpty;
  }

  @override
  Future<SelftestResult> selftest() async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    return SelftestResult(0x3F, [0, 0, 0, 0]);
  }
}

/// Real BLE central against the ESP32 bridge or the simulator app
/// (both speak protocol v1, spec: docs/协议v1.md).
class BleDeviceSource implements DeviceDataSource {
  BleDeviceSource(this.remoteId, {this.deviceName = ''});

  final String remoteId;
  final String deviceName;

  final _samples = StreamController<Sample>.broadcast();
  final _link = StreamController<bool>.broadcast();

  BluetoothCharacteristic? _writeChar;
  BluetoothCharacteristic? _notifyChar;
  StreamSubscription? _valueSub;
  StreamSubscription? _connSub;
  Timer? _hbTimer;

  /// one in-flight request at a time (spec §4.2)
  final Map<int, Completer<ParsedFrame>> _pending = {};
  final List<int> _rxBuf = [];

  @override
  Stream<Sample> get samples => _samples.stream;

  @override
  Stream<bool> get linkEvents => _link.stream;

  /// Discover nearby C4F7N-* advertisers (10 s window).
  static Future<List<ScanHit>> scan({Duration timeout = const Duration(seconds: 10)}) async {
    final hits = <String, ScanHit>{};
    final sub = FlutterBluePlus.scanResults.listen((results) {
      for (final r in results) {
        final name = r.advertisementData.advName;
        if (name.startsWith('C4F7N-')) {
          hits[r.device.remoteId.str] = ScanHit(r.device.remoteId.str, name, r.rssi);
        }
      }
    });
    await FlutterBluePlus.startScan(timeout: timeout, continuousUpdates: true);
    await Future<void>.delayed(timeout);
    await sub.cancel();
    await FlutterBluePlus.stopScan();
    final list = hits.values.toList()..sort((a, b) => b.rssi.compareTo(a.rssi));
    return list;
  }

  @override
  Future<void> connect() async {
    final device = BluetoothDevice.fromId(remoteId);
    await device.connect(mtu: 247, timeout: const Duration(seconds: 15));

    // link monitor
    _connSub?.cancel();
    _connSub = device.connectionState.listen((s) {
      if (s == BluetoothConnectionState.connected) {
        _link.add(true);
      } else {
        _link.add(false);
        _teardown();
      }
    });

    // GATT setup
    final services = await device.discoverServices(timeout: 15);
    for (final svc in services) {
      if (svc.serviceUuid.str.toString().toUpperCase() !=
          kServiceUuid.toUpperCase()) {
        continue;
      }
      for (final c in svc.characteristics) {
        final u = c.characteristicUuid.str.toString().toUpperCase();
        if (u == kCharWriteUuid.toUpperCase()) {
          _writeChar = c;
        } else if (u == kCharNotifyUuid.toUpperCase()) {
          _notifyChar = c;
        }
      }
    }
    if (_writeChar == null || _notifyChar == null) {
      // diagnostic: list what the device actually exposes
      final seen = services.map((s) => s.serviceUuid.str.toString()).join(', ');
      await device.disconnect(); // clean drop, device resumes advertising
      throw ProtocolException(
          'protocol v1 GATT service not found; device exposes: [$seen]');
    }

    await _notifyChar!.setNotifyValue(true);
    _valueSub?.cancel();
    _valueSub = _notifyChar!.onValueReceived.listen(_feedBytes);

    // heartbeat @5s (spec §4.2); device drops us after 15 s silence
    _hbTimer?.cancel();
    _hbTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _request(Cmd.heartbeat, const [], expectAck: false);
    });
    _link.add(true);
  }

  void _teardown() {
    _hbTimer?.cancel();
    _hbTimer = null;
    for (final c in _pending.values) {
      if (!c.isCompleted) c.completeError(const ProtocolException('link lost'));
    }
    _pending.clear();
  }

  @override
  Future<void> disconnect() async {
    _teardown();
    await _valueSub?.cancel();
    await _connSub?.cancel();
    await BluetoothDevice.fromId(remoteId).disconnect();
    _link.add(false);
  }

  // ---- frame plumbing ----

  void _feedBytes(List<int> bytes) {
    _rxBuf.addAll(bytes);
    while (true) {
      var h = -1;
      for (var i = 0; i + 1 < _rxBuf.length; i++) {
        if (_rxBuf[i] == 0xA5 && _rxBuf[i + 1] == 0x5A) {
          h = i;
          break;
        }
      }
      if (h < 0) {
        _rxBuf.clear();
        return;
      }
      if (h > 0) _rxBuf.removeRange(0, h);
      if (_rxBuf.length < 3) return;
      final len = _rxBuf[2];
      final total = len + 5;
      if (_rxBuf.length < total) return;
      final frame = Uint8List.fromList(_rxBuf.sublist(0, total));
      _rxBuf.removeRange(0, total);
      ParsedFrame pf;
      try {
        final (p, _) = tryParseFrame(frame)!;
        pf = p;
      } on ProtocolException {
        continue; // CRC error: drop frame
      }
      _handleFrame(pf);
    }
  }

  void _handleFrame(ParsedFrame pf) {
    switch (pf.cmd) {
      case Cmd.realtime:
        final rt = RealtimeFrame.decode(pf.payload);
        _samples.add(Sample(DateTime.now(), rt.concPpm));
      case Cmd.event:
        // Phase 3: alarm events page consumes these
        break;
      default:
        final c = _pending.remove(pf.cmd);
        if (c != null && !c.isCompleted) {
          c.complete(pf);
        }
    }
  }

  /// Request-response with 2s timeout and one retry (spec §4.2).
  Future<ParsedFrame> _request(
    int cmd,
    List<int> payload, {
    bool expectAck = true,
  }) async {
    if (_writeChar == null) {
      throw const ProtocolException('not connected');
    }
    for (var attempt = 0; attempt < 2; attempt++) {
      final c = Completer<ParsedFrame>();
      _pending[expectAck ? cmd : -1] = c;
      try {
        await _writeChar!.write(
          buildFrame(cmd, payload),
          withoutResponse: true,
          timeout: 3,
        );
        final pf = await c.future.timeout(const Duration(seconds: 2));
        return pf;
      } on TimeoutException {
        _pending.remove(expectAck ? cmd : -1);
        if (attempt == 1) rethrow;
      } finally {
        // heartbeat (no-ack) cleanup
        if (!expectAck) _pending.remove(-1);
      }
    }
    throw const ProtocolException('no response');
  }

  void _checkAck(ParsedFrame pf) {
    if (pf.payload.isNotEmpty && pf.payload[0] != 1 && pf.payload[0] != 0x81) {
      throw ProtocolException('NACK 0x${pf.payload[0].toRadixString(16)}');
    }
  }

  // ---- DeviceDataSource API ----

  @override
  Future<bool> setPump(bool on) async {
    final pf = await _request(Cmd.pump, [on ? 1 : 0]);
    return pf.payload.isNotEmpty ? pf.payload[0] == 1 : on;
  }

  @override
  Future<bool> setMute(bool mute) async {
    final pf = await _request(Cmd.mute, [mute ? 1 : 0]);
    return pf.payload.isNotEmpty ? pf.payload[0] == 1 : mute;
  }

  @override
  Future<int?> readThreshold() async {
    final pf = await _request(Cmd.paramRead, _u16(ParamId.thrHi));
    if (pf.payload.length >= 6) {
      return rdU32(pf.payload, 2);
    }
    return null;
  }

  @override
  Future<bool> writeThreshold(int ppmX10) async {
    final pf = await _request(
      Cmd.paramWrite,
      [..._u16(ParamId.thrHi), ..._u32(ppmX10)],
    );
    _checkAck(pf);
    return true;
  }

  @override
  Future<List<HistPoint>> readHistory(int start, int count) async {
    final out = <HistPoint>[];
    var idx = start;
    // pages of 32 until empty batch or requested count reached
    while (out.length < count) {
      final n = math.min(32, count - out.length);
      final pf = await _request(
        Cmd.historyRead,
        [..._u32(idx), ..._u16(n), ..._u16(0)],
      );
      final batch = HistoryBatch.decode(pf.payload);
      if (batch.points.isEmpty) break;
      out.addAll(batch.points);
      idx += batch.points.length;
    }
    return out;
  }

  @override
  Future<({double concPpm, bool stable})> calPrepare() async {
    final pf = await _request(Cmd.zeroCal, [1]);
    return (
      concPpm: rdU16(pf.payload, 0) / 10.0,
      stable: rdU16(pf.payload, 2) == 1,
    );
  }

  @override
  Future<bool> calConfirm() async {
    final pf = await _request(Cmd.zeroCal, [2]);
    return pf.payload.isNotEmpty && pf.payload[0] == 1;
  }

  @override
  Future<int> factoryCal(int op, {bool confirm = false, double value = 0}) async {
    final bytes = ByteData(4)..setFloat32(0, value, Endian.little);
    final pf = await _request(Cmd.factoryCal, [
      op,
      confirm ? 1 : 0,
      ...bytes.buffer.asUint8List(),
    ]);
    return pf.payload.isNotEmpty ? pf.payload[0] : 0;
  }

  @override
  Future<bool> factoryAuth(String password, String deviceIdHex) async {
    final req = FactoryAuthRequest(deviceIdHex, password).encode();
    final (pf, _) = tryParseFrame(req)!;
    _pending[Cmd.factoryAuth] = Completer<ParsedFrame>();
    try {
      await _writeChar!.write(
        buildFrame(Cmd.factoryAuth, pf.payload),
        withoutResponse: true,
        timeout: 3,
      );
      final resp = await _pending[Cmd.factoryAuth]!
          .future
          .timeout(const Duration(seconds: 2));
      return resp.payload.isNotEmpty && resp.payload[0] == 1;
    } on TimeoutException {
      return false;
    } finally {
      _pending.remove(Cmd.factoryAuth);
    }
  }

  @override
  Future<SelftestResult> selftest() async {
    final pf = await _request(Cmd.selftest, const []);
    return SelftestResult.decode(pf.payload);
  }

  List<int> _u16(int v) => [v & 0xFF, (v >> 8) & 0xFF];
  List<int> _u32(int v) =>
      [v & 0xFF, (v >> 8) & 0xFF, (v >> 16) & 0xFF, (v >> 24) & 0xFF];
}
