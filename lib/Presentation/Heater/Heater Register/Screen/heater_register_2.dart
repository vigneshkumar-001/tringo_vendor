import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:tringo_vendor_new/Core/Const/app_logger.dart';
import 'package:tringo_vendor_new/Presentation/Heater/Heater%20Register/Controller/heater_register_notifier.dart';
import '../../../../Api/DataSource/api_data_source.dart';
import '../../../../Core/Const/app_color.dart';
import '../../../../Core/Const/app_images.dart';
import '../../../../Core/Utility/app_loader.dart';
import '../../../../Core/Utility/app_snackbar.dart';
import '../../../../Core/Utility/app_textstyles.dart';
import '../../../../Core/Utility/thanglish_to_tamil.dart';
import '../../../../Core/Widgets/app_go_routes.dart';
import '../../../../Core/Widgets/common_container.dart';

class HeaterRegister2 extends ConsumerStatefulWidget {
  const HeaterRegister2({super.key});

  @override
  ConsumerState<HeaterRegister2> createState() => _HeaterRegister2State();
}

class _HeaterRegister2State extends ConsumerState<HeaterRegister2> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitted = false;

  // final type = RegistrationSession.instance.businessType?.label ?? 'Not set';

  final TextEditingController accountNumberController = TextEditingController();
  final TextEditingController bankNameController = TextEditingController();
  final TextEditingController accountHolderNameController =
      TextEditingController();
  final TextEditingController accountBranchController = TextEditingController();
  final TextEditingController accountIFSCCodeController =
      TextEditingController();

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
    _existingUrls = List<String?>.filled(1, null, growable: false);
  }

  @override
  void dispose() {
    bankNameController.dispose();
    accountHolderNameController.dispose();
    accountBranchController.dispose();
    accountIFSCCodeController.dispose();
    accountNumberController.dispose();

    for (final c in otpControllers) {
      c.dispose();
    }
    for (final f in otpFocusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _onSubmitOtp() {
    final otp = otpControllers.map((c) => c.text).join();
    debugPrint("Entered OTP: $otp");
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("OTP Entered: $otp")));
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

  List<File?> _pickedImages = List<File?>.filled(1, null);
  List<bool> _hasError = List<bool>.filled(1, false);
  late List<String?> _existingUrls;
  bool _insidePhotoError = false;
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(heaterRegisterNotifier);
    // final bool isIndividualFlow = widget.isIndividual;

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
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 16,
                  ),
                  child: Row(
                    children: [
                      CommonContainer.topLeftArrow(
                        onTap: () {
                          if (showOtpCard) {
                            setState(() => showOtpCard = false);
                          } else {
                            Navigator.pop(context);
                          }
                        },
                      ),
                      SizedBox(width: 50),
                      Text(
                        'Register Vendor',
                        style: AppTextStyles.mulish(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColor.mildBlack,
                        ),
                      ),
                      SizedBox(width: 5),
                      // Text(
                      //   '-',
                      //   style: AppTextStyles.mulish(
                      //     fontSize: 16,
                      //     fontWeight: FontWeight.w400,
                      //     color: AppColor.mildBlack,
                      //   ),
                      // ),
                      // SizedBox(width: 5),
                      Text(
                        'Company',
                        // isIndividualFlow ? 'Individual' : 'Company',
                        style: AppTextStyles.mulish(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColor.mildBlack,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 35),

                /// HEADER BLOCK
                Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(AppImages.registerBCImage),
                      fit: BoxFit.cover,
                    ),
                    gradient: LinearGradient(
                      colors: [AppColor.white, AppColor.iceGreen],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
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
                        const SizedBox(height: 15),
                        Text(
                          'Owner’s Info',
                          style: AppTextStyles.mulish(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: AppColor.mildBlack,
                          ),
                        ),
                        const SizedBox(height: 30),
                        LinearProgressIndicator(
                          minHeight: 12,
                          value: 0.3,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColor.green,
                          ),
                          backgroundColor: AppColor.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        const SizedBox(height: 25),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bank Account Number',
                        style: GoogleFonts.mulish(color: AppColor.mildBlack),
                      ),
                      SizedBox(height: 10),

                      CommonContainer.fillingContainer(
                        keyboardType: TextInputType.number,
                        text: '',
                        verticalDivider: false,
                        controller: accountNumberController,
                        context: context,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Bank Account Number is required';
                          }
                          if (v.length < 8) {
                            return 'Enter a valid account number';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: 30),

                      Text(
                        'Bank Name',
                        style: GoogleFonts.mulish(color: AppColor.mildBlack),
                      ),
                      SizedBox(height: 10),

                      CommonContainer.fillingContainer(
                        keyboardType: TextInputType.name,
                        text: '',
                        verticalDivider: false,
                        controller: bankNameController,
                        context: context,
                        validator:
                            (v) =>
                                v == null || v.isEmpty
                                    ? 'Bank Name is required'
                                    : null,
                      ),

                      SizedBox(height: 30),

                      Text(
                        'Account Holder Name',
                        style: GoogleFonts.mulish(color: AppColor.mildBlack),
                      ),
                      SizedBox(height: 10),

                      CommonContainer.fillingContainer(
                        keyboardType: TextInputType.name,
                        text: '',
                        verticalDivider: false,
                        controller: accountHolderNameController,
                        context: context,
                        validator:
                            (v) =>
                                v == null || v.isEmpty
                                    ? 'Account Holder Name is required'
                                    : null,
                      ),

                      SizedBox(height: 30),

                      Text(
                        'Account Branch',
                        style: GoogleFonts.mulish(color: AppColor.mildBlack),
                      ),
                      SizedBox(height: 10),

                      CommonContainer.fillingContainer(
                        keyboardType: TextInputType.name,
                        text: '',
                        verticalDivider: false,
                        controller: accountBranchController,
                        context: context,
                        validator:
                            (v) =>
                                v == null || v.isEmpty
                                    ? 'Account Branch is required'
                                    : null,
                      ),

                      SizedBox(height: 30),

                      Text(
                        'Account IFSC Code',
                        style: GoogleFonts.mulish(color: AppColor.mildBlack),
                      ),
                      SizedBox(height: 10),

                      CommonContainer.fillingContainer(
                        keyboardType: TextInputType.name,
                        text: '',
                        verticalDivider: false,
                        controller: accountIFSCCodeController,
                        context: context,
                        validator:
                            (v) =>
                                v == null || v.isEmpty
                                    ? 'Account IFSC Code is required'
                                    : null,
                      ),

                      SizedBox(height: 30),

                      CommonContainer.button(
                        buttonColor: AppColor.darkBlue,
                        imagePath:
                            state.isLoading ? null : AppImages.rightStickArrow,
                        text:
                            state.isLoading
                                ? ThreeDotsLoader()
                                : Text('Save & Continue'),
                        onTap: () async {
                          setState(() => _isSubmitted = true);

                          if (!_formKey.currentState!.validate()) {
                            return;
                          }

                          final accountNumber =
                              accountNumberController.text.trim();
                          final bankName = bankNameController.text.trim();
                          final accountHolderName =
                              accountHolderNameController.text.trim();
                          final accountBranch =
                              accountBranchController.text.trim();
                          final accountIFSCCode =
                              accountIFSCCodeController.text.trim();

                          await ref
                              .read(heaterRegisterNotifier.notifier)
                              .registerVendor(
                                aadhaarFile: _pickedImages[0],
                                screen: VendorRegisterScreen.screen2,
                                vendorName: '',
                                vendorNameTamil: '',
                                phoneNumber: '',
                                aadharNumber: '',
                                aadharDocumentUrl: '',
                                bankAccountNumber: accountNumber,
                                bankName: bankName,
                                bankAccountName: accountHolderName,
                                bankBranch: accountBranch,
                                bankIfsc: accountIFSCCode,
                                companyName: '',
                                companyAddress: '',
                                gpsLatitude: '',
                                gpsLongitude: '',
                                primaryCity: '',
                                primaryState: '',
                                companyContactNumber: '',
                                alternatePhone: '',
                                companyEmail: '',
                                gstNumber: '',
                                avatarUrl: '',
                                email: '',
                                dateOfBirth: '',
                                gender: '',
                              );

                          final newState = ref.read(heaterRegisterNotifier);

                          if (newState.error != null) {
                            AppSnackBar.error(context, newState.error!);
                          } else if (newState.vendorResponse != null) {
                            AppSnackBar.success(
                              context,
                              "Owner information saved successfully",
                            );
                            context.push(AppRoutes.vendorCompanyInfoPath);

                            AppLogger.log.i(
                              "Owner Info Saved  ${newState.vendorResponse?.toJson()}",
                            );
                          }
                        },
                      ),
                      // CommonContainer.button(
                      //   buttonColor: AppColor.darkBlue,
                      //   imagePath: AppImages.rightStickArrow,
                      //   text: Text('Save & Continue'),
                      //   onTap: () {
                      //     context.push(AppRoutes.vendorCompanyInfoPath);
                      //   },
                      // ),
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
