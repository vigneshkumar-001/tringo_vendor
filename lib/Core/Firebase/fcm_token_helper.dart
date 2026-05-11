import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tringo_vendor_new/Core/Const/app_logger.dart';

class FcmTokenHelper {
  static const _prefsKey = 'fcmToken';

  static String redact(String token) {
    final t = token.trim();
    if (t.isEmpty) return '';
    if (t.length <= 12) return '***';
    return '${t.substring(0, 6)}…${t.substring(t.length - 6)}';
  }

  static Future<String?> getTokenWithBackoff({
    List<int> delaysSeconds = const [1, 2, 4, 8],
  }) async {
    for (final seconds in delaysSeconds) {
      try {
        final token = await FirebaseMessaging.instance.getToken();
        if (token != null && token.trim().isNotEmpty) return token.trim();
      } catch (e) {
        AppLogger.log.w('FCM getToken failed (retry in ${seconds}s): $e');
      }
      await Future.delayed(Duration(seconds: seconds));
    }

    try {
      final token = await FirebaseMessaging.instance.getToken();
      return (token == null || token.trim().isEmpty) ? null : token.trim();
    } catch (e, st) {
      AppLogger.log.e('FCM getToken final failure: $e\n$st');
      return null;
    }
  }

  /// Ensures we have an FCM token in SharedPreferences and returns it.
  ///
  /// - If a token is already cached and [forceRefresh] is false, returns the cached token.
  /// - Otherwise tries to fetch a fresh token and updates the cache when it changes.
  static Future<String?> ensureCachedToken({bool forceRefresh = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final cached = (prefs.getString(_prefsKey) ?? '').trim();

    if (!forceRefresh && cached.isNotEmpty) return cached;

    final fresh = await getTokenWithBackoff();
    if (fresh == null || fresh.isEmpty) return cached.isNotEmpty ? cached : null;

    if (fresh != cached) {
      await prefs.setString(_prefsKey, fresh);
      // Do not log full token; redact if needed for debugging.
      AppLogger.log.i('FCM token updated: ${redact(fresh)}');
    }
    return fresh;
  }

  static Future<void> cacheToken(String token) async {
    final t = token.trim();
    if (t.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, t);
  }
}

