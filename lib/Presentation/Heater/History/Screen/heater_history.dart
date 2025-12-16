import 'package:dotted_border/dotted_border.dart';
import 'package:dotted_border/dotted_border.dart' as dotted;
import 'package:flutter/material.dart';
import 'package:tringo_vendor_new/Core/Const/app_color.dart';
import 'package:tringo_vendor_new/Core/Utility/app_textstyles.dart';
import 'package:tringo_vendor_new/Core/Widgets/common_container.dart';

import '../../../../Core/Const/app_images.dart';
import '../../../../Core/Utility/filter_popup_screen.dart';
import '../../../../Core/Utility/sortby_popup_screen.dart';

class HeaterHistory extends StatefulWidget {
  const HeaterHistory({super.key});

  @override
  State<HeaterHistory> createState() => _HeaterHistoryState();
}

class _HeaterHistoryState extends State<HeaterHistory> {
  bool _showSearch = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Text(
                  'History',
                  style: AppTextStyles.mulish(
                    fontWeight: FontWeight.w700,
                    fontSize: 24,
                    color: AppColor.darkBlue,
                  ),
                ),
              ),
              SizedBox(height: 10),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _showSearch = true;
                        });
                      },
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child:
                            _showSearch
                                ? Container(
                                  key: const ValueKey('searchField'),
                                  width: 260,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: AppColor.darkBlue,
                                    ),
                                    borderRadius: BorderRadius.circular(25),
                                    color: AppColor.white,
                                  ),
                                  child: Row(
                                    children: [
                                      Image.asset(
                                        AppImages.searchImage,
                                        height: 14,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: TextField(
                                          controller: _searchController,
                                          autofocus: true,
                                          decoration: const InputDecoration(
                                            hintText: 'Search...',
                                            border: InputBorder.none,
                                          ),
                                          onChanged: (value) {
                                            // 🔍 filter logic here
                                          },
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          setState(() {
                                            _searchController.clear();
                                            _showSearch = false;
                                          });
                                        },
                                        child: const Icon(
                                          Icons.close,
                                          size: 18,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                                : Container(
                                  key: const ValueKey('searchButton'),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: AppColor.darkBlue,
                                    ),
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 47,
                                    vertical: 8,
                                  ),
                                  child: Row(
                                    children: [
                                      Image.asset(
                                        AppImages.searchImage,
                                        height: 14,
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        'Search',
                                        style: AppTextStyles.mulish(
                                          color: AppColor.darkBlue,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                      ),
                    ),

                    SizedBox(width: 10),
                    GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          isScrollControlled:
                              true, // needed for tall sheet + keyboard
                          backgroundColor: Colors.transparent,
                          context: context,
                          showDragHandle: true,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                          ),
                          builder: (_) => FilterPopupScreen(),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColor.lightGray2),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 17,
                            vertical: 9,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Filter',
                                style: AppTextStyles.mulish(
                                  color: AppColor.lightGray2,
                                ),
                              ),
                              SizedBox(width: 10),
                              Image.asset(AppImages.drapDownImage, height: 19),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          backgroundColor: Colors.transparent,
                          context: context,
                          isScrollControlled: true,
                          showDragHandle: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                          ),
                          builder: (_) => SortbyPopupScreen(),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColor.lightGray2),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 17,
                            vertical: 9,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Sort By',
                                style: AppTextStyles.mulish(
                                  color: AppColor.lightGray2,
                                ),
                              ),
                              SizedBox(width: 10),
                              Image.asset(AppImages.drapDownImage, height: 19),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: Text(
                  'Today',
                  style: AppTextStyles.mulish(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColor.lightGray2,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: AppColor.ivoryGreen,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  '₹30 Commission',
                                  style: AppTextStyles.mulish(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: AppColor.darkBlue,
                                  ),
                                ),
                                Spacer(),
                                Text(
                                  'Sivan',
                                  style: AppTextStyles.mulish(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: AppColor.darkBlue,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 15),
                            CommonContainer.horizonalDivider(),
                            SizedBox(height: 15),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Kandhasamy Mobiles',
                                        style: AppTextStyles.mulish(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: AppColor.darkBlue,
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        '77, Nehru St, Sathyamoorthy Nagar, State Bank Supervisors Colony, Madurai, Tamil Nadu 625016',
                                        style: AppTextStyles.mulish(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: AppColor.gray84,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 40),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: SizedBox(
                                    height: 60,
                                    width: 60,
                                    child: Image.asset(
                                      AppImages.homeImage1,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 15),
                            Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: AppColor.white,
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Image.asset(
                                      AppImages.premiumImage,
                                      height: 16,
                                      width: 17,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: DottedBorder(
                                    color: AppColor.black.withOpacity(0.2),
                                    dashPattern: [3.0, 2.0],
                                    borderType: dotted.BorderType.RRect,
                                    padding: EdgeInsets.all(10),
                                    radius: Radius.circular(18),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 5,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              '2 Months Pro Premium',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: AppTextStyles.mulish(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 12,
                                                color: AppColor.darkBlue,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 10),
                                          Text(
                                            '10.40Pm',
                                            style: AppTextStyles.mulish(
                                              fontWeight: FontWeight.w400,
                                              fontSize: 12,
                                              color: AppColor.lightGray3,
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
                      ),
                    ),
                    SizedBox(height: 25,),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColor.iceGray,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  '₹50 Commission',
                                  style: AppTextStyles.mulish(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: AppColor.darkBlue,
                                  ),
                                ),
                                Spacer(),
                                Text(
                                  'Harish',
                                  style: AppTextStyles.mulish(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: AppColor.darkBlue,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 15),
                            CommonContainer.horizonalDivider(),
                            SizedBox(height: 15),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Kandhasamy Mobiles',
                                        style: AppTextStyles.mulish(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: AppColor.darkBlue,
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        '77, Nehru St, Sathyamoorthy Nagar, State Bank Supervisors Colony, Madurai, Tamil Nadu 625016',
                                        style: AppTextStyles.mulish(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: AppColor.gray84,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 40),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: SizedBox(
                                    height: 60,
                                    width: 60,
                                    child: Image.asset(
                                      AppImages.homeImage1,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 15),
                            Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: AppColor.white,
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Image.asset(
                                      AppImages.premiumImage01,
                                      height: 16,
                                      width: 17,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: DottedBorder(
                                    color: AppColor.black.withOpacity(0.2),
                                    dashPattern: [3.0, 2.0],
                                    borderType: dotted.BorderType.RRect,
                                    padding: EdgeInsets.all(10),
                                    radius: Radius.circular(18),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 5,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              '1 Year Premium',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: AppTextStyles.mulish(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 12,
                                                color: AppColor.darkBlue,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 10),
                                          Text(
                                            '10.40Pm',
                                            style: AppTextStyles.mulish(
                                              fontWeight: FontWeight.w400,
                                              fontSize: 12,
                                              color: AppColor.lightGray3,
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
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
