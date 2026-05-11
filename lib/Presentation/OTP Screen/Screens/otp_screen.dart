import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tringo_vendor_new/Core/Const/app_logger.dart';
import 'package:tringo_vendor_new/Core/Firebase/fcm_token_helper.dart';
import 'package:tringo_vendor_new/Core/Utility/device_helper.dart';
import 'package:tringo_vendor_new/Presentation/Login%20Screen/Controller/app_version_notifier.dart';

import '../../../../Core/Utility/app_snackbar.dart';
import '../../../../Core/Widgets/common_container.dart';
import '../../../Core/Const/app_color.dart';
import '../../../Core/Const/app_images.dart';
import '../../../Core/Utility/app_loader.dart';
import '../../../Core/Utility/app_textstyles.dart';
import '../../../Core/Widgets/app_go_routes.dart';
import '../../Home Screen/Contoller/employee_home_notifier.dart';
import '../../Login Screen/Controller/login_notifier.dart';
import '../../subscription/Controller/subscription_notifier.dart';

class OtpScreen extends ConsumerStatefulWidget {
  final String phoneNumber;
  const OtpScreen({super.key, required this.phoneNumber});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  // âœ… Create controller once
  final TextEditingController otp = TextEditingController();

  Timer? _timer;
  int _secondsRemaining = 30;
  bool _canResend = false;
  String verifyCode = '';
  String? otpError;
  String? lastLoginPage;

  late final ProviderSubscription<LoginState> _loginSub;

