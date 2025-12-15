import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
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

class VendorCompanyInfo extends ConsumerStatefulWidget {
  const VendorCompanyInfo({super.key});

  @override
  ConsumerState<VendorCompanyInfo> createState() => _VendorCompanyInfoState();
}

class _VendorCompanyInfoState extends ConsumerState<VendorCompanyInfo> {
  final _formKey = GlobalKey<FormState>();

  // List<ShopCategoryListData>? _selectedCategoryChildren;

  final TextEditingController _gSTNumberController = TextEditingController();
  final TextEditingController _gpsController = TextEditingController();
  final TextEditingController _alternateMobileNumberController =
      TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _shopNameEnglishController =
      TextEditingController();
  final TextEditingController _addressEnglishController =
      TextEditingController();
  final TextEditingController _primaryMobileController =
      TextEditingController();

  List<String> tamilNameSuggestion = [];
  List<String> descriptionTamilSuggestion = [];
  List<String> addressTamilSuggestion = [];
  bool _tamilPrefilled = false;
  String categorySlug = '';
  String subCategorySlug = '';
  bool isTamilNameLoading = false;
  bool isDescriptionTamilLoading = false;
  bool isAddressLoading = false;
  bool _isSubmitted = false;
  bool _gpsFetched = false;
  bool _timetableInvalid = false;
  bool _isFetchingGps = false;

  String _withCountryCode(String number) {
    final n = number.trim();
    if (n.isEmpty) return n;
    if (n.startsWith('+91')) return n;
    return '+91$n';
  }

  String _stripIndianCode(String number) {
    var n = number.trim();
    if (n.isEmpty) return n;

    if (n.startsWith('+91')) {
      return n.substring(3).trim();
    }

    // e.g. "91XXXXXXXXXX"
    if (n.startsWith('91') && n.length > 10) {
      return n.substring(n.length - 10).trim();
    }

    return n;
  }

  TimeOfDay? _parseTimeOfDay(String input) {
    try {
      final parts = input.trim().split(' ');
      final hm = parts[0].split(':');
      int hour = int.parse(hm[0]);
      int minute = int.parse(hm[1]);

      if (parts.length > 1) {
        final period = parts[1].toUpperCase();
        if (period == 'PM' && hour != 12) hour += 12;
        if (period == 'AM' && hour == 12) hour = 0;
      }

      return TimeOfDay(hour: hour, minute: minute);
    } catch (_) {
      return null;
    }
  }

