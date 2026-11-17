import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/db.dart';
import '../../data/report.dart';

/// Detection task archive: list / detail / PDF export / delete + summary.
class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  List<Map<String, Object?>> _tasks = [];

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    _tasks = await TaskStore.instance.listTasks();
    if (mounted) setState(() {});
  }

  String _fmt(int? ms) => ms == null
      ? '-'
      : DateTime.fromMillisecondsSinceEpoch(ms).toString().substring(0, 16);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('检测任务'),
        actions: [
          IconButton(
            tooltip: '汇总与导出',
            icon: const Icon(Icons.analytics_outlined),
            onPressed: () => _openSummary(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _reload,
        child: _tasks.isEmpty
            ? ListView(
                children: const [
                  SizedBox(height: 120),
                  Center(child: Text('暂无检测任务\n在测量页点“开始检测任务”创建')),
                ],
              )
            : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _tasks.length,
                itemBuilder: (context, i) {
                  final t = _tasks[i];
                  final running = t['ended_at'] == null;
                  return Card(
                    child: ListTile(
                      leading: Icon(
                        running
                            ? Icons.fiber_manual_record
                            : Icons.task_alt,
                        color: running ? cs.error : cs.primary,
                      ),
                      title: Text(
                        '${t['site']!.toString().isEmpty ? '未命名站点' : t['site']}'
                        '${t['section_no']!.toString().isEmpty ? '' : ' · ${t['section_no']}'}',
                      ),
                      subtitle: Text(
                        '#${t['id']} ${_fmt(t['started_at'] as int?)}\n'
                        '峰值 ${t['peak_ppm']} ppm · 超限 ${t['over_count']} 次',
                      ),
                      isThreeLine: true,
                      trailing: running
                          ? const Chip(label: Text('进行中'))
                          : const Icon(Icons.chevron_right),
                      onTap: running ? null : () => _openDetail(t),
                    ),
                  );
                },
              ),
      ),
    );
  }

  void _openSummary(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TaskSummaryPage()),
    );
  }

  void _openDetail(Map<String, Object?> t) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('任务 #${t['id']} 详情',
                  style: Theme.of(ctx).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(
                '设备：${t['device']}\n站点：${t['site']} · ${t['section_no']}\n'
                '备注：${t['note']}\n开始：${_fmt(t['started_at'] as int?)}\n'
                '结束：${_fmt(t['ended_at'] as int?)}\n'
                '峰值：${t['peak_ppm']} ppm（阈值 ${t['thr_ppm']}）\n'
                '超限：${t['over_count']} 次',
                style: const TextStyle(height: 1.6),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('导出 PDF 检测报告'),
                onPressed: () async {
                  final events =
                      await TaskStore.instance.listEvents();
                  final related = events
                      .where((e) => e['task_id'] == t['id'])
                      .toList();
                  await shareReport(ReportData(
                    task: t,
                    device: '${t['device']}',
                    events: related,
                  ));
                },
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                icon: const Icon(Icons.delete_outline),
                label: const Text('删除任务'),
                onPressed: () async {
                  Navigator.pop(ctx);
                  await TaskStore.instance.deleteTask(t['id'] as int);
                  _reload();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Multi-task aggregate statistics + batch Excel export.
class TaskSummaryPage extends StatefulWidget {
  const TaskSummaryPage({super.key});

  @override
  State<TaskSummaryPage> createState() => _TaskSummaryPageState();
}

class _TaskSummaryPageState extends State<TaskSummaryPage> {
  List<Map<String, Object?>> _tasks = [];
  List<Map<String, Object?>> _events = [];
  bool _exporting = false;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    _tasks = await TaskStore.instance.listTasks();
    _events = await TaskStore.instance.listEvents();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final s = summarize(_tasks);
    return Scaffold(
      appBar: AppBar(title: const Text('汇总与导出')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _stat('任务数', '${s['count']}', cs),
              _stat('进行中', '${s['running']}', cs),
              _stat('超限次数', '${s['over']}', cs),
              _stat('历史峰值', '${s['peak']}', cs),
            ],
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            icon: _exporting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.table_view),
            label: const Text('导出 Excel（汇总+事件+逐任务曲线）'),
            onPressed: _exporting ? null : _exportExcel,
          ),
          const SizedBox(height: 16),
          Text('报警事件（最近 200 条）',
              style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          ..._events.take(50).map((e) => Card(
                child: ListTile(
                  dense: true,
                  leading: Icon(Icons.warning_amber, color: cs.error),
                  title: Text('峰值 ${e['peak_ppm']} ppm'),
                  subtitle: Text(
                    '${DateTime.fromMillisecondsSinceEpoch((e['started_at'] as num).toInt()).toString().substring(0, 19)} · ${e['device']}',
                  ),
                ),
              )),
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

  Future<void> _exportExcel() async {
    setState(() => _exporting = true);
    try {
      final f = await generateTasksExcel(_tasks, _events);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('已生成 ${f.uri.pathSegments.last}'),
      ));
      // hand the file to the system share sheet
      await Share.shareXFiles(
        [XFile(f.path, mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')],
        text: 'C4F7N 检测任务数据',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('导出失败：$e')));
      }
    }
    if (mounted) setState(() => _exporting = false);
  }
}

