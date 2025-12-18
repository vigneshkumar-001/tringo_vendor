import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tringo_vendor_new/Core/Const/app_logger.dart';
import 'package:tringo_vendor_new/Presentation/AddProduct/Controller/product_notifier.dart';
import 'package:tringo_vendor_new/Presentation/AddProduct/Controller/service_info_notifier.dart';
import '../../../Core/Const/app_color.dart';
import '../../../Core/Const/app_images.dart';

import '../../../Core/Session/registration_product_seivice.dart';
import '../../../Core/Session/registration_session.dart';
import '../../../Core/Utility/app_loader.dart';
import '../../../Core/Utility/app_snackbar.dart';
import '../../../Core/Utility/app_textstyles.dart';
import '../../../Core/Widgets/app_go_routes.dart';
import '../../../Core/Widgets/common_container.dart';
import '../../ShopInfo/Model/category_list_response.dart';
import 'add_product_list.dart';

class ProductCategoryScreens extends ConsumerStatefulWidget {
  final bool? isService;
  final bool? isIndividual;
  final bool allowOfferEdit;
  final String? initialOfferLabel;
  final String? initialOfferValue;
  final String? shopId;
  final String? productId;
  final String? page;
  final String? pages;

  final String? initialCategoryName;
  final String? initialSubCategoryName;
  final String? initialProductName;
  final int? initialPrice;
  final String? initialDescription;
  final String? initialDoorDelivery; // "Yes" / "No"
  final String? initialCategorySlug;
  final String? initialSubCategorySlug;

  const ProductCategoryScreens({
    super.key,
    this.isService,
    this.shopId,
    this.productId,
    this.page,
    this.pages,
    this.isIndividual,
    this.allowOfferEdit = false,
    this.initialOfferLabel,
    this.initialOfferValue,
    this.initialCategoryName,
    this.initialSubCategoryName,
    this.initialProductName,
    this.initialPrice,
    this.initialDescription,
    this.initialDoorDelivery,
    this.initialCategorySlug,
    this.initialSubCategorySlug,
  });

  @override
  ConsumerState<ProductCategoryScreens> createState() =>
      _ProductCategoryScreensState();
}

