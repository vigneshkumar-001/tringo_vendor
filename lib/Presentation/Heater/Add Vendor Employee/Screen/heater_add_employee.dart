import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tringo_vendor_new/Core/Const/app_color.dart';
import 'package:tringo_vendor_new/Core/Const/app_images.dart';
import 'package:tringo_vendor_new/Core/Utility/app_loader.dart';
import 'package:tringo_vendor_new/Core/Utility/app_snackbar.dart';
import 'package:tringo_vendor_new/Core/Utility/app_textstyles.dart';
import 'package:tringo_vendor_new/Presentation/Heater/Add Vendor Employee/Controller/add_employee_notifier.dart';
import '../../../../Core/Widgets/app_go_routes.dart';
import '../../../../Core/Widgets/common_container.dart';
import '../../../../Core/Widgets/owner_verify_feild.dart';
import 'employee_approval_pending.dart';

class HeaterAddEmployee extends ConsumerStatefulWidget {
  const HeaterAddEmployee({super.key});

  @override
  ConsumerState<HeaterAddEmployee> createState() => _HeaterAddEmployeeState();
}

class _HeaterAddEmployeeState extends ConsumerState<HeaterAddEmployee> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitted = false;

  final TextEditingController englishNameController = TextEditingController();
  final TextEditingController emergencyNameController = TextEditingController();
  final TextEditingController emergencyRelationShipController =
      TextEditingController();
  final TextEditingController emailIdController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController aadharController = TextEditingController();
  final TextEditingController emergencyMobileController =
      TextEditingController();

  final ImagePicker _picker = ImagePicker();

  List<File?> _pickedImages = List<File?>.filled(2, null, growable: false);
  List<bool> _hasError = List<bool>.filled(2, false, growable: false);
  List<String?> _existingUrls = List<String?>.filled(2, null, growable: false);

  // ✅ NEW: safe india phone normalize (avoid +91+91 / 9191)
  String _normalizeIndianPhone10(String input) {
    var p = input.trim();
    p = p.replaceAll(RegExp(r'[^0-9]'), '');
    if (p.startsWith('91') && p.length == 12) {
      p = p.substring(2);
    }
    if (p.length > 10) {
      p = p.substring(p.length - 10);
    }
    return p;
  }

  @override
  void dispose() {
    englishNameController.dispose();
    emergencyNameController.dispose();
    emergencyRelationShipController.dispose();
    mobileController.dispose();
    emailIdController.dispose();
    emergencyMobileController.dispose();
    aadharController.dispose();
    super.dispose();
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

  Future<void> _pickImageFromSource(int index, ImageSource source) async {
    final pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 85,
    );

    if (pickedFile == null) return;

    setState(() {
      _pickedImages[index] = File(pickedFile.path);
      _hasError[index] = false;
    });
  }

  bool _validateImages() {
    bool hasError = false;

    for (int i = 0; i < 2; i++) {
      if (_pickedImages[i] == null) {
        _hasError[i] = true;
        hasError = true;
      } else {
        _hasError[i] = false;
      }
    }

    setState(() {});
    return !hasError;
  }

  Widget _imageBox({required int index}) {
    final file = _pickedImages[index];
    final hasError = _hasError[index];
    final hasImage = file != null;

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
                          child: Image.file(
                            file!,
                            fit: BoxFit.cover,
                            height: 150,
                            width: double.infinity,
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

  // ✅ NEW: Add success -> refresh employee list (prevents blocked-stale UI)
  Future<void> _refreshEmployeesSilent() async {
    try {
      await ref
          .read(addEmployeeNotifier.notifier)
          .getEmployeeList(silent: true);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(addEmployeeNotifier);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          // ✅ FIX: actually call a method
          onRefresh: () async {
            await ref.read(addEmployeeNotifier.notifier).getEmployeeList();
          },
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
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 16,
                    ),
                    child: Row(
                      children: [
                        CommonContainer.topLeftArrow(
                          onTap: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 50),
                        Text(
                          'Register Vendor',
                          style: AppTextStyles.mulish(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColor.mildBlack,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Employee',
                          style: AppTextStyles.mulish(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColor.mildBlack,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 35),

                  Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(AppImages.registerBCImage),
                        fit: BoxFit.cover,
                      ),
                      gradient: LinearGradient(
                        colors: [AppColor.white, AppColor.lavenderMist],
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
                          Image.asset(AppImages.vendorEmployee, height: 85),
                          const SizedBox(height: 15),
                          Text(
                            'Add Vendor Employee',
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
                        Text(
                          'Name',
                          style: AppTextStyles.mulish(
                            color: AppColor.mildBlack,
                          ),
                        ),
                        const SizedBox(height: 10),
                        CommonContainer.fillingContainer(
                          controller: englishNameController,
                          context: context,
                          validator:
                              (v) =>
                                  v == null || v.trim().isEmpty
                                      ? 'Name required'
                                      : null,
                        ),
                        const SizedBox(height: 30),
                        Text(
                          'Mobile Number',
                          style: AppTextStyles.mulish(
                            color: AppColor.mildBlack,
                          ),
                        ),
                        const SizedBox(height: 10),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 400),
                          transitionBuilder:
                              (child, animation) => FadeTransition(
                                opacity: animation,
                                child: child,
                              ),
                          child: OwnerVerifyField(
                            controller: mobileController,
                            isLoading: state.isSendingOtp,
                            isOtpVerifying: state.isVerifyingOtp,
                            onSendOtp: (mobile) {
                              return ref
                                  .read(addEmployeeNotifier.notifier)
                                  .employeeAddNumberRequest(
                                    phoneNumber: mobile,
                                  );
                            },
                            onVerifyOtp: (mobile, otp) {
                              return ref
                                  .read(addEmployeeNotifier.notifier)
                                  .employeeAddOtpRequest(
                                    phoneNumber: mobile,
                                    code: otp,
                                  );
                            },
                          ),
                        ),
                        const SizedBox(height: 30),

                        Text(
                          'Email Id',
                          style: GoogleFonts.mulish(color: AppColor.mildBlack),
                        ),
                        const SizedBox(height: 10),
                        CommonContainer.fillingContainer(
                          controller: emailIdController,
                          keyboardType: TextInputType.emailAddress,
                          context: context,
                          validator: (v) {
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

                        Text(
                          'Emergency Contact Details',
                          style: GoogleFonts.mulish(color: AppColor.mildBlack),
                        ),
                        const SizedBox(height: 10),

                        CommonContainer.fillingContainer(
                          text: 'Name',
                          verticalDivider: true,
                          controller: emergencyNameController,
                          context: context,
                          validator:
                              (v) =>
                                  v == null || v.trim().isEmpty
                                      ? 'Name required'
                                      : null,
                        ),
                        const SizedBox(height: 10),

                        CommonContainer.fillingContainer(
                          text: 'Relationship',
                          verticalDivider: true,
                          controller: emergencyRelationShipController,
                          context: context,
                          validator:
                              (v) =>
                                  v == null || v.trim().isEmpty
                                      ? 'Relationship required'
                                      : null,
                        ),
                        const SizedBox(height: 10),

                        CommonContainer.fillingContainer(
                          text: 'Mobile Number',
                          isMobile: true,
                          controller: emergencyMobileController,
                          context: context,
                          validator:
                              (v) =>
                                  v == null || v.isEmpty
                                      ? 'Please enter mobile number'
                                      : null,
                        ),

                        const SizedBox(height: 30),

                        Text(
                          'Aadhar No',
                          style: GoogleFonts.mulish(color: AppColor.mildBlack),
                        ),
                        const SizedBox(height: 10),

                        CommonContainer.fillingContainer(
                          verticalDivider: false,
                          controller: aadharController,
                          context: context,
                          keyboardType: TextInputType.number,
                          isAadhaar: true,
                          validator: (v) {
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
                        _imageBox(index: 0),

                        const SizedBox(height: 30),

                        CommonContainer.containerTitle(
                          context: context,
                          title: 'Profile Picture',
                          image: AppImages.iImage,
                          infoMessage: 'Please upload a clear profile picture.',
                        ),
                        const SizedBox(height: 10),
                        _imageBox(index: 1),

                        const SizedBox(height: 30),

                        CommonContainer.button(
                          buttonColor: AppColor.darkBlue,
                          imagePath:
                              state.isLoading
                                  ? null
                                  : AppImages.rightStickArrow,
                          text:
                              state.isLoading
                                  ? ThreeDotsLoader()
                                  : const Text('Save & Continue'),
                          onTap: () async {
                            setState(() => _isSubmitted = true);

                            if (!_formKey.currentState!.validate()) return;

                            if (!_validateImages()) {
                              AppSnackBar.error(
                                context,
                                "Please upload required images",
                              );
                              return;
                            }

                            // ✅ normalize numbers before API call
                            final phone10 = _normalizeIndianPhone10(
                              mobileController.text,
                            );
                            final emergency10 = _normalizeIndianPhone10(
                              emergencyMobileController.text,
                            );

                            await ref
                                .read(addEmployeeNotifier.notifier)
                                .addEmployeeVendor(
                                  phoneNumber: phone10,
                                  fullName: englishNameController.text.trim(),
                                  email: emailIdController.text.trim(),
                                  emergencyContactName:
                                      emergencyNameController.text.trim(),
                                  emergencyContactRelationship:
                                      emergencyRelationShipController.text
                                          .trim(),
                                  emergencyContactPhone: emergency10,
                                  aadhaarNumber: aadharController.text.trim(),
                                  aadhaarFile: _pickedImages[0]!,
                                  ownerImageFile: _pickedImages[1]!,
                                );

                            final newState = ref.read(addEmployeeNotifier);

                            if (newState.error != null) {
                              AppSnackBar.error(context, newState.error!);
                              return;
                            }

                            //  refresh list so new employee shows correctly (not blocked/stale)
                            await _refreshEmployeesSilent();

                            AppSnackBar.success(
                              context,
                              "Employee added successfully",
                            );

                            final prefs = await SharedPreferences.getInstance();
                            final vendorStatus =
                                (prefs.getString('vendorStatus') ?? 'PENDING')
                                    .toUpperCase();
                            final hasShownPending =
                                prefs.getBool('hasShownPendingScreen') ?? false;

                            if (vendorStatus == 'ACTIVE') {
                              if (!mounted) return;
                              context.pop();
                              return;
                            }

                            if (!hasShownPending) {
                              await prefs.setBool(
                                'hasShownPendingScreen',
                                true,
                              );
                              if (!mounted) return;
                              context.push(
                                AppRoutes.employeeApprovalPendingPath,
                              );
                            } else {
                              if (!mounted) return;
                              context.pop();
                            }
                          },
                        ),

                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ],
              ),
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
// import 'package:shared_preferences/shared_preferences.dart';
//
// import 'package:tringo_vendor_new/Core/Const/app_color.dart';
// import 'package:tringo_vendor_new/Core/Const/app_images.dart';
// import 'package:tringo_vendor_new/Core/Utility/app_loader.dart';
// import 'package:tringo_vendor_new/Core/Utility/app_snackbar.dart';
// import 'package:tringo_vendor_new/Core/Utility/app_textstyles.dart';
// import 'package:tringo_vendor_new/Presentation/Heater/Add Vendor Employee/Controller/add_employee_notifier.dart';
// import '../../../../Core/Widgets/app_go_routes.dart';
// import '../../../../Core/Widgets/common_container.dart';
// import '../../../../Core/Widgets/owner_verify_feild.dart';
// import 'employee_approval_pending.dart';
//
// class HeaterAddEmployee extends ConsumerStatefulWidget {
//   const HeaterAddEmployee({super.key});
//
//   @override
//   ConsumerState<HeaterAddEmployee> createState() => _HeaterAddEmployeeState();
// }
//
// class _HeaterAddEmployeeState extends ConsumerState<HeaterAddEmployee> {
//   final _formKey = GlobalKey<FormState>();
//   bool _isSubmitted = false;
//
//   final TextEditingController englishNameController = TextEditingController();
//   final TextEditingController emergencyNameController = TextEditingController();
//   final TextEditingController emergencyRelationShipController =
//       TextEditingController();
//   final TextEditingController emailIdController = TextEditingController();
//   final TextEditingController mobileController = TextEditingController();
//   final TextEditingController aadharController = TextEditingController();
//   final TextEditingController emergencyMobileController =
//       TextEditingController();
//
//   final ImagePicker _picker = ImagePicker();
//
//   List<File?> _pickedImages = List<File?>.filled(2, null, growable: false);
//   List<bool> _hasError = List<bool>.filled(2, false, growable: false);
//   List<String?> _existingUrls = List<String?>.filled(2, null, growable: false);
//
//   @override
//   void dispose() {
//     englishNameController.dispose();
//     emergencyNameController.dispose();
//     emergencyRelationShipController.dispose();
//     mobileController.dispose();
//     emailIdController.dispose();
//     emergencyMobileController.dispose();
//     aadharController.dispose();
//     super.dispose();
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
//   Future<void> _pickImage(int index) async {
//     final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
//
//     if (pickedFile != null) {
//       setState(() {
//         _pickedImages[index] = File(pickedFile.path);
//         _existingUrls[index] = null;
//         _hasError[index] = false;
//       });
//     }
//   }
//
//   bool _validateImages() {
//     bool hasError = false;
//
//     for (int i = 0; i < 2; i++) {
//       if (_pickedImages[i] == null) {
//         _hasError[i] = true;
//         hasError = true;
//       } else {
//         _hasError[i] = false;
//       }
//     }
//
//     setState(() {});
//     return !hasError;
//   }
//
//   Widget _imageBox({required int index}) {
//     final file = _pickedImages[index];
//     final hasError = _hasError[index];
//     final hasImage = file != null;
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
//                               SizedBox(width: 10),
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
//                           child: Image.file(
//                             file!,
//                             fit: BoxFit.cover,
//                             height: 150,
//                             width: double.infinity,
//                           ),
//                         ),
//               ),
//             ),
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
//                       SizedBox(height: 2),
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
//     final state = ref.watch(addEmployeeNotifier);
//
//
//
//     return Scaffold(
//       body: SafeArea(
//         child: RefreshIndicator(
//           onRefresh: () async {
//             await ref.read(addEmployeeNotifier.notifier);
//             await ref.read(addEmployeeNotifier.notifier);
//           },
//           child: SingleChildScrollView(
//             child: Form(
//               key: _formKey,
//               autovalidateMode:
//                   _isSubmitted
//                       ? AutovalidateMode.onUserInteraction
//                       : AutovalidateMode.disabled,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 15,
//                       vertical: 16,
//                     ),
//                     child: Row(
//                       children: [
//                         CommonContainer.topLeftArrow(
//                           onTap: () => Navigator.pop(context),
//                         ),
//                         SizedBox(width: 50),
//                         Text(
//                           'Register Vendor',
//                           style: AppTextStyles.mulish(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w500,
//                             color: AppColor.mildBlack,
//                           ),
//                         ),
//                         SizedBox(width: 5),
//                         Text(
//                           'Employee',
//                           style: AppTextStyles.mulish(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w600,
//                             color: AppColor.mildBlack,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//
//                   SizedBox(height: 35),
//
//                   Container(
//                     decoration: BoxDecoration(
//                       image: DecorationImage(
//                         image: AssetImage(AppImages.registerBCImage),
//                         fit: BoxFit.cover,
//                       ),
//                       gradient: LinearGradient(
//                         colors: [AppColor.white, AppColor.lavenderMist],
//                         begin: Alignment.topCenter,
//                         end: Alignment.bottomCenter,
//                       ),
//                       borderRadius: const BorderRadius.only(
//                         bottomRight: Radius.circular(30),
//                         bottomLeft: Radius.circular(30),
//                       ),
//                     ),
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 20),
//                       child: Column(
//                         children: [
//                           Image.asset(AppImages.vendorEmployee, height: 85),
//                           SizedBox(height: 15),
//                           Text(
//                             'Add Vendor Employee',
//                             style: AppTextStyles.mulish(
//                               fontSize: 28,
//                               fontWeight: FontWeight.w700,
//                               color: AppColor.mildBlack,
//                             ),
//                           ),
//                           SizedBox(height: 30),
//                           LinearProgressIndicator(
//                             minHeight: 12,
//                             value: 0.3,
//                             valueColor: AlwaysStoppedAnimation<Color>(
//                               AppColor.green,
//                             ),
//                             backgroundColor: AppColor.white,
//                             borderRadius: BorderRadius.circular(16),
//                           ),
//                           SizedBox(height: 25),
//                         ],
//                       ),
//                     ),
//                   ),
//
//                   SizedBox(height: 30),
//
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 15),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Name',
//                           style: AppTextStyles.mulish(
//                             color: AppColor.mildBlack,
//                           ),
//                         ),
//                         SizedBox(height: 10),
//                         CommonContainer.fillingContainer(
//                           controller: englishNameController,
//                           context: context,
//                           validator:
//                               (v) =>
//                                   v == null || v.trim().isEmpty
//                                       ? 'Name required'
//                                       : null,
//                         ),
//                         SizedBox(height: 30),
//
//                         AnimatedSwitcher(
//                           duration: const Duration(milliseconds: 400),
//                           transitionBuilder:
//                               (child, animation) => FadeTransition(
//                                 opacity: animation,
//                                 child: child,
//                               ),
//                           child: OwnerVerifyField(
//                             controller: mobileController,
//                             isLoading: state.isSendingOtp,
//                             isOtpVerifying: state.isVerifyingOtp,
//
//                             onSendOtp: (mobile) {
//                               return ref
//                                   .read(addEmployeeNotifier.notifier)
//                                   .employeeAddNumberRequest(
//                                     phoneNumber: mobile,
//                                   );
//                             },
//                             onVerifyOtp: (mobile, otp) {
//                               return ref
//                                   .read(addEmployeeNotifier.notifier)
//                                   .employeeAddOtpRequest(
//                                     phoneNumber: mobile,
//                                     code: otp,
//                                   );
//                             },
//                           ),
//                         ),
//                         SizedBox(height: 30),
//
//                         Text(
//                           'Email Id',
//                           style: GoogleFonts.mulish(color: AppColor.mildBlack),
//                         ),
//                         SizedBox(height: 10),
//                         CommonContainer.fillingContainer(
//                           controller: emailIdController,
//                           keyboardType: TextInputType.emailAddress,
//                           context: context,
//                           validator: (v) {
//                             if (v == null || v.isEmpty) return 'Email required';
//                             if (!RegExp(
//                               r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
//                             ).hasMatch(v)) {
//                               return 'Enter valid email';
//                             }
//                             return null;
//                           },
//                         ),
//
//                         SizedBox(height: 30),
//
//                         Text(
//                           'Emergency Contact Details',
//                           style: GoogleFonts.mulish(color: AppColor.mildBlack),
//                         ),
//                         SizedBox(height: 10),
//
//                         CommonContainer.fillingContainer(
//                           text: 'Name',
//                           verticalDivider: true,
//                           controller: emergencyNameController,
//                           context: context,
//                           validator:
//                               (v) =>
//                                   v == null || v.trim().isEmpty
//                                       ? 'Name required'
//                                       : null,
//                         ),
//                         SizedBox(height: 10),
//
//                         CommonContainer.fillingContainer(
//                           text: 'Relationship',
//                           verticalDivider: true,
//                           controller: emergencyRelationShipController,
//                           context: context,
//                           validator:
//                               (v) =>
//                                   v == null || v.trim().isEmpty
//                                       ? 'Relationship required'
//                                       : null,
//                         ),
//                         SizedBox(height: 10),
//
//                         CommonContainer.fillingContainer(
//                           text: 'Mobile Number',
//                           isMobile: true,
//                           controller: emergencyMobileController,
//                           context: context,
//                           validator:
//                               (v) =>
//                                   v == null || v.isEmpty
//                                       ? 'Please enter mobile number'
//                                       : null,
//                         ),
//
//                         SizedBox(height: 30),
//
//                         Text(
//                           'Aadhar No',
//                           style: GoogleFonts.mulish(color: AppColor.mildBlack),
//                         ),
//                         SizedBox(height: 10),
//
//                         CommonContainer.fillingContainer(
//                           verticalDivider: false,
//                           controller: aadharController,
//                           context: context,
//                           keyboardType: TextInputType.number,
//                           isAadhaar: true,
//                           validator: (v) {
//                             final digits = (v ?? '').replaceAll(' ', '');
//                             if (digits.length != 12) {
//                               return 'Enter valid 12 digit Aadhar No';
//                             }
//                             return null;
//                           },
//                         ),
//
//                         SizedBox(height: 30),
//                         CommonContainer.containerTitle(
//                           context: context,
//                           title: 'Aadhar Photo',
//                           image: AppImages.iImage,
//                           infoMessage:
//                               'Please upload a clear photo of your Aadhar.',
//                         ),
//                         SizedBox(height: 10),
//                         _imageBox(index: 0),
//
//                         SizedBox(height: 30),
//
//                         CommonContainer.containerTitle(
//                           context: context,
//                           title: 'Profile Picture',
//                           image: AppImages.iImage,
//                           infoMessage: 'Please upload a clear profile picture.',
//                         ),
//                         SizedBox(height: 10),
//                         _imageBox(index: 1),
//
//                         SizedBox(height: 30),
//
//                         CommonContainer.button(
//                           buttonColor: AppColor.darkBlue,
//                           imagePath:
//                               state.isLoading
//                                   ? null
//                                   : AppImages.rightStickArrow,
//                           text:
//                               state.isLoading
//                                   ? ThreeDotsLoader()
//                                   : Text('Save & Continue'),
//
//                           onTap: () async {
//                             setState(() => _isSubmitted = true);
//
//                             if (!_formKey.currentState!.validate()) return;
//
//                             if (!_validateImages()) {
//                               AppSnackBar.error(
//                                 context,
//                                 "Please upload required images",
//                               );
//                               return;
//                             }
//
//                             await ref
//                                 .read(addEmployeeNotifier.notifier)
//                                 .addEmployeeVendor(
//                                   phoneNumber: mobileController.text,
//                                   fullName: englishNameController.text.trim(),
//                                   email: emailIdController.text.trim(),
//                                   emergencyContactName:
//                                       emergencyNameController.text.trim(),
//                                   emergencyContactRelationship:
//                                       emergencyRelationShipController.text
//                                           .trim(),
//                                   emergencyContactPhone:
//                                       emergencyMobileController.text.trim(),
//                                   aadhaarNumber: aadharController.text.trim(),
//                                   aadhaarFile: _pickedImages[0]!,
//                                   ownerImageFile: _pickedImages[1]!,
//                                 );
//
//                             final newState = ref.read(addEmployeeNotifier);
//
//                             if (newState.error != null) {
//                               AppSnackBar.error(context, newState.error!);
//                               return;
//                             }
//
//                             AppSnackBar.success(
//                               context,
//                               "Employee added successfully",
//                             );
//
//                             //  NEW: decide navigation based on vendor status + first-time flag
//                             final prefs = await SharedPreferences.getInstance();
//                             final vendorStatus =
//                                 (prefs.getString('vendorStatus') ?? 'PENDING')
//                                     .toUpperCase();
//                             final hasShownPending =
//                                 prefs.getBool('hasShownPendingScreen') ?? false;
//
//                             // If vendor already ACTIVE => always go back after adding employee
//                             if (vendorStatus == 'ACTIVE') {
//                               if (!mounted) return;
//                               context.pop(); //back
//                               return;
//                             }
//
//                             // If vendor not active (PENDING/REJECTED) => only first time go to pending screen
//                             if (!hasShownPending) {
//                               await prefs.setBool(
//                                 'hasShownPendingScreen',
//                                 true,
//                               );
//                               if (!mounted) return;
//                               context.push(
//                                 AppRoutes.employeeApprovalPendingPath,
//                               ); //  only first time
//                             } else {
//                               if (!mounted) return;
//                               context.pop(); //  next adds: back
//                             }
//                           },
//
//                           // onTap: () async {
//                           //   setState(() => _isSubmitted = true);
//                           //
//                           //   if (!_formKey.currentState!.validate()) return;
//                           //
//                           //   if (!_validateImages()) {
//                           //     AppSnackBar.error(
//                           //       context,
//                           //       "Please upload required images",
//                           //     );
//                           //     return;
//                           //   }
//                           //
//                           //   await ref
//                           //       .read(addEmployeeNotifier.notifier)
//                           //       .addEmployeeVendor(
//                           //         phoneNumber: mobileController.text,
//                           //         fullName: englishNameController.text.trim(),
//                           //         email: emailIdController.text.trim(),
//                           //         emergencyContactName:
//                           //             emergencyNameController.text.trim(),
//                           //         emergencyContactRelationship:
//                           //             emergencyRelationShipController.text
//                           //                 .trim(),
//                           //         emergencyContactPhone:
//                           //             emergencyMobileController.text.trim(),
//                           //         aadhaarNumber: aadharController.text.trim(),
//                           //         aadhaarFile: _pickedImages[0]!,
//                           //         ownerImageFile: _pickedImages[1]!,
//                           //       );
//                           //
//                           //   final newState = ref.read(addEmployeeNotifier);
//                           //
//                           //   if (newState.error != null) {
//                           //     AppSnackBar.error(context, newState.error!);
//                           //     return;
//                           //   }
//                           //
//                           //   AppSnackBar.success(
//                           //     context,
//                           //     "Employee added successfully",
//                           //   );
//                           //   context.push(AppRoutes.employeeApprovalPendingPath);
//                           //
//                           //   // if (!mounted) return;
//                           //   // context.pushNamed(AppRoutes.employeeApprovalPending);
//                           // },
//                         ),
//
//                         SizedBox(height: 30),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
