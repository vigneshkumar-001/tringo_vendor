import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tringo_vendor_new/Core/Const/app_logger.dart';
import 'package:tringo_vendor_new/Presentation/AddProduct/Controller/product_notifier.dart';
import 'package:tringo_vendor_new/Presentation/AddProduct/Controller/service_info_notifier.dart';
import 'package:tringo_vendor_new/Presentation/AddProduct/Screens/product_search_keyword.dart';
import '../../../Core/Const/app_color.dart';
import '../../../Core/Const/app_images.dart';
import '../../../Core/Session/registration_product_seivice.dart';
import '../../../Core/Session/registration_session.dart';
import '../../../Core/Utility/app_loader.dart';
import '../../../Core/Utility/app_snackbar.dart';
import '../../../Core/Utility/app_textstyles.dart';
import '../../../Core/Widgets/common_container.dart';

class AddProductList extends ConsumerStatefulWidget {
  final bool? isService;
  const AddProductList({super.key, this.isService});

  @override
  ConsumerState<AddProductList> createState() => _AddProductListState();
}

class _AddProductListState extends ConsumerState<AddProductList> {
  final ImagePicker _picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();

  List<File?> _pickedImages = List<File?>.filled(4, null);
  List<bool> _hasError = List<bool>.filled(4, false);

  List<Map<String, TextEditingController>> _featureControllers = [
    {'heading': TextEditingController(), 'answer': TextEditingController()},
  ];

  bool get isIndividualFlow {
    final session = RegistrationProductSeivice.instance;
    return session.businessType == BusinessType.individual;
  }

  Future<void> _pickImage(int index) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _pickedImages[index] = File(pickedFile.path);
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

  void _addFeatureList() {
    setState(() {
      _featureControllers.add({
        'heading': TextEditingController(),
        'answer': TextEditingController(),
      });
    });
  }

  void _removeFeature(int index) {
    setState(() {
      _featureControllers.removeAt(index);
    });
  }

  @override
  void dispose() {
    for (var map in _featureControllers) {
      map['heading']?.dispose();
      map['answer']?.dispose();
    }
    super.dispose();
  }