class _ProductCategoryScreensState
    extends ConsumerState<ProductCategoryScreens> {
  final _formKey = GlobalKey<FormState>();
  bool _categoryHasError = false;
  bool _subCategoryHasError = false;
  bool _doorDelivery = false;

  List<ShopCategoryListData>? _selectedCategoryChildren;
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _subCategoryController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _offerController = TextEditingController();
  final TextEditingController _doorDeliveryController = TextEditingController();
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _productPriceController = TextEditingController();
  final TextEditingController _offerPriceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final List<String> categories = [
    'product-mobile-devices',
    'Clothing',
    'Groceries',
  ];
  final List<String> cities = ['Yes', 'No'];
  final List<String> offers = ['First App Offer', 'second App Offer'];

  String productCategorySlug = '';
  String productSubCategorySlug = '';
  bool get isIndividualFlow {
    final session = RegistrationProductSeivice.instance;
    return session.businessType == BusinessType.individual;
  }

  void _showCategoryBottomSheet(
    BuildContext context,
    WidgetRef ref,
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
            final productState = ref.watch(productNotifierProvider);
            final isLoading = productState.isLoading;
            final categories =
                productState.shopCategoryListResponse?.data ?? [];

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

                    return Column(
                      children: [
                        const Padding(
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
                        const Text(
                          'Select Category',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
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
                              prefixIcon: Icon(
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
                                      padding: const EdgeInsets.all(20),
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
                                            productCategorySlug = category.slug;
                                            _categoryHasError = false;
                                            _subCategoryHasError = false;
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
                            borderSide: BorderSide.none,
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
                                        productSubCategorySlug = child.slug;
                                        _categoryHasError = false;
                                        _subCategoryHasError = false;
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

  Future<void> _showOfferBottomSheet() async {
    if (!widget.allowOfferEdit) return;

    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              const Text(
                'Select App Offer',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...offers.map(
                (offer) => ListTile(
                  title: Text(offer),
                  onTap: () => Navigator.pop(context, offer),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );

    if (selected != null && mounted) {
      setState(() {
        _offerController.text = selected;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    AppLogger.log.i(widget.productId);
    AppLogger.log.i(widget.page);

    _categoryController.text = widget.initialCategoryName ?? '';
    _subCategoryController.text = widget.initialSubCategoryName ?? '';
    _productNameController.text = widget.initialProductName ?? '';
    if (widget.initialPrice != null) {
      _productPriceController.text = widget.initialPrice!.toString();
    }
    _descriptionController.text = widget.initialDescription ?? '';
    _doorDeliveryController.text = widget.initialDoorDelivery ?? '';
    if (widget.initialDoorDelivery != null &&
        widget.initialDoorDelivery!.isNotEmpty) {
      _doorDelivery = widget.initialDoorDelivery == 'Yes';
    }

    productCategorySlug = widget.initialCategorySlug ?? '';
    productSubCategorySlug = widget.initialSubCategorySlug ?? '';

    _offerController.text = widget.initialOfferLabel ?? offers.first;
    _offerPriceController.text = widget.initialOfferValue ?? '5%';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(productNotifierProvider.notifier)
          .fetchProductCategories(apiShopId: widget.shopId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final productState = ref.watch(productNotifierProvider);
    final serviceState = ref.watch(serviceInfoNotifierProvider);

    // 👇 VERY IMPORTANT: Decide service / product from widget.isService if given
    final bool isServiceFlow =
        widget.isService ??
        RegistrationProductSeivice.instance.isServiceBusiness;
    AppLogger.log.i('IS Service : $isServiceFlow');
    final bool isEditFromAboutMe =
        (widget.page == 'AboutMeScreens') &&
        (widget.productId != null && widget.productId!.isNotEmpty);
    // 👇 VERY IMPORTANT:
    final bool isLoading =
        isServiceFlow ? serviceState.isLoading : productState.isLoading;

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
                      const SizedBox(width: 50),
                      Text(
                        'Register Vendor',
                        style: AppTextStyles.mulish(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
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
                const SizedBox(height: 35),
                CommonContainer.registerTopContainer(
                  image: AppImages.addProduct,
                  text: isServiceFlow ? 'Add Service' : 'Add Product',
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
                        isServiceFlow
                            ? ' Service Category'
                            : 'Product Category',
                        style: AppTextStyles.mulish(color: AppColor.mildBlack),
                      ),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () {
                          ref
                              .read(productNotifierProvider.notifier)
                              .fetchProductCategories(apiShopId: widget.shopId);

                          _showCategoryBottomSheet(
                            context,
                            ref,
                            _categoryController,
                            onCategorySelected: (selectedCategory) {
                              _selectedCategoryChildren =
                                  selectedCategory.children;
                              _subCategoryController.clear();
                              setState(() {
                                _categoryHasError = false;
                                _subCategoryHasError = false;
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
                            border: Border.all(
                              color:
                                  _categoryHasError
                                      ? Colors.red
                                      : Colors.transparent,
                              width: 1.5,
                            ),
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
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () {
                          if (_categoryController.text.isEmpty) {
                            AppSnackBar.info(
                              context,
                              'Please select a category first',
                            );
                            setState(() {
                              _categoryHasError = true;
                            });
                            return;
                          }

                          if (_selectedCategoryChildren == null ||
                              _selectedCategoryChildren!.isEmpty) {
                            AppSnackBar.info(
                              context,
                              'No subcategories available for this category',
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
                            border: Border.all(
                              color:
                                  _subCategoryHasError
                                      ? Colors.red
                                      : Colors.transparent,
                              width: 1.5,
                            ),
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
                      const SizedBox(height: 25),
                      Text(
                        isServiceFlow ? 'Service Name' : 'Product name',
                        style: AppTextStyles.mulish(color: AppColor.mildBlack),
                      ),
                      const SizedBox(height: 10),
                      CommonContainer.fillingContainer(
                        verticalDivider: false,
                        controller: _productNameController,
                        // validator: (value) {
                        //   if (value == null || value.isEmpty) {
                        //     return isServiceFlow
                        //         ? 'Please enter Service Name'
                        //         : 'Please enter Product name';
                        //   }
                        //   return null;
                        // },
                      ),
                      const SizedBox(height: 25),
                      Text(
                        isServiceFlow ? 'Start From' : 'Product price',
                        style: AppTextStyles.mulish(color: AppColor.mildBlack),
                      ),
                      const SizedBox(height: 10),
                      CommonContainer.fillingContainer(
                        keyboardType: TextInputType.number,
                        verticalDivider: false,
                        controller: _productPriceController,
                        // validator: (value) {
                        //   if (value == null || value.isEmpty) {
                        //     return isServiceFlow
                        //         ? 'Please enter Start From amount'
                        //         : 'Please enter Product price';
                        //   }
                        //   return null;
                        // },
                      ),
                      SizedBox(height: 25),
                      Text(
                        'App Offer price',
                        style: AppTextStyles.mulish(color: AppColor.mildBlack),
                      ),
                      SizedBox(height: 10),
                      CommonContainer.fillingContainer(
                        text1: 'First App Offer',
                        readOnly: true,
                        verticalDivider: false,
                        controller: _offerController,
                      ),
                      // GestureDetector(
                      //   onTap: widget.allowOfferEdit
                      //       ? _showOfferBottomSheet
                      //       : null,
                      //   child: AbsorbPointer(
                      //     child: CommonContainer.fillingContainer(
                      //       imagePath: widget.allowOfferEdit
                      //           ? AppImages.downArrow
                      //           : null,
                      //       verticalDivider: false,
                      //       controller: _offerController,
                      //       readOnly: true,
                      //       context: context,
                      //     ),
                      //   ),
                      // ),
                      SizedBox(height: 10),
                      CommonContainer.fillingContainer(
                        keyboardType: TextInputType.number,
                        verticalDivider: false,
                        controller: _offerPriceController,
                        readOnly: !widget.allowOfferEdit,
                        onChanged: (value) {
                          final onlyDigits = value.replaceAll(
                            RegExp(r'[^0-9]'),
                            '',
                          );
                          if (onlyDigits.isEmpty) {
                            _offerPriceController.clear();
                            return;
                          }
                          final formatted = '$onlyDigits%';
                          _offerPriceController.value = TextEditingValue(
                            text: formatted,
                            selection: TextSelection.collapsed(
                              offset: formatted.length,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 25),
                      Text(
                        isServiceFlow
                            ? 'Service Description'
                            : 'Product Description',
                        style: AppTextStyles.mulish(color: AppColor.mildBlack),
                      ),
                      const SizedBox(height: 10),
                      CommonContainer.fillingContainer(
                        maxLine: 4,
                        verticalDivider: false,
                        controller: _descriptionController,
                        // validator: (value) {
                        //   if (value == null || value.isEmpty) {
                        //     return isServiceFlow
                        //         ? 'Please enter Service Description'
                        //         : 'Please enter Product Description';
                        //   }
                        //   return null;
                        // },
                      ),
                      if (!isServiceFlow) ...[
                        const SizedBox(height: 25),
                        Text(
                          'Door Delivery',
                          style: AppTextStyles.mulish(
                            color: AppColor.mildBlack,
                          ),
                        ),
                        const SizedBox(height: 10),
                        CommonContainer.fillingContainer(
                          imagePath: AppImages.drapDownImage,
                          verticalDivider: false,
                          controller: _doorDeliveryController,
                          isDropdown: true,
                          dropdownItems: cities,
                          context: context,
                          // validator: (value) => value == null || value.isEmpty
                          //     ? 'Please select Door Delivery option'
                          //     : null,
                        ),
                        const SizedBox(height: 30),
                      ],
                      const SizedBox(height: 30),
                      CommonContainer.button(
                        buttonColor: AppColor.black,

                        onTap: () async {
                          FocusScope.of(context).unfocus();

                          final priceText = _productPriceController.text.trim();
                          final price = int.tryParse(priceText);

                          final hasCategoryError =
                              _categoryController.text.trim().isEmpty;
                          final hasSubCategoryError =
                              _subCategoryController.text.trim().isEmpty;

                          setState(() {
                            _categoryHasError = hasCategoryError;
                            _subCategoryHasError = hasSubCategoryError;
                          });

                          final formValid = _formKey.currentState!.validate();

                          // if (!formValid ||
                          //     hasCategoryError ||
                          //     hasSubCategoryError) {
                          //   AppSnackBar.info(
                          //     context,
                          //     'Please fill all required fields correctly.',
                          //   );
                          //   return;
                          // }

                          bool success = false;
                          if (!isServiceFlow) {
                            final ddText = _doorDeliveryController.text.trim();

                            if (ddText.isEmpty) {
                              AppSnackBar.error(
                                context,
                                'Please select Door Delivery',
                              );
                              return;
                            }

                            // 'Yes' → true, anything else → false
                            _doorDelivery = ddText == 'Yes';
                          } else {
                            _doorDelivery =
                                false; // services currently no door-delivery flag
                          }

                          if (isServiceFlow) {
                            final serviceResponse = await ref
                                .read(serviceInfoNotifierProvider.notifier)
                                .saveServiceInfo(
                                  apiShopId: widget.shopId,
                                  ServiceId: widget.productId ?? '',
                                  title: _productNameController.text.trim(),
                                  tamilName: _productNameController.text.trim(),
                                  description:
                                      _descriptionController.text.trim(),
                                  startsAt: price ?? 0,
                                  offerLabel: _offerController.text.trim(),
                                  offerValue: _offerPriceController.text.trim(),
                                  durationMinutes: 60,
                                  categoryId: productCategorySlug,
                                  subCategory:
                                      _subCategoryController.text.trim(),
                                  tags: const [],
                                );

                            success = serviceResponse != null;

                            if (!success) {
                              final svcState = ref.read(
                                serviceInfoNotifierProvider,
                              );
                              if (svcState.error != null &&
                                  svcState.error!.isNotEmpty) {
                                AppSnackBar.error(context, svcState.error!);
                              } else {
                                AppSnackBar.error(
                                  context,
                                  'Service save failed. Please try again.',
                                );
                              }
                            }
                          } else {
                            // PRODUCT SAVE / UPDATE
                            final ddText = _doorDeliveryController.text.trim();
                            if (ddText.isEmpty) {
                              AppSnackBar.error(
                                context,
                                'Please select Door Delivery option',
                              );
                              return;
                            }
                            _doorDelivery = ddText == 'Yes';
                            success = await ref
                                .read(productNotifierProvider.notifier)
                                .addProduct(
                                  doorDelivery:
                                      _doorDelivery, //  use state variable
                                  productId: widget.productId,
                                  shopId: widget.shopId,
                                  category: _categoryController.text.trim(),
                                  subCategory:
                                      _subCategoryController.text.trim(),
                                  englishName:
                                      _productNameController.text.trim(),
                                  price: price ?? 0,
                                  offerLabel: _offerController.text.trim(),
                                  offerValue: _offerPriceController.text.trim(),
                                  description:
                                      _descriptionController.text.trim(),
                                );

                            if (!success) {
                              final err =
                                  ref.read(productNotifierProvider).error;
                              if (err != null && err.isNotEmpty) {
                                AppSnackBar.error(context, err);
                              } else {
                                AppSnackBar.error(
                                  context,
                                  'Something went wrong',
                                );
                              }
                            }
                          }

                          if (success) {
                            context.pushNamed(
                              AppRoutes.addProductList,
                              extra: {'isService': isServiceFlow},
                            );
                          }
                        },
                        text:
                            isLoading
                                ? const ThreeDotsLoader()
                                : Text(
                                  isEditFromAboutMe
                                      ? 'Update'
                                      : 'Save & Continue',
                                  style: AppTextStyles.mulish(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        imagePath: isLoading ? null : AppImages.rightStickArrow,
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
      ),
    );
  }
}
