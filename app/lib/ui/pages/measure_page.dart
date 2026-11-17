import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../state/device_controller.dart';

/// Big-number + 60 s curve + pump/mute + task recording.
class MeasurePage extends StatelessWidget {
  const MeasurePage({super.key, required this.controller});

  final DeviceController controller;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final alarming = controller.alarming;
    return Scaffold(
      backgroundColor: alarming ? cs.errorContainer : null,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    controller.link == LinkState.connected
                        ? '已连接 ${controller.deviceName}${controller.isMock ? '（模拟）' : ''}'
                        : '未连接',
                    style: TextStyle(
                      fontSize: 12,
                      color: alarming ? cs.onErrorContainer : cs.outline,
                    ),
                  ),
                  Text(
                    '阈值 ${(controller.threshold / 10).toStringAsFixed(1)} ppm',
                    style: TextStyle(
                      fontSize: 12,
                      color: alarming ? cs.onErrorContainer : cs.outline,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  controller.conc.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 72,
                    fontWeight: FontWeight.w500,
                    color: alarming ? cs.error : cs.primary,
                  ),
                ),
              ),
              Center(
                child: Text(
                  alarming ? 'ppm · 超限报警！' : 'ppm',
                  style: TextStyle(
                    fontSize: 13,
                    color: alarming ? cs.error : cs.outline,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _stat('峰值', controller.peak.toStringAsFixed(1), cs),
                  _stat('泵', controller.pumpOn ? '运行' : '停止', cs),
                  _stat('静音', controller.muted ? '开' : '关', cs),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: CustomPaint(
                    painter: _CurvePainter(
                      samples: controller.window,
                      thresholdPpm: controller.threshold / 10.0,
                      line: alarming ? cs.error : cs.primary,
                      alert: cs.error,
                      grid: cs.outlineVariant,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _taskBar(context, cs),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: controller.togglePump,
                      icon: Icon(
                          controller.pumpOn ? Icons.pause : Icons.play_arrow),
                      label: Text(controller.pumpOn ? '关泵' : '开泵'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: controller.toggleMute,
                      icon: const Icon(Icons.notifications_off),
                      label: Text(controller.muted ? '取消静音' : '静音'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _taskBar(BuildContext context, ColorScheme cs) {
    if (controller.recording) {
      return Row(
        children: [
          Icon(Icons.fiber_manual_record, size: 14, color: cs.error),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              '任务 #${controller.activeTaskId} 记录中（峰值 ${controller.peak.toStringAsFixed(1)} ppm）',
              style: TextStyle(fontSize: 12, color: cs.error),
            ),
          ),
          FilledButton.tonal(
            onPressed: () => showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('结束检测任务？'),
                content: Text(
                    '峰值 ${controller.peak.toStringAsFixed(1)} ppm，已记录到任务列表。'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('继续检测')),
                  FilledButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      controller.stopTask();
                    },
                    child: const Text('结束任务'),
                  ),
                ],
              ),
            ),
            child: const Text('结束检测'),
          ),
        ],
      );
    }
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: controller.link == LinkState.connected
            ? () => _showStartTaskDialog(context)
            : null,
        icon: const Icon(Icons.play_circle_outline),
        label: const Text('开始检测任务'),
      ),
    );
  }

  void _showStartTaskDialog(BuildContext context) {
    final site = TextEditingController();
    final section = TextEditingController();
    final note = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('新建检测任务'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: site,
              decoration: const InputDecoration(labelText: '站点名称'),
            ),
            TextField(
              controller: section,
              decoration: const InputDecoration(labelText: '间隔号/仓位'),
            ),
            TextField(
              controller: note,
              decoration: const InputDecoration(labelText: '备注'),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              controller.startTask(
                site: site.text,
                sectionNo: section.text,
                note: note.text,
              );
            },
            child: const Text('开始'),
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, String value, ColorScheme cs) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: cs.outline)),
        Text(value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class _CurvePainter extends CustomPainter {
  _CurvePainter({
    required this.samples,
    required this.thresholdPpm,
    required this.line,
    required this.alert,
    required this.grid,
  });

  final List<Sample> samples;
  final double thresholdPpm;
  final Color line;
  final Color alert;
  final Color grid;

  @override
  void paint(Canvas canvas, Size size) {
    if (samples.length < 2) return;
    final values = samples.map((s) => s.conc).toList();
    final maxV = math.max(
      values.reduce(math.max) * 1.2,
      thresholdPpm * 1.2,
    );
    final scaleY = size.height / (maxV == 0 ? 1 : maxV);
    final dx = size.width / (samples.length - 1);

    // threshold line
    final ty = size.height - thresholdPpm * scaleY;
    if (ty >= 0) {
      final p = Paint()
        ..color = alert
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke;
      canvas.drawDashLine(Offset(0, ty), Offset(size.width, ty), p);
    }

    final path = Path();
    for (var i = 0; i < samples.length; i++) {
      final x = i * dx;
      final y = size.height - values[i] * scaleY;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = line
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _CurvePainter old) => true;
}

extension _Dash on Canvas {
  void drawDashLine(Offset a, Offset b, Paint p) {
    const dash = 6.0;
    final d = (b - a);
    final len = d.distance;
    if (len == 0) return;
    final n = (len / (dash * 2)).floor();
    for (var i = 0; i < n; i++) {
      drawLine(
        a + d * (i * dash * 2 / len),
        a + d * ((i * dash * 2 + dash) / len),
        p,
      );
    }
  }
}