  // âœ… Store notifiers ONCE (NO ref.read inside async listener)
  late final LoginNotifier _loginNotifier;
  late final EmployeeHomeNotifier _employeeHomeNotifier;
  late final SubscriptionNotifier _subscriptionNotifier;
  bool _fcmSent = false;
  Future<void> _sendFcmAfterLogin() async {
    if (_fcmSent) return;
    _fcmSent = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      var fcmToken = (prefs.getString('fcmToken') ?? '').trim();

      if (fcmToken.isEmpty) {
        AppLogger.log.w("âš ï¸ FCM token empty after login");
        fcmToken =
            (await FcmTokenHelper.ensureCachedToken(forceRefresh: true)) ?? '';
        fcmToken = fcmToken.trim();
      }

      if (fcmToken.isEmpty) {
        AppLogger.log.w("âš ï¸ Still no FCM token after login");
        return;
      }

      final deviceId = await DeviceIdHelper.getDeviceId();
      final platform = Platform.isAndroid ? "android" : "ios";

      await ref.read(appVersionNotifierProvider.notifier).fcmTokenSend(
        fcmToken: fcmToken,
        platform: platform,
        deviceId: deviceId,
      );

      AppLogger.log.i("âœ… FCM token sent after OTP login");
    } catch (e) {
      AppLogger.log.e("âŒ FCM send failed: $e");
    }
  }
  @override
  void initState() {
    super.initState();

    // âœ… Safe reads in initState
    _loginNotifier = ref.read(loginNotifierProvider.notifier);
    _employeeHomeNotifier = ref.read(employeeHomeNotifier.notifier);
    _subscriptionNotifier = ref.read(subscriptionNotifier.notifier);

    _startTimer(30);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loginNotifier.resetState();
    });

    // âœ… Listener WITHOUT ref.read INSIDE
    _loginSub = ref.listenManual<LoginState>(loginNotifierProvider, (
      previous,
      next,
    ) async {
      if (!mounted) return;

      /// âŒ Error
      if (next.error != null) {
        AppSnackBar.error(context, next.error!);
        if (!mounted) return;
        _loginNotifier.resetState();
        return;
      }

      /// âœ… OTP VERIFIED
      if (next.otpResponse != null) {
        final data = next.otpResponse!.data;
        final role = (data?.role ?? '').toUpperCase();
        final isNewOwner = data?.isNewOwner ?? false;
        AppLogger.log.w(isNewOwner);

        AppSnackBar.success(context, 'OTP verified successfully!');
        // âœ… Send FCM in background (non-blocking)
        Future(() => _sendFcmAfterLogin());

        // âœ… NAVIGATE FIRST
        if (role == 'VENDOR') {
          final vendorApproved = data?.vendorApproved ?? false;
          final onboarding = data?.onboardingStep;
          final stepMatch = RegExp(r'(\d+)').firstMatch(onboarding ?? '');
          final step =
              stepMatch == null
                  ? null
                  : int.tryParse(stepMatch.group(1) ?? '');

          if (vendorApproved) {
            context.goNamed(AppRoutes.heaterHomeScreen);
          } else if (step != null) {
            switch (step) {
              case 1:
                context.goNamed(AppRoutes.heaterRegister1);
                break;
              case 2:
                context.goNamed(AppRoutes.heaterRegister2);
                break;
              case 3:
                context.goNamed(AppRoutes.vendorCompanyInfo);
                break;
              case 4:
                context.goNamed(AppRoutes.vendorCompanyPhoto);
                break;
              case 5:
                context.goNamed(AppRoutes.heaterAddEmployee);
                break;
              case 6:
                context.goNamed(AppRoutes.employeeApprovalPending);
                break;
              case 7:
                context.goNamed(AppRoutes.heaterHomeScreen);
                break;
              default:
                context.goNamed(
                  isNewOwner
                      ? AppRoutes.heaterRegister1
                      : AppRoutes.employeeApprovalPending,
                );
            }
          } else {
            context.goNamed(
              isNewOwner
                  ? AppRoutes.heaterRegister1
                  : AppRoutes.employeeApprovalPending,
            );
          }
        } else if (role == 'EMPLOYEE') {
          context.goNamed(AppRoutes.home);
        }

        // âš ï¸ After navigation, widget may unmount â†’ check mounted again
        if (!mounted) return;

        // âœ… SAFE ASYNC CALLS (no ref.read)
        try {
          await _employeeHomeNotifier.employeeHome(
            date: '',
            page: '1',
            limit: '6',
            q: '',
          );
        } catch (_) {}

        if (!mounted) return;

        try {
          await _subscriptionNotifier.getPlanList();
        } catch (_) {}

        if (!mounted) return;

        _loginNotifier.resetState();
        return;
      }

      /// ðŸ” RESEND OTP
      if (next.resendOtpResponse != null) {
        final waitSeconds = next.resendOtpResponse!.data?.waitSeconds ?? 30;

        AppSnackBar.success(context, 'OTP resent successfully!');
        if (!mounted) return;

        _startTimer(waitSeconds);
        _loginNotifier.resetState();
      }
    });
  }

  @override
  void dispose() {
    // âœ… close listener FIRST so no callback runs after dispose
    _loginSub.close();
    _timer?.cancel();

    // âœ… IMPORTANT:
    // Your crash says controller is already disposed somewhere else.
    // To avoid double-dispose crash, DO NOT dispose here.
    // If you confirm it is NOT disposed elsewhere, then enable otp.dispose().
    //
    // otp.dispose();

    super.dispose();
  }

  void _startTimer(int seconds) {
    _timer?.cancel();
    setState(() {
      _secondsRemaining = seconds;
      _canResend = false;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_secondsRemaining == 0) {
        setState(() => _canResend = true);
        timer.cancel();
      } else {
        setState(() => _secondsRemaining--);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loginNotifierProvider);
    final notifier = ref.read(loginNotifierProvider.notifier);

    // ref.listen<LoginState>(loginNotifierProvider, (previous, next) async {
    //   final notifier = ref.read(loginNotifierProvider.notifier);
    //
    //   // Error case
    //   if (next.error != null) {
    //     AppSnackBar.error(context, next.error!);
    //     notifier.resetState();
    //   }
    //   // OTP verified
    //   else if (next.otpResponse != null) {
    //     AppSnackBar.success(context, 'OTP verified successfully!');
    //
    //     // final prefs = await SharedPreferences.getInstance();
    //     // final alreadySynced = prefs.getBool('contacts_synced') ?? false;
    //     //
    //     // if (!alreadySynced) {
    //     //   try {
    //     //     // âœ… permission first
    //     //     final contacts = await ContactsService.getAllContacts();
    //     //
    //     //     final limited = contacts.take(200).toList();
    //     //     for (final c in limited) {
    //     //       await ref
    //     //           .read(apiDataSourceProvider)
    //     //           .syncContacts(name: c.name, phone: c.phone);
    //     //     }
    //     //
    //     //     await prefs.setBool('contacts_synced', true);
    //     //     AppLogger.log.i("âœ… Contacts synced: ${limited.length}");
    //     //   } catch (e) {
    //     //     AppLogger.log.e("âŒ Contact sync failed: $e");
    //     //   }
    //     // }
    //     context.goNamed(AppRoutes.privacyPolicy);
    //     notifier.resetState();
    //   }
    //   // Login response (used for resend OTP)
    //   else if (next.loginResponse != null) {
    //     if (lastLoginPage == 'resendOtp') {
    //       AppSnackBar.success(context, 'OTP resent successfully!');
    //
    //       otp.clear(); // âœ… clear old OTP in field
    //       verifyCode = ''; // âœ… reset local value
    //       _startTimer(30);
    //     }
    //     lastLoginPage = null;
    //     notifier.resetState();
    //   }
    // });
    // phoneNumber is non-nullable, so no ??
    final String mobileNumber = widget.phoneNumber;
    late final String maskMobileNumber;

    if (mobileNumber.length <= 3) {
      maskMobileNumber = mobileNumber;
    } else {
      maskMobileNumber =
          'x' * (mobileNumber.length - 3) +
          mobileNumber.substring(mobileNumber.length - 3);
    }

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Image.asset(
              AppImages.loginBCImage,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 35, top: 50),
                          child: Image.asset(
                            AppImages.logo,
                            height: 88,
                            width: 85,
                          ),
                        ),
                        const SizedBox(height: 80),
                        Padding(
                          padding: const EdgeInsets.only(left: 35, top: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Enter 4 Digit OTP',
                                    style: AppTextStyles.mulish(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 24,
                                      color: AppColor.darkBlue,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    'sent to',
                                    style: AppTextStyles.mulish(
                                      fontSize: 24,
                                      color: AppColor.darkBlue,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                'your given Mobile Number',
                                style: AppTextStyles.mulish(
                                  fontSize: 24,
                                  color: AppColor.darkBlue,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 35),
                        // Padding(
                        //   padding: const EdgeInsets.symmetric(horizontal: 35),
                        //   child: PinCodeTextField(
                        //     appContext: context,
                        //     length: 4,
                        //     controller: otp,
                        //     keyboardType: TextInputType.number,
                        //     autoFocus: true,
                        //     enableActiveFill: true,
                        //     pinTheme: PinTheme(
                        //       shape: PinCodeFieldShape.box,
                        //       borderRadius: BorderRadius.circular(17),
                        //       fieldHeight: 55,
                        //       fieldWidth: 55,
                        //       activeFillColor: Colors.white,
                        //       inactiveFillColor: Colors.white,
                        //       selectedFillColor: Colors.white,
                        //       activeColor: AppColor.darkBlue,
                        //       inactiveColor: AppColor.darkBlue,
                        //       selectedColor: AppColor.darkBlue,
                        //     ),
                        //   ),
                        // ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 35),
                          child: PinCodeTextField(
                            appContext: context,
                            length: 4,
                            autoFocus: otp.text.isEmpty,
                            mainAxisAlignment: MainAxisAlignment.start,
                            autoDisposeControllers: false,
                            blinkWhenObscuring: true,
                            controller: otp,
                            keyboardType: TextInputType.number,
                            cursorColor: AppColor.black,
                            animationDuration: const Duration(
                              milliseconds: 300,
                            ),
                            enableActiveFill: true,
                            pinTheme: PinTheme(
                              shape: PinCodeFieldShape.box,
                              borderRadius: BorderRadius.circular(17),
                              fieldHeight: 55,
                              fieldWidth: 55,
                              selectedColor: AppColor.darkBlue,
                              activeColor: AppColor.darkBlue,
                              activeFillColor: AppColor.white,
                              inactiveColor: AppColor.darkBlue,
                              selectedFillColor: AppColor.white,
                              inactiveFillColor: AppColor.white,
                              fieldOuterPadding: const EdgeInsets.symmetric(
                                horizontal: 9,
                              ),
                            ),
                            boxShadows: [
                              BoxShadow(
                                offset: const Offset(0, 1),
                                color: AppColor.skyBlue,
                                blurRadius: 5,
                              ),
                            ],
                            onCompleted: (value) {
                              verifyCode = value;
                            },
                            onChanged: (value) {
                              verifyCode = value;
                              if (otpError != null && value.isNotEmpty) {
                                setState(() {
                                  otpError = null;
                                });
                              }
                            },
                            beforeTextPaste: (text) {
                              return true;
                            },
                          ),
                        ),

                        // const SizedBox(height: 35),
                        // Padding(
                        //   padding: const EdgeInsets.symmetric(horizontal: 35),
                        //   child: Row(
                        //     children: [
                        //       InkWell(
                        //         onTap:
                        //             _canResend && !state.isLoading
                        //                 ? () => _loginNotifier.resendOtp(
                        //                   contact: widget.phoneNumber,
                        //                 )
                        //                 : null,
                        //         child: Text(
                        //           'Resend OTP',
                        //           style: AppTextStyles.mulish(
                        //             fontWeight: FontWeight.w800,
                        //             color:
                        //                 _canResend
                        //                     ? AppColor.skyBlue
                        //                     : AppColor.gray84,
                        //           ),
                        //         ),
                        //       ),
                        //       const Spacer(),
                        //       if (!_canResend)
                        //         Text(
                        //           '00:${_secondsRemaining.toString().padLeft(2, '0')}',
                        //           style: AppTextStyles.mulish(
                        //             fontWeight: FontWeight.w800,
                        //             color: AppColor.darkBlue,
                        //           ),
                        //         ),
                        //     ],
                        //   ),
                        // ),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 35),
                          child: Row(
                            children: [
                              InkWell(
                                onTap:
                                    _canResend
                                        ? () {
                                          // mark as resend call
                                          lastLoginPage = 'resendOtp';
                                          notifier.loginUser(
                                            phoneNumber: widget.phoneNumber,
                                            page: 'resendOtp',
                                          );
                                          _startTimer(30);
                                        }
                                        : null,
                                child: Text(
                                  'Resend',
                                  style: AppTextStyles.mulish(
                                    fontWeight: FontWeight.w800,
                                    color:
                                        _canResend
                                            ? AppColor.skyBlue
                                            : AppColor.gray84,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                _canResend ? 'OTP' : 'code in',
                                style: AppTextStyles.mulish(
                                  fontWeight: FontWeight.w800,
                                  color:
                                      _canResend
                                          ? AppColor.skyBlue
                                          : AppColor.gray84,
                                ),
                              ),
                              if (!_canResend) ...[
                                const SizedBox(width: 4),
                                Text(
                                  '00:${_secondsRemaining.toString().padLeft(2, '0')}',
                                  style: AppTextStyles.mulish(
                                    fontWeight: FontWeight.w800,
                                    color: AppColor.darkBlue,
                                  ),
                                ),
                              ],
                              const Spacer(),
                            ],
                          ),
                        ),

                        // Padding(
                        //   padding: const EdgeInsets.symmetric(horizontal: 35),
                        //   child: Text(
                        //     'OTP sent to $masked. Please enter the OTP.',
                        //     style: AppTextStyles.mulish(
                        //       fontSize: 14,
                        //       color: AppColor.darkGrey,
                        //     ),
                        //   ),
                        // ),
                        const SizedBox(height: 15),

                        // Info text
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 35),
                          child: Text(
                            'OTP sent to $maskMobileNumber, please check and enter below. '
                            'If you\'ve not received OTP, you can resend after the timer ends.',
                            style: AppTextStyles.mulish(
                              fontSize: 14,
                              color: AppColor.darkGrey,
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 35),
                          child: CommonContainer.button(
                            buttonColor: AppColor.skyBlue,
                            onTap: () {
                              final enteredOtp = otp.text.trim();
                              if (enteredOtp.isEmpty) {
                                AppSnackBar.error(context, 'Please enter OTP');
                                return;
                              }
                              _loginNotifier.verifyOtp(
                                contact: widget.phoneNumber,
                                otp: enteredOtp,
                              );
                            },
                            text:
                                state.isLoading
                                    ? const ThreeDotsLoader()
                                    : const Text('Verify Now'),
                          ),
                        ),

                        const SizedBox(height: 50),
                      ],
                    ),
                  ),
                  Image.asset(
                    AppImages.loginScreenBottom,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

