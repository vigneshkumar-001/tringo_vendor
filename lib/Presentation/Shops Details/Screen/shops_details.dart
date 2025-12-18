import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:tringo_vendor_new/Core/Const/app_images.dart';
import 'package:tringo_vendor_new/Core/Session/registration_session.dart';
import 'package:tringo_vendor_new/Core/Utility/app_loader.dart';
import 'package:tringo_vendor_new/Core/Utility/app_textstyles.dart';
import 'package:tringo_vendor_new/Core/Widgets/common_container.dart';
import 'package:tringo_vendor_new/Presentation/subscription/Screen/subscription_screen.dart';

import 'package:url_launcher/url_launcher.dart';

import '../../../Core/Const/app_color.dart';
import '../../../Core/Session/registration_product_seivice.dart';

import '../../../Core/Widgets/app_go_routes.dart';
import '../../../Core/Widgets/bottom_navigation_bar.dart';
import '../../AddProduct/Screens/product_category_screens.dart';
import '../../AddProduct/Screens/product_search_keyword.dart';

import '../../No Data Screen/Screen/no_data_screen.dart';
import '../../ShopInfo/Screens/shop_category_info.dart';
import '../Controller/shop_details_notifier.dart';


class ShopsDetails extends ConsumerStatefulWidget {
  final bool backDisabled;
  final bool fromSubscriptionSkip;
  final String? shopId;

  const ShopsDetails({
    super.key,
    this.backDisabled = false,
    this.fromSubscriptionSkip = false,
    this.shopId,
  });

  @override
  ConsumerState<ShopsDetails> createState() => _ShopsDetailsState();
}

class _ShopsDetailsState extends ConsumerState<ShopsDetails> {
  int selectedIndex = 0;
  int selectedWeight = 0;

  Future<void> _openMap(String latitude, String longitude) async {
    final Uri googleMapUrl = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
    );

