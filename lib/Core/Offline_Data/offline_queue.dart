import 'dart:convert';
import 'offline_db.dart';

class OfflineQueue {
  static Future<void> save(String apiName, Map<String, dynamic> payload) async {
    final db = await OfflineDB.db;

    await db.insert('api_queue', {
      'api_name': apiName,
      'payload': jsonEncode(payload),
      'created_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  static Future<List<Map<String, dynamic>>> getAll() async {
    final db = await OfflineDB.db;
    return db.query('api_queue', orderBy: 'id ASC');
  }

  static Future<void> delete(int id) async {
    final db = await OfflineDB.db;
    await db.delete('api_queue', where: 'id = ?', whereArgs: [id]);
  }
}
