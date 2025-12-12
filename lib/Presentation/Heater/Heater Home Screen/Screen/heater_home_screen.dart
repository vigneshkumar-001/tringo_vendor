import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tringo_vendor_new/Core/Const/app_color.dart';
import 'package:tringo_vendor_new/Core/Const/app_images.dart';
import 'package:tringo_vendor_new/Core/Utility/app_loader.dart';
import 'package:tringo_vendor_new/Core/Utility/app_textstyles.dart';
import 'package:tringo_vendor_new/Presentation/Heater/Heater%20Home%20Screen/Controller/heater_home_notifier.dart';
import 'package:tringo_vendor_new/Presentation/No%20Data%20Screen/Screen/no_data_screen.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Model/heater_home_response.dart';

class HeaterHomeScreen extends ConsumerStatefulWidget {
  const HeaterHomeScreen({super.key});

  @override
  ConsumerState<HeaterHomeScreen> createState() => _HeaterHomeScreenState();
}

class _HeaterHomeScreenState extends ConsumerState<HeaterHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      ref.read(heaterHomeNotifier.notifier).heaterHome();
    });
  }

  Future<void> _launchDialer(String phoneNumber) async {
    final Uri uri = Uri(scheme: 'tel', path: phoneNumber);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      // handle error or show a snackbar
      debugPrint('Could not launch dialer for $phoneNumber');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(heaterHomeNotifier);

    if (state.isLoading) {
      return Scaffold(
        body: Center(child: ThreeDotsLoader(dotColor: AppColor.darkBlue)),
      );
    }

    if (state.error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(state.error!),
              SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  ref.read(heaterHomeNotifier.notifier).heaterHome();
                },
                child: Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final VendorDashboardResponse? response = state.vendorDashboardResponse;
    final VendorDashboardData? dashboard = response?.data;

    if (dashboard == null) {
      return const Scaffold(
        body: NoDataScreen(showTopBackArrow: false, showBottomButton: false),
      );
    }

    final header = dashboard.header;
    final planCards = dashboard.planCards;
    final todayTotalCount = dashboard.todayTotalCount;
    final todayActivity = dashboard.todayActivity;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 0,
                  vertical: 20,
                ),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(AppImages.homeScreenTopBCImage),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      AppColor.richNavy.withOpacity(0.4),
                      BlendMode.srcATop,
                    ),
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
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  header.displayName ?? '-',
                                  style: AppTextStyles.mulish(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: AppColor.white,
                                  ),
                                ),
                                SizedBox(height: 3),
                                Text(
                                  header.vendorCode ?? '',
                                  style: AppTextStyles.mulish(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                    color: AppColor.lightGray1,
                                  ),
                                ),
                                Text(
                                  '${header.employeesCount ?? 0} Employees',
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
                              child:
                                  header.avatarUrl != null &&
                                          header.avatarUrl!.isNotEmpty
                                      ? Image.network(
                                        header.avatarUrl!,
                                        height: 52,
                                        width: 52,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) {
                                          return Center(
                                            child: Icon(
                                              Icons.person,
                                              size: 40,
                                              color: AppColor.white,
                                            ),
                                          );
                                        },
                                      )
                                      : Image.asset(
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
                      _TotalEntryDonut(
                        plans: planCards,
                        value: todayTotalCount,
                        label: "Today",
                      ),

                      SizedBox(height: 25),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: BouncingScrollPhysics(),
                        padding: EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 25,
                        ),
                        child: Row(
                          children: [
                            for (final plan in planCards) ...[
                              _PlanCardWidget(plan: plan),
                              SizedBox(width: 15),
                            ],
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
              todayActivity.isEmpty
                  ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Text(
                        'No Today Activity',
                        style: AppTextStyles.mulish(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColor.gray84,
                        ),
                      ),
                    ),
                  )
                  : ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: todayActivity.length,
                    itemBuilder: (context, index) {
                      final data = todayActivity[index];
                      return Padding(
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
                                        child: Image.network(
                                          data.avatarUrl ?? "",
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) {
                                            return const Center(
                                              child: Icon(
                                                Icons.broken_image,
                                                size: 40,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 20),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          data.name,
                                          style: AppTextStyles.mulish(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 16,
                                            color: AppColor.darkBlue,
                                          ),
                                        ),
                                        SizedBox(height: 3),
                                        Text(
                                          data.employeeCode,
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
                                          'Rs.${data.todayAmount}',
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
                                            if (data.phoneNumber.isNotEmpty) {
                                              _launchDialer(data.phoneNumber);
                                            }
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: AppColor.black,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
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
                                          onTap: () {},
                                          child: Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: AppColor.black
                                                    .withOpacity(0.5),
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
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
                      );
                    },
                  ),

              SizedBox(height: 20),
              todayActivity.isNotEmpty
                  ? Row(
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
                          child: Image.asset(
                            AppImages.rightStickArrow,
                            height: 12,
                          ),
                        ),
                      ),
                    ],
                  )
                  : SizedBox.shrink(),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlanCardWidget extends StatelessWidget {
  final PlanCard plan;

  const _PlanCardWidget({Key? key, required this.plan}) : super(key: key);

  Decoration _planDecoration(String label) {
    if (label == "Premium Pro") {
      return const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0797FD), Color(0xFF07C8FD)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.all(Radius.circular(999)),
      );
    }

    return BoxDecoration(
      color:
          {
            "Freemium": AppColor.steelBlueGray,
            "Premium": AppColor.blue,
          }[label] ??
          Colors.grey,
      borderRadius: const BorderRadius.all(Radius.circular(999)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: AppColor.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // LEFT COLOR BAR (solid or gradient)
          Container(
            width: 6,
            height: 48,
            decoration: _planDecoration(plan.label),
          ),

          const SizedBox(width: 16),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Rs. ${plan.amount}',
                style: AppTextStyles.mulish(
                  color: AppColor.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    plan.count.toString(),
                    style: AppTextStyles.mulish(
                      fontWeight: FontWeight.w700,
                      color: AppColor.borderLightGrey,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(width: 3),
                  Text(
                    plan.label,
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
    );
  }
}

class _TotalEntryDonut extends StatelessWidget {
  final List<PlanCard> plans;
  final int value; // e.g. 26
  final String label; // e.g. "Today"

  const _TotalEntryDonut({
    Key? key,
    required this.value,
    required this.label,
    required this.plans,
  }) : super(key: key);

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
            /// Figma-style donut
            CustomPaint(
              size: Size(size, size),
              painter: _FigmaRingPainter(plans: plans),
            ),

            /// Inner rounded square (center card)
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
                      SizedBox(width: 4),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 16,
                        color: AppColor.white4,
                      ),
                    ],
                  ),
                  SizedBox(height: 10),

                  // value
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
  final List<PlanCard> plans;

  _FigmaRingPainter({required this.plans});

  // solid colors for non-gradient plans
  final Map<String, Color> planColors = const {
    "Freemium": AppColor.steelBlueGray,
    "Premium": AppColor.blue,
  };

  Color _getColor(int index) {
    if (index >= plans.length) return Colors.grey;
    final p = plans[index];
    return planColors[p.label] ?? Colors.grey;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final Rect outerRect = Offset.zero & size;

    // Rounded square container
    final double outerRadius = size.width * 0.37;
    final RRect outerRRect = RRect.fromRectAndRadius(
      outerRect,
      Radius.circular(outerRadius),
    );

    canvas.save();
    canvas.clipRRect(outerRRect);

    final Paint paint = Paint()..style = PaintingStyle.fill;

    final double halfW = size.width / 2;
    final double halfH = size.height / 2;

    // GRADIENT for Premium Pro
    final Gradient premiumProGradient = const LinearGradient(
      colors: [Color(0xFF0797FD), Color(0xFF07C8FD)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );

    // ==============================
    // RIGHT HALF (index 0)
    // ==============================
    paint.shader = null;
    paint.color = _getColor(0);
    canvas.drawRect(Rect.fromLTWH(halfW, 0, halfW, size.height), paint);

    // ==============================
    // TOP LEFT (index 1)
    // ==============================
    paint.shader = null;
    paint.color = _getColor(1);
    canvas.drawRect(Rect.fromLTWH(0, 0, halfW, halfH), paint);

    // ==============================
    // BOTTOM LEFT (index 2) — Gradient if Premium Pro
    // ==============================
    final rectBottomLeft = Rect.fromLTWH(0, halfH, halfW, halfH);

    if (plans.length > 2 && plans[2].label == "Premium Pro") {
      paint.shader = premiumProGradient.createShader(rectBottomLeft);
    } else {
      paint.shader = null;
      paint.color = _getColor(2);
    }

    canvas.drawRect(rectBottomLeft, paint);

    // reset shader
    paint.shader = null;

    canvas.restore();

    // ==============================
    // INNER DONUT HOLE
    // ==============================
    final double inset = size.width * 0.18;
    final Rect innerRect = Rect.fromLTWH(
      inset,
      inset,
      size.width - 2 * inset,
      size.height - 2 * inset,
    );

    final double innerRadius = (innerRect.width / 2).clamp(0.0, size.width);

    final RRect innerRRect = RRect.fromRectAndRadius(
      innerRect,
      Radius.circular(innerRadius),
    );

    final Paint cutPaint =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;

    canvas.drawRRect(innerRRect, cutPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
