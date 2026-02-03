import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:tringo_vendor_new/Core/Const/app_logger.dart';
import 'package:tringo_vendor_new/Presentation/ShopInfo/Controller/shop_notifier.dart';
import 'package:tringo_vendor_new/Presentation/ShopInfo/Model/category_list_response.dart';
import 'package:tringo_vendor_new/Presentation/ShopInfo/Screens/shop_photo_info.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../Core/Const/app_color.dart';
import '../../../Core/Const/app_images.dart';
import '../../../Core/Offline_Data/offline_sync_models.dart';
import '../../../Core/Offline_Data/provider/offline_providers.dart';
import '../../../Core/Utility/app_loader.dart';
import '../../../Core/Utility/app_prefs.dart';
import '../../../Core/Utility/app_snackbar.dart';
import '../../../Core/Utility/app_textstyles.dart';
import '../../../Core/Utility/map_picker.dart';
import '../../../Core/Utility/thanglish_to_tamil.dart';
import '../../../Core/Widgets/app_go_routes.dart';
import '../../../Core/Widgets/common_container.dart';
import '../../../Core/Widgets/owner_verify_feild.dart';

class ShopCategoryInfo extends ConsumerStatefulWidget {
  final String? pages;
  final bool isEditMode;
  final String? initialShopNameEnglish;
  final String? initialShopNameTamil;
  final String? businessProfileId;
  final String? shopId;
  final bool? isService;
  final bool? isIndividual;

  // Prefill fields (edit)
  final String? initialDescriptionEnglish;
  final String? initialDescriptionTamil;
  final String? initialAddressEnglish;
  final String? initialAddressTamil;
  final String? initialGps;
  final String? initialPrimaryMobile;
  final String? initialWhatsapp;
  final String? initialEmail;
  final String? initialCategoryName;
  final String? initialCategorySlug;
  final String? initialSubCategoryName;
  final String? initialSubCategorySlug;
  final String? initialDoorDeliveryText;
  final String? initialOpenTimeText;
  final String? initialCloseTimeText;
  final String? initialOwnerImageUrl;
  final String? employeeId;
  final List<String?>? initialImageUrls;
  final bool fromOffline;
  final String? offlineSessionId;
  final bool focusWhatsapp;

  const ShopCategoryInfo({
    super.key,
    this.pages,
    this.initialShopNameEnglish,
    this.businessProfileId,
    this.initialShopNameTamil,
    this.isEditMode = false,
    this.shopId,
    required this.isService,
    required this.isIndividual,
    this.initialDescriptionEnglish,
    this.initialDescriptionTamil,
    this.initialAddressEnglish,
    this.initialAddressTamil,
    this.initialGps,
    this.initialPrimaryMobile,
    this.initialWhatsapp,
    this.initialEmail,
    this.initialCategoryName,
    this.initialCategorySlug,
    this.initialSubCategoryName,
    this.initialSubCategorySlug,
    this.initialDoorDeliveryText,
    this.initialOpenTimeText,
    this.initialCloseTimeText,
    this.initialOwnerImageUrl,
    this.employeeId,
    this.initialImageUrls,
    this.fromOffline = false,
    this.offlineSessionId,
    this.focusWhatsapp = false,
  });

  @override
  ConsumerState<ShopCategoryInfo> createState() => _ShopCategoryInfotate();
}

class _ShopCategoryInfotate extends ConsumerState<ShopCategoryInfo> {
  final _formKey = GlobalKey<FormState>();
  final FocusNode mobileFocusNode = FocusNode();
  List<ShopCategoryListData>? _selectedCategoryChildren;

  final TextEditingController _openTimeController = TextEditingController();
  final TextEditingController _closeTimeController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _subCategoryController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _doorDeliveryController = TextEditingController();
  final TextEditingController tamilNameController = TextEditingController();
  final TextEditingController _gpsController = TextEditingController();
  final TextEditingController _whatsappController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  final TextEditingController addressTamilNameController =
      TextEditingController();
  final TextEditingController descriptionTamilController =
      TextEditingController();
  final TextEditingController _shopNameEnglishController =
      TextEditingController();
  final TextEditingController _descriptionEnglishController =
      TextEditingController();
  final TextEditingController _addressEnglishController =
      TextEditingController();
  final TextEditingController _primaryMobileController =
      TextEditingController();

  final List<String> categories = ['Electronics', 'Clothing', 'Groceries'];
  final List<String> doorDelivery = ['Yes', 'No'];

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

  // 🔹 Extra validation error texts
  String? _categoryErrorText;
  String? _subCategoryErrorText;
  String? _timeErrorText;
  String? _imageErrorText;
  String? _gpsErrorText;

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

