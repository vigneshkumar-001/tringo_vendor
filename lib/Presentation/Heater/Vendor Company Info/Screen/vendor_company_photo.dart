import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../Api/DataSource/api_data_source.dart';
import '../../../../Core/Const/app_color.dart';
import '../../../../Core/Const/app_images.dart';
import '../../../../Core/Session/registration_product_seivice.dart';
import '../../../../Core/Session/registration_session.dart';
import '../../../../Core/Utility/app_loader.dart';
import '../../../../Core/Utility/app_snackbar.dart';
import '../../../../Core/Utility/app_textstyles.dart';
import '../../../../Core/Widgets/app_go_routes.dart';
import '../../../../Core/Widgets/common_container.dart';
import '../../Heater Register/Controller/heater_register_notifier.dart';

class VendorCompanyPhoto extends ConsumerStatefulWidget {
  final String? pages;
  final List<String?>? initialImageUrls;

  const VendorCompanyPhoto({super.key, this.initialImageUrls, this.pages = ''});

  @override
  ConsumerState<VendorCompanyPhoto> createState() => _VendorCompanyPhotoState();
}

class _VendorCompanyPhotoState extends ConsumerState<VendorCompanyPhoto> {
  final ImagePicker _picker = ImagePicker();

  List<File?> _pickedImages = List<File?>.filled(4, null);

  late List<String?> _existingUrls;

  // Errors
  List<bool> _hasError = List<bool>.filled(4, false);
  bool _insidePhotoError = false;

  bool get isIndividualFlow {
    final session = RegistrationProductSeivice.instance;
    return session.businessType == BusinessType.individual;
  }

  @override
  void initState() {
    super.initState();

    /// Initialize existing URLs
    _existingUrls = List<String?>.filled(4, null);
    final input = widget.initialImageUrls ?? [];

    for (int i = 0; i < 4; i++) {
      if (i < input.length) {
        if (input[i] != null && input[i]!.isNotEmpty) {
          _existingUrls[i] = input[i];
        }
      }
    }
  }

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