    try {
      final bool launched = await launchUrl(
        googleMapUrl,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open Google Maps')),
        );
      }
    } catch (e) {
      debugPrint('Error launching map: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to open map')));
    }
  }

  Future<void> _openDialer(String phoneNumber) async {
    final trimmed = phoneNumber.trim();
    if (trimmed.isEmpty) {
      debugPrint('No phone number provided');
      return;
    }

    final uri = Uri.parse('tel:$trimmed');
    debugPrint('Trying to launch: $uri');

    final canLaunch = await canLaunchUrl(uri);
    debugPrint('canLaunchUrl: $canLaunch');

    if (canLaunch) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('Could not launch dialer for $trimmed');
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(shopDetailsNotifierProvider.notifier)
          .fetchShopDetails(apiShopId: widget.shopId);
    });
  }

  void _maybeGoToProductCategory() {
    // your existing logic here, example:
    //
    // if (RegistrationProductSeivice.instance.shouldGoToProductCategory) {
    //   context.goNamed(AppRoutes.productCategoryScreens);
    // }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(shopDetailsNotifierProvider);
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
                  onTap: state.isLoading
                      ? null
                      : () {
                    ref
                        .read(shopDetailsNotifierProvider.notifier)
                        .fetchShopDetails();
                  },
                  text: Text('Try Again'),
                ),
                // ElevatedButton(
                //   onPressed: state.isLoading
                //       ? null
                //       : () {
                //           // retry API call
                //           ref
                //               .read(shopDetailsNotifierProvider.notifier)
                //               .fetchShopDetails();
                //         },
                //   child: state.isLoading
                //       ? const SizedBox(
                //           width: 16,
                //           height: 16,
                //           child: CircularProgressIndicator(strokeWidth: 2),
                //         )
                //       : const Text('Try again'),
                // ),
              ],
            ),
          ),
        ),
      );
    }

    final shop = state.shopDetailsResponse?.data;

    if (shop == null && !state.isLoading) {
      return const Scaffold(body: Center(child: Text('No shop data found')));
    }

    const String shopDisplayNameTamil =
        'ஸ்ரீ கிருஷ்ணா ஸ்வீட்ஸ் பிரைவேட் லிமிடெட்';
    const String shopDisplayName = 'Sri Krishna Sweets Private Limited';

    final productSession = RegistrationProductSeivice.instance;
    final bool isPremium = productSession.isPremium;
    final bool isNonPremium = productSession.isNonPremium;

    final bool isCompany =
        RegistrationSession.instance.businessType == BusinessType.company;
    final bool isIndividual =
        RegistrationSession.instance.businessType == BusinessType.individual;
    final isService = RegistrationProductSeivice.instance.isServiceBusiness;
    //  Only premium company can add branches
    final bool showAddBranch = isPremium && isCompany;

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
                      colors: [AppColor.scaffoldColor, AppColor.leftArrow],
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
                                if (widget.backDisabled) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'You cannot go back from this screen.',
                                      ),
                                    ),
                                  );
                                  return;
                                }
                                if (Navigator.of(context).canPop()) {
                                  Navigator.of(context).pop();
                                } else {
                                  // context.goNamed(
                                  //   AppRoutes.homeScreen,
                                  //   extra: 2,
                                  // );
                                }
                              },
                            ),

                            // CommonContainer.topLeftArrow(
                            //   // onTap: () {
                            //   //   Navigator.push(
                            //   //     context,
                            //   //     MaterialPageRoute(
                            //   //       builder: (context) =>
                            //   //           ProductSearchKeyword(isCompany: true),
                            //   //     ),
                            //   //   );
                            //   // },
                            //   onTap: () => Navigator.pop(context),
                            // ),
                            const Spacer(),
                            CommonContainer.gradientContainer(
                              text: shop?.category.toString() ?? '',
                              textColor: AppColor.skyBlue,
                              fontWeight: FontWeight.w700,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),
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
                                callOnTap: () =>
                                    _openDialer(shop?.shopPhone ?? ''),

                                callImage: AppImages.callImage,
                                callText: 'Call Now',
                                whatsAppIcon: true,
                                whatsAppOnTap: () {},
                                messageOnTap: () {},
                                MessageIcon: true,
                                mapText: 'Map',
                                mapOnTap: () => _openMap(
                                  shop?.shopGpsLatitude.toString() ?? '',
                                  shop?.shopGpsLongitude.toString() ?? '',
                                ),
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

                                              placeholder: (context, url) =>
                                                  Container(
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
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                    const ShopCategoryInfo(
                                      // isEditMode: true,
                                      initialShopNameEnglish:
                                      shopDisplayName,
                                      initialShopNameTamil:
                                      shopDisplayNameTamil,
                                      isService: true,
                                      isIndividual: false,
                                    ),
                                  ),
                                );
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
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                                final imageUrl = (data.media.isNotEmpty)
                                    ? (data.media.first.url ?? '')
                                    : '';

                                return Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: CommonContainer.foodList(
                                    fontSize: 14,
                                    doorDelivery: data.doorDelivery == true,
                                    titleWeight: FontWeight.w700,
                                    onTap: () {},
                                    imageWidth: 130,
                                    image: imageUrl,
                                    foodName: data.englishName ?? '',
                                    ratingStar: data.rating?.toString() ?? '0',
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
                                );
                              },
                            ),

                            SizedBox(height: 10),
                            // InkWell(
                            //   onTap: () {
                            //     Navigator.push(
                            //       context,
                            //       MaterialPageRoute(
                            //         builder: (context) =>
                            //             ProductCategoryScreens(
                            //               shopId: shop.shopId,
                            //             ),
                            //       ),
                            //     );
                            //   },
                            //   child: Container(
                            //     width: double.infinity,
                            //     decoration: BoxDecoration(
                            //       color: AppColor.lightGray,
                            //       borderRadius: BorderRadius.circular(15),
                            //     ),
                            //     padding: EdgeInsets.symmetric(vertical: 22.5),
                            //     child: Row(
                            //       mainAxisAlignment: MainAxisAlignment.center,
                            //       children: [
                            //         Image.asset(
                            //           AppImages.addListImage,
                            //           height: 22,
                            //           color: AppColor.darkBlue,
                            //         ),
                            //         const SizedBox(width: 9),
                            //         Text(
                            //           'Add Products',
                            //           style: AppTextStyles.mulish(
                            //             color: AppColor.darkBlue,
                            //           ),
                            //         ),
                            //       ],
                            //     ),
                            //   ),
                            // ),
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

                                final imageUrl = (data.media.isNotEmpty)
                                    ? (data.media.first.url ?? '')
                                    : '';

                                // Fallbacks
                                final double startsAt = data.startsAt ?? 0;
                                final double offer = data.offerPrice ?? 0;

                                return Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: CommonContainer.foodList(
                                    fontSize: 14,
                                    doorDelivery: false,
                                    titleWeight: FontWeight.w700,
                                    onTap: () {},
                                    imageWidth: 130,
                                    image: imageUrl,
                                    foodName: data.englishName ?? '',
                                    ratingStar: (data.rating ?? 0).toString(),
                                    ratingCount: (data.ratingCount ?? 0)
                                        .toString(),

                                    //  show both prices
                                    offAmound: '₹${offer.toStringAsFixed(0)}',
                                    oldAmound:
                                    '₹${startsAt.toStringAsFixed(0)}',

                                    km: '',
                                    location: '',
                                    Verify: false,
                                    locations: false,
                                    weight: false,
                                    horizontalDivider: false,
                                  ),
                                );
                              },
                            ),


                            SizedBox(height: 10),
                            // InkWell(
                            //   onTap: () {
                            //     Navigator.push(
                            //       context,
                            //       MaterialPageRoute(
                            //         builder: (context) =>
                            //             ProductCategoryScreens(),
                            //       ),
                            //     );
                            //   },
                            //   child: Container(
                            //     width: double.infinity,
                            //     decoration: BoxDecoration(
                            //       color: AppColor.lightGray,
                            //       borderRadius: BorderRadius.circular(15),
                            //     ),
                            //     padding: EdgeInsets.symmetric(vertical: 22.5),
                            //     child: Row(
                            //       mainAxisAlignment: MainAxisAlignment.center,
                            //       children: [
                            //         Image.asset(
                            //           AppImages.addListImage,
                            //           height: 22,
                            //           color: AppColor.darkBlue,
                            //         ),
                            //         const SizedBox(width: 9),
                            //         Text(
                            //           'Add Service',
                            //           style: AppTextStyles.mulish(
                            //             color: AppColor.darkBlue,
                            //           ),
                            //         ),
                            //       ],
                            //     ),
                            //   ),
                            // ),
                          ],
                        ],
                      ),

                      SizedBox(height: 40),
                      if (isNonPremium)
                        CommonContainer.attractCustomerCard(
                          title: 'Attract More Customers',
                          description:
                          'Unlock premium to attract more customers',
                          onTap: () {
                            // From details we don’t want Skip again – only real subscribe
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                const SubscriptionScreen(showSkip: false),
                              ),
                            );
                          },
                        ),

                      const SizedBox(height: 40),
                      Row(
                        children: [
                          Image.asset(
                            AppImages.reviewImage,
                            height: 27.08,
                            width: 26,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Reviews',
                            style: AppTextStyles.mulish(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColor.darkBlue,
                            ),
                          ),
                        ],
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Builder(
                          builder: (context) {
                            final reviews = shop?.reviews ?? [];

                            if (reviews.isEmpty) {
                              return const Center(
                                child: Text(
                                  'No reviews found',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                              );
                            }

                            return ListView.builder(
                              itemCount: reviews.length,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                final data = reviews[index];
                                final reviewText = data is String
                                    ? data
                                    : data.toString();

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          data,
                                          style: AppTextStyles.mulish(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 33,
                                            color: AppColor.darkBlue,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Image.asset(
                                          AppImages.starImage,
                                          height: 30,
                                          color: AppColor.green,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Based on 58 reviews',
                                      style: AppTextStyles.mulish(
                                        color: AppColor.gray84,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    CommonContainer.reviewBox(),
                                    const SizedBox(height: 17),
                                    CommonContainer.reviewBox(),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ),
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
                color: AppColor.scaffoldColor,
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
                    // 1️⃣ Always navigate immediately
                    // context.go(AppRoutes.homeScreenPath);
                    // await ref
                    //     .read(selectedShopProvider.notifier)
                    //     .switchShop('');


                    // 2️⃣ Reset AFTER navigation
                    Future.microtask(() {
                      RegistrationSession.instance.reset();
                      // RegistrationProductSeivice.instance.reset();
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Close Preview',
                    style: AppTextStyles.mulish(
                      color: AppColor.scaffoldColor,
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
