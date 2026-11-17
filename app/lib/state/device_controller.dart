import 'dart:async';

import 'package:c4f7n_protocol/c4f7n_protocol.dart' show HistPoint, SelftestResult;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';

import '../core/device_source.dart';
import '../data/alarm_notify.dart';
import '../data/db.dart';

export '../core/device_source.dart'
    show DeviceDataSource, LinkState, Sample, ScanHit;

/// App-wide device controller: bridges a DeviceDataSource to UI state.
class DeviceController extends ChangeNotifier {
  DeviceController(this._source);

  DeviceDataSource _source;
  StreamSubscription<Sample>? _sub;
  StreamSubscription<bool>? _linkSub;

  final TaskStore store = TaskStore.instance;

  LinkState link = LinkState.disconnected;
  double conc = 0;
  double peak = 0;
  bool pumpOn = false;
  bool muted = false;
  bool alarming = false;
  int threshold = 500; // ppm * 10
  final List<Sample> window = []; // last 60 s
  String deviceName = '';

  // scan state
  List<ScanHit> hits = [];
  bool scanning = false;
  String? scanError;

  // favorite devices (switch-style multi-device)
  List<Map<String, Object?>> favorites = [];

  // task recording state
  int? _activeTaskId;
  int _overCount = 0;
  double _taskPeak = 0;
  bool get recording => _activeTaskId != null;
  int? get activeTaskId => _activeTaskId;

  // open alarm event (client-side capture; device 0x60 events merge in Phase 4)
  int? _openEventId;

  // factory session
  bool factoryUnlocked = false;

  // dark mode (persisted)
  ThemeMode themeMode = ThemeMode.system;

  bool get isMock => _source is MockDeviceSource;

  Future<void> bootstrap() async {
    await AlarmNotifier.instance.init();
    try {
      favorites = await store.listDevices();
      final sp = await SharedPreferences.getInstance();
      final m = sp.getString('themeMode') ?? 'system';
      themeMode = m == 'light'
          ? ThemeMode.light
          : m == 'dark'
              ? ThemeMode.dark
              : ThemeMode.system;
    } catch (_) {}
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode m) async {
    themeMode = m;
    try {
      final sp = await SharedPreferences.getInstance();
      await sp.setString('themeMode', m.name);
    } catch (_) {}
    notifyListeners();
  }

