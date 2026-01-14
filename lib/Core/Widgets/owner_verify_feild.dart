import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

import '../Const/app_color.dart';
import '../Const/app_images.dart';
import '../Utility/app_textstyles.dart';

/// ✅ OTP Paste Formatter: paste "1234" in any box → fills all boxes
class OtpPasteFormatter extends TextInputFormatter {
  OtpPasteFormatter({
    required this.controllers,
    required this.focusNodes,
    required this.onPasteStart,
    required this.onPasteEnd,
    required this.onFilled,
  });

  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final VoidCallback onPasteStart;
  final VoidCallback onPasteEnd;
  final VoidCallback onFilled;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.length <= 1) return newValue;

    onPasteStart();

    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) {
      onPasteEnd();
      return const TextEditingValue(text: '');
    }

    final n = controllers.length;
    final take = digits.length > n ? n : digits.length;

    for (int i = 0; i < n; i++) {
      controllers[i].text = (i < take) ? digits[i] : '';
    }

    // Focus last box when all filled, else next empty
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (take >= n) {
        focusNodes.last.requestFocus();
        onFilled();
      } else {
        focusNodes[take].requestFocus();
      }
      onPasteEnd();
    });

    // keep current field stable; show first digit to avoid empty first box
    final first = controllers[0].text;
    return TextEditingValue(
      text: first,
      selection: TextSelection.collapsed(offset: first.length),
    );
  }
}

class OwnerVerifyField extends StatefulWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final FormFieldValidator<String>? validator;
  final bool isLoading;
  final bool isOtpVerifying;
  final bool readOnly;

  final Future<String?> Function(String mobile)? onSendOtp;
  final Future<bool> Function(String mobile, String otp)? onVerifyOtp;

  const OwnerVerifyField({
    super.key,
    this.controller,
    this.focusNode,
    this.validator,
    this.isLoading = false,
    this.isOtpVerifying = false,
    this.readOnly = false,
    this.onSendOtp,
    this.onVerifyOtp,
  });

  @override
  State<OwnerVerifyField> createState() => _OwnerVerifyFieldState();
}

class _OwnerVerifyFieldState extends State<OwnerVerifyField> {
  final List<TextEditingController> otpControllers = List.generate(
    4,
    (_) => TextEditingController(),
  );

  final List<FocusNode> otpFocusNodes = List.generate(4, (_) => FocusNode());

  bool showOtp = false;
  bool isVerified = false;
  bool showOtpError = false;

  int resendSeconds = 30;
  Timer? resendTimer;
  bool _isPastingOtp = false;

