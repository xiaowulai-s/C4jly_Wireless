import 'dart:math' as math;

import 'package:c4f7n_protocol/c4f7n_protocol.dart';
import 'package:flutter/material.dart';

import '../../state/device_controller.dart';

/// Device flash history replay via protocol 0x40 paginated reads.
class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key, required this.controller});

  final DeviceController controller;

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final List<HistPoint> _points = [];
  bool _loading = false;
  bool _reachedEnd = false;
  String? _error;
  final _scroll = ScrollController();

  Future<void> _loadMore() async {
    if (_loading || _reachedEnd) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final batch =
          await widget.controller.readHistory(_points.length, 200);
      if (batch.isEmpty) {
        _reachedEnd = true;
      } else {
        _points.addAll(batch);
      }
    } catch (e) {
      _error = '读取失败：$e';
    }
    _loading = false;
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _loadMore();
    _scroll.addListener(() {
      if (_scroll.position.pixels >
          _scroll.position.maxScrollExtent - 400) {
        _loadMore();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text('设备历史（已载 ${_points.length} 点）')),
      body: Column(
        children: [
          if (_error != null)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(_error!, style: TextStyle(color: cs.error, fontSize: 12)),
            ),
          SizedBox(
            height: 220,
            width: double.infinity,
            child: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: CustomPaint(painter: _HistPainter(_points, cs.primary)),
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              itemCount: _points.length + (_loading ? 1 : 0),
              itemBuilder: (context, i) {
                if (i >= _points.length) {
                  return const Padding(
                    padding: EdgeInsets.all(12),
                    child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  );
                }
                final pt = _points[_points.length - 1 - i]; // newest first
                final ts = DateTime.fromMillisecondsSinceEpoch(pt.ts * 1000);
                return ListTile(
                  dense: true,
                  title: Text('${pt.ppm / 10} ppm'),
                  subtitle: Text(ts.toString().substring(0, 19)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _HistPainter extends CustomPainter {
  _HistPainter(this.points, this.color);
  final List<HistPoint> points;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;
    final values = points.map((p) => p.ppm / 10.0).toList();
    final maxV = math.max(values.reduce(math.max) * 1.2, 1.0);
    final scaleY = size.height / maxV;
    final dx = size.width / (points.length - 1);
    final path = Path();
    for (var i = 0; i < points.length; i++) {
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
        ..color = color
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(covariant _HistPainter old) => old.points != points;
}
