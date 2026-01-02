import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../Core/Const/app_color.dart';
import '../../../Core/Const/app_images.dart';
import '../../../Core/Utility/app_textstyles.dart';
import '../../../Core/Widgets/common_container.dart';
import '../../ShopInfo/Screens/shop_category_info.dart';

class MoreDetails extends StatefulWidget {
  const MoreDetails({super.key});

  @override
  State<MoreDetails> createState() => _MoreDetailsState();
}

class _MoreDetailsState extends State<MoreDetails> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                          CommonContainer.topLeftArrow(onTap: () {}),

                          Spacer(),
                          CommonContainer.gradientContainer(
                            text: "Sweets & Bakery",
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
                              CommonContainer.doorDelivery(
                                text: 'Door Delivery',
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                textColor: AppColor.skyBlue,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            " Sri Krishna Sweets Private Limited",
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
                                  "12, 2, Tirupparankunram Rd, kunram ",
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
                        const SizedBox(height: 27),

                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: CommonContainer.callNowButton(
                              callOnTap: () {},

                              // () => _openDialer(shop?.shopPhone ?? ''),
                              callImage: AppImages.callImage,
                              callText: 'Call Now',
                              whatsAppIcon: true,
                              whatsAppOnTap: () {},
                              messageOnTap: () {},
                              MessageIcon: true,
                              mapText: 'Map',
                              mapOnTap: () {},
                              //     () =>
                              //         _openMap(
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

                        const SizedBox(height: 20),

                        SizedBox(
                          height: 250,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 15),

                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 10.0),
                                  child: Stack(
                                    children: [
                                      ClipRRect(
                                        clipBehavior: Clip.antiAlias,
                                        borderRadius: BorderRadius.circular(20),

                                        child: Image.asset(
                                          AppImages.homeImage1,
                                        ),
                                      ),
                                      Positioned(
                                        top: 20,
                                        left: 15,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColor.scaffoldColor,
                                            borderRadius: BorderRadius.circular(
                                              30,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,

                                            children: [
                                              Text(
                                                // (shop?.shopRating ?? 0.0)
                                                //     .toStringAsFixed(1),
                                                '4.1',
                                                style: AppTextStyles.mulish(
                                                  fontWeight: FontWeight.bold,
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
                                                      BorderRadius.circular(1),
                                                ),
                                              ),
                                              const SizedBox(width: 5),
                                              Text(
                                                // (shop?.shopReviewCount ?? 0)
                                                //     .toString(),
                                                '16',
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
                                ),
                              ],
                            ),
                          ),
                        ),

                        // // if (showAddBranch)
                        //   GestureDetector(
                        //     // onTap: () {
                        //     //   Navigator.push(
                        //     //     context,
                        //     //     MaterialPageRoute(
                        //     //       builder:
                        //     //           (context) => const ShopCategoryInfo(
                        //     //         // isEditMode: true,
                        //     //         initialShopNameEnglish:
                        //     //         shopDisplayName,
                        //     //         initialShopNameTamil:
                        //     //         shopDisplayNameTamil,
                        //     //         isService: true,
                        //     //         isIndividual: false,
                        //     //       ),
                        //     //     ),
                        //     //   );
                        //     // },
                        //     child: Padding(
                        //       padding: const EdgeInsets.symmetric(
                        //         horizontal: 15,
                        //         vertical: 15,
                        //       ),
                        //       child: Container(
                        //         decoration: BoxDecoration(
                        //           border: Border.all(
                        //             color: AppColor.borderLightGrey,
                        //             width: 2,
                        //           ),
                        //           borderRadius: BorderRadius.circular(22),
                        //         ),
                        //         child: Padding(
                        //           padding: const EdgeInsets.symmetric(
                        //             vertical: 20,
                        //           ),
                        //           child: Row(
                        //             mainAxisAlignment:
                        //                 MainAxisAlignment.center,
                        //             children: [
                        //               Image.asset(
                        //                 AppImages.addBranch,
                        //                 height: 22,
                        //               ),
                        //               const SizedBox(width: 10),
                        //               Text(
                        //                 'Add Branch',
                        //                 style: AppTextStyles.mulish(
                        //                   color: AppColor.darkBlue,
                        //                 ),
                        //               ),
                        //             ],
                        //           ),
                        //         ),
                        //       ),
                        //     ),
                        //   ),
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
                    CommonContainer.foodList(
                      fontSize: 14,
                      doorDelivery: true,
                      titleWeight: FontWeight.w700,
                      onTap: () {},
                      imageWidth: 130,
                      image: AppImages.humanImage1,
                      foodName: 'Badam Mysurpa',
                      ratingStar: '4.1',
                      ratingCount: '16',
                      offAmound: '₹79',
                      oldAmound: '₹110',
                      km: '',
                      location: '',
                      Verify: false,
                      locations: false,
                      weight: false,
                      horizontalDivider: false,
                    ),
                    SizedBox(height: 20),
                    InkWell(
                      onTap: () {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) =>
                        //         ProductCategoryScreens(
                        //           shopId: shop.shopId,
                        //         ),
                        //   ),
                        // );
                      },
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColor.lowGery1,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 22.5),
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
                    SizedBox(height: 40),
                    CommonContainer.attractCustomerCard(
                      title: "Attract More Customers",
                      description: 'Unlock premium to attract more customers',
                      onTap: () {},
                    ),
                    SizedBox(height: 48),
                    Row(
                      children: [
                        Image.asset(
                          AppImages.reviewImage,
                          height: 35,
                          color: AppColor.darkBlue,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Reviews',
                          style: AppTextStyles.mulish(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                            color: AppColor.darkBlue,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 21),
                    Row(
                      children: [
                        Text(
                          '4.5',
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
                    SizedBox(height: 10),
                    Text(
                      'Based on 58 reviews',
                      style: AppTextStyles.mulish(color: AppColor.gray84),
                    ),
                    SizedBox(height: 20),
                    CommonContainer.reviewBox(),
                    SizedBox(height: 17),
                    CommonContainer.reviewBox(),
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: ElevatedButton(
                onPressed: () {},
                // onPressed: () async {
                //   // 1️⃣ Always navigate immediately
                //   context.goNamed(AppRoutes.home);
                //   await ref
                //       .read(employeeHomeNotifier.notifier)
                //       .employeeHome(date: '', page: '1', limit: '6', q: '');
                //   // await ref
                //   //     .read(selectedShopProvider.notifier)
                //   //     .switchShop('');
                //
                //   Future.microtask(() {
                //     RegistrationSession.instance.reset();
                //     // RegistrationProductSeivice.instance.reset();
                //   });
                // },
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
    );
  }
}
