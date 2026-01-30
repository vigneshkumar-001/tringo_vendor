import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:tringo_vendor_new/Api/DataSource/api_data_source.dart';
import 'package:tringo_vendor_new/Core/Const/app_logger.dart';
import 'package:tringo_vendor_new/Presentation/Heater/Heater%20Home%20Screen/Controller/heater_home_notifier.dart';
import 'package:tringo_vendor_new/Presentation/Heater/Setting/Model/get_profile_response.dart';
import '../../../../Core/Const/app_color.dart';
import '../../../../Core/Const/app_images.dart';
import '../../../../Core/Utility/app_loader.dart';
import '../../../../Core/Utility/app_snackbar.dart';
import '../../../../Core/Utility/app_textstyles.dart';
import '../../../../Core/Widgets/app_go_routes.dart';
import '../../../../Core/Widgets/common_container.dart';
import '../Controller/heater_register_notifier.dart';

class HeaterRegister1 extends ConsumerStatefulWidget {
  final GetProfileResponse? profile;
  final bool isService;
  final bool isIndividual;
  final bool edit;
  final String? userName;
  final bool? isCompany;

  const HeaterRegister1({
    super.key,
    this.isCompany,
    this.profile,
    required this.isService,
    this.userName,
    required this.edit,
    required this.isIndividual,
  });

  @override
  ConsumerState<HeaterRegister1> createState() => _HeaterRegister1State();
}

class _HeaterRegister1State extends ConsumerState<HeaterRegister1> {
  final _formKey = GlobalKey<FormState>();

  bool _isSubmitted = false;
  bool _prefilledOnce = false;

  bool get _shouldValidate => _isSubmitted;

  final TextEditingController englishNameController = TextEditingController();
  final TextEditingController tamilNameController = TextEditingController();
  final TextEditingController emailIdController = TextEditingController();
  final TextEditingController dateOfBirthController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController aadharController = TextEditingController();

  bool showOtpCard = false;
  int resendSeconds = 30;

  final int otpLength = 4;
  late List<TextEditingController> otpControllers;
  late List<FocusNode> otpFocusNodes;

  late final String ownershipType;
  late final String businessTypeForApi;

  // Images
  final ImagePicker _picker = ImagePicker();
  List<File?> _pickedImages = List<File?>.filled(1, null);
  List<bool> _hasError = List<bool>.filled(1, false);
  late List<String?> _existingUrls;

  bool _validateAadharPhoto() {
    final hasImage =
        _pickedImages[0] != null ||
        (_existingUrls[0] != null && _existingUrls[0]!.isNotEmpty);

    setState(() {
      _hasError[0] = !hasImage;
    });

    return hasImage;
  }

