import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:tringo_vendor_new/Core/Const/app_logger.dart';
import 'package:tringo_vendor_new/Core/Firebase/firebase_service.dart';

import 'Core/Const/app_color.dart';
import 'Core/Const/app_images.dart';
import 'Core/Utility/app_prefs.dart';
import 'Core/Utility/app_textstyles.dart';
import 'Core/Widgets/app_go_routes.dart';
import 'dummy_screen.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Must initialize Firebase in background isolate too
  await Firebase.initializeApp();
  AppLogger.log.i('🔕 [BG] messageId=${message.messageId}');
}

Map<String, dynamic>? _pendingPushData;

Future<void> _handlePushData(Map<String, dynamic> data) async {
  final eventTypeRaw = (data['eventType'] ?? '').toString().trim();
  final eventType = eventTypeRaw.toUpperCase();

  final ctx = rootNavKey.currentContext;
  if (ctx == null) {
    AppLogger.log.w('Push navigation skipped (no navigation context yet).');
    return;
  }
  final router = GoRouter.of(ctx);

  switch (eventType) {
    case 'VENDOR_APPROVED':
      final vendorId = (data['vendorId'] ?? '').toString().trim();
      if (vendorId.isNotEmpty) {
        await AppPrefs.setVendorId(vendorId);
      }
      await AppPrefs.setVendorApproved(true);
      router.goNamed(AppRoutes.heaterHomeScreen);
      return;
    default:
      router.goNamed(AppRoutes.notifications);
      return;
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Optional: keep Flutter errors visible
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
  };

  // ✅ Init Firebase
  await Firebase.initializeApp();

  // ✅ Register background handler early
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // ✅ Ensure FCM auto-init
  await FirebaseMessaging.instance.setAutoInitEnabled(true);

  final firebaseService = FirebaseService();

  // ✅ This initializes local notifications + channel + permission
  await firebaseService.initializeFirebase(onNotificationTap: _handlePushData);

  // ✅ Small delay helps some devices (Play Services not ready immediately)
  await Future.delayed(const Duration(seconds: 3));

  // ✅ Fetch token with your backoff
  await firebaseService.fetchFCMTokenIfNeeded();

  // ✅ Foreground + opened listeners
  firebaseService.listenToMessages(
    onMessage: (msg) async {
      AppLogger.log.i('📩 [FG] ${msg.messageId}');
      await firebaseService.showNotification(msg);
    },
    onMessageOpenedApp: (msg) {
      AppLogger.log.i('📬 [OPENED] ${msg.messageId}');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handlePushData(msg.data);
      });
    },
  );

  // ✅ Terminated -> opened by tap
  final initialMsg = await firebaseService.getInitialMessage();
  if (initialMsg != null) {
    AppLogger.log.i('🚀 [TERMINATED OPEN] ${initialMsg.messageId}');
    _pendingPushData = initialMsg.data;
  }

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final data = _pendingPushData;
      if (data == null) return;
      _pendingPushData = null;
      _handlePushData(data);
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(goRouterProvider);

    return ScreenUtilInit(
      designSize: const Size(360, 690),
      builder: (context, child) {
        return MaterialApp.router(
          routerConfig: router,
          debugShowCheckedModeBanner: false,
          theme: ThemeData(scaffoldBackgroundColor: AppColor.white),
        );
      },
    );
  }
}

class NoInternetScreen extends StatelessWidget {
  const NoInternetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 160),
          child: Column(
            children: [
              Image.asset(AppImages.noDataGif),
              const SizedBox(height: 30),
              Text(
                'No Internet Connection',
                style: AppTextStyles.mulish(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColor.darkBlue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final routerRefreshProvider = Provider<ChangeNotifier>((ref) {
  final notifier = ValueNotifier<int>(0);

  ref.listen(internetStatusProvider, (_, __) {
    notifier.value++;
  });

  ref.onDispose(notifier.dispose);
  return notifier;
});
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
//
// import 'package:flutter/foundation.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
//
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:tringo_vendor_new/Core/Const/app_logger.dart';
// import 'package:tringo_vendor_new/Core/Firebase/firebase_service.dart';
//
// import 'Core/Const/app_color.dart';
//
// import 'Core/Const/app_images.dart';
// import 'Core/Utility/app_textstyles.dart';
// import 'Core/Widgets/app_go_routes.dart';
// import 'Core/Widgets/common_container.dart';
// import 'dummy_screen.dart';
// @pragma('vm:entry-point')
// Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   // Must initialize Firebase in background isolate too
//   await Firebase.initializeApp();
//   AppLogger.log.i('🔕 [BG] messageId=${message.messageId}');
// }
// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   FlutterError.onError = (FlutterErrorDetails details) {
//     FlutterError.dumpErrorToConsole(details);
//   };
//   await Firebase.initializeApp();
//   // Background handler must be registered early
//   FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
//
//   final firebaseService = FirebaseService();
//   await firebaseService.initializeFirebase();
//   await firebaseService.fetchFCMTokenIfNeeded();
//
//   // ✅ Register listeners (no need for postFrame)
//   firebaseService.listenToMessages(
//     onMessage: (msg) async {
//       AppLogger.log.i('📩 [FG] ${msg.messageId}');
//       await firebaseService.showNotification(msg);
//     },
//     onMessageOpenedApp: (msg) {
//       AppLogger.log.i('📬 [OPENED] ${msg.messageId}');
//       // TODO: navigate based on msg.data if needed
//     },
//   );
//
//   // ✅ Handle "terminated -> opened by tap"
//   final initialMsg = await FirebaseMessaging.instance.getInitialMessage();
//   if (initialMsg != null) {
//     AppLogger.log.i('🚀 [TERMINATED OPEN] ${initialMsg.messageId}');
//     // TODO: navigate based on initialMsg.data if needed
//   }
//   runApp(const ProviderScope(child: MyApp()));
// }
//
// class MyApp extends ConsumerWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final router = ref.watch(goRouterProvider);
//
//     return ScreenUtilInit(
//       designSize: const Size(360, 690),
//       builder: (context, child) {
//         return MaterialApp.router(
//           routerConfig: router,
//           debugShowCheckedModeBanner: false,
//           theme: ThemeData(scaffoldBackgroundColor: AppColor.white),
//         );
//       },
//     );
//   }
// }
//
// class NoInternetScreen extends StatelessWidget {
//   const NoInternetScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 160),
//           child: Column(
//             children: [
//               Image.asset(AppImages.noDataGif),
//               SizedBox(height: 30),
//               Text(
//                 'No Internet Connection',
//                 style: AppTextStyles.mulish(
//                   fontSize: 24,
//                   fontWeight: FontWeight.w800,
//                   color: AppColor.darkBlue,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// final routerRefreshProvider = Provider<ChangeNotifier>((ref) {
//   final notifier = ValueNotifier<int>(0);
//
//   // whenever internetStatusProvider changes, refresh go_router
//   ref.listen(internetStatusProvider, (_, __) {
//     notifier.value++;
//   });
//
//   ref.onDispose(notifier.dispose);
//   return notifier;
// });
