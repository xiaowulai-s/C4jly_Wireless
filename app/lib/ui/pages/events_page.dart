import 'package:flutter/material.dart';

import '../../data/db.dart';

/// Alarm event list (captured client-side; merges 0x60 in Phase 4).
class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  List<Map<String, Object?>> _events = [];

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    _events = await TaskStore.instance.listEvents();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('报警事件')),
      body: _events.isEmpty
          ? const Center(child: Text('暂无报警事件'))
          : RefreshIndicator(
              onRefresh: _reload,
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _events.length,
                itemBuilder: (context, i) {
                  final e = _events[i];
                  final open = e['ended_at'] == null;
                  final start = DateTime.fromMillisecondsSinceEpoch(
                      (e['started_at'] as num).toInt());
                  return Card(
                    child: ListTile(
                      leading: Icon(
                        open
                            ? Icons.warning_amber
                            : Icons.notification_important,
                        color: cs.error,
                      ),
                      title: Text('峰值 ${e['peak_ppm']} ppm'),
                      subtitle: Text(
                        '${start.toString().substring(0, 19)}\n'
                        '设备 ${e['device']} · ${open ? '持续中' : '已结束'}',
                      ),
                      isThreeLine: true,
                    ),
                  );
                },
              ),
            ),
    );
  }
}
