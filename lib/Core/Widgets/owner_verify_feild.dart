import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../Const/app_color.dart';
import '../Const/app_images.dart';
import '../Utility/app_textstyles.dart';

class  OwnerVerifyField  extends StatefulWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final FormFieldValidator<String>? validator;
  final bool isLoading;
  final bool isOtpVerifying;
  final bool readOnly;

  final Future<bool> Function(String mobile)? onSendOtp;
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
  final List<TextEditingController> otpControllers =
  List.generate(4, (_) => TextEditingController());

  bool showOtp = false;
  bool isVerified = false;
  bool showOtpError = false;

  int resendSeconds = 30;
  Timer? resendTimer;

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

  @override
  void dispose() {
    resendTimer?.cancel();
    for (final c in otpControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textValue = widget.controller?.text ?? '';
    final isTenDigits = textValue.length == 10;
    final hasMobile = textValue.isNotEmpty;
    final last4Digits =
    hasMobile && textValue.length >= 4 ? textValue.substring(textValue.length - 4) : '';

    return FormField<String>(
      validator: widget.validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      builder: (state) {
        final hasError = state.hasError;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mobile Number',
              style: AppTextStyles.mulish(color: AppColor.mildBlack),
            ),
            const SizedBox(height: 10),

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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: widget.controller,
                            focusNode: widget.focusNode,
                            readOnly: widget.readOnly,
                            maxLength: 10,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10),
                            ],
                            decoration: const InputDecoration(
                              counterText: '',
                              hintText: ' ',
                              border: InputBorder.none,
                            ),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                              letterSpacing: 0.5,
                            ),
                            onChanged: (v) {
                              state.didChange(v);
                              setState(() {
                                showOtpError = false;
                                if (!isVerified) showOtp = false;
                              });
                            },
                          ),
                        ),

                        if (hasMobile && !isVerified)
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
                            child: const Icon(Icons.close, color: Colors.grey, size: 20),
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
                            style: AppTextStyles.mulish(color: AppColor.mediumGray),
                          ),

                        if (isTenDigits && !isVerified && !showOtp)
                          GestureDetector(
                            onTap: widget.isLoading
                                ? null
                                : () async {
                              if (widget.onSendOtp == null || widget.controller == null) return;

                              final success = await widget.onSendOtp!(widget.controller!.text);
                              if (!success) return;

                              if (!mounted) return;
                              setState(() {
                                showOtp = true; // this now persists
                                showOtpError = false;
                                for (final c in otpControllers) {
                                  c.clear();
                                }
                                startResendTimer();
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: widget.isLoading ? Colors.grey : const Color(0xFF2196F3),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: widget.isLoading
                                  ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
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
                            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                            child: Row(
                              children: [
                                Image.asset(AppImages.tickImage, height: 11, color: AppColor.white),
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
                                  onTap: () {
                                    setState(() {
                                      showOtp = false;
                                      showOtpError = false;
                                    });
                                  },
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
                              onTap: resendSeconds > 0 || widget.isLoading
                                  ? null
                                  : () async {
                                if (widget.onSendOtp == null || widget.controller == null) return;
                                final success = await widget.onSendOtp!(widget.controller!.text);
                                if (!success) return;
                                if (!mounted) return;
                                setState(() {
                                  for (final c in otpControllers) c.clear();
                                  showOtpError = false;
                                  startResendTimer();
                                });
                              },
                              child: Text(
                                resendSeconds > 0 ? "Resend in ${resendSeconds}s" : "Resend OTP",
                                style: AppTextStyles.mulish(
                                  color: AppColor.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                             SizedBox(height: 16),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ...List.generate(4, (index) {
                                  return SizedBox(
                                    width: 53,
                                    height: 52,
                                    child: TextField(
                                      controller: otpControllers[index],
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      maxLength: 1,
                                      style: AppTextStyles.mulish(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Colors.white,
                                        counterText: '',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(15),
                                          borderSide: BorderSide(
                                            color: showOtpError ? Colors.red : Colors.white,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(15),
                                          borderSide: BorderSide(
                                            color: showOtpError ? Colors.red : Colors.white,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(15),
                                          borderSide: const BorderSide(color: Colors.black, width: 2.5),
                                        ),
                                      ),
                                      onChanged: (value) {
                                        if (value.isNotEmpty && index < 3) {
                                          FocusScope.of(context).nextFocus();
                                        } else if (value.isEmpty && index > 0) {
                                          FocusScope.of(context).previousFocus();
                                        }
                                      },
                                    ),
                                  );
                                }),

                                GestureDetector(
                                  onTap: widget.isOtpVerifying
                                      ? null
                                      : () async {
                                    if (widget.onVerifyOtp == null || widget.controller == null) return;

                                    final otp = otpControllers.map((c) => c.text).join();
                                    if (otp.length != 4) {
                                      setState(() => showOtpError = true);
                                      return;
                                    }

                                    final success = await widget.onVerifyOtp!(widget.controller!.text, otp);
                                    if (!success) {
                                      setState(() => showOtpError = true);
                                      return;
                                    }

                                    if (!mounted) return;
                                    setState(() {
                                      isVerified = true;
                                      showOtp = false;
                                      showOtpError = false;
                                      resendTimer?.cancel();
                                    });
                                  },
                                  child: Container(
                                    width: 53,
                                    height: 52,
                                    decoration: BoxDecoration(
                                      color: widget.isOtpVerifying ? Colors.grey : Colors.black,
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: widget.isOtpVerifying
                                        ? const Padding(
                                      padding: EdgeInsets.all(12),
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                        : const Icon(Icons.check, color: Colors.white),
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
