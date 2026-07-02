import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'registration_product_seivice.dart';
import 'registration_session.dart';

/// Centralised session reset.
///
/// A bare `prefs.clear()` on logout / account deletion left the previous user's
/// in-memory Riverpod state and registration singletons alive, which then
/// leaked into the next login. `forceLogout()` additionally rebuilds the root
/// ProviderScope so every provider (including the router) is recreated; the
/// router restarts at the splash screen, which routes to login when there is no
/// token.
class SessionManager {
  SessionManager._();

  static bool _isResetting = false;
  static ValueNotifier<int>? _providerScopeResetSignal;

  /// Bound once from the app root (main.dart) to the ProviderScope seed.
  static void bindProviderScopeResetSignal(ValueNotifier<int> signal) {
    _providerScopeResetSignal = signal;
  }

  static void _resetProviderScope() {
    final signal = _providerScopeResetSignal;
    if (signal == null) return;
    signal.value = signal.value + 1;
  }

  static Future<void> _clearLocalUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    // Reset in-memory singletons that can leak state across sessions.
    RegistrationSession.instance.reset();
    RegistrationProductSeivice.instance.reset();
  }

  /// Full local reset: clears prefs + in-memory singletons and recreates all
  /// Riverpod providers. Safe after logout OR account deletion (no backend call).
  static Future<void> forceLogout() async {
    if (_isResetting) return;
    _isResetting = true;
    try {
      await _clearLocalUserData();
      _resetProviderScope();
    } finally {
      _isResetting = false;
    }
  }
}
