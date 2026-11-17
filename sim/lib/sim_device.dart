import 'dart:async';
import 'dart:typed_data';

import 'package:ble_peripheral/ble_peripheral.dart';
import 'package:c4f7n_protocol/c4f7n_protocol.dart';

/// Fake C4F7N leak detector: GATT server + protocol v1 handler + scenarios.
///
/// Used to develop/test the mobile app before ESP32 hardware arrives.
class SimDevice {
  SimDevice({this.deviceIdHex = '0001'});

  final String deviceIdHex;

  // ---- simulated device state ----
  double conc = 3.2;
  double tempC = 26.3;
  double peak = 3.2;
  int battery = 86;
  bool pumpOn = false;
  bool muted = false;
  bool alarming = false;
  int thrHi = 500; // ppm * 10
  final DateTime bootTime = DateTime.now();

  /// scenario drives conc over time
  Scenario scenario = Scenario.stable;

  /// in-memory history ring (ts, ppm)
  final List<HistPoint> history = [];

  // ---- BLE ----
  bool advertising = false;
  int connectedCount = 0;
  bool _notifySubscribed = false;
  final List<int> _rxBuf = [];
  final List<String> logLines = [];
  Timer? _tick;

  static const int _maxLog = 200;

  void log(String s) {
    final ts = DateTime.now().toIso8601String().substring(11, 19);
    logLines.insert(0, '[$ts] $s');
    if (logLines.length > _maxLog) logLines.removeLast();
  }

  int get _uptime => DateTime.now().difference(bootTime).inSeconds;

  Future<void> start() async {
    await BlePeripheral.initialize();
    BlePeripheral.setWriteRequestCallback(_onWrite);
    BlePeripheral.setReadRequestCallback(_onRead);
    BlePeripheral.setCharacteristicSubscriptionChangeCallback(
      (deviceId, characteristicId, isSubscribed, name) {
        if (characteristicId == kCharNotifyUuid) {
          _notifySubscribed = isSubscribed;
        }
        log('notify sub=$isSubscribed');
      },
    );
    BlePeripheral.setConnectionStateChangeCallback((deviceId, connected) {
      if (connected) {
        connectedCount++;
      } else {
        connectedCount = (connectedCount - 1).clamp(0, 99);
      }
      log('conn ${connected ? "up" : "down"} $deviceId');
    });
    BlePeripheral.setMtuChangeCallback((deviceId, mtu) => log('mtu $mtu'));

    await BlePeripheral.addService(
      BleService(
        uuid: kServiceUuid,
        primary: true,
        characteristics: [
          BleCharacteristic(
            uuid: kCharWriteUuid,
            properties: [
              CharacteristicProperties.write.index,
              CharacteristicProperties.writeWithoutResponse.index,
            ],
            permissions: [AttributePermissions.writeable.index],
            value: Uint8List(0),
          ),
          BleCharacteristic(
            uuid: kCharNotifyUuid,
            properties: [
              CharacteristicProperties.read.index,
              CharacteristicProperties.notify.index,
            ],
            permissions: [AttributePermissions.readable.index],
            value: Uint8List(0),
          ),
        ],
      ),
    );

    _tick = Timer.periodic(const Duration(seconds: 1), (_) => _onTick());
    log('service added, ready');
  }

  Future<void> startAdvertise() async {
    await BlePeripheral.startAdvertising(
      services: [kServiceUuid],
      localName: 'C4F7N-$deviceIdHex',
    );
    advertising = true;
    log('advertising as C4F7N-$deviceIdHex');
  }

  Future<void> stopAdvertise() async {
    await BlePeripheral.stopAdvertising();
    advertising = false;
    log('advertising stopped');
  }

  void dispose() {
    _tick?.cancel();
    BlePeripheral.stopAdvertising();
  }

  // ---- 1 Hz tick: scenario + history + notify ----

