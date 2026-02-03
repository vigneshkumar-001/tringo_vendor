import 'dart:convert';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../offline_sync_models.dart';
import 'dart:convert';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../offline_sync_models.dart';

class OfflineSyncDb {
  static const _dbName = 'offline_sync.db';
  static const _dbVersion = 2;

  static final OfflineSyncDb _instance = OfflineSyncDb._internal();
  factory OfflineSyncDb() => _instance;
  OfflineSyncDb._internal();

  Database? _db;
  final _uuid = const Uuid();

  Future<Database> get db async {
    _db ??= await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final base = await getDatabasesPath();
    final path = join(base, _dbName);

    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: (d, v) async {
        await _createAll(d);
      },
      onUpgrade: (d, oldV, newV) async {
        await _createAll(d);
      },
    );
  }

  Future<void> _createAll(Database d) async {
    await d.execute('''
      CREATE TABLE IF NOT EXISTS registration_sessions (
        id TEXT PRIMARY KEY,
        status TEXT NOT NULL,
        lastError TEXT,
        createdAt INTEGER NOT NULL
      );
    ''');

    await d.execute('''
      CREATE TABLE IF NOT EXISTS sync_steps (
        id TEXT PRIMARY KEY,
        sessionId TEXT NOT NULL,
        stepType TEXT NOT NULL,
        status TEXT NOT NULL,
        payloadJson TEXT NOT NULL,
        resultJson TEXT,
        errorMessage TEXT,
        updatedAt INTEGER NOT NULL
      );
    ''');

    await d.execute('''
      CREATE INDEX IF NOT EXISTS idx_steps_session_stepType
      ON sync_steps(sessionId, stepType);
    ''');
  }

  Future<String> createSession() async {
    final d = await db;
    final id = _uuid.v4();

    await d.insert('registration_sessions', {
      'id': id,
      'status': enumName(SyncSessionStatus.pending),
      'lastError': null,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
    });

    return id;
  }

  /// ✅ NEW: return all sessions newest first (multiple shops)
  Future<List<String>> getAllSessionIds() async {
    final d = await db;
    final rows = await d.query(
      'registration_sessions',
      columns: ['id'],
      orderBy: 'createdAt DESC',
    );
    return rows.map((e) => (e['id'] ?? '').toString()).where((e) => e.isNotEmpty).toList();
  }

  Future<void> upsertStep({
    required String sessionId,
    required SyncStepType type,
    required Map<String, dynamic> payload,
  }) async {
    final d = await db;
    final stepType = enumName(type);

    final existing = await d.query(
      'sync_steps',
      where: 'sessionId = ? AND stepType = ?',
      whereArgs: [sessionId, stepType],
      limit: 1,
    );

    final now = DateTime.now().millisecondsSinceEpoch;

    if (existing.isEmpty) {
      await d.insert('sync_steps', {
        'id': _uuid.v4(),
        'sessionId': sessionId,
        'stepType': stepType,
        'status': enumName(SyncStepStatus.pending),
        'payloadJson': jsonEncode(payload),
        'resultJson': null,
        'errorMessage': null,
        'updatedAt': now,
      });
    } else {
      await d.update(
        'sync_steps',
        {
          'status': enumName(SyncStepStatus.pending),
          'payloadJson': jsonEncode(payload),
          'errorMessage': null,
          'updatedAt': now,
        },
        where: 'sessionId = ? AND stepType = ?',
        whereArgs: [sessionId, stepType],
      );
    }
  }

  Future<Map<String, dynamic>?> getPayload(String sessionId, SyncStepType type) async {
    final d = await db;
    final rows = await d.query(
      'sync_steps',
      where: 'sessionId = ? AND stepType = ?',
      whereArgs: [sessionId, enumName(type)],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return jsonDecode(rows.first['payloadJson'] as String) as Map<String, dynamic>;
  }

  Future<void> markSuccess({
    required String sessionId,
    required SyncStepType type,
    Map<String, dynamic>? result,
  }) async {
    final d = await db;
    await d.update(
      'sync_steps',
      {
        'status': enumName(SyncStepStatus.success),
        'resultJson': result == null ? null : jsonEncode(result),
        'errorMessage': null,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'sessionId = ? AND stepType = ?',
      whereArgs: [sessionId, enumName(type)],
    );
  }

  Future<void> markFailed({
    required String sessionId,
    required SyncStepType type,
    required String errorMessage,
  }) async {
    final d = await db;
    await d.update(
      'sync_steps',
      {
        'status': enumName(SyncStepStatus.failed),
        'errorMessage': errorMessage,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'sessionId = ? AND stepType = ?',
      whereArgs: [sessionId, enumName(type)],
    );
  }

  Future<String?> getStepStatus(String sessionId, SyncStepType type) async {
    final d = await db;
    final rows = await d.query(
      'sync_steps',
      columns: ['status'],
      where: 'sessionId = ? AND stepType = ?',
      whereArgs: [sessionId, enumName(type)],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first['status'] as String?;
  }
}


