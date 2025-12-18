import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tringo_vendor_new/Core/Const/app_color.dart';
import 'package:tringo_vendor_new/Core/Utility/app_textstyles.dart';
import 'package:tringo_vendor_new/Core/Widgets/app_go_routes.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../Core/Const/app_images.dart';
import '../../../../Core/Utility/filter_popup_screen.dart';
import '../../../../Core/Utility/sortby_popup_screen.dart';
import '../../../../Core/Widgets/bottom_navigation_bar.dart';
import '../../Add Vendor Employee/Screen/heater_add_employee.dart';

class HeaterEmployeesList extends StatefulWidget {
  const HeaterEmployeesList({super.key});

  @override
  State<HeaterEmployeesList> createState() => _HeaterEmployeesListState();
}

class _HeaterEmployeesListState extends State<HeaterEmployeesList> {
  bool _showSearch = false;
  final TextEditingController _searchController = TextEditingController();

  Future<void> _launchDialer(String phoneNumber) async {
    final Uri uri = Uri(scheme: 'tel', path: phoneNumber);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {

      debugPrint('Could not launch dialer for $phoneNumber');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Text(
                      'Employees',
                      style: AppTextStyles.mulish(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColor.darkBlue,
                      ),
                    ),
                    Spacer(),
                    Text(
                      'Add Employees',
                      style: AppTextStyles.mulish(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColor.darkBlue,
                      ),
                    ),
                    SizedBox(width: 10),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HeaterAddEmployee(),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColor.black,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Image.asset(
                          AppImages.rightStickArrow,
                          height: 19,
                        ),
                      ),
                    ),
                  ],
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
              SizedBox(height: 25),
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
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: SizedBox(
                                height: 115,
                                width: 92,
                                child: Image.asset(
                                  AppImages.humanImage1,
                                  width: 92,
                                  height: 115,
                                ),
                                // Image.network(
                                //    data.avatarUrl ?? "",
                                //   fit: BoxFit.cover,
                                //   errorBuilder: (_, __, ___) {
                                //     return const Center(
                                //       child: Icon(
                                //         Icons.broken_image,
                                //         size: 40,
                                //       ),
                                //     );
                                //   },
                                // ),
                              ),
                            ),
                            SizedBox(width: 20),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Siva',
                                  // data.name,
                                  style: AppTextStyles.mulish(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                    color: AppColor.darkBlue,
                                  ),
                                ),
                                SizedBox(height: 3),
                                Text(
                                  'THU29849H',
                                  // data.employeeCode,
                                  style: AppTextStyles.mulish(
                                    fontSize: 11,
                                    color: AppColor.mildBlack,
                                  ),
                                ),
                                SizedBox(height: 20),
                                Text(
                                  'Today Collection',
                                  style: AppTextStyles.mulish(
                                    fontSize: 10,
                                    color: AppColor.gray84,
                                  ),
                                ),
                                Text(
                                  // 'Rs.${data.todayAmount}',
                                  'Rs. 49,098',
                                  style: AppTextStyles.mulish(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 18,
                                    color: AppColor.mildBlack,
                                  ),
                                ),
                              ],
                            ),
                            Spacer(),
                            Column(
                              children: [
                                InkWell(
                                  onTap: () {
                                    // if (data.phoneNumber.isNotEmpty) {
                                    //   _launchDialer(data.phoneNumber);
                                    // }
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: AppColor.black,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14.5,
                                        vertical: 19.5,
                                      ),
                                      child: Image.asset(
                                        AppImages.callImage1,
                                        height: 12,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 15),
                                InkWell(
                                  onTap: () {
                                    context.push(
                                      AppRoutes.heaterEmployeeDetailsPath,
                                    );
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: AppColor.black.withOpacity(0.5),
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14.5,
                                        vertical: 14.5,
                                      ),
                                      child: Image.asset(
                                        AppImages.rightArrow,
                                        color: AppColor.darkBlue,
                                        height: 12,
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
                    SizedBox(height: 15),
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
