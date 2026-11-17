import 'dart:convert';

import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart' show ConflictAlgorithm;

/// Local business store: detection tasks + alarm events (spec §7.5).
/// Data lives on the phone; the device flash keeps raw history untouched.
class TaskStore {
  TaskStore._();
  static final TaskStore instance = TaskStore._();

  Database? _db;

  Future<Database> get db async {
    _db ??= await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final dir = await getDatabasesPath();
    return openDatabase(
      p.join(dir, 'c4f7n_app.db'),
      version: 2,
      onCreate: (db, v) async {
        await _createV2(db);
      },
      onUpgrade: (db, oldV, newV) async {
        if (oldV < 2) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS devices(
              remote_id TEXT PRIMARY KEY,
              name TEXT NOT NULL,
              last_seen INTEGER NOT NULL DEFAULT 0
            )
          ''');
        }
      },
    );
  }

  Future<void> _createV2(Database db) async {
    await db.execute('''
      CREATE TABLE tasks(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        device TEXT NOT NULL,
        site TEXT NOT NULL DEFAULT '',
        section_no TEXT NOT NULL DEFAULT '',
        note TEXT NOT NULL DEFAULT '',
        started_at INTEGER NOT NULL,
        ended_at INTEGER,
        peak_ppm REAL NOT NULL DEFAULT 0,
        over_count INTEGER NOT NULL DEFAULT 0,
        thr_ppm REAL NOT NULL DEFAULT 50,
        points TEXT NOT NULL DEFAULT '[]'
      )
    ''');
    await db.execute('''
      CREATE TABLE events(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        device TEXT NOT NULL,
        task_id INTEGER,
        started_at INTEGER NOT NULL,
        ended_at INTEGER,
        peak_ppm REAL NOT NULL DEFAULT 0
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS devices(
        remote_id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        last_seen INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  // ---- favorite devices (switch-style multi-device) ----

  Future<void> saveDevice(String remoteId, String name) async {
    final db = await this.db;
    await db.insert(
      'devices',
      {'remote_id': remoteId, 'name': name, 'last_seen': DateTime.now().millisecondsSinceEpoch},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, Object?>>> listDevices() async {
    final db = await this.db;
    return db.query('devices', orderBy: 'last_seen DESC');
  }

  Future<void> deleteDevice(String remoteId) async {
    final db = await this.db;
    await db.delete('devices', where: 'remote_id = ?', whereArgs: [remoteId]);
  }

  // ---- tasks ----

  Future<int> startTask({
    required String device,
    String site = '',
    String sectionNo = '',
    String note = '',
    double thrPpm = 50.0,
  }) async {
    final db = await this.db;
    return db.insert('tasks', {
      'device': device,
      'site': site,
      'section_no': sectionNo,
      'note': note,
      'started_at': DateTime.now().millisecondsSinceEpoch,
      'thr_ppm': thrPpm,
      'points': '[]',
    });
  }

  Future<void> appendPoint(int taskId, DateTime t, double conc) async {
    final db = await this.db;
    final rows = await db.query('tasks',
        columns: ['points', 'peak_ppm'], where: 'id = ?', whereArgs: [taskId]);
    if (rows.isEmpty) return;
    final points = (jsonDecode(rows.first['points'] as String) as List).toList();
    points.add([t.millisecondsSinceEpoch, double.parse(conc.toStringAsFixed(2))]);
    final peak = (rows.first['peak_ppm'] as num).toDouble();
    await db.update(
      'tasks',
      {'points': jsonEncode(points)},
      where: 'id = ?',
      whereArgs: [taskId],
    );
    if (conc > peak) {
      await db.update('tasks', {'peak_ppm': conc},
          where: 'id = ?', whereArgs: [taskId]);
    }
  }

  Future<void> endTask(
    int taskId, {
    required double peakPpm,
    required int overCount,
  }) async {
    final db = await this.db;
    await db.update(
      'tasks',
      {
        'ended_at': DateTime.now().millisecondsSinceEpoch,
        'peak_ppm': peakPpm,
        'over_count': overCount,
      },
      where: 'id = ?',
      whereArgs: [taskId],
    );
  }

  Future<List<Map<String, Object?>>> listTasks() async {
    final db = await this.db;
    return db.query('tasks', orderBy: 'id DESC');
  }

  Future<Map<String, Object?>?> getTask(int id) async {
    final db = await this.db;
    final rows =
        await db.query('tasks', where: 'id = ?', whereArgs: [id], limit: 1);
    return rows.isEmpty ? null : rows.first;
  }

  Future<void> deleteTask(int id) async {
    final db = await this.db;
    await db.delete('events', where: 'task_id = ?', whereArgs: [id]);
    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  // ---- alarm events ----

  Future<int> openEvent(String device, int? taskId) async {
    final db = await this.db;
    return db.insert('events', {
      'device': device,
      'task_id': taskId,
      'started_at': DateTime.now().millisecondsSinceEpoch,
      'peak_ppm': 0,
    });
  }

  Future<void> updateEventPeak(int eventId, double peak) async {
    final db = await this.db;
    await db.rawUpdate(
      'UPDATE events SET peak_ppm = MAX(peak_ppm, ?) WHERE id = ?',
      [peak, eventId],
    );
  }

  Future<void> closeEvent(int eventId) async {
    final db = await this.db;
    await db.update('events', {
      'ended_at': DateTime.now().millisecondsSinceEpoch,
    }, where: 'id = ?', whereArgs: [eventId]);
  }

  Future<List<Map<String, Object?>>> listEvents() async {
    final db = await this.db;
    return db.query('events', orderBy: 'id DESC', limit: 200);
  }
}
