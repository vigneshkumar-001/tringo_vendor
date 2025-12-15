import 'package:dotted_border/dotted_border.dart';
import 'package:dotted_border/dotted_border.dart' as dotted;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../Core/Const/app_color.dart';
import '../../../../Core/Const/app_images.dart';
import '../../../../Core/Utility/app_textstyles.dart';
import '../../../../Core/Widgets/app_go_routes.dart';
import '../../../../Core/Widgets/common_container.dart';

class HeaterEmployeeDetails extends StatefulWidget {
  const HeaterEmployeeDetails({super.key});

  @override
  State<HeaterEmployeeDetails> createState() => _HeaterEmployeeDetailsState();
}

class _HeaterEmployeeDetailsState extends State<HeaterEmployeeDetails> {
  int selectedIndex = 0;

  final List<Map<String, dynamic>> categoryTabs = [
    {"label": "22 Pro Premium User", "image": AppImages.premiumImage},
    {"label": "4 Premium Users", "image": AppImages.premiumImage01},
    {"label": "4 Free Users", "image": AppImages.premiumImage01},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
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
                    SizedBox(width: 80),
                    Text(
                      'Employee Details',
                      style: AppTextStyles.mulish(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColor.mildBlack,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 35),
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(AppImages.registerBCImage),
                  ),
                  gradient: LinearGradient(
                    colors: [AppColor.white, AppColor.mintCream],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(20),
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
                                  vertical: 15,
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
                                AppRoutes.heaterEmployeeDetailsEditPath,
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: AppColor.black.withOpacity(0.1),
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14.5,
                                  vertical: 17.5,
                                ),
                                child: Image.asset(
                                  AppImages.editImage,
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
              SizedBox(height: 25),
              Center(
                child: Text(
                  'Shops & Services',
                  style: AppTextStyles.mulish(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColor.darkBlue,
                  ),
                ),
              ),
              SizedBox(height: 0),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 25,
                ),
                child: Row(
                  children: List.generate(categoryTabs.length, (index) {
                    final isSelected = selectedIndex == index;
                    final category = categoryTabs[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: CommonContainer.premiumCategory(
                        appImage: category["image"],
                        ContainerColor:
                            isSelected
                                ? AppColor.white
                                : AppColor.black.withOpacity(0.05),
                        BorderColor:
                            isSelected
                                ? AppColor.deepTeaBlue
                                : Colors.transparent,
                        TextColor:
                            isSelected ? AppColor.darkBlue : AppColor.darkBlue,
                        categoryTabs[index]["label"],
                        isSelected: isSelected,
                        onTap: () {
                          setState(() => selectedIndex = index);
                        },
                      ),
                    );
                  }),
                ),
              ),
              SizedBox(height: 0),
              Center(
                child: Text(
                  'Today',
                  style: AppTextStyles.mulish(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColor.darkGrey,
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
                                    // Navigator.push(
                                    //   context,
                                    //   MaterialPageRoute(
                                    //     builder: (context) =>
                                    //         CommonBottomNavigation(initialIndex: 1),
                                    //   ),
                                    // );
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
                                    // Navigator.push(
                                    //   context,
                                    //   MaterialPageRoute(
                                    //     builder: (context) =>
                                    //         CommonBottomNavigation(initialIndex: 1),
                                    //   ),
                                    // );
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
              SizedBox(height: 44),
            ],
          ),
        ),
      ),
    );
  }
}