  void _onTick() {
    // scenario drives concentration
    switch (scenario) {
      case Scenario.stable:
        conc = 3.2 + _noise(1.5);
      case Scenario.rampAlarm:
        conc += 0.8 + _noise(0.3);
        if (conc > 200) conc = 3.2;
      case Scenario.spike:
        conc = _spikeShape(_uptime % 30) + _noise(0.5);
    }
    if (conc < 0) conc = 0;
    if (conc > peak) peak = conc;
    alarming = !muted && (conc * 10).round() >= thrHi;

    // history @1s
    history.add(HistPoint(_uptime, (conc * 10).round()));
    if (history.length > 3600) history.removeAt(0);

    // battery slow drain
    if (battery > 5) battery -= pumpOn ? 1 : 0; // 1%/min-ish when pumped

    // 1 Hz notify
    final f = RealtimeFrame(
      concPpm: conc,
      tempC: tempC + _noise(0.2),
      peakPpm: peak,
      battery: battery,
      deviceState: _stateBits(),
      thrHiPpm: thrHi / 10.0,
      uptimeS: _uptime,
    );
    if (_notifySubscribed) {
      BlePeripheral.updateCharacteristic(
        characteristicId: kCharNotifyUuid,
        value: f.encode(),
      );
    }
  }

  int _stateBits() {
    var s = 0;
    if (pumpOn) s |= DevState.pumpOn;
    if (alarming) s |= DevState.alarming;
    if (muted) s |= DevState.muted;
    return s;
  }

  double _noise(double amp) =>
      (DateTime.now().microsecondsSinceEpoch % 1000) / 1000.0 * amp - amp / 2;

  double _spikeShape(int t) {
    if (t < 10) return 3.0;
    if (t < 15) return 3.0 + (t - 10) * 12; // fast rise to ~63
    if (t < 20) return 63.0 - (t - 15) * 10;
    return 3.0;
  }

  // ---- GATT callbacks ----

  ReadRequestResult? _onRead(
    String deviceId,
    String characteristicId,
    int offset,
    Uint8List? value,
  ) {
    return ReadRequestResult(value: Uint8List(0), offset: offset, status: 0);
  }

  WriteRequestResult? _onWrite(
    String deviceId,
    String characteristicId,
    int offset,
    Uint8List? value,
  ) {
    if (value != null && value.isNotEmpty) {
      _rxBuf.addAll(value);
      _drainRx(deviceId);
    }
    return WriteRequestResult(offset: offset, status: 0);
  }

  /// Frame assembly: scan buffer for A5 5A ... CRC; dispatch each frame.
  void _drainRx(String deviceId) {
    while (true) {
      // find header
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
      final frameBytes = Uint8List.fromList(_rxBuf.sublist(0, total));
      _rxBuf.removeRange(0, total);
      try {
        final (pf, _) = tryParseFrame(frameBytes)!;
        _dispatch(pf, deviceId);
      } on ProtocolException catch (e) {
        log('rx error: $e');
      }
    }
  }

  void _send(ParsedFrame f, String deviceId) {
    final bytes = buildFrame(f.cmd, f.payload);
    BlePeripheral.updateCharacteristic(
      characteristicId: kCharNotifyUuid,
      value: bytes,
      deviceId: deviceId,
    );
  }

