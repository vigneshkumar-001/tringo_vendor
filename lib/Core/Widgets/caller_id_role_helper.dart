import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:permission_handler/permission_handler.dart';

/// ✅ TOP LEVEL provider (one-time per session)
final callerIdAskedProvider = StateProvider<bool>((ref) => false);

/// ✅ Native channel
const MethodChannel _native = MethodChannel('sim_info');

class CallerIdRoleHelper {
  // ---------------- Caller ID role ----------------

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
    } catch (_) {
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
      ref.read(callerIdAskedProvider.notifier).state = true;
      return;
    }

    ref.read(callerIdAskedProvider.notifier).state = true;
    await requestDefaultCallerIdApp();
  }

  // ---------------- Overlay ----------------

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

  // ---------------- Battery optimization ----------------

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

  /// ✅ IMPORTANT: return bool + don't silently swallow.
  /// - true => intent triggered (opened)
  /// - false => failed, call fallback (open app settings etc)
  static Future<bool> openBatteryUnrestrictedSettings() async {
    if (!Platform.isAndroid) return true;

    try {
      final ok = await _native.invokeMethod<bool>(
        'openBatteryUnrestrictedSettings',
      );

      // some native impl returns nothing -> treat as "attempted"
      return ok ?? true;
    } catch (e) {
      // log and return false so caller can fallback
      // ignore: avoid_print
      print('❌ openBatteryUnrestrictedSettings failed: $e');
      return false;
    }
  }

  // ---------------- Fallbacks (WORKS ON ALL DEVICES) ----------------

  /// ✅ Always works: opens App Details page (user can go Battery -> Unrestricted)
  static Future<bool> openAppDetailsSettings() async {
    if (!Platform.isAndroid) return true;
    try {
      final ok = await openAppSettings(); // permission_handler
      return ok;
    } catch (e) {
      // ignore: avoid_print
      print('❌ openAppDetailsSettings failed: $e');
      return false;
    }
  }

  /// ✅ Optional fallback via native intent (only if you implement on Android)
  /// If you don't have native method, it will fail and return false safely.
  static Future<bool> openIgnoreBatteryOptimizationsSettings() async {
    if (!Platform.isAndroid) return true;
    try {
      final ok = await _native.invokeMethod<bool>(
        'openIgnoreBatteryOptimizationsSettings',
      );
      return ok ?? true;
    } catch (e) {
      // ignore: avoid_print
      print('❌ openIgnoreBatteryOptimizationsSettings failed: $e');
      return false;
    }
  }

  /// ✅ Best helper to call from UI:
  /// Try Unrestricted screen -> fallback to App Details -> fallback ignore list
  static Future<bool> openBatterySettingsBestEffort() async {
    // 1) best try
    final ok1 = await openBatteryUnrestrictedSettings();
    if (ok1) return true;

    // 2) universal fallback
    final ok2 = await openAppDetailsSettings();
    if (ok2) return true;

    // 3) optional fallback (if native exists)
    final ok3 = await openIgnoreBatteryOptimizationsSettings();
    return ok3;
  }
}



//
// import 'dart:io';
// import 'package:flutter/services.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_riverpod/legacy.dart';
//
// /// ✅ TOP LEVEL provider (one-time per session)
// final callerIdAskedProvider = StateProvider<bool>((ref) => false);
//
// /// ✅ Native channel
// const MethodChannel _native = MethodChannel('sim_info');
//
// class CallerIdRoleHelper {
//   static Future<bool> isDefaultCallerIdApp() async {
//     if (!Platform.isAndroid) return true;
//     try {
//       final ok = await _native.invokeMethod<bool>('isDefaultCallerIdApp');
//       return ok ?? false;
//     } catch (_) {
//       return false;
//     }
//   }
//
//   static Future<bool> requestDefaultCallerIdApp() async {
//     if (!Platform.isAndroid) return true;
//     try {
//       final ok = await _native.invokeMethod<bool>('requestDefaultCallerIdApp');
//       return ok ?? false;
//     } catch (e) {
//       return false;
//     }
//   }
//
//   /// ✅ Only System popup (no custom UI)
//   static Future<void> maybeAskOnce({
//     required WidgetRef ref,
//     bool force = false,
//   }) async {
//     if (!Platform.isAndroid) return;
//
//     final alreadyAsked = ref.read(callerIdAskedProvider);
//     if (!force && alreadyAsked) return;
//
//     final ok = await isDefaultCallerIdApp();
//     if (ok) {
//       ref.read(callerIdAskedProvider.notifier).state = true; // keep asked
//       return;
//     }
//
//     ref.read(callerIdAskedProvider.notifier).state = true;
//     final granted = await requestDefaultCallerIdApp();
//     // optional log:
//     // debugPrint("ROLE granted? $granted");
//   }
//
//   static Future<bool> isOverlayGranted() async {
//     if (!Platform.isAndroid) return true;
//     try {
//       final ok = await _native.invokeMethod<bool>('isOverlayGranted');
//       return ok ?? false;
//     } catch (_) {
//       return false;
//     }
//   }
//
//   static Future<void> requestOverlayPermission() async {
//     if (!Platform.isAndroid) return;
//     try {
//       await _native.invokeMethod('requestOverlayPermission');
//     } catch (_) {}
//   }
//
//   // static Future<bool> isIgnoringBatteryOptimizations() async {
//   //   if (!Platform.isAndroid) return true;
//   //   try {
//   //     final ok =
//   //     await _native.invokeMethod<bool>('isIgnoringBatteryOptimizations');
//   //     return ok ?? false;
//   //   } catch (_) {
//   //     return false;
//   //   }
//   // }
//
//   static Future<bool> isIgnoringBatteryOptimizations() async {
//     if (!Platform.isAndroid) return true;
//     try {
//       final ok = await _native.invokeMethod<bool>(
//         'isIgnoringBatteryOptimizations',
//       );
//       return ok ?? false;
//     } catch (_) {
//       return false;
//     }
//   }
//
//   static Future<void> requestIgnoreBatteryOptimization() async {
//     if (!Platform.isAndroid) return;
//     try {
//       await _native.invokeMethod('requestIgnoreBatteryOptimization');
//     } catch (_) {}
//   }
//
//   static Future<void> openBatteryUnrestrictedSettings() async {
//     if (!Platform.isAndroid) return;
//     try {
//       await _native.invokeMethod('openBatteryUnrestrictedSettings');
//     } catch (_) {}
//   }
// }
