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
import '../../../../Core/Const/app_color.dart';
import '../../../../Core/Const/app_images.dart';
import '../../../../Core/Utility/app_loader.dart';
import '../../../../Core/Utility/app_snackbar.dart';
import '../../../../Core/Utility/app_textstyles.dart';
import '../../../../Core/Utility/thanglish_to_tamil.dart';
import '../../../../Core/Widgets/app_go_routes.dart';
import '../../../../Core/Widgets/common_container.dart';

class HeaterRegister2 extends ConsumerStatefulWidget {
  // final bool isService;
  // final bool isIndividual;
  const HeaterRegister2({
    super.key,
    this.isCompany,
    // required this.isService,
    // required this.isIndividual,
  });
  final bool? isCompany;
  @override
  ConsumerState<HeaterRegister2> createState() => _HeaterRegister2State();
}

class _HeaterRegister2State extends ConsumerState<HeaterRegister2> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitted = false;

  // final type = RegistrationSession.instance.businessType?.label ?? 'Not set';

  final TextEditingController accountNumberController = TextEditingController();
  final TextEditingController accountNameController = TextEditingController();
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

    // ownershipType = widget.isIndividual ? 'INDIVIDUAL' : 'COMPANY';
    // businessTypeForApi = widget.isService ? 'SERVICES' : 'SELLING_PRODUCTS';

    otpControllers = List.generate(otpLength, (_) => TextEditingController());
    otpFocusNodes = List.generate(otpLength, (_) => FocusNode());
    _existingUrls = List<String?>.filled(1, null, growable: false);
  }

  @override
  void dispose() {
    accountNameController.dispose();
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

  Future<void> _pickImage(int index) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _pickedImages[index] = File(pickedFile.path);

        // clear old server image URL
        _existingUrls[index] = null;

        if (index == 0) {
          _hasError[index] = false;
        }
      });
    }
  }

  Widget _addImageContainer({
    required int index,
    bool checkIndividualError = false,
  }) {
    final file = _pickedImages[index];
    final url = _existingUrls[index];
    final hasImage = file != null || (url != null && url.isNotEmpty);
    final hasError = checkIndividualError ? _hasError[index] : false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            GestureDetector(
              onTap: () => _pickImage(index),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColor.lowGery1,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color:
                        hasError
                            ? Colors.red
                            : hasImage
                            ? AppColor.lightSkyBlue
                            : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child:
                    !hasImage
                        ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 22.5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(AppImages.addImage, height: 20),
                              const SizedBox(width: 10),
                              Text(
                                'Upload Image',
                                style: AppTextStyles.mulish(
                                  color: AppColor.darkGrey,
                                ),
                              ),
                            ],
                          ),
                        )
                        : ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child:
                              file != null
                                  ? Image.file(
                                    file,
                                    fit: BoxFit.cover,
                                    height: 150,
                                    width: double.infinity,
                                  )
                                  : Image.network(
                                    url!,
                                    fit: BoxFit.cover,
                                    height: 150,
                                    width: double.infinity,
                                  ),
                        ),
              ),
            ),

            // CLEAR BUTTON
            if (hasImage)
              Positioned(
                top: 15,
                right: 16,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _pickedImages[index] = null;
                      _existingUrls[index] = null;
                      _hasError[index] = false;
                    });
                  },
                  child: Column(
                    children: [
                      Image.asset(
                        AppImages.closeImage,
                        height: 28,
                        color: AppColor.white,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Clear',
                        style: AppTextStyles.mulish(
                          color: AppColor.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 5),
            child: Text(
              'Please add this image',
              style: AppTextStyles.mulish(
                color: Colors.red,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
      ],
    );
  }

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
                        // validator:
                        //     (v) =>
                        //         v == null || v.isEmpty ? 'Bank Account Number' : null,
                      ),

                      SizedBox(height: 30),

                      Text(
                        'Bank Account Name',
                        style: GoogleFonts.mulish(color: AppColor.mildBlack),
                      ),
                      const SizedBox(height: 10),

                      CommonContainer.fillingContainer(
                        keyboardType: TextInputType.name,
                        text: '',
                        verticalDivider: false,
                        controller: accountNameController,
                        context: context,
                        // validator:
                        //     (v) =>
                        //         v == null || v.isEmpty ? 'Bank Account Name' : null,
                      ),

                      SizedBox(height: 30),

                      Text(
                        'Bank Account Branch',
                        style: GoogleFonts.mulish(color: AppColor.mildBlack),
                      ),
                      SizedBox(height: 10),

                      CommonContainer.fillingContainer(
                        keyboardType: TextInputType.name,
                        text: '',
                        verticalDivider: false,
                        controller: accountBranchController,
                        context: context,
                        // validator:
                        //     (v) =>
                        //         v == null || v.isEmpty ? 'Bank Account Name' : null,
                      ),

                      SizedBox(height: 30),

                      Text(
                        'Bank Account IFSC Code',
                        style: GoogleFonts.mulish(color: AppColor.mildBlack),
                      ),
                      SizedBox(height: 10),

                      CommonContainer.fillingContainer(
                        keyboardType: TextInputType.name,
                        text: '',
                        verticalDivider: false,
                        controller: accountIFSCCodeController,
                        context: context,
                        // validator:
                        //     (v) =>
                        //         v == null || v.isEmpty ? 'Bank Account Name' : null,
                      ),

                      SizedBox(height: 30),

                      CommonContainer.button(
                        buttonColor: AppColor.darkBlue,
                        imagePath: AppImages.rightStickArrow,
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
                          final accountName = accountNameController.text.trim();
                          final accountBranch =
                              accountBranchController.text.trim();
                          final accountIFSCCode =
                              accountIFSCCodeController.text.trim();

                          String dobForApi = '';

                          AppLogger.log.i(
                            'ownershipType: $ownershipType, businessType: $businessTypeForApi',
                          );

                          await ref
                              .read(heaterRegisterNotifier.notifier)
                              .registerVendor(
                                vendorName: '',
                                vendorNameTamil: '',
                                phoneNumber: '',
                                aadharNumber: '',
                                aadharDocumentUrl: '',
                                bankAccountNumber: accountNumber,
                                bankAccountName: accountName,
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
                                dateOfBirth: dobForApi,
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
