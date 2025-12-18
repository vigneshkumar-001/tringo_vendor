import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tringo_vendor_new/Presentation/Shop%20Details%20Edit/Controller/shop_edit_notifier.dart';

import '../../../Core/Const/app_color.dart';
import '../../../Core/Const/app_images.dart';
import '../../../Core/Session/registration_product_seivice.dart';
import '../../../Core/Session/registration_session.dart';
import '../../../Core/Utility/app_loader.dart';
import '../../../Core/Utility/app_textstyles.dart';
import '../../../Core/Widgets/common_container.dart';
import '../../AddProduct/Screens/product_category_screens.dart';
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

    Future.microtask(() async {
      await ref
          .read(shopEditNotifierProvider.notifier)
          .fetchAllShopDetails(shopId: widget.shopId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final aboutState = ref.watch(shopEditNotifierProvider);
    return Scaffold(
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
                          Spacer(),
                          CommonContainer.gradientContainer(
                            text: 'kalavasal...',
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
                              // shop?.shopDoorDelivery == true
                              //     ?
                              CommonContainer.doorDelivery(
                                text: 'Door Delivery',
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                textColor: AppColor.skyBlue,
                              ),
                              // : SizedBox.shrink(),
                            ],
                          ),
                        ),
                        SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Dig',
                            // shop?.shopEnglishName.toString() ?? '',
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
                              SizedBox(width: 3),
                              Expanded(
                                child: Text(
                                  'kbdn',
                                  // '${shop?.shopAddressEn.toString() ?? ''} ${shop?.shopCity.toString() ?? ''} ${shop?.shopState.toString() ?? ''},${shop?.shopCountry.toString() ?? ''}',
                                  style: AppTextStyles.mulish(
                                    color: AppColor.darkGrey,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 27),

                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: CommonContainer.callNowButton(
                              callOnTap: () => {},

                              // _openDialer(shop?.shopPhone ?? ''),
                              callImage: AppImages.callImage,
                              callText: 'Call Now',
                              whatsAppIcon: true,
                              whatsAppOnTap: () {},
                              messageOnTap: () {},
                              MessageIcon: true,
                              mapText: 'Map',
                              mapOnTap: () => {},
                              //     _openMap(
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
                              iconContainerPadding: const EdgeInsets.symmetric(
                                horizontal: 22,
                                vertical: 13,
                              ),
                              messageContainer: true,
                              mapBox: true,
                            ),
                          ),
                        ),

                        SizedBox(height: 20),

                        SizedBox(
                          height: 250,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 15),

                            // child: Row(
                            //   children: List.generate(
                            //     shop?.shopImages.length ?? 0,
                            //         (index) {
                            //       final imageData = shop?.shopImages[index];
                            //
                            //       return
                            //         Padding(
                            //         padding: const EdgeInsets.only(
                            //           right: 10.0,
                            //         ),
                            //         child: Stack(
                            //           children: [
                            //             ClipRRect(
                            //               clipBehavior: Clip.antiAlias,
                            //               borderRadius: BorderRadius.circular(
                            //                 20,
                            //               ),
                            //               // --- Replace Image.network with CachedNetworkImage ---
                            //               child: CachedNetworkImage(
                            //                 imageUrl: imageData?.url ?? '',
                            //                 height: 230,
                            //                 width: 310,
                            //                 fit: BoxFit.cover,
                            //
                            //                 placeholder: (context, url) =>
                            //                     Container(
                            //                       width: 310,
                            //                       height: 230,
                            //                       color: Colors.grey[300],
                            //                       child: Center(
                            //                         child: ThreeDotsLoader(),
                            //                       ),
                            //                     ),
                            //                 // The errorWidget is shown if the image fails to load
                            //                 errorWidget:
                            //                     (context, url, error) =>
                            //                     Container(
                            //                       width: 310,
                            //                       height: 230,
                            //                       color: Colors.grey[300],
                            //                       child: const Icon(
                            //                         Icons.broken_image,
                            //                         color: Colors.grey,
                            //                       ),
                            //                     ),
                            //               ),
                            //             ),
                            //             Positioned(
                            //               top: 20,
                            //               left: 15,
                            //               child: Container(
                            //                 padding:
                            //                 const EdgeInsets.symmetric(
                            //                   horizontal: 8,
                            //                   vertical: 4,
                            //                 ),
                            //                 decoration: BoxDecoration(
                            //                   color: AppColor.white,
                            //                   borderRadius:
                            //                   BorderRadius.circular(30),
                            //                 ),
                            //                 child: Row(
                            //                   mainAxisSize: MainAxisSize.min,
                            //
                            //                   children: [
                            //                     Text( 'jdsv',
                            //                       // (shop?.shopRating ?? 0.0)
                            //                       //     .toStringAsFixed(1),
                            //                       style: AppTextStyles.mulish(
                            //                         fontWeight:
                            //                         FontWeight.bold,
                            //                         fontSize: 14,
                            //                         color: AppColor.darkBlue,
                            //                       ),
                            //                     ),
                            //                     const SizedBox(width: 5),
                            //                     Image.asset(
                            //                       AppImages.starImage,
                            //                       height: 9,
                            //                       color: AppColor.green,
                            //                     ),
                            //                     const SizedBox(width: 5),
                            //                     Container(
                            //                       width: 1.5,
                            //                       height: 11,
                            //                       decoration: BoxDecoration(
                            //                         color: AppColor.darkBlue
                            //                             .withOpacity(0.2),
                            //                         borderRadius:
                            //                         BorderRadius.circular(
                            //                           1,
                            //                         ),
                            //                       ),
                            //                     ),
                            //                     const SizedBox(width: 5),
                            //                     Text( 'jhbdf',
                            //                       // (shop?.shopReviewCount ?? 0)
                            //                       //     .toString(),
                            //                       style: AppTextStyles.mulish(
                            //                         fontSize: 12,
                            //                         color: AppColor.darkBlue,
                            //                       ),
                            //                     ),
                            //                   ],
                            //                 ),
                            //               ),
                            //             ),
                            //           ],
                            //         ),
                            //       );
                            //     },
                            //   ),
                            // ),
                          ),
                        ),

                        // // if (showAddBranch)
                        // GestureDetector(
                        //   // onTap: () {
                        //   //   Navigator.push(
                        //   //     context,
                        //   //     MaterialPageRoute(
                        //   //       builder:
                        //   //           (context) => const ShopCategoryInfo(
                        //   //             initialShopNameEnglish: shopDisplayName,
                        //   //             initialShopNameTamil:
                        //   //                 shopDisplayNameTamil,
                        //   //             isService: true,
                        //   //             isIndividual: false,
                        //   //           ),
                        //   //     ),
                        //   //   );
                        //   // },
                        //   child: Padding(
                        //     padding: const EdgeInsets.symmetric(
                        //       horizontal: 15,
                        //       vertical: 15,
                        //     ),
                        //     child: Container(
                        //       decoration: BoxDecoration(
                        //         border: Border.all(
                        //           color: AppColor.borderLightGrey,
                        //           width: 2,
                        //         ),
                        //         borderRadius: BorderRadius.circular(22),
                        //       ),
                        //       child: Padding(
                        //         padding: const EdgeInsets.symmetric(
                        //           vertical: 20,
                        //         ),
                        //         child: Row(
                        //           mainAxisAlignment: MainAxisAlignment.center,
                        //           children: [
                        //             Image.asset(
                        //               AppImages.addBranch,
                        //               height: 22,
                        //             ),
                        //             const SizedBox(width: 10),
                        //             Text(
                        //               'Add Branch',
                        //               style: AppTextStyles.mulish(
                        //                 color: AppColor.darkBlue,
                        //               ),
                        //             ),
                        //           ],
                        //         ),
                        //       ),
                        //     ),
                        //   ),
                        // ),
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
                    Row(
                      children: [
                        Image.asset(
                          AppImages.product,
                          height: 35,
                          color: AppColor.darkBlue,
                        ),
                        SizedBox(width: 10),
                        Text(
                          // hasServices ? 'Services' :
                          'Products',
                          style: AppTextStyles.mulish(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                            color: AppColor.darkBlue,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 10),
                    CommonContainer.foodList(
                      fontSize: 14,
                      titleWeight: FontWeight.w700,
                      onTap: () {},
                      imageWidth: 130,
                      image: AppImages.humanImage1,
                      foodName: 'Badam Mysurpa',
                      ratingStar: '4.5',
                      ratingCount: '16',
                      offAmound: '76',
                      oldAmound: '110',
                      km: '',
                      location: '',
                      Verify: false,
                      locations: false,
                      weight: false,
                      horizontalDivider: false,
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 15,
                            horizontal: 15,
                          ),
                          decoration: BoxDecoration(
                            color: AppColor.blue,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                AppImages.editImage,
                                color: AppColor.white,
                                height: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Edit',
                                style: AppTextStyles.mulish(
                                  color: AppColor.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 15),
                        Expanded(
                          child: GestureDetector(
                            /*   onTap: () async {
                          // prevent double tap while this service is deleting
                          if (_deletingServiceId == s.serviceId) return;

                          final confirm = await showDialog<bool>(
                            context: this.context,
                            builder: (_) => AlertDialog(
                              backgroundColor: AppColor.white,
                              title: const Text('Confirm Remove'),
                              content: const Text(
                                'Are you sure you want to remove this service?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(this.context, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(this.context, true),
                                  child: Text(
                                    'Remove',
                                    style: AppTextStyles.mulish(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );

                          if (confirm != true) return;
                          if (!mounted) return;

                          setState(
                                () => _deletingServiceId = s.serviceId,
                          );

                          final success = await ref
                              .read(productNotifierProvider.notifier)
                              .deleteServiceAction(
                            serviceId: s.serviceId,
                          );

                          if (!mounted) return;

                          setState(() => _deletingServiceId = null);

                          final productState = ref.read(
                            productNotifierProvider,
                          );
                          final deleteMsg =
                              productState.serviceRemoveResponse?.message;

                          if (success) {
                            // optional: instant local removal of the service
                            final currentShop = _getSelectedShop(
                              aboutState,
                            );
                            if (currentShop != null) {
                              currentShop.services.removeWhere(
                                    (srv) => srv.serviceId == s.serviceId,
                              );
                            }

                            // refresh from backend
                            await ref
                                .read(aboutMeNotifierProvider.notifier)
                                .fetchAllShopDetails(
                              shopId:
                              _currentShopId ??
                                  currentShop?.shopId,
                            );

                            if (!mounted) return;

                            ScaffoldMessenger.of(
                              this.context,
                            ).showSnackBar(
                              SnackBar(
                                content: Text(
                                  deleteMsg ??
                                      'Service removed successfully',
                                ),
                              ),
                            );
                          } else {
                            if (!mounted) return;
                            ScaffoldMessenger.of(
                              this.context,
                            ).showSnackBar(
                              SnackBar(
                                content: Text(
                                  productState.error ??
                                      'Failed to remove service',
                                ),
                              ),
                            );
                          }
                        },*/
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 15,
                                horizontal: 15,
                              ),
                              decoration: BoxDecoration(
                                color: AppColor.whiteSmoke,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child:
                              // Center(
                              //   child: (_deletingServiceId == s.serviceId)
                              //       ? ThreeDotsLoader(
                              //     dotColor: AppColor.black,
                              //   )
                              //       :
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    AppImages.closeImage,
                                    color: AppColor.black,
                                    height: 16,
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    'Remove',
                                    style: AppTextStyles.mulish(
                                      color: AppColor.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 30),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(),
                        color: AppColor.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 15.5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            AppImages.addListImage,
                            height: 22,
                            color: AppColor.darkBlue,
                          ),
                          SizedBox(width: 9),
                          Text(
                            // hasServices ? 'Add Service' :
                            'Add Product',
                            style: AppTextStyles.mulish(
                              color: AppColor.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 30),
                    CommonContainer.attractCustomerCard(
                      title: 'Attract More Customers',
                      description: 'Unlock premium to attract more customers',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SubscriptionScreen(),
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: ElevatedButton(
                onPressed: () {
                  // 1️⃣ Always navigate immediately
                  // context.goNamed(AppRoutes.aboutMeScreens, extra: 3);

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
    );
  }

  /*  Widget _buildShopDetails() {
    final isPremium = RegistrationProductSeivice.instance.isPremium;
    final selectedShop = _getSelectedShop(aboutState);
    final products = selectedShop?.products ?? [];
    final services = selectedShop?.services ?? [];

    final bool hasServices = services.isNotEmpty;
    final bool hasProducts = products.isNotEmpty;

    final String title;

    if (hasServices && !hasProducts) {
      title = "Services";
    } else if (hasProducts && !hasServices) {
      title = "Products";
    } else {
      title = "Products & Services";
    }

    return Container(
      key: const ValueKey('shopDetails'),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: [
            AppColor.whiteSmoke,
            AppColor.white,
            AppColor.white,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            _buildShopHeaderCard(aboutState),
            const SizedBox(height: 28),
            if (!isPremium)
              CommonContainer.attractCustomerCard(
                title: 'Attract More Customers',
                description: 'Unlock premium to attract more customers',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SubscriptionScreen(),
                    ),
                  );
                },
              ),
            SizedBox(height: isPremium ? 20 : 40),
            Row(
              children: [
                Image.asset(
                  AppImages.product,
                  height: 35,
                  color: AppColor.darkBlue,
                ),
                const SizedBox(width: 10),
                Text(
                  hasServices ? 'Services' : 'Products',
                  style: AppTextStyles.mulish(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: AppColor.darkBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (!hasServices && !hasProducts)
              Text(
                'No products or services added yet.',
                style: AppTextStyles.mulish(
                  color: AppColor.gray84,
                  fontSize: 14,
                ),
              )
            else if (hasServices)
            // ----------------- SERVICES LIST -----------------
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: services.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, i) {
                  final s = services[i];

                  final title = (s.englishName ?? s.tamilName ?? '').trim();
                  final serviceName = title.isEmpty ? 'Unnamed Service' : title;

                  final rating = (s.rating ?? 0).toDouble().toStringAsFixed(1);
                  final ratingCount = (s.ratingCount ?? 0).toString();

                  final startsAt = s.startsAt ?? 0;
                  final offerPrice = s.offerPrice ?? 0;
                  final priceText = ' ₹$startsAt';
                  final offerPriceText = ' ₹$offerPrice';

                  String imageUrl = '';
                  if (s.media.isNotEmpty) {
                    imageUrl = s.media.first.url ?? '';
                  }

                  return Column(
                    children: [
                      CommonContainer.foodList(
                        fontSize: 14,
                        titleWeight: FontWeight.w700,
                        onTap: () {},
                        imageWidth: 130,
                        image: imageUrl,
                        foodName: serviceName,
                        ratingStar: rating,
                        ratingCount: ratingCount,
                        offAmound: offerPriceText,
                        oldAmound: priceText,
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
                                final prefs =
                                await SharedPreferences.getInstance();
                                // prefs.remove('product_id');
                                prefs.remove('shop_id');
                                prefs.remove('service_id');
                                final selectedShop = _getSelectedShop(
                                  aboutState,
                                );
                                if (selectedShop == null) return;

                                final title =
                                (s.englishName ?? s.tamilName ?? '').trim();
                                final englishName = title.isEmpty
                                    ? 'Unnamed Product'
                                    : title;

                                final updated = await Navigator.push<bool>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ProductCategoryScreens(
                                          page: 'AboutMeScreens',
                                          isService: true,
                                          shopId: selectedShop.shopId,
                                          productId: s.serviceId,
                                          allowOfferEdit: true,
                                          initialCategoryName: s.category,
                                          initialSubCategoryName: s.subCategory,
                                          initialProductName: englishName,
                                          initialPrice: s.startsAt,
                                          initialDescription: s.description,
                                          initialOfferLabel: s.offerLabel,
                                          initialOfferValue: s.offerValue,
                                        ),
                                  ),
                                );

                                //  AFTER POP: refresh automatically
                                if (updated == true && mounted) {
                                  await ref
                                      .read(aboutMeNotifierProvider.notifier)
                                      .fetchAllShopDetails(
                                    shopId:
                                    _currentShopId ??
                                        selectedShop.shopId,
                                  );
                                  setState(() {});
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                  horizontal: 15,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColor.blue,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      AppImages.editImage,
                                      color: AppColor.white,
                                      height: 16,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Edit',
                                      style: AppTextStyles.mulish(
                                        color: AppColor.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          SizedBox(width: 10),
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                // prevent double tap while this service is deleting
                                if (_deletingServiceId == s.serviceId) return;

                                final confirm = await showDialog<bool>(
                                  context: this.context,
                                  builder: (_) => AlertDialog(
                                    backgroundColor: AppColor.white,
                                    title: const Text('Confirm Remove'),
                                    content: const Text(
                                      'Are you sure you want to remove this service?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(this.context, false),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(this.context, true),
                                        child: Text(
                                          'Remove',
                                          style: AppTextStyles.mulish(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm != true) return;
                                if (!mounted) return;

                                setState(
                                      () => _deletingServiceId = s.serviceId,
                                );

                                final success = await ref
                                    .read(productNotifierProvider.notifier)
                                    .deleteServiceAction(
                                  serviceId: s.serviceId,
                                );

                                if (!mounted) return;

                                setState(() => _deletingServiceId = null);

                                final productState = ref.read(
                                  productNotifierProvider,
                                );
                                final deleteMsg =
                                    productState.serviceRemoveResponse?.message;

                                if (success) {
                                  // optional: instant local removal of the service
                                  final currentShop = _getSelectedShop(
                                    aboutState,
                                  );
                                  if (currentShop != null) {
                                    currentShop.services.removeWhere(
                                          (srv) => srv.serviceId == s.serviceId,
                                    );
                                  }

                                  // refresh from backend
                                  await ref
                                      .read(aboutMeNotifierProvider.notifier)
                                      .fetchAllShopDetails(
                                    shopId:
                                    _currentShopId ??
                                        currentShop?.shopId,
                                  );

                                  if (!mounted) return;

                                  ScaffoldMessenger.of(
                                    this.context,
                                  ).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        deleteMsg ??
                                            'Service removed successfully',
                                      ),
                                    ),
                                  );
                                } else {
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(
                                    this.context,
                                  ).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        productState.error ??
                                            'Failed to remove service',
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                  horizontal: 15,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColor.whiteSmoke,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Center(
                                  child: (_deletingServiceId == s.serviceId)
                                      ? ThreeDotsLoader(
                                    dotColor: AppColor.black,
                                  )
                                      : Row(
                                    mainAxisSize: MainAxisSize.min,
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
                                        style: AppTextStyles.mulish(
                                          color: AppColor.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: products.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, i) {
                  final p = products[i];
                  final title = (p.englishName ?? p.tamilName ?? '').trim();
                  final englishName = title.isEmpty ? 'Unnamed Product' : title;

                  final rating = (p.rating ?? 0).toDouble().toStringAsFixed(1);
                  final ratingCount = (p.ratingCount ?? 0).toString();

                  final price = p.price ?? 0;
                  final priceText = '₹$price';

                  final offerPrice = p.offerPrice ?? 0;
                  final offerPriceText = '₹$offerPrice';

                  String imageUrl = '';
                  if (p.media.isNotEmpty) {
                    imageUrl = p.media.first.url ?? '';
                  }

                  final bool hasDoorDelivery = p.doorDelivery == true;

                  return Column(
                    children: [
                      CommonContainer.foodList(
                        fontSize: 14,

                        titleWeight: FontWeight.w700,
                        onTap: () {},
                        imageWidth: 130,
                        image: imageUrl,
                        foodName: englishName,
                        ratingStar: rating,
                        ratingCount: ratingCount,
                        offAmound: offerPriceText,

                        oldAmound: priceText,
                        km: '',
                        location: '',
                        Verify: false,
                        locations: false,
                        weight: false,
                        horizontalDivider: false,
                        doorDelivery: hasDoorDelivery,
                      ),
                      Row(
                        children: [
                          // 🔵 EDIT BUTTON (unchanged)
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                final selectedShop = _getSelectedShop(
                                  aboutState,
                                );
                                if (selectedShop == null) return;

                                final title =
                                (p.englishName ?? p.tamilName ?? '').trim();
                                final englishName = title.isEmpty
                                    ? 'Unnamed Product'
                                    : title;
                                final price = p.price ?? 0;

                                final offerLabel = p.offerLabel;
                                final offerValue = p.offerValue;
                                final description = p.description;
                                final doorDelivery = (p.doorDelivery == true)
                                    ? 'Yes'
                                    : 'No';

                                final updated = await Navigator.push<bool>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ProductCategoryScreens(
                                          page: 'AboutMeScreens',
                                          isService: false,

                                          shopId: selectedShop.shopId,
                                          productId: p.productId,
                                          allowOfferEdit: true,
                                          initialCategoryName: p.category,
                                          initialSubCategoryName: p.subCategory,
                                          initialProductName: englishName,
                                          initialPrice: price,
                                          initialDescription: description,
                                          initialDoorDelivery: doorDelivery,
                                          initialOfferLabel: offerLabel,
                                          initialOfferValue: offerValue,
                                          initialCategorySlug: p.categorySlug,
                                          initialSubCategorySlug:
                                          p.subCategorySlug,
                                        ),
                                  ),
                                );
                                if (updated == true && mounted) {
                                  await ref
                                      .read(aboutMeNotifierProvider.notifier)
                                      .fetchAllShopDetails(
                                    shopId:
                                    _currentShopId ??
                                        selectedShop.shopId,
                                  );
                                  setState(() {});
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                  horizontal: 15,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColor.blue,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      AppImages.editImage,
                                      color: AppColor.white,
                                      height: 16,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Edit',
                                      style: AppTextStyles.mulish(
                                        color: AppColor.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),

                          //  REMOVE BUTTON (NOW WIRED TO API)
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                if (_deletingProductId == p.productId) return;

                                // use page-level context for dialog (safer)
                                final confirm = await showDialog<bool>(
                                  context: this.context,
                                  builder: (_) => AlertDialog(
                                    backgroundColor: AppColor.white,
                                    title: const Text('Confirm Remove'),
                                    content: const Text(
                                      'Are you sure you want to remove this product?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(this.context, false),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(this.context, true),
                                        child: Text(
                                          'Remove',
                                          style: AppTextStyles.mulish(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm != true) return;
                                if (!mounted) return;

                                setState(
                                      () => _deletingProductId = p.productId,
                                );

                                final success = await ref
                                    .read(productNotifierProvider.notifier)
                                    .deleteProductAction(
                                  productId: p.productId,
                                );

                                if (!mounted) return;

                                setState(() => _deletingProductId = null);

                                final productState = ref.read(
                                  productNotifierProvider,
                                );
                                final deleteMsg =
                                    productState.DeleteResponses?.message;

                                if (success) {
                                  // (optional) local remove – only if you want instant effect
                                  final currentShop = _getSelectedShop(
                                    aboutState,
                                  );
                                  if (currentShop != null) {
                                    currentShop.products.removeWhere(
                                          (prod) => prod.productId == p.productId,
                                    );
                                  }

                                  // refresh from backend
                                  await ref
                                      .read(aboutMeNotifierProvider.notifier)
                                      .fetchAllShopDetails(
                                    shopId:
                                    _currentShopId ??
                                        currentShop?.shopId,
                                  );

                                  if (!mounted) return;

                                  setState(() {});

                                  // IMPORTANT: use page context, NOT the row context
                                  ScaffoldMessenger.of(
                                    this.context,
                                  ).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        deleteMsg ??
                                            'Product removed successfully',
                                      ),
                                    ),
                                  );
                                } else {
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(
                                    this.context,
                                  ).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        productState.error ??
                                            'Failed to remove product',
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                  horizontal: 15,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColor.whiteSmoke,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Center(
                                  child: (_deletingProductId == p.productId)
                                      ? ThreeDotsLoader(
                                    dotColor: AppColor.black,
                                  )
                                      : Row(
                                    mainAxisSize: MainAxisSize.min,
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
                                        style: AppTextStyles.mulish(
                                          color: AppColor.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),

            const SizedBox(height: 20),

            // 🔹 Add Product / Service
            InkWell(
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();
                prefs.remove('product_id');
                prefs.remove('shop_id');
                prefs.remove('service_id');
                final selectedShop = _getSelectedShop(aboutState);
                if (selectedShop == null) return;

                final added = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductCategoryScreens(
                      page: 'AboutMeScreens',
                      shopId: selectedShop.shopId,
                      isService: hasServices,
                      allowOfferEdit: true,
                    ),
                  ),
                );

                if (added == true && mounted) {
                  await ref
                      .read(aboutMeNotifierProvider.notifier)
                      .fetchAllShopDetails(
                    shopId: _currentShopId ?? selectedShop.shopId,
                  );
                  setState(() {});
                }
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(),
                  color: AppColor.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(vertical: 15.5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      AppImages.addListImage,
                      height: 22,
                      color: AppColor.darkBlue,
                    ),
                    SizedBox(width: 9),
                    Text(
                      hasServices ? 'Add Service' : 'Add Product',
                      style: AppTextStyles.mulish(
                        color: AppColor.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            Row(
              children: [
                Image.asset(AppImages.reviewImage, height: 27.08, width: 26),
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
            const SizedBox(height: 21),
            Row(
              children: [
                Text(
                  ((selectedShop?.shopRating ?? 0.0).toStringAsFixed(1)),
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
              'Based on ${(selectedShop?.shopReviewCount ?? 0)} reviews',
              style: AppTextStyles.mulish(color: AppColor.gray84),
            ),
            */ /*      const SizedBox(height: 17),
            CommonContainer.reviewBox(),
            const SizedBox(height: 17),
            CommonContainer.reviewBox(),*/ /*
          ],
        ),
      ),
    );
  }*/
}
