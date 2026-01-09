import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:tringo_vendor_new/Core/Const/app_logger.dart';
import 'package:tringo_vendor_new/Presentation/Login%20Screen/Controller/login_notifier.dart';
import 'package:tringo_vendor_new/Presentation/Owner%20Screen/controller/owner_info_notifer.dart';
import '../../../../Core/Session/registration_session.dart';
import '../../../Core/Const/app_color.dart';
import '../../../Core/Const/app_images.dart';
import '../../../Core/Offline_Data/Screens/offline_demo_screen.dart';
import '../../../Core/Offline_Data/offline_owner_payload.dart';
import '../../../Core/Offline_Data/provider/offline_providers.dart';
import '../../../Core/Offline_Data/offline_sync_models.dart';
import '../../../Core/Utility/app_loader.dart';
import '../../../Core/Utility/app_prefs.dart';
import '../../../Core/Utility/app_snackbar.dart';
import '../../../Core/Utility/app_textstyles.dart';
import '../../../Core/Utility/thanglish_to_tamil.dart';
import '../../../Core/Widgets/app_go_routes.dart';
import '../../../Core/Widgets/common_container.dart';
import '../../../Core/Widgets/owner_verify_feild.dart';

class OwnerInfoScreens extends ConsumerStatefulWidget {
  final bool isService;
  final bool isIndividual;
  final bool fromOffline; // ✅ new
  final String? offlineSessionId; // ✅ new
  const OwnerInfoScreens({
    super.key,
    this.isCompany,
    required this.isService,
    required this.isIndividual,
    this.fromOffline = false,
    this.offlineSessionId,
  });
  final bool? isCompany;
  @override
  ConsumerState<OwnerInfoScreens> createState() => _OwnerInfoScreensState();
}

