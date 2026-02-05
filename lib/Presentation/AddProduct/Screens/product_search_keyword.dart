import 'dart:async';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tringo_vendor_new/Core/Const/app_logger.dart';
import 'package:tringo_vendor_new/Core/Utility/app_prefs.dart';
import 'package:tringo_vendor_new/Presentation/AddProduct/Controller/product_notifier.dart';

import '../../../Core/Const/app_color.dart';
import '../../../Core/Const/app_images.dart';
import '../../../Core/Offline_Data/Screens/offline_demo_screen.dart';
import '../../../Core/Session/registration_product_seivice.dart';
import '../../../Core/Session/registration_session.dart';
import '../../../Core/Utility/app_loader.dart';
import '../../../Core/Utility/app_snackbar.dart';
import '../../../Core/Utility/app_textstyles.dart';
import '../../../Core/Widgets/app_go_routes.dart';
import '../../../Core/Widgets/common_container.dart';
import '../../subscription/Screen/subscription_screen.dart';
import '../Controller/service_info_notifier.dart';
import '../../ShopInfo/Controller/shop_notifier.dart';
import 'add_product_list.dart';

class ProductSearchKeyword extends ConsumerStatefulWidget {
  final bool? isCompany;
  final bool? isService;

  const ProductSearchKeyword({super.key, this.isCompany, this.isService});

  bool get isCompanyResolved =>
      isCompany ??
      (RegistrationSession.instance.businessType == BusinessType.company);

  @override
  ConsumerState<ProductSearchKeyword> createState() =>
      _ProductSearchKeywordState();
}

class _ProductSearchKeywordState extends ConsumerState<ProductSearchKeyword> {
  final TextEditingController _searchKeywordController =
      TextEditingController();

  final List<String> _keywords = [];

  bool _showRecommended = false;

  // ✅ Suggestions
  final FocusNode _focusNode = FocusNode();
  Timer? _debounce;
  bool _showSuggestions = false;

  bool get isIndividualFlow {
    final session = RegistrationProductSeivice.instance;
    return session.businessType == BusinessType.individual;
  }

  @override
  void initState() {
    super.initState();

    // ✅ Fetch initial recommended keywords on screen open based on product/service
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bool isServiceFlow =
          widget.isService ??
          RegistrationProductSeivice.instance.isServiceBusiness;

      ref
          .read(shopCategoryNotifierProvider.notifier)
          .fetchKeyWords(
            type: isServiceFlow ? "service" : "product",
            query: "", // recommended/default
          );
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchKeywordController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _addKeyword(String keyword) {
    final text = keyword.trim();
    if (text.isEmpty) return;

    if (_keywords.contains(text)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Keyword already added')));
      return;
    }

    if (_keywords.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You can only add up to 5 keywords')),
      );
      return;
    }

    setState(() => _keywords.add(text));
  }

  void _onSubmitted() {
    _addKeyword(_searchKeywordController.text);
    _searchKeywordController.clear();
    setState(() => _showSuggestions = false);
    _debounce?.cancel();
  }

  void _removeKeyword(String keyword) {
    setState(() => _keywords.remove(keyword));
  }

