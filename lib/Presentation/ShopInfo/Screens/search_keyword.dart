import 'dart:async';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tringo_vendor_new/Core/Utility/app_prefs.dart';
import 'package:tringo_vendor_new/Presentation/ShopInfo/Controller/shop_notifier.dart';

import '../../../Core/Const/app_color.dart';
import '../../../Core/Const/app_images.dart';
import '../../../Core/Session/registration_product_seivice.dart';
import '../../../Core/Session/registration_session.dart';
import '../../../Core/Utility/app_loader.dart';
import '../../../Core/Utility/app_snackbar.dart';
import '../../../Core/Utility/app_textstyles.dart';
import '../../../Core/Widgets/app_go_routes.dart';
import '../../../Core/Widgets/common_container.dart';

class SearchKeyword extends ConsumerStatefulWidget {
  final String? page;
  final bool? isIndividual;
  const SearchKeyword({super.key, this.isIndividual, this.page});

  @override
  ConsumerState<SearchKeyword> createState() => _SearchKeywordState();
}

class _SearchKeywordState extends ConsumerState<SearchKeyword> {
  final TextEditingController _searchKeywordController =
      TextEditingController();
  final FocusNode _focusNode = FocusNode();

  final List<String> _keywords = [];

  Timer? _debounce;
  bool _showSuggestions = false;
  bool _showRecommended = false;

  bool get isIndividualFlow {
    final session = RegistrationProductSeivice.instance;
    return session.businessType == BusinessType.individual;
  }