  Widget _addImageContainer({required int index}) {
    final file = _pickedImages[index];
    final hasError = _hasError[index];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
                        : (file != null
                            ? AppColor.lightSkyBlue
                            : Colors.transparent),
                width: 1.5,
              ),
            ),
            child:
                file == null
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
                      child: Image.file(
                        file,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 150,
                      ),
                    ),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 5),
            child: Text(
              'Please add this image',
              style: AppTextStyles.mulish(
                color: Colors.red,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFeatureItem(int index) {
    final headingController = _featureControllers[index]['heading']!;
    final answerController = _featureControllers[index]['answer']!;

    return Padding(
      padding: const EdgeInsets.only(bottom: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '${index + 1}. Feature',
                style: AppTextStyles.mulish(color: AppColor.mildBlack),
              ),
              const Spacer(),
              if (_featureControllers.length > 1)
                InkWell(
                  onTap: () => _removeFeature(index),
                  child: const Icon(Icons.close, size: 20, color: Colors.red),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: CommonContainer.fillingContainer(
                  verticalDivider: false,
                  controller: headingController,
                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? 'Please enter Feature Heading'
                              : null,
                ),
              ),
              SizedBox(width: 15),
              Text(
                'Heading',
                style: AppTextStyles.mulish(color: AppColor.mildBlack),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: CommonContainer.fillingContainer(
                  verticalDivider: false,
                  controller: answerController,
                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? 'Please enter Feature Answer'
                              : null,
                ),
              ),
              SizedBox(width: 15),
              Text(
                'Answer',
                style: AppTextStyles.mulish(color: AppColor.mildBlack),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final regService = RegistrationProductSeivice.instance.isServiceBusiness;
    AppLogger.log.i('regService - $regService');
    // Final values with priority
    final bool isService =
        widget.isService ??
        RegistrationProductSeivice.instance.isServiceBusiness;

    final isProduct = !isService;

    // final isService = regService
    //     ? true
    //     : (RegistrationProductSeivice.instance.isServiceBusiness == false
    //           ? (widget.isService ?? false)
    //           : false);
    AppLogger.log.i('isServicess - $isService');
    // final isProduct = RegistrationProductSeivice.instance.isProductBusiness;

    final isCompany =
        RegistrationProductSeivice.instance.businessType ==
        BusinessType.company;

    // // watch both states
    final productState = ref.watch(productNotifierProvider);
    final serviceState = ref.watch(serviceInfoNotifierProvider);

    // choose loader
    final isLoading =
        isService ? serviceState.isLoading : productState.isLoading;
    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formKey,
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
                          fontWeight: FontWeight.w400,
                          color: AppColor.mildBlack,
                        ),
                      ),
                      SizedBox(width: 5),
                      Text(
                        '-',
                        style: AppTextStyles.mulish(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: AppColor.mildBlack,
                        ),
                      ),
                      SizedBox(width: 5),
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
                CommonContainer.registerTopContainer(
                  image: AppImages.addProduct,
                  text: isProduct ? 'Add Product' : 'Add Service',
                  imageHeight: 85,
                  gradientColor: AppColor.lavenderMist,
                  value: 0.8,
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isProduct ? 'Add Product' : 'Add Service',
                        style: AppTextStyles.mulish(color: AppColor.mildBlack),
                      ),
                      SizedBox(height: 10),
                      _addImageContainer(index: 0),
                      const SizedBox(height: 25),
                      Text(
                        'Feature List',
                        style: AppTextStyles.mulish(color: AppColor.mildBlack),
                      ),
                      const SizedBox(height: 20),
                      Column(
                        children: List.generate(
                          _featureControllers.length,
                          (index) => _buildFeatureItem(index),
                        ),
                      ),
                      const SizedBox(height: 15),
                      GestureDetector(
                        onTap: _addFeatureList,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 22.5),
                          decoration: BoxDecoration(
                            color: AppColor.lowGery1,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(AppImages.addListImage, height: 20),
                              const SizedBox(width: 10),
                              Text(
                                'Add Feature List',
                                style: AppTextStyles.mulish(
                                  color: AppColor.darkGrey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 30),
                      CommonContainer.button2(
                        context: context,
                        text: 'Save & Continue',
                        width: double.infinity,
                        height: 60,

                        loader: isLoading ? ThreeDotsLoader() : null,
                        onTap: isLoading
                            ? null
                            : () async {
                          if (_pickedImages[0] == null) {
                            setState(() => _hasError[0] = true);
                            return;
                          }

                          final formValid =
                              _formKey.currentState?.validate() ?? false;
                          setState(() {});
                          if (!formValid) return;

                          final features = _featureControllers.map((
                              item,
                              ) {
                            return {
                              "label": item['heading']!.text.trim(),
                              "value": item['answer']!.text.trim(),
                            };
                          }).toList();

                          bool success;
                          String? apiError;

                          if (isService) {
                            final serviceNotifier = ref.read(
                              serviceInfoNotifierProvider.notifier,
                            );

                            success = await serviceNotifier
                                .uploadServiceImages(
                              images: _pickedImages,
                              features: features,
                              context: context,
                            );

                            // read correct error
                            apiError = ref
                                .read(serviceInfoNotifierProvider)
                                .error;
                          } else {
                            final productNotifier = ref.read(
                              productNotifierProvider.notifier,
                            );

                            success = await productNotifier
                                .uploadProductImages(
                              images: _pickedImages,
                              features: features,
                              context: context,
                            );

                            // read correct error
                            apiError = ref
                                .read(productNotifierProvider)
                                .error;
                          }

                          if (!success) {
                            AppSnackBar.error(
                              context,
                              apiError ?? "Failed. Try again.",
                            );
                            return;
                          }

                          final isCompany =
                              RegistrationProductSeivice
                                  .instance
                                  .businessType ==
                                  BusinessType.company;

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductSearchKeyword(
                                isService: isService,
                                isCompany: isCompany,
                              ),
                            ),
                          );
                        },
                      ),

                      SizedBox(height: 36),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