  void _dispatch(ParsedFrame f, String deviceId) {
    final p = f.payload;
    switch (f.cmd) {
      case Cmd.heartbeat:
        log('hb');
        _send(
          ParsedFrame(
            cmd: Cmd.heartbeat,
            payload: Uint8List.fromList([
              ..._u32(protoVersion),
              battery,
              _stateBits(),
              4, 10, // fw 4.10
              4, // param version
              0, 0, 0, 0,
            ]),
          ),
          deviceId,
        );
      case Cmd.pump:
        pumpOn = p[0] == 1;
        log('pump -> $pumpOn');
        _send(ParsedFrame(cmd: Cmd.pump, payload: Uint8List.fromList([pumpOn ? 1 : 0])), deviceId);
      case Cmd.mute:
        muted = p[0] == 1;
        log('mute -> $muted');
        _send(ParsedFrame(cmd: Cmd.mute, payload: Uint8List.fromList([muted ? 1 : 0])), deviceId);
      case Cmd.paramRead:
        final id = rdU16(p, 0);
        _send(
          ParsedFrame(cmd: Cmd.paramRead, payload: Uint8List.fromList([..._u16(id), ..._u32(_paramValue(id))])),
          deviceId,
        );
        log('param read 0x${id.toRadixString(16)}');
      case Cmd.paramWrite:
        final id = rdU16(p, 0);
        final v = rdU32(p, 2);
        _setParam(id, v);
        _send(
          ParsedFrame(cmd: Cmd.paramWrite, payload: Uint8List.fromList([..._u16(id), ..._u32(_paramValue(id))])),
          deviceId,
        );
        log('param write 0x${id.toRadixString(16)}=$v');
      case Cmd.zeroCal:
        if (p[0] == 1) {
          log('cal step1');
          _send(
            ParsedFrame(
              cmd: Cmd.zeroCal,
              payload: Uint8List.fromList([
                ..._u16((conc * 10).round()),
                ..._u16(1), // stable
                ..._u32(0),
              ]),
            ),
            deviceId,
          );
        } else {
          log('cal step2 -> ok');
          _send(ParsedFrame(cmd: Cmd.zeroCal, payload: Uint8List.fromList([1])), deviceId);
        }
      case Cmd.factoryCal:
        final op = p[0];
        final confirm = p[1] == 1;
        log('factoryCal op=0x${op.toRadixString(16)} confirm=$confirm');
        // simulate need-confirm when writing man_k beyond 20%
        final need = (op == FactoryCalOp.writeManK || op == FactoryCalOp.writeManB) && !confirm;
        _send(
          ParsedFrame(
            cmd: Cmd.factoryCal,
            payload: Uint8List.fromList([need ? Err.needConfirm : 1, 0]),
          ),
          deviceId,
        );
      case Cmd.historyRead:
        final start = rdU32(p, 0);
        final maxN = rdU16(p, 4) > 32 ? 32 : rdU16(p, 4);
        final slice = <HistPoint>[];
        for (var i = 0; i < maxN && start + i < history.length; i++) {
          slice.add(history[start + i]);
        }
        final payload = <int>[slice.length];
        for (final pt in slice) {
          payload..addAll(_u32(pt.ts))..addAll(_u16(pt.ppm));
        }
        _send(ParsedFrame(cmd: Cmd.historyRead, payload: Uint8List.fromList(payload)), deviceId);
        log('hist read idx=$start n=${slice.length}');
      case Cmd.historyDelete:
        history.clear();
        log('history cleared');
        _send(ParsedFrame(cmd: Cmd.historyDelete, payload: Uint8List(0)), deviceId);
      case Cmd.selftest:
        _send(
          ParsedFrame(
            cmd: Cmd.selftest,
            payload: Uint8List.fromList([..._u32(0x3F), 0, 0, 0, 0]),
          ),
          deviceId,
        );
        log('selftest ok');
      case Cmd.factoryAuth:
        log('factory auth (sim: always ok)');
        _send(ParsedFrame(cmd: Cmd.factoryAuth, payload: Uint8List.fromList([1])), deviceId);
      default:
        log('unknown cmd 0x${f.cmd.toRadixString(16)}');
        _send(ParsedFrame(cmd: f.cmd, payload: Uint8List.fromList([Err.unknownCmd])), deviceId);
    }
  }

  int _paramValue(int id) {
    switch (id) {
      case ParamId.thrHi:
        return thrHi;
      case ParamId.buzzerEn:
        return 1;
      case ParamId.deviceId:
        return int.parse(deviceIdHex, radix: 16);
      default:
        return 0;
    }
  }

  void _setParam(int id, int v) {
    if (id == ParamId.thrHi) thrHi = v;
  }
}

enum Scenario { stable, rampAlarm, spike }

List<int> _u16(int v) => [v & 0xFF, (v >> 8) & 0xFF];
List<int> _u32(int v) =>
    [v & 0xFF, (v >> 8) & 0xFF, (v >> 16) & 0xFF, (v >> 24) & 0xFF];