  Future<void> refreshFavorites() async {
    try {
      favorites = await store.listDevices();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> removeFavorite(String remoteId) async {
    await store.deleteDevice(remoteId);
    await refreshFavorites();
  }

  /// switch device: tear down current link, connect the favorite
  Future<void> connectFavorite(Map<String, Object?> fav) async {
    final remoteId = fav['remote_id'] as String;
    final name = fav['name'] as String;
    if (link != LinkState.disconnected) {
      try {
        await _source.disconnect();
      } catch (_) {}
    }
    _source = BleDeviceSource(remoteId, deviceName: name);
    deviceName = name;
    await connect();
  }

  Future<void> startScan() async {
    // Android 12+ runtime permissions (manifest already declares them)
    final statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ].request();
    final scanDenied = statuses[Permission.bluetoothScan]?.isDenied ?? false;
    final connDenied =
        statuses[Permission.bluetoothConnect]?.isDenied ?? false;
    if (scanDenied || connDenied) {
      scanError = '蓝牙权限被拒绝，请在系统设置中允许“附近的设备”';
      notifyListeners();
      return;
    }

    scanning = true;
    hits = [];
    scanError = null;
    notifyListeners();
    try {
      hits = await BleDeviceSource.scan();
    } catch (e) {
      scanError = '扫描失败：$e';
    }
    scanning = false;
    notifyListeners();
  }

  Future<void> connectScanHit(ScanHit hit) async {
    _source = BleDeviceSource(hit.remoteId, deviceName: hit.name);
    deviceName = hit.name;
    await connect();
    if (link == LinkState.connected) {
      await store.saveDevice(hit.remoteId, hit.name);
      await refreshFavorites();
    }
  }

  Future<void> connect() async {
    link = LinkState.connecting;
    notifyListeners();
    _sub?.cancel();
    _sub = _source.samples.listen(_onSample);
    _linkSub?.cancel();
    _linkSub = _source.linkEvents.listen((up) {
      link = up ? LinkState.connected : LinkState.disconnected;
      if (!up) {
        window.clear();
        conc = 0;
        peak = 0;
        pumpOn = false;
        muted = false;
      }
      _syncForeground();
      notifyListeners();
    });
    try {
      await _source.connect();
      try {
        final t = await _source.readThreshold();
        if (t != null) threshold = t;
      } catch (_) {
        // bare ESP32 (no STM32 / no loopback) never ACKs: keep the link up
        scanError = '已连接（设备暂无应答：未接 STM32 时属正常）';
      }
    } catch (e) {
      link = LinkState.disconnected;
      scanError = '连接失败：$e';
      notifyListeners();
    }
  }

  /// keep a foreground service alive while connected so alarms survive
  /// backgrounding (Android kills BLE otherwise)
  void _syncForeground() {
    if (link == LinkState.connected) {
      FlutterForegroundTask.startService(
        notificationTitle: 'C4F7N 监测运行中',
        notificationText: ' 连接保持 · 报警即时通知',
        notificationInitialRoute: '/',
      );
    } else {
      FlutterForegroundTask.stopService();
    }
  }

  void _onSample(Sample s) {
    conc = s.conc;
    if (conc > peak) peak = conc;
    final over = !muted && conc * 10 >= threshold;
    alarming = over;
    window.add(s);
    while (window.length > 60) {
      window.removeAt(0);
    }

    // async side-effects (fire and forget, errors ignored for UI flow)
    unawaited(_record(s, over));
    notifyListeners();
  }

  Future<void> _record(Sample s, bool over) async {
    try {
      // task curve capture
      if (_activeTaskId != null) {
        await store.appendPoint(_activeTaskId!, s.t, s.conc);
        if (s.conc > _taskPeak) _taskPeak = s.conc;
      }
      // alarm event lifecycle
      if (over && _openEventId == null) {
        _openEventId = await store.openEvent(deviceName, _activeTaskId);
        _overCount++;
        unawaited(AlarmNotifier.instance.alarm(deviceName, s.conc));
      }
      if (over && _openEventId != null) {
        await store.updateEventPeak(_openEventId!, s.conc);
      }
      if (!over && _openEventId != null) {
        await store.closeEvent(_openEventId!);
        _openEventId = null;
        unawaited(AlarmNotifier.instance.clearAll());
      }
    } catch (_) {
      // storage failures must not break measurement UI
    }
  }

  Future<void> startTask(
      {String site = '', String sectionNo = '', String note = ''}) async {
    if (_activeTaskId != null) return;
    _activeTaskId = await store.startTask(
      device: deviceName.isEmpty ? 'C4F7N' : deviceName,
      site: site,
      sectionNo: sectionNo,
      note: note,
      thrPpm: threshold / 10.0,
    );
    _overCount = 0;
    _taskPeak = 0;
    notifyListeners();
  }

  Future<void> stopTask() async {
    if (_activeTaskId == null) return;
    await store
        .endTask(_activeTaskId!, peakPpm: _taskPeak, overCount: _overCount);
    _activeTaskId = null;
    notifyListeners();
  }

  Future<void> togglePump() async {
    // setPump/setMute return the resulting device state (ACK echo)
    try {
      pumpOn = await _source.setPump(!pumpOn);
    } catch (_) {
      scanError = '泵命令无响应（未接 STM32 且未做环回短接时属正常）';
    }
    notifyListeners();
  }

  Future<void> toggleMute() async {
    try {
      muted = await _source.setMute(!muted);
    } catch (_) {
      scanError = '静音命令无响应（未接 STM32 且未做环回短接时属正常）';
    }
    notifyListeners();
  }

  Future<void> setThreshold(int ppmX10) async {
    try {
      if (await _source.writeThreshold(ppmX10)) {
        threshold = ppmX10;
      }
    } catch (_) {
      scanError = '阈值写入无响应（未接 STM32 且未做环回短接时属正常）';
    }
    notifyListeners();
  }

  Future<List<HistPoint>> readHistory(int start, int count) =>
      _source.readHistory(start, count);

  Future<({double concPpm, bool stable})> calPrepare() => _source.calPrepare();

  Future<bool> calConfirm() => _source.calConfirm();

  Future<int> factoryCal(int op, {bool confirm = false, double value = 0}) =>
      _source.factoryCal(op, confirm: confirm, value: value);

  Future<SelftestResult> selftest() => _source.selftest();

  Future<bool> unlockFactory(String password) async {
    // device SN suffix = 4 hex chars after "C4F7N-"
    final m = RegExp(r'C4F7N-([0-9A-Fa-f]{4})').firstMatch(deviceName);
    final hex = m?.group(1)?.toUpperCase() ?? '0001';
    factoryUnlocked = await _source.factoryAuth(password, hex);
    notifyListeners();
    return factoryUnlocked;
  }

  Future<void> disconnect() async {
    if (_activeTaskId != null) {
      await stopTask();
    }
    await _source.disconnect();
    link = LinkState.disconnected;
    factoryUnlocked = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    _linkSub?.cancel();
    super.dispose();
  }
}
