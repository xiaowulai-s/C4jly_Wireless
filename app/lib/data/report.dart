import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

/// Detection report PDF (spec §7.4 page 7): stats table + curve + events.
class ReportData {
  ReportData({
    required this.task,
    required this.device,
    required this.events,
  });

  final Map<String, Object?> task;
  final String device;
  final List<Map<String, Object?>> events;

  List<(DateTime, double)> get points {
    final raw = jsonDecode(task['points'] as String) as List;
    return raw
        .map((e) => (
              DateTime.fromMillisecondsSinceEpoch((e[0] as num).toInt()),
              (e[1] as num).toDouble(),
            ))
        .toList();
  }

  double get threshold =>
      (task['thr_ppm'] as num?)?.toDouble() ?? 50.0;

  DateTime get startedAt =>
      DateTime.fromMillisecondsSinceEpoch((task['started_at'] as num).toInt());
  DateTime? get endedAt => task['ended_at'] == null
      ? null
      : DateTime.fromMillisecondsSinceEpoch((task['ended_at'] as num).toInt());
}

Future<File> generateReportPdf(ReportData data) async {
  final doc = pw.Document();
  final pts = data.points;
  final thr = data.threshold;

  pw.Widget curveChart() {
    if (pts.length < 2) {
      return pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 8),
        child: pw.Text('无采样数据'),
      );
    }
    final maxV = math.max(
      pts.map((e) => e.$2).reduce(math.max) * 1.2,
      thr * 1.2,
    );
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.CustomPaint(
          size: const PdfPoint(500, 200),
          painter: (canvas, size) {
            final w = size.x;
            final h = size.y;
            final scaleY = h / maxV;
            final dx = w / (pts.length - 1);

            // threshold dashed line
            canvas
              ..setLineWidth(1)
              ..setLineDashPattern(const [4, 3], 0)
              ..setStrokeColor(PdfColor.fromInt(0xFFE24B4A))
              ..drawLine(0, h - thr * scaleY, w, h - thr * scaleY)
              ..strokePath();

            // solid curve
            canvas
              ..setLineWidth(1.2)
              ..setLineDashPattern(const [], 0)
              ..setStrokeColor(PdfColor.fromInt(0xFF0F6E56));
            for (var i = 0; i < pts.length; i++) {
              final x = i * dx;
              final y = h - pts[i].$2 * scaleY;
              if (i == 0) {
                canvas.moveTo(x, y);
              } else {
                canvas.lineTo(x, y);
              }
            }
            canvas.strokePath();

            // baseline
            canvas
              ..setStrokeColor(PdfColors.grey400)
              ..setLineWidth(0.5)
              ..drawLine(0, 0, w, 0)
              ..strokePath();
          },
        ),
      ],
    );
  }

  String fmt(int? ms) => ms == null
      ? '-'
      : DateTime.fromMillisecondsSinceEpoch(ms).toString().substring(0, 19);

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      build: (ctx) => [
        pw.Header(
          child: pw.Text('C4F7N 检测报告',
              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
        ),
        pw.Table.fromTextArray(
          headers: ['项目', '内容'],
          data: [
            ['设备', data.device],
            ['站点', '${data.task['site']}'],
            ['检测间隔号', '${data.task['section_no']}'],
            ['备注', '${data.task['note']}'],
            ['开始时间', fmt(data.task['started_at'] as int?)],
            ['结束时间', fmt(data.task['ended_at'] as int?)],
            ['峰值', '${data.task['peak_ppm']} ppm'],
            ['报警阈值', '$thr ppm'],
            ['超限次数', '${data.task['over_count']}'],
            ['采样点数', '${pts.length}'],
          ],
        ),
        pw.SizedBox(height: 12),
        pw.Text('浓度曲线',
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 6),
        curveChart(),
        pw.SizedBox(height: 12),
        if (data.events.isNotEmpty) ...[
          pw.Text('报警事件',
              style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
          pw.Table.fromTextArray(
            headers: ['开始时间', '结束时间', '峰值 ppm'],
            data: data.events
                .map((e) => [
                      fmt(e['started_at'] as int?),
                      fmt(e['ended_at'] as int?),
                      '${e['peak_ppm']}',
                    ])
                .toList(),
          ),
        ],
        pw.SizedBox(height: 24),
        pw.Text('报告生成：${DateTime.now().toString().substring(0, 19)}',
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey)),
      ],
    ),
  );

  final dir = await getTemporaryDirectory();
  final file = File(
      '${dir.path}/C4F7N_report_task${data.task['id']}_${DateTime.now().millisecondsSinceEpoch}.pdf');
  await file.writeAsBytes(await doc.save());
  return file;
}

