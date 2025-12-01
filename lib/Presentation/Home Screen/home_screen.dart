import 'dart:math' as math;

import 'package:dotted_border/dotted_border.dart';
import 'package:dotted_border/dotted_border.dart' as dotted;
import 'package:flutter/material.dart';
import 'package:tringo_vendor_new/Core/Const/app_color.dart';
import 'package:tringo_vendor_new/Core/Const/app_images.dart';
import 'package:tringo_vendor_new/Core/Utility/app_textstyles.dart';

import '../../Core/Widgets/bottom_navigation_bar.dart';
import '../../Core/Widgets/common_container.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
              Container(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(AppImages.homeScreenTopBCImage),
                  ),
                  gradient: LinearGradient(
                    colors: [AppColor.richNavy, AppColor.richBlack],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(25),
                    bottomRight: Radius.circular(25),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Siva',
                                style: AppTextStyles.mulish(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: AppColor.white,
                                ),
                              ),
                              Text(
                                'TGV69040V49',
                                style: AppTextStyles.mulish(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                  color: AppColor.lightGray1,
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    'Reporting',
                                    style: AppTextStyles.mulish(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 10,
                                      color: AppColor.white4,
                                    ),
                                  ),
                                  SizedBox(width: 3),
                                  Text(
                                    '-',
                                    style: AppTextStyles.mulish(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 10,
                                      color: AppColor.white4,
                                    ),
                                  ),
                                  SizedBox(width: 3),
                                  Text(
                                    'Johndue',
                                    style: AppTextStyles.mulish(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 10,
                                      color: AppColor.white4,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Spacer(),
                          Container(
                            decoration: BoxDecoration(
                              color: AppColor.white.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Image.asset(
                                AppImages.cloudImage,
                                height: 22.5,
                                width: 25.85,
                              ),
                            ),
                          ),
                          SizedBox(width: 15),
                          ClipOval(
                            child: Image.asset(
                              AppImages.profileImage,
                              height: 52,
                              width: 52,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 40),
                      _TotalEntryDonut(value: 26, label: 'Total Entry'),
                      SizedBox(height: 25),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 120,
                        ),
                        child: InkWell(
                          onTap: () {},
                          child: DottedBorder(
                            color: AppColor.lightBlueBorder,
                            dashPattern: [4.0, 5.0],
                            borderType: dotted.BorderType.RRect,
                            padding: EdgeInsets.all(10),
                            radius: Radius.circular(18),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Today',
                                  style: AppTextStyles.mulish(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 12,
                                    color: AppColor.white,
                                  ),
                                ),
                                SizedBox(width: 7),
                                Image.asset(
                                  AppImages.drapDownImage,
                                  height: 14,
                                  width: 10,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 15),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Activity',
                      style: AppTextStyles.mulish(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
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
              SizedBox(height: 20),
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
              SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'View All Users',
                    style: AppTextStyles.mulish(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(width: 20),
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
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColor.black,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Image.asset(AppImages.rightStickArrow, height: 12),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _TotalEntryDonut extends StatelessWidget {
  final int value;
  final String label;

  const _TotalEntryDonut({Key? key, required this.value, required this.label})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    const double size = 220;

    return Center(
      child: SizedBox(
        height: size,
        width: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            /// 🎨 Figma-style ring
            CustomPaint(
              size: const Size(size, size),
              painter: _FigmaRingPainter(
                backgroundColor: AppColor.steelNavy,
                startColor: AppColor.blueGradient3, // bright blue
                endColor:
                    AppColor.blueGradient2, // another blue (no dark shadow)
              ),
            ),

            /// ⬛ Inner rounded square
            Container(
              height: 140,
              width: 140,
              decoration: BoxDecoration(
                color: AppColor.midnightBlue,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    value.toString(),
                    style: AppTextStyles.mulish(
                      fontWeight: FontWeight.w800,
                      fontSize: 26,
                      color: AppColor.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: AppTextStyles.mulish(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: AppColor.white4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ===================  PAINTER  ===================

/// Draws:
/// 1. Outer rounded-square blue ring
/// 2. Dark top-left quarter
/// 3. Inner rounded-square cutout (donut hole)
class _FigmaRingPainter extends CustomPainter {
  final Color backgroundColor;
  final Color startColor;
  final Color endColor;

  _FigmaRingPainter({
    required this.backgroundColor,
    required this.startColor,
    required this.endColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Rect outerRect = Offset.zero & size;

    // 🔵 Outer rounded square
    final double outerRadius = size.width * 0.35;
    final RRect outerRRect = RRect.fromRectAndRadius(
      outerRect,
      Radius.circular(outerRadius),
    );

    final Paint ringPaint =
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [startColor, endColor],
          ).createShader(outerRect)
          ..style = PaintingStyle.fill;

    canvas.drawRRect(outerRRect, ringPaint);

    // 🌑 Top-left dark quarter
    final Paint quarterPaint =
        Paint()
          ..color = backgroundColor
          ..style = PaintingStyle.fill;

    canvas.save();
    canvas.clipRRect(outerRRect); // stay inside rounded square
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width / 2, size.height / 2),
      quarterPaint,
    );
    canvas.restore();

    // ⬜ Inner rounded square to create donut
    final double inset = size.width * 0.18; // controls ring thickness
    final Rect innerRect = Rect.fromLTWH(
      inset,
      inset,
      size.width - 2 * inset,
      size.height - 2 * inset,
    );
    final double innerRadius = size.width * 0.24;
    final RRect innerRRect = RRect.fromRectAndRadius(
      innerRect,
      Radius.circular(innerRadius),
    );

    final Paint cutPaint =
        Paint()
          ..color = backgroundColor
          ..style = PaintingStyle.fill;

    canvas.drawRRect(innerRRect, cutPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
