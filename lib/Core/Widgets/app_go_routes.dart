// lib/Core/Routing/app_go_routes.dart
import 'package:go_router/go_router.dart';
import 'package:tringo_vendor_new/Core/Widgets/bottom_navigation_bar.dart';

import '../../Presentation/Home Screen/home_screen.dart';
import '../../Presentation/Login Screen/Screens/login_mobile_number.dart';
import '../../Presentation/OTP Screen/Screens/otp_screen.dart';
import '../../Presentation/Owner Screen/owner_info_screens.dart';
import '../../Splash_screen.dart';

class AppRoutes {
  static const String splashScreen = 'splashScreen';
  static const String login = 'login';
  static const String otp = 'otp';
  static const String home = 'home';
  static const String ownerInfo = 'ownerInfo';

  static const String splashScreenPath = '/splashScreen';
  static const String loginPath = '/login';
  static const String otpPath = '/otp';
  static const String homePath = '/home';
  static const String ownerInfoPath = '/ownerInfo';
}

final goRouter = GoRouter(
  initialLocation: AppRoutes.loginPath,
  routes: [
    GoRoute(
      path: AppRoutes.splashScreenPath,
      name: AppRoutes.splashScreen,
      builder: (context, state) => SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.loginPath,
      name: AppRoutes.login,
      builder: (context, state) => LoginMobileNumber(),
    ),

    GoRoute(
      path: AppRoutes.otpPath,
      name: AppRoutes.otp,
      builder: (context, state) {
        final phone = state.extra as String?;
        return OtpScreen(phoneNumber: phone ?? '');
      },
    ),
    GoRoute(
      path: AppRoutes.ownerInfoPath,
      name: AppRoutes.ownerInfo,
      builder: (context, state) => OwnerInfoScreens(),
    ),
    GoRoute(
      path: AppRoutes.homePath,
      name: AppRoutes.home,
      builder: (context, state) => CommonBottomNavigation(initialIndex: 0),
    ),
  ],
);
