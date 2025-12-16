import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../Core/Const/app_color.dart';
import '../../../../Core/Const/app_images.dart';
import '../../../../Core/Utility/app_loader.dart';
import '../../../../Core/Utility/app_snackbar.dart';
import '../../../../Core/Utility/app_textstyles.dart';
import '../../../../Core/Widgets/app_go_routes.dart';
import '../../../../Core/Widgets/common_container.dart';
import '../../Add Vendor Employee/Controller/add_employee_notifier.dart';

class HeaterEmployeeDetailsEdit extends ConsumerStatefulWidget {
  const HeaterEmployeeDetailsEdit({super.key});

  @override
  ConsumerState<HeaterEmployeeDetailsEdit> createState() =>
      _HeaterEmployeeDetailsEditState();
}

class _HeaterEmployeeDetailsEditState
    extends ConsumerState<HeaterEmployeeDetailsEdit> {
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

  Future<void> _pickImage(int index) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _pickedImages[index] = File(pickedFile.path);
        _existingUrls[index] = null;
        _hasError[index] = false;
      });
    }
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
              // onTap: () => _pickImage(index),
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
                              SizedBox(width: 10),
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
                      SizedBox(height: 2),
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
    final state = ref.watch(addEmployeeNotifier);
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await ref.read(addEmployeeNotifier.notifier);
            await ref.read(addEmployeeNotifier.notifier);
          },
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              autovalidateMode:
                  _isSubmitted
                      ? AutovalidateMode.onUserInteraction
                      : AutovalidateMode.disabled,
              child: Column(
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
                        SizedBox(width: 80),
                        Text(
                          'Employee Details',
                          style: AppTextStyles.mulish(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
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
                      ),
                      gradient: LinearGradient(
                        colors: [AppColor.white, AppColor.mintCream],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: SizedBox(
                              height: 115,
                              width: 92,
                              child: Image.asset(
                                AppImages.humanImage1,
                                width: 92,
                                height: 115,
                              ),
                              // Image.network(
                              //    data.avatarUrl ?? "",
                              //   fit: BoxFit.cover,
                              //   errorBuilder: (_, __, ___) {
                              //     return const Center(
                              //       child: Icon(
                              //         Icons.broken_image,
                              //         size: 40,
                              //       ),
                              //     );
                              //   },
                              // ),
                            ),
                          ),
                          SizedBox(width: 20),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Siva',
                                // data.name,
                                style: AppTextStyles.mulish(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  color: AppColor.darkBlue,
                                ),
                              ),
                              SizedBox(height: 3),
                              Text(
                                'THU29849H',
                                // data.employeeCode,
                                style: AppTextStyles.mulish(
                                  fontSize: 11,
                                  color: AppColor.mildBlack,
                                ),
                              ),
                              SizedBox(height: 20),
                              Text(
                                'Today Collection',
                                style: AppTextStyles.mulish(
                                  fontSize: 10,
                                  color: AppColor.gray84,
                                ),
                              ),
                              Text(
                                // 'Rs.${data.todayAmount}',
                                'Rs. 49,098',
                                style: AppTextStyles.mulish(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 18,
                                  color: AppColor.mildBlack,
                                ),
                              ),
                            ],
                          ),
                          Spacer(),
                          Column(
                            children: [
                              InkWell(
                                onTap: () {
                                  // if (data.phoneNumber.isNotEmpty) {
                                  //   _launchDialer(data.phoneNumber);
                                  // }
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppColor.black,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14.5,
                                      vertical: 15,
                                    ),
                                    child: Image.asset(
                                      AppImages.callImage1,
                                      height: 12,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 15),
                              InkWell(
                                onTap: () {
                                  // context.push(
                                  //   AppRoutes.heaterEmployeeDetailsPath,
                                  // );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: AppColor.black.withOpacity(0.1),
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14.5,
                                      vertical: 17.5,
                                    ),
                                    child: Image.asset(
                                      AppImages.personOff,
                                      color: AppColor.darkBlue,
                                      height: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 25),
                  Center(
                    child: Text(
                      'Edit Employee Details',
                      style: AppTextStyles.mulish(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColor.darkBlue,
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 21,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Name',
                              style: AppTextStyles.mulish(
                                color: AppColor.mildBlack,
                              ),
                            ),
                            SizedBox(height: 10),
                            CommonContainer.fillingContainer(
                              controller: englishNameController,
                              context: context,
                              validator:
                                  (v) =>
                                      v == null || v.trim().isEmpty
                                          ? 'Name required'
                                          : null,
                            ),
                            SizedBox(height: 30),

                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: CommonContainer.mobileNumberField(
                                controller: mobileController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Mobile number required';
                                  }
                                  if (value.length != 10) {
                                    return 'Enter valid 10-digit number';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            SizedBox(height: 30),

                            Text(
                              'Email Id',
                              style: AppTextStyles.mulish(
                                color: AppColor.mildBlack,
                              ),
                            ),
                            SizedBox(height: 10),
                            CommonContainer.fillingContainer(
                              controller: emailIdController,
                              keyboardType: TextInputType.emailAddress,
                              context: context,
                              validator: (v) {
                                if (v == null || v.isEmpty)
                                  return 'Email required';
                                if (!RegExp(
                                  r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                                ).hasMatch(v)) {
                                  return 'Enter valid email';
                                }
                                return null;
                              },
                            ),

                            SizedBox(height: 30),

                            Text(
                              'Emergency Contact Details',
                              style: AppTextStyles.mulish(
                                color: AppColor.mildBlack,
                              ),
                            ),
                            SizedBox(height: 10),

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
                            SizedBox(height: 10),

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
                            SizedBox(height: 10),

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

                            SizedBox(height: 30),

                            Text(
                              'Aadhar No',
                              style: AppTextStyles.mulish(
                                color: AppColor.mildBlack,
                              ),
                            ),
                            SizedBox(height: 10),

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

                            SizedBox(height: 30),
                            CommonContainer.containerTitle(
                              context: context,
                              title: 'Aadhar Photo',
                              image: AppImages.iImage,
                              infoMessage:
                                  'Please upload a clear photo of your Aadhar.',
                            ),
                            SizedBox(height: 10),
                            _imageBox(index: 0),

                            SizedBox(height: 30),

                            CommonContainer.containerTitle(
                              context: context,
                              title: 'Profile Picture',
                              image: AppImages.iImage,
                              infoMessage:
                                  'Please upload a clear profile picture.',
                            ),
                            SizedBox(height: 10),
                            _imageBox(index: 1),

                            SizedBox(height: 30),

                            CommonContainer.button(
                              buttonColor: AppColor.darkBlue,
                              imagePath:
                                  state.isLoading
                                      ? null
                                      : AppImages.rightStickArrow,
                              text:
                                  state.isLoading
                                      ? ThreeDotsLoader()
                                      : Text('Save'),
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

                                await ref
                                    .read(addEmployeeNotifier.notifier)
                                    .addEmployeeVendor(
                                      phoneNumber: mobileController.text,
                                      fullName:
                                          englishNameController.text.trim(),
                                      email: emailIdController.text.trim(),
                                      emergencyContactName:
                                          emergencyNameController.text.trim(),
                                      emergencyContactRelationship:
                                          emergencyRelationShipController.text
                                              .trim(),
                                      emergencyContactPhone:
                                          emergencyMobileController.text.trim(),
                                      aadhaarNumber:
                                          aadharController.text.trim(),
                                      aadhaarFile: _pickedImages[0]!,
                                      ownerImageFile: _pickedImages[1]!,
                                    );

                                final newState = ref.read(addEmployeeNotifier);

                                if (newState.error != null) {
                                  AppSnackBar.error(context, newState.error!);
                                  return;
                                }

                                AppSnackBar.success(
                                  context,
                                  "Employee updated successfully",
                                );
                                if (!mounted) return;

                                // context.pop(true);
                                context.pushReplacement(
                                  AppRoutes.heaterEmployeeDetailsEditPath,
                                );
                              },
                            ),

                            SizedBox(height: 30),
                          ],
                        ),
                      ),
                    ],
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