  String _toE164India(String input) {
    final ten = _normalizeIndianPhone10(input); // your existing helper
    if (ten.isEmpty) return '';
    return '+91$ten';
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

  void _showCategoryBottomSheet(
    BuildContext context,
    TextEditingController controller, {
    void Function(ShopCategoryListData selectedCategory)? onCategorySelected,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final searchController = TextEditingController();

        return Consumer(
          builder: (context, ref, _) {
            final shopState = ref.watch(shopCategoryNotifierProvider);
            final isLoading = shopState.isLoading;
            final categories = shopState.categoryListResponse?.data ?? [];

            // Local filtered list for search
            List<ShopCategoryListData> filtered = List.from(categories);

            return StatefulBuilder(
              builder: (context, setModalState) {
                return DraggableScrollableSheet(
                  expand: false,
                  initialChildSize: 0.8,
                  minChildSize: 0.4,
                  maxChildSize: 0.95,
                  builder: (context, scrollController) {
                    if (!isLoading && categories.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Text(
                            'No categories found',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    }

                    //  Normal UI: header + search + loader/list
                    return Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: SizedBox(
                            width: 40,
                            height: 4,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(2),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Text(
                          'Select Category',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // 🔍 Search box
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: TextField(
                            controller: searchController,
                            onChanged: (value) {
                              setModalState(() {
                                filtered =
                                    categories
                                        .where(
                                          (c) => c.name.toLowerCase().contains(
                                            value.toLowerCase(),
                                          ),
                                        )
                                        .toList();
                              });
                            },
                            decoration: InputDecoration(
                              hintText: 'Search category...',
                              prefixIcon: const Icon(
                                Icons.search,
                                color: Colors.grey,
                              ),
                              filled: true,
                              fillColor: Colors.grey[100],
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),

                        Expanded(
                          child:
                              isLoading
                                  ? Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(20),
                                      child: ThreeDotsLoader(
                                        dotColor: AppColor.darkBlue,
                                      ),
                                    ),
                                  )
                                  : ListView.builder(
                                    controller: scrollController,
                                    itemCount: filtered.length,
                                    itemBuilder: (context, index) {
                                      final category = filtered[index];
                                      return ListTile(
                                        title: Text(category.name),
                                        trailing:
                                            category.children.isNotEmpty
                                                ? const Icon(
                                                  Icons.arrow_forward_ios,
                                                  size: 14,
                                                )
                                                : null,
                                        onTap: () {
                                          Navigator.pop(context);

                                          setState(() {
                                            controller.text = category.name;
                                            categorySlug = category.slug;
                                            _categoryErrorText = null;
                                            _selectedCategoryChildren =
                                                category.children;
                                            _subCategoryController.clear();
                                            _subCategoryErrorText = null;
                                          });

                                          if (onCategorySelected != null) {
                                            onCategorySelected(category);
                                          }
                                        },
                                      );
                                    },
                                  ),
                        ),
                      ],
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Future<void> openGoogleMapsApp() async {
    // optional: current location எடுத்துக்கொள்
    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    final Uri uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${pos.latitude},${pos.longitude}',
    );

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch Google Maps';
    }
  }

  void _showCategoryChildrenBottomSheet(
    BuildContext context,
    List<ShopCategoryListData> children,
    TextEditingController controller,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        final searchController = TextEditingController();
        List<ShopCategoryListData> filtered = List.from(children);

        return StatefulBuilder(
          builder: (context, setModalState) {
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.6,
              minChildSize: 0.4,
              maxChildSize: 0.9,
              builder: (context, scrollController) {
                return Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: SizedBox(
                        width: 40,
                        height: 4,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.all(Radius.circular(2)),
                          ),
                        ),
                      ),
                    ),
                    const Text(
                      'Select Subcategory',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // 🔹 Search field with no underline
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: TextField(
                        controller: searchController,
                        onChanged: (value) {
                          setModalState(() {
                            filtered =
                                children
                                    .where(
                                      (c) => c.name.toLowerCase().contains(
                                        value.toLowerCase(),
                                      ),
                                    )
                                    .toList();
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Search subcategory...',
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Colors.grey,
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none, // ❌ No divider
                          ),
                        ),
                      ),
                    ),

                    Expanded(
                      child:
                          filtered.isEmpty
                              ? const Center(
                                child: Text(
                                  'No subcategories found',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              )
                              : ListView.builder(
                                controller: scrollController,
                                itemCount: filtered.length,
                                itemBuilder: (context, index) {
                                  final child = filtered[index];
                                  return ListTile(
                                    title: Text(child.name),
                                    onTap: () {
                                      Navigator.pop(context);
                                      setState(() {
                                        controller.text = child.name;
                                        subCategorySlug = child.slug;
                                        _subCategoryErrorText = null;
                                      });
                                    },
                                  );
                                },
                              ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  XFile? _permanentImage;
  bool _hasExistingOwnerImage = false;
  String? _existingUrl;
  File? _pickedImage;
  bool _imageInvalid = false;

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 85,
    );

    if (pickedFile == null) return;

    setState(() {
      _pickedImage = File(pickedFile.path); // ✅ THIS is what UI shows
      _existingUrl = null; // ✅ clear server image
      _imageInvalid = false;
      _imageErrorText = null;
    });

    debugPrint("✅ picked image path: ${_pickedImage!.path}");
  }

  final ImagePicker _picker = ImagePicker();
  Future<void> _showImageSourcePicker() async {
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
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  TimeOfDay? _openTod;
  TimeOfDay? _closeTod;
  int _toMinutes(TimeOfDay t) => t.hour * 60 + t.minute;
  bool validateTimes() {
    if (_openTod == null || _closeTod == null) return false;
    return _toMinutes(_closeTod!) > _toMinutes(_openTod!);
  }

  @override
  void initState() {
    super.initState();

    AppLogger.log.i("shopId=${widget.shopId}");
    AppLogger.log.i("isService=${widget.isService}");
    AppLogger.log.i("offlineSid=${widget.offlineSessionId}");

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // ✅ fetch category
      ref.read(shopCategoryNotifierProvider.notifier).fetchCategories();

      // ✅ edit mode prefill first (so offline won't overwrite)
      if (widget.isEditMode) {
        _prefillFields();
      }
      if (widget.fromOffline) {
        await _prefillShopFromOffline();
        if (mounted) mobileFocusNode.requestFocus();
      }
      // ✅ offline prefill
    });
  }

  // @override
  // void initState() {
  //   super.initState();
  //   AppLogger.log.i(widget.shopId);
  //   AppLogger.log.i(widget.isService);
  //   _prefillShopFromOffline();
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     ref.read(shopCategoryNotifierProvider.notifier).fetchCategories();
  //     final extra = GoRouterState.of(context).extra as Map<String, dynamic>;
  //     final parentShopId = extra['parentShopId'] as String?;
  //
  //     // if (parentShopId != null && parentShopId.isNotEmpty) {
  //     //   ref
  //     //       .read(aboutMeNotifierProvider.notifier)
  //     //       .fetchAllShopDetails(shopId: parentShopId);
  //     // }
  //   });
  //   if (widget.isEditMode) {
  //     _prefillFields();
  //   }
  // }

  void _setIfEmpty(TextEditingController c, String v) {
    if (c.text.trim().isNotEmpty) return;
    final val = v.trim();
    if (val.isEmpty) return;
    c.text = val;
  }

  bool _prefilled = false;
  bool _prefilledShop = false;

  Future<void> _prefillShopFromOffline() async {
    AppLogger.log.i("🟦 prefillShopFromOffline called");
    AppLogger.log.i("🟦 widget.offlineSessionId = ${widget.offlineSessionId}");

    if (_prefilledShop) return;

    String? sid = widget.offlineSessionId;
    if (sid == null || sid.trim().isEmpty) {
      // ✅ fallback: prefs la irundhu eduthuko
      sid = await AppPrefs.getOfflineSessionId();
      AppLogger.log.i("🟨 fallback sid(from prefs) = $sid");
    }

    if (sid == null || sid.trim().isEmpty) {
      AppLogger.log.i("🟥 sid empty -> cannot prefill");
      return;
    }

    final db = ref.read(offlineSyncDbProvider);

    final raw = await db.getPayload(sid.trim(), SyncStepType.shop);
    AppLogger.log.i("🟦 raw payload = $raw");

    if (raw == null) {
      AppLogger.log.i("🟥 raw is null -> stepType mismatch or not saved");
      return;
    }

    // ✅ Shop fields
    _setIfEmpty(
      _shopNameEnglishController,
      (raw["englishName"] ?? "").toString(),
    );
    _setIfEmpty(
      _descriptionEnglishController,
      (raw["descriptionEn"] ?? "").toString(),
    );
    _setIfEmpty(_addressEnglishController, (raw["addressEn"] ?? "").toString());

    // ✅ GPS -> "lat, lng"
    final lat = raw["gpsLatitude"];
    final lng = raw["gpsLongitude"];
    final gpsText = "${lat ?? 0}, ${lng ?? 0}";
    _setIfEmpty(_gpsController, gpsText);

    // ✅ Phones (strip +91)
    final p1 = (raw["primaryPhone"] ?? "").toString();
    final p2 = (raw["alternatePhone"] ?? "").toString();
    _setIfEmpty(_primaryMobileController, _stripIndianCode(p1));
    _setIfEmpty(_whatsappController, _stripIndianCode(p2));

    _setIfEmpty(_emailController, (raw["contactEmail"] ?? "").toString());

    // ✅ Door delivery (bool -> Yes/No)
    final dd = raw["doorDelivery"];
    final ddBool = dd == true || dd == 1 || dd.toString() == "true";
    _setIfEmpty(_doorDeliveryController, ddBool ? "Yes" : "No");

    // ✅ WeeklyHours -> Open/Close
    final wh = (raw["weeklyHours"] ?? "").toString().trim();
    if (wh.contains("-")) {
      final parts = wh.split("-");
      final openText = parts.isNotEmpty ? parts[0].trim() : "";
      final closeText = parts.length > 1 ? parts[1].trim() : "";

      _setIfEmpty(_openTimeController, openText);
      _setIfEmpty(_closeTimeController, closeText);

      // optional: parse and store to TimeOfDay (for validation)
      _openTod = _parseTimeOfDay(openText);
      _closeTod = _parseTimeOfDay(closeText);
    } else {
      // fallback
      _setIfEmpty(_openTimeController, wh);
    }

    AppLogger.log.i("✅ after set: shopName=${_shopNameEnglishController.text}");

    _prefilledShop = true;
    if (mounted) setState(() {});
  }

  void _prefillFields() {
    // 👉 shop name
    if (widget.initialShopNameEnglish?.isNotEmpty ?? false) {
      _shopNameEnglishController.text = widget.initialShopNameEnglish!;
    }

    if (widget.initialShopNameTamil?.isNotEmpty ?? false) {
      tamilNameController.text = widget.initialShopNameTamil!;
      _tamilPrefilled = true;
    } else {
      _prefillTamilFromEnglishOnce();
    }

    // 👉 description
    if (widget.initialDescriptionEnglish?.isNotEmpty ?? false) {
      _descriptionEnglishController.text = widget.initialDescriptionEnglish!;
    }
    if (widget.initialDescriptionTamil?.isNotEmpty ?? false) {
      descriptionTamilController.text = widget.initialDescriptionTamil!;
    }

    // 👉 address
    if (widget.initialAddressEnglish?.isNotEmpty ?? false) {
      _addressEnglishController.text = widget.initialAddressEnglish!;
    }
    if (widget.initialAddressTamil?.isNotEmpty ?? false) {
      addressTamilNameController.text = widget.initialAddressTamil!;
    }

    // 👉 GPS
    if (widget.initialGps?.isNotEmpty ?? false) {
      _gpsController.text = widget.initialGps!;
      _gpsFetched = true;
    }

    // 👉 phones (strip +91 / 91 for edit mode)
    if (widget.initialPrimaryMobile?.isNotEmpty ?? false) {
      var phone = widget.initialPrimaryMobile!.trim();
      phone = _stripIndianCode(phone);
      _primaryMobileController.text = phone;
    }

    if (widget.initialWhatsapp?.isNotEmpty ?? false) {
      var wa = widget.initialWhatsapp!.trim();
      wa = _stripIndianCode(wa);
      _whatsappController.text = wa;
    }

    // 👉 email
    if (widget.initialEmail?.isNotEmpty ?? false) {
      _emailController.text = widget.initialEmail!;
    }

    // 👉 category / subcategory
    if (widget.initialCategoryName?.isNotEmpty ?? false) {
      _categoryController.text = widget.initialCategoryName!;
      categorySlug = widget.initialCategorySlug ?? '';
    }
    if (widget.initialSubCategoryName?.isNotEmpty ?? false) {
      _subCategoryController.text = widget.initialSubCategoryName!;
      subCategorySlug = widget.initialSubCategorySlug ?? '';
    }

    // 👉 door delivery (for product flow)
    if (widget.initialDoorDeliveryText?.isNotEmpty ?? false) {
      _doorDeliveryController.text = widget.initialDoorDeliveryText!;
    }

    // 👉 open / close time – text + parse to TimeOfDay
    if (widget.initialOpenTimeText?.isNotEmpty ?? false) {
      final parsedOpen = _parseTimeOfDay(widget.initialOpenTimeText!);
      if (parsedOpen != null) {
        _openTod = parsedOpen;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _openTimeController.text = parsedOpen.format(context);
          }
        });
      } else {
        _openTimeController.text = widget.initialOpenTimeText!;
      }
    }

    if (widget.initialCloseTimeText?.isNotEmpty ?? false) {
      final parsedClose = _parseTimeOfDay(widget.initialCloseTimeText!);
      if (parsedClose != null) {
        _closeTod = parsedClose;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _closeTimeController.text = parsedClose.format(context);
          }
        });
      } else {
        _closeTimeController.text = widget.initialCloseTimeText!;
      }
    }

    // 👉 owner image
    if ((widget.initialOwnerImageUrl?.isNotEmpty ?? false) &&
        (widget.isService == true)) {
      _existingUrl = widget.initialOwnerImageUrl; // optional
      _hasExistingOwnerImage = true;
    }
  }

  Future<void> _prefillTamilFromEnglishOnce() async {
    if (_tamilPrefilled) return;
    final english = _shopNameEnglishController.text.trim();
    if (english.isEmpty) return;

    setState(() => isTamilNameLoading = true);
    try {
      final result = await TanglishTamilHelper.transliterate(english);
      if (!mounted) return;
      if (result.isNotEmpty && tamilNameController.text.trim().isEmpty) {
        tamilNameController.text = result.first; // pick first suggestion
      }
      _tamilPrefilled = true;
    } catch (_) {
      // ignore; user can type manually
    } finally {
      if (mounted) setState(() => isTamilNameLoading = false);
    }
  }

  @override
  void dispose() {
    _shopNameEnglishController.dispose();
    _categoryController.dispose();
    _cityController.dispose();
    _doorDeliveryController.dispose();
    tamilNameController.dispose();
    addressTamilNameController.dispose();
    descriptionTamilController.dispose();
    _gpsController.dispose();
    _openTimeController.dispose();
    _closeTimeController.dispose();
    _descriptionEnglishController.dispose();
    _addressEnglishController.dispose();
    _primaryMobileController.dispose();
    _whatsappController.dispose();
    _emailController.dispose();
    _subCategoryController.dispose();
    super.dispose();
  }

  // 🔹 Central validation function
  bool _validateAll() {
    final bool isEditFromAboutMe = widget.pages == "shopDetailsEdit";
    if (isEditFromAboutMe) {
      // ✅ AboutMe update screen: no validation at all
      return true;
    }

    setState(() {
      _isSubmitted = true;
      _categoryErrorText = null;
      _subCategoryErrorText = null;
      _timeErrorText = null;
      _imageErrorText = null;
      _timetableInvalid = false;
      _gpsErrorText = null;
    });

    final baseValid = _formKey.currentState?.validate() ?? false;
    bool extraValid = true;

    // ... your existing validations

    final allGood = baseValid && extraValid;

    if (!allGood) {
      AppSnackBar.error(context, 'Please fill all required fields correctly');
    }

    setState(() {});
    return allGood;
  }

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
    final state = ref.watch(shopCategoryNotifierProvider);
    final bool isServiceFlow = widget.isService ?? false;
    final bool isIndividualFlow = widget.isIndividual ?? true;
    final bool isEditFromAboutMe = widget.pages == "shopDetailsEdit";
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
                        'Register Shop',
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
                  image: AppImages.shopInfoImage,
                  text: 'Shop Info',
                  imageHeight: 85,
                  gradientColor: AppColor.lightSkyBlue,
                  value: 0.3,
                ),

                SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Shop name',
                            style: AppTextStyles.mulish(
                              color: AppColor.mildBlack,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '( As per Govt Certificate )',
                            style: AppTextStyles.mulish(
                              color: AppColor.mediumLightGray,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      CommonContainer.fillingContainer(
                        verticalDivider: false,
                        controller: _shopNameEnglishController,
                        text: '',
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? 'Please Enter Shop Name '
                                    : null,
                      ),
                      const SizedBox(height: 25),
                      Text(
                        'Shop Category',
                        style: AppTextStyles.mulish(color: AppColor.mildBlack),
                      ),
                      SizedBox(height: 10),
                      GestureDetector(
                        onTap: () {
                          // 1️⃣ Start API call – this will set isLoading = true
                          ref
                              .read(shopCategoryNotifierProvider.notifier)
                              .fetchCategories();

                          // 2️⃣ Open bottom sheet immediately
                          _showCategoryBottomSheet(
                            context,
                            _categoryController,
                            onCategorySelected: (selectedCategory) {
                              setState(() {
                                _selectedCategoryChildren =
                                    selectedCategory.children;
                                _subCategoryController.clear();
                                _categoryErrorText = null;
                                _subCategoryErrorText = null;
                              });
                            },
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 19,
                          ),
                          decoration: BoxDecoration(
                            color: AppColor.lowGery1,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _categoryController.text.isEmpty
                                        ? ""
                                        : _categoryController.text,
                                    style: AppTextStyles.mulish(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                Image.asset(
                                  AppImages.drapDownImage,
                                  height: 30,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (_categoryErrorText != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 6.0, left: 4),
                          child: Text(
                            _categoryErrorText!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ),

                      const SizedBox(height: 10),

                      GestureDetector(
                        onTap: () {
                          if (_categoryController.text.isEmpty ||
                              _selectedCategoryChildren == null) {
                            AppSnackBar.info(
                              context,
                              'Please select a category first',
                            );
                            return;
                          }
                          _showCategoryChildrenBottomSheet(
                            context,
                            _selectedCategoryChildren!,
                            _subCategoryController,
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 19,
                          ),
                          decoration: BoxDecoration(
                            color: AppColor.lowGery1,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _subCategoryController.text.isEmpty
                                        ? " "
                                        : _subCategoryController.text,
                                    style: AppTextStyles.mulish(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 18,
                                      color:
                                          _subCategoryController.text.isEmpty
                                              ? Colors.grey
                                              : Colors.black,
                                    ),
                                  ),
                                ),
                                Image.asset(
                                  AppImages.drapDownImage,
                                  height: 30,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (_subCategoryErrorText != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 6.0, left: 4),
                          child: Text(
                            _subCategoryErrorText!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ),

                      // const SizedBox(height: 15),
                      // CommonContainer.fillingContainer(
                      //   controller: tamilNameController,
                      //   text: 'Tamil',
                      //   isTamil: true,
                      //   validator: (v) => (v == null || v.isEmpty)
                      //       ? 'Please Enter Shop Name in Tamil'
                      //       : null,
                      //   onChanged: (value) async {
                      //     // your existing suggestion logic can remain
                      //     setState(() => isTamilNameLoading = true);
                      //     final result =
                      //         await TanglishTamilHelper.transliterate(value);
                      //     setState(() {
                      //       tamilNameSuggestion = result;
                      //       isTamilNameLoading = false;
                      //       _tamilPrefilled =
                      //           true; // user started typing; stop auto-updates
                      //     });
                      //   },
                      // ),
                      // if (isTamilNameLoading)
                      //   const Padding(
                      //     padding: EdgeInsets.all(8.0),
                      //     child: CircularProgressIndicator(strokeWidth: 2),
                      //   ),
                      // if (isTamilNameLoading)
                      //   const Padding(
                      //     padding: EdgeInsets.all(8.0),
                      //     child: CircularProgressIndicator(strokeWidth: 2),
                      //   ),
                      // if (tamilNameSuggestion.isNotEmpty)
                      //   Container(
                      //     margin: const EdgeInsets.only(top: 4),
                      //     constraints: const BoxConstraints(maxHeight: 150),
                      //     decoration: BoxDecoration(
                      //       color: Colors.white,
                      //       borderRadius: BorderRadius.circular(15),
                      //       border: Border.all(color: Colors.grey),
                      //     ),
                      //     child: ListView.builder(
                      //       shrinkWrap: true,
                      //       itemCount: tamilNameSuggestion.length,
                      //       itemBuilder: (context, index) {
                      //         final suggestion = tamilNameSuggestion[index];
                      //         return ListTile(
                      //           title: Text(suggestion),
                      //           onTap: () {
                      //             print("Selected suggestion: $suggestion");
                      //             TanglishTamilHelper.applySuggestion(
                      //               controller: tamilNameController,
                      //               suggestion: suggestion,
                      //               onSuggestionApplied: () {
                      //                 setState(() => tamilNameSuggestion = []);
                      //               },
                      //             );
                      //           },
                      //         );
                      //       },
                      //     ),
                      //   ),
                      const SizedBox(height: 25),
                      Text(
                        'Describe Shop',
                        style: AppTextStyles.mulish(color: AppColor.mildBlack),
                      ),
                      const SizedBox(height: 10),
                      CommonContainer.fillingContainer(
                        controller: _descriptionEnglishController,
                        maxLine: 4,
                        text: '',
                        verticalDivider: false,
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? 'Please Enter Describe'
                                    : null,
                      ),
                      // const SizedBox(height: 15),
                      // CommonContainer.fillingContainer(
                      //   onChanged: (value) async {
                      //     setState(() => isDescriptionTamilLoading = true);
                      //     final result =
                      //         await TanglishTamilHelper.transliterate(value);
                      //
                      //     setState(() {
                      //       descriptionTamilSuggestion = result;
                      //       isDescriptionTamilLoading = false;
                      //     });
                      //   },
                      //   controller: descriptionTamilController,
                      //   maxLine: 4,
                      //   text: 'Tamil',
                      //   isTamil: true,
                      //   validator: (value) => value == null || value.isEmpty
                      //       ? 'Please Enter Describe in Tamil'
                      //       : null,
                      // ),
                      // if (isDescriptionTamilLoading)
                      //   const Padding(
                      //     padding: EdgeInsets.all(8.0),
                      //     child: CircularProgressIndicator(strokeWidth: 2),
                      //   ),
                      // if (descriptionTamilSuggestion.isNotEmpty)
                      //   Container(
                      //     margin: const EdgeInsets.only(top: 4),
                      //     constraints: const BoxConstraints(maxHeight: 150),
                      //     decoration: BoxDecoration(
                      //       color: Colors.white,
                      //       borderRadius: BorderRadius.circular(15),
                      //       border: Border.all(color: Colors.grey),
                      //     ),
                      //     child: ListView.builder(
                      //       shrinkWrap: true,
                      //       itemCount: descriptionTamilSuggestion.length,
                      //       itemBuilder: (context, index) {
                      //         final suggestion =
                      //             descriptionTamilSuggestion[index];
                      //         return ListTile(
                      //           title: Text(suggestion),
                      //           onTap: () {
                      //             print("Selected suggestion: $suggestion");
                      //             TanglishTamilHelper.applySuggestion(
                      //               controller: descriptionTamilController,
                      //               suggestion: suggestion,
                      //               onSuggestionApplied: () {
                      //                 setState(
                      //                   () => descriptionTamilSuggestion = [],
                      //                 );
                      //               },
                      //             );
                      //           },
                      //         );
                      //       },
                      //     ),
                      //   ),
                      SizedBox(height: 25),
                      Text(
                        'Address',
                        style: AppTextStyles.mulish(color: AppColor.mildBlack),
                      ),
                      SizedBox(height: 10),
                      CommonContainer.fillingContainer(
                        controller: _addressEnglishController,
                        maxLine: 4,
                        text: '',
                        verticalDivider: false,
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? 'Please Enter Address '
                                    : null,
                      ),
                      // SizedBox(height: 15),
                      // CommonContainer.fillingContainer(
                      //   onChanged: (value) async {
                      //     setState(() => isAddressLoading = true);
                      //     final result =
                      //         await TanglishTamilHelper.transliterate(value);
                      //
                      //     setState(() {
                      //       addressTamilSuggestion = result;
                      //       isAddressLoading = false;
                      //     });
                      //   },
                      //   controller: addressTamilNameController,
                      //   maxLine: 4,
                      //   text: 'Tamil',
                      //   isTamil: true,
                      //   validator: (value) => value == null || value.isEmpty
                      //       ? 'Please Enter Address in Tamil'
                      //       : null,
                      // ),
                      // if (isAddressLoading)
                      //   const Padding(
                      //     padding: EdgeInsets.all(8.0),
                      //     child: CircularProgressIndicator(strokeWidth: 2),
                      //   ),
                      // if (addressTamilSuggestion.isNotEmpty)
                      //   Container(
                      //     margin: const EdgeInsets.only(top: 4),
                      //     constraints: const BoxConstraints(maxHeight: 150),
                      //     decoration: BoxDecoration(
                      //       color: Colors.white,
                      //       borderRadius: BorderRadius.circular(15),
                      //       border: Border.all(color: Colors.grey),
                      //     ),
                      //     child: ListView.builder(
                      //       shrinkWrap: true,
                      //       itemCount: addressTamilSuggestion.length,
                      //       itemBuilder: (context, index) {
                      //         final suggestion = addressTamilSuggestion[index];
                      //         return ListTile(
                      //           title: Text(suggestion),
                      //           onTap: () {
                      //             print("Selected suggestion: $suggestion");
                      //             TanglishTamilHelper.applySuggestion(
                      //               controller: addressTamilNameController,
                      //               suggestion: suggestion,
                      //               onSuggestionApplied: () {
                      //                 setState(
                      //                   () => addressTamilSuggestion = [],
                      //                 );
                      //               },
                      //             );
                      //           },
                      //         );
                      //       },
                      //     ),
                      //   ),
                      const SizedBox(height: 25),
                      Text(
                        'GPS Location',
                        style: AppTextStyles.mulish(color: AppColor.mildBlack),
                      ),
                      const SizedBox(height: 10),
                      GpsInputField(
                        controller: _gpsController,
                        isLoading: _isFetchingGps,
                        onMapTap: () async {
                          setState(() => _isFetchingGps = true);

                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => const GoogleLocationPickerScreen(),
                            ),
                          );

                          setState(() => _isFetchingGps = false);

                          if (result != null) {
                            final double lat = result['lat'];
                            final double lng = result['lng'];
                            final String area = result['area'];

                            _gpsController.text =
                                '${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}';

                            debugPrint('LAT: $lat');
                            debugPrint('LNG: $lng');
                            debugPrint('AREA: $area');
                          }
                        },
                      ),

                      const SizedBox(height: 25),
                      Text(
                        'Primary Mobile Number',
                        style: AppTextStyles.mulish(color: AppColor.mildBlack),
                      ),
                      const SizedBox(height: 10),
                      if (isEditFromAboutMe) ...[
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 400),
                          transitionBuilder:
                              (child, animation) => FadeTransition(
                                opacity: animation,
                                child: child,
                              ),
                          child: OwnerVerifyField(
                            controller: _primaryMobileController,
                            // focusNode: mobileFocusNode,
                            isLoading: state.isSendingOtp,
                            isOtpVerifying: state.isVerifyingOtp,
                            onSendOtp: (mobile) {
                              final phone10 = _normalizeIndianPhone10(mobile);
                              return ref
                                  .read(shopCategoryNotifierProvider.notifier)
                                  .shopAddNumberRequest(
                                    type: "SHOP_PRIMARY_PHONE",
                                    phoneNumber: phone10,
                                  );
                            },
                            onVerifyOtp: (mobile, otp) async {
                              final phone10 = _normalizeIndianPhone10(mobile);

                              final ok = await ref
                                  .read(shopCategoryNotifierProvider.notifier)
                                  .shopAddOtpRequest(
                                    phoneNumber: phone10,
                                    type: "SHOP_PRIMARY_PHONE",
                                    code: otp,
                                  );

                              if (!ok ||
                                  !widget.fromOffline ||
                                  !context.mounted)
                                return ok;

                              final sid = widget.offlineSessionId;
                              if (sid == null || sid.trim().isEmpty) return ok;

                              final db = ref.read(offlineSyncDbProvider);

                              // ✅ existing offline shop payload
                              final oldShop =
                                  await db.getPayload(
                                    sid.trim(),
                                    SyncStepType.shop,
                                  ) ??
                                  {};

                              // ✅ update phone fields in offline payload
                              // IMPORTANT: store E164 (+91...) because your API expects it
                              final e164 = _toE164India(mobile);

                              final updatedShop = <String, dynamic>{
                                ...oldShop,

                                // ✅ update common keys
                                "primaryPhone": e164,
                                "shopPrimaryPhone": e164,
                                "phoneNumber": e164,
                                "phone": e164,
                                "mobile": e164,
                                "mobileNumber": e164,

                                // ✅ if you saved token for server sync (optional but useful)
                                // After OTP verify, your notifier usually saves verification token in prefs.
                                // If not, you can store it here if you have it.
                                // "primaryPhoneVerificationToken": (await AppPrefs.getVerificationToken()) ?? "",
                                // "phoneVerifyToken": (await AppPrefs.getVerificationToken()) ?? "",
                              };

                              await db.upsertStep(
                                sessionId: sid.trim(),
                                type: SyncStepType.shop,
                                payload: updatedShop,
                              );

                              Navigator.pop(
                                context,
                                true,
                              ); // ✅ return verified to sync screen
                              return ok;
                            },

                            // onVerifyOtp: (mobile, otp) {
                            //   final phone10 = _normalizeIndianPhone10(mobile);
                            //   return ref
                            //       .read(shopCategoryNotifierProvider.notifier)
                            //       .shopAddOtpRequest(
                            //         phoneNumber: phone10,
                            //         type: "SHOP_PRIMARY_PHONE",
                            //         code: otp,
                            //       );
                            // },
                          ),
                        ),
                        // CommonContainer.fillingContainer(
                        //   controller: _primaryMobileController,
                        //   verticalDivider:
                        //       false, // optional: hide divider if you want
                        //   isMobile: false, // IMPORTANT → disables +91 logic
                        //   text: 'Mobile No',
                        //   keyboardType: TextInputType.phone,
                        //   validator: (_) => null, // no validation
                        // ),
                      ] else ...[
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 400),
                          transitionBuilder:
                              (child, animation) => FadeTransition(
                                opacity: animation,
                                child: child,
                              ),
                          child: OwnerVerifyField(
                            focusNode: mobileFocusNode,
                            controller: _primaryMobileController,
                            isLoading: state.isSendingOtp,
                            isOtpVerifying: state.isVerifyingOtp,
                            onSendOtp: (mobile) {
                              final phone10 = _normalizeIndianPhone10(mobile);
                              return ref
                                  .read(shopCategoryNotifierProvider.notifier)
                                  .shopAddNumberRequest(
                                    type: "SHOP_PRIMARY_PHONE",
                                    phoneNumber: phone10,
                                  );
                            },
                            onVerifyOtp: (mobile, otp) async {
                              final phone10 = _normalizeIndianPhone10(mobile);

                              final ok = await ref
                                  .read(shopCategoryNotifierProvider.notifier)
                                  .shopAddOtpRequest(
                                    phoneNumber: phone10,
                                    type: "SHOP_PRIMARY_PHONE",
                                    code: otp,
                                  );

                              if (!ok ||
                                  !widget.fromOffline ||
                                  !context.mounted)
                                return ok;

                              final sid = widget.offlineSessionId;
                              if (sid == null || sid.trim().isEmpty) return ok;

                              final db = ref.read(offlineSyncDbProvider);

                              // ✅ existing offline shop payload
                              final oldShop =
                                  await db.getPayload(
                                    sid.trim(),
                                    SyncStepType.shop,
                                  ) ??
                                  {};

                              // ✅ update phone fields in offline payload
                              // IMPORTANT: store E164 (+91...) because your API expects it
                              final e164 = _toE164India(mobile);

                              final updatedShop = <String, dynamic>{
                                ...oldShop,

                                // ✅ update common keys
                                "primaryPhone": e164,
                                "shopPrimaryPhone": e164,
                                "phoneNumber": e164,
                                "phone": e164,
                                "mobile": e164,
                                "mobileNumber": e164,

                                // ✅ if you saved token for server sync (optional but useful)
                                // After OTP verify, your notifier usually saves verification token in prefs.
                                // If not, you can store it here if you have it.
                                // "primaryPhoneVerificationToken": (await AppPrefs.getVerificationToken()) ?? "",
                                // "phoneVerifyToken": (await AppPrefs.getVerificationToken()) ?? "",
                              };

                              await db.upsertStep(
                                sessionId: sid.trim(),
                                type: SyncStepType.shop,
                                payload: updatedShop,
                              );

                              Navigator.pop(
                                context,
                                true,
                              ); // ✅ return verified to sync screen
                              return ok;
                            },
                            // onVerifyOtp: (mobile, otp) {
                            //   final phone10 = _normalizeIndianPhone10(mobile);
                            //   return ref
                            //       .read(shopCategoryNotifierProvider.notifier)
                            //       .shopAddOtpRequest(
                            //         phoneNumber: phone10,
                            //         type: "SHOP_PRIMARY_PHONE",
                            //         code: otp,
                            //       );
                            // },
                          ),
                        ),
                        // CommonContainer.fillingContainer(
                        //   controller: _primaryMobileController,
                        //   verticalDivider: true,
                        //   isMobile: true, // mobile behavior +91 etc
                        //   text: 'Mobile No',
                        //   keyboardType: TextInputType.phone,
                        //   validator: (value) {
                        //     if (value == null || value.isEmpty) {
                        //       return 'Please Enter Primary Mobile Number';
                        //     }
                        //     return null;
                        //   },
                        // ),
                      ],
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
                        'Whatsapp Number',
                        style: AppTextStyles.mulish(color: AppColor.mildBlack),
                      ),
                      SizedBox(height: 10),
                      if (isEditFromAboutMe) ...[
                        //  Edit mode: simple text field, no +91, no validation
                        CommonContainer.fillingContainer(
                          controller: _whatsappController,
                          verticalDivider: false,
                          isMobile: false, //  IMPORTANT
                          text: 'Mobile No',
                          keyboardType: TextInputType.phone,
                          validator: (_) => null,
                        ),
                      ] else ...[
                        //  Normal register flow
                        CommonContainer.fillingContainer(
                          controller: _whatsappController,
                          verticalDivider: true,
                          isMobile: true,
                          text: 'Mobile No',
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please Enter Whatsapp Number';
                            }
                            return null;
                          },
                        ),
                      ],
                      // CommonContainer.fillingContainer(
                      //   controller: _whatsappController,
                      //   verticalDivider: true,
                      //   isMobile: true,
                      //   text: 'Mobile No',
                      //   // validator: (value) => value == null || value.isEmpty
                      //   //     ? 'Please Enter Whatsapp Number'
                      //   //     : null,
                      // ),
                      const SizedBox(height: 25),
                      Text(
                        'Open Time',
                        style: AppTextStyles.mulish(color: AppColor.mildBlack),
                      ),
                      const SizedBox(height: 10),
                      CommonContainer.fillingContainer(
                        controller: _openTimeController,
                        text: '',
                        imagePath: AppImages.clock,
                        imageWidth: 25,
                        readOnly: true,

                        onFieldTap: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  timePickerTheme: TimePickerThemeData(
                                    backgroundColor: Colors.white,
                                    hourMinuteTextColor: Colors.black,
                                    hourMinuteColor: AppColor.iceGray,
                                    dialHandColor: Colors.black,
                                    dialBackgroundColor: AppColor.white,
                                    entryModeIconColor: AppColor.black,
                                    dayPeriodTextColor:
                                        AppColor.borderLightGrey,
                                    dayPeriodColor: AppColor.black,
                                  ),
                                  colorScheme: ColorScheme.light(
                                    primary: Colors.black,
                                    onPrimary: AppColor.white,
                                    onSurface: Colors.black,
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );

                          if (picked != null) {
                            _openTimeController.text = picked.format(context);
                            setState(() => _openTod = picked);
                          }
                        },

                        validator: (v) {
                          if (isEditFromAboutMe)
                            return null; // ✅ skip validation
                          return (v == null || v.isEmpty)
                              ? 'Please select Open Time'
                              : null;
                        },
                      ),
                      const SizedBox(height: 25),
                      Text(
                        'Close Time',
                        style: AppTextStyles.mulish(color: AppColor.mildBlack),
                      ),
                      const SizedBox(height: 10),
                      CommonContainer.fillingContainer(
                        controller: _closeTimeController,
                        text: '',
                        readOnly: true,
                        imagePath: AppImages.clock,
                        imageWidth: 25,
                        onFieldTap: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  timePickerTheme: TimePickerThemeData(
                                    backgroundColor: Colors.white,
                                    hourMinuteTextColor: Colors.black,
                                    hourMinuteColor: AppColor.iceGray,
                                    dialHandColor: Colors.black,
                                    dialBackgroundColor: AppColor.white,
                                    entryModeIconColor: AppColor.black,
                                    dayPeriodTextColor:
                                        AppColor.borderLightGrey,
                                    dayPeriodColor: AppColor.black,
                                  ),
                                  colorScheme: ColorScheme.light(
                                    primary: Colors.black,
                                    onPrimary: AppColor.white,
                                    onSurface: Colors.black,
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );

                          if (picked != null) {
                            _closeTimeController.text = picked.format(context);
                            setState(() => _closeTod = picked);
                          }
                        },
                        validator: (v) {
                          if (isEditFromAboutMe)
                            return null; // ✅ skip validation
                          return (v == null || v.isEmpty)
                              ? 'Please select Close Time'
                              : null;
                        },
                      ),
                      if (_timeErrorText != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 6.0, left: 4),
                          child: Text(
                            _timeErrorText!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ),

                      const SizedBox(height: 25),
                      Text(
                        'Email Id',
                        style: AppTextStyles.mulish(color: AppColor.mildBlack),
                      ),
                      const SizedBox(height: 10),
                      CommonContainer.fillingContainer(
                        keyboardType: TextInputType.emailAddress,
                        controller: _emailController,
                        verticalDivider: true,
                        text: 'Email Id',
                        validator: (v) {
                          if (isEditFromAboutMe)
                            return null; // ✅ skip validation
                          if (v == null || v.isEmpty) return 'Email required';
                          if (!RegExp(
                            r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                          ).hasMatch(v)) {
                            return 'Enter valid email';
                          }
                          return null;
                        },

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
                      SizedBox(height: 25),
                      // if (widget.isService ??
                      //     false || widget.pages != 'AboutMeScreens')
                      if (!(widget.isService ?? false)) ...[
                        Text(
                          'Door Delivery',
                          style: AppTextStyles.mulish(
                            color: AppColor.mildBlack,
                          ),
                        ),
                        SizedBox(height: 10),
                        CommonContainer.fillingContainer(
                          imagePath: AppImages.drapDownImage,
                          verticalDivider: false,
                          controller: _doorDeliveryController,
                          isDropdown: true,
                          dropdownItems: doorDelivery,
                          context: context,
                          validator:
                              (value) =>
                                  value == null || value.isEmpty
                                      ? 'Please select a Door Delivery'
                                      : null,
                        ),
                      ] else ...[
                        // Service: show image picker container
                        Text(
                          'Add Your Photo',
                          style: AppTextStyles.mulish(
                            color: AppColor.mildBlack,
                          ),
                        ),
                        SizedBox(height: 10),
                        GestureDetector(
                          // onTap: _pickImage,
                          onTap: _showImageSourcePicker,
                          child: DottedBorder(
                            borderType: BorderType.RRect,
                            radius: const Radius.circular(20),
                            color:
                                _timetableInvalid
                                    ? Colors.red
                                    : AppColor.mediumLightGray,
                            strokeWidth: 1.5,
                            dashPattern: const [6, 2],
                            padding: const EdgeInsets.all(1),
                            child: Container(
                              height: 160,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                color: AppColor.white3,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: _buildOwnerPhotoWidget(),

                              // _permanentImage == null
                              //     ? Center(
                              //         child: Row(
                              //           mainAxisSize: MainAxisSize.min,
                              //           children: [
                              //             Image.asset(
                              //               AppImages.uploadImage,
                              //               height: 30,
                              //             ),
                              //             const SizedBox(width: 10),
                              //             Text(
                              //               'Upload',
                              //               style: AppTextStyles.mulish(
                              //                 fontSize: 14,
                              //                 fontWeight: FontWeight.w500,
                              //                 color: AppColor.mediumLightGray,
                              //               ),
                              //             ),
                              //           ],
                              //         ),
                              //       )
                              //     : Row(
                              //         children: [
                              //           Expanded(
                              //             child: ClipRRect(
                              //               borderRadius: BorderRadius.circular(
                              //                 12,
                              //               ),
                              //               child: Image.file(
                              //                 File(_permanentImage!.path),
                              //                 height: 140,
                              //                 fit: BoxFit.cover,
                              //               ),
                              //             ),
                              //           ),
                              //           const SizedBox(width: 8),
                              //           InkWell(
                              //             onTap: () {
                              //               setState(() {
                              //                 _permanentImage = null;
                              //                 _imageErrorText =
                              //                     'Please Add Your Photo';
                              //                 _timetableInvalid = true;
                              //               });
                              //             },
                              //             child: Padding(
                              //               padding: const EdgeInsets.symmetric(
                              //                 vertical: 35.0,
                              //               ),
                              //               child: Column(
                              //                 mainAxisAlignment:
                              //                     MainAxisAlignment.center,
                              //                 children: [
                              //                   Image.asset(
                              //                     AppImages.closeImage,
                              //                     height: 26,
                              //                     color: AppColor.mediumGray,
                              //                   ),
                              //                   Text(
                              //                     'Clear',
                              //                     style: AppTextStyles.mulish(
                              //                       fontSize: 14,
                              //                       fontWeight: FontWeight.w400,
                              //                       color: AppColor
                              //                           .mediumLightGray,
                              //                     ),
                              //                   ),
                              //                 ],
                              //               ),
                              //             ),
                              //           ),
                              //         ],
                              //       ),
                            ),
                          ),
                        ),
                        if (_imageErrorText != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 6.0, left: 4.0),
                            child: Text(
                              _imageErrorText!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],

                      SizedBox(height: 30),
                      CommonContainer.button(
                        buttonColor: AppColor.black,

                        onTap: () async {
                          FocusScope.of(context).unfocus();

                          final bool isEditFromAboutMe =
                              widget.pages == "shopDetailsEdit";
                          final isOffline = widget.fromOffline == true;
                          // ✅ Only register flow should validate
                          // ✅ Only ONLINE register flow should validate
                          if (!isEditFromAboutMe && !isOffline) {
                            if (!_validateAll()) return;
                          }

                          final bool isServiceFlow = widget.isService ?? false;
                          final String type =
                              isServiceFlow ? 'service' : 'product';

                          // GPS parsing
                          final gpsText = _gpsController.text.trim();
                          double latitude = 0.0;
                          double longitude = 0.0;

                          if (gpsText.isNotEmpty && gpsText.contains(',')) {
                            final parts = gpsText.split(',');
                            latitude = double.tryParse(parts[0].trim()) ?? 0.0;
                            longitude = double.tryParse(parts[1].trim()) ?? 0.0;
                          }

                          // door delivery
                          bool isDoorDeliveryEnabled = false;
                          if (!isServiceFlow) {
                            final doorDeliveryValue =
                                _doorDeliveryController.text.trim();
                            if (doorDeliveryValue.isEmpty) {
                              AppSnackBar.error(
                                context,
                                'Please select Door Delivery',
                              );
                              return;
                            }
                            isDoorDeliveryEnabled = doorDeliveryValue == 'Yes';
                          }

                          // owner image
                          final File? ownerFile =
                              _pickedImage == null
                                  ? null
                                  : File(_pickedImage!.path);

                          final weeklyHoursText =
                              "${_openTimeController.text.trim()} - ${_closeTimeController.text.trim()}";

                          final String primaryPhoneToSend = _toE164India(
                            _primaryMobileController.text,
                          );
                          final String alternatePhoneToSend = _toE164India(
                            _whatsappController.text,
                          );

                          // ✅ VERIFIED CHECK FIX (OTP or Pref token)
                          // ✅ OTP verified required ONLY in register flow
                          if (!isEditFromAboutMe) {
                            final shopState = ref.read(
                              shopCategoryNotifierProvider,
                            );
                            final savedToken =
                                await AppPrefs.getVerificationToken();

                            final isVerified =
                                (shopState
                                        .shopNumberOtpResponse
                                        ?.data
                                        ?.verified ==
                                    true) ||
                                (savedToken != null && savedToken.isNotEmpty);

                            // if (!isVerified) {
                            //   AppSnackBar.error(
                            //     context,
                            //     "Please verify Primary Mobile Number",
                            //   );
                            //   return;
                            // }
                          }

                          // final shopState = ref.read(
                          //   shopCategoryNotifierProvider,
                          // );
                          // final savedToken =
                          //     await AppPrefs.getVerificationToken();
                          //
                          // final isVerified =
                          //     (shopState
                          //             .shopNumberOtpResponse
                          //             ?.data
                          //             ?.verified ==
                          //         true) ||
                          //     (savedToken != null && savedToken.isNotEmpty);
                          //
                          // if (!isVerified) {
                          //   AppSnackBar.error(
                          //     context,
                          //     "Please verify Primary Mobile Number",
                          //   );
                          //   return;
                          // }
                          final bool ok = await ref
                              .read(shopCategoryNotifierProvider.notifier)
                              .shopInfoRegister(
                                businessProfileId: widget.employeeId ?? '',
                                shopId: widget.shopId,
                                ownerImageFile: ownerFile,
                                type: type,
                                addressEn:
                                    _addressEnglishController.text.trim(),
                                addressTa:
                                    addressTamilNameController.text.trim(),
                                alternatePhone: alternatePhoneToSend,
                                primaryPhone: primaryPhoneToSend,
                                category: categorySlug,
                                contactEmail: _emailController.text.trim(),
                                descriptionEn:
                                    _descriptionEnglishController.text.trim(),
                                descriptionTa:
                                    descriptionTamilController.text.trim(),
                                doorDelivery: isDoorDeliveryEnabled,
                                englishName:
                                    _shopNameEnglishController.text.trim(),
                                gpsLatitude: latitude,
                                gpsLongitude: longitude,
                                subCategory: subCategorySlug,
                                tamilName: tamilNameController.text.trim(),
                                weeklyHours: weeklyHoursText,
                              );

                          final st = ref.read(shopCategoryNotifierProvider);

                          if (!context.mounted) return;

                          if (ok == true) {
                            if (widget.pages == 'shopDetailsEdit') {
                              Navigator.pop(context, true);
                            } else {
                              context.pushNamed(
                                AppRoutes.shopPhotoInfo,
                                extra: 'shopCategory',
                              );
                            }
                          } else {
                            // ✅ show proper error
                            final msg = (st.error ?? '').trim();
                            AppSnackBar.error(
                              context,
                              msg.isNotEmpty
                                  ? msg
                                  : "Unexpected error, please try again",
                            );
                          }

                          /*     final response = await ref
                              .read(shopCategoryNotifierProvider.notifier)
                              .shopInfoRegister(
                                businessProfileId: widget.employeeId ?? '',
                                shopId: widget.shopId,
                                ownerImageFile: ownerFile,
                                type: type,
                                addressEn:
                                    _addressEnglishController.text.trim(),
                                addressTa:
                                    addressTamilNameController.text.trim(),
                                alternatePhone: alternatePhoneToSend,
                                primaryPhone: primaryPhoneToSend,
                                category: categorySlug,
                                contactEmail: _emailController.text.trim(),
                                descriptionEn:
                                    _descriptionEnglishController.text.trim(),
                                descriptionTa:
                                    descriptionTamilController.text.trim(),
                                doorDelivery: isDoorDeliveryEnabled,
                                englishName:
                                    _shopNameEnglishController.text.trim(),
                                gpsLatitude: latitude,
                                gpsLongitude: longitude,
                                subCategory: subCategorySlug,
                                tamilName: tamilNameController.text.trim(),
                                weeklyHours: weeklyHoursText,
                              );

                          final newState = ref.read(
                            shopCategoryNotifierProvider,
                          );

                          if (newState.error != null &&
                              newState.error!.isNotEmpty) {
                            AppSnackBar.error(context, newState.error!);
                          } else if (response != null) {
                            if (widget.pages == 'shopDetailsEdit') {
                              Navigator.pop(context, true);
                            } else {
                              context.pushNamed(
                                AppRoutes.shopPhotoInfo,
                                extra: 'shopCategory',
                              );
                            }
                          } else {
                            AppSnackBar.error(
                              context,
                              "Unexpected error, please try again",
                            );
                          }*/
                        },

                        text:
                            state.isLoading
                                ? ThreeDotsLoader()
                                : Text(
                                  widget.pages == "shopDetailsEdit"
                                      ? 'Update'
                                      : 'Save & Continue',
                                  style: AppTextStyles.mulish(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        imagePath:
                            state.isLoading ? null : AppImages.rightStickArrow,
                      ),
                      const SizedBox(height: 36),
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

  Widget _buildOwnerPhotoWidget() {
    // 1️⃣ Local selected image
    if (_pickedImage != null) {
      return Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(_pickedImage!, height: 140, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: () {
              setState(() {
                _pickedImage = null;
                _imageErrorText = 'Please Add Your Photo';
                _imageInvalid = true;
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 35.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    AppImages.closeImage,
                    height: 26,
                    color: AppColor.mediumGray,
                  ),
                  Text(
                    'Clear',
                    style: AppTextStyles.mulish(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColor.mediumLightGray,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    // 2️⃣ Server image (edit mode)
    if (_existingUrl != null && _existingUrl!.trim().isNotEmpty) {
      return Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                _existingUrl!,
                height: 140,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: () {
              setState(() {
                _existingUrl = null;
                _imageErrorText = 'Please Add Your Photo';
                _imageInvalid = true;
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 35.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    AppImages.closeImage,
                    height: 26,
                    color: AppColor.mediumGray,
                  ),
                  Text(
                    'Clear',
                    style: AppTextStyles.mulish(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColor.mediumLightGray,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    // 3️⃣ Default upload UI
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(AppImages.uploadImage, height: 30),
          const SizedBox(width: 10),
          Text(
            'Upload',
            style: AppTextStyles.mulish(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColor.mediumLightGray,
            ),
          ),
        ],
      ),
    );
  }
}

class GpsInputField extends StatelessWidget {
  final TextEditingController controller;
  final bool isLoading;
  final VoidCallback onMapTap;
  final String hintText;

  const GpsInputField({
    super.key,
    required this.controller,
    required this.isLoading,
    required this.onMapTap,
    this.hintText = ' ',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.lowGery1,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: controller,
              style: AppTextStyles.textWith700(fontSize: 16),
              readOnly: true, // IMPORTANT
              decoration: InputDecoration(
                border: InputBorder.none,
                hintStyle: AppTextStyles.mulish(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColor.skyBlue,
                ),
                hintText: hintText,
              ),
            ),
          ),
          Container(width: 2, height: 30, color: Colors.grey.shade300),
          InkWell(
            onTap: isLoading ? null : onMapTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              child: Row(
                children: [
                  Icon(Icons.location_on, size: 18, color: AppColor.blue),
                  SizedBox(width: 6),
                  Text(
                    'Shop Location',
                    style: AppTextStyles.mulish(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColor.blue,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
