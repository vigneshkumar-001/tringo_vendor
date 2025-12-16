import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../Core/Const/app_color.dart';
import '../../../Core/Const/app_images.dart';
import '../../../Core/Session/registration_product_seivice.dart';
import '../../../Core/Session/registration_session.dart';
import '../../../Core/Utility/app_snackbar.dart';
import '../../../Core/Utility/app_textstyles.dart';
import '../../../Core/Widgets/app_go_routes.dart';
import '../../../Core/Widgets/common_container.dart';

class ShopPhotoInfo extends ConsumerStatefulWidget {
  final String? pages;
  final String? shopId;

  /// existing images
  final List<String?>? initialImageUrls;

  const ShopPhotoInfo({
    super.key,
    this.pages = '',
    this.shopId,
    this.initialImageUrls,
  });

  @override
  ConsumerState<ShopPhotoInfo> createState() => _ShopPhotoInfoState();
}

class _ShopPhotoInfoState extends ConsumerState<ShopPhotoInfo> {
  final ImagePicker _picker = ImagePicker();

  // Newly picked images
  List<File?> _pickedImages = List<File?>.filled(4, null);

  // Existing URLs loaded from server / AboutMeScreens
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

  Future<void> _showImageSourcePicker(int index) async {
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

    if (pickedFile != null) {
      setState(() {
        _pickedImages[index] = File(pickedFile.path);

        // Clear existing server image
        _existingUrls[index] = null;

        // Clear errors
        if (index == 0 || index == 1) {
          _hasError[index] = false;
        }

        final hasInside =
            _pickedImages[2] != null ||
                _pickedImages[3] != null ||
                (_existingUrls[2] != null && _existingUrls[2]!.isNotEmpty) ||
                (_existingUrls[3] != null && _existingUrls[3]!.isNotEmpty);

        if (hasInside) {
          _insidePhotoError = false;
        }
      });
    }
  }

  Future<void> _pickImage(int index) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _pickedImages[index] = File(pickedFile.path);

        // If user picks new image, clear old server image URL
        _existingUrls[index] = null;

        // Individual field errors for image 0 & 1
        if (index == 0 || index == 1) {
          _hasError[index] = false;
        }

        // For inside photos (2 & 3)
        final hasInside =
            _pickedImages[2] != null ||
            _pickedImages[3] != null ||
            (_existingUrls[2] != null && _existingUrls[2]!.isNotEmpty) ||
            (_existingUrls[3] != null && _existingUrls[3]!.isNotEmpty);

        if (hasInside) {
          _insidePhotoError = false;
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
              // onTap: () => _pickImage(index),
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
                                'Add Image',
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
    // final state = ref.watch(shopCategoryNotifierProvider);
    // final notifier = ref.read(shopCategoryNotifierProvider.notifier);

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
                    const SizedBox(width: 50),
                    Text(
                      'Register Shop',
                      style: AppTextStyles.mulish(
                        fontSize: 16,
                        color: AppColor.mildBlack,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '-',
                      style: AppTextStyles.mulish(
                        fontSize: 16,
                        color: AppColor.mildBlack,
                      ),
                    ),
                    const SizedBox(width: 5),
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

              const SizedBox(height: 35),

              CommonContainer.registerTopContainer(
                image: AppImages.shopInfoImage,
                text: 'Shop Info',
                imageHeight: 85,
                gradientColor: AppColor.lightSkyBlue,
                value: 0.6,
              ),

              const SizedBox(height: 30),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  children: [
                    CommonContainer.containerTitle(
                      context: context,
                      title: 'Sign Board Photo',
                      image: AppImages.iImage,
                      infoMessage:
                          'Please upload a clear photo of your shop signboard.',
                    ),
                    const SizedBox(height: 10),
                    _addImageContainer(index: 0, checkIndividualError: true),

                    const SizedBox(height: 25),

                    CommonContainer.containerTitle(
                      context: context,
                      title: 'Shop Outside Photo',
                      image: AppImages.iImage,
                      infoMessage:
                          'Please upload a clear photo of the shop exterior.',
                    ),
                    const SizedBox(height: 10),
                    _addImageContainer(index: 1, checkIndividualError: true),

                    const SizedBox(height: 25),

                    CommonContainer.containerTitle(
                      context: context,
                      title: 'Shop Inside Photo',
                      image: AppImages.iImage,
                      infoMessage:
                          'Please upload at least one inside shop image.',
                    ),
                    const SizedBox(height: 10),
                    _addImageContainer(index: 2),
                    const SizedBox(height: 10),
                    _addImageContainer(index: 3),

                    if (_insidePhotoError)
                      Padding(
                        padding: const EdgeInsets.only(top: 6, left: 5),
                        child: Text(
                          'Please upload at least one inside photo',
                          style: AppTextStyles.mulish(
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),

                    const SizedBox(height: 30),

                    CommonContainer.button(
                      buttonColor: AppColor.black,
                      onTap: () async {
                        // 🔹 Validation ONLY for registration flow
                        if (widget.pages != "AboutMeScreens") {
                          // await _validateImages();

                          if (_hasError.contains(true) || _insidePhotoError) {
                            AppSnackBar.error(
                              context,
                              'Please fix the highlighted errors before continuing',
                            );
                            return;
                          }
                        }

                        // 🔹 In AboutMeScreens flow → NO validation, direct upload
                        // final success = await notifier.uploadShopImages(
                        //   images: _pickedImages,
                        //   shopId: widget.shopId,
                        //   context: context,
                        // );
                        context.pushNamed(AppRoutes.searchKeyword);
                        // if (success) {
                        //   if (widget.pages == "AboutMeScreens") {
                        //     context.pushNamed(AppRoutes.home, extra: 3);
                        //   } else {
                        //     context.pushNamed(AppRoutes.searchKeyword);
                        //   }
                        // } else {
                        //   final err = ref
                        //       .read(shopCategoryNotifierProvider)
                        //       .error;
                        //   AppSnackBar.error(
                        //     context,
                        //     err ?? 'Image upload failed. Try again.',
                        //   );
                        // }
                      },
                      text:
                      // state.isLoading
                      //     ? const ThreeDotsLoader()
                      //     :
                      Text(
                        widget.pages == "AboutMeScreens"
                            ? 'Update'
                            : 'Save & Continue',
                        style: AppTextStyles.mulish(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      imagePath:
                          // state.isLoading
                          //     ? null
                          //     :
                          AppImages.rightStickArrow,
                      imgHeight: 20,
                    ),

                    const SizedBox(height: 36),
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
