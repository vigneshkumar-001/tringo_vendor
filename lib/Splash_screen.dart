import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../Core/Const/app_color.dart';
import '../../Core/Const/app_images.dart';
import '../../Core/Const/app_logger.dart';

import '../../Core/Utility/app_textstyles.dart';

import '../../Core/Utility/app_prefs.dart';

import 'Core/Widgets/app_go_routes.dart';
import 'Core/Widgets/caller_id_role_helper.dart';
import 'Core/Widgets/common_container.dart';
import 'Core/permissions/permission_service.dart';
import 'Presentation/Home Screen/Contoller/employee_home_notifier.dart';
import 'Presentation/Login Screen/Controller/app_version_notifier.dart';
import 'Presentation/subscription/Controller/subscription_notifier.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with WidgetsBindingObserver {
  String appVersion = '1.0.0';

  bool _batteryFlowRunning = false;
  bool _batterySheetOpen = false;

  static const _kBatteryDoneKey = "battery_opt_done";
  static const _kBatteryLastShownAt = "battery_opt_last_shown_at";
  static const _kWentToBatterySettings = "went_to_battery_settings";

  static const int _cooldownSeconds = 60 * 60 * 12; // 12 hours

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final ok = await PermissionService.requestCorePermissionsWithDialog(
        context,
      );
      if (!ok) return;
      // final nativeOk = await CallerIdRoleHelper.debugPhonePerm();
      // debugPrint("✅ NATIVE READ_PHONE_STATE => $nativeOk");
      // ✅ 2) Overlay permission (optional here)
      final req = await CallerIdRoleHelper.requestReadPhoneState();
      final now = await CallerIdRoleHelper.debugPhonePerm();
      print("PHONE req=$req now=$now");

      await PermissionService.requestOverlayIfNeeded();

      // ✅ 3) Continue your flow
      checkNavigation();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      _batteryFlowRunning = false;
      await _postSettingsRecheckAndMarkDone();
    }
  }

  Future<void> _postSettingsRecheckAndMarkDone() async {
    if (!Platform.isAndroid) return;

    final prefs = await SharedPreferences.getInstance();
    final went = prefs.getBool(_kWentToBatterySettings) ?? false;
    if (!went) return;

    await prefs.setBool(_kWentToBatterySettings, false);

    await Future.delayed(const Duration(milliseconds: 500));

    bool ignoring = await CallerIdRoleHelper.isIgnoringBatteryOptimizations();
    if (!ignoring) {
      await Future.delayed(const Duration(milliseconds: 500));
      ignoring = await CallerIdRoleHelper.isIgnoringBatteryOptimizations();
    }

    AppLogger.log.i("🔋 Post-settings recheck ignoring=$ignoring");

    if (ignoring == true) {
      await prefs.setBool(_kBatteryDoneKey, true);
      AppLogger.log.i("✅ Battery optimization marked DONE");
    }
  }

  Future<void> checkNavigation() async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString('token') ?? '';
    final role = (prefs.getString('role') ?? '').toUpperCase();
    final vendorStatus =
        (prefs.getString('vendorStatus') ?? 'PENDING').toUpperCase();

    await ref
        .read(appVersionNotifierProvider.notifier)
        .getAppVersion(
          appPlatForm: 'android',
          appVersion: appVersion,
          appName: 'vendor',
        );

    final versionState = ref.read(appVersionNotifierProvider);
    if (versionState.appVersionResponse?.data?.forceUpdate == true) {
      _showUpdateBottomSheet();
      return;
    }

    AppLogger.log.i('token=$token role=$role vendorStatus=$vendorStatus');

    // ✅ IMPORTANT FIX: Fresh install / logged-out -> go login directly
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    if (token.isEmpty) {
      context.go(AppRoutes.loginPath);
      return;
    }

    // ✅ Battery flow only AFTER login session exists (token present)
    await _batteryOptimizationFlow();

    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    final offlineSessionId = await AppPrefs.getOfflineSessionId();
    final hasOfflineSession =
        offlineSessionId != null && offlineSessionId.trim().isNotEmpty;
    AppLogger.log.i("offlineSession exists? $hasOfflineSession");

    await ref
        .read(employeeHomeNotifier.notifier)
        .employeeHome(date: '', page: '1', limit: '6', q: '');
    await ref.read(subscriptionNotifier.notifier).getPlanList();

    if (role == 'EMPLOYEE') {
      context.goNamed(AppRoutes.home);
      return;
    }

    if (role == 'VENDOR') {
      if (vendorStatus == 'ACTIVE') {
        context.go(AppRoutes.heaterHomeScreenPath);
      } else {
        context.go(AppRoutes.employeeApprovalPendingPath);
      }
      return;
    }

    context.go(AppRoutes.loginPath);
  }

  // Future<void> checkNavigation() async {
  //   final prefs = await SharedPreferences.getInstance();
  //
  //   final token = prefs.getString('token') ?? '';
  //   final role = (prefs.getString('role') ?? '').toUpperCase();
  //   final vendorStatus =
  //       (prefs.getString('vendorStatus') ?? 'PENDING').toUpperCase();
  //
  //   await ref
  //       .read(appVersionNotifierProvider.notifier)
  //       .getAppVersion(
  //         appPlatForm: 'android',
  //         appVersion: appVersion,
  //         appName: 'vendor',
  //       );
  //
  //   final versionState = ref.read(appVersionNotifierProvider);
  //   if (versionState.appVersionResponse?.data?.forceUpdate == true) {
  //     _showUpdateBottomSheet();
  //     return;
  //   }
  //
  //   AppLogger.log.i('token=$token role=$role vendorStatus=$vendorStatus');
  //
  //   // ✅ Battery flow BEFORE navigation
  //   await _batteryOptimizationFlow();
  //
  //   await Future.delayed(const Duration(seconds: 3));
  //   if (!mounted) return;
  //
  //   if (token.isEmpty) {
  //     context.go(AppRoutes.loginPath);
  //     return;
  //   }
  //
  //   final offlineSessionId = await AppPrefs.getOfflineSessionId();
  //   final hasOfflineSession =
  //       offlineSessionId != null && offlineSessionId.trim().isNotEmpty;
  //   AppLogger.log.i("offlineSession exists? $hasOfflineSession");
  //
  //   await ref
  //       .read(employeeHomeNotifier.notifier)
  //       .employeeHome(date: '', page: '1', limit: '6', q: '');
  //   await ref.read(subscriptionNotifier.notifier).getPlanList();
  //
  //   if (role == 'EMPLOYEE') {
  //     context.goNamed(AppRoutes.home);
  //     return;
  //   }
  //
  //   if (role == 'VENDOR') {
  //     if (vendorStatus == 'ACTIVE') {
  //       context.go(AppRoutes.heaterHomeScreenPath);
  //     } else {
  //       context.go(AppRoutes.employeeApprovalPendingPath);
  //     }
  //     return;
  //   }
  //
  //   context.go(AppRoutes.loginPath);
  // }

  // ---------------------------------------------------------
  // ✅ FIXED: battery optimization flow
  // ---------------------------------------------------------
  Future<void> _batteryOptimizationFlow() async {
    if (!Platform.isAndroid) return;
    if (_batteryFlowRunning) return;
    _batteryFlowRunning = true;

    try {
      final prefs = await SharedPreferences.getInstance();

      final done = prefs.getBool(_kBatteryDoneKey) ?? false;
      if (done) {
        _batteryFlowRunning = false;
        return;
      }

      final lastShownAt = prefs.getInt(_kBatteryLastShownAt) ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;
      final secondsFromLast = (now - lastShownAt) ~/ 1000;
      if (secondsFromLast < _cooldownSeconds) {
        _batteryFlowRunning = false;
        return;
      }

      bool isIgnoring =
          await CallerIdRoleHelper.isIgnoringBatteryOptimizations();
      if (!isIgnoring) {
        await Future.delayed(const Duration(milliseconds: 450));
        isIgnoring = await CallerIdRoleHelper.isIgnoringBatteryOptimizations();
      }

      AppLogger.log.i("🔋 isIgnoringBatteryOptimizations=$isIgnoring");

      if (isIgnoring == true) {
        await prefs.setBool(_kBatteryDoneKey, true);
        _batteryFlowRunning = false;
        return;
      }

      if (!mounted) {
        _batteryFlowRunning = false;
        return;
      }

      await prefs.setInt(_kBatteryLastShownAt, now);

      if (_batterySheetOpen) {
        _batteryFlowRunning = false;
        return;
      }

      _batterySheetOpen = true;
      final action = await _showBatteryMandatoryBottomSheet();
      _batterySheetOpen = false;

      if (!mounted) {
        _batteryFlowRunning = false;
        return;
      }

      if (action == _BatterySheetAction.openSettings) {
        // ✅ IMPORTANT: set flag so resume recheck will mark done
        await prefs.setBool(_kWentToBatterySettings, true);

        // ✅ IMPORTANT: BottomSheet close animation + Navigator pop settle
        await Future.delayed(const Duration(milliseconds: 350));

        final opened = await _openBatterySettingsSafely();
        AppLogger.log.i("⚙️ Battery settings opened? $opened");

        // If not opened, prevent infinite sheet spam by cooldown already set.
      }

      _batteryFlowRunning = false;
    } catch (e, st) {
      AppLogger.log.e("❌ Battery flow error: $e");
      AppLogger.log.e("$st");
      _batteryFlowRunning = false;
    }
  }

  /// ✅ This function tries multiple ways to open correct screen
  Future<bool> _openBatterySettingsSafely() async {
    try {
      // 1) Your custom helper (best)
      await CallerIdRoleHelper.openBatteryUnrestrictedSettings();
      return true;
    } catch (e) {
      AppLogger.log.e("❌ openBatteryUnrestrictedSettings failed: $e");
    }

    // 2) Fallback #1: app details settings (works on all devices)
    try {
      await CallerIdRoleHelper.openAppDetailsSettings();
      return true;
    } catch (e) {
      AppLogger.log.e("❌ openAppDetailsSettings failed: $e");
    }

    // 3) Fallback #2: battery optimization ignore list (some devices)
    try {
      await CallerIdRoleHelper.openBatteryUnrestrictedSettings();
      return true;
    } catch (e) {
      AppLogger.log.e("❌ openIgnoreBatteryOptimizationsSettings failed: $e");
    }

    return false;
  }

  Future<_BatterySheetAction?> _showBatteryMandatoryBottomSheet() async {
    return showModalBottomSheet<_BatterySheetAction>(
      backgroundColor: AppColor.white,
      context: context,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Battery Optimization Required",
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "To show Caller ID popup reliably on Android 12–15, set Tringo battery usage to "
                "\"Unrestricted\".\n\n"
                "Settings → Apps → Tringo → Battery → Unrestricted",
                textAlign: TextAlign.center,
                style: GoogleFonts.ibmPlexSans(fontSize: 14),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      () => Navigator.pop(
                        context,
                        _BatterySheetAction.openSettings,
                      ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: AppColor.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    "Open Settings",
                    style: GoogleFonts.ibmPlexSans(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showUpdateBottomSheet() {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Update Available",
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "A new version of the app is available. Please update to continue.",
                textAlign: TextAlign.center,
                style: GoogleFonts.ibmPlexSans(fontSize: 14),
              ),
              const SizedBox(height: 24),
              CommonContainer.button(
                text: const Text('Update Now'),
                onTap: () => openPlayStore(),
              ),
            ],
          ),
        );
      },
    );
  }

  void openPlayStore() async {
    final versionState = ref.read(appVersionNotifierProvider);
    final storeUrl =
        versionState.appVersionResponse?.data?.store.android.toString() ?? '';
    if (storeUrl.isEmpty) return;
    final uri = Uri.parse(storeUrl);
    await launchUrl(uri, mode: LaunchMode.platformDefault);
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Image.asset(
              AppImages.splashScreen,
              width: w,
              height: h,
              fit: BoxFit.cover,
            ),
            Positioned(
              top: h * 0.53,
              left: w * 0.43,
              child: Text(
                'V $appVersion',
                style: AppTextStyles.mulish(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: AppColor.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _BatterySheetAction { openSettings }

///old////
// import 'dart:io';
//
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:tringo_vendor_new/Core/Const/app_logger.dart';
//
// import 'package:tringo_vendor_new/Core/Utility/app_textstyles.dart';
// import 'package:tringo_vendor_new/dummy_screen.dart';
// import 'package:url_launcher/url_launcher.dart';
//
// import 'Core/Const/app_color.dart';
// import 'Core/Const/app_images.dart';
// import 'Core/Offline_Data/Screens/offline_demo_screen.dart';
// import 'Core/Utility/app_prefs.dart';
// import 'Core/Widgets/app_go_routes.dart';
// import 'Core/Widgets/caller_id_role_helper.dart';
// import 'Core/Widgets/common_container.dart';
// import 'Core/permissions/permission_service.dart';
// import 'Presentation/Home Screen/Contoller/employee_home_notifier.dart';
// import 'Presentation/Login Screen/Controller/app_version_notifier.dart';
// import 'Presentation/subscription/Controller/subscription_notifier.dart';
//
// class SplashScreen extends ConsumerStatefulWidget {
//   const SplashScreen({super.key});
//
//   @override
//   ConsumerState<SplashScreen> createState() => _SplashScreenState();
// }
//
// class _SplashScreenState extends ConsumerState<SplashScreen> {
//   String appVersion = '1.0.0';
//   bool _batteryFlowRunning = false;
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       checkNavigation();
//       PermissionService.requestOverlayAndContacts();
//     });
//   }
//
//   Future<void> checkNavigation() async {
//     final prefs = await SharedPreferences.getInstance();
//
//     final token = prefs.getString('token') ?? '';
//     final role = (prefs.getString('role') ?? '').toUpperCase();
//     final vendorStatus =
//         (prefs.getString('vendorStatus') ?? 'PENDING').toUpperCase();
//
//     await ref
//         .read(appVersionNotifierProvider.notifier)
//         .getAppVersion(
//           appPlatForm: 'android',
//           appVersion: appVersion,
//           appName: 'vendor',
//         );
//
//     // 2) Read version state and decide
//     final versionState = ref.read(appVersionNotifierProvider);
//
//     if (versionState.appVersionResponse?.data?.forceUpdate == true) {
//       _showUpdateBottomSheet();
//
//       return;
//     }
//     AppLogger.log.i('token=$token role=$role vendorStatus=$vendorStatus');
//     await _batteryOptimizationFlow();
//     await Future.delayed(const Duration(seconds: 3));
//     if (!mounted) return;
//
//     // ❌ Not logged in
//     if (token.isEmpty) {
//       context.go(AppRoutes.loginPath);
//       return;
//     }
//     final offlineSessionId = await AppPrefs.getOfflineSessionId();
//     final hasOfflineSession =
//         offlineSessionId != null && offlineSessionId.trim().isNotEmpty;
//
//     await ref
//         .read(employeeHomeNotifier.notifier)
//         .employeeHome(date: '', page: '1', limit: '6', q: '');
//     await ref.read(subscriptionNotifier.notifier).getPlanList();
//     //  EMPLOYEE → always home
//     if (role == 'EMPLOYEE') {
//       // Navigator.push(
//       //   context,
//       //   MaterialPageRoute(
//       //     builder:
//       //         (_) => OfflineDemoScreen(
//       //
//       //     ),
//       //   ),
//       // );
//       context.goNamed(AppRoutes.home);
//       return;
//     }
//
//     // VENDOR flow
//     if (role == 'VENDOR') {
//       if (vendorStatus == 'ACTIVE') {
//         context.go(AppRoutes.heaterHomeScreenPath);
//       } else {
//         // PENDING / REJECTED
//         context.go(AppRoutes.employeeApprovalPendingPath);
//       }
//       return;
//     }
//
//     // fallback
//
//     context.go(AppRoutes.loginPath);
//   }
//   Future<void> _batteryOptimizationFlow() async {
//     if (!Platform.isAndroid) return;
//     if (_batteryFlowRunning) return; // prevent multiple popups
//     _batteryFlowRunning = true;
//
//     try {
//       // Check if battery optimization already unrestricted
//       final isIgnoring =
//       await CallerIdRoleHelper.isIgnoringBatteryOptimizations();
//
//       if (isIgnoring == true) {
//         _batteryFlowRunning = false;
//         return;
//       }
//
//       if (!mounted) {
//         _batteryFlowRunning = false;
//         return;
//       }
//
//       // Show explanation + only one button (Open Settings)
//       await _showBatteryMandatoryBottomSheet();
//
//       // Open settings
//       await CallerIdRoleHelper.openBatteryUnrestrictedSettings();
//
//       // After coming back -> didChangeAppLifecycleState(resumed) will re-check
//     } catch (_) {
//       _batteryFlowRunning = false;
//     }
//   }
//
//   Future<void> _showBatteryMandatoryBottomSheet() async {
//     return showModalBottomSheet(
//       backgroundColor: AppColor.white,
//       context: context,
//       isDismissible: false,
//       enableDrag: false,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (_) {
//         return Padding(
//           padding: const EdgeInsets.all(24.0),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text(
//                 "Battery Optimization Required",
//                 style: GoogleFonts.ibmPlexSans(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 12),
//               Text(
//                 "To show Caller ID popup reliably on Android 12–15, you must set Tringo battery usage to "
//                     "\"Unrestricted\" (or disable battery optimization).\n\n"
//                     "Please do this now:\n"
//                     "Settings → Apps → Tringo → Battery → Unrestricted",
//                 textAlign: TextAlign.center,
//                 style: GoogleFonts.ibmPlexSans(fontSize: 14),
//               ),
//               const SizedBox(height: 24),
//
//               // ✅ Only button (No Later)
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: () => Navigator.pop(context),
//                   style: ElevatedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(vertical: 14),
//                     backgroundColor: AppColor.blue,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(14),
//                     ),
//                   ),
//                   child: Text(
//                     "Open Settings",
//                     style: GoogleFonts.ibmPlexSans(
//                       color: Colors.white,
//                       fontSize: 15,
//                       fontWeight: FontWeight.w700,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//   void _showUpdateBottomSheet() {
//     showModalBottomSheet(
//       context: context,
//       isDismissible: false,
//       enableDrag: false,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (_) {
//         return Padding(
//           padding: const EdgeInsets.all(24.0),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text(
//                 "Update Available",
//                 style: GoogleFonts.ibmPlexSans(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 12),
//
//               Text(
//                 "A new version of the app is available. Please update to continue.",
//                 textAlign: TextAlign.center,
//                 style: GoogleFonts.ibmPlexSans(fontSize: 14),
//               ),
//               const SizedBox(height: 24),
//               CommonContainer.button(
//                 text: Text('Update Now'),
//                 onTap: () {
//                   openPlayStore();
//                 },
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   void openPlayStore() async {
//     final versionState = ref.read(appVersionNotifierProvider);
//     final storeUrl =
//         versionState.appVersionResponse?.data?.store.android.toString() ?? '';
//
//     if (storeUrl.isEmpty) {
//       print('No URL available.');
//       return;
//     }
//
//     final uri = Uri.parse(storeUrl);
//     print('Trying to launch: $uri');
//
//     // Try in-app or platform default mode
//     final success = await launchUrl(
//       uri,
//       mode: LaunchMode.platformDefault, // or LaunchMode.inAppWebView
//     );
//
//     if (!success) {
//       print('Could not open the link. Maybe no browser is installed.');
//     }
//   }
//
//   // Future<void> checkNavigation() async {
//   //   // final prefs = await SharedPreferences.getInstance();
//   //   //
//   //   // final token = prefs.getString('token') ?? '';
//   //   // final role = (prefs.getString('role') ?? '').toUpperCase();
//   //   // final vendorStatus =
//   //   //     (prefs.getString('vendorStatus') ?? 'PENDING').toUpperCase();
//   //   //
//   //   // AppLogger.log.i('token=$token role=$role vendorStatus=$vendorStatus');
//   //   //
//   //   // await Future.delayed(const Duration(seconds: 3));
//   //   // if (!mounted) return;
//   //   //
//   //   // // ❌ Not logged in
//   //   // if (token.isEmpty) {
//   //   //   context.go(AppRoutes.loginPath);
//   //   //   return;
//   //   // }
//   //   //
//   //   // await ref
//   //   //     .read(employeeHomeNotifier.notifier)
//   //   //     .employeeHome(date: '', page: '1', limit: '6', q: '');
//   //   // await ref.read(subscriptionNotifier.notifier).getPlanList();
//   //   // //  EMPLOYEE → always home
//   //   // if (role == 'EMPLOYEE') {
//   //   //   context.goNamed(AppRoutes.home);
//   //   //   return;
//   //   // }
//   //   //
//   //   // // VENDOR flow
//   //   // if (role == 'VENDOR') {
//   //   //   if (vendorStatus == 'ACTIVE') {
//   //   //     context.go(AppRoutes.heaterHomeScreenPath);
//   //   //   } else {
//   //   //     // PENDING / REJECTED
//   //   //     context.go(AppRoutes.employeeApprovalPendingPath);
//   //   //   }
//   //   //   return;
//   //   // }
//   //
//   //   // fallback
//   //   Navigator.push(context, MaterialPageRoute(builder: (context)=>CounterScreen()));
//   //   // context.go(AppRoutes.loginPath);
//   // }
//
//   // Future<void> checkNavigation() async {
//   //   final prefs = await SharedPreferences.getInstance();
//   //
//   //   final String token = prefs.getString("token") ?? '';
//   //   final String sessionToken = prefs.getString("sessionToken") ?? '';
//   //
//   //
//   //
//   //   AppLogger.log.i('sessionToken : $sessionToken \n token : $token');
//   //
//   //   await Future.delayed(const Duration(seconds: 5));
//   //
//   //   if (!mounted) return;
//   //
//   //   if (token.isNotEmpty) {
//   //     context.go(AppRoutes.heaterHomeScreenPath);
//   //   } else {
//   //     // context.go(AppRoutes.employeeApprovalPendingPath);
//   //     context.go(AppRoutes.loginPath);
//   //     // context.go(AppRoutes.loginPath);
//   //   }
//   // }
//   //
//
//   @override
//   Widget build(BuildContext context) {
//     final h = MediaQuery.of(context).size.height;
//     final w = MediaQuery.of(context).size.width;
//
//     return Scaffold(
//       body: SafeArea(
//         child: Stack(
//           children: [
//             Image.asset(
//               AppImages.splashScreen,
//               width: w,
//               height: h,
//               fit: BoxFit.cover,
//             ),
//             Positioned(
//               top: h * 0.53,
//               left: w * 0.43,
//               child: Text(
//                 'V $appVersion',
//                 style: AppTextStyles.mulish(
//                   fontSize: 12,
//                   fontWeight: FontWeight.w900,
//                   color: AppColor.black,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
