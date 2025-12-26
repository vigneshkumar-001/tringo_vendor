import 'dart:convert';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import 'offline_sync_models.dart';

class OfflineSyncDb {
  static const _dbName = 'offline_sync.db';
  static const _dbVersion = 1;

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
        await d.execute('''
          CREATE TABLE registration_sessions (
            id TEXT PRIMARY KEY,
            status TEXT NOT NULL,
            lastError TEXT,
            createdAt INTEGER NOT NULL
          );
        ''');

        await d.execute('''
          CREATE TABLE sync_steps (
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
      },
    );
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

  Future<void> addOwnerStep({
    required String sessionId,
    required Map<String, dynamic> payload,
  }) async {
    final d = await db;
    final id = _uuid.v4();

    await d.insert('sync_steps', {
      'id': id,
      'sessionId': sessionId,
      'stepType': enumName(SyncStepType.owner),
      'status': enumName(SyncStepStatus.pending),
      'payloadJson': jsonEncode(payload),
      'resultJson': null,
      'errorMessage': null,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    });
  }
  Future<Map<String, dynamic>?> getOwnerPayload(String sessionId) async {
    final d = await db;

    final rows = await d.query(
      'sync_steps',
      where: 'sessionId = ? AND stepType = ?',
      whereArgs: [sessionId, 'owner'],
      limit: 1,
    );

    if (rows.isEmpty) return null;

    final payloadJson = rows.first['payloadJson'] as String;
    return jsonDecode(payloadJson) as Map<String, dynamic>;
  }

}
