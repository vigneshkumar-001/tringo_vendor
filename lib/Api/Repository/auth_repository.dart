import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tringo_vendor_new/Core/Const/app_logger.dart';
import 'package:tringo_vendor_new/Core/Utility/app_prefs.dart';
import 'package:tringo_vendor_new/Core/Widgets/app_go_routes.dart';

import '../DataSource/api_data_source.dart';

class AuthRepository {
  final ApiDataSource api;

  const AuthRepository({required this.api});

  /// UI-safe logout:
  /// - Clears local session immediately
  /// - Navigates to login immediately (prevents back navigation via `go`)
  /// - Sends logout API in background (best-effort)
  Future<void> logout({bool showMessageIfNeeded = false}) async {
    // ✅ UI-first: NEVER use a potentially deactivated widget context.
    final navCtx = rootNavKey.currentContext;
    if (navCtx != null) {
      GoRouter.of(navCtx).go(AppRoutes.loginPath);
    }

    final prefs = await SharedPreferences.getInstance();
    final refreshToken = (prefs.getString('refreshToken') ?? '').trim();
    final sessionToken = (prefs.getString('sessionToken') ?? '').trim();

    // Clear local session regardless of API outcome (safe after navigation).
    await AppPrefs.clearAuthSessionForLogout();

    if (refreshToken.isEmpty) {
      if (showMessageIfNeeded) {
        AppLogger.log.w('Logout API skipped (no refreshToken stored).');
      }
      return;
    }

    unawaited(
      _bestEffortServerLogout(
        refreshToken: refreshToken,
        sessionToken: sessionToken.isEmpty ? null : sessionToken,
      ),
    );
  }

  Future<void> _bestEffortServerLogout({
    required String refreshToken,
    String? sessionToken,
  }) async {
    try {
      final result = await api
          .logout(refreshToken: refreshToken, sessionToken: sessionToken)
          .timeout(const Duration(seconds: 15));

      result.fold(
        (failure) => AppLogger.log.w('Logout API failed: ${failure.message}'),
        (res) => AppLogger.log.i(
          'Logout API success: status=${res.status} code=${res.code} data=${res.data?.success}',
        ),
      );
    } catch (e) {
      AppLogger.log.w('Logout API error (ignored): $e');
    }
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(api: ApiDataSource());
});