  @override
  void initState() {
    super.initState();

    // ✅ Fetch initial recommended keywords on screen open
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(shopCategoryNotifierProvider.notifier)
          .fetchKeyWords(
            type: "shop",
            query: "", // empty = recommended/default
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

  void _onSearchChanged(String val) {
    setState(() {});

    final q = val.trim();

    // hide if empty
    if (q.isEmpty) {
      setState(() => _showSuggestions = false);
      _debounce?.cancel();
      return;
    }

    // show suggestions
    setState(() => _showSuggestions = true);

    // debounce API call
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      ref
          .read(shopCategoryNotifierProvider.notifier)
          .fetchKeyWords(type: "shop", query: q);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(shopCategoryNotifierProvider);
    final apiKeywords = state.categoryKeywordsResponse?.data ?? [];

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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
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
                  image: AppImages.shopInfoImage,
                  text: 'Shop Info',
                  imageHeight: 85,
                  gradientColor: AppColor.lightSkyBlue,
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
                            'Add relevant keywords so customers can easily find your shop in search results.',
                      ),

                      const SizedBox(height: 10),

                      // ✅ Search field
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
                        onChanged: _onSearchChanged,
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
                              state.isKeyWordsLoading
                                  ? Padding(
                                    padding: EdgeInsets.all(12),
                                    child: Center(
                                      child: AppLoader.circularLoader(),
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

                      // ✅ Selected keywords chips
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

                      // ✅ Toggle recommended
                      GestureDetector(
                        onTap: () async {
                          setState(() => _showRecommended = !_showRecommended);

                          if (_showRecommended) {
                            await ref
                                .read(shopCategoryNotifierProvider.notifier)
                                .fetchKeyWords(type: "shop", query: "");
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

                      // ✅ Recommended list (API)
                      if (_showRecommended)
                        state.isKeyWordsLoading
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

                      // ✅ Save & Continue
                      CommonContainer.button(
                        buttonColor: AppColor.black,
                        onTap: () async {
                          if (_keywords.isEmpty) {
                            AppSnackBar.error(
                              context,
                              'Please add at least one keyword',
                            );
                            return;
                          }

                          final notifier = ref.read(
                            shopCategoryNotifierProvider.notifier,
                          );
                          final currentState = ref.read(
                            shopCategoryNotifierProvider,
                          );

                          final success = await notifier.searchKeywords(
                            keywords: _keywords,
                          );

                          if (success) {
                            final shopId = await AppPrefs.getSopId();
                            if (widget.page == 'shopDetailsEdit') {
                              final businessProfileId =
                                  await AppPrefs.getBusinessProfileId();
                              context.goNamed(
                                AppRoutes.shopDetailsEdit,
                                extra: <String, dynamic>{
                                  'shopId': shopId,
                                  'businessProfileId': businessProfileId,
                                },
                              );
                            } else {
                              context.pushNamed(
                                AppRoutes.productCategoryScreens,
                                extra: 'SearchKeyword',
                              );
                            }
                          } else {
                            final errorMsg =
                                currentState.error ??
                                'Failed to save keywords. Try again.';
                            AppSnackBar.error(context, errorMsg);
                          }
                        },
                        text:
                            state.isLoading
                                ? const ThreeDotsLoader()
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

// import 'dart:async';
//
// import 'package:dotted_border/dotted_border.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import 'package:tringo_vendor_new/Core/Utility/app_prefs.dart';
// import 'package:tringo_vendor_new/Presentation/ShopInfo/Controller/shop_notifier.dart';
//
// import '../../../Core/Const/app_color.dart';
// import '../../../Core/Const/app_images.dart';
// import '../../../Core/Session/registration_product_seivice.dart';
// import '../../../Core/Session/registration_session.dart';
// import '../../../Core/Utility/app_loader.dart';
// import '../../../Core/Utility/app_snackbar.dart';
// import '../../../Core/Utility/app_textstyles.dart';
// import '../../../Core/Widgets/app_go_routes.dart';
// import '../../../Core/Widgets/common_container.dart';
//
// class SearchKeyword extends ConsumerStatefulWidget {
//   final String? page;
//   final bool? isIndividual;
//   const SearchKeyword({super.key, this.isIndividual, this.page});
//
//   @override
//   ConsumerState<SearchKeyword> createState() => _SearchKeywordState();
// }
//
// class _SearchKeywordState extends ConsumerState<SearchKeyword> {
//   final TextEditingController _searchKeywordController =
//       TextEditingController();
//
//   final List<String> _keywords = [];
//   // final List<String> _recommendedKeywords = [
//   //   'Saravana store',
//   //   'Textile near me',
//   //   'Tshirt Sale',
//   //   'Mens Clothing',
//   //   'Trending costumes',
//   // ];
//   int selectedIndex = 0;
//   bool _showRecommended = false;
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
//   bool get isIndividualFlow {
//     final session = RegistrationProductSeivice.instance;
//     return session.businessType == BusinessType.individual;
//   }
//
//   final FocusNode _focusNode = FocusNode();
//   Timer? _debounce;
//   bool _showSuggestions = false;
//
//   @override
//   void dispose() {
//     _debounce?.cancel();
//     _searchKeywordController.dispose();
//     _focusNode.dispose();
//     super.dispose();
//   }
//   @override
//   void initState() {
//     super.initState();
//
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       ref.read(shopCategoryNotifierProvider.notifier).fetchKeyWords(
//         type: "shop",
//         query: "", // empty = default/recommended list
//       );
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final state = ref.watch(shopCategoryNotifierProvider);
//     final apiKeywords = state.categoryKeywordsResponse?.data ?? [];
//
//     // final bool isIndividualFlow = widget.isIndividual ?? true;
//     return Scaffold(
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 child: Row(
//                   children: [
//                     CommonContainer.topLeftArrow(
//                       onTap: () => Navigator.pop(context),
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
//                 image: AppImages.shopInfoImage,
//                 text: 'Shop Info',
//                 imageHeight: 85,
//                 gradientColor: AppColor.lightSkyBlue,
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
//                           'Add relevant keywords so customers can easily find your shop in search results.',
//                     ),
//
//                     SizedBox(height: 10),
//
//                     // Typing Field
//                     TextField(
//                       focusNode: _focusNode,
//
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
//                       onChanged: (val) {
//                         setState(() {});
//
//                         final q = val.trim();
//
//                         // hide if empty
//                         if (q.isEmpty) {
//                           setState(() => _showSuggestions = false);
//                           return;
//                         }
//
//                         // show suggestions
//                         setState(() => _showSuggestions = true);
//
//                         // debounce API call
//                         _debounce?.cancel();
//                         _debounce = Timer(const Duration(milliseconds: 350), () {
//                           ref
//                               .read(shopCategoryNotifierProvider.notifier)
//                               .fetchKeyWords(
//                                 type:
//                                     "shop", // change if backend expects category
//                                 query: q,
//                               );
//                         });
//                       },
//                     ),
//                     if (_showSuggestions && _focusNode.hasFocus)
//                       Container(
//                         margin: const EdgeInsets.only(top: 8),
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(12),
//                           border: Border.all(color: AppColor.borderGray),
//                           boxShadow: [
//                             BoxShadow(
//                               blurRadius: 10,
//                               color: Colors.black.withOpacity(0.06),
//                               offset: const Offset(0, 4),
//                             ),
//                           ],
//                         ),
//                         child:
//                             state.isKeyWordsLoading
//                                 ? const Padding(
//                                   padding: EdgeInsets.all(12),
//                                   child: Center(
//                                     child: CircularProgressIndicator(),
//                                   ),
//                                 )
//                                 : (apiKeywords.isEmpty
//                                     ? const Padding(
//                                       padding: EdgeInsets.all(12),
//                                       child: Text("No suggestions found"),
//                                     )
//                                     : ListView.separated(
//                                       shrinkWrap: true,
//                                       physics:
//                                           const NeverScrollableScrollPhysics(),
//                                       itemCount:
//                                           apiKeywords.length > 6
//                                               ? 6
//                                               : apiKeywords.length,
//                                       separatorBuilder:
//                                           (_, __) => Divider(height: 1),
//                                       itemBuilder: (context, index) {
//                                         final keyword = apiKeywords[index];
//                                         return ListTile(
//                                           dense: true,
//                                           title: Text(keyword),
//                                           onTap: () {
//                                             // ✅ set typed text
//                                             _searchKeywordController.text =
//                                                 keyword;
//                                             _searchKeywordController.selection =
//                                                 TextSelection.collapsed(
//                                                   offset: keyword.length,
//                                                 );
//
//                                             // ✅ add to selected keywords
//                                             _addKeyword(keyword);
//
//                                             // ✅ hide dropdown
//                                             setState(
//                                               () => _showSuggestions = false,
//                                             );
//
//                                             // optional: close keyboard
//                                             FocusScope.of(context).unfocus();
//                                           },
//                                         );
//                                       },
//                                     )),
//                       ),
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
//                     //  Save & Continue
//                     // CommonContainer.button(
//                     //   buttonColor: AppColor.black,
//                     //   onTap: () {
//                     //     Navigator.push(
//                     //       context,
//                     //       MaterialPageRoute(
//                     //         builder: (context) => ProductCategoryScreens(),
//                     //       ),
//                     //     );
//                     //   },
//                     //   text: Text(
//                     //     'Save & Continue',
//                     //     style: AppTextStyles.mulish(
//                     //       fontSize: 18,
//                     //       fontWeight: FontWeight.w700,
//                     //     ),
//                     //   ),
//                     //   imagePath: AppImages.rightStickArrow,
//                     //   imgHeight: 20,
//                     // ),
//                     CommonContainer.button(
//                       buttonColor: AppColor.black,
//                       onTap: () async {
//                         if (_keywords.isEmpty) {
//                           AppSnackBar.error(
//                             context,
//                             'Please add at least one keyword',
//                           );
//                           return;
//                         }
//
//                         final notifier = ref.read(
//                           shopCategoryNotifierProvider.notifier,
//                         );
//                         final state = ref.read(shopCategoryNotifierProvider);
//
//                         // Call the API
//                         final success = await notifier.searchKeywords(
//                           keywords: _keywords,
//                         );
//
//                         if (success) {
//                           final shopId = await AppPrefs.getSopId();
//                           if (widget.page == 'shopDetailsEdit') {
//                             final businessProfileId =
//                                 await AppPrefs.getBusinessProfileId();
//
//                             context.goNamed(
//                               AppRoutes.shopDetailsEdit,
//                               extra: <String, dynamic>{
//                                 'shopId': shopId,
//                                 'businessProfileId': businessProfileId,
//                               },
//                             );
//                           } else {
//                             context.pushNamed(
//                               AppRoutes.productCategoryScreens,
//                               extra: 'SearchKeyword',
//                             );
//                           }
//                         } else {
//                           // Show error from state if available
//                           final errorMsg =
//                               state.error ??
//                               'Failed to save keywords. Try again.';
//                           AppSnackBar.error(context, errorMsg);
//                         }
//                       },
//                       text:
//                           state.isLoading
//                               ? const ThreeDotsLoader()
//                               : Text(
//                                 'Save & Continue',
//                                 style: AppTextStyles.mulish(
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.w700,
//                                 ),
//                               ),
//                       imagePath:
//                           state.isLoading ? null : AppImages.rightStickArrow,
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
