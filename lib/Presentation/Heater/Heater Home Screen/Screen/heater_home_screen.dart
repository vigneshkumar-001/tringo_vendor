import 'dart:math' as math;

import 'package:dotted_border/dotted_border.dart';
import 'package:dotted_border/dotted_border.dart' as dotted;
import 'package:flutter/material.dart';
import 'package:tringo_vendor_new/Core/Const/app_color.dart';
import 'package:tringo_vendor_new/Core/Const/app_images.dart';
import 'package:tringo_vendor_new/Core/Utility/app_textstyles.dart';

import '../../../../Core/Widgets/common_container.dart';

class HeaterHomeScreen extends StatefulWidget {
  const HeaterHomeScreen({super.key});

  @override
  State<HeaterHomeScreen> createState() => _HeaterHomeScreenState();
}

class _HeaterHomeScreenState extends State<HeaterHomeScreen> {
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
                padding: EdgeInsets.symmetric(horizontal: 0, vertical: 20),
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
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
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
                                SizedBox(height: 3),
                                Text(
                                  'TGV69040V49',
                                  style: AppTextStyles.mulish(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                    color: AppColor.lightGray1,
                                  ),
                                ),
                                Text(
                                  '8 Employees',
                                  style: AppTextStyles.mulish(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 10,
                                    color: AppColor.white4,
                                  ),
                                ),
                              ],
                            ),
                            Spacer(),
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
                      ),
                      SizedBox(height: 40),
                      _TotalEntryDonut(value: 26, label: 'Total Entry'),
                      SizedBox(height: 25),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 25,
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: AppColor.white.withOpacity(
                                  0.1,
                                ), // card color
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.4),
                                    blurRadius: 20,
                                    offset: Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // left vertical blue bar
                                  Container(
                                    width: 6,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(999),
                                      color: AppColor.steelBlueGray,
                                      // gradient: const LinearGradient(
                                      //   begin: Alignment.topCenter,
                                      //   end: Alignment.bottomCenter,
                                      //   colors: [
                                      //     Color(0xFF00D2FF),
                                      //     Color(0xFF0072FF),
                                      //   ],
                                      // ),
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  // text
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Rs. 0',
                                        style: AppTextStyles.mulish(
                                          color: AppColor.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Text(
                                            '5',
                                            style: AppTextStyles.mulish(
                                              fontWeight: FontWeight.w700,
                                              color: AppColor.borderLightGrey,
                                              fontSize: 10,
                                            ),
                                          ),
                                          SizedBox(width: 3),
                                          Text(
                                            'Premium Pro',
                                            style: AppTextStyles.mulish(
                                              color: AppColor.borderLightGrey,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 15),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: AppColor.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.4),
                                    blurRadius: 20,
                                    offset: Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // left vertical blue bar
                                  Container(
                                    width: 6,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(999),
                                      color: AppColor.blue,
                                      // gradient: const LinearGradient(
                                      //   begin: Alignment.topCenter,
                                      //   end: Alignment.bottomCenter,
                                      //   colors: [
                                      //     Color(0xFF00D2FF),
                                      //     Color(0xFF0072FF),
                                      //   ],
                                      // ),
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  // text
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Rs. 3000',
                                        style: AppTextStyles.mulish(
                                          color: AppColor.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Text(
                                            '5',
                                            style: AppTextStyles.mulish(
                                              fontWeight: FontWeight.w700,
                                              color: AppColor.borderLightGrey,
                                              fontSize: 10,
                                            ),
                                          ),
                                          SizedBox(width: 3),
                                          Text(
                                            'Premium Pro',
                                            style: AppTextStyles.mulish(
                                              color: AppColor.borderLightGrey,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 15),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: AppColor.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.4),
                                    blurRadius: 20,
                                    offset: Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // left vertical blue bar
                                  Container(
                                    width: 6,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(999),
                                      gradient: const LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Color(0xFF00D2FF),
                                          Color(0xFF0072FF),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  // text
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Rs. 45000',
                                        style: AppTextStyles.mulish(
                                          color: AppColor.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Text(
                                            '5',
                                            style: AppTextStyles.mulish(
                                              fontWeight: FontWeight.w700,
                                              color: AppColor.borderLightGrey,
                                              fontSize: 10,
                                            ),
                                          ),
                                          SizedBox(width: 3),
                                          Text(
                                            'Premium Pro',
                                            style: AppTextStyles.mulish(
                                              color: AppColor.borderLightGrey,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 40),
              Text(
                'Today Activity',
                style: AppTextStyles.mulish(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
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
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: SizedBox(
                                height: 115,
                                width: 92,
                                child: Image.asset(
                                  AppImages.humanImage1,

                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),

                            SizedBox(width: 20),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Siva',
                                  style: AppTextStyles.mulish(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                    color: AppColor.darkBlue,
                                  ),
                                ),
                                SizedBox(height: 3),
                                Text(
                                  'THU29849H',
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
                                  onTap: (){},
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
                                InkWell(onTap: (){},
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
                            SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 5),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColor.iceGray,
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
                                  AppImages.humanImage2,

                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),

                            SizedBox(width: 20),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Kishore',
                                  style: AppTextStyles.mulish(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                    color: AppColor.darkBlue,
                                  ),
                                ),
                                SizedBox(height: 3),
                                Text(
                                  'THU29849H',
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
                                  'Rs. 5,090',
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
                                  borderRadius: BorderRadius.circular(10),
                                  onTap: (){},
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
                                  onTap: (){},
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
                            SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 25),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'View All',
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

            ],
          ),
        ),
      ),
    );
  }
}

class _TotalEntryDonut extends StatelessWidget {
  final int value; // 26
  final String label; // "Today"

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
            /// 🎯 Figma-style donut
            CustomPaint(
              size: const Size(size, size),
              painter: _FigmaRingPainter(
                // tweak these 3 to match your colors
                topLeftColor: AppColor.steelBlueGray, // dark grey (top-left)
                bottomLeftColor: AppColor.blue, // mid blue (bottom-left)
                rightColor: AppColor.blueGradient2, // bright blue (right half)
                innerGapColor: AppColor.blueGradient1, // color behind donut
              ),
            ),

            /// ⬛ Inner rounded square (center card)
            Container(
              height: 140,
              width: 140,
              decoration: BoxDecoration(
                color: AppColor.midnightBlue,
                borderRadius: BorderRadius.circular(48),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // "Today  ▾"
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label,
                        style: AppTextStyles.mulish(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: AppColor.white,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 16,
                        color: AppColor.white4,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // "26"
                  Text(
                    value.toString(),
                    style: AppTextStyles.mulish(
                      fontWeight: FontWeight.w800,
                      fontSize: 32,
                      color: AppColor.white,
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

class _FigmaRingPainter extends CustomPainter {
  final Color topLeftColor;
  final Color bottomLeftColor;
  final Color rightColor;
  final Color innerGapColor;

  _FigmaRingPainter({
    required this.topLeftColor,
    required this.bottomLeftColor,
    required this.rightColor,
    required this.innerGapColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Rect outerRect = Offset.zero & size;

    // 🔵 Outer rounded square
    final double outerRadius = size.width * 0.37; // nice pill like Figma
    final RRect outerRRect = RRect.fromRectAndRadius(
      outerRect,
      Radius.circular(outerRadius),
    );

    // we paint everything INSIDE the rounded rect only
    canvas.save();
    canvas.clipRRect(outerRRect);

    final Paint paint = Paint()..style = PaintingStyle.fill;

    final double halfW = size.width / 2;
    final double halfH = size.height / 2;

    // RIGHT HALF – one solid bright blue
    paint.color = rightColor;
    canvas.drawRect(Rect.fromLTWH(halfW, 0, halfW, size.height), paint);

    // TOP-LEFT QUARTER – dark color
    paint.color = topLeftColor;
    canvas.drawRect(Rect.fromLTWH(0, 0, halfW, halfH), paint);

    // BOTTOM-LEFT QUARTER – mid blue
    paint.color = bottomLeftColor;
    canvas.drawRect(Rect.fromLTWH(0, halfH, halfW, halfH), paint);

    canvas.restore();

    // ⬛ Inner rounded square to cut out center (donut gap)
    final double inset = size.width * 0.18; // controls thickness
    final Rect innerRect = Rect.fromLTWH(
      inset,
      inset,
      size.width - 2 * inset,
      size.height - 2 * inset,
    );

    final double innerRadius = size.width * 0.35;
    final RRect innerRRect = RRect.fromRectAndRadius(
      innerRect,
      Radius.circular(innerRadius),
    );

    final Paint cutPaint =
        Paint()
          ..color = innerGapColor
          ..style = PaintingStyle.fill;

    canvas.drawRRect(innerRRect, cutPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
