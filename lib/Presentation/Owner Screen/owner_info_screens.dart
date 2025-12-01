import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:tringo_vendor_new/Core/Const/app_logger.dart';

import '../../Core/Const/app_color.dart';
import '../../Core/Const/app_images.dart';
import '../../Core/Utility/app_loader.dart';
import '../../Core/Utility/app_snackbar.dart';
import '../../Core/Utility/app_textstyles.dart';
import '../../Core/Utility/thanglish_to_tamil.dart';
import '../../Core/Widgets/app_go_routes.dart';
import '../../Core/Widgets/common_container.dart';

class OwnerInfoScreens extends ConsumerStatefulWidget {
  const OwnerInfoScreens({super.key});

  @override
  ConsumerState<OwnerInfoScreens> createState() => _OwnerInfoScreensState();
}

class _OwnerInfoScreensState extends ConsumerState<OwnerInfoScreens> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitted = false;

  // final type = RegistrationSession.instance.businessType?.label ?? 'Not set';

  final TextEditingController englishNameController = TextEditingController();
  final TextEditingController tamilNameController = TextEditingController();
  final TextEditingController emailIdController = TextEditingController();
  final TextEditingController dateOfBirthController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();

  bool showOtpCard = false;
  int resendSeconds = 30;
  List<String> tamilNameSuggestion = [];
  bool isTamilNameLoading = false;

  // OTP
  final int otpLength = 4;
  late List<TextEditingController> otpControllers;
  late List<FocusNode> otpFocusNodes;

  late final String ownershipType;
  late final String businessTypeForApi;
  @override
  void initState() {
    super.initState();

    otpControllers = List.generate(otpLength, (_) => TextEditingController());
    otpFocusNodes = List.generate(otpLength, (_) => FocusNode());
  }

  @override
  void dispose() {
    englishNameController.dispose();
    tamilNameController.dispose();
    mobileController.dispose();
    emailIdController.dispose();
    dateOfBirthController.dispose();
    genderController.dispose();

    for (final c in otpControllers) {
      c.dispose();
    }
    for (final f in otpFocusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _startResendTimer() {
    resendSeconds = 30;
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendSeconds == 0) {
        timer.cancel();
      } else {
        setState(() => resendSeconds--);
      }
    });
  }

  bool get isOtpComplete =>
      otpControllers.every((controller) => controller.text.isNotEmpty);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            autovalidateMode:
                _isSubmitted
                    ? AutovalidateMode.onUserInteraction
                    : AutovalidateMode.disabled,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// HEADER BAR
                // Padding(
                //   padding: const EdgeInsets.symmetric(
                //     horizontal: 15,
                //     vertical: 16,
                //   ),
                //   child: Row(
                //     children: [
                //       // CommonContainer.topLeftArrow(
                //       //   onTap: () {
                //       //     if (showOtpCard) {
                //       //       setState(() => showOtpCard = false);
                //       //     } else {
                //       //       Navigator.pop(context);
                //       //     }
                //       //   },
                //       // ),
                //       SizedBox(width: 50),
                //       Text(
                //         'Register Shop - Individual',
                //         style: AppTextStyles.mulish(
                //           fontSize: 16,
                //           fontWeight: FontWeight.w400,
                //           color: AppColor.mildBlack,
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
                SizedBox(height: 35),

                /// HEADER BLOCK
                Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(AppImages.registerBCImage),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomRight: Radius.circular(30),
                      bottomLeft: Radius.circular(30),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        Image.asset(AppImages.person, height: 85),
                        SizedBox(height: 15),
                        Text(
                          'Owner’s Info',
                          style: AppTextStyles.mulish(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: AppColor.mildBlack,
                          ),
                        ),
                        SizedBox(height: 30),
                        LinearProgressIndicator(
                          minHeight: 12,
                          value: 0.3,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColor.green,
                          ),
                          backgroundColor: AppColor.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        SizedBox(height: 25),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 30),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// USER NAME
                      RichText(
                        text: TextSpan(
                          style: GoogleFonts.mulish(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          children: [
                            TextSpan(
                              text: 'Name of the User ',
                              style: TextStyle(color: AppColor.mildBlack),
                            ),
                            TextSpan(
                              text: '( As per Govt Certificate )',
                              style: TextStyle(color: AppColor.mediumLightGray),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 10),

                      /// ENGLISH NAME
                      CommonContainer.fillingContainer(
                        text: 'English',
                        verticalDivider: true,
                        controller: englishNameController,
                        context: context,
                        validator:
                            (v) =>
                                v == null || v.trim().isEmpty
                                    ? 'Enter English name'
                                    : null,
                      ),

                      SizedBox(height: 10),

                      /// TAMIL NAME
                      CommonContainer.fillingContainer(
                        onChanged: (value) async {
                          setState(() => isTamilNameLoading = true);
                          final result =
                              await TanglishTamilHelper.transliterate(value);

                          setState(() {
                            tamilNameSuggestion = result;
                            isTamilNameLoading = false;
                          });
                        },
                        text: 'Tamil',
                        verticalDivider: true,
                        controller: tamilNameController,
                        context: context,
                        validator:
                            (v) =>
                                v == null || v.trim().isEmpty
                                    ? 'Enter Tamil name'
                                    : null,
                      ),

                      if (isTamilNameLoading)
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),

                      if (tamilNameSuggestion.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          constraints: const BoxConstraints(maxHeight: 150),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.grey),
                          ),
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: tamilNameSuggestion.length,
                            itemBuilder: (context, index) {
                              final suggestion = tamilNameSuggestion[index];
                              return ListTile(
                                title: Text(suggestion),
                                onTap: () {
                                  TanglishTamilHelper.applySuggestion(
                                    controller: tamilNameController,
                                    suggestion: suggestion,
                                    onSuggestionApplied: () {
                                      setState(() => tamilNameSuggestion = []);
                                    },
                                  );
                                },
                              );
                            },
                          ),
                        ),

                      SizedBox(height: 30),

                      /// MOBILE NUMBER
                      Text(
                        'Mobile Number',
                        style: GoogleFonts.mulish(color: AppColor.mildBlack),
                      ),
                      SizedBox(height: 10),

                      CommonContainer.fillingContainer(
                        controller: mobileController,
                        verticalDivider: true,
                        isMobile: true,
                        text: 'Mobile No',
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Mobile number required';
                          }
                          if (v.length != 10) {
                            return 'Enter valid 10-digit mobile number';
                          }
                          if (!RegExp(r'^[6-9]\d{9}$').hasMatch(v)) {
                            return 'Invalid mobile number';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: 30),

                      /// EMAIL
                      Text(
                        'Email Id',
                        style: GoogleFonts.mulish(color: AppColor.mildBlack),
                      ),
                      SizedBox(height: 10),

                      CommonContainer.fillingContainer(
                        keyboardType: TextInputType.emailAddress,
                        text: 'Email Id',
                        verticalDivider: true,
                        controller: emailIdController,
                        context: context,
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Email required';
                          }
                          if (!RegExp(
                            r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                          ).hasMatch(v)) {
                            return 'Enter valid email';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: 30),

                      /// DOB
                      Text(
                        'Date of Birth',
                        style: GoogleFonts.mulish(color: AppColor.mildBlack),
                      ),
                      SizedBox(height: 10),

                      CommonContainer.fillingContainer(
                        isDOB: true,
                        verticalDivider: true,
                        imagePath: AppImages.dob,
                        imageWidth: 20,
                        imageHight: 25,
                        controller: dateOfBirthController,
                        textFontWeight: FontWeight.w700,
                        context: context,
                        datePickMode: DatePickMode.single,
                        validator:
                            (v) =>
                                v == null || v.isEmpty ? 'DOB required' : null,
                      ),

                      SizedBox(height: 30),

                      /// GENDER
                      Text(
                        'Gender',
                        style: GoogleFonts.mulish(color: AppColor.mildBlack),
                      ),
                      SizedBox(height: 10),

                      CommonContainer.fillingContainer(
                        readOnly: true,
                        isDropdown: true,
                        dropdownItems: ['Male', 'Female', 'Others'],
                        verticalDivider: false,
                        imagePath: AppImages.drapDownImage,
                        controller: genderController,
                        context: context,
                        validator:
                            (v) =>
                                v == null || v.isEmpty ? 'Select gender' : null,
                      ),

                      SizedBox(height: 30),
                      CommonContainer.button(
                        onTap: () {
                          context.goNamed(AppRoutes.home);
                        },
                        text: Text('Save & Continue'),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