  @override
  Widget build(BuildContext context) {
    final bool isService =
        widget.isService ??
        RegistrationProductSeivice.instance.isServiceBusiness;

    AppLogger.log.i('Search KeyWords - isService: $isService');

    final bool isProduct = !isService;
    final bool isCompany = widget.isCompanyResolved;

    // ✅ API type to send
    final String keywordType = isService ? "service" : "product";

    final serviceState = ref.watch(serviceInfoNotifierProvider);
    final productState = ref.watch(productNotifierProvider);

    final bool isLoading =
        isService ? serviceState.isLoading : productState.isLoading;

    // ✅ Keywords state (from shop notifier)
    final shopState = ref.watch(shopCategoryNotifierProvider);
    final apiKeywords = shopState.categoryKeywordsResponse?.data ?? [];

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        setState(() => _showSuggestions = false);
      },
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      CommonContainer.topLeftArrow(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddProductList(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 50),
                      Text(
                        'Register Shop',
                        style: AppTextStyles.mulish(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: AppColor.mildBlack,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '-',
                        style: AppTextStyles.mulish(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
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
                  image: AppImages.addProduct,
                  text: isProduct ? 'Add Product' : 'Add Service',
                  imageHeight: 85,
                  gradientColor: AppColor.lavenderMist,
                  value: 0.8,
                ),

                const SizedBox(height: 30),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CommonContainer.containerTitle(
                        context: context,
                        title: 'Search Keyword',
                        image: AppImages.iImage,
                        infoMessage:
                            'Add relevant search keywords customers might use to find your shop.',
                      ),

                      const SizedBox(height: 10),

                      // ✅ Typing Field with API suggestions
                      TextField(
                        focusNode: _focusNode,
                        controller: _searchKeywordController,
                        enabled: _keywords.length < 5,
                        onSubmitted: (_) => _onSubmitted(),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppColor.lowGery1,
                          hintText:
                              _keywords.length >= 5
                                  ? 'Keyword limit reached'
                                  : 'Enter keyword',
                          hintStyle: AppTextStyles.mulish(
                            fontSize: 14,
                            color: AppColor.gray84,
                          ),
                          suffixIcon:
                              _searchKeywordController.text.isNotEmpty
                                  ? IconButton(
                                    icon: const Icon(
                                      Icons.clear,
                                      color: Colors.grey,
                                    ),
                                    onPressed: () {
                                      _searchKeywordController.clear();
                                      setState(() => _showSuggestions = false);
                                      _debounce?.cancel();
                                    },
                                  )
                                  : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                        ),
                        onChanged: (val) {
                          setState(() {});
                          final q = val.trim();

                          if (q.isEmpty) {
                            setState(() => _showSuggestions = false);
                            _debounce?.cancel();
                            return;
                          }

                          setState(() => _showSuggestions = true);

                          _debounce?.cancel();
                          _debounce = Timer(
                            const Duration(milliseconds: 350),
                            () {
                              ref
                                  .read(shopCategoryNotifierProvider.notifier)
                                  .fetchKeyWords(
                                    type: keywordType, // ✅ product/service
                                    query: q,
                                  );
                            },
                          );
                        },
                      ),

                      // ✅ Suggestions dropdown
                      if (_showSuggestions && _focusNode.hasFocus)
                        Container(
                          margin: const EdgeInsets.only(top: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColor.borderGray),
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 10,
                                color: Colors.black.withOpacity(0.06),
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child:
                              shopState.isKeyWordsLoading
                                  ? Padding(
                                    padding: EdgeInsets.all(12),
                                    child: Center(
                                      child: AppLoader.circularLoader(
                                        color: AppColor.darkBlue,
                                      ),
                                    ),
                                  )
                                  : (apiKeywords.isEmpty
                                      ? const Padding(
                                        padding: EdgeInsets.all(12),
                                        child: Text("No suggestions found"),
                                      )
                                      : ListView.separated(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount:
                                            apiKeywords.length > 6
                                                ? 6
                                                : apiKeywords.length,
                                        separatorBuilder:
                                            (_, __) => const Divider(height: 1),
                                        itemBuilder: (context, index) {
                                          final keyword = apiKeywords[index];
                                          return ListTile(
                                            dense: true,
                                            title: Text(keyword),
                                            onTap: () {
                                              _searchKeywordController.text =
                                                  keyword;
                                              _searchKeywordController
                                                      .selection =
                                                  TextSelection.collapsed(
                                                    offset: keyword.length,
                                                  );

                                              _addKeyword(keyword);

                                              setState(
                                                () => _showSuggestions = false,
                                              );
                                              FocusScope.of(context).unfocus();
                                            },
                                          );
                                        },
                                      )),
                        ),

                      const SizedBox(height: 10),
                      Text(
                        'Maximum 5 keywords acceptable',
                        style: AppTextStyles.mulish(
                          fontSize: 12,
                          color: AppColor.darkGrey,
                        ),
                      ),
                      const SizedBox(height: 15),

                      // ✅ Added keywords
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children:
                            _keywords.map((keyword) {
                              return DottedBorder(
                                borderType: BorderType.RRect,
                                radius: const Radius.circular(12),
                                color: AppColor.black,
                                strokeWidth: 1,
                                dashPattern: const [3, 2],
                                padding: const EdgeInsets.all(1),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 9,
                                    horizontal: 16,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        keyword,
                                        style: AppTextStyles.mulish(
                                          fontWeight: FontWeight.w600,
                                          color: AppColor.black,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      GestureDetector(
                                        onTap: () => _removeKeyword(keyword),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: AppColor.whiteSmoke,
                                            borderRadius: BorderRadius.circular(
                                              9,
                                            ),
                                          ),
                                          padding: const EdgeInsets.all(9.5),
                                          child: Image.asset(
                                            AppImages.closeImage,
                                            height: 11,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                      ),

                      const SizedBox(height: 20),

                      // ✅ Toggle Recommended
                      GestureDetector(
                        onTap: () async {
                          setState(() => _showRecommended = !_showRecommended);

                          if (_showRecommended) {
                            await ref
                                .read(shopCategoryNotifierProvider.notifier)
                                .fetchKeyWords(type: keywordType, query: "");
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColor.brightBlue,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 5,
                            ),
                            child: Text(
                              _showRecommended
                                  ? 'Hide Recommended Keywords'
                                  : 'View Recommended Keywords',
                              style: AppTextStyles.mulish(
                                fontWeight: FontWeight.w700,
                                color: AppColor.white,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ✅ Recommended Keywords from API
                      if (_showRecommended)
                        shopState.isKeyWordsLoading
                            ? Padding(
                              padding: EdgeInsets.all(12),
                              child: Center(
                                child: AppLoader.circularLoader(
                                  color: AppColor.darkBlue,
                                ),
                              ),
                            )
                            : Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children:
                                  apiKeywords.map((keyword) {
                                    return GestureDetector(
                                      onTap: () => _addKeyword(keyword),
                                      child: DottedBorder(
                                        borderType: BorderType.RRect,
                                        radius: const Radius.circular(12),
                                        color: AppColor.borderGray,
                                        strokeWidth: 1,
                                        dashPattern: const [3, 2],
                                        padding: const EdgeInsets.all(1),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 9,
                                            horizontal: 16,
                                          ),
                                          child: Text(
                                            keyword,
                                            style: AppTextStyles.mulish(
                                              color: AppColor.gray84,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                            ),

                      const SizedBox(height: 30),

                      // ✅ Preview Shop
                      CommonContainer.button(
                        buttonColor: AppColor.black,
                        onTap: () async {
                          FocusScope.of(context).unfocus();

                          if (_keywords.isEmpty) {
                            AppSnackBar.error(
                              context,
                              'Please add at least one keyword',
                            );
                            return;
                          }

                          final bool isServiceFlow = isService;
                          bool success = false;

                          // API call (service / product)
                          if (isServiceFlow) {
                            success = await ref
                                .read(serviceInfoNotifierProvider.notifier)
                                .serviceSearchWords(keywords: _keywords);
                          } else {
                            success = await ref
                                .read(productNotifierProvider.notifier)
                                .updateProductSearchWords(keywords: _keywords);
                          }

                          final productStateNow = ref.read(
                            productNotifierProvider,
                          );
                          final serviceStateNow = ref.read(
                            serviceInfoNotifierProvider,
                          );

                          if (!success) {
                            if (!isServiceFlow &&
                                productStateNow.error != null) {
                              AppSnackBar.error(
                                context,
                                productStateNow.error!,
                              );
                            } else if (isServiceFlow &&
                                serviceStateNow.error != null) {
                              AppSnackBar.error(
                                context,
                                serviceStateNow.error!,
                              );
                            } else {
                              AppSnackBar.error(context, 'Failed. Try again.');
                            }
                            return;
                          }

                          // OFFLINE FLOW
                          final offlineSessionId =
                              await AppPrefs.getOfflineSessionId();
                          final hasOfflineSession =
                              offlineSessionId != null &&
                              offlineSessionId.trim().isNotEmpty;

                          if (hasOfflineSession) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => OfflineDemoScreen(),
                              ),
                            );
                            return;
                          }

                          // SUBSCRIPTION CHECK
                          final regSession = RegistrationSession.instance;
                          final productSession =
                              RegistrationProductSeivice.instance;

                          final shouldGoToSubscription =
                              regSession.isCompanyBusiness &&
                              productSession.isNonPremium;

                          if (shouldGoToSubscription) {
                            final id = await AppPrefs.getBusinessProfileId();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => SubscriptionScreen(
                                      businessProfileId: (id ?? '').toString(),
                                    ),
                              ),
                            );
                            return;
                          }

                          // SHOP DETAILS NAVIGATION
                          final shopId =
                              isServiceFlow
                                  ? serviceStateNow
                                      .serviceInfoResponse
                                      ?.data
                                      .shopId
                                  : productStateNow
                                      .productResponse
                                      ?.data
                                      .shopId;

                          context.goNamed(
                            AppRoutes.shopsDetails,
                            extra: <String, dynamic>{
                              'backDisabled': true,
                              'fromSubscriptionSkip': false,
                              'shopId': shopId,
                            },
                          );
                        },
                        text:
                            isLoading
                                ? const ThreeDotsLoader()
                                : Text(
                                  'Preview Shop',
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

// import 'package:dotted_border/dotted_border.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import 'package:tringo_vendor_new/Core/Const/app_logger.dart';
// import 'package:tringo_vendor_new/Core/Utility/app_prefs.dart';
// import 'package:tringo_vendor_new/Presentation/AddProduct/Controller/product_notifier.dart';
// import '../../../Core/Const/app_color.dart';
// import '../../../Core/Const/app_images.dart';
// import '../../../Core/Offline_Data/Screens/offline_demo_screen.dart';
// import '../../../Core/Session/registration_product_seivice.dart';
// import '../../../Core/Session/registration_session.dart';
// import '../../../Core/Utility/app_loader.dart';
// import '../../../Core/Utility/app_snackbar.dart';
// import '../../../Core/Utility/app_textstyles.dart';
// import '../../../Core/Widgets/app_go_routes.dart';
// import '../../../Core/Widgets/common_container.dart';
// import '../../AddProduct/Screens/product_category_screens.dart';
// import '../../subscription/Screen/subscription_screen.dart';
// import '../Controller/service_info_notifier.dart';
// import 'add_product_list.dart';
//
// class ProductSearchKeyword extends ConsumerStatefulWidget {
//   final bool? isCompany;
//   final bool? isService;
//
//   const ProductSearchKeyword({super.key, this.isCompany, this.isService});
//   bool get isCompanyResolved =>
//       isCompany ??
//       (RegistrationSession.instance.businessType == BusinessType.company);
//
//   @override
//   ConsumerState<ProductSearchKeyword> createState() =>
//       _ProductSearchKeywordState();
// }
//
// class _ProductSearchKeywordState extends ConsumerState<ProductSearchKeyword> {
//   final TextEditingController _searchKeywordController =
//       TextEditingController();
//
//   final List<String> _keywords = []; // Only added/typed ones
//   final List<String> _recommendedKeywords = [
//     'Face tissue',
//     'Paper product',
//     'Bathroom product',
//     'Paper',
//     'face towel',
//   ];
//
//   bool _showRecommended = false;
//
//   bool get isIndividualFlow {
//     final session = RegistrationProductSeivice.instance;
//     return session.businessType == BusinessType.individual;
//   }
//
//   void _addKeyword(String keyword) {
//     final text = keyword.trim();
//
//     if (text.isEmpty) return;
//
//     if (_keywords.contains(text)) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text('Keyword already added')));
//       return;
//     }
//
//     if (_keywords.length >= 5) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('You can only add up to 5 keywords')),
//       );
//       return;
//     }
//
//     setState(() => _keywords.add(text));
//   }
//
//   void _onSubmitted() {
//     _addKeyword(_searchKeywordController.text);
//     _searchKeywordController.clear();
//   }
//
//   void _removeKeyword(String keyword) {
//     setState(() => _keywords.remove(keyword));
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // final isProduct = RegistrationProductSeivice.instance.isProductBusiness;
//     // final isService = RegistrationProductSeivice.instance.isServiceBusiness;
//
//     final bool isService =
//         widget.isService ??
//         RegistrationProductSeivice.instance.isServiceBusiness;
//     AppLogger.log.i('Search KeyWords - $isService');
//     final isProduct = !isService;
//     final bool isCompany = widget.isCompanyResolved;
//
//     final serviceState = ref.watch(serviceInfoNotifierProvider);
//     final productState = ref.watch(productNotifierProvider);
//
//     final bool isLoading =
//         isService ? serviceState.isLoading : productState.isLoading;
//     return Scaffold(
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Header
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 child: Row(
//                   children: [
//                     CommonContainer.topLeftArrow(
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => AddProductList(),
//                           ),
//                         );
//                       },
//                       // onTap: () => Navigator.pop(context),
//                     ),
//                     SizedBox(width: 50),
//                     Text(
//                       'Register Shop',
//                       style: AppTextStyles.mulish(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w400,
//                         color: AppColor.mildBlack,
//                       ),
//                     ),
//                     SizedBox(width: 5),
//                     Text(
//                       '-',
//                       style: AppTextStyles.mulish(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w400,
//                         color: AppColor.mildBlack,
//                       ),
//                     ),
//                     SizedBox(width: 5),
//                     Text(
//                       isIndividualFlow ? 'Individual' : 'Company',
//                       style: AppTextStyles.mulish(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600,
//                         color: AppColor.mildBlack,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               SizedBox(height: 35),
//
//               CommonContainer.registerTopContainer(
//                 image: AppImages.addProduct,
//                 text: isProduct ? 'Add Product' : 'Add Service',
//                 imageHeight: 85,
//                 gradientColor: AppColor.lavenderMist,
//                 value: 0.8,
//               ),
//
//               SizedBox(height: 30),
//
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     //  Search Keyword title
//                     CommonContainer.containerTitle(
//                       context: context,
//                       title: 'Search Keyword',
//                       image: AppImages.iImage,
//                       infoMessage:
//                           'Add relevant search keywords customers might use to find your shop.',
//                     ),
//
//                     SizedBox(height: 10),
//
//                     // Typing Field
//                     TextField(
//                       controller: _searchKeywordController,
//                       enabled: _keywords.length < 5,
//                       onSubmitted: (_) => _onSubmitted(),
//                       decoration: InputDecoration(
//                         filled: true,
//                         fillColor: AppColor.lowGery1,
//                         hintText:
//                             _keywords.length >= 5
//                                 ? 'Keyword limit reached'
//                                 : 'Enter keyword',
//                         hintStyle: AppTextStyles.mulish(
//                           fontSize: 14,
//                           color: AppColor.gray84,
//                         ),
//                         suffixIcon:
//                             _searchKeywordController.text.isNotEmpty
//                                 ? IconButton(
//                                   icon: const Icon(
//                                     Icons.clear,
//                                     color: Colors.grey,
//                                   ),
//                                   onPressed:
//                                       () => _searchKeywordController.clear(),
//                                 )
//                                 : null,
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(16),
//                         ),
//                         contentPadding: const EdgeInsets.symmetric(
//                           vertical: 12,
//                           horizontal: 16,
//                         ),
//                       ),
//                       onChanged: (_) => setState(() {}),
//                     ),
//
//                     SizedBox(height: 10),
//                     Text(
//                       'Maximum 5 keywords acceptable',
//                       style: AppTextStyles.mulish(
//                         fontSize: 12,
//                         color: AppColor.darkGrey,
//                       ),
//                     ),
//                     SizedBox(height: 15),
//
//                     // Show typed/added keywords only
//                     Wrap(
//                       spacing: 10,
//                       runSpacing: 10,
//                       children:
//                           _keywords.map((keyword) {
//                             return DottedBorder(
//                               borderType: BorderType.RRect,
//                               radius: Radius.circular(12),
//                               color: AppColor.black,
//                               strokeWidth: 1,
//                               dashPattern: [3, 2],
//                               padding: EdgeInsets.all(1),
//                               child: Padding(
//                                 padding: EdgeInsets.symmetric(
//                                   vertical: 9,
//                                   horizontal: 16,
//                                 ),
//                                 child: Row(
//                                   mainAxisSize: MainAxisSize.min,
//                                   children: [
//                                     Text(
//                                       keyword,
//                                       style: AppTextStyles.mulish(
//                                         fontWeight: FontWeight.w600,
//                                         color: AppColor.black,
//                                       ),
//                                     ),
//                                     SizedBox(width: 10),
//                                     GestureDetector(
//                                       onTap: () => _removeKeyword(keyword),
//                                       child: Container(
//                                         decoration: BoxDecoration(
//                                           color: AppColor.whiteSmoke,
//                                           borderRadius: BorderRadius.circular(
//                                             9,
//                                           ),
//                                         ),
//                                         padding: const EdgeInsets.all(9.5),
//                                         child: Image.asset(
//                                           AppImages.closeImage,
//                                           height: 11,
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             );
//                           }).toList(),
//                     ),
//
//                     SizedBox(height: 20),
//
//                     //  Toggle Button (show/hide recommended)
//                     GestureDetector(
//                       onTap:
//                           () => setState(() {
//                             _showRecommended = !_showRecommended;
//                           }),
//                       child: Container(
//                         decoration: BoxDecoration(
//                           color: AppColor.brightBlue,
//                           borderRadius: BorderRadius.circular(50),
//                         ),
//                         child: Padding(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 12,
//                             vertical: 5,
//                           ),
//                           child: Text(
//                             _showRecommended
//                                 ? 'Hide Recommended Keywords'
//                                 : 'View Recommended Keywords',
//                             style: AppTextStyles.mulish(
//                               fontWeight: FontWeight.w700,
//                               color: AppColor.white,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//
//                     SizedBox(height: 20),
//
//                     //  Recommended Keywords (only when toggled)
//                     if (_showRecommended)
//                       Wrap(
//                         spacing: 10,
//                         runSpacing: 10,
//                         children:
//                             _recommendedKeywords.map((keyword) {
//                               return GestureDetector(
//                                 onTap: () => _addKeyword(keyword),
//                                 child: DottedBorder(
//                                   borderType: BorderType.RRect,
//                                   radius: const Radius.circular(12),
//                                   color: AppColor.borderGray,
//                                   strokeWidth: 1,
//                                   dashPattern: const [3, 2],
//                                   padding: const EdgeInsets.all(1),
//                                   child: Padding(
//                                     padding: const EdgeInsets.symmetric(
//                                       vertical: 9,
//                                       horizontal: 16,
//                                     ),
//                                     child: Text(
//                                       keyword,
//                                       style: AppTextStyles.mulish(
//                                         color: AppColor.gray84,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               );
//                             }).toList(),
//                       ),
//
//                     SizedBox(height: 30),
//
//                     CommonContainer.button(
//                       buttonColor: AppColor.black,
//
//                       // onTap: () async {
//                       //   FocusScope.of(context).unfocus();
//                       //
//                       //   // 🔹 Basic validation
//                       //   if (_keywords.isEmpty) {
//                       //     AppSnackBar.error(
//                       //       context,
//                       //       'Please add at least one keyword',
//                       //     );
//                       //     return;
//                       //   }
//                       //
//                       //   final bool isServiceFlow = isService;
//                       //
//                       //   bool success = false;
//                       //
//                       //   // 🔹 Call correct API (service / product)
//                       //   if (isServiceFlow) {
//                       //     success = await ref
//                       //         .read(serviceInfoNotifierProvider.notifier)
//                       //         .serviceSearchWords(keywords: _keywords);
//                       //   } else {
//                       //     success = await ref
//                       //         .read(productNotifierProvider.notifier)
//                       //         .updateProductSearchWords(keywords: _keywords);
//                       //   }
//                       //
//                       //   final productState = ref.read(productNotifierProvider);
//                       //   final serviceState = ref.read(
//                       //     serviceInfoNotifierProvider,
//                       //   );
//                       //
//                       //   // ❌ Handle errors (only for real API errors)
//                       //   if (!success) {
//                       //     if (!isServiceFlow && productState.error != null) {
//                       //       AppSnackBar.error(context, productState.error!);
//                       //     } else if (isServiceFlow &&
//                       //         serviceState.error != null) {
//                       //       AppSnackBar.error(context, serviceState.error!);
//                       //     } else {
//                       //       AppSnackBar.error(context, "Failed. Try again.");
//                       //     }
//                       //     return;
//                       //   }
//                       //
//                       //   // ✅ OFFLINE CHECK (important)
//                       //   // If offline, your notifier already enqueued sqlite and returned true.
//                       //   // So here we must redirect to Offline Demo screen.
//                       //   final offlineSessionId =
//                       //       await AppPrefs.getOfflineSessionId();
//                       //   final hasOfflineSession =
//                       //       offlineSessionId != null &&
//                       //       offlineSessionId.trim().isNotEmpty;
//                       //
//                       //   if (hasOfflineSession) {
//                       //     Navigator.push(
//                       //       context,
//                       //       MaterialPageRoute(
//                       //         builder: (_) => OfflineDemoScreen(),
//                       //       ),
//                       //     );
//                       //     return;
//                       //   }
//                       //
//                       //   // ================================
//                       //   //        ONLINE SUCCESS FLOW
//                       //   // ================================
//                       //   final productSession =
//                       //       RegistrationProductSeivice.instance;
//                       //   final regSession = RegistrationSession.instance;
//                       //
//                       //   // Company + Non-premium → Subscription Screen (ONLINE only)
//                       //   if (regSession.isCompanyBusiness &&
//                       //       productSession.isNonPremium) {
//                       //     final id = await AppPrefs.getBusinessProfileId();
//                       //
//                       //     Navigator.push(
//                       //       context,
//                       //       MaterialPageRoute(
//                       //         builder:
//                       //             (context) => SubscriptionScreen(
//                       //               businessProfileId: (id ?? "").toString(),
//                       //             ),
//                       //       ),
//                       //     );
//                       //     return;
//                       //   }
//                       //
//                       //   // ================================
//                       //   //      ONLINE NAVIGATION
//                       //   // ================================
//                       //   if (isServiceFlow) {
//                       //     final shopId =
//                       //         serviceState.serviceInfoResponse?.data.shopId;
//                       //     context.goNamed(
//                       //       AppRoutes.shopsDetails,
//                       //       extra: <String, dynamic>{
//                       //         'backDisabled': true,
//                       //         'fromSubscriptionSkip': false,
//                       //         'shopId': shopId,
//                       //       },
//                       //     );
//                       //   } else {
//                       //     final shopId =
//                       //         productState.productResponse?.data.shopId;
//                       //     context.goNamed(
//                       //       AppRoutes.shopsDetails,
//                       //       extra: <String, dynamic>{
//                       //         'backDisabled': true,
//                       //         'fromSubscriptionSkip': false,
//                       //         'shopId': shopId,
//                       //       },
//                       //     );
//                       //     // context.goNamed(
//                       //     //   AppRoutes.shopsDetails,
//                       //     //   extra: {
//                       //     //     'backDisabled': true,
//                       //     //     'fromSubscriptionSkip': false,
//                       //     //     'shopId': shopId,
//                       //     //   },
//                       //     // );
//                       //   }
//                       // },
//                       onTap: () async {
//                         FocusScope.of(context).unfocus();
//
//                         // -----------------------------
//                         // Basic validation
//                         // -----------------------------
//                         if (_keywords.isEmpty) {
//                           AppSnackBar.error(
//                             context,
//                             'Please add at least one keyword',
//                           );
//                           return;
//                         }
//
//                         final bool isServiceFlow = isService;
//                         bool success = false;
//
//                         // -----------------------------
//                         // API call (service / product)
//                         // -----------------------------
//                         if (isServiceFlow) {
//                           success = await ref
//                               .read(serviceInfoNotifierProvider.notifier)
//                               .serviceSearchWords(keywords: _keywords);
//                         } else {
//                           success = await ref
//                               .read(productNotifierProvider.notifier)
//                               .updateProductSearchWords(keywords: _keywords);
//                         }
//
//                         final productState = ref.read(productNotifierProvider);
//                         final serviceState = ref.read(
//                           serviceInfoNotifierProvider,
//                         );
//
//                         // -----------------------------
//                         // API error handling
//                         // -----------------------------
//                         if (!success) {
//                           if (!isServiceFlow && productState.error != null) {
//                             AppSnackBar.error(context, productState.error!);
//                           } else if (isServiceFlow &&
//                               serviceState.error != null) {
//                             AppSnackBar.error(context, serviceState.error!);
//                           } else {
//                             AppSnackBar.error(context, 'Failed. Try again.');
//                           }
//                           return;
//                         }
//
//                         // -----------------------------
//                         // OFFLINE FLOW
//                         // -----------------------------
//                         final offlineSessionId =
//                             await AppPrefs.getOfflineSessionId();
//                         final hasOfflineSession =
//                             offlineSessionId != null &&
//                             offlineSessionId.trim().isNotEmpty;
//
//                         if (hasOfflineSession) {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (_) => OfflineDemoScreen(),
//                             ),
//                           );
//                           return;
//                         }
//
//                         // -----------------------------
//                         // SUBSCRIPTION CHECK
//                         // (SERVICE + PRODUCT)
//                         // -----------------------------
//                         final regSession = RegistrationSession.instance;
//                         final productSession =
//                             RegistrationProductSeivice.instance;
//
//                         final shouldGoToSubscription =
//                             regSession.isCompanyBusiness &&
//                             productSession.isNonPremium;
//
//                         if (shouldGoToSubscription) {
//                           final id = await AppPrefs.getBusinessProfileId();
//
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder:
//                                   (_) => SubscriptionScreen(
//                                     businessProfileId: (id ?? '').toString(),
//                                   ),
//                             ),
//                           );
//                           return;
//                         }
//
//                         // -----------------------------
//                         // SHOP DETAILS NAVIGATION
//                         // -----------------------------
//                         final shopId =
//                             isServiceFlow
//                                 ? serviceState.serviceInfoResponse?.data.shopId
//                                 : productState.productResponse?.data.shopId;
//
//                         context.goNamed(
//                           AppRoutes.shopsDetails,
//                           extra: <String, dynamic>{
//                             'backDisabled': true,
//                             'fromSubscriptionSkip': false,
//                             'shopId': shopId,
//                           },
//                         );
//                       },
//
//                       text:
//                           isLoading
//                               ? ThreeDotsLoader()
//                               : Text(
//                                 'Preview Shop',
//                                 style: AppTextStyles.mulish(
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.w700,
//                                 ),
//                               ),
//                       imagePath: isLoading ? null : AppImages.rightStickArrow,
//                       imgHeight: 20,
//                     ),
//
//                     SizedBox(height: 36),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