  @override
  void initState() {
    super.initState();

    ownershipType = widget.isIndividual ? 'INDIVIDUAL' : 'COMPANY';
    businessTypeForApi = widget.isService ? 'SERVICES' : 'SELLING_PRODUCTS';

    otpControllers = List.generate(otpLength, (_) => TextEditingController());
    otpFocusNodes = List.generate(otpLength, (_) => FocusNode());

    // ✅ MUST init before prefill
    _existingUrls = List<String?>.filled(1, null, growable: false);

    // ✅ edit: don't show validators on open
    _isSubmitted = false;

    // Prefill if edit and profile already available
    if (widget.edit == true) {
      _prefillFromProfile();
      _prefilledOnce = true;
    } else {
      englishNameController.text = widget.userName ?? '';
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // ✅ If profile comes later (async), fill once after first frame
    if (widget.edit == true && !_prefilledOnce) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _prefillFromProfile();
        if (mounted) setState(() {});
        _prefilledOnce = true;
      });
    }
  }

  String _mapGenderForUI(String? g) {
    final s = (g ?? '').trim();
    if (s.isEmpty) return '';

    final up = s.toUpperCase();
    if (up == 'MALE') return 'Male';
    if (up == 'FEMALE') return 'Female';
    if (up == 'OTHERS' || up == 'OTHER') return 'Others';

    if (s == 'Male' || s == 'Female' || s == 'Others') return s;
    return '';
  }

  String _formatDobForUI(String? dobFromApi) {
    if (dobFromApi == null || dobFromApi.trim().isEmpty) return '';
    final raw = dobFromApi.trim();

    // API: yyyy-MM-dd -> UI: dd-MM-yyyy
    try {
      final dt = DateFormat('yyyy-MM-dd').parseStrict(raw);
      return DateFormat('dd-MM-yyyy').format(dt);
    } catch (_) {}

    // if already dd-MM-yyyy
    try {
      final dt = DateFormat('dd-MM-yyyy').parseStrict(raw);
      return DateFormat('dd-MM-yyyy').format(dt);
    } catch (_) {}

    return raw;
  }

  void _prefillFromProfile() {
    final p = widget.profile;
    if (p == null) {
      englishNameController.text = widget.userName ?? '';
      return;
    }

    englishNameController.text = (p.data?.displayName ?? widget.userName ?? '');
    emailIdController.text = (p.data?.user?.email ?? '');
    dateOfBirthController.text = _formatDobForUI(p.data?.dateOfBirth);
    genderController.text = _mapGenderForUI(p.data?.gender);
    mobileController.text = (p.data?.user?.phoneNumber ?? '');
    aadharController.text = (p.data?.aadharNumber ?? '');

    // ✅ show existing aadhar image URL
    final url = p.data?.aadharDocumentUrl;
    if (url != null && url.isNotEmpty) {
      _existingUrls[0] = url;
    }
  }

  @override
  void dispose() {
    englishNameController.dispose();
    tamilNameController.dispose();
    mobileController.dispose();
    emailIdController.dispose();
    dateOfBirthController.dispose();
    genderController.dispose();
    aadharController.dispose();

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

  Future<void> _pickImageFromSource(int index, ImageSource source) async {
    final pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 85,
    );

    if (pickedFile == null) return;

    setState(() {
      _pickedImages[index] = File(pickedFile.path);

      // clear old server url
      _existingUrls[index] = null;

      _hasError[index] = false;
    });
  }

  void _showImageSourcePicker(int index) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromSource(index, ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromSource(index, ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
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
              onTap: () => _showImageSourcePicker(index),
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
                                    loadingBuilder: (context, child, progress) {
                                      if (progress == null) return child;
                                      return const SizedBox(
                                        height: 150,
                                        child: Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      );
                                    },
                                    errorBuilder: (_, __, ___) {
                                      return const SizedBox(
                                        height: 150,
                                        child: Center(
                                          child: Text("Image load failed"),
                                        ),
                                      );
                                    },
                                  ),
                        ),
              ),
            ),

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
                      const SizedBox(width: 50),
                      Text(
                        'Register Vendor Company',
                        style: AppTextStyles.mulish(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColor.mildBlack,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 35),

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
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// USER NAME TITLE
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
                            const TextSpan(
                              text: '( As per Govt Certificate )',
                              style: TextStyle(color: AppColor.mediumLightGray),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),

                      /// ENGLISH NAME
                      CommonContainer.fillingContainer(
                        text: ' ',
                        verticalDivider: false,
                        controller: englishNameController,
                        context: context,
                        validator: (v) {
                          if (!_shouldValidate) return null;
                          return (v == null || v.trim().isEmpty)
                              ? 'Enter name'
                              : null;
                        },
                      ),

                      const SizedBox(height: 30),

                      Text(
                        'Mobile Number',
                        style: GoogleFonts.mulish(color: AppColor.mildBlack),
                      ),
                      const SizedBox(height: 10),

                      CommonContainer.fillingContainer(
                        controller: mobileController,
                        verticalDivider: false,
                        isMobile: true,
                        text: '',
                        keyboardType: TextInputType.phone,
                        validator: (v) {
                          if (!_shouldValidate) return null;
                          if (v == null || v.isEmpty) {
                            return 'Please Enter Mobile Number';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 30),

                      /// EMAIL
                      Text(
                        'Email Id',
                        style: GoogleFonts.mulish(color: AppColor.mildBlack),
                      ),
                      const SizedBox(height: 10),

                      CommonContainer.fillingContainer(
                        keyboardType: TextInputType.emailAddress,
                        text: 'Email Id',
                        verticalDivider: true,
                        controller: emailIdController,
                        context: context,
                        validator: (v) {
                          if (!_shouldValidate) return null;
                          if (v == null || v.isEmpty) return 'Email required';
                          if (!RegExp(
                            r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                          ).hasMatch(v)) {
                            return 'Enter valid email';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 30),

                      /// DOB
                      Text(
                        'Date of Birth',
                        style: GoogleFonts.mulish(color: AppColor.mildBlack),
                      ),
                      const SizedBox(height: 10),

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
                        validator: (v) {
                          if (!_shouldValidate) return null;
                          return (v == null || v.isEmpty)
                              ? 'DOB required'
                              : null;
                        },
                      ),

                      const SizedBox(height: 30),

                      /// GENDER
                      Text(
                        'Gender',
                        style: GoogleFonts.mulish(color: AppColor.mildBlack),
                      ),
                      const SizedBox(height: 10),

                      CommonContainer.fillingContainer(
                        readOnly: true,
                        isDropdown: true,
                        dropdownItems: const ['Male', 'Female', 'Others'],
                        verticalDivider: false,
                        imagePath: AppImages.drapDownImage,
                        imageColor: AppColor.gray84,
                        controller: genderController,
                        context: context,
                        validator: (v) {
                          if (!_shouldValidate) return null;
                          return (v == null || v.isEmpty)
                              ? 'Select gender'
                              : null;
                        },
                      ),

                      const SizedBox(height: 30),

                      Text(
                        'Aadhar No',
                        style: GoogleFonts.mulish(color: AppColor.mildBlack),
                      ),
                      const SizedBox(height: 10),

                      CommonContainer.fillingContainer(
                        keyboardType: TextInputType.number,
                        isAadhaar: true,
                        text: 'Aadhar No',
                        verticalDivider: true,
                        controller: aadharController,
                        context: context,
                        validator: (v) {
                          if (!_shouldValidate) return null;
                          final digits = (v ?? '').replaceAll(' ', '');
                          if (digits.length != 12) {
                            return 'Enter valid 12 digit Aadhar No';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 30),

                      CommonContainer.containerTitle(
                        context: context,
                        title: 'Aadhar Photo',
                        image: AppImages.iImage,
                        infoMessage:
                            'Please upload a clear photo of your Aadhar.',
                      ),

                      const SizedBox(height: 10),
                      _addImageContainer(index: 0, checkIndividualError: true),
                      const SizedBox(height: 30),

                      /// SUBMIT
                      CommonContainer.button(
                        buttonColor: AppColor.darkBlue,
                        imagePath:
                            state.isLoading ? null : AppImages.rightStickArrow,
                        text:
                            state.isLoading
                                ? ThreeDotsLoader()
                                : const Text('Save & Continue'),
                        onTap: () async {
                          // setState(() => _isSubmitted = true);
                          //
                          // if (!_formKey.currentState!.validate()) return;

                          final hasAadharPhoto = _validateAadharPhoto();
                          if (!hasAadharPhoto) {
                            AppSnackBar.error(
                              context,
                              "Please upload your Aadhar photo",
                            );
                            return;
                          }

                          final englishName = englishNameController.text.trim();
                          final tamilName = tamilNameController.text.trim();
                          final mobile = mobileController.text.trim();
                          final email = emailIdController.text.trim();
                          final gender = genderController.text.trim();
                          final aadhar = aadharController.text.trim();
                          final input = dateOfBirthController.text.trim();

                          String dobForApi = '';
                          try {
                            final parsedDate = DateFormat(
                              'dd-MM-yyyy',
                            ).parseStrict(input);
                            dobForApi = DateFormat(
                              'yyyy-MM-dd',
                            ).format(parsedDate);
                          } catch (e) {
                            AppSnackBar.error(context, "Invalid DOB");
                            return;
                          }

                          final File? pickedFile = _pickedImages[0];
                          final String? existingUrl = _existingUrls[0];

                          String aadharDocUrl = '';
                          if (pickedFile != null) {
                            // TODO upload and get url
                            aadharDocUrl = pickedFile.path; // temp
                          } else if (existingUrl != null &&
                              existingUrl.isNotEmpty) {
                            aadharDocUrl = existingUrl;
                          }

                          AppLogger.log.i(
                            'ownershipType: $ownershipType, businessType: $businessTypeForApi',
                          );

                          await ref
                              .read(heaterRegisterNotifier.notifier)
                              .registerVendor(
                                aadhaarFile: pickedFile, // ✅ nullable
                                screen: VendorRegisterScreen.screen1,
                                vendorName: englishName,
                                vendorNameTamil: tamilName,
                                phoneNumber: mobile,
                                aadharNumber: aadhar,
                                aadharDocumentUrl: aadharDocUrl,
                                bankAccountNumber: '',
                                bankName: '',
                                bankAccountName: '',
                                bankBranch: '',
                                bankIfsc: '',
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
                                email: email,
                                dateOfBirth: dobForApi,
                                gender: gender,
                              );

                          final newState = ref.read(heaterRegisterNotifier);

                          if (newState.error != null) {
                            AppSnackBar.error(context, newState.error!);
                          } else if (newState.vendorResponse != null) {
                            AppSnackBar.success(
                              context,
                              "Owner information saved successfully",
                            );
                            if (widget.edit == true) {
                              Navigator.pop(context);
                              final notifier = ref.read(
                                heaterHomeNotifier.notifier,
                              );

                              final today = DateFormat(
                                'yyyy-MM-dd',
                              ).format(DateTime.now());

                              notifier.heaterHome(
                                dateFrom: today,
                                dateTo: today,
                              );
                            } else {
                              context.push(AppRoutes.heaterRegister2Path);
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// import 'dart:async';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:intl/intl.dart';
// import 'package:tringo_vendor_new/Core/Const/app_logger.dart';
// import 'package:tringo_vendor_new/Presentation/Heater/Setting/Model/get_profile_response.dart';
// import '../../../../Api/DataSource/api_data_source.dart';
// import '../../../../Core/Const/app_color.dart';
// import '../../../../Core/Const/app_images.dart';
// import '../../../../Core/Utility/app_loader.dart';
// import '../../../../Core/Utility/app_snackbar.dart';
// import '../../../../Core/Utility/app_textstyles.dart';
// import '../../../../Core/Utility/thanglish_to_tamil.dart';
// import '../../../../Core/Widgets/app_go_routes.dart';
// import '../../../../Core/Widgets/common_container.dart';
// import '../../Vendor Company Info/Controller/vendor_company_notofier.dart';
// import '../Controller/heater_register_notifier.dart';
//
// class HeaterRegister1 extends ConsumerStatefulWidget {
//   final GetProfileResponse? profile;   // 👈 add this
//   final bool isService;
//   final bool isIndividual;
//   final bool edit;
//   final String? userName;
//   const HeaterRegister1({
//     super.key,
//     this.isCompany,
//     this. profile ,
//     required this.isService,
//     this.userName,
//     required this.edit,
//     required this.isIndividual,
//   });
//   final bool? isCompany;
//   @override
//   ConsumerState<HeaterRegister1> createState() => _HeaterRegister1State();
// }
//
// class _HeaterRegister1State extends ConsumerState<HeaterRegister1> {
//   final _formKey = GlobalKey<FormState>();
//   bool _isSubmitted = false;
//
//   // final type = RegistrationSession.instance.businessType?.label ?? 'Not set';
//
//   final TextEditingController englishNameController = TextEditingController();
//   final TextEditingController tamilNameController = TextEditingController();
//   final TextEditingController emailIdController = TextEditingController();
//   final TextEditingController dateOfBirthController = TextEditingController();
//   final TextEditingController genderController = TextEditingController();
//   final TextEditingController mobileController = TextEditingController();
//   final TextEditingController aadharController = TextEditingController();
//
//   bool showOtpCard = false;
//   int resendSeconds = 30;
//   List<String> tamilNameSuggestion = [];
//   bool isTamilNameLoading = false;
//
//   // OTP
//   final int otpLength = 4;
//   late List<TextEditingController> otpControllers;
//   late List<FocusNode> otpFocusNodes;
//
//   late final String ownershipType;
//   late final String businessTypeForApi;
//
//   bool _validateAadharPhoto() {
//     final hasImage =
//         _pickedImages[0] != null ||
//         (_existingUrls[0] != null && _existingUrls[0]!.isNotEmpty);
//
//     setState(() {
//       _hasError[0] = !hasImage;
//     });
//
//     return hasImage;
//   }
//
//   @override
//   void initState() {
//     super.initState();
//
//     ownershipType = widget.isIndividual ? 'INDIVIDUAL' : 'COMPANY';
//     businessTypeForApi = widget.isService ? 'SERVICES' : 'SELLING_PRODUCTS';
//     if (widget.edit == true) {
//       _prefillFromProfile();
//     }
//     otpControllers = List.generate(otpLength, (_) => TextEditingController());
//     otpFocusNodes = List.generate(otpLength, (_) => FocusNode());
//     _existingUrls = List<String?>.filled(1, null, growable: false);
//   }
//   void _prefillFromProfile() {
//     final p = widget.profile;
//
//     if (p == null) {
//       // fallback
//       englishNameController.text = widget.userName ?? '';
//       return;
//     }
//
//     // ✅ Replace these with your actual response structure
//     englishNameController.text = p.data.  displayName?? widget.userName ?? '';
//     // tamilNameController.text   = p.data?. ?? '';
//     emailIdController.text     = p.data.user.email ?? '';
//     dateOfBirthController.text = p.data.dateOfBirth ?? '';
//     genderController.text      = p.data.gender ?? '';
//     mobileController.text      = p.data.user.phoneNumber ?? '';
//     aadharController.text      = p.data.aadharNumber ?? '';
//
//     // ✅ if you have already uploaded image url(s)
//     // _existingUrls[0] = p.data?.aadharPhotoUrl;   // adjust field
//   }
//
//   @override
//   void dispose() {
//     englishNameController.dispose();
//     tamilNameController.dispose();
//     mobileController.dispose();
//     emailIdController.dispose();
//     dateOfBirthController.dispose();
//     genderController.dispose();
//     aadharController.dispose();
//
//     for (final c in otpControllers) {
//       c.dispose();
//     }
//     for (final f in otpFocusNodes) {
//       f.dispose();
//     }
//     super.dispose();
//   }
//
//   void _onSubmitOtp() {
//     final otp = otpControllers.map((c) => c.text).join();
//     debugPrint("Entered OTP: $otp");
//     ScaffoldMessenger.of(
//       context,
//     ).showSnackBar(SnackBar(content: Text("OTP Entered: $otp")));
//   }
//
//   void _startResendTimer() {
//     resendSeconds = 30;
//     Timer.periodic(const Duration(seconds: 1), (timer) {
//       if (resendSeconds == 0) {
//         timer.cancel();
//       } else {
//         setState(() => resendSeconds--);
//       }
//     });
//   }
//
//   bool get isOtpComplete =>
//       otpControllers.every((controller) => controller.text.isNotEmpty);
//
//   List<File?> _pickedImages = List<File?>.filled(1, null);
//   List<bool> _hasError = List<bool>.filled(1, false);
//   late List<String?> _existingUrls;
//   bool _insidePhotoError = false;
//   final ImagePicker _picker = ImagePicker();
//
//   Future<void> _pickImage(int index) async {
//     final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
//
//     if (pickedFile != null) {
//       setState(() {
//         _pickedImages[index] = File(pickedFile.path);
//
//         // clear old server image URL
//         _existingUrls[index] = null;
//
//         if (index == 0) {
//           _hasError[index] = false;
//         }
//       });
//     }
//   }
//
//   void _showImageSourcePicker(int index) {
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//       ),
//       builder: (_) {
//         return SafeArea(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               ListTile(
//                 leading: const Icon(Icons.camera_alt),
//                 title: const Text('Camera'),
//                 onTap: () {
//                   Navigator.pop(context);
//                   _pickImageFromSource(index, ImageSource.camera);
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(Icons.photo_library),
//                 title: const Text('Gallery'),
//                 onTap: () {
//                   Navigator.pop(context);
//                   _pickImageFromSource(index, ImageSource.gallery);
//                 },
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   Future<void> _pickImageFromSource(int index, ImageSource source) async {
//     final pickedFile = await _picker.pickImage(
//       source: source,
//       imageQuality: 85,
//     );
//
//     if (pickedFile == null) return;
//
//     setState(() {
//       _pickedImages[index] = File(pickedFile.path);
//       _hasError[index] = false;
//     });
//   }
//
//   Widget _addImageContainer({
//     required int index,
//     bool checkIndividualError = false,
//   }) {
//     final file = _pickedImages[index];
//     final url = _existingUrls[index];
//     final hasImage = file != null || (url != null && url.isNotEmpty);
//     final hasError = checkIndividualError ? _hasError[index] : false;
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Stack(
//           children: [
//             GestureDetector(
//               // onTap: () => _pickImage(index),
//               onTap: () => _showImageSourcePicker(index),
//               child: Container(
//                 width: double.infinity,
//                 decoration: BoxDecoration(
//                   color: AppColor.lowGery1,
//                   borderRadius: BorderRadius.circular(16),
//                   border: Border.all(
//                     color:
//                         hasError
//                             ? Colors.red
//                             : hasImage
//                             ? AppColor.lightSkyBlue
//                             : Colors.transparent,
//                     width: 1.5,
//                   ),
//                 ),
//                 child:
//                     !hasImage
//                         ? Padding(
//                           padding: const EdgeInsets.symmetric(vertical: 22.5),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Image.asset(AppImages.addImage, height: 20),
//                               const SizedBox(width: 10),
//                               Text(
//                                 'Upload Image',
//                                 style: AppTextStyles.mulish(
//                                   color: AppColor.darkGrey,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         )
//                         : ClipRRect(
//                           borderRadius: BorderRadius.circular(16),
//                           child:
//                               file != null
//                                   ? Image.file(
//                                     file,
//                                     fit: BoxFit.cover,
//                                     height: 150,
//                                     width: double.infinity,
//                                   )
//                                   : Image.network(
//                                     url!,
//                                     fit: BoxFit.cover,
//                                     height: 150,
//                                     width: double.infinity,
//                                   ),
//                         ),
//               ),
//             ),
//
//             // CLEAR BUTTON
//             if (hasImage)
//               Positioned(
//                 top: 15,
//                 right: 16,
//                 child: InkWell(
//                   onTap: () {
//                     setState(() {
//                       _pickedImages[index] = null;
//                       _existingUrls[index] = null;
//                       _hasError[index] = false;
//                     });
//                   },
//                   child: Column(
//                     children: [
//                       Image.asset(
//                         AppImages.closeImage,
//                         height: 28,
//                         color: AppColor.white,
//                       ),
//                       const SizedBox(height: 2),
//                       Text(
//                         'Clear',
//                         style: AppTextStyles.mulish(
//                           color: AppColor.white,
//                           fontWeight: FontWeight.w500,
//                           fontSize: 12,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//           ],
//         ),
//         if (hasError)
//           Padding(
//             padding: const EdgeInsets.only(top: 6, left: 5),
//             child: Text(
//               'Please add this image',
//               style: AppTextStyles.mulish(
//                 color: Colors.red,
//                 fontWeight: FontWeight.w600,
//                 fontSize: 13,
//               ),
//             ),
//           ),
//       ],
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final state = ref.watch(heaterRegisterNotifier);
//     final bool isIndividualFlow = widget.isIndividual;
//
//     return Scaffold(
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Form(
//             key: _formKey,
//             autovalidateMode:
//                 _isSubmitted
//                     ? AutovalidateMode.onUserInteraction
//                     : AutovalidateMode.disabled,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 /// HEADER BAR
//                 Padding(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 15,
//                     vertical: 16,
//                   ),
//                   child: Row(
//                     children: [
//                       CommonContainer.topLeftArrow(
//                         onTap: () {
//                           if (showOtpCard) {
//                             setState(() => showOtpCard = false);
//                           } else {
//                             Navigator.pop(context);
//                           }
//                         },
//                       ),
//                       SizedBox(width: 50),
//                       Text(
//                         'Register Vendor Company',
//                         style: AppTextStyles.mulish(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w500,
//                           color: AppColor.mildBlack,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//
//                 SizedBox(height: 35),
//
//                 /// HEADER BLOCK
//                 Container(
//                   decoration: BoxDecoration(
//                     image: DecorationImage(
//                       image: AssetImage(AppImages.registerBCImage),
//                       fit: BoxFit.cover,
//                     ),
//                     gradient: LinearGradient(
//                       colors: [AppColor.white, AppColor.iceGreen],
//                       begin: Alignment.topCenter,
//                       end: Alignment.bottomCenter,
//                     ),
//                     borderRadius: const BorderRadius.only(
//                       bottomRight: Radius.circular(30),
//                       bottomLeft: Radius.circular(30),
//                     ),
//                   ),
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 20),
//                     child: Column(
//                       children: [
//                         Image.asset(AppImages.person, height: 85),
//                         const SizedBox(height: 15),
//                         Text(
//                           'Owner’s Info',
//                           style: AppTextStyles.mulish(
//                             fontSize: 28,
//                             fontWeight: FontWeight.w700,
//                             color: AppColor.mildBlack,
//                           ),
//                         ),
//                         const SizedBox(height: 30),
//                         LinearProgressIndicator(
//                           minHeight: 12,
//                           value: 0.3,
//                           valueColor: AlwaysStoppedAnimation<Color>(
//                             AppColor.green,
//                           ),
//                           backgroundColor: AppColor.white,
//                           borderRadius: BorderRadius.circular(16),
//                         ),
//                         const SizedBox(height: 25),
//                       ],
//                     ),
//                   ),
//                 ),
//
//                 const SizedBox(height: 30),
//
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 15),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       /// USER NAME
//                       RichText(
//                         text: TextSpan(
//                           style: GoogleFonts.mulish(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w500,
//                           ),
//                           children: [
//                             TextSpan(
//                               text: 'Name of the User ',
//                               style: TextStyle(color: AppColor.mildBlack),
//                             ),
//                             const TextSpan(
//                               text: '( As per Govt Certificate )',
//                               style: TextStyle(color: AppColor.mediumLightGray),
//                             ),
//                           ],
//                         ),
//                       ),
//
//                       const SizedBox(height: 10),
//
//                       /// ENGLISH NAME
//                       CommonContainer.fillingContainer(
//                         text: ' ',
//                         verticalDivider: false,
//                         controller: englishNameController,
//                         context: context,
//                         validator:
//                             (v) =>
//                                 v == null || v.trim().isEmpty
//                                     ? 'Enter name'
//                                     : null,
//                       ),
//
//                       // const SizedBox(height: 10),
//                       //
//                       // /// TAMIL NAME
//                       // CommonContainer.fillingContainer(
//                       //   onChanged: (value) async {
//                       //     setState(() => isTamilNameLoading = true);
//                       //     final result =
//                       //         await TanglishTamilHelper.transliterate(value);
//                       //
//                       //     setState(() {
//                       //       tamilNameSuggestion = result;
//                       //       isTamilNameLoading = false;
//                       //     });
//                       //   },
//                       //   text: 'Tamil',
//                       //   verticalDivider: true,
//                       //   controller: tamilNameController,
//                       //   context: context,
//                       //   validator:
//                       //       (v) =>
//                       //           v == null || v.trim().isEmpty
//                       //               ? 'Enter Tamil name'
//                       //               : null,
//                       // ),
//                       //
//                       // if (isTamilNameLoading)
//                       //   const Padding(
//                       //     padding: EdgeInsets.all(8.0),
//                       //     child: CircularProgressIndicator(strokeWidth: 2),
//                       //   ),
//                       //
//                       // if (tamilNameSuggestion.isNotEmpty)
//                       //   Container(
//                       //     margin: const EdgeInsets.only(top: 4),
//                       //     constraints: const BoxConstraints(maxHeight: 150),
//                       //     decoration: BoxDecoration(
//                       //       color: Colors.white,
//                       //       borderRadius: BorderRadius.circular(15),
//                       //       border: Border.all(color: Colors.grey),
//                       //     ),
//                       //     child: ListView.builder(
//                       //       shrinkWrap: true,
//                       //       itemCount: tamilNameSuggestion.length,
//                       //       itemBuilder: (context, index) {
//                       //         final suggestion = tamilNameSuggestion[index];
//                       //         return ListTile(
//                       //           title: Text(suggestion),
//                       //           onTap: () {
//                       //             TanglishTamilHelper.applySuggestion(
//                       //               controller: tamilNameController,
//                       //               suggestion: suggestion,
//                       //               onSuggestionApplied: () {
//                       //                 setState(() => tamilNameSuggestion = []);
//                       //               },
//                       //             );
//                       //           },
//                       //         );
//                       //       },
//                       //     ),
//                       //   ),
//                       SizedBox(height: 30),
//
//                       Text(
//                         'Mobile Number',
//                         style: GoogleFonts.mulish(color: AppColor.mildBlack),
//                       ),
//                       SizedBox(height: 10),
//                       CommonContainer.fillingContainer(
//                         controller: mobileController,
//                         verticalDivider: false,
//                         isMobile: true, // mobile behavior +91 etc
//                         text: '',
//                         keyboardType: TextInputType.phone,
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Please Enter Mobile Number';
//                           }
//                           return null;
//                         },
//                       ),
//                       SizedBox(height: 30),
//
//                       /// EMAIL
//                       Text(
//                         'Email Id',
//                         style: GoogleFonts.mulish(color: AppColor.mildBlack),
//                       ),
//                       SizedBox(height: 10),
//
//                       CommonContainer.fillingContainer(
//                         keyboardType: TextInputType.emailAddress,
//                         text: 'Email Id',
//                         verticalDivider: true,
//                         controller: emailIdController,
//                         context: context,
//                         validator: (v) {
//                           if (v == null || v.isEmpty) {
//                             return 'Email required';
//                           }
//                           if (!RegExp(
//                             r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
//                           ).hasMatch(v)) {
//                             return 'Enter valid email';
//                           }
//                           return null;
//                         },
//                       ),
//
//                       SizedBox(height: 30),
//
//                       /// DOB
//                       Text(
//                         'Date of Birth',
//                         style: GoogleFonts.mulish(color: AppColor.mildBlack),
//                       ),
//                       SizedBox(height: 10),
//
//                       CommonContainer.fillingContainer(
//                         isDOB: true,
//                         verticalDivider: true,
//                         imagePath: AppImages.dob,
//                         imageWidth: 20,
//                         imageHight: 25,
//                         controller: dateOfBirthController,
//                         textFontWeight: FontWeight.w700,
//                         context: context,
//                         datePickMode: DatePickMode.single,
//                         validator:
//                             (v) =>
//                                 v == null || v.isEmpty ? 'DOB required' : null,
//                       ),
//
//                       SizedBox(height: 30),
//
//                       /// GENDER
//                       Text(
//                         'Gender',
//                         style: GoogleFonts.mulish(color: AppColor.mildBlack),
//                       ),
//                       SizedBox(height: 10),
//
//                       CommonContainer.fillingContainer(
//                         readOnly: true,
//                         isDropdown: true,
//                         dropdownItems: ['Male', 'Female', 'Others'],
//                         verticalDivider: false,
//                         imagePath: AppImages.drapDownImage,
//                         imageColor: AppColor.gray84,
//                         controller: genderController,
//                         context: context,
//                         validator:
//                             (v) =>
//                                 v == null || v.isEmpty ? 'Select gender' : null,
//                       ),
//
//                       SizedBox(height: 30),
//
//                       Text(
//                         'Aadhar No',
//                         style: GoogleFonts.mulish(color: AppColor.mildBlack),
//                       ),
//                       SizedBox(height: 10),
//
//                       CommonContainer.fillingContainer(
//                         keyboardType: TextInputType.number,
//                         isAadhaar: true,
//                         text: 'Aadhar No',
//                         verticalDivider: true,
//                         controller: aadharController,
//                         context: context,
//                         validator: (v) {
//                           final digits = (v ?? '').replaceAll(' ', '');
//                           if (digits.length != 12) {
//                             return 'Enter valid 12 digit Aadhar No';
//                           }
//                           return null;
//                         },
//                       ),
//
//                       SizedBox(height: 30),
//                       CommonContainer.containerTitle(
//                         context: context,
//                         title: 'Aadhar Photo',
//                         image: AppImages.iImage,
//                         infoMessage:
//                             'Please upload a clear photo of your Aadhar.',
//                       ),
//                       SizedBox(height: 10),
//                       _addImageContainer(index: 0, checkIndividualError: true),
//                       SizedBox(height: 30),
//
//                       /// SUBMIT
//                       CommonContainer.button(
//                         buttonColor: AppColor.darkBlue,
//                         imagePath:
//                             state.isLoading ? null : AppImages.rightStickArrow,
//                         text:
//                             state.isLoading
//                                 ? ThreeDotsLoader()
//                                 : Text('Save & Continue'),
//                         onTap: () async {
//                           setState(() => _isSubmitted = true);
//
//                           /// 1) Validate form fields
//                           if (!_formKey.currentState!.validate()) {
//                             return;
//                           }
//
//                           /// 2) Validate Aadhaar photo
//                           final hasAadharPhoto = _validateAadharPhoto();
//                           if (!hasAadharPhoto) {
//                             AppSnackBar.error(
//                               context,
//                               "Please upload your Aadhar photo",
//                             );
//                             return;
//                           }
//
//                           final englishName = englishNameController.text.trim();
//                           final tamilName = tamilNameController.text.trim();
//                           final mobile = mobileController.text.trim();
//                           final email = emailIdController.text.trim();
//                           final gender = genderController.text.trim();
//                           final aadhar = aadharController.text.trim();
//                           final input = dateOfBirthController.text.trim();
//
//                           String dobForApi = '';
//                           try {
//                             final parsedDate = DateFormat(
//                               'dd-MM-yyyy',
//                             ).parseStrict(input);
//                             dobForApi = DateFormat(
//                               'yyyy-MM-dd',
//                             ).format(parsedDate);
//                           } catch (e) {
//                             AppSnackBar.error(context, "Invalid DOB");
//                             return;
//                           }
//
//                           /// 3) Build Aadhaar document URL for API
//                           String aadharDocUrl = '';
//
//                           if (_pickedImages[0] != null) {
//                             // TODO: replace with your upload API call and get URL
//                             // Example:
//                             // aadharDocUrl = await uploadAadharAndGetUrl(_pickedImages[0]!);
//                             aadharDocUrl =
//                                 _pickedImages[0]!
//                                     .path; // temp: at least send something
//                           } else if (_existingUrls[0] != null &&
//                               _existingUrls[0]!.isNotEmpty) {
//                             aadharDocUrl = _existingUrls[0]!;
//                           }
//
//                           AppLogger.log.i(
//                             'ownershipType: $ownershipType, businessType: $businessTypeForApi',
//                           );
//
//                           await ref
//                               .read(heaterRegisterNotifier.notifier)
//                               .registerVendor(
//                                 aadhaarFile: _pickedImages[0]!,
//                                 screen: VendorRegisterScreen.screen1,
//                                 vendorName: englishName,
//                                 vendorNameTamil: tamilName,
//                                 phoneNumber: mobile,
//                                 aadharNumber: aadhar,
//                                 aadharDocumentUrl:
//                                     aadharDocUrl, //  now sending Aadhaar photo
//                                 bankAccountNumber: '',
//                                 bankName: '',
//                                 bankAccountName: '',
//                                 bankBranch: '',
//                                 bankIfsc: '',
//                                 companyName: '',
//                                 companyAddress: '',
//                                 gpsLatitude: '',
//                                 gpsLongitude: '',
//                                 primaryCity: '',
//                                 primaryState: '',
//                                 companyContactNumber: '',
//                                 alternatePhone: '',
//                                 companyEmail: '',
//                                 gstNumber: '',
//                                 avatarUrl: '',
//                                 email: email,
//                                 dateOfBirth: dobForApi,
//                                 gender: gender,
//                               );
//
//                           final newState = ref.read(heaterRegisterNotifier);
//
//                           if (newState.error != null) {
//                             AppSnackBar.error(context, newState.error!);
//                           } else if (newState.vendorResponse != null) {
//                             AppSnackBar.success(
//                               context,
//                               "Owner information saved successfully",
//                             );
//                             if (widget.edit == true) {
//                               Navigator.pop(context);
//                             } else {
//                               context.push(AppRoutes.heaterRegister2Path);
//                             }
//
//                             AppLogger.log.i(
//                               "Owner Info Saved  ${newState.vendorResponse?.toJson()}",
//                             );
//                           }
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//
//                 SizedBox(height: 30),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
