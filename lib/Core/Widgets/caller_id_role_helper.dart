
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

/// ✅ TOP LEVEL provider (one-time per session)
final callerIdAskedProvider = StateProvider<bool>((ref) => false);

/// ✅ Native channel
const MethodChannel _native = MethodChannel('sim_info');

class CallerIdRoleHelper {
  static Future<bool> isDefaultCallerIdApp() async {
    if (!Platform.isAndroid) return true;
    try {
      final ok = await _native.invokeMethod<bool>('isDefaultCallerIdApp');
      return ok ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> requestDefaultCallerIdApp() async {
    if (!Platform.isAndroid) return true;
    try {
      final ok = await _native.invokeMethod<bool>('requestDefaultCallerIdApp');
      return ok ?? false;
    } catch (e) {
      return false;
    }
  }

  /// ✅ Only System popup (no custom UI)
  static Future<void> maybeAskOnce({
    required WidgetRef ref,
    bool force = false,
  }) async {
    if (!Platform.isAndroid) return;

    final alreadyAsked = ref.read(callerIdAskedProvider);
    if (!force && alreadyAsked) return;

    final ok = await isDefaultCallerIdApp();
    if (ok) {
      ref.read(callerIdAskedProvider.notifier).state = true; // keep asked
      return;
    }

    ref.read(callerIdAskedProvider.notifier).state = true;
    final granted = await requestDefaultCallerIdApp();
    // optional log:
    // debugPrint("ROLE granted? $granted");
  }

  static Future<bool> isOverlayGranted() async {
    if (!Platform.isAndroid) return true;
    try {
      final ok = await _native.invokeMethod<bool>('isOverlayGranted');
      return ok ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<void> requestOverlayPermission() async {
    if (!Platform.isAndroid) return;
    try {
      await _native.invokeMethod('requestOverlayPermission');
    } catch (_) {}
  }

  // static Future<bool> isIgnoringBatteryOptimizations() async {
  //   if (!Platform.isAndroid) return true;
  //   try {
  //     final ok =
  //     await _native.invokeMethod<bool>('isIgnoringBatteryOptimizations');
  //     return ok ?? false;
  //   } catch (_) {
  //     return false;
  //   }
  // }

  static Future<bool> isIgnoringBatteryOptimizations() async {
    if (!Platform.isAndroid) return true;
    try {
      final ok = await _native.invokeMethod<bool>(
        'isIgnoringBatteryOptimizations',
      );
      return ok ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<void> requestIgnoreBatteryOptimization() async {
    if (!Platform.isAndroid) return;
    try {
      await _native.invokeMethod('requestIgnoreBatteryOptimization');
    } catch (_) {}
  }

  static Future<void> openBatteryUnrestrictedSettings() async {
    if (!Platform.isAndroid) return;
    try {
      await _native.invokeMethod('openBatteryUnrestrictedSettings');
    } catch (_) {}
  }
}
