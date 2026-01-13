import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:country_picker/country_picker.dart'; // ⬅️ NEW
import 'package:mobile_number/mobile_number.dart';

import '../../../Core/Const/app_color.dart';
import '../../../Core/Const/app_images.dart';
import '../../../Core/Utility/app_loader.dart';
import '../../../Core/Utility/app_snackbar.dart';
import '../../../Core/Utility/app_textstyles.dart';
import '../../../Core/Utility/sim_token.dart';
import '../../../Core/Widgets/app_go_routes.dart';
import '../../../Core/Widgets/common_container.dart';
import '../Controller/login_notifier.dart';

class LoginMobileNumber extends ConsumerStatefulWidget {
  const LoginMobileNumber({super.key});

  @override
  ConsumerState<LoginMobileNumber> createState() => _LoginMobileNumberState();
}

class _LoginMobileNumberState extends ConsumerState<LoginMobileNumber> {
  bool isWhatsappChecked = false;
  String errorText = '';
  bool _isFormatting = false;
  final TextEditingController mobileNumberController = TextEditingController();
  String? _lastRawPhone;

  ProviderSubscription<LoginState>? _sub;

  String _selectedDialCode = '+91';
  String _selectedFlag = '🇮🇳';

  // 🔹 Ask phone/SIM permission as soon as login screen opens
  Future<void> _ensurePhonePermission() async {
    try {
      final hasPermission = await MobileNumber.hasPhonePermission;
      if (!hasPermission) {
        await MobileNumber.requestPhonePermission;
      }

      // Optional: debug log
      final after = await MobileNumber.hasPhonePermission;
      debugPrint('PHONE PERMISSION AFTER REQUEST: $after');
    } catch (e, st) {
      debugPrint('❌ Error requesting phone permission: $e');
      debugPrint('$st');
    }
  }

