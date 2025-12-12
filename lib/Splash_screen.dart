import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tringo_vendor_new/Core/Const/app_logger.dart';

import 'package:tringo_vendor_new/Core/Utility/app_textstyles.dart';

import 'Core/Const/app_color.dart';
import 'Core/Const/app_images.dart';
import 'Core/Widgets/app_go_routes.dart';
import 'Presentation/Login Screen/Controllre/login_notifier.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    checkNavigation();
  }

  Future<void> checkNavigation() async {
    final prefs = await SharedPreferences.getInstance();

    final String token = prefs.getString("token") ?? '';
    final String sessionToken = prefs.getString("sessionToken") ?? '';



    AppLogger.log.i('sessionToken : $sessionToken \n token : $token');

    await Future.delayed(const Duration(seconds: 5));

    if (!mounted) return;

    if (token.isNotEmpty) {
      context.go(AppRoutes.heaterHomeScreenPath);
    } else {
      // context.go(AppRoutes.employeeApprovalPendingPath);
      context.go(AppRoutes.loginPath);
      // context.go(AppRoutes.loginPath);
    }
  }

  // Future<void> checkNavigation() async {
  //   final prefs = await SharedPreferences.getInstance();
  //
  //   bool isLoggedIn = prefs.getBool("isLoggedIn") ?? false;
  //   bool isProfileCompleted = prefs.getBool("isProfileCompleted") ?? false;
  //
  //   // Hold splash for 5 seconds
  //   await Future.delayed(const Duration(seconds: 5));
  //
  //   if (!isLoggedIn) {
  //     Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(builder: (_) => LoginMobileNumber()),
  //     );
  //   } else if (!isProfileCompleted) {
  //     Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(builder: (_) => FillProfile()),
  //     );
  //   } else {
  //     Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(builder: (_) => HomeScreen()),
  //     );
  //   }
  // }

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
                'V 1.2',
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
