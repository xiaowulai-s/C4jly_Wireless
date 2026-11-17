import 'package:flutter/material.dart';

import '../../state/device_controller.dart';

/// Connection / device management: BLE scan for C4F7N-* advertisers.
/// In mock mode the built-in fake device is offered as a one-tap connect.
class ConnectPage extends StatelessWidget {
  const ConnectPage({super.key, required this.controller});

  final DeviceController controller;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Scaffold(
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (controller.favorites.isNotEmpty) ...[
                Text('我的设备', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                ...controller.favorites.map(
                  (f) => Card(
                    child: ListTile(
                      leading: Icon(
                        Icons.star,
                        color: controller.deviceName == f['name'] &&
                                controller.link == LinkState.connected
                            ? cs.primary
                            : cs.outline,
                      ),
                      title: Text('${f['name']}'),
                      subtitle: Text(
                        '上一次使用：${DateTime.fromMillisecondsSinceEpoch((f['last_seen'] as num).toInt()).toString().substring(0, 16)}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FilledButton.tonal(
                            onPressed: controller.link == LinkState.connecting
                                ? null
                                : () => controller.connectFavorite(f),
                            child: Text(
                              controller.deviceName == f['name'] &&
                                      controller.link == LinkState.connected
                                  ? '当前'
                                  : '连接',
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () =>
                                controller.removeFavorite(f['remote_id'] as String),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
              Row(
                children: [
                  Text('附近设备', style: Theme.of(context).textTheme.titleMedium),
                  const Spacer(),
                  IconButton(
                    onPressed: controller.scanning ? null : controller.startScan,
                    icon: controller.scanning
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.refresh),
                  ),
                ],
              ),
              if (controller.scanError != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    controller.scanError!,
                    style: TextStyle(fontSize: 12, color: cs.error),
                  ),
                ),
              if (controller.hits.isEmpty && !controller.scanning)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      controller.isMock
                          ? '未发现设备。当前为模拟数据源，可直接使用下方模拟设备体验全部功能。\n\n真机联调：先在另一台手机打开“C4F7N模拟器”并开启广播，然后点右上角刷新。'
                          : '未发现 C4F7N-* 广播设备。\n请确认检漏仪/模拟器已开启广播，然后点右上角刷新。',
                      style: TextStyle(fontSize: 12, color: cs.outline),
                    ),
                  ),
                ),
              ...controller.hits.map(
                (h) => Card(
                  child: ListTile(
                    leading: Icon(
                      Icons.sensors,
                      color: controller.link == LinkState.connected &&
                              controller.deviceName == h.name
                          ? cs.primary
                          : cs.outline,
                    ),
                    title: Text(h.name),
                    subtitle: Text('信号 ${h.rssi} dBm'),
                    trailing: controller.link == LinkState.connected &&
                            controller.deviceName == h.name
                        ? FilledButton.tonal(
                            onPressed: controller.disconnect,
                            child: const Text('断开'),
                          )
                        : FilledButton(
                            onPressed: controller.link == LinkState.connecting
                                ? null
                                : () => controller.connectScanHit(h),
                            child: const Text('连接'),
                          ),
                  ),
                ),
              ),
              if (controller.isMock) ...[
                const SizedBox(height: 16),
                Text('模拟设备', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Card(
                  child: ListTile(
                    leading: Icon(
                      Icons.sensors,
                      color: controller.link == LinkState.connected
                          ? cs.primary
                          : cs.outline,
                    ),
                    title: const Text('C4F7N-0001（内置模拟）'),
                    subtitle: Text(
                      controller.link == LinkState.connected ? '已连接' : '无硬件时的体验入口',
                    ),
                    trailing: controller.link == LinkState.connected
                        ? FilledButton.tonal(
                            onPressed: controller.disconnect,
                            child: const Text('断开'),
                          )
                        : FilledButton(
                            onPressed: controller.connect,
                            child: const Text('连接'),
                          ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
