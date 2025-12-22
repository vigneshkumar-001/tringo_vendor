import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:tringo_vendor_new/Core/Const/app_logger.dart';
import 'package:tringo_vendor_new/Core/Utility/app_prefs.dart';
import 'package:tringo_vendor_new/Core/Utility/call_helper.dart';
import 'package:tringo_vendor_new/Presentation/Shop%20Details%20Edit/Controller/shop_edit_notifier.dart';

import '../../../Core/Const/app_color.dart';
import '../../../Core/Const/app_images.dart';
import '../../../Core/Session/registration_product_seivice.dart';
import '../../../Core/Session/registration_session.dart';
import '../../../Core/Utility/app_loader.dart';
import '../../../Core/Utility/app_textstyles.dart';
import '../../../Core/Widgets/app_go_routes.dart';
import '../../../Core/Widgets/common_container.dart';
import '../../AddProduct/Controller/product_notifier.dart';
import '../../AddProduct/Screens/product_category_screens.dart';
import '../../No Data Screen/Screen/no_data_screen.dart';
import '../../ShopInfo/Model/search_keywords_response.dart';
import '../../ShopInfo/Screens/shop_category_info.dart';
import '../../Shops Details/Controller/shop_details_notifier.dart';
import '../../subscription/Screen/subscription_screen.dart';

class ShopDetailsEdit extends ConsumerStatefulWidget {
  final String shopId;
  const ShopDetailsEdit({required this.shopId, super.key});

  @override
  ConsumerState<ShopDetailsEdit> createState() => _ShopDetailsEditState();
}

