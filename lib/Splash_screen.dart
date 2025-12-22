import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tringo_vendor_new/Core/Const/app_logger.dart';

import 'package:tringo_vendor_new/Core/Utility/app_textstyles.dart';

import 'Core/Const/app_color.dart';
import 'Core/Const/app_images.dart';
import 'Core/Widgets/app_go_routes.dart';
import 'Presentation/Home Screen/Contoller/employee_home_notifier.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    checkNavigation();
  }

  Future<void> checkNavigation() async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString('token') ?? '';
    final role = (prefs.getString('role') ?? '').toUpperCase();
    final vendorStatus =
        (prefs.getString('vendorStatus') ?? 'PENDING').toUpperCase();

    AppLogger.log.i('token=$token role=$role vendorStatus=$vendorStatus');

    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    // ❌ Not logged in
    if (token.isEmpty) {
      context.go(AppRoutes.loginPath);
      return;
    }

    await ref
        .read(employeeHomeNotifier.notifier)
        .employeeHome(date: '', page: '1', limit: '6', q: '');
    //  EMPLOYEE → always home
    if (role == 'EMPLOYEE') {
      context.goNamed(AppRoutes.home);
      return;
    }

    // VENDOR flow
    if (role == 'VENDOR') {
      if (vendorStatus == 'ACTIVE') {
        context.go(AppRoutes.heaterHomeScreenPath);
      } else {
        // PENDING / REJECTED
        context.go(AppRoutes.employeeApprovalPendingPath);
      }
      return;
    }

    // fallback
    context.go(AppRoutes.loginPath);
  }

  // Future<void> checkNavigation() async {
  //   final prefs = await SharedPreferences.getInstance();
  //
  //   final String token = prefs.getString("token") ?? '';
  //   final String sessionToken = prefs.getString("sessionToken") ?? '';
  //
  //
  //
  //   AppLogger.log.i('sessionToken : $sessionToken \n token : $token');
  //
  //   await Future.delayed(const Duration(seconds: 5));
  //
  //   if (!mounted) return;
  //
  //   if (token.isNotEmpty) {
  //     context.go(AppRoutes.heaterHomeScreenPath);
  //   } else {
  //     // context.go(AppRoutes.employeeApprovalPendingPath);
  //     context.go(AppRoutes.loginPath);
  //     // context.go(AppRoutes.loginPath);
  //   }
  // }
  //

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