  void startResendTimer() {
    resendTimer?.cancel();
    resendSeconds = 30;

    resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendSeconds == 0) {
        timer.cancel();
      } else {
        if (mounted) setState(() => resendSeconds--);
      }
    });
  }

  void _clearOtp() {
    for (final c in otpControllers) {
      c.clear();
    }
    showOtpError = false;
  }

  void _openOtpBox() {
    if (!mounted) return;
    setState(() {
      showOtp = true;
      showOtpError = false;
      _clearOtp();
      startResendTimer();
    });

    FocusScope.of(context).unfocus();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) otpFocusNodes.first.requestFocus();
    });
  }

  void _closeOtpBox({bool focusMobile = false}) {
    if (!mounted) return;
    setState(() {
      showOtp = false;
      showOtpError = false;
    });

    if (focusMobile) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.focusNode?.requestFocus();
      });
    } else {
      FocusScope.of(context).unfocus();
    }
  }

  @override
  void dispose() {
    resendTimer?.cancel();
    for (final c in otpControllers) {
      c.dispose();
    }
    for (final f in otpFocusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textValue = widget.controller?.text ?? '';
    final isTenDigits = textValue.length == 10;
    final hasMobile = textValue.isNotEmpty;
    final last4Digits =
        hasMobile && textValue.length >= 4
            ? textValue.substring(textValue.length - 4)
            : '';

    // ✅ LOCK: OTP typing time phone number should not be editable
    final bool lockMobileField = showOtp && !isVerified;

    return FormField<String>(
      validator: widget.validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      builder: (state) {
        final hasError = state.hasError;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: const Color(0xFFF5F5F5),
                border: Border.all(
                  color: hasError ? Colors.red : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: widget.controller,
                            focusNode: widget.focusNode,

                            enabled: !lockMobileField && !widget.readOnly,
                            readOnly: lockMobileField || widget.readOnly,

                            maxLength: 10,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              OtpPasteFormatter(
                                controllers: otpControllers,
                                focusNodes: otpFocusNodes,
                                onPasteStart: () => _isPastingOtp = true,
                                onPasteEnd: () => _isPastingOtp = false,
                                onFilled: () {
                                  if (mounted)
                                    setState(() => showOtpError = false);
                                },
                              ),
                            ],

                            decoration: const InputDecoration(
                              counterText: '',
                              hintText: ' ',
                              border: InputBorder.none,
                            ),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color:
                                  lockMobileField ? Colors.grey : Colors.black,
                              letterSpacing: 0.5,
                            ),

                            onChanged:
                                lockMobileField
                                    ? null
                                    : (v) {
                                      state.didChange(v);
                                      setState(() {
                                        showOtpError = false;
                                        if (!isVerified) showOtp = false;
                                      });
                                    },
                          ),
                        ),

                        if (hasMobile && !isVerified && !lockMobileField)
                          GestureDetector(
                            onTap: () {
                              widget.controller?.clear();
                              state.didChange('');
                              setState(() {
                                showOtp = false;
                                showOtpError = false;
                                resendTimer?.cancel();
                              });
                            },
                            child: const Icon(
                              Icons.close,
                              color: Colors.grey,
                              size: 20,
                            ),
                          ),

                        const SizedBox(width: 8),

                        Container(
                          width: 2,
                          height: 30,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.grey.shade200,
                                Colors.grey.shade300,
                                Colors.grey.shade200,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),

                        const SizedBox(width: 8),

                        if (!hasMobile)
                          Text(
                            'Mobile No',
                            style: AppTextStyles.mulish(
                              color: AppColor.mediumGray,
                            ),
                          ),

                        if (isTenDigits && !isVerified && !showOtp)
                          GestureDetector(
                            onTap:
                                widget.isLoading
                                    ? null
                                    : () async {
                                      if (widget.onSendOtp == null ||
                                          widget.controller == null)
                                        return;

                                      final err = await widget.onSendOtp!(
                                        widget.controller!.text,
                                      );
                                      if (err != null) {
                                        showTopSnackBar(
                                          Overlay.of(context),
                                          CustomSnackBar.error(message: err),
                                        );
                                        return;
                                      }

                                      _openOtpBox();
                                    },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    widget.isLoading
                                        ? Colors.grey
                                        : const Color(0xFF2196F3),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child:
                                  widget.isLoading
                                      ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                      : Text(
                                        "Verify",
                                        style: AppTextStyles.mulish(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                            ),
                          ),

                        if (isVerified)
                          Container(
                            decoration: BoxDecoration(
                              color: AppColor.green,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 5,
                            ),
                            child: Row(
                              children: [
                                Image.asset(
                                  AppImages.tickImage,
                                  height: 11,
                                  color: AppColor.white,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Verified',
                                  style: AppTextStyles.mulish(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),

                    /// ================= OTP BOX =================
                    if (showOtp && !isVerified && hasMobile) ...[
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F2F2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () => _closeOtpBox(focusMobile: true),
                                  child: Icon(
                                    Icons.arrow_back_ios_new,
                                    size: 14,
                                    color: AppColor.mediumGray,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    "OTP Sent to your xxx$last4Digits",
                                    style: AppTextStyles.mulish(
                                      color: AppColor.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "If you didn’t get otp by sms, resend otp using the button",
                              style: AppTextStyles.mulish(
                                color: AppColor.darkGrey,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),

                            GestureDetector(
                              onTap:
                                  resendSeconds > 0 || widget.isLoading
                                      ? null
                                      : () async {
                                        if (widget.onSendOtp == null ||
                                            widget.controller == null)
                                          return;

                                        final err = await widget.onSendOtp!(
                                          widget.controller!.text,
                                        );
                                        if (err != null) {
                                          showTopSnackBar(
                                            Overlay.of(context),
                                            CustomSnackBar.error(message: err),
                                          );
                                          return;
                                        }

                                        if (!mounted) return;
                                        setState(() {
                                          _clearOtp();
                                          startResendTimer();
                                        });

                                        WidgetsBinding.instance
                                            .addPostFrameCallback((_) {
                                              otpFocusNodes.first
                                                  .requestFocus();
                                            });
                                      },
                              child: Text(
                                resendSeconds > 0
                                    ? "Resend in ${resendSeconds}s"
                                    : "Resend OTP",
                                style: AppTextStyles.mulish(
                                  color: AppColor.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ...List.generate(4, (index) {
                                  return SizedBox(
                                    width: 53,
                                    height: 52,
                                    child: TextField(
                                      controller: otpControllers[index],
                                      focusNode: otpFocusNodes[index],
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      maxLength: 1,
                                      style: AppTextStyles.mulish(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                        OtpPasteFormatter(
                                          onPasteStart:
                                              () => _isPastingOtp = true,
                                          onPasteEnd:
                                              () => _isPastingOtp = false,
                                          controllers: otpControllers,
                                          focusNodes: otpFocusNodes,
                                          onFilled: () {
                                            if (mounted) {
                                              setState(
                                                () => showOtpError = false,
                                              );
                                            }
                                          },
                                        ),
                                      ],
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Colors.white,
                                        counterText: '',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            15,
                                          ),
                                          borderSide: BorderSide(
                                            color:
                                                showOtpError
                                                    ? Colors.red
                                                    : Colors.white,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            15,
                                          ),
                                          borderSide: BorderSide(
                                            color:
                                                showOtpError
                                                    ? Colors.red
                                                    : Colors.white,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            15,
                                          ),
                                          borderSide: const BorderSide(
                                            color: Colors.black,
                                            width: 2.5,
                                          ),
                                        ),
                                      ),
                                      onChanged: (value) {
                                        if (mounted)
                                          setState(() => showOtpError = false);

                                        // ✅ ignore focus shifting while paste is happening
                                        if (_isPastingOtp) return;

                                        if (value.length == 1 && index < 3) {
                                          otpFocusNodes[index + 1]
                                              .requestFocus();
                                        } else if (value.isEmpty && index > 0) {
                                          otpFocusNodes[index - 1]
                                              .requestFocus();
                                        }
                                      },
                                    ),
                                  );
                                }),

                                GestureDetector(
                                  onTap:
                                      widget.isOtpVerifying
                                          ? null
                                          : () async {
                                            if (widget.onVerifyOtp == null ||
                                                widget.controller == null)
                                              return;

                                            final otp =
                                                otpControllers
                                                    .map((c) => c.text)
                                                    .join();
                                            if (otp.length != 4) {
                                              setState(
                                                () => showOtpError = true,
                                              );
                                              return;
                                            }

                                            final ok = await widget
                                                .onVerifyOtp!(
                                              widget.controller!.text,
                                              otp,
                                            );

                                            if (!ok) {
                                              setState(
                                                () => showOtpError = true,
                                              );
                                              return;
                                            }

                                            if (!mounted) return;
                                            setState(() {
                                              isVerified = true;
                                              showOtp = false;
                                              showOtpError = false;
                                              resendTimer?.cancel();
                                            });

                                            FocusScope.of(context).unfocus();
                                          },
                                  child: Container(
                                    width: 53,
                                    height: 52,
                                    decoration: BoxDecoration(
                                      color:
                                          widget.isOtpVerifying
                                              ? Colors.grey
                                              : Colors.black,
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child:
                                        widget.isOtpVerifying
                                            ? const Padding(
                                              padding: EdgeInsets.all(12),
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white,
                                              ),
                                            )
                                            : const Icon(
                                              Icons.check,
                                              color: Colors.white,
                                            ),
                                  ),
                                ),
                              ],
                            ),

                            if (showOtpError)
                              Padding(
                                padding: const EdgeInsets.only(top: 8, left: 4),
                                child: Text(
                                  "⚠️ Please Enter Valid OTP",
                                  style: AppTextStyles.mulish(
                                    color: Colors.red,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            if (hasError)
              Padding(
                padding: const EdgeInsets.only(left: 12.0, top: 4),
                child: Text(
                  state.errorText ?? '',
                  style: AppTextStyles.mulish(color: Colors.red, fontSize: 12),
                ),
              ),
          ],
        );
      },
    );
  }
}

// import 'dart:async';
//
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:top_snackbar_flutter/custom_snack_bar.dart';
// import 'package:top_snackbar_flutter/top_snack_bar.dart';
//
// import '../Const/app_color.dart';
// import '../Const/app_images.dart';
// import '../Utility/app_textstyles.dart';
//
// class OwnerVerifyField extends StatefulWidget {
//   final TextEditingController? controller;
//   final FocusNode? focusNode;
//   final FormFieldValidator<String>? validator;
//   final bool isLoading;
//   final bool isOtpVerifying;
//   final bool readOnly;
//
//   final Future<String?> Function(String mobile)? onSendOtp;
//   final Future<bool> Function(String mobile, String otp)? onVerifyOtp;
//
//   const OwnerVerifyField({
//     super.key,
//     this.controller,
//     this.focusNode,
//     this.validator,
//     this.isLoading = false,
//     this.isOtpVerifying = false,
//     this.readOnly = false,
//     this.onSendOtp,
//     this.onVerifyOtp,
//   });
//
//   @override
//   State<OwnerVerifyField> createState() => _OwnerVerifyFieldState();
// }
//
// class _OwnerVerifyFieldState extends State<OwnerVerifyField> {
//   final List<TextEditingController> otpControllers = List.generate(
//     4,
//         (_) => TextEditingController(),
//   );
//
//   // ✅ focus nodes for OTP boxes (better UX)
//   final List<FocusNode> otpFocusNodes = List.generate(4, (_) => FocusNode());
//
//   bool showOtp = false;
//   bool isVerified = false;
//   bool showOtpError = false;
//
//   int resendSeconds = 30;
//   Timer? resendTimer;
//
//   void startResendTimer() {
//     resendTimer?.cancel();
//     resendSeconds = 30;
//
//     resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       if (resendSeconds == 0) {
//         timer.cancel();
//       } else {
//         if (mounted) setState(() => resendSeconds--);
//       }
//     });
//   }
//
//   void _clearOtp() {
//     for (final c in otpControllers) {
//       c.clear();
//     }
//     showOtpError = false;
//   }
//
//   void _openOtpBox() {
//     if (!mounted) return;
//     setState(() {
//       showOtp = true;
//       showOtpError = false;
//       _clearOtp();
//       startResendTimer();
//     });
//
//     // ✅ remove focus from mobile field & focus first OTP box
//     FocusScope.of(context).unfocus();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (mounted) {
//         otpFocusNodes.first.requestFocus();
//       }
//     });
//   }
//
//   void _closeOtpBox({bool focusMobile = false}) {
//     if (!mounted) return;
//     setState(() {
//       showOtp = false;
//       showOtpError = false;
//     });
//
//     if (focusMobile) {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         widget.focusNode?.requestFocus();
//       });
//     } else {
//       FocusScope.of(context).unfocus();
//     }
//   }
//
//   @override
//   void dispose() {
//     resendTimer?.cancel();
//     for (final c in otpControllers) {
//       c.dispose();
//     }
//     for (final f in otpFocusNodes) {
//       f.dispose();
//     }
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final textValue = widget.controller?.text ?? '';
//     final isTenDigits = textValue.length == 10;
//     final hasMobile = textValue.isNotEmpty;
//     final last4Digits =
//     hasMobile && textValue.length >= 4 ? textValue.substring(textValue.length - 4) : '';
//
//     // ✅ LOCK: OTP typing time phone number should not be editable
//     final bool lockMobileField = showOtp && !isVerified;
//
//     return FormField<String>(
//       validator: widget.validator,
//       autovalidateMode: AutovalidateMode.onUserInteraction,
//       builder: (state) {
//         final hasError = state.hasError;
//
//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Container(
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(20),
//                 color: const Color(0xFFF5F5F5),
//                 border: Border.all(
//                   color: hasError ? Colors.red : Colors.transparent,
//                   width: 1.5,
//                 ),
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         Expanded(
//                           child: TextFormField(
//                             controller: widget.controller,
//                             focusNode: widget.focusNode,
//
//                             // ✅ IMPORTANT FIX
//                             enabled: !lockMobileField && !widget.readOnly,
//                             readOnly: lockMobileField || widget.readOnly,
//
//                             maxLength: 10,
//                             keyboardType: TextInputType.number,
//                             inputFormatters: [
//                               FilteringTextInputFormatter.digitsOnly,
//                               LengthLimitingTextInputFormatter(10),
//                             ],
//                             decoration: const InputDecoration(
//                               counterText: '',
//                               hintText: ' ',
//                               border: InputBorder.none,
//                             ),
//                             style: TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.w600,
//                               color: lockMobileField ? Colors.grey : Colors.black, // ✅ grey look
//                               letterSpacing: 0.5,
//                             ),
//
//                             // ✅ prevent onChanged when locked
//                             onChanged: lockMobileField
//                                 ? null
//                                 : (v) {
//                               state.didChange(v);
//                               setState(() {
//                                 showOtpError = false;
//                                 if (!isVerified) showOtp = false;
//                               });
//                             },
//                           ),
//                         ),
//
//                         if (hasMobile && !isVerified && !lockMobileField)
//                           GestureDetector(
//                             onTap: () {
//                               widget.controller?.clear();
//                               state.didChange('');
//                               setState(() {
//                                 showOtp = false;
//                                 showOtpError = false;
//                                 resendTimer?.cancel();
//                               });
//                             },
//                             child: const Icon(
//                               Icons.close,
//                               color: Colors.grey,
//                               size: 20,
//                             ),
//                           ),
//
//                         const SizedBox(width: 8),
//
//                         Container(
//                           width: 2,
//                           height: 30,
//                           decoration: BoxDecoration(
//                             gradient: LinearGradient(
//                               begin: Alignment.topCenter,
//                               end: Alignment.bottomCenter,
//                               colors: [
//                                 Colors.grey.shade200,
//                                 Colors.grey.shade300,
//                                 Colors.grey.shade200,
//                               ],
//                             ),
//                             borderRadius: BorderRadius.circular(1),
//                           ),
//                         ),
//
//                         const SizedBox(width: 8),
//
//                         if (!hasMobile)
//                           Text(
//                             'Mobile No',
//                             style: AppTextStyles.mulish(
//                               color: AppColor.mediumGray,
//                             ),
//                           ),
//
//                         if (isTenDigits && !isVerified && !showOtp)
//                           GestureDetector(
//                             onTap: widget.isLoading
//                                 ? null
//                                 : () async {
//                               if (widget.onSendOtp == null || widget.controller == null) return;
//
//                               final err = await widget.onSendOtp!(widget.controller!.text);
//                               if (err != null) {
//                                 showTopSnackBar(
//                                   Overlay.of(context),
//                                   CustomSnackBar.error(message: err),
//                                 );
//                                 return;
//                               }
//
//                               _openOtpBox();
//                             },
//                             child: Container(
//                               padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
//                               decoration: BoxDecoration(
//                                 color: widget.isLoading ? Colors.grey : const Color(0xFF2196F3),
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               child: widget.isLoading
//                                   ? const SizedBox(
//                                 width: 18,
//                                 height: 18,
//                                 child: CircularProgressIndicator(
//                                   strokeWidth: 2,
//                                   color: Colors.white,
//                                 ),
//                               )
//                                   : Text(
//                                 "Verify",
//                                 style: AppTextStyles.mulish(
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.w700,
//                                 ),
//                               ),
//                             ),
//                           ),
//
//                         if (isVerified)
//                           Container(
//                             decoration: BoxDecoration(
//                               color: AppColor.green,
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                             padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
//                             child: Row(
//                               children: [
//                                 Image.asset(
//                                   AppImages.tickImage,
//                                   height: 11,
//                                   color: AppColor.white,
//                                 ),
//                                 const SizedBox(width: 6),
//                                 Text(
//                                   'Verified',
//                                   style: AppTextStyles.mulish(
//                                     color: Colors.white,
//                                     fontWeight: FontWeight.w700,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                       ],
//                     ),
//
//                     if (showOtp && !isVerified && hasMobile) ...[
//                       const SizedBox(height: 16),
//                       Container(
//                         decoration: BoxDecoration(
//                           color: const Color(0xFFF2F2F2),
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                         padding: const EdgeInsets.all(16),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Row(
//                               children: [
//                                 GestureDetector(
//                                   onTap: () {
//                                     _closeOtpBox(focusMobile: true);
//                                   },
//                                   child: Icon(
//                                     Icons.arrow_back_ios_new,
//                                     size: 14,
//                                     color: AppColor.mediumGray,
//                                   ),
//                                 ),
//                                 const SizedBox(width: 6),
//                                 Expanded(
//                                   child: Text(
//                                     "OTP Sent to your xxx$last4Digits",
//                                     style: AppTextStyles.mulish(
//                                       color: AppColor.black,
//                                       fontSize: 18,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(height: 8),
//                             Text(
//                               "If you didn’t get otp by sms, resend otp using the button",
//                               style: AppTextStyles.mulish(
//                                 color: AppColor.darkGrey,
//                                 fontSize: 14,
//                               ),
//                             ),
//                             const SizedBox(height: 8),
//                             GestureDetector(
//                               onTap: resendSeconds > 0 || widget.isLoading
//                                   ? null
//                                   : () async {
//                                 if (widget.onSendOtp == null || widget.controller == null) return;
//
//                                 final err = await widget.onSendOtp!(widget.controller!.text);
//                                 if (err != null) {
//                                   showTopSnackBar(
//                                     Overlay.of(context),
//                                     CustomSnackBar.error(message: err),
//                                   );
//                                   return;
//                                 }
//
//                                 if (!mounted) return;
//                                 setState(() {
//                                   _clearOtp();
//                                   startResendTimer();
//                                 });
//
//                                 WidgetsBinding.instance.addPostFrameCallback((_) {
//                                   otpFocusNodes.first.requestFocus();
//                                 });
//                               },
//                               child: Text(
//                                 resendSeconds > 0 ? "Resend in ${resendSeconds}s" : "Resend OTP",
//                                 style: AppTextStyles.mulish(
//                                   color: AppColor.blue,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(height: 16),
//
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                               children: [
//                                 ...List.generate(4, (index) {
//                                   return SizedBox(
//                                     width: 53,
//                                     height: 52,
//                                     child: TextField(
//                                       controller: otpControllers[index],
//                                       focusNode: otpFocusNodes[index],
//                                       textAlign: TextAlign.center,
//                                       keyboardType: TextInputType.number,
//                                       maxLength: 1,
//                                       style: AppTextStyles.mulish(
//                                         fontSize: 22,
//                                         fontWeight: FontWeight.bold,
//                                         color: Colors.black,
//                                       ),
//                                       decoration: InputDecoration(
//                                         filled: true,
//                                         fillColor: Colors.white,
//                                         counterText: '',
//                                         border: OutlineInputBorder(
//                                           borderRadius: BorderRadius.circular(15),
//                                           borderSide: BorderSide(
//                                             color: showOtpError ? Colors.red : Colors.white,
//                                           ),
//                                         ),
//                                         enabledBorder: OutlineInputBorder(
//                                           borderRadius: BorderRadius.circular(15),
//                                           borderSide: BorderSide(
//                                             color: showOtpError ? Colors.red : Colors.white,
//                                           ),
//                                         ),
//                                         focusedBorder: OutlineInputBorder(
//                                           borderRadius: BorderRadius.circular(15),
//                                           borderSide: const BorderSide(
//                                             color: Colors.black,
//                                             width: 2.5,
//                                           ),
//                                         ),
//                                       ),
//                                       onChanged: (value) {
//                                         // move forward
//                                         if (value.isNotEmpty && index < 3) {
//                                           otpFocusNodes[index + 1].requestFocus();
//                                         }
//                                         // move back
//                                         if (value.isEmpty && index > 0) {
//                                           otpFocusNodes[index - 1].requestFocus();
//                                         }
//                                       },
//                                     ),
//                                   );
//                                 }),
//
//                                 GestureDetector(
//                                   onTap: widget.isOtpVerifying
//                                       ? null
//                                       : () async {
//                                     if (widget.onVerifyOtp == null || widget.controller == null) return;
//
//                                     final otp = otpControllers.map((c) => c.text).join();
//                                     if (otp.length != 4) {
//                                       setState(() => showOtpError = true);
//                                       return;
//                                     }
//
//                                     final ok = await widget.onVerifyOtp!(
//                                       widget.controller!.text,
//                                       otp,
//                                     );
//
//                                     if (!ok) {
//                                       setState(() => showOtpError = true);
//                                       return;
//                                     }
//
//                                     if (!mounted) return;
//                                     setState(() {
//                                       isVerified = true;
//                                       showOtp = false;
//                                       showOtpError = false;
//                                       resendTimer?.cancel();
//                                     });
//
//                                     FocusScope.of(context).unfocus();
//                                   },
//                                   child: Container(
//                                     width: 53,
//                                     height: 52,
//                                     decoration: BoxDecoration(
//                                       color: widget.isOtpVerifying ? Colors.grey : Colors.black,
//                                       borderRadius: BorderRadius.circular(15),
//                                     ),
//                                     child: widget.isOtpVerifying
//                                         ? const Padding(
//                                       padding: EdgeInsets.all(12),
//                                       child: CircularProgressIndicator(
//                                         strokeWidth: 2,
//                                         color: Colors.white,
//                                       ),
//                                     )
//                                         : const Icon(
//                                       Icons.check,
//                                       color: Colors.white,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//
//                             if (showOtpError)
//                               Padding(
//                                 padding: const EdgeInsets.only(top: 8, left: 4),
//                                 child: Text(
//                                   "⚠️ Please Enter Valid OTP",
//                                   style: AppTextStyles.mulish(
//                                     color: Colors.red,
//                                     fontSize: 13,
//                                   ),
//                                 ),
//                               ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ],
//                 ),
//               ),
//             ),
//
//             if (hasError)
//               Padding(
//                 padding: const EdgeInsets.only(left: 12.0, top: 4),
//                 child: Text(
//                   state.errorText ?? '',
//                   style: AppTextStyles.mulish(color: Colors.red, fontSize: 12),
//                 ),
//               ),
//           ],
//         );
//       },
//     );
//   }
// }
//
//
//
