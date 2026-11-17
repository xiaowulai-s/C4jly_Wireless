import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// First-launch quick guide (shown once; resettable from settings).
Future<void> showGuideIfNeeded(BuildContext context) async {
  try {
    final sp = await SharedPreferences.getInstance();
    if (sp.getBool('guide_seen') == true) return;
    await showGuide(context);
    await sp.setBool('guide_seen', true);
  } catch (_) {
    // never block the app on guide storage failures
  }
}

Future<void> showGuide(BuildContext context) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      title: const Text('欢迎使用 C4F7N 检漏仪'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          ListTile(
            leading: Icon(Icons.sensors, color: Colors.teal),
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: Text('① 设备页连接'),
            subtitle: Text('扫描附近的 C4F7N-* 设备并连接，模拟设备可先体验'),
          ),
          ListTile(
            leading: Icon(Icons.speed, color: Colors.teal),
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: Text('② 测量页监测'),
            subtitle: Text('实时浓度/曲线，开泵/静音一键操作，可录制检测任务'),
          ),
          ListTile(
            leading: Icon(Icons.warning_amber, color: Colors.orange),
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: Text('③ 报警通知'),
            subtitle: Text('连接保持期间，浓度超限会推送系统通知（请允许通知权限）'),
          ),
        ],
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('开始使用'),
        ),
      ],
    ),
  );
}

/// GuidePage widget (used by guide route inside dialogs too)
class GuidePage extends StatelessWidget {
  const GuidePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('使用引导')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ListTile(
            leading: Icon(Icons.sensors),
            title: Text('① 设备页连接'),
            subtitle: Text('扫描附近的 C4F7N-* 设备并连接，模拟设备可先体验'),
          ),
          ListTile(
            leading: Icon(Icons.speed),
            title: Text('② 测量页监测'),
            subtitle: Text('实时浓度/曲线，开泵/静音一键操作，可录制检测任务'),
          ),
          ListTile(
            leading: Icon(Icons.assignment),
            title: Text('③ 任务与报告'),
            subtitle: Text('任务归档、PDF/Excel 导出、报警事件与历史回放'),
          ),
        ],
      ),
    );
  }
}
