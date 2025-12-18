import 'package:dotted_border/dotted_border.dart';
import 'package:dotted_border/dotted_border.dart' as dotted;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../Core/Const/app_color.dart';
import '../../../Core/Const/app_images.dart';
import '../../../Core/Utility/app_textstyles.dart';
import '../../../Core/Utility/filter_popup_screen.dart';
import '../../../Core/Utility/sortby_popup_screen.dart';
import '../../../Core/Widgets/app_go_routes.dart';

class EmployeeHistory extends ConsumerStatefulWidget {
  const EmployeeHistory({super.key});

  @override
  ConsumerState<EmployeeHistory> createState() => _EmployeeHistoryState();
}

class _EmployeeHistoryState extends ConsumerState<EmployeeHistory> {
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
                padding: const EdgeInsets.symmetric(horizontal: 15),
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
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColor.black.withOpacity(0.054),
                                    AppColor.black.withOpacity(0.0),
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 15,
                                  vertical: 10,
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      'Product',
                                      style: AppTextStyles.mulish(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: AppColor.darkBlue,
                                      ),
                                    ),
                                    SizedBox(width: 6),
                                    Image.asset(
                                      AppImages.rightArrow,
                                      height: 10,
                                      color: AppColor.darkGrey,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      'Textiles',
                                      style: AppTextStyles.mulish(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: AppColor.darkBlue,
                                      ),
                                    ),
                                    SizedBox(width: 6),
                                    Image.asset(
                                      AppImages.rightArrow,
                                      height: 10,
                                      color: AppColor.darkGrey,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      'Mens Wear',
                                      style: AppTextStyles.mulish(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: AppColor.darkBlue,
                                      ),
                                    ),
                                    SizedBox(width: 6),
                                    Image.asset(
                                      AppImages.rightArrow,
                                      height: 10,
                                      color: AppColor.darkGrey,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: AspectRatio(
                                aspectRatio:
                                    328 / 143, // your original image ratio
                                child: Image.asset(
                                  AppImages.homeImage1,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),

                            SizedBox(height: 20),
                            Text(
                              'Kandhasamy Mobiles',
                              style: AppTextStyles.mulish(
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                                color: AppColor.darkBlue,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              '77, Nehru St, Sathyamoorthy Nagar, State Bank Supervisors Colony, Madurai, Tamil Nadu 625016',
                              style: AppTextStyles.mulish(
                                fontWeight: FontWeight.w400,
                                fontSize: 12,
                                color: AppColor.lightGray3,
                              ),
                            ),
                            SizedBox(height: 20),
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
                                DottedBorder(
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
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '2Months Pro Premium',
                                          style: AppTextStyles.mulish(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 12,
                                            color: AppColor.darkBlue,
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
                                Spacer(),
                                GestureDetector(
                                  onTap: () {
                                    context.push(AppRoutes.shopDetailsEditPath);
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 13,
                                      vertical: 7.5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColor.black,
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    child: Image.asset(
                                      AppImages.rightStickArrow,
                                      height: 19,
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
              SizedBox(height: 25),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  children: [
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
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColor.black.withOpacity(0.054),
                                    AppColor.black.withOpacity(0.0),
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 15,
                                  vertical: 10,
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      'Product',
                                      style: AppTextStyles.mulish(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: AppColor.darkBlue,
                                      ),
                                    ),
                                    SizedBox(width: 6),
                                    Image.asset(
                                      AppImages.rightArrow,
                                      height: 10,
                                      color: AppColor.darkGrey,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      'Daily',
                                      style: AppTextStyles.mulish(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: AppColor.darkBlue,
                                      ),
                                    ),
                                    SizedBox(width: 6),
                                    Image.asset(
                                      AppImages.rightArrow,
                                      height: 10,
                                      color: AppColor.darkGrey,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      'Grocery',
                                      style: AppTextStyles.mulish(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: AppColor.darkBlue,
                                      ),
                                    ),
                                    SizedBox(width: 6),
                                    Image.asset(
                                      AppImages.rightArrow,
                                      height: 10,
                                      color: AppColor.darkGrey,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: AspectRatio(
                                aspectRatio:
                                    328 / 143, // your original image ratio
                                child: Image.asset(
                                  AppImages.homeImage2,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),

                            SizedBox(height: 20),
                            Text(
                              'HJ Grocery Stores',
                              style: AppTextStyles.mulish(
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                                color: AppColor.darkBlue,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              '77, Nehru St, Sathyamoorthy Nagar, State Bank Supervisors Colony, Madurai, Tamil Nadu 625016',
                              style: AppTextStyles.mulish(
                                fontWeight: FontWeight.w400,
                                fontSize: 12,
                                color: AppColor.lightGray3,
                              ),
                            ),
                            SizedBox(height: 20),
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
                                DottedBorder(
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
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '1Year Premium ',
                                          style: AppTextStyles.mulish(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 12,
                                            color: AppColor.darkBlue,
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
                                Spacer(),
                                // SizedBox(width: 10),
                                GestureDetector(
                                  onTap: () {
                                    context.push(AppRoutes.shopDetailsEditPath);
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 13,
                                      vertical: 7.5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColor.black,
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    child: Image.asset(
                                      AppImages.rightStickArrow,
                                      height: 19,
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
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
