import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../state/device_controller.dart';
import 'events_page.dart';
import 'guide_page.dart';
import 'history_page.dart';

/// Settings: alarm threshold (0x12) + zero-cal wizard (0x30) + entries.
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key, required this.controller});

  final DeviceController controller;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final TextEditingController _thr = TextEditingController(
      text: (widget.controller.threshold / 10).toStringAsFixed(1));

  Future<void> _save() async {
    final v = double.tryParse(_thr.text);
    if (v == null || v <= 0 || v > 6000) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('阈值需在 0.1 ~ 6000 ppm 之间')),
      );
      return;
    }
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认修改报警阈值'),
        content: Text('新阈值：${v.toStringAsFixed(1)} ppm'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('确认')),
        ],
      ),
    );
    if (ok == true) {
      await widget.controller.setThreshold((v * 10).round());
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('阈值已保存')));
      }
    }
  }

  /// Zero-point calibration wizard (protocol 0x30 two-step).
  Future<void> _zeroCalWizard() async {
    final c = widget.controller;
    if (c.link != LinkState.connected) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('请先连接设备')));
      return;
    }
    var stepText = '步骤 1/2：准备读数…';
    final done = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) {
          Future<void> run() async {
            final prep = await c.calPrepare();
            stepText = prep.stable
                ? '步骤 1/2：读数 ${prep.concPpm.toStringAsFixed(1)} ppm，已稳定。确认执行零点校准？'
                : '步骤 1/2：读数 ${prep.concPpm.toStringAsFixed(1)} ppm，不稳定，请等待气体排空。';
            setSt(() {});
          }

          run();
          return AlertDialog(
            title: const Text('零点校准向导'),
            content: Text(stepText),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('取消')),
              TextButton(
                onPressed: () => run(),
                child: const Text('重读'),
              ),
              FilledButton(
                onPressed: () async {
                  setSt(() => stepText = '步骤 2/2：执行校准中…');
                  final ok = await c.calConfirm();
                  setSt(() =>
                      stepText = ok ? '校准成功，已保存标定原始值。' : '校准失败（读数不稳或传感器异常）');
                  await Future.delayed(const Duration(seconds: 1));
                  if (ctx.mounted) Navigator.pop(ctx, ok);
                },
                child: const Text('执行校准'),
              ),
            ],
          );
        },
      ),
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(done == true ? '零点校准完成' : '零点校准未完成'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 16),
          Text('外观与帮助', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.dark_mode),
                  title: const Text('深色模式'),
                  trailing: SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'system', label: Icon(Icons.settings_suggest)),
                      ButtonSegment(value: 'light', label: Icon(Icons.light_mode)),
                      ButtonSegment(value: 'dark', label: Icon(Icons.dark_mode)),
                    ],
                    selected: {
                      widget.controller.themeMode == ThemeMode.light
                          ? 'light'
                          : widget.controller.themeMode == ThemeMode.dark
                              ? 'dark'
                              : 'system'
                    },
                    onSelectionChanged: (v) => widget.controller.setThemeMode(
                        v.first == 'light'
                            ? ThemeMode.light
                            : v.first == 'dark'
                                ? ThemeMode.dark
                                : ThemeMode.system),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.help_outline),
                  title: const Text('重新查看使用引导'),
                  onTap: () => showGuide(context),
                ),
                ListTile(
                  leading: const Icon(Icons.restart_alt),
                  title: const Text('重置引导（下次启动显示）'),
                  onTap: () async {
                    final sp = await SharedPreferences.getInstance();
                    await sp.setBool('guide_seen', false);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('已重置，下次启动将显示引导')));
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text('报警设置', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('报警阈值（ppm）'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _thr,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: '50.0',
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      FilledButton(onPressed: _save, child: const Text('保存')),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('数据与维护', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.cleaning_services),
                  title: const Text('零点校准向导'),
                  subtitle: const Text('两步确认流程（0x30）'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _zeroCalWizard,
                ),
                ListTile(
                  leading: const Icon(Icons.history),
                  title: const Text('设备历史回放'),
                  subtitle: const Text('从设备 Flash 分页读取（0x40）'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => HistoryPage(controller: widget.controller),
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.warning_amber),
                  title: const Text('报警事件'),
                  subtitle: const Text('超阈值事件列表'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const EventsPage()),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