class _OwnerInfoScreensState extends ConsumerState<OwnerInfoScreens> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitted = false;
  final FocusNode mobileFocusNode = FocusNode();

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
  bool _prefilled = false;

  final int otpLength = 4;
  late List<TextEditingController> otpControllers;
  late List<FocusNode> otpFocusNodes;
  Timer? _tamilDebounce;
  int _tamilReqId = 0;
  late final String ownershipType;
  late final String businessTypeForApi;
  @override
  void initState() {
    super.initState();

    ownershipType = widget.isIndividual ? 'INDIVIDUAL' : 'COMPANY';
    businessTypeForApi = widget.isService ? 'SERVICES' : 'SELLING_PRODUCTS';

    otpControllers = List.generate(otpLength, (_) => TextEditingController());
    otpFocusNodes = List.generate(otpLength, (_) => FocusNode());
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.fromOffline) {
        await _prefillFromOffline();
        if (mounted) mobileFocusNode.requestFocus();
      }
    });
  }

  bool showOtp = false;
  bool isVerified = false;
  bool showOtpError = false;

  Timer? resendTimer;

  void startResendTimer() {
    resendTimer?.cancel();
    resendSeconds = 30;

    resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendSeconds == 0) {
        timer.cancel();
      } else {
        setState(() => resendSeconds--);
      }
    });
  }

  @override
  void dispose() {
    englishNameController.dispose();
    tamilNameController.dispose();
    mobileController.dispose();
    emailIdController.dispose();
    dateOfBirthController.dispose();
    genderController.dispose();
    _tamilDebounce?.cancel();
    for (final c in otpControllers) {
      c.dispose();
    }
    for (final f in otpFocusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _setIfEmpty(TextEditingController c, String v) {
    if (c.text.trim().isNotEmpty) return;
    final val = v.trim();
    if (val.isEmpty) return;
    c.text = val;
  }

  Future<void> _prefillFromOffline() async {
    if (_prefilled) return;

    final sid = widget.offlineSessionId;
    if (sid == null || sid.trim().isEmpty) return;

    final db = ref.read(offlineSyncDbProvider);
    final raw = await db.getPayload(sid, SyncStepType.owner); // ✅ updated
    if (raw == null) return;

    final p = OfflineOwnerPayload.fromMap(raw);

    _setIfEmpty(
      englishNameController,
      p.govtRegisteredName.isNotEmpty ? p.govtRegisteredName : p.fullName,
    );
    _setIfEmpty(tamilNameController, p.ownerNameTamil);
    _setIfEmpty(mobileController, p.phone10);
    _setIfEmpty(emailIdController, p.email);
    _setIfEmpty(dateOfBirthController, p.dobUi);
    _setIfEmpty(genderController, p.genderUi);

    _prefilled = true;
    if (mounted) setState(() {});
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

  @override
  Widget build(BuildContext context) {
    // final state = ref.watch(ownerInfoNotifierProvider);
    final ownerState = ref.watch(ownerInfoNotifierProvider);
    final bool isIndividualFlow = widget.isIndividual ?? true;
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
                        'Register Shop',
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
                        isIndividualFlow ? 'Individual' : 'Company',
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

                      CommonContainer.fillingContainer(
                        text: 'English',
                        verticalDivider: true,
                        controller: englishNameController,
                        context: context,
                        // validator:
                        //     (v) =>
                        //         v == null || v.trim().isEmpty
                        //             ? 'Enter English name'
                        //             : null,
                      ),

                      const SizedBox(height: 10),
                      CommonContainer.fillingContainer(
                        onChanged: (value) {
                          // ✅ Debounce: wait user stops typing for 400ms
                          _tamilDebounce?.cancel();
                          _tamilDebounce = Timer(
                            const Duration(milliseconds: 400),
                            () async {
                              final text = value.trim();

                              // if empty, clear and stop loading
                              if (text.isEmpty) {
                                if (!mounted) return;
                                setState(() {
                                  tamilNameSuggestion = [];
                                  isTamilNameLoading = false;
                                });
                                return;
                              }

                              final int reqId = ++_tamilReqId;

                              if (!mounted) return;
                              setState(() => isTamilNameLoading = true);

                              try {
                                final result =
                                    await TanglishTamilHelper.transliterate(
                                      text,
                                    );

                                // ✅ ignore old responses
                                if (!mounted || reqId != _tamilReqId) return;

                                setState(() => tamilNameSuggestion = result);
                              } finally {
                                if (!mounted || reqId != _tamilReqId) return;
                                setState(() => isTamilNameLoading = false);
                              }
                            },
                          );
                        },
                        text: 'Tamil',
                        verticalDivider: true,
                        controller: tamilNameController,
                        context: context,
                      ),

                      // CommonContainer.fillingContainer(
                      //   onChanged: (value) async {
                      //     setState(() => isTamilNameLoading = true);
                      //     final result =
                      //         await TanglishTamilHelper.transliterate(value);
                      //
                      //     setState(() {
                      //       tamilNameSuggestion = result;
                      //       isTamilNameLoading = false;
                      //     });
                      //   },
                      //   text: 'Tamil',
                      //   verticalDivider: true,
                      //   controller: tamilNameController,
                      //   context: context,
                      //   // validator:
                      //   //     (v) =>
                      //   //         v == null || v.trim().isEmpty
                      //   //             ? 'Enter Tamil name'
                      //   //             : null,
                      // ),
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

                      const SizedBox(height: 30),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        transitionBuilder:
                            (child, animation) => FadeTransition(
                              opacity: animation,
                              child: child,
                            ),
                        child: OwnerVerifyField(
                          controller: mobileController,
                          focusNode: mobileFocusNode,
                          isLoading: ownerState.isSendingOtp,
                          isOtpVerifying: ownerState.isVerifyingOtp,
                          onSendOtp: (mobile) {
                            return ref
                                .read(ownerInfoNotifierProvider.notifier)
                                .ownerInfoNumberRequest(phoneNumber: mobile);
                          },
                          onVerifyOtp: (mobile, otp) async {
                            final ok = await ref
                                .read(ownerInfoNotifierProvider.notifier)
                                .ownerInfoOtpRequest(
                                  phoneNumber: mobile,
                                  code: otp,
                                );

                            if (!ok || !widget.fromOffline || !context.mounted)
                              return ok;

                            final sid = widget.offlineSessionId;
                            if (sid == null || sid.trim().isEmpty) return ok;

                            final db = ref.read(offlineSyncDbProvider);

                            final oldOwner =
                                await db.getPayload(sid, SyncStepType.owner) ??
                                {};

                            final updatedOwner = <String, dynamic>{
                              ...oldOwner,

                              // ✅ update all possible keys
                              "phoneNumber": mobile,
                              "phone": mobile,
                              "mobile": mobile,
                              "mobileNumber": mobile,

                              // ✅ MOST IMPORTANT for your OfflineDemoScreen (you are reading this key)
                              "ownerPhoneNumber": mobile,
                            };

                            await db.upsertStep(
                              sessionId: sid,
                              type: SyncStepType.owner,
                              payload: updatedOwner,
                            );

                            Navigator.pop(context, true);
                            return ok;
                          },
                        ),
                      ),

                      // AnimatedSwitcher(
                      //   duration: const Duration(milliseconds: 400),
                      //   transitionBuilder:
                      //       (child, animation) => FadeTransition(
                      //         opacity: animation,
                      //         child: child,
                      //       ),
                      //   child: OwnerVerifyField(
                      //     controller: mobileController,
                      //     focusNode: mobileFocusNode, // ✅
                      //     isLoading: ownerState.isSendingOtp,
                      //     isOtpVerifying: ownerState.isVerifyingOtp,
                      //     onSendOtp: (mobile) {
                      //       return ref
                      //           .read(ownerInfoNotifierProvider.notifier)
                      //           .ownerInfoNumberRequest(phoneNumber: mobile);
                      //     },
                      //     onVerifyOtp: (mobile, otp) async {
                      //       final ok = await ref
                      //           .read(ownerInfoNotifierProvider.notifier)
                      //           .ownerInfoOtpRequest(
                      //         phoneNumber: mobile,
                      //         code: otp,
                      //       );
                      //
                      //       if (!ok || !widget.fromOffline || !context.mounted) return ok;
                      //
                      //       final sid = widget.offlineSessionId;
                      //       if (sid == null || sid.trim().isEmpty) {
                      //         // offline session id missing, can't update db
                      //         return ok;
                      //       }
                      //
                      //       final db = ref.read(offlineSyncDbProvider);
                      //
                      //       final oldOwner = await db.getPayload(sid, SyncStepType.owner) ?? {};
                      //
                      //       final updatedOwner = <String, dynamic>{
                      //         ...oldOwner,
                      //         "phoneNumber": mobile,
                      //         "phone": mobile,
                      //         "mobile": mobile,
                      //         "mobileNumber": mobile,
                      //       };
                      //
                      //       await db.upsertStep(
                      //         sessionId: sid,
                      //         type: SyncStepType.owner,
                      //         payload: updatedOwner,
                      //       );
                      //
                      //       Navigator.pop(context, true);
                      //       return ok;
                      //     },
                      //
                      //
                      //
                      //     // onVerifyOtp: (mobile, otp) async {
                      //     //   final ok = await ref
                      //     //       .read(ownerInfoNotifierProvider.notifier)
                      //     //       .ownerInfoOtpRequest(
                      //     //         phoneNumber: mobile,
                      //     //         code: otp,
                      //     //       );
                      //     //
                      //     //   if (ok && widget.fromOffline && context.mounted) {
                      //     //     Navigator.pop(context, true);
                      //     //   }
                      //     //   return ok;
                      //     // },
                      //
                      //
                      //   ),
                      // ),
                      const SizedBox(height: 30),

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
                        // validator: (v) {
                        //   if (v == null || v.isEmpty) {
                        //     return 'Email required';
                        //   }
                        //   if (!RegExp(
                        //     r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                        //   ).hasMatch(v)) {
                        //     return 'Enter valid email';
                        //   }
                        //   return null;
                        // },
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
                        // validator:
                        //     (v) =>
                        //         v == null || v.isEmpty ? 'DOB required' : null,
                      ),

                      const SizedBox(height: 30),

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
                        imageColor: AppColor.gray84,
                        controller: genderController,
                        context: context,
                        // validator:
                        //     (v) =>
                        //         v == null || v.isEmpty ? 'Select gender' : null,
                      ),

                      SizedBox(height: 30),

                      /// SUBMIT
                      CommonContainer.button(
                        buttonColor: AppColor.black,
                        imagePath:
                            ownerState.isLoading
                                ? null
                                : AppImages.rightStickArrow,

                        text:
                            ownerState.isLoading
                                ? ThreeDotsLoader()
                                : Text('Save & Continue'),
                        onTap: () async {
                          setState(() => _isSubmitted = true);

                          if (!_formKey.currentState!.validate()) return;

                          final englishName = englishNameController.text.trim();
                          final tamilName = tamilNameController.text.trim();
                          final mobile = mobileController.text.trim();
                          final email = emailIdController.text.trim();
                          final input = dateOfBirthController.text.trim();

                          String dobForApi = '';
                          try {
                            final parsedDate = DateFormat(
                              'dd-MM-yyyy',
                            ).parseStrict(input);
                            dobForApi = DateFormat(
                              'yyyy-MM-dd',
                            ).format(parsedDate);
                          } catch (_) {
                            AppSnackBar.error(context, "Invalid DOB");
                            return;
                          }

                          final gender = genderController.text.trim();

                          final ok = await ref
                              .read(ownerInfoNotifierProvider.notifier)
                              .ownerInfoRegister(
                                ownershipType: ownershipType,
                                businessType: businessTypeForApi,
                                ownerNameTamil: tamilName,
                                ownerPhoneNumber: mobile,
                                govtRegisteredName: englishName,
                                gender: gender,
                                fullName: englishName,
                                dateOfBirth: dobForApi,
                                email: email,
                                preferredLanguage: '',
                              );

                          final newState = ref.read(ownerInfoNotifierProvider);

                          if (!ok) {
                            AppSnackBar.error(
                              context,
                              newState.error ?? "Something went wrong",
                            );
                            return;
                          }

                          // ✅ ALWAYS go to ShopCategoryInfo (online + offline)
                          // Online: employeeId will be available
                          // Offline: employeeId may be null -> next screen should read offlineSessionId from prefs if needed
                          final employeeId =
                              newState.ownerRegisterResponse?.data?.id;

                          if (!mounted) return;

                          context.push(
                            AppRoutes.shopCategoryInfoPath,
                            extra: {
                              'isService': widget.isService,
                              'isIndividual': widget.isIndividual,
                              'pages': 'OwnerInfoScreens',
                              'employeeId':
                                  employeeId, // can be null in offline case
                              // Optional: pass this too if your ShopCategory needs it
                              'offlineSessionId':
                                  await AppPrefs.getOfflineSessionId(),
                            },
                          );
                        },

                        // onTap: () async {
                        //   setState(() => _isSubmitted = true);
                        //
                        //   if (!_formKey.currentState!.validate()) {
                        //     return;
                        //   }
                        //
                        //   final englishName = englishNameController.text.trim();
                        //   final tamilName = tamilNameController.text.trim();
                        //   final mobile = mobileController.text.trim();
                        //   final email = emailIdController.text.trim();
                        //   final input = dateOfBirthController.text.trim();
                        //
                        //   String dobForApi = '';
                        //   try {
                        //     final parsedDate = DateFormat(
                        //       'dd-MM-yyyy',
                        //     ).parseStrict(input);
                        //     dobForApi = DateFormat(
                        //       'yyyy-MM-dd',
                        //     ).format(parsedDate);
                        //   } catch (e) {
                        //     AppSnackBar.error(context, "Invalid DOB");
                        //     return;
                        //   }
                        //
                        //   final gender = genderController.text.trim();
                        //
                        //   AppLogger.log.i(
                        //     'ownershipType: $ownershipType, businessType: $businessTypeForApi',
                        //   );
                        //
                        //   await ref
                        //       .read(ownerInfoNotifierProvider.notifier)
                        //       .ownerInfoRegister(
                        //         ownershipType:
                        //             ownershipType, // ✅ "INDIVIDUAL" / "COMPANY"
                        //         businessType:
                        //             businessTypeForApi, // ✅ "PRODUCT" / "SERVICE" (adjust if backend uses different strings)
                        //         ownerNameTamil: tamilName,
                        //         ownerPhoneNumber: mobile,
                        //         govtRegisteredName: englishName,
                        //         gender: gender,
                        //         fullName: englishName,
                        //         dateOfBirth: dobForApi,
                        //         email: email,
                        //         preferredLanguage: '',
                        //       );
                        //
                        //   final newState = ref.read(ownerInfoNotifierProvider);
                        //
                        //   if (newState.error != null) {
                        //     AppSnackBar.error(context, newState.error!);
                        //   } else if (newState.ownerRegisterResponse != null) {
                        //     final employeeId =
                        //         newState
                        //             .ownerRegisterResponse
                        //             ?.data
                        //             ?.id; // <-- change if your model differs
                        //
                        //     context.push(
                        //       AppRoutes.shopCategoryInfoPath,
                        //       extra: {
                        //         'isService': widget.isService,
                        //         'isIndividual': widget.isIndividual,
                        //         // 'initialShopNameEnglish':
                        //         //     englishNameController.text.trim(),
                        //         // 'initialShopNameTamil':
                        //         //     tamilNameController.text.trim(),
                        //         'pages': 'OwnerInfoScreens',
                        //         'employeeId': employeeId,
                        //       },
                        //     );
                        //     //
                        //     //   AppLogger.log.i(
                        //     //     "Owner Info Saved  ${newState.ownerResponse?.toJson()}",
                        //     //   );
                        //     // }
                        //   }
                        // },
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
