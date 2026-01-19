import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:tringo_vendor_new/Core/Const/app_logger.dart';

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
  // ✅ Create controller once
  final TextEditingController otp = TextEditingController();

  Timer? _timer;
  int _secondsRemaining = 30;
  bool _canResend = false;
  String verifyCode = '';
  String? otpError;
  String? lastLoginPage;

  late final ProviderSubscription<LoginState> _loginSub;

  // ✅ Store notifiers ONCE (NO ref.read inside async listener)
  late final LoginNotifier _loginNotifier;
  late final EmployeeHomeNotifier _employeeHomeNotifier;
  late final SubscriptionNotifier _subscriptionNotifier;

  @override
  void initState() {
    super.initState();

    // ✅ Safe reads in initState
    _loginNotifier = ref.read(loginNotifierProvider.notifier);
    _employeeHomeNotifier = ref.read(employeeHomeNotifier.notifier);
    _subscriptionNotifier = ref.read(subscriptionNotifier.notifier);

    _startTimer(30);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loginNotifier.resetState();
    });

    // ✅ Listener WITHOUT ref.read INSIDE
    _loginSub = ref.listenManual<LoginState>(loginNotifierProvider, (
      previous,
      next,
    ) async {
      if (!mounted) return;

      /// ❌ Error
      if (next.error != null) {
        AppSnackBar.error(context, next.error!);
        if (!mounted) return;
        _loginNotifier.resetState();
        return;
      }

      /// ✅ OTP VERIFIED
      if (next.otpResponse != null) {
        final data = next.otpResponse!.data;
        final role = (data?.role ?? '').toUpperCase();
        final isNewOwner = data?.isNewOwner ?? false;
        AppLogger.log.w(isNewOwner);

        AppSnackBar.success(context, 'OTP verified successfully!');

        // ✅ NAVIGATE FIRST
        if (role == 'VENDOR') {
          if (isNewOwner) {
            context.goNamed(AppRoutes.privacyPolicy);
          } else {
            context.goNamed(AppRoutes.heaterHomeScreen);
          }
        } else if (role == 'EMPLOYEE') {
          context.goNamed(AppRoutes.home);
        }

        // ⚠️ After navigation, widget may unmount → check mounted again
        if (!mounted) return;

        // ✅ SAFE ASYNC CALLS (no ref.read)
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

      /// 🔁 RESEND OTP
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
    // ✅ close listener FIRST so no callback runs after dispose
    _loginSub.close();
    _timer?.cancel();

    // ✅ IMPORTANT:
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
    final mobile = widget.phoneNumber;

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
    //     //     // ✅ permission first
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
    //     //     AppLogger.log.i("✅ Contacts synced: ${limited.length}");
    //     //   } catch (e) {
    //     //     AppLogger.log.e("❌ Contact sync failed: $e");
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
    //       otp.clear(); // ✅ clear old OTP in field
    //       verifyCode = ''; // ✅ reset local value
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
                                'If you’ve not received OTP, you can resend after the timer ends.',
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

/*import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../../../Core/Utility/app_snackbar.dart';
import '../../../../Core/Widgets/common_container.dart';
import '../../../Core/Const/app_color.dart';
import '../../../Core/Const/app_images.dart';
import '../../../Core/Utility/app_loader.dart';
import '../../../Core/Utility/app_textstyles.dart';
import '../../../Core/Widgets/app_go_routes.dart';
import '../../Home Support Screen/Contoller/employee_home_notifier.dart';
import '../../Login Support Screen/Controller/login_notifier.dart';
import '../../subscription/Controller/subscription_notifier.dart';

class OtpScreen extends ConsumerStatefulWidget {
  final String phoneNumber;

  const OtpScreen({super.key, required this.phoneNumber});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final TextEditingController otp = TextEditingController();

  Timer? _timer;
  int _secondsRemaining = 30;
  bool _canResend = false;

  late final ProviderSubscription<LoginState> _loginSub;

  @override
  void initState() {
    super.initState();

    _startTimer(30);

    /// reset login state once screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(loginNotifierProvider.notifier).resetState();
    });

    /// ✅ SAFE LISTENER (NOT in build)
    _loginSub = ref.listenManual<LoginState>(
      loginNotifierProvider,
          (previous, next) async {
        if (!mounted) return;

        final notifier = ref.read(loginNotifierProvider.notifier);

        /// ❌ Error
        if (next.error != null) {
          AppSnackBar.error(context, next.error!);
          notifier.resetState();
          return;
        }

        /// ✅ OTP VERIFIED
        if (next.otpResponse != null) {
          final data = next.otpResponse!.data;
          final role = (data?.role ?? '').toUpperCase();
          final isNewOwner = data?.isNewOwner ?? false;

          AppSnackBar.success(context, 'OTP verified successfully!');

          /// ✅ NAVIGATE FIRST
          if (role == 'VENDOR') {
            if (isNewOwner) {
              context.goNamed(AppRoutes.privacyPolicy);
            } else {
              context.goNamed(AppRoutes.heaterHomeScreen);
            }
          } else if (role == 'EMPLOYEE') {
            context.goNamed(AppRoutes.home);
          }

          if (!mounted) return;

          /// ✅ SAFE ASYNC CALLS AFTER NAVIGATION
          await ref
              .read(employeeHomeNotifier.notifier)
              .employeeHome(date: '', page: '1', limit: '6', q: '');

          await ref
              .read(subscriptionNotifier.notifier)
              .getPlanList();

          notifier.resetState();
          return;
        }

        /// 🔁 RESEND OTP
        if (next.resendOtpResponse != null) {
          final waitSeconds =
              next.resendOtpResponse!.data?.waitSeconds ?? 30;

          AppSnackBar.success(context, 'OTP resent successfully!');
          _startTimer(waitSeconds);

          notifier.resetState();
        }
      },
    );
  }

  @override
  void dispose() {
    _loginSub.close(); // ✅ VERY IMPORTANT
    _timer?.cancel();
    otp.dispose();
    super.dispose();
  }

  void _startTimer(int seconds) {
    _timer?.cancel();
    setState(() {
      _secondsRemaining = seconds;
      _canResend = false;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
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

    final mobile = widget.phoneNumber;
    final masked =
    mobile.length <= 3 ? mobile : 'x' * (mobile.length - 3) + mobile.substring(mobile.length - 3);

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
                          padding: const EdgeInsets.only(left: 35),
                          child: Text(
                            'Enter 4 Digit OTP\nsent to your given Mobile Number',
                            style: AppTextStyles.mulish(
                              fontWeight: FontWeight.w800,
                              fontSize: 24,
                              color: AppColor.darkBlue,
                            ),
                          ),
                        ),

                        const SizedBox(height: 35),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 35),
                          child: PinCodeTextField(
                            appContext: context,
                            length: 4,
                            controller: otp,
                            keyboardType: TextInputType.number,
                            autoFocus: true,
                            enableActiveFill: true,
                            pinTheme: PinTheme(
                              shape: PinCodeFieldShape.box,
                              borderRadius: BorderRadius.circular(17),
                              fieldHeight: 55,
                              fieldWidth: 55,
                              activeFillColor: Colors.white,
                              inactiveFillColor: Colors.white,
                              selectedFillColor: Colors.white,
                              activeColor: AppColor.darkBlue,
                              inactiveColor: AppColor.darkBlue,
                              selectedColor: AppColor.darkBlue,
                            ),
                          ),
                        ),

                        const SizedBox(height: 35),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 35),
                          child: Row(
                            children: [
                              InkWell(
                                onTap: _canResend && !state.isLoading
                                    ? () => notifier.resendOtp(
                                  contact: widget.phoneNumber,
                                )
                                    : null,
                                child: Text(
                                  'Resend OTP',
                                  style: AppTextStyles.mulish(
                                    fontWeight: FontWeight.w800,
                                    color: _canResend
                                        ? AppColor.skyBlue
                                        : AppColor.gray84,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              if (!_canResend)
                                Text(
                                  '00:${_secondsRemaining.toString().padLeft(2, '0')}',
                                  style: AppTextStyles.mulish(
                                    fontWeight: FontWeight.w800,
                                    color: AppColor.darkBlue,
                                  ),
                                ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 35),
                          child: Text(
                            'OTP sent to $masked. Please enter the OTP.',
                            style: AppTextStyles.mulish(
                              fontSize: 14,
                              color: AppColor.darkGrey,
                            ),
                          ),
                        ),

                        const SizedBox(height: 35),

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
                              notifier.verifyOtp(
                                contact: widget.phoneNumber,
                                otp: enteredOtp,
                              );
                            },
                            text: state.isLoading
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
}*/

///old///
// import 'dart:async';
//
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import 'package:pin_code_fields/pin_code_fields.dart';
// import '../../../../Core/Utility/app_snackbar.dart';
// import '../../../../Core/Widgets/common_container.dart';
// import '../../../Core/Const/app_color.dart';
// import '../../../Core/Const/app_images.dart';
// import '../../../Core/Utility/app_loader.dart';
// import '../../../Core/Utility/app_textstyles.dart';
// import '../../../Core/Widgets/app_go_routes.dart';
// import '../../../Core/Widgets/heater_bottom_navigation_bar.dart';
// import '../../Home Support Screen/Contoller/employee_home_notifier.dart';
// import '../../Login Support Screen/Controller/login_notifier.dart';
// import '../../subscription/Controller/subscription_notifier.dart';
//
// class OtpScreen extends ConsumerStatefulWidget {
//   final String phoneNumber;
//
//   const OtpScreen({super.key, required this.phoneNumber});
//
//   @override
//   ConsumerState<OtpScreen> createState() => _OtpScreenState();
// }
//
// class _OtpScreenState extends ConsumerState<OtpScreen> {
//   final TextEditingController otp = TextEditingController();
//
//   String? otpError;
//   String verifyCode = '';
//
//   Timer? _timer;
//   int _secondsRemaining = 30;
//   bool _canResend = false;
//
//   String? lastLoginPage;
//
//   @override
//   void initState() {
//     super.initState();
//
//     // Start the countdown timer
//     _startTimer(30);
//
//     // Reset login state when screen opens
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       ref.read(loginNotifierProvider.notifier).resetState();
//     });
//   }
//
//   @override
//   void dispose() {
//     _timer?.cancel();
//     otp.dispose();
//     super.dispose();
//   }
//
//   void _startTimer(int seconds) {
//     _timer?.cancel();
//     setState(() {
//       _secondsRemaining = seconds;
//       _canResend = false;
//     });
//
//     _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       if (_secondsRemaining == 0) {
//         setState(() {
//           _canResend = true;
//         });
//         _timer?.cancel();
//       } else {
//         setState(() {
//           _secondsRemaining--;
//         });
//       }
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final state = ref.watch(loginNotifierProvider);
//     final notifier = ref.read(loginNotifierProvider.notifier);
//
//     ref.listen<LoginState>(loginNotifierProvider, (previous, next) async {
//       final notifier = ref.read(loginNotifierProvider.notifier);
//
//       if (next.error != null) {
//         AppSnackBar.error(context, next.error!);
//         notifier.resetState();
//       } else if (next.otpResponse != null) {
//         final data = next.otpResponse!.data;
//         final role = (data?.role ?? '').toUpperCase();
//         final isNewOwner = data?.isNewOwner ?? false;
//
//         AppSnackBar.success(context, 'OTP verified successfully!');
//
//         if (role == 'VENDOR') {
//           if (isNewOwner) {
//             context.goNamed(AppRoutes.privacyPolicy);
//           } else {
//
//             context.goNamed(AppRoutes.heaterHomeScreen);
//             await ref.read(employeeHomeNotifier.notifier).employeeHome(date: '', page: '1', limit: '6', q: '');
//             await ref.read(subscriptionNotifier.notifier).getPlanList();
//           }
//         } else if (role == 'EMPLOYEE') {
//
//           context.goNamed(AppRoutes.home);
//           await ref.read(employeeHomeNotifier.notifier).employeeHome(date: '', page: '1', limit: '6', q: '');
//           await ref.read(subscriptionNotifier.notifier).getPlanList();
//         } else {
//           AppSnackBar.error(context, 'Unknown role: $role');
//         }
//
//         notifier.resetState();
//       } else if (next.resendOtpResponse != null) {
//         final data = next.resendOtpResponse!.data;
//         final waitSeconds = data?.waitSeconds ?? 30;
//
//         AppSnackBar.success(context, 'OTP resent successfully!');
//         _startTimer(waitSeconds);
//
//         notifier.resetState();
//       }
//     });
//
//     final String mobileNumber = widget.phoneNumber;
//     late final String maskMobileNumber;
//
//     if (mobileNumber.length <= 3) {
//       maskMobileNumber = mobileNumber;
//     } else {
//       maskMobileNumber =
//           'x' * (mobileNumber.length - 3) +
//           mobileNumber.substring(mobileNumber.length - 3);
//     }
//     return Scaffold(
//       body: SafeArea(
//         child: Stack(
//           children: [
//             Image.asset(
//               AppImages.loginBCImage,
//               width: double.infinity,
//               height: double.infinity,
//               fit: BoxFit.cover,
//             ),
//             // Positioned(
//             //   top: 0,
//             //   left: 0,
//             //   right: 0,
//             //   bottom: 140,
//             //   child:
//             // ),
//
//             // Bottom decoration
//             Positioned(
//               bottom: 0,
//               left: 0,
//               right: 0,
//               child: Column(
//                 children: [
//                   SingleChildScrollView(
//                     padding: const EdgeInsets.only(bottom: 20),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // Logo
//                         Padding(
//                           padding: const EdgeInsets.only(left: 35, top: 50),
//                           child: Image.asset(
//                             AppImages.logo,
//                             height: 88,
//                             width: 85,
//                           ),
//                         ),
//
//                         SizedBox(height: 81),
//
//                         // Title
//                         Padding(
//                           padding: const EdgeInsets.only(left: 35, top: 20),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Row(
//                                 children: [
//                                   Text(
//                                     'Enter 4 Digit OTP',
//                                     style: AppTextStyles.mulish(
//                                       fontWeight: FontWeight.w800,
//                                       fontSize: 24,
//                                       color: AppColor.darkBlue,
//                                     ),
//                                   ),
//                                   SizedBox(width: 5),
//                                   Text(
//                                     'sent to',
//                                     style: AppTextStyles.mulish(
//                                       fontSize: 24,
//                                       color: AppColor.darkBlue,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               Text(
//                                 'your given Mobile Number',
//                                 style: AppTextStyles.mulish(
//                                   fontSize: 24,
//                                   color: AppColor.darkBlue,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//
//                         SizedBox(height: 35),
//
//                         // OTP fields
//                         Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 35),
//                           child: PinCodeTextField(
//                             appContext: context,
//                             length: 4,
//                             autoFocus: otp.text.isEmpty,
//                             mainAxisAlignment: MainAxisAlignment.start,
//                             autoDisposeControllers: false,
//                             blinkWhenObscuring: true,
//                             controller: otp,
//                             keyboardType: TextInputType.number,
//                             cursorColor: AppColor.black,
//                             animationDuration: const Duration(
//                               milliseconds: 300,
//                             ),
//                             enableActiveFill: true,
//                             pinTheme: PinTheme(
//                               shape: PinCodeFieldShape.box,
//                               borderRadius: BorderRadius.circular(17),
//                               fieldHeight: 55,
//                               fieldWidth: 55,
//                               selectedColor: AppColor.darkBlue,
//                               activeColor: AppColor.darkBlue,
//                               activeFillColor: AppColor.white,
//                               inactiveColor: AppColor.darkBlue,
//                               selectedFillColor: AppColor.white,
//                               inactiveFillColor: AppColor.white,
//                               fieldOuterPadding: const EdgeInsets.symmetric(
//                                 horizontal: 9,
//                               ),
//                             ),
//                             boxShadows: [
//                               BoxShadow(
//                                 offset: Offset(0, 1),
//                                 color: AppColor.skyBlue,
//                                 blurRadius: 5,
//                               ),
//                             ],
//                             onCompleted: (value) {
//                               verifyCode = value;
//                             },
//                             onChanged: (value) {
//                               verifyCode = value;
//                               if (otpError != null && value.isNotEmpty) {
//                                 setState(() {
//                                   otpError = null;
//                                 });
//                               }
//                             },
//                             beforeTextPaste: (text) {
//                               return true;
//                             },
//                           ),
//                         ),
//
//                         if (otpError != null)
//                           Center(
//                             child: Text(
//                               otpError!,
//                               style: AppTextStyles.mulish(
//                                 color: AppColor.red,
//                                 fontSize: 14,
//                               ),
//                               textAlign: TextAlign.center,
//                             ),
//                           ),
//
//                         SizedBox(height: 35),
//
//                         // Resend row
//                         Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 35),
//                           child: Row(
//                             children: [
//                               InkWell(
//                                 onTap:
//                                     _canResend && !state.isLoading
//                                         ? () {
//                                           notifier.resendOtp(
//                                             contact: widget.phoneNumber,
//                                           );
//                                         }
//                                         : null,
//                                 child:
//                                     state.isLoading && _canResend
//                                         ? const SizedBox(
//                                           height: 16,
//                                           width: 16,
//                                           child: CircularProgressIndicator(
//                                             strokeWidth: 2,
//                                           ),
//                                         )
//                                         : Text(
//                                           'Resend',
//                                           style: AppTextStyles.mulish(
//                                             fontWeight: FontWeight.w800,
//                                             color:
//                                                 _canResend
//                                                     ? AppColor.skyBlue
//                                                     : AppColor.gray84,
//                                           ),
//                                         ),
//                               ),
//                               SizedBox(width: 5),
//                               Text(
//                                 _canResend ? 'OTP' : 'code in',
//                                 style: AppTextStyles.mulish(
//                                   fontWeight: FontWeight.w800,
//                                   color:
//                                       _canResend
//                                           ? AppColor.skyBlue
//                                           : AppColor.gray84,
//                                 ),
//                               ),
//                               if (!_canResend) ...[
//                                 SizedBox(width: 4),
//                                 Text(
//                                   '00:${_secondsRemaining.toString().padLeft(2, '0')}',
//                                   style: AppTextStyles.mulish(
//                                     fontWeight: FontWeight.w800,
//                                     color: AppColor.darkBlue,
//                                   ),
//                                 ),
//                               ],
//                               Spacer(),
//                             ],
//                           ),
//                         ),
//
//                         SizedBox(height: 12),
//
//                         // Info text
//                         Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 35),
//                           child: Text(
//                             'OTP sent to $maskMobileNumber, please check and enter below. '
//                             'If you’ve not received OTP, you can resend after the timer ends.',
//                             style: AppTextStyles.mulish(
//                               fontSize: 14,
//                               color: AppColor.darkGrey,
//                             ),
//                           ),
//                         ),
//
//                         SizedBox(height: 35),
//
//                         // Verify button
//                         Padding(
//                           padding: EdgeInsets.symmetric(horizontal: 35),
//                           child: CommonContainer.button(
//                             buttonColor: AppColor.skyBlue,
//                             onTap: () {
//                               final enteredOtp = otp.text.trim();
//                               if (enteredOtp.isEmpty) {
//                                 ScaffoldMessenger.of(context).showSnackBar(
//                                   SnackBar(content: Text('Please enter OTP')),
//                                 );
//                                 return;
//                               }
//                               notifier.verifyOtp(
//                                 contact: widget.phoneNumber,
//                                 otp: enteredOtp,
//                               );
//                             },
//                             text:
//                                 state.isLoading
//                                     ? ThreeDotsLoader()
//                                     : Text('Verify Now'),
//                           ),
//                         ),
//
//                         SizedBox(height: 50),
//                       ],
//                     ),
//                   ),
//                   Image.asset(
//                     AppImages.loginScreenBottom,
//                     width: double.infinity,
//                     fit: BoxFit.cover,
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
