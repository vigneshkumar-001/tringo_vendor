import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tringo_vendor_new/Core/Utility/device_helper.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tringo_vendor_new/Core/Firebase/fcm_token_helper.dart';

import 'Core/Const/app_color.dart';
import 'Core/Const/app_images.dart';
import 'Core/Const/app_logger.dart';
import 'Core/Utility/app_prefs.dart';
import 'Core/Utility/app_textstyles.dart';

import 'Core/Widgets/app_go_routes.dart';
import 'Core/Widgets/common_container.dart';
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
  // Read at runtime from the platform build (iOS Info.plist / Android
  // build.gradle), so Android and iOS each report their own real version.
  String appVersion = '0.0.0';

  Future<void> _loadAppVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (info.version.isNotEmpty) {
        appVersion = info.version;
        if (mounted) setState(() {});
      }
    } catch (e) {
      AppLogger.log.w('Failed to read app version: $e');
    }
  }

  bool _navigated = false;
  bool _tokenSent = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    /// Start immediately
    Future.microtask(checkNavigation);

    /// Failsafe after 8 seconds
    Future.delayed(const Duration(seconds: 8), () {
      if (!mounted || _navigated) return;
      AppLogger.log.e("⛑️ Splash failsafe -> Login");
      _navigated = true;
      context.go(AppRoutes.loginPath);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // ---------------------------------------------------------
  // ✅ SAFE DEVICE TOKEN SEND
  // ---------------------------------------------------------
  Future<void> _sendDeviceTokenIfNeeded() async {
    if (_tokenSent) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      var fcmToken = (prefs.getString('fcmToken') ?? '').trim();
      if (fcmToken.isEmpty) {
        AppLogger.log.w("⚠️ No fcmToken in prefs yet");
        fcmToken =
            (await FcmTokenHelper.ensureCachedToken(forceRefresh: true)) ?? '';
        fcmToken = fcmToken.trim();
        if (fcmToken.isEmpty) return;
      }
      _tokenSent = true;
      final deviceId = await DeviceIdHelper.getDeviceId();
      final platform = Platform.isAndroid ? "android" : "ios";
      await ref
          .read(appVersionNotifierProvider.notifier)
          .fcmTokenSend(
            fcmToken: fcmToken,
            platform: platform,
            deviceId: deviceId,
          );
      final st = ref.read(appVersionNotifierProvider);
      AppLogger.log.i(
        "✅ device-token api response: ${st.deviceTokenResponse?.status}",
      );
    } catch (e, st) {
      _tokenSent = false;
      AppLogger.log.e("❌ sendDeviceToken failed: $e");
      AppLogger.log.e(st);
    }
  }

  // ---------------------------------------------------------
  // ✅ FULLY SAFE checkNavigation()
  // ---------------------------------------------------------
  Future<void> checkNavigation() async {
    if (!mounted || _navigated) return;

    try {
      /// 🔥 CACHE NOTIFIERS FIRST (CRITICAL FIX)
      final appVersionCtrl = ref.read(appVersionNotifierProvider.notifier);

      final employeeHomeCtrl = ref.read(employeeHomeNotifier.notifier);

      final subscriptionCtrl = ref.read(subscriptionNotifier.notifier);

      final prefs = await SharedPreferences.getInstance();
      if (!mounted || _navigated) return;

      final token = prefs.getString('token') ?? '';
      final role = (prefs.getString('role') ?? '').toUpperCase();
      final vendorStatus =
          (prefs.getString('vendorStatus') ?? 'PENDING').toUpperCase();
      final vendorBlockType =
          (await AppPrefs.getVendorAccessBlockType() ?? '').toUpperCase();

      /// 🔹 Version check — read the real installed version first.
      await _loadAppVersion();
      await appVersionCtrl
          .getAppVersion(
            appPlatForm: Platform.isAndroid ? 'android' : 'ios',
            appVersion: appVersion,
            appName: 'vendor',
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => AppLogger.log.e("⏳ getAppVersion timeout"),
          );

      if (!mounted || _navigated) return;

      final versionState = ref.read(appVersionNotifierProvider);

      if (versionState.appVersionResponse?.data?.forceUpdate == true) {
        _showUpdateBottomSheet();
        return;
      }

      await Future.delayed(const Duration(seconds: 1));
      if (!mounted || _navigated) return;

      /// 🔹 Not logged in
      if (token.isEmpty) {
        _navigated = true;
        context.go(AppRoutes.loginPath);
        return;
      }

      if (role == 'VENDOR' && vendorBlockType.isNotEmpty) {
        _navigated = true;
        context.go(AppRoutes.vendorAccessBlockedPath);
        return;
      }

      /// 🔹 Send FCM token safely
      await _sendDeviceTokenIfNeeded();
      if (!mounted || _navigated) return;

      /// 🔹 Safe optional APIs
      try {
        await employeeHomeCtrl
            .employeeHome(date: '', page: '1', limit: '6', q: '')
            .timeout(const Duration(seconds: 12));
      } catch (e) {
        AppLogger.log.e("employeeHome error: $e");
      }

      if (!mounted || _navigated) return;

      try {
        await subscriptionCtrl.getPlanList().timeout(
          const Duration(seconds: 12),
        );
      } catch (e) {
        AppLogger.log.e("getPlanList error: $e");
      }

      if (!mounted || _navigated) return;

      /// 🔹 Navigate by role
      _navigated = true;

      if (role == 'EMPLOYEE') {
        context.goNamed(AppRoutes.home);
        return;
      }

      if (role == 'VENDOR') {
        final vendorApproved = prefs.getBool('vendorApproved') ?? false;
        final onboarding = prefs.getString('onboardingStep') ?? '';
        final stepMatch = RegExp(r'(\d+)').firstMatch(onboarding);
        final step =
            stepMatch == null ? null : int.tryParse(stepMatch.group(1) ?? '');

        if (vendorApproved || vendorStatus == 'ACTIVE') {
          context.go(AppRoutes.heaterHomeScreenPath);
        } else if (step != null) {
          switch (step) {
            case 1:
              context.go(AppRoutes.heaterRegister1Path);
              break;
            case 2:
              context.go(AppRoutes.heaterRegister2Path);
              break;
            case 3:
              context.go(AppRoutes.vendorCompanyInfoPath);
              break;
            case 4:
              context.go(AppRoutes.vendorCompanyPhotoPath);
              break;
            case 5:
              context.go(AppRoutes.heaterAddEmployeePath);
              break;
            case 6:
              context.go(AppRoutes.employeeApprovalPendingPath);
              break;
            case 7:
              context.go(AppRoutes.heaterHomeScreenPath);
              break;
            default:
              context.go(AppRoutes.employeeApprovalPendingPath);
          }
        } else {
          context.go(AppRoutes.employeeApprovalPendingPath);
        }
        return;
      }

      context.go(AppRoutes.loginPath);
    } catch (e, st) {
      AppLogger.log.e("❌ checkNavigation crash: $e");
      AppLogger.log.e("$st");

      if (!mounted || _navigated) return;

      _navigated = true;
      context.go(AppRoutes.loginPath);
    }
  }

  // ---------------------------------------------------------
  // FORCE UPDATE BOTTOM SHEET
  // ---------------------------------------------------------
  void _showUpdateBottomSheet() {
    if (!mounted) return;

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
                onTap: openPlayStore,
              ),
            ],
          ),
        );
      },
    );
  }

  void openPlayStore() async {
    final versionState = ref.read(appVersionNotifierProvider);
    final store = versionState.appVersionResponse?.data?.store;
    // Open the App Store on iOS and the Play Store on Android.
    final storeUrl =
        (Platform.isIOS ? store?.ios : store?.android)?.toString() ?? '';

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

// import 'dart:io';
//
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:tringo_vendor_new/Core/Utility/device_helper.dart';
// import 'package:url_launcher/url_launcher.dart';
//
// import '../../Core/Const/app_color.dart';
// import '../../Core/Const/app_images.dart';
// import '../../Core/Const/app_logger.dart';
// import '../../Core/Utility/app_textstyles.dart';
// import '../../Core/Utility/app_prefs.dart';
//
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
// class _SplashScreenState extends ConsumerState<SplashScreen>
//     with WidgetsBindingObserver {
//   String appVersion = '1.0.0';
//
//   bool _batteryFlowRunning = false;
//   bool _batterySheetOpen = false;
//
//   static const _kBatteryDoneKey = "battery_opt_done";
//   static const _kBatteryLastShownAt = "battery_opt_last_shown_at";
//   static const _kWentToBatterySettings = "went_to_battery_settings";
//
//   static const int _cooldownSeconds = 60 * 60 * 12; // 12 hours
//
//   bool _navigated = false; // ✅ prevent double navigation
//   bool _tokenSent = false;
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//
//     Future.microtask(checkNavigation);
//     // ✅ FAILSAFE: if any plugin/API hangs, do not stay stuck on splash
//     Future.delayed(const Duration(seconds: 8), () {
//       if (!mounted) return;
//       if (_navigated) return;
//       AppLogger.log.e("⛑️ Splash failsafe -> Login");
//       _navigated = true;
//       context.go(AppRoutes.loginPath);
//     });
//   }
//
//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     super.dispose();
//   }
//
//   // @override
//   // void didChangeAppLifecycleState(AppLifecycleState state) async {
//   //   if (state == AppLifecycleState.resumed) {
//   //     _batteryFlowRunning = false;
//   //     await _postSettingsRecheckAndMarkDone();
//   //   }
//   // }
//
//   // ---------------------------------------------------------
//   // ✅ NEW: Boot flow that NEVER blocks navigation
//   // ---------------------------------------------------------
//   // Future<void> _bootFlow() async {
//   //   try {
//   //     // 1) Core permissions (timeout) - DO NOT return even if denied
//   //     final ok = await PermissionService.requestCorePermissionsWithDialog(
//   //       context,
//   //     ).timeout(const Duration(seconds: 12), onTimeout: () => false);
//   //
//   //     AppLogger.log.i("✅ core permissions ok=$ok");
//   //
//   //     if (!mounted) return;
//   //
//   //     // 2) Phone permission - never block app
//   //     try {
//   //       final req = await CallerIdRoleHelper.requestReadPhoneState().timeout(
//   //         const Duration(seconds: 8),
//   //         onTimeout: () => false,
//   //       );
//   //       final now = await CallerIdRoleHelper.debugPhonePerm().timeout(
//   //         const Duration(seconds: 6),
//   //         onTimeout: () => false,
//   //       );
//   //       AppLogger.log.i("📞 PHONE req=$req now=$now");
//   //     } catch (e) {
//   //       AppLogger.log.e("📞 phone perm error: $e");
//   //     }
//   //
//   //     if (!mounted) return;
//   //
//   //     // 3) Overlay permission (optional) - never block app
//   //     try {
//   //       await PermissionService.requestOverlayIfNeeded().timeout(
//   //         const Duration(seconds: 8),
//   //         onTimeout: () {},
//   //       );
//   //       AppLogger.log.i("🪟 overlay request done");
//   //     } catch (e) {
//   //       AppLogger.log.e("🪟 overlay error: $e");
//   //     }
//   //
//   //     if (!mounted) return;
//   //
//   //     // 4) Continue to main navigation ALWAYS
//   //     await checkNavigation();
//   //   } catch (e, st) {
//   //     AppLogger.log.e("❌ boot flow crash: $e");
//   //     AppLogger.log.e("$st");
//   //     if (!mounted) return;
//   //     if (_navigated) return;
//   //     _navigated = true;
//   //     context.go(AppRoutes.loginPath);
//   //   }
//   // }
//
//   // Future<void> _postSettingsRecheckAndMarkDone() async {
//   //   if (!Platform.isAndroid) return;
//   //
//   //   final prefs = await SharedPreferences.getInstance();
//   //   final went = prefs.getBool(_kWentToBatterySettings) ?? false;
//   //   if (!went) return;
//   //
//   //   await prefs.setBool(_kWentToBatterySettings, false);
//   //
//   //   await Future.delayed(const Duration(milliseconds: 500));
//   //
//   //   bool ignoring = await CallerIdRoleHelper.isIgnoringBatteryOptimizations();
//   //   if (!ignoring) {
//   //     await Future.delayed(const Duration(milliseconds: 500));
//   //     ignoring = await CallerIdRoleHelper.isIgnoringBatteryOptimizations();
//   //   }
//   //
//   //   AppLogger.log.i("🔋 Post-settings recheck ignoring=$ignoring");
//   //
//   //   if (ignoring == true) {
//   //     await prefs.setBool(_kBatteryDoneKey, true);
//   //     AppLogger.log.i("✅ Battery optimization marked DONE");
//   //   }
//   // }
//
//   Future<void> _sendDeviceTokenIfNeeded() async {
//     if (_tokenSent) return;
//     _tokenSent = true;
//
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final fcmToken = prefs.getString('fcmToken') ?? '';
//       AppLogger.log.i(fcmToken);
//
//       if (fcmToken.isEmpty) {
//         AppLogger.log.w("⚠️ No fcmToken in prefs yet");
//         return;
//       }
//
//       final deviceId = await DeviceIdHelper.getDeviceId();
//       final platform = Platform.isAndroid ? "android" : "ios";
//
//       await ref
//           .read(appVersionNotifierProvider.notifier)
//           .fcmTokenSend(
//             fcmToken: fcmToken,
//             platform: platform,
//             deviceId: deviceId,
//           );
//
//       final st = ref.read(appVersionNotifierProvider);
//       AppLogger.log.i(
//         "✅ device-token api response: ${st.deviceTokenResponse?.status}",
//       );
//     } catch (e, st) {
//       AppLogger.log.e("❌ sendDeviceToken failed: $e");
//       AppLogger.log.e(st);
//     }
//   }
//
//   // ---------------------------------------------------------
//   // ✅ Updated: checkNavigation() with timeouts + safe fallback
//   // ---------------------------------------------------------
//   Future<void> checkNavigation() async {
//     if (_navigated) return;
//
//     try {
//       final prefs = await SharedPreferences.getInstance();
//
//       final token = prefs.getString('token') ?? '';
//       final role = (prefs.getString('role') ?? '').toUpperCase();
//       final vendorStatus =
//           (prefs.getString('vendorStatus') ?? 'PENDING').toUpperCase();
//
//       // ✅ getAppVersion can hang -> add timeout
//       await ref
//           .read(appVersionNotifierProvider.notifier)
//           .getAppVersion(
//             appPlatForm: 'android',
//             appVersion: appVersion,
//             appName: 'vendor',
//           )
//           .timeout(
//             const Duration(seconds: 10),
//             onTimeout: () {
//               AppLogger.log.e("⏳ getAppVersion timeout");
//             },
//           );
//
//       final versionState = ref.read(appVersionNotifierProvider);
//       if (versionState.appVersionResponse?.data?.forceUpdate == true) {
//         _showUpdateBottomSheet();
//         return;
//       }
//
//       AppLogger.log.i('token=$token role=$role vendorStatus=$vendorStatus');
//
//       // small splash delay (optional)
//       await Future.delayed(const Duration(seconds: 2));
//       if (!mounted) return;
//
//       // ✅ Logged out -> go login immediately
//       if (token.isEmpty) {
//         _navigated = true;
//         context.go(AppRoutes.loginPath);
//         return;
//       }
//       _sendDeviceTokenIfNeeded();
//       // ✅ Battery flow only after login session exists
//       // await _batteryOptimizationFlow();
//
//       await Future.delayed(const Duration(seconds: 1));
//       if (!mounted) return;
//
//       final offlineSessionId = await AppPrefs.getOfflineSessionId();
//       final hasOfflineSession =
//           offlineSessionId != null && offlineSessionId.trim().isNotEmpty;
//       AppLogger.log.i("offlineSession exists? $hasOfflineSession");
//
//       // These API calls can hang -> keep them safe
//       try {
//         await ref
//             .read(employeeHomeNotifier.notifier)
//             .employeeHome(date: '', page: '1', limit: '6', q: '')
//             .timeout(
//               const Duration(seconds: 12),
//               onTimeout: () {
//                 AppLogger.log.e("⏳ employeeHome timeout");
//               },
//             );
//       } catch (e) {
//         AppLogger.log.e("employeeHome error: $e");
//       }
//
//       try {
//         await ref
//             .read(subscriptionNotifier.notifier)
//             .getPlanList()
//             .timeout(
//               const Duration(seconds: 12),
//               onTimeout: () {
//                 AppLogger.log.e("⏳ getPlanList timeout");
//               },
//             );
//       } catch (e) {
//         AppLogger.log.e("getPlanList error: $e");
//       }
//
//       if (!mounted) return;
//
//       // ✅ Navigate by role
//       if (role == 'EMPLOYEE') {
//         _navigated = true;
//         context.goNamed(AppRoutes.home);
//         return;
//       }
//
//       if (role == 'VENDOR') {
//         _navigated = true;
//         if (vendorStatus == 'ACTIVE') {
//           context.go(AppRoutes.heaterHomeScreenPath);
//         } else {
//           context.go(AppRoutes.employeeApprovalPendingPath);
//         }
//         return;
//       }
//
//       // fallback
//       _navigated = true;
//       context.go(AppRoutes.loginPath);
//     } catch (e, st) {
//       AppLogger.log.e("❌ checkNavigation crash: $e");
//       AppLogger.log.e("$st");
//       if (!mounted) return;
//       if (_navigated) return;
//       _navigated = true;
//       context.go(AppRoutes.loginPath);
//     }
//   }
//
//   // ---------------------------------------------------------
//   // ✅ FIXED: battery optimization flow (safe)
//   // ---------------------------------------------------------
//   // Future<void> _batteryOptimizationFlow() async {
//   //   if (!Platform.isAndroid) return;
//   //   if (_batteryFlowRunning) return;
//   //   _batteryFlowRunning = true;
//   //
//   //   try {
//   //     final prefs = await SharedPreferences.getInstance();
//   //
//   //     final done = prefs.getBool(_kBatteryDoneKey) ?? false;
//   //     if (done) {
//   //       _batteryFlowRunning = false;
//   //       return;
//   //     }
//   //
//   //     final lastShownAt = prefs.getInt(_kBatteryLastShownAt) ?? 0;
//   //     final now = DateTime.now().millisecondsSinceEpoch;
//   //     final secondsFromLast = (now - lastShownAt) ~/ 1000;
//   //     if (secondsFromLast < _cooldownSeconds) {
//   //       _batteryFlowRunning = false;
//   //       return;
//   //     }
//   //
//   //     bool isIgnoring =
//   //         await CallerIdRoleHelper.isIgnoringBatteryOptimizations().timeout(
//   //           const Duration(seconds: 6),
//   //           onTimeout: () => false,
//   //         );
//   //     if (!isIgnoring) {
//   //       await Future.delayed(const Duration(milliseconds: 450));
//   //       isIgnoring = await CallerIdRoleHelper.isIgnoringBatteryOptimizations()
//   //           .timeout(const Duration(seconds: 6), onTimeout: () => false);
//   //     }
//   //
//   //     AppLogger.log.i("🔋 isIgnoringBatteryOptimizations=$isIgnoring");
//   //
//   //     if (isIgnoring == true) {
//   //       await prefs.setBool(_kBatteryDoneKey, true);
//   //       _batteryFlowRunning = false;
//   //       return;
//   //     }
//   //
//   //     if (!mounted) {
//   //       _batteryFlowRunning = false;
//   //       return;
//   //     }
//   //
//   //     await prefs.setInt(_kBatteryLastShownAt, now);
//   //
//   //     if (_batterySheetOpen) {
//   //       _batteryFlowRunning = false;
//   //       return;
//   //     }
//   //
//   //     _batterySheetOpen = true;
//   //     final action = await _showBatteryMandatoryBottomSheet();
//   //     _batterySheetOpen = false;
//   //
//   //     if (!mounted) {
//   //       _batteryFlowRunning = false;
//   //       return;
//   //     }
//   //
//   //     if (action == _BatterySheetAction.openSettings) {
//   //       await prefs.setBool(_kWentToBatterySettings, true);
//   //       await Future.delayed(const Duration(milliseconds: 350));
//   //
//   //       final opened = await _openBatterySettingsSafely();
//   //       AppLogger.log.i("⚙️ Battery settings opened? $opened");
//   //     }
//   //
//   //     _batteryFlowRunning = false;
//   //   } catch (e, st) {
//   //     AppLogger.log.e("❌ Battery flow error: $e");
//   //     AppLogger.log.e("$st");
//   //     _batteryFlowRunning = false;
//   //   }
//   // }
//   //
//   // Future<bool> _openBatterySettingsSafely() async {
//   //   try {
//   //     await CallerIdRoleHelper.openBatteryUnrestrictedSettings();
//   //     return true;
//   //   } catch (e) {
//   //     AppLogger.log.e("❌ openBatteryUnrestrictedSettings failed: $e");
//   //   }
//   //
//   //   try {
//   //     await CallerIdRoleHelper.openAppDetailsSettings();
//   //     return true;
//   //   } catch (e) {
//   //     AppLogger.log.e("❌ openAppDetailsSettings failed: $e");
//   //   }
//   //
//   //   try {
//   //     await CallerIdRoleHelper.openBatteryUnrestrictedSettings();
//   //     return true;
//   //   } catch (e) {
//   //     AppLogger.log.e("❌ openIgnoreBatteryOptimizationsSettings failed: $e");
//   //   }
//   //
//   //   return false;
//   // }
//   //
//   // Future<_BatterySheetAction?> _showBatteryMandatoryBottomSheet() async {
//   //   if (!mounted) return null;
//   //
//   //   return showModalBottomSheet<_BatterySheetAction>(
//   //     backgroundColor: AppColor.white,
//   //     context: context,
//   //     isDismissible: false,
//   //     enableDrag: false,
//   //     shape: const RoundedRectangleBorder(
//   //       borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//   //     ),
//   //     builder: (_) {
//   //       return Padding(
//   //         padding: const EdgeInsets.all(24.0),
//   //         child: Column(
//   //           mainAxisSize: MainAxisSize.min,
//   //           children: [
//   //             Text(
//   //               "Battery Optimization Required",
//   //               style: GoogleFonts.ibmPlexSans(
//   //                 fontSize: 18,
//   //                 fontWeight: FontWeight.bold,
//   //               ),
//   //             ),
//   //             const SizedBox(height: 12),
//   //             Text(
//   //               "To show Caller ID popup reliably on Android 12–15, set Tringo battery usage to "
//   //               "\"Unrestricted\".\n\n"
//   //               "Settings → Apps → Tringo → Battery → Unrestricted",
//   //               textAlign: TextAlign.center,
//   //               style: GoogleFonts.ibmPlexSans(fontSize: 14),
//   //             ),
//   //             const SizedBox(height: 20),
//   //             SizedBox(
//   //               width: double.infinity,
//   //               child: ElevatedButton(
//   //                 onPressed:
//   //                     () => Navigator.pop(
//   //                       context,
//   //                       _BatterySheetAction.openSettings,
//   //                     ),
//   //                 style: ElevatedButton.styleFrom(
//   //                   padding: const EdgeInsets.symmetric(vertical: 14),
//   //                   backgroundColor: AppColor.blue,
//   //                   shape: RoundedRectangleBorder(
//   //                     borderRadius: BorderRadius.circular(14),
//   //                   ),
//   //                 ),
//   //                 child: Text(
//   //                   "Open Settings",
//   //                   style: GoogleFonts.ibmPlexSans(
//   //                     color: Colors.white,
//   //                     fontSize: 15,
//   //                     fontWeight: FontWeight.w700,
//   //                   ),
//   //                 ),
//   //               ),
//   //             ),
//   //           ],
//   //         ),
//   //       );
//   //     },
//   //   );
//   // }
//
//   void _showUpdateBottomSheet() {
//     if (!mounted) return;
//
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
//               Text(
//                 "A new version of the app is available. Please update to continue.",
//                 textAlign: TextAlign.center,
//                 style: GoogleFonts.ibmPlexSans(fontSize: 14),
//               ),
//               const SizedBox(height: 24),
//               CommonContainer.button(
//                 text: const Text('Update Now'),
//                 onTap: () => openPlayStore(),
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
//     if (storeUrl.isEmpty) return;
//     final uri = Uri.parse(storeUrl);
//     await launchUrl(uri, mode: LaunchMode.platformDefault);
//   }
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
//
// // enum _BatterySheetAction { openSettings }
