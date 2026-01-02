import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Api/DataSource/api_data_source.dart';
import '../Const/app_logger.dart';
import 'contacts_service.dart';

class ContactsSyncManager {
  static bool _inFlight = false;

  static const _syncedKey = 'contacts_synced';
  static const _hashKey = 'contacts_sync_hash';

  /// Call this after OTP success (background)
  static Future<void> syncIfNeeded({
    required ApiDataSource api,
    String defaultDialCode = '+91',
    int maxContacts = 500,
    int chunkSize = 200,
  }) async {
    if (_inFlight) {
      AppLogger.log.i("⏳ Contacts sync already running, skip");
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final alreadySynced = prefs.getBool(_syncedKey) ?? false;

    if (alreadySynced) {
      AppLogger.log.i("✅ Contacts already synced (flag), skipping");
      return;
    }

    _inFlight = true;
    try {
      AppLogger.log.i("✅ Contact sync started");

      final contacts = await ContactsService.getAllContacts();
      AppLogger.log.i("📞 contacts fetched = ${contacts.length}");

      if (contacts.isEmpty) {
        AppLogger.log.w(
          "⚠️ Contacts empty OR permission denied. Not marking synced.",
        );
        return;
      }

      final limited = contacts.take(maxContacts).toList();

      final dial = _safeDialCode(defaultDialCode);
      final items =
          limited.map((c) {
            final phone = c.phone; // normalized 10-digit
            return {"name": c.name, "phone": "$dial$phone"};
          }).toList();

      // Optional hash skip
      final newHash = _hashItems(items);
      final oldHash = prefs.getString(_hashKey);
      if (oldHash != null && oldHash == newHash) {
        AppLogger.log.i(
          "✅ Contacts unchanged (hash), marking synced & skipping upload",
        );
        await prefs.setBool(_syncedKey, true);
        return;
      }

      for (var i = 0; i < items.length; i += chunkSize) {
        final chunk = items.sublist(
          i,
          (i + chunkSize > items.length) ? items.length : i + chunkSize,
        );

        final res = await api.syncContacts(items: chunk);

        res.fold(
          (l) => AppLogger.log.e("❌ batch sync failed: ${l.message}"),
          (r) => AppLogger.log.i(
            "✅ batch ok total=${r.data.total} inserted=${r.data.inserted} touched=${r.data.touched} skipped=${r.data.skipped}",
          ),
        );
      }

      await prefs.setString(_hashKey, newHash);
      await prefs.setBool(_syncedKey, true);

      AppLogger.log.i("✅ Contacts synced done: ${limited.length}");
    } catch (e) {
      AppLogger.log.e("❌ Contact sync failed: $e");
    } finally {
      _inFlight = false;
    }
  }

  static String _safeDialCode(String dial) {
    var d = dial.trim();
    if (d.isEmpty) return '+91';
    if (!d.startsWith('+')) d = '+$d';
    return d;
  }

  static String _hashItems(List<Map<String, dynamic>> items) {
    final normalized =
        items
            .map(
              (e) =>
                  "${(e['phone'] ?? '').toString()}|${(e['name'] ?? '').toString()}"
                      .toLowerCase(),
            )
            .toList()
          ..sort();

    final bytes = utf8.encode(normalized.join(','));
    return sha1.convert(bytes).toString();
  }
}