  TimeOfDay? _openTod;
  TimeOfDay? _closeTod;
  int _toMinutes(TimeOfDay t) => t.hour * 60 + t.minute;
  bool validateTimes() {
    if (_openTod == null || _closeTod == null) return false;
    return _toMinutes(_closeTod!) > _toMinutes(_openTod!);
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location services are disabled.')),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission denied.')),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location permissions are permanently denied.'),
          ),
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _gpsController.text =
            '${position.latitude.toStringAsFixed(6)}, '
            '${position.longitude.toStringAsFixed(6)}';
        _gpsFetched = true; // Mark GPS as fetched
      });

      if (_isSubmitted) {
        _formKey.currentState?.validate();
      }

      debugPrint('📍 Current Location → ${_gpsController.text}');
    } catch (e) {
      debugPrint('❌ Error getting location: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to get current location.')),
      );
    }
  }

  ///new////
  // @override
  // void initState() {
  //   super.initState();
  //   AppLogger.log.i(widget.shopId);
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     ref.read(shopCategoryNotifierProvider.notifier).fetchCategories();
  //   });
  //
  //   if (widget.pages == "AboutMeScreens") {
  //     // 👉 shop name
  //     if (widget.initialShopNameEnglish?.isNotEmpty ?? false) {
  //       _shopNameEnglishController.text = widget.initialShopNameEnglish!;
  //     }
  //
  //     if (widget.initialShopNameTamil?.isNotEmpty ?? false) {
  //       tamilNameController.text = widget.initialShopNameTamil!;
  //       _tamilPrefilled = true;
  //     } else {
  //       _prefillTamilFromEnglishOnce();
  //     }
  //
  //     // 👉 description
  //     if (widget.initialDescriptionEnglish?.isNotEmpty ?? false) {
  //       _descriptionEnglishController.text = widget.initialDescriptionEnglish!;
  //     }
  //     if (widget.initialDescriptionTamil?.isNotEmpty ?? false) {
  //       descriptionTamilController.text = widget.initialDescriptionTamil!;
  //     }
  //
  //     // 👉 address
  //     if (widget.initialAddressEnglish?.isNotEmpty ?? false) {
  //       _addressEnglishController.text = widget.initialAddressEnglish!;
  //     }
  //     if (widget.initialAddressTamil?.isNotEmpty ?? false) {
  //       addressTamilNameController.text = widget.initialAddressTamil!;
  //     }
  //
  //     // 👉 GPS
  //     if (widget.initialGps?.isNotEmpty ?? false) {
  //       _gpsController.text = widget.initialGps!;
  //       _gpsFetched = true;
  //     }
  //
  //     // 👉 phones (strip +91 / 91 for edit mode)
  //     if (widget.initialPrimaryMobile?.isNotEmpty ?? false) {
  //       var phone = widget.initialPrimaryMobile!.trim();
  //       if (widget.pages == "AboutMeScreens") {
  //         phone = _stripIndianCode(phone);
  //       }
  //       _primaryMobileController.text = phone;
  //     }
  //
  //     if (widget.initialWhatsapp?.isNotEmpty ?? false) {
  //       var wa = widget.initialWhatsapp!.trim();
  //       if (widget.pages == "AboutMeScreens") {
  //         wa = _stripIndianCode(wa); // 👈 REMOVE +91 / 91 HERE ALSO
  //       }
  //       _whatsappController.text = wa;
  //     }
  //
  //     // 👉 email
  //     if (widget.initialEmail?.isNotEmpty ?? false) {
  //       _emailController.text = widget.initialEmail!;
  //     }
  //
  //     // 👉 category / subcategory
  //     if (widget.initialCategoryName?.isNotEmpty ?? false) {
  //       _categoryController.text = widget.initialCategoryName!;
  //       categorySlug = widget.initialCategorySlug ?? '';
  //     }
  //     if (widget.initialSubCategoryName?.isNotEmpty ?? false) {
  //       _subCategoryController.text = widget.initialSubCategoryName!;
  //       subCategorySlug = widget.initialSubCategorySlug ?? '';
  //     }
  //
  //     // 👉 door delivery (for product flow)
  //     if (widget.initialDoorDeliveryText?.isNotEmpty ?? false) {
  //       _doorDeliveryController.text = widget.initialDoorDeliveryText!;
  //     }
  //
  //     // 👉 open / close time – text + parse to TimeOfDay
  //     if (widget.initialOpenTimeText?.isNotEmpty ?? false) {
  //       final parsedOpen = _parseTimeOfDay(widget.initialOpenTimeText!);
  //
  //       if (parsedOpen != null) {
  //         _openTod = parsedOpen;
  //         WidgetsBinding.instance.addPostFrameCallback((_) {
  //           if (mounted) {
  //             _openTimeController.text = parsedOpen.format(context);
  //           }
  //         });
  //       } else {
  //         _openTimeController.text = widget.initialOpenTimeText!;
  //       }
  //     }
  //
  //     if (widget.initialCloseTimeText?.isNotEmpty ?? false) {
  //       final parsedClose = _parseTimeOfDay(widget.initialCloseTimeText!);
  //
  //       if (parsedClose != null) {
  //         _closeTod = parsedClose;
  //         WidgetsBinding.instance.addPostFrameCallback((_) {
  //           if (mounted) {
  //             _closeTimeController.text = parsedClose.format(context);
  //           }
  //         });
  //       } else {
  //         _closeTimeController.text = widget.initialCloseTimeText!;
  //       }
  //     }
  //
  //     if ((widget.initialOwnerImageUrl?.isNotEmpty ?? false) &&
  //         (widget.isService == true)) {
  //       _hasExistingOwnerImage = true;
  //     }
  //   }
  // }

  @override
  void dispose() {
    _shopNameEnglishController.dispose();
    _gpsController.dispose();
    _addressEnglishController.dispose();
    _primaryMobileController.dispose();
    _emailController.dispose();
    _gSTNumberController.dispose();
    _alternateMobileNumberController.dispose();

    super.dispose();
  }

  // // 🔹 Central validation function
  // bool _validateAll() {
  //   setState(() {
  //     _isSubmitted = true;
  //     _categoryErrorText = null;
  //     _subCategoryErrorText = null;
  //     _timeErrorText = null;
  //     _imageErrorText = null;
  //     _timetableInvalid = false;
  //     _gpsErrorText = null;
  //   });
  //
  //   final baseValid = _formKey.currentState?.validate() ?? false;
  //   bool extraValid = true;
  //
  //   // Category
  //   if (_categoryController.text.trim().isEmpty) {
  //     _categoryErrorText = 'Please select a category';
  //     extraValid = false;
  //   }
  //
  //   // Subcategory
  //   if (_subCategoryController.text.trim().isEmpty) {
  //     _subCategoryErrorText = 'Please select a subcategory';
  //     extraValid = false;
  //   }
  //
  //   // Time order
  //   if (_openTod != null && _closeTod != null && !validateTimes()) {
  //     _timeErrorText = 'Close Time must be after Open Time';
  //     extraValid = false;
  //   }
  //
  //   // Image validation for service
  //   if (widget.isService == true && _permanentImage == null) {
  //     _imageErrorText = 'Please add your Photo';
  //     _timetableInvalid = true;
  //     extraValid = false;
  //   }
  //
  //   if (widget.isService != true) {
  //     if (_gpsController.text.trim().isEmpty) {
  //       _gpsErrorText = 'Please get GPS location';
  //       extraValid = false;
  //     }
  //   }
  //
  //   final allGood = baseValid && extraValid;
  //
  //   if (!allGood) {
  //     AppSnackBar.error(context, 'Please fill all required fields correctly');
  //   }
  //
  //   setState(() {});
  //   return allGood;
  // }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(heaterRegisterNotifier);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
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
                      SizedBox(width: 50),
                      Text(
                        'Register Vendor',
                        style: AppTextStyles.mulish(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: AppColor.mildBlack,
                        ),
                      ),
                      // SizedBox(width: 5),
                      // Text(
                      //   '-',
                      //   style: AppTextStyles.mulish(
                      //     fontSize: 16,
                      //     fontWeight: FontWeight.w400,
                      //     color: AppColor.mildBlack,
                      //   ),
                      // ),
                      SizedBox(width: 5),
                      Text(
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
                const SizedBox(height: 35),
                CommonContainer.registerTopContainer(
                  image: AppImages.shopInfoImage,
                  text: 'Vendor Company Info',
                  imageHeight: 85,
                  gradientColor: AppColor.lightSkyBlue,
                  value: 0.3,
                ),

                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Vendor Company Name',
                            style: AppTextStyles.mulish(
                              color: AppColor.mildBlack,
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(
                            '( As per Govt Certificate )',
                            style: AppTextStyles.mulish(
                              color: AppColor.mediumLightGray,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      CommonContainer.fillingContainer(
                        controller: _shopNameEnglishController,
                        text: 'English',
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? 'Please Enter Shop Name in English'
                                    : null,
                      ),
                      SizedBox(height: 15),

                      Text(
                        'Address',
                        style: AppTextStyles.mulish(color: AppColor.mildBlack),
                      ),
                      SizedBox(height: 10),
                      CommonContainer.fillingContainer(
                        controller: _addressEnglishController,
                        maxLine: 4,
                        text: 'English',
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? 'Please Enter Address in English'
                                    : null,
                      ),

                      SizedBox(height: 25),
                      Text(
                        'GPS Location',
                        style: AppTextStyles.mulish(color: AppColor.mildBlack),
                      ),
                      SizedBox(height: 10),

                      GestureDetector(
                        onTap: () async {
                          setState(() => _isFetchingGps = true);
                          await _getCurrentLocation();
                          setState(() => _isFetchingGps = false);
                        },
                        child: AbsorbPointer(
                          child: CommonContainer.fillingContainer(
                            controller: _gpsController,
                            text:
                                _gpsController.text.isEmpty
                                    ? (_isFetchingGps
                                        ? ''
                                        : 'Get by GPS') // 👈 important
                                    : '', // after GPS, no label
                            textColor:
                                _gpsController.text.isEmpty
                                    ? AppColor
                                        .skyBlue // blue while empty
                                    : AppColor.mildBlack, // dark after fill
                            textFontWeight: FontWeight.w700,
                            suffixWidget:
                                _isFetchingGps
                                    ? SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColor.skyBlue,
                                      ),
                                    )
                                    : null,
                            validator: (_) => null,
                          ),
                        ),
                      ),

                      // if (_gpsErrorText != null)
                      //   Padding(
                      //     padding: const EdgeInsets.only(top: 6.0, left: 4),
                      //     child: Text(
                      //       _gpsErrorText!,
                      //       style: TextStyle(color: Colors.red, fontSize: 12),
                      //     ),
                      //   ),
                      SizedBox(height: 25),
                      Text(
                        'Primary Mobile Number',
                        style: AppTextStyles.mulish(color: AppColor.mildBlack),
                      ),
                      SizedBox(height: 10),

                      CommonContainer.fillingContainer(
                        controller: _primaryMobileController,
                        verticalDivider: true,
                        isMobile: true, // mobile behavior +91 etc
                        text: 'Verify by OTP',
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please Enter Primary Mobile Number';
                          }
                          return null;
                        },
                      ),
                      // CommonContainer.fillingContainer(
                      //   controller: _primaryMobileController,
                      //   verticalDivider: true,
                      //   isMobile: true,
                      //   text: 'Mobile No',
                      //   // validator: (value) => value == null || value.isEmpty
                      //   //     ? 'Please Enter Primary Mobile Number'
                      //   //     : null,
                      // ),
                      const SizedBox(height: 25),
                      Text(
                        'Alternate Mobile Number',
                        style: AppTextStyles.mulish(color: AppColor.mildBlack),
                      ),
                      SizedBox(height: 10),
                      CommonContainer.fillingContainer(
                        controller: _alternateMobileNumberController,
                        verticalDivider: false,
                        isMobile: true,
                        text: '',
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please Enter Alternate Mobile Number';
                          }
                          return null;
                        },
                      ),
                      // CommonContainer.fillingContainer(
                      //   controller: _whatsappController,
                      //   verticalDivider: true,
                      //   isMobile: true,
                      //   text: 'Mobile No',
                      //   // validator: (value) => value == null || value.isEmpty
                      //   //     ? 'Please Enter Whatsapp Number'
                      //   //     : null,
                      // ),
                      SizedBox(height: 25),

                      Text(
                        'Email Id',
                        style: AppTextStyles.mulish(color: AppColor.mildBlack),
                      ),
                      SizedBox(height: 10),
                      CommonContainer.fillingContainer(
                        keyboardType: TextInputType.emailAddress,
                        controller: _emailController,
                        verticalDivider: false,
                        text: '',
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
                      SizedBox(height: 25),
                      Row(
                        children: [
                          Text(
                            'GST Number',
                            style: AppTextStyles.mulish(
                              color: AppColor.mildBlack,
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(
                            '( Optional )',
                            style: AppTextStyles.mulish(
                              color: AppColor.mediumLightGray,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      CommonContainer.fillingContainer(
                        controller: _gSTNumberController,
                        verticalDivider: false,
                        isMobile: true,
                        text: '',
                        keyboardType: TextInputType.phone,
                        // validator: (value) {
                        //   if (value == null || value.isEmpty) {
                        //     return 'Please Enter GST Number';
                        //   }
                        //   return null;
                        // },
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

                          final englishName =
                              _shopNameEnglishController.text.trim();
                          final address = _addressEnglishController.text.trim();
                          final primaryMobile =
                              _primaryMobileController.text.trim();
                          final alternateMobileNumber =
                              _alternateMobileNumberController.text.trim();
                          final email = _emailController.text.trim();
                          // final gps = _gpsController.text.trim();
                          final gSTNumber = _gSTNumberController.text.trim();

                          if (!mounted) return;
                          final gpsText = _gpsController.text.trim();
                          String latitude = '';
                          String longitude = '';

                          if (gpsText.isNotEmpty && gpsText.contains(',')) {
                            final parts = gpsText.split(',');
                            latitude = parts[0].trim();
                            longitude = parts[1].trim();
                          }

                          await ref
                              .read(heaterRegisterNotifier.notifier)
                              .registerVendor(

                                screen: VendorRegisterScreen.screen3,
                                vendorName: '',
                                vendorNameTamil: '',
                                phoneNumber: '',
                                aadharNumber: '',
                                aadharDocumentUrl: '',
                                bankAccountNumber: '',
                                bankAccountName: '',
                                bankBranch: '',
                                bankIfsc: '',
                                companyName: englishName,
                                companyAddress: address,
                                gpsLatitude: latitude,
                                gpsLongitude: longitude,
                                primaryCity: '',
                                primaryState: '',
                                companyContactNumber: primaryMobile,
                                alternatePhone: alternateMobileNumber,
                                companyEmail: email,
                                gstNumber: gSTNumber,
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
                            context.push(AppRoutes.vendorCompanyPhotoPath); // ✅ correct next screen


                            AppLogger.log.i(
                              "Owner Info Saved  ${newState.vendorResponse?.toJson()}",
                            );
                          }
                        },
                      ),

                      // CommonContainer.button(
                      //   onTap: () {
                      //     context.push(AppRoutes.vendorCompanyPhotoPath);
                      //   },
                      //   text: Text(
                      //     'Save & Continue',
                      //     style: AppTextStyles.mulish(
                      //       fontSize: 18,
                      //       fontWeight: FontWeight.w700,
                      //     ),
                      //   ),
                      //   imagePath: AppImages.rightStickArrow,
                      //   buttonColor: AppColor.black,
                      // ),
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
