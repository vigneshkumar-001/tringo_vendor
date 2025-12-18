import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class OfflineDB {
  static Database? _db;

  static Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  static Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'offline_queue.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE api_queue (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            api_name TEXT,
            payload TEXT,
            created_at INTEGER
          )
        ''');
      },
    );
  }
}