Future<void> shareReport(ReportData data) async {
  final f = await generateReportPdf(data);
  await Printing.sharePdf(
      bytes: f.readAsBytesSync(),
      filename: f.uri.pathSegments.last);
}

/* ==================== Excel export ==================== */

/// Multi-task summary workbook: overview sheet + per-task curve sheets.
Future<File> generateTasksExcel(
  List<Map<String, Object?>> tasks,
  List<Map<String, Object?>> events,
) async {
  final excel = Excel.createExcel();
  final sheet = excel['汇总'];
  excel.setDefaultSheet('汇总');

  sheet.appendRow([
    TextCellValue('任务号'), TextCellValue('设备'), TextCellValue('站点'),
    TextCellValue('间隔号'), TextCellValue('开始时间'), TextCellValue('结束时间'),
    TextCellValue('峰值 ppm'), TextCellValue('报警阈值'), TextCellValue('超限次数'),
  ]);
  String fmt(int? ms) => ms == null
      ? '-'
      : DateTime.fromMillisecondsSinceEpoch(ms).toString().substring(0, 19);
  for (final t in tasks) {
    sheet.appendRow([
      TextCellValue('${t['id']}'), TextCellValue('${t['device']}'),
      TextCellValue('${t['site']}'), TextCellValue('${t['section_no']}'),
      TextCellValue(fmt(t['started_at'] as int?)),
      TextCellValue(fmt(t['ended_at'] as int?)),
      DoubleCellValue((t['peak_ppm'] as num?)?.toDouble() ?? 0),
      TextCellValue('${t['thr_ppm']}'),
      IntCellValue((t['over_count'] as num?)?.toInt() ?? 0),
    ]);
  }

  // alarm events sheet
  final es = excel['报警事件'];
  es.appendRow([
    TextCellValue('设备'), TextCellValue('开始时间'), TextCellValue('结束时间'),
    TextCellValue('峰值 ppm'), TextCellValue('关联任务'),
  ]);
  for (final e in events) {
    es.appendRow([
      TextCellValue('${e['device']}'),
      TextCellValue(fmt(e['started_at'] as int?)),
      TextCellValue(fmt(e['ended_at'] as int?)),
      DoubleCellValue((e['peak_ppm'] as num?)?.toDouble() ?? 0),
      TextCellValue('${e['task_id'] ?? '-'}'),
    ]);
  }

  // per-task curve sheets (capped to first 30 tasks to keep file sane)
  var n = 0;
  for (final t in tasks) {
    if (n >= 30) break;
    n++;
    final pts = jsonDecode(t['points'] as String) as List;
    if (pts.isEmpty) continue;
    final cs = excel['曲线#${t['id']}'];
    cs.appendRow([TextCellValue('时间'), TextCellValue('ppm')]);
    for (final e in pts) {
      cs.appendRow([
        TextCellValue(DateTime.fromMillisecondsSinceEpoch((e[0] as num).toInt())
            .toString()
            .substring(11, 19)),
        DoubleCellValue((e[1] as num).toDouble()),
      ]);
    }
  }

  final dir = await getTemporaryDirectory();
  final file = File(
      '${dir.path}/C4F7N_tasks_${DateTime.now().millisecondsSinceEpoch}.xlsx');
  await excel.save(fileName: file.path);
  return file;
}

/// summary stats for the aggregate page
Map<String, num> summarize(List<Map<String, Object?>> tasks) {
  var over = 0;
  double peak = 0;
  var running = 0;
  for (final t in tasks) {
    over += (t['over_count'] as num?)?.toInt() ?? 0;
    final p = (t['peak_ppm'] as num?)?.toDouble() ?? 0;
    if (p > peak) peak = p;
    if (t['ended_at'] == null) running++;
  }
  return {
    'count': tasks.length,
    'running': running,
    'over': over,
    'peak': peak,
  };
}
