import 'dart:convert';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class OfflineCategoryDb {
  static const _dbName = 'offline_sync.db'; // ✅ same db name ok
  static const _dbVersion = 3; // ✅ bump version
  static const _table = 'category_cache';

  static final OfflineCategoryDb _instance = OfflineCategoryDb._internal();
  factory OfflineCategoryDb() => _instance;
  OfflineCategoryDb._internal();

  Database? _db;

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
        // ✅ if you already create other tables in another file,
        // keep those in that onCreate. Here we only ensure our table exists.
        await _ensureTables(d);
      },
      onUpgrade: (d, oldV, newV) async {
        await _ensureTables(d);
      },
    );
  }

  Future<void> _ensureTables(Database d) async {
    await d.execute('''
      CREATE TABLE IF NOT EXISTS $_table (
        key TEXT PRIMARY KEY,
        json TEXT NOT NULL,
        updatedAt INTEGER NOT NULL
      );
    ''');
  }

  Future<void> saveCategoriesJson({
    required String key, // ex: "shop_categories"
    required Map<String, dynamic> json,
  }) async {
    final d = await db;
    await d.insert(
      _table,
      {
        'key': key,
        'json': jsonEncode(json),
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> getCategoriesJson(String key) async {
    final d = await db;
    final rows = await d.query(
      _table,
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );
    if (rows.isEmpty) return null;

    final raw = rows.first['json'] as String;
    return jsonDecode(raw) as Map<String, dynamic>;
  }
}
