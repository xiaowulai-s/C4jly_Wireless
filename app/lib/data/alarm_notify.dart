import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Alarm system notifications (Android 13+ needs POST_NOTIFICATIONS runtime
/// permission, requested together with BLE perms in DeviceController).
class AlarmNotifier {
  AlarmNotifier._();
  static final AlarmNotifier instance = AlarmNotifier._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;
  int _seq = 100;

  Future<void> init() async {
    if (_ready) return;
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _plugin.initialize(
      const InitializationSettings(android: android),
    );
    _ready = true;
  }

  Future<void> alarm(String device, double ppm) async {
    if (!_ready) return;
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        'c4f7n_alarm',
        '浓度报警',
        channelDescription: 'C4F7N 浓度超限报警通知',
        importance: Importance.max,
        priority: Priority.max,
        fullScreenIntent: false,
        ongoing: true,
        autoCancel: false,
      ),
    );
    await _plugin.show(
      _seq++,
      '⚠️ 浓度报警 · $device',
      '当前 ${ppm.toStringAsFixed(1)} ppm 超过阈值，请及时处理',
      details,
    );
  }

  /// ongoing alarm cleared (concentration back under threshold)
  Future<void> clearAll() async {
    if (!_ready) return;
    await _plugin.cancelAll();
  }
}
