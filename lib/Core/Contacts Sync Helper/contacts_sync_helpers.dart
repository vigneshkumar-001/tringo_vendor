import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tringo_vendor_new/Core/Const/app_logger.dart';

import '../../Presentation/Login Screen/Controller/login_notifier.dart';
import '../contacts/contacts_service.dart';


class ContactsSyncHelper {
  static Future<void> syncOnce(Ref ref) async {
    final prefs = await SharedPreferences.getInstance();
    final alreadySynced = prefs.getBool('contacts_synced') ?? false;

    if (alreadySynced) {
      AppLogger.log.i("✅ Contacts already synced, skipping");
      return;
    }

    final contacts = await ContactsService.getAllContacts();
    AppLogger.log.i("📞 contacts fetched = ${contacts.length}");

    if (contacts.isEmpty) {
      AppLogger.log.w("⚠️ No contacts OR permission denied. Will retry later.");
      return; // IMPORTANT: synced flag set pannadheenga
    }

    final limited = contacts.take(500).toList(); // you decide limit
    final items = limited
        .map((c) => {"name": c.name, "phone": "+91${c.phone}"})
        .toList();

    final api = ref.read(apiDataSourceProvider);

    final result = await api.syncContacts(items: items);

    result.fold((l) => AppLogger.log.e("❌ batch sync failed: ${l.message}"), (
        r,
        ) async {
      await prefs.setBool('contacts_synced', true);
      AppLogger.log.i(
        "✅ batch sync done total=${r.data.total} inserted=${r.data.inserted} touched=${r.data.touched} skipped=${r.data.skipped}",
      );
    });
  }
}