class _ShopDetailsEditState extends ConsumerState<ShopDetailsEdit> {
  int selectedIndex = 0;
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(shopDetailsNotifierProvider.notifier)
          .fetchShopDetails(apiShopId: widget.shopId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(shopDetailsNotifierProvider);
    final productSession = RegistrationProductSeivice.instance;
    final bool isPremium = productSession.isPremium;
    final bool isNonPremium = productSession.isNonPremium;

    final bool isCompany =
        RegistrationSession.instance.businessType == BusinessType.company;
    final bool showAddBranch = isPremium && isCompany;
    if (state.isLoading) {
      return Skeletonizer(
        enabled: true,
        enableSwitchAnimation: true,
        child: Scaffold(
          body: SafeArea(
            child: Center(child: ThreeDotsLoader(dotColor: AppColor.black)),
          ),
        ),
      );
    }

    if (state.error != null) {
      debugPrint('Shop details error: ${state.error}');
      return Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                NoDataScreen(),
                // Text(
                //   'No data available. Please try again later.',
                //   textAlign: TextAlign.center,
                //   style: AppTextStyles.mulish(fontSize: 18),
                // ),
                const SizedBox(height: 16),
                CommonContainer.button(
                  onTap:
                      state.isLoading
                          ? null
                          : () {
                            ref
                                .read(shopDetailsNotifierProvider.notifier)
                                .fetchShopDetails();
                          },
                  text: Text('Try Again'),
                ),
              ],
            ),
          ),
        ),
      );
    }
    final shop = state.shopDetailsResponse?.data;
    // if (shop == null && !state.isLoading) {
    //   return const Scaffold(body: Center(child: Text('No shop data found')));
    // }
    return Skeletonizer(
      enabled: state.isLoading,
      enableSwitchAnimation: true,
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: LinearGradient(
                      colors: [AppColor.white, AppColor.borderGray],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        child: Row(
                          children: [
                            CommonContainer.topLeftArrow(
                              onTap: () {
                                Navigator.of(context).pop();
                                // if (widget.backDisabled) {
                                //   ScaffoldMessenger.of(context).showSnackBar(
                                //     const SnackBar(
                                //       content: Text(
                                //         'You cannot go back from this screen.',
                                //       ),
                                //     ),
                                //   );
                                //   return;
                                // }
                                // if (Navigator.of(context).canPop()) {
                                //   Navigator.of(context).pop();
                                // } else {
                                //   context.goNamed(AppRoutes.home, extra: 2);
                                // }
                              },
                            ),

                            Spacer(),
                            CommonContainer.gradientContainer(
                              text: shop?.category.toString() ?? '',
                              textColor: AppColor.skyBlue,
                              fontWeight: FontWeight.w700,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                shop?.shopDoorDelivery == true
                                    ? CommonContainer.doorDelivery(
                                      text: 'Door Delivery',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w900,
                                      textColor: AppColor.skyBlue,
                                    )
                                    : SizedBox.shrink(),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              shop?.shopEnglishName.toString() ?? '',
                              style: AppTextStyles.mulish(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                color: AppColor.darkBlue,
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                Image.asset(
                                  AppImages.locationImage,
                                  height: 15,
                                  color: AppColor.darkGrey,
                                ),
                                const SizedBox(width: 3),
                                Expanded(
                                  child: Text(
                                    '${shop?.shopAddressEn.toString() ?? ''} ${shop?.shopCity.toString() ?? ''} ${shop?.shopState.toString() ?? ''},${shop?.shopCountry.toString() ?? ''}',
                                    style: AppTextStyles.mulish(
                                      color: AppColor.darkGrey,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 27),

                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: CommonContainer.callNowButton(
                                callOnTap:
                                    () => CallHelper.openDialer(
                                      context: context,
                                      rawPhone: shop?.shopPhone ?? '',
                                    ),

                                // callOnTap:
                                //     () => _openDialer(shop?.shopPhone ?? ''),
                                callImage: AppImages.callImage,
                                callText: 'Call Now',
                                whatsAppIcon: true,
                                whatsAppOnTap: () {},
                                messageOnTap: () {},
                                MessageIcon: true,
                                mapText: 'Map',
                                mapOnTap:
                                    () => CallHelper.openMap(
                                      context: context,
                                      latitude:
                                          shop?.shopGpsLatitude.toString() ??
                                          '',
                                      longitude:
                                          shop?.shopGpsLongitude.toString() ??
                                          '',
                                    ),

                                // mapOnTap: () => _openMap(
                                //   shop?.shopGpsLatitude.toString() ?? '',
                                //   shop?.shopGpsLongitude.toString() ?? '',
                                // ),
                                mapImage: AppImages.locationImage,
                                callIconSize: 21,
                                callTextSize: 16,
                                mapIconSize: 21,
                                mapTextSize: 16,
                                messagesIconSize: 23,
                                whatsAppIconSize: 23,
                                fireIconSize: 23,
                                callNowPadding: const EdgeInsets.symmetric(
                                  horizontal: 30,
                                  vertical: 12,
                                ),
                                mapBoxPadding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 10,
                                ),
                                iconContainerPadding:
                                    const EdgeInsets.symmetric(
                                      horizontal: 22,
                                      vertical: 13,
                                    ),
                                messageContainer: true,
                                mapBox: true,
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          SizedBox(
                            height: 250,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15,
                              ),

                              child: Row(
                                children: List.generate(
                                  shop?.shopImages.length ?? 0,
                                  (index) {
                                    final imageData = shop?.shopImages[index];

                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        right: 10.0,
                                      ),
                                      child: Stack(
                                        children: [
                                          ClipRRect(
                                            clipBehavior: Clip.antiAlias,
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            // --- Replace Image.network with CachedNetworkImage ---
                                            child: CachedNetworkImage(
                                              imageUrl: imageData?.url ?? '',
                                              height: 230,
                                              width: 310,
                                              fit: BoxFit.cover,

                                              placeholder:
                                                  (context, url) => Container(
                                                    width: 310,
                                                    height: 230,
                                                    color: Colors.grey[300],
                                                    child: Center(
                                                      child: ThreeDotsLoader(),
                                                    ),
                                                  ),
                                              // The errorWidget is shown if the image fails to load
                                              errorWidget:
                                                  (context, url, error) =>
                                                      Container(
                                                        width: 310,
                                                        height: 230,
                                                        color: Colors.grey[300],
                                                        child: const Icon(
                                                          Icons.broken_image,
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                            ),
                                          ),
                                          Positioned(
                                            top: 20,
                                            left: 15,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: AppColor.scaffoldColor,
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,

                                                children: [
                                                  Text(
                                                    (shop?.shopRating ?? 0.0)
                                                        .toStringAsFixed(1),
                                                    style: AppTextStyles.mulish(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 14,
                                                      color: AppColor.darkBlue,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 5),
                                                  Image.asset(
                                                    AppImages.starImage,
                                                    height: 9,
                                                    color: AppColor.green,
                                                  ),
                                                  const SizedBox(width: 5),
                                                  Container(
                                                    width: 1.5,
                                                    height: 11,
                                                    decoration: BoxDecoration(
                                                      color: AppColor.darkBlue
                                                          .withOpacity(0.2),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            1,
                                                          ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 5),
                                                  Text(
                                                    (shop?.shopReviewCount ?? 0)
                                                        .toString(),
                                                    style: AppTextStyles.mulish(
                                                      fontSize: 12,
                                                      color: AppColor.darkBlue,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),

                          if (showAddBranch)
                            GestureDetector(
                              onTap: () {
                                // Navigator.push(
                                //   context,
                                //   MaterialPageRoute(
                                //     builder: (context) =>
                                //     const ShopCategoryInfo(
                                //       isEditMode: true,
                                //       initialShopNameEnglish:
                                //       shopDisplayName,
                                //       initialShopNameTamil:
                                //       shopDisplayNameTamil,
                                //       isService: true,
                                //       isIndividual: false,
                                //     ),
                                //   ),
                                // );
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 15,
                                  vertical: 15,
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: AppColor.borderLightGrey,
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(22),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 20,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Image.asset(
                                          AppImages.addBranch,
                                          height: 22,
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          'Add Branch',
                                          style: AppTextStyles.mulish(
                                            color: AppColor.darkBlue,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),

                          SizedBox(height: 15),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ------------------- PRODUCTS SECTION -------------------
                          if ((shop?.products ?? []).isNotEmpty) ...[
                            Row(
                              children: [
                                Image.asset(
                                  AppImages.fireImage,
                                  height: 35,
                                  color: AppColor.darkBlue,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'Offer Products',
                                  style: AppTextStyles.mulish(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22,
                                    color: AppColor.darkBlue,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),

                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: shop!.products.length,
                              itemBuilder: (context, index) {
                                final data = shop.products[index];

                                // Safe image
                                final imageUrl =
                                    (data.media.isNotEmpty)
                                        ? (data.media.first.url ?? '')
                                        : '';

                                return Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: Column(
                                    children: [
                                      CommonContainer.foodList(
                                        fontSize: 14,
                                        doorDelivery: data.doorDelivery == true,
                                        titleWeight: FontWeight.w700,
                                        onTap: () {},
                                        imageWidth: 130,
                                        image: imageUrl,
                                        foodName: data.englishName ?? '',
                                        ratingStar:
                                            data.rating?.toString() ?? '0',
                                        ratingCount:
                                            data.ratingCount?.toString() ?? '0',
                                        offAmound: '₹${data.offerPrice ?? 0}',
                                        oldAmound: '₹${data.price ?? 0}',
                                        km: '',
                                        location: '',
                                        Verify: false,
                                        locations: false,
                                        weight: false,
                                        horizontalDivider: false,
                                      ),
                                      Row(
                                        children: [
                                          // EDIT PRODUCT
                                          Expanded(
                                            child: GestureDetector(
                                              onTap: () async {
                                                final updated = await Navigator.push<
                                                  bool
                                                >(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder:
                                                        (
                                                          context,
                                                        ) => ProductCategoryScreens(
                                                          page:
                                                              'AboutMeScreens',
                                                          isService:
                                                              false, // Product
                                                          shopId: shop.shopId,
                                                          productId:
                                                              data.productId,
                                                          allowOfferEdit: true,
                                                          initialCategoryName:
                                                              data.category,
                                                          initialSubCategoryName:
                                                              data.subCategory,
                                                          initialProductName:
                                                              data.englishName,
                                                          initialPrice:
                                                              data.price,
                                                          initialDescription:
                                                              data.description,
                                                          initialOfferLabel:
                                                              data.offerLabel,
                                                          initialOfferValue:
                                                              data.offerValue,
                                                        ),
                                                  ),
                                                );

                                                if (updated == true &&
                                                    mounted) {
                                                  await ref
                                                      .read(
                                                        shopDetailsNotifierProvider
                                                            .notifier,
                                                      )
                                                      .fetchShopDetails(
                                                        apiShopId:
                                                            widget.shopId,
                                                      );
                                                  setState(() {});
                                                }
                                              },
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 15,
                                                      horizontal: 15,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: AppColor.blue,
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Image.asset(
                                                      AppImages.editImage,
                                                      color: AppColor.white,
                                                      height: 16,
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Text(
                                                      'Edit',
                                                      style:
                                                          AppTextStyles.mulish(
                                                            color:
                                                                AppColor.white,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),

                                          const SizedBox(width: 15),

                                          // REMOVE PRODUCT
                                          Expanded(
                                            child: GestureDetector(
                                              onTap: () async {
                                                final confirm = await showDialog<
                                                  bool
                                                >(
                                                  context: context,
                                                  barrierDismissible: false,
                                                  builder:
                                                      (_) => AlertDialog(
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                20,
                                                              ),
                                                        ),
                                                        title: Row(
                                                          children: const [
                                                            Icon(
                                                              Icons.warning,
                                                              color:
                                                                  Colors.orange,
                                                            ),
                                                            SizedBox(width: 10),
                                                            Text(
                                                              'Remove Product?',
                                                            ),
                                                          ],
                                                        ),
                                                        content: const Text(
                                                          'Are you sure you want to remove this product? This action cannot be undone.',
                                                        ),
                                                        actionsPadding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 16,
                                                              vertical: 8,
                                                            ),
                                                        actions: [
                                                          TextButton(
                                                            onPressed:
                                                                () =>
                                                                    Navigator.pop(
                                                                      context,
                                                                      false,
                                                                    ),
                                                            child: const Text(
                                                              'Cancel',
                                                            ),
                                                          ),
                                                          ElevatedButton(
                                                            style: ElevatedButton.styleFrom(
                                                              backgroundColor:
                                                                  Colors.red,
                                                              shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      12,
                                                                    ),
                                                              ),
                                                            ),
                                                            onPressed:
                                                                () =>
                                                                    Navigator.pop(
                                                                      context,
                                                                      true,
                                                                    ),
                                                            child: Text(
                                                              'Remove',
                                                              style: AppTextStyles.mulish(
                                                                color:
                                                                    AppColor
                                                                        .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                );

                                                if (confirm != true) return;

                                                // Show loader while deleting
                                                showDialog(
                                                  context: context,
                                                  barrierDismissible: false,
                                                  builder:
                                                      (_) => AlertDialog(
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                20,
                                                              ),
                                                        ),
                                                        content: SizedBox(
                                                          height: 100,
                                                          child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: const [
                                                              CircularProgressIndicator(),
                                                              SizedBox(
                                                                height: 20,
                                                              ),
                                                              Text(
                                                                'Removing product...',
                                                                style:
                                                                    TextStyle(
                                                                      fontSize:
                                                                          16,
                                                                    ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                );

                                                // Call deleteProductAction
                                                final success = await ref
                                                    .read(
                                                      productNotifierProvider
                                                          .notifier,
                                                    )
                                                    .deleteProductAction(
                                                      productId: data.productId,
                                                    );

                                                if (mounted)
                                                  Navigator.pop(
                                                    context,
                                                  ); // close loader

                                                // Refresh shop details
                                                if (success && mounted) {
                                                  await ref
                                                      .read(
                                                        shopDetailsNotifierProvider
                                                            .notifier,
                                                      )
                                                      .fetchShopDetails(
                                                        apiShopId: shop.shopId,
                                                      );
                                                }

                                                // Feedback
                                                if (mounted) {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        success
                                                            ? 'Product removed successfully'
                                                            : 'Failed to remove product',
                                                      ),
                                                    ),
                                                  );
                                                }
                                              },
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 15,
                                                      horizontal: 15,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: AppColor.whiteSmoke,
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Image.asset(
                                                      AppImages.closeImage,
                                                      color: AppColor.black,
                                                      height: 16,
                                                    ),
                                                    const SizedBox(width: 10),
                                                    Text(
                                                      'Remove',
                                                      style:
                                                          AppTextStyles.mulish(
                                                            color:
                                                                AppColor.black,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),

                            SizedBox(height: 10),
                            InkWell(
                              onTap: () async {
                                await AppPrefs.clearIds();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => ProductCategoryScreens(
                                          shopId: shop.shopId,
                                        ),
                                  ),
                                );
                              },
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  border: Border.all(),
                                  color: AppColor.white,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15.5,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      AppImages.addListImage,
                                      height: 22,
                                      color: AppColor.darkBlue,
                                    ),
                                    const SizedBox(width: 9),
                                    Text(
                                      'Add Products',
                                      style: AppTextStyles.mulish(
                                        color: AppColor.darkBlue,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],

                          // ------------------- SERVICES SECTION -------------------
                          if ((shop?.services ?? []).isNotEmpty) ...[
                            Row(
                              children: [
                                Image.asset(
                                  AppImages.fireImage,
                                  height: 35,
                                  color: AppColor.darkBlue,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'Offer Services',
                                  style: AppTextStyles.mulish(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22,
                                    color: AppColor.darkBlue,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),

                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount:
                                  shop?.services.length ?? 0, // 👈 null-safe
                              itemBuilder: (context, index) {
                                final data = shop!.services[index];

                                final imageUrl =
                                    (data.media.isNotEmpty)
                                        ? (data.media.first.url ?? '')
                                        : '';

                                // Fallbacks
                                final double startsAt = data.startsAt ?? 0;
                                final double offer = data.offerPrice ?? 0;

                                return Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: Column(
                                    children: [
                                      CommonContainer.foodList(
                                        fontSize: 14,
                                        doorDelivery: false,
                                        titleWeight: FontWeight.w700,
                                        onTap: () {},
                                        imageWidth: 130,
                                        image: imageUrl,
                                        foodName: data.englishName ?? '',
                                        ratingStar:
                                            (data.rating ?? 0).toString(),
                                        ratingCount:
                                            (data.ratingCount ?? 0).toString(),

                                        //  show both prices
                                        offAmound:
                                            '₹${offer.toStringAsFixed(0)}',
                                        oldAmound:
                                            '₹${startsAt.toStringAsFixed(0)}',

                                        km: '',
                                        location: '',
                                        Verify: false,
                                        locations: false,
                                        weight: false,
                                        horizontalDivider: false,
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: GestureDetector(
                                              onTap: () async {
                                                final updated = await Navigator.push<
                                                  bool
                                                >(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder:
                                                        (
                                                          context,
                                                        ) => ProductCategoryScreens(
                                                          page:
                                                              'AboutMeScreens',
                                                          isService: true,
                                                          shopId: shop.shopId,
                                                          productId:
                                                              data.serviceId,
                                                          allowOfferEdit: true,
                                                          initialCategoryName:
                                                              data.category,
                                                          initialSubCategoryName:
                                                              data.subCategory,
                                                          initialProductName:
                                                              data.englishName,
                                                          initialPrice:
                                                              data.startsAt
                                                                  ?.toInt(),
                                                          initialDescription:
                                                              data.description,
                                                          initialOfferLabel:
                                                              data.offerLabel,
                                                          initialOfferValue:
                                                              data.offerValue,
                                                        ),
                                                  ),
                                                );
                                                //  AFTER POP: refresh automatically
                                                if (updated == true &&
                                                    mounted) {
                                                  await ref
                                                      .read(
                                                        shopDetailsNotifierProvider
                                                            .notifier,
                                                      )
                                                      .fetchShopDetails(
                                                        apiShopId:
                                                            widget.shopId,
                                                      );
                                                  setState(() {});
                                                }
                                              },
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 15,
                                                      horizontal: 15,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: AppColor.blue,
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Image.asset(
                                                      AppImages.editImage,
                                                      color: AppColor.white,
                                                      height: 16,
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Text(
                                                      'Edit',
                                                      style:
                                                          AppTextStyles.mulish(
                                                            color:
                                                                AppColor.white,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 15),
                                          Expanded(
                                            child: GestureDetector(
                                              onTap: () async {
                                                final confirm = await showDialog<
                                                  bool
                                                >(
                                                  context: context,
                                                  barrierDismissible: false,
                                                  builder:
                                                      (_) => AlertDialog(
                                                        backgroundColor:
                                                            AppColor.white,
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                20,
                                                              ),
                                                        ),
                                                        title: Row(
                                                          children: const [
                                                            Icon(
                                                              Icons.warning,
                                                              color:
                                                                  Colors.orange,
                                                            ),
                                                            SizedBox(width: 10),
                                                            Text(
                                                              'Remove Service?',
                                                            ),
                                                          ],
                                                        ),
                                                        content: const Text(
                                                          'Are you sure you want to remove this service? This action cannot be undone.',
                                                        ),
                                                        actionsPadding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 16,
                                                              vertical: 8,
                                                            ),
                                                        actions: [
                                                          TextButton(
                                                            onPressed:
                                                                () =>
                                                                    Navigator.pop(
                                                                      context,
                                                                      false,
                                                                    ),
                                                            child: const Text(
                                                              'Cancel',
                                                            ),
                                                          ),
                                                          ElevatedButton(
                                                            style: ElevatedButton.styleFrom(
                                                              backgroundColor:
                                                                  Colors.red,
                                                              shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      12,
                                                                    ),
                                                              ),
                                                            ),
                                                            onPressed: () async {
                                                              Navigator.pop(
                                                                context,
                                                                true,
                                                              );

                                                              // Show loader dialog
                                                              showDialog(
                                                                context:
                                                                    context,
                                                                barrierDismissible:
                                                                    false,
                                                                builder:
                                                                    (
                                                                      _,
                                                                    ) => AlertDialog(
                                                                      shape: RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                              20,
                                                                            ),
                                                                      ),
                                                                      content: SizedBox(
                                                                        height:
                                                                            100,
                                                                        child: Column(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.center,
                                                                          children: [
                                                                            AppLoader.circularLoader(
                                                                              color:
                                                                                  AppColor.darkBlue,
                                                                            ),
                                                                            SizedBox(
                                                                              height:
                                                                                  20,
                                                                            ),
                                                                            Text(
                                                                              'Removing service...',
                                                                              style: TextStyle(
                                                                                fontSize:
                                                                                    16,
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                              );

                                                              // Call delete API
                                                              final success = await ref
                                                                  .read(
                                                                    productNotifierProvider
                                                                        .notifier,
                                                                  )
                                                                  .deleteServiceAction(
                                                                    serviceId:
                                                                        data.serviceId,
                                                                  );

                                                              // Close loader
                                                              if (mounted)
                                                                Navigator.pop(
                                                                  context,
                                                                );

                                                              // Refresh shop details if deleted successfully
                                                              if (success &&
                                                                  mounted) {
                                                                await ref
                                                                    .read(
                                                                      shopDetailsNotifierProvider
                                                                          .notifier,
                                                                    )
                                                                    .fetchShopDetails(
                                                                      apiShopId:
                                                                          shop.shopId,
                                                                    );
                                                              }

                                                              // SnackBar feedback
                                                              if (mounted) {
                                                                ScaffoldMessenger.of(
                                                                  context,
                                                                ).showSnackBar(
                                                                  SnackBar(
                                                                    content: Text(
                                                                      success
                                                                          ? 'Service removed successfully'
                                                                          : 'Failed to remove service',
                                                                    ),
                                                                  ),
                                                                );
                                                              }
                                                            },
                                                            child: Text(
                                                              'Remove',
                                                              style: AppTextStyles.mulish(
                                                                color:
                                                                    AppColor
                                                                        .white,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                );

                                                if (confirm != true) return;
                                              },
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 15,
                                                      horizontal: 15,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: AppColor.whiteSmoke,
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Image.asset(
                                                      AppImages.closeImage,
                                                      color: AppColor.black,
                                                      height: 16,
                                                    ),
                                                    const SizedBox(width: 10),
                                                    Text(
                                                      'Remove',
                                                      style:
                                                          AppTextStyles.mulish(
                                                            color:
                                                                AppColor.black,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 10),
                                    ],
                                  ),
                                );
                              },
                            ),

                            SizedBox(height: 10),
                            InkWell(
                              onTap: () async {
                                await AppPrefs.clearIds();

                                AppLogger.log.i(shop?.shopId);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => ProductCategoryScreens(
                                          isService: true,
                                          shopId: shop?.shopId ?? '',
                                        ),
                                  ),
                                );
                              },
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  border: Border.all(),
                                  color: AppColor.white,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15.5,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      AppImages.addListImage,
                                      height: 22,
                                      color: AppColor.darkBlue,
                                    ),
                                    const SizedBox(width: 9),
                                    Text(
                                      'Add Service',
                                      style: AppTextStyles.mulish(
                                        color: AppColor.darkBlue,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),

                      SizedBox(height: 30),
                      CommonContainer.attractCustomerCard(
                        title: 'Attract More Customers',
                        description: 'Unlock premium to attract more customers',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => SubscriptionScreen(
                                    businessProfileId:
                                        shop?.businessProfileId ?? '',
                                  ),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 30),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: Material(
          color: Colors.transparent,
          child: SafeArea(
            child: Container(
              decoration: BoxDecoration(
                color: AppColor.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 16,
                    offset: const Offset(0, -6),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: ElevatedButton(
                  onPressed: () async {
                    final bool isServiceFlow =
                        (shop?.shopKind?.toUpperCase() == 'SERVICE');
                    final bool isIndividual =
                        (shop?.ownershipType?.toUpperCase() == 'INDIVIDUAL');
                    final images = List.from(shop?.shopImages ?? [])..sort(
                      (a, b) =>
                          (a.displayOrder ?? 0).compareTo(b.displayOrder ?? 0),
                    );

                    final initialImageUrls = List<String?>.filled(4, null);
                    for (int i = 0; i < images.length && i < 4; i++) {
                      final url = images[i].url;
                      if (url != null && url.trim().isNotEmpty) {
                        initialImageUrls[i] = url.trim();
                      }
                    }
                    final updated = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => ShopCategoryInfo(
                              isEditMode: true,
                              employeeId: shop?.businessProfileId ?? '',
                              shopId: shop?.shopId,
                              initialImageUrls: initialImageUrls,
                              pages: 'shopDetailsEdit',
                              isService: isServiceFlow,
                              isIndividual: isIndividual,

                              //  prefill values from Shop model
                              initialShopNameEnglish: shop?.shopEnglishName,
                              initialShopNameTamil: shop?.shopTamilName,

                              initialDescriptionEnglish:
                                  shop?.shopDescriptionEn,
                              initialDescriptionTamil: shop?.shopDescriptionTa,

                              initialAddressEnglish: shop?.shopAddressEn,
                              initialAddressTamil: shop?.shopAddressTa,

                              initialGps:
                                  (shop?.shopGpsLatitude != null &&
                                          shop?.shopGpsLongitude != null)
                                      ? "${shop?.shopGpsLatitude}, ${shop?.shopGpsLongitude}"
                                      : "",
                              initialPrimaryMobile: shop?.shopPhone,
                              initialWhatsapp: shop?.shopWhatsapp,
                              initialEmail: shop?.shopContactEmail,
                              // no separate name fields in model → use slug as display text for now
                              initialCategoryName: shop?.category ?? "",
                              initialCategorySlug: shop?.category,
                              initialSubCategoryName: shop?.subCategory ?? "",
                              initialSubCategorySlug: shop?.subCategory,

                              initialDoorDeliveryText:
                                  (shop?.shopDoorDelivery == true)
                                      ? 'Yes'
                                      : 'No',
                              initialOpenTimeText: shop?.opensAt ?? '',
                              initialCloseTimeText: shop?.closesAt ?? '',
                              initialOwnerImageUrl: '',
                              businessProfileId: shop?.businessProfileId ?? '',
                            ),
                      ),
                    );
                    // 1️⃣ Always navigate immediately
                    // context.goNamed(AppRoutes.aboutMeScreens, extra: 3);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Edit Shop Details',
                    style: AppTextStyles.mulish(
                      color: AppColor.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