  // Future<void> _validateImages() async {
  //   bool valid = true;
  //
  //   setState(() {
  //     // Slot 0 & 1: must have File OR URL
  //     for (int i = 0; i <= 1; i++) {
  //       final has =
  //           _pickedImages[i] != null ||
  //           (_existingUrls[i] != null && _existingUrls[i]!.isNotEmpty);
  //
  //       if (!has) {
  //         _hasError[i] = true;
  //         valid = false;
  //       } else {
  //         _hasError[i] = false;
  //       }
  //     }
  //
  //     // Inside photos validation (2 OR 3)
  //     final hasInside =
  //         _pickedImages[2] != null ||
  //         _pickedImages[3] != null ||
  //         (_existingUrls[2] != null && _existingUrls[2]!.isNotEmpty) ||
  //         (_existingUrls[3] != null && _existingUrls[3]!.isNotEmpty);
  //
  //     if (!hasInside) {
  //       _insidePhotoError = true;
  //       valid = false;
  //     } else {
  //       _insidePhotoError = false;
  //     }
  //   });
  //
  //   if (!valid) return;
  //
  //   debugPrint("✔ All images valid (File or Existing URL)");
  // }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(heaterRegisterNotifier);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
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
                    SizedBox(width: 50),
                    Text(
                      'Register Vendor',
                      style: AppTextStyles.mulish(
                        fontSize: 16,
                        color: AppColor.mildBlack,
                      ),
                    ),
                    //   SizedBox(width: 5),
                    // Text(
                    //   '-',
                    //   style: AppTextStyles.mulish(
                    //     fontSize: 16,
                    //     color: AppColor.mildBlack,
                    //   ),
                    // ),
                    SizedBox(width: 5),
                    Text(
                      // isIndividualFlow ? 'Individual' :
                      'Company',
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

              CommonContainer.registerTopContainer(
                image: AppImages.shopInfoImage,
                text: 'Vendor Company Info',
                imageHeight: 85,
                gradientColor: AppColor.lightSkyBlue,
                value: 0.6,
              ),

              SizedBox(height: 30),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  children: [
                    CommonContainer.containerTitle(
                      context: context,
                      title: 'Company Logo',
                      image: AppImages.iImage,
                      infoMessage:
                          'Please upload a clear photo of your Company Logo.',
                    ),
                    SizedBox(height: 10),
                    _addImageContainer(index: 0, checkIndividualError: true),
                    SizedBox(height: 30),
                    CommonContainer.button(
                      buttonColor: AppColor.black,
                      onTap: () async {
                        final file = _pickedImages[0];
                        final url = _existingUrls[0];

                        final hasLogo =
                            file != null || (url != null && url.isNotEmpty);

                        if (!hasLogo) {
                          setState(() => _hasError[0] = true);
                          AppSnackBar.error(
                            context,
                            'Please upload your company logo',
                          );
                          return;
                        }

                        await ref
                            .read(heaterRegisterNotifier.notifier)
                            .registerVendor(
                              screen: VendorRegisterScreen.screen4,

                              vendorName: '',
                              vendorNameTamil: '',
                              phoneNumber: '',
                              email: '',
                              dateOfBirth: '',
                              gender: '',
                              aadharNumber: '',
                              aadharDocumentUrl: '',
                              bankAccountNumber: '',
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

                              // 🔥 HERE IS THE REAL FIX
                              avatarFile: file, // File from picker
                              avatarUrl:
                                  url, // existing URL from server (if any)
                            );

                        if (!mounted) return;

                        final newState = ref.read(heaterRegisterNotifier);

                        if (newState.error != null) {
                          AppSnackBar.error(context, newState.error!);
                        } else if (newState.vendorResponse != null) {
                          AppSnackBar.success(
                            context,
                            "Company logo saved successfully",
                          );
                          context.push(AppRoutes.heaterAddEmployeePath);
                        }
                      },
                      text:
                          state.isLoading
                              ? ThreeDotsLoader()
                              : Text(
                                'Save & Continue',
                                style: AppTextStyles.mulish(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      imagePath:
                          state.isLoading ? null : AppImages.rightStickArrow,
                      imgHeight: 20,
                    ),

                    // CommonContainer.button(
                    //   buttonColor: AppColor.black,
                    //   onTap: () async {
                    //     // 1) Validate logo image
                    //     final file = _pickedImages[0];
                    //     final url = _existingUrls[0];
                    //     final hasLogo =
                    //         file != null || (url != null && url.isNotEmpty);
                    //
                    //     if (!hasLogo) {
                    //       setState(() {
                    //         _hasError[0] = true;
                    //       });
                    //       AppSnackBar.error(
                    //         context,
                    //         'Please upload your company logo',
                    //       );
                    //       return;
                    //     }
                    //
                    //     String avatarUrl;
                    //     if (file != null) {
                    //       // TODO: upload `file` to server and get real URL
                    //       // avatarUrl = await uploadLogoAndGetUrl(file);
                    //       avatarUrl = file.path;
                    //     } else {
                    //       avatarUrl = url!; // existing URL
                    //     }
                    //
                    //     await ref
                    //         .read(heaterRegisterNotifier.notifier)
                    //         .registerVendor(
                    //           screen: VendorRegisterScreen.screen4,
                    //           vendorName: '',
                    //           vendorNameTamil: '',
                    //           phoneNumber: '',
                    //           email: '',
                    //           dateOfBirth: '',
                    //           gender: '',
                    //           aadharNumber: '',
                    //           aadharDocumentUrl: '',
                    //           bankAccountNumber: '',
                    //           bankAccountName: '',
                    //           bankBranch: '',
                    //           bankIfsc: '',
                    //           companyName: '',
                    //           companyAddress: '',
                    //           gpsLatitude: '',
                    //           gpsLongitude: '',
                    //           primaryCity: '',
                    //           primaryState: '',
                    //           companyContactNumber: '',
                    //           alternatePhone: '',
                    //           companyEmail: '',
                    //           gstNumber: '',
                    //           avatarUrl: file,
                    //         );
                    //
                    //     if (!mounted) return;
                    //     final newState = ref.read(heaterRegisterNotifier);
                    //
                    //     if (newState.error != null) {
                    //       AppSnackBar.error(context, newState.error!);
                    //     } else if (newState.vendorResponse != null) {
                    //       AppSnackBar.success(
                    //         context,
                    //         "Company logo saved successfully",
                    //       );
                    //
                    //       // 👇 Now move to next screen
                    //       context.push(AppRoutes.heaterAddEmployeePath);
                    //     }
                    //   },
                    //   text:
                    //       state.isLoading
                    //           ? ThreeDotsLoader()
                    //           : Text(
                    //             'Save & Continue',
                    //             style: AppTextStyles.mulish(
                    //               fontSize: 18,
                    //               fontWeight: FontWeight.w700,
                    //             ),
                    //           ),
                    //   imagePath:
                    //       state.isLoading ? null : AppImages.rightStickArrow,
                    //   imgHeight: 20,
                    // ),
                    SizedBox(height: 36),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