  @override
  void initState() {
    super.initState();

    // ✅ Request permission immediately
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _ensurePhonePermission();
    });

    _sub = ref.listenManual<LoginState>(loginNotifierProvider, (
      prev,
      next,
    ) async {
      if (!mounted) return;

      // ❌ remove this line from here:
      // _ensurePhonePermission();

      if (next.error != null) {
        AppSnackBar.error(context, next.error!);
        return;
      }

      if (next.whatsappResponse != null) {
        final resp = next.whatsappResponse!;
        final hasWhatsapp = resp.data.hasWhatsapp;

        if (hasWhatsapp) {
          setState(() => isWhatsappChecked = true);

          final raw = _lastRawPhone;
          if (raw != null) {
            final fullPhone = '$_selectedDialCode$raw';
            final simToken = generateSimToken(fullPhone);

            ref
                .read(loginNotifierProvider.notifier)
                .loginUser(phoneNumber: raw, simToken: simToken);
          }
        } else {
          setState(() => isWhatsappChecked = false);
          AppSnackBar.error(
            context,
            'This number is not registered on WhatsApp. Please use a WhatsApp number.',
          );
        }
      }

      if (next.loginResponse != null) {
        await _ensurePhonePermission();

        final raw = _lastRawPhone ?? '';
        final fullPhone = '$_selectedDialCode$raw';
        final simToken = generateSimToken(fullPhone);

        // context.pushNamed(
        //   AppRoutes.mobileNumberVerify,
        //   extra: {'phone': raw, 'simToken': simToken},
        // );
        context.pushNamed(AppRoutes.otp, extra: raw);
        ref.read(loginNotifierProvider.notifier).resetState();
      }
    });
  }

  // @override
  // void initState() {
  //   super.initState();
  //
  //   _sub = ref.listenManual<LoginState>(loginNotifierProvider, (prev, next) {
  //     if (!mounted) return;
  //
  //     _ensurePhonePermission();
  //
  //     // 1) API error
  //     if (next.error != null) {
  //       AppSnackBar.error(context, next.error!);
  //       return;
  //     }
  //
  //     // 2) WhatsApp verify result
  //     if (next.whatsappResponse != null) {
  //       final resp = next.whatsappResponse!;
  //       final hasWhatsapp = resp.data.hasWhatsapp;
  //
  //       if (hasWhatsapp) {
  //         setState(() => isWhatsappChecked = true);
  //
  //         final raw = _lastRawPhone;
  //         if (raw != null) {
  //           final fullPhone = '$_selectedDialCode$raw';
  //           final simToken = generateSimToken(fullPhone);
  //
  //           // NOTE: your backend currently builds "+91$phone" inside request.
  //           // For full multi-country support, update backend later.
  //           print(simToken);
  //           ref
  //               .read(loginNotifierProvider.notifier)
  //               .loginUser(phoneNumber: raw, simToken: simToken);
  //         }
  //       } else {
  //         setState(() => isWhatsappChecked = false);
  //         AppSnackBar.error(
  //           context,
  //           'This number is not registered on WhatsApp. Please use a WhatsApp number.',
  //         );
  //       }
  //     }
  //
  //     // 3) Login result -> navigate to SIM/OTP verify screen
  //     if (next.loginResponse != null) {
  //       final raw = _lastRawPhone ?? '';
  //       final fullPhone = '$_selectedDialCode$raw';
  //       final simToken = generateSimToken(fullPhone);
  //
  //       context.pushNamed(
  //         AppRoutes.mobileNumberVerify,
  //         extra: {'phone': raw, 'simToken': simToken},
  //       );
  //
  //       ref.read(loginNotifierProvider.notifier).resetState();
  //     }
  //   });
  // }

  @override
  void dispose() {
    _sub?.close();
    mobileNumberController.dispose();
    super.dispose();
  }

  void _formatPhoneNumber(String value) {
    setState(() => errorText = '');

    if (_isFormatting) return;
    _isFormatting = true;

    String digitsOnly = value.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length > 10) digitsOnly = digitsOnly.substring(0, 10);

    String formatted = '';
    for (int i = 0; i < digitsOnly.length; i++) {
      if (i == 4 || i == 7) formatted += ' ';
      formatted += digitsOnly[i];
    }

    mobileNumberController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );

    _isFormatting = false;
  }

  // 🔹 Show Country Picker (ALL countries, with flag & dial code)
  void _showCountryPicker() {
    showCountryPicker(
      context: context,
      showPhoneCode: true,
      onSelect: (Country country) {
        setState(() {
          _selectedDialCode = '+${country.phoneCode}';
          _selectedFlag = country.flagEmoji;
        });
      },
      countryListTheme: CountryListThemeData(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        // 🔹 Modern search box styling
        inputDecoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey.shade100,
          hintText: 'Search country or code',
          hintStyle: AppTextStyles.mulish(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColor.borderLightGrey,
          ),
          prefixIcon: const Icon(Icons.search_rounded, size: 22),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),

          // No strong border, just a soft pill
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: AppColor.skyBlue, width: 1.5),
          ),
          // Remove error border visuals (not really needed here)
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
        bottomSheetHeight: 500,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loginNotifierProvider);
    final notifier = ref.read(loginNotifierProvider.notifier);

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Image.asset(
              AppImages.loginBCImage,
              width: double.infinity,
              fit: BoxFit.cover,
              height: double.infinity,
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
                        // Logo
                        Padding(
                          padding: const EdgeInsets.only(left: 35, top: 50),
                          child: Image.asset(
                            AppImages.logo,
                            height: 88,
                            width: 85,
                          ),
                        ),
                        const SizedBox(height: 81),

                        // Titles
                        Padding(
                          padding: const EdgeInsets.only(left: 35, top: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Login',
                                    style: AppTextStyles.mulish(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 24,
                                      color: AppColor.darkBlue,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    'With',
                                    style: AppTextStyles.mulish(
                                      fontSize: 24,
                                      color: AppColor.darkBlue,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                'Your Mobile Number',
                                style: AppTextStyles.mulish(
                                  fontSize: 24,
                                  color: AppColor.darkBlue,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 35),

                        // Phone input
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 35),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColor.white,
                              borderRadius: BorderRadius.circular(17),
                              border: Border.all(
                                color:
                                    mobileNumberController.text.isNotEmpty
                                        ? AppColor.skyBlue
                                        : AppColor.black,
                                width:
                                    mobileNumberController.text.isNotEmpty
                                        ? 2
                                        : 1.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                // 🔹 Country selector (flag + code + dropdown)
                                GestureDetector(
                                  onTap: _showCountryPicker,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        _selectedFlag,
                                        style: const TextStyle(fontSize: 20),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        _selectedDialCode,
                                        style: AppTextStyles.mulish(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14,
                                          color: AppColor.gray84,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Image.asset(
                                        AppImages.drapDownImage,
                                        height: 14,
                                        color: AppColor.darkGrey,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  width: 2,
                                  height: 35,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        AppColor.white.withOpacity(0.5),
                                        AppColor.white3,
                                        AppColor.white3,
                                        AppColor.white.withOpacity(0.5),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(1),
                                  ),
                                ),
                                const SizedBox(width: 9),
                                Expanded(
                                  child: TextFormField(
                                    controller: mobileNumberController,
                                    keyboardType: TextInputType.phone,
                                    maxLength: 12,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    style: AppTextStyles.mulish(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 20,
                                    ),
                                    onChanged: _formatPhoneNumber,
                                    decoration: InputDecoration(
                                      counterText: '',
                                      hintText: 'Enter Mobile Number',
                                      hintStyle: AppTextStyles.mulish(
                                        fontWeight: FontWeight.w600,
                                        color: AppColor.borderLightGrey,
                                        fontSize: 16,
                                      ),
                                      border: InputBorder.none,
                                      suffixIcon:
                                          mobileNumberController.text.isNotEmpty
                                              ? GestureDetector(
                                                onTap: () {
                                                  mobileNumberController
                                                      .clear();
                                                  setState(() {});
                                                },
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 17,
                                                      ),
                                                  child: Image.asset(
                                                    AppImages.closeImage,
                                                    width: 10,
                                                    height: 10,
                                                    fit: BoxFit.contain,
                                                  ),
                                                ),
                                              )
                                              : null,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 35),

                        // WhatsApp checkbox row
                        Padding(
                          padding: const EdgeInsets.only(left: 25, right: 10),
                          child: ListTile(
                            dense: true,
                            minLeadingWidth: 0,
                            horizontalTitleGap: 10,
                            leading: Image.asset(
                              AppImages.whatsAppBlack,
                              height: 20,
                            ),
                            title: Text(
                              'Get Instant Updates',
                              style: AppTextStyles.mulish(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: AppColor.darkBlue,
                              ),
                            ),
                            subtitle: Row(
                              children: [
                                Text(
                                  'From Tringo on your',
                                  style: AppTextStyles.mulish(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: AppColor.darkGrey,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  'whatsapp',
                                  style: AppTextStyles.mulish(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: AppColor.gray84,
                                  ),
                                ),
                              ],
                            ),
                            trailing: GestureDetector(
                              onTap: () {
                                setState(() {
                                  isWhatsappChecked = !isWhatsappChecked;
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color:
                                        isWhatsappChecked
                                            ? AppColor.green
                                            : AppColor.darkGrey,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child:
                                      isWhatsappChecked
                                          ? Image.asset(
                                            AppImages.tickImage,
                                            height: 12,
                                            color: AppColor.green,
                                          )
                                          : const SizedBox(
                                            width: 12,
                                            height: 12,
                                          ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 35),

                        // VERIFY BUTTON
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 35),
                          child: CommonContainer.button2(
                            width: double.infinity,
                            loader: state.isLoading ? ThreeDotsLoader() : null,
                            onTap:
                                state.isLoading
                                    ? null
                                    : () async {
                                      final formatted =
                                          mobileNumberController.text.trim();
                                      final rawPhone = formatted.replaceAll(
                                        ' ',
                                        '',
                                      );

                                      if (rawPhone.isEmpty) {
                                        AppSnackBar.info(
                                          context,
                                          'Please enter phone number',
                                        );
                                        return;
                                      }
                                      if (rawPhone.length != 10) {
                                        // For true international validation,
                                        // handle per-country length later.
                                        AppSnackBar.info(
                                          context,
                                          'Please enter a valid 10-digit number',
                                        );
                                        return;
                                      }

                                      _lastRawPhone = rawPhone;

                                      await notifier.verifyWhatsappNumber(
                                        contact: rawPhone,
                                        purpose: 'vendor',
                                      );
                                    },
                            text: 'Verify Now',
                          ),
                        ),

                        const SizedBox(height: 50),
                      ],
                    ),
                  ),
                  Image.asset(
                    AppImages.loginScreenBottom,
                    fit: BoxFit.cover,
                    width: double.infinity,
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

// import 'package:country_picker/country_picker.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import 'package:tringo_vendor_new/Core/Utility/app_textstyles.dart';
//
// import '../../../Core/Const/app_color.dart';
// import '../../../Core/Const/app_images.dart';
// import '../../../Core/Utility/app_loader.dart';
// import '../../../Core/Utility/app_snackbar.dart';
// import '../../../Core/Widgets/app_go_routes.dart';
// import '../../../Core/Widgets/common_container.dart';
// import '../Controller/login_notifier.dart';
//
// class LoginMobileNumber extends ConsumerStatefulWidget {
//   const LoginMobileNumber({super.key});
//
//   @override
//   ConsumerState<LoginMobileNumber> createState() => _LoginMobileNumberState();
// }
//
// class _LoginMobileNumberState extends ConsumerState<LoginMobileNumber> {
//   bool isWhatsappChecked = false; // ⬅ start unchecked
//   String errorText = '';
//   bool _isFormatting = false;
//   // 🔹 Selected country data (default = India)
//   String _selectedDialCode = '+91';
//   String _selectedFlag = '🇮🇳';
//   final TextEditingController mobileNumberController = TextEditingController();
//
//   String? _lastRawPhone;
//
//   @override
//   void initState() {
//     super.initState();
//   }
//
//   void _showCountryPicker() {
//     showCountryPicker(
//       context: context,
//       showPhoneCode: true,
//       onSelect: (Country country) {
//         setState(() {
//           _selectedDialCode = '+${country.phoneCode}';
//           _selectedFlag = country.flagEmoji;
//         });
//       },
//       countryListTheme: CountryListThemeData(
//         borderRadius: const BorderRadius.only(
//           topLeft: Radius.circular(16),
//           topRight: Radius.circular(16),
//         ),
//         // 🔹 Modern search box styling
//         inputDecoration: InputDecoration(
//           filled: true,
//           fillColor: Colors.grey.shade100,
//           hintText: 'Search country or code',
//           hintStyle: AppTextStyles.mulish(
//             fontSize: 14,
//             fontWeight: FontWeight.w500,
//             color: AppColor.borderLightGrey,
//           ),
//           prefixIcon: const Icon(Icons.search_rounded, size: 22),
//           contentPadding: const EdgeInsets.symmetric(
//             horizontal: 16,
//             vertical: 12,
//           ),
//
//           // No strong border, just a soft pill
//           enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(30),
//             borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(30),
//             borderSide: BorderSide(color: AppColor.skyBlue, width: 1.5),
//           ),
//           // Remove error border visuals (not really needed here)
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(30),
//             borderSide: BorderSide.none,
//           ),
//         ),
//         bottomSheetHeight: 500,
//       ),
//     );
//   }
//
//   void _formatPhoneNumber(String value) {
//     setState(() => errorText = '');
//
//     if (_isFormatting) return;
//
//     _isFormatting = true;
//     String digitsOnly = value.replaceAll(' ', '');
//
//     if (digitsOnly.length > 10) {
//       digitsOnly = digitsOnly.substring(0, 10);
//     }
//
//     String formatted = '';
//     for (int i = 0; i < digitsOnly.length; i++) {
//       if (i == 4 || i == 7) {
//         formatted += ' ';
//       }
//       formatted += digitsOnly[i];
//     }
//
//     mobileNumberController.value = TextEditingValue(
//       text: formatted,
//       selection: TextSelection.collapsed(offset: formatted.length),
//     );
//
//     _isFormatting = false;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final state = ref.watch(loginNotifierProvider);
//     final notifier = ref.read(loginNotifierProvider.notifier);
//
//     ref.listen<LoginState>(loginNotifierProvider, (prev, next) {
//       if (!mounted) return;
//
//       if (next.error != null) {
//         AppSnackBar.error(context, next.error!);
//         return;
//       }
//
//       if (next.whatsappResponse != null) {
//         final hasWhatsapp = next.whatsappResponse!.data.hasWhatsapp;
//
//         if (hasWhatsapp) {
//           setState(() => isWhatsappChecked = true);
//
//           final raw = _lastRawPhone;
//           if (raw != null) {
//             ref
//                 .read(loginNotifierProvider.notifier)
//                 .loginUser(phoneNumber: raw);
//           }
//         } else {
//           setState(() => isWhatsappChecked = false);
//           AppSnackBar.error(
//             context,
//             'This number is not registered on WhatsApp. Please use a WhatsApp number.',
//           );
//         }
//       }
//
//       if (next.loginResponse != null) {
//         AppSnackBar.success(context, 'OTP sent successfully!');
//         final raw = _lastRawPhone ?? '';
//         context.pushNamed(AppRoutes.mobileNumberVerify, extra: raw);
//         ref.read(loginNotifierProvider.notifier).resetState();
//       }
//     });
//     return Scaffold(
//       body: SafeArea(
//         child: Stack(
//           children: [
//             Image.asset(
//               AppImages.loginBCImage,
//               width: double.infinity,
//               fit: BoxFit.cover,
//               height: double.infinity,
//             ),
//
//             // Positioned(
//             //   top: 0,
//             //   left: 0,
//             //   right: 0,
//             //   bottom: 120,
//             //   child:
//             // ),
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
//                         // LOGO
//                         Padding(
//                           padding: const EdgeInsets.only(left: 35, top: 50),
//                           child: Image.asset(
//                             AppImages.logo,
//                             height: 88,
//                             width: 85,
//                           ),
//                         ),
//                         SizedBox(height: 81),
//
//                         Padding(
//                           padding: const EdgeInsets.only(left: 35, top: 20),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Row(
//                                 children: [
//                                   Text(
//                                     'Login',
//                                     style: AppTextStyles.mulish(
//                                       fontWeight: FontWeight.w800,
//                                       fontSize: 24,
//                                       color: AppColor.darkBlue,
//                                     ),
//                                   ),
//                                   SizedBox(width: 5),
//                                   Text(
//                                     'With',
//                                     style: AppTextStyles.mulish(
//                                       fontSize: 24,
//                                       color: AppColor.darkBlue,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               Text(
//                                 'Your Mobile Number',
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
//                         Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 35),
//                           child: Container(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 20,
//                               vertical: 6,
//                             ),
//                             decoration: BoxDecoration(
//                               color: AppColor.white,
//                               borderRadius: BorderRadius.circular(17),
//                               border: Border.all(
//                                 color:
//                                     mobileNumberController.text.isNotEmpty
//                                         ? AppColor.skyBlue
//                                         : AppColor.black,
//                                 width:
//                                     mobileNumberController.text.isNotEmpty
//                                         ? 2
//                                         : 1.5,
//                               ),
//                             ),
//                             child: Row(
//                               children: [
//                                 GestureDetector(
//                                   onTap: _showCountryPicker,
//                                   child: Row(
//                                     mainAxisSize: MainAxisSize.min,
//                                     children: [
//                                       Text(
//                                         _selectedFlag,
//                                         style: const TextStyle(fontSize: 20),
//                                       ),
//                                       const SizedBox(width: 6),
//                                       Text(
//                                         _selectedDialCode,
//                                         style: AppTextStyles.mulish(
//                                           fontWeight: FontWeight.w700,
//                                           fontSize: 14,
//                                           color: AppColor.gray84,
//                                         ),
//                                       ),
//                                       const SizedBox(width: 4),
//                                       Image.asset(
//                                         AppImages.drapDownImage,
//                                         height: 14,
//                                         color: AppColor.darkGrey,
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//
//                                 // Text(
//                                 //   '+91',
//                                 //   style: AppTextStyles.mulish(
//                                 //     fontWeight: FontWeight.w700,
//                                 //     fontSize: 14,
//                                 //     color: AppColor.gray84,
//                                 //   ),
//                                 // ),
//                                 SizedBox(width: 8),
//                                 Container(
//                                   width: 2,
//                                   height: 35,
//                                   decoration: BoxDecoration(
//                                     gradient: LinearGradient(
//                                       begin: Alignment.topCenter,
//                                       end: Alignment.bottomCenter,
//                                       colors: [
//                                         AppColor.white.withOpacity(0.5),
//                                         AppColor.white3,
//                                         AppColor.white3,
//                                         AppColor.white.withOpacity(0.5),
//                                       ],
//                                     ),
//                                     borderRadius: BorderRadius.circular(1),
//                                   ),
//                                 ),
//                                 SizedBox(width: 9),
//                                 Expanded(
//                                   child: TextFormField(
//                                     controller: mobileNumberController,
//                                     keyboardType: TextInputType.phone,
//                                     maxLength: 12, // 10 digits + 2 spaces
//                                     inputFormatters: [
//                                       FilteringTextInputFormatter.digitsOnly,
//                                     ],
//                                     style: AppTextStyles.mulish(
//                                       fontWeight: FontWeight.w700,
//                                       fontSize: 20,
//                                     ),
//                                     onChanged: _formatPhoneNumber,
//                                     decoration: InputDecoration(
//                                       counterText: '',
//                                       hintText: 'Enter Mobile Number',
//                                       hintStyle: AppTextStyles.mulish(
//                                         fontWeight: FontWeight.w600,
//                                         color: AppColor.borderLightGrey,
//                                         fontSize: 16,
//                                       ),
//                                       border: InputBorder.none,
//                                       suffixIcon:
//                                           mobileNumberController.text.isNotEmpty
//                                               ? GestureDetector(
//                                                 onTap: () {
//                                                   mobileNumberController
//                                                       .clear();
//                                                   setState(() {});
//                                                 },
//                                                 child: Padding(
//                                                   padding:
//                                                       const EdgeInsets.symmetric(
//                                                         vertical: 17,
//                                                       ),
//                                                   child: Image.asset(
//                                                     AppImages.closeImage,
//                                                     width: 8,
//                                                     height: 8,
//                                                     fit: BoxFit.contain,
//                                                   ),
//                                                 ),
//                                               )
//                                               : null,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//
//                         SizedBox(height: 35),
//
//                         Padding(
//                           padding: const EdgeInsets.only(left: 25, right: 10),
//                           child: ListTile(
//                             dense: true,
//                             minLeadingWidth: 0,
//                             horizontalTitleGap: 10,
//                             leading: Image.asset(
//                               AppImages.whatsAppBlack,
//                               height: 20,
//                             ),
//                             title: Text(
//                               'Get Instant Updates',
//                               style: AppTextStyles.mulish(
//                                 fontSize: 12,
//                                 fontWeight: FontWeight.w800,
//                                 color: AppColor.darkBlue,
//                               ),
//                             ),
//                             subtitle: Row(
//                               children: [
//                                 Text(
//                                   'From Tringo on your',
//                                   style: AppTextStyles.mulish(
//                                     fontSize: 10,
//                                     fontWeight: FontWeight.w500,
//                                     color: AppColor.darkGrey,
//                                   ),
//                                 ),
//                                 SizedBox(width: 5),
//                                 Text(
//                                   'whatsapp',
//                                   style: AppTextStyles.mulish(
//                                     fontSize: 10,
//                                     fontWeight: FontWeight.w700,
//                                     color: AppColor.gray84,
//                                   ),
//                                 ),
//                               ],
//                             ),
//
//                             trailing: GestureDetector(
//                               onTap: () {
//                                 setState(() {
//                                   isWhatsappChecked = !isWhatsappChecked;
//                                 });
//                               },
//                               child: Container(
//                                 decoration: BoxDecoration(
//                                   border: Border.all(
//                                     color:
//                                         isWhatsappChecked
//                                             ? AppColor.green
//                                             : AppColor.darkGrey,
//                                     width: 2,
//                                   ),
//                                   borderRadius: BorderRadius.circular(12),
//                                 ),
//                                 child: Padding(
//                                   padding: const EdgeInsets.all(8.0),
//                                   child:
//                                       isWhatsappChecked
//                                           ? Image.asset(
//                                             AppImages.tickImage,
//                                             height: 12,
//                                             color: AppColor.green,
//                                           )
//                                           : SizedBox(width: 12, height: 12),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//
//                         SizedBox(height: 35),
//
//                         // VERIFY BUTTON
//                         Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 35),
//                           child: CommonContainer.button2(
//                             width: double.infinity,
//                             loader: state.isLoading ? ThreeDotsLoader() : null,
//                             onTap:
//                                 state.isLoading
//                                     ? null
//                                     : () async {
//                                       final formatted =
//                                           mobileNumberController.text.trim();
//                                       final rawPhone = formatted.replaceAll(
//                                         ' ',
//                                         '',
//                                       );
//
//                                       if (rawPhone.isEmpty) {
//                                         AppSnackBar.info(
//                                           context,
//                                           'Please enter phone number',
//                                         );
//                                         return;
//                                       }
//                                       if (rawPhone.length != 10) {
//                                         AppSnackBar.info(
//                                           context,
//                                           'Please enter a valid 10-digit number',
//                                         );
//                                         return;
//                                       }
//
//                                       _lastRawPhone = rawPhone;
//
//                                       await notifier.verifyWhatsappNumber(
//                                         contact: rawPhone,
//                                         purpose: 'owner', //  important
//                                       );
//                                     },
//                             text: 'Verify Now',
//                           ),
//                         ),
//
//                         // Padding(
//                         //   padding: const EdgeInsets.symmetric(horizontal: 35),
//                         //   child: CommonContainer.button(
//                         //     isLoading: state.isLoading, // 👈 VERY IMPORTANT
//                         //     loader: ThreeDotsLoader(dotColor: AppColor.black),
//                         //
//                         //     onTap:
//                         //         state.isLoading
//                         //             ? null
//                         //             : () async {
//                         //               final formatted =
//                         //                   mobileNumberController.text.trim();
//                         //               final rawPhone = formatted.replaceAll(
//                         //                 ' ',
//                         //                 '',
//                         //               );
//                         //
//                         //               if (rawPhone.isEmpty) {
//                         //                 AppSnackBar.info(
//                         //                   context,
//                         //                   'Please enter phone number',
//                         //                 );
//                         //                 return;
//                         //               }
//                         //
//                         //               if (rawPhone.length != 10) {
//                         //                 AppSnackBar.info(
//                         //                   context,
//                         //                   'Please enter a valid 10-digit number',
//                         //                 );
//                         //                 return;
//                         //               }
//                         //
//                         //               _lastRawPhone = rawPhone;
//                         //
//                         //               await notifier.verifyWhatsappNumber(
//                         //                 contact: rawPhone,
//                         //                 purpose: 'owner', // important
//                         //               );
//                         //             },
//                         //
//                         //     text: Text('Verify Now'),
//                         //   ),
//                         // ),
//                         SizedBox(height: 50),
//                       ],
//                     ),
//                   ),
//                   Image.asset(
//                     AppImages.loginScreenBottom,
//                     fit: BoxFit.cover,
//                     width: double.infinity,
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
