import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:tringo_vendor_new/Core/Const/app_color.dart';
import 'package:tringo_vendor_new/Core/Const/app_images.dart';
import 'package:tringo_vendor_new/Core/Utility/app_loader.dart';
import 'package:tringo_vendor_new/Core/Utility/app_textstyles.dart';
import 'package:tringo_vendor_new/Presentation/Heater/Heater%20Home%20Screen/Controller/heater_home_notifier.dart';
import 'package:tringo_vendor_new/Presentation/No%20Data%20Screen/Screen/no_data_screen.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../Core/Widgets/app_go_routes.dart';
import '../../../../Core/Widgets/heater_bottom_navigation_bar.dart';
import '../../../Home Screen/home_screen.dart';
import '../../Employees/Screen/heater_employees_list.dart';
import '../Model/heater_home_response.dart';

enum HeaterDateFilterType { today, yesterday, custom }

class HeaterHomeScreen extends ConsumerStatefulWidget {
  const HeaterHomeScreen({super.key});

  @override
  ConsumerState<HeaterHomeScreen> createState() => _HeaterHomeScreenState();
}

class _HeaterHomeScreenState extends ConsumerState<HeaterHomeScreen> {
  int selectedIndex = 0;
  HeaterDateFilterType _selectedFilter = HeaterDateFilterType.today;

  DateTime? _customDate;

  String get _filterLabel {
    switch (_selectedFilter) {
      case HeaterDateFilterType.today:
        return 'Today';
      case HeaterDateFilterType.yesterday:
        return 'Yesterday';
      case HeaterDateFilterType.custom:
        if (_customDate == null) return 'Select Date';
        return DateFormat('dd MMM yyyy').format(_customDate!);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _refreshDashboardByDate(); // ✅ default today load
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

  DateTime _selectedDate() {
    switch (_selectedFilter) {
      case HeaterDateFilterType.today:
        return DateTime.now();
      case HeaterDateFilterType.yesterday:
        return DateTime.now().subtract(const Duration(days: 1));
      case HeaterDateFilterType.custom:
        return _customDate ?? DateTime.now();
    }
  }

  String _apiDate(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

  Future<void> _refreshDashboardByDate() async {
    final selected = _selectedDate();
    final date = _apiDate(selected);

    await ref
        .read(heaterHomeNotifier.notifier)
        .heaterHome(
          dateFrom: date,
          dateTo: date, // ✅ same date
        );
  }

  void _showDateFilterSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Today'),
              onTap: () async {
                Navigator.pop(context);
                setState(() {
                  _selectedFilter = HeaterDateFilterType.today;
                  _customDate = null;
                });
                await _refreshDashboardByDate();
              },
            ),
            ListTile(
              title: const Text('Yesterday'),
              onTap: () async {
                Navigator.pop(context);
                setState(() {
                  _selectedFilter = HeaterDateFilterType.yesterday;
                  _customDate = null;
                });
                await _refreshDashboardByDate();
              },
            ),
            ListTile(
              title: const Text('Custom Date'),
              onTap: () async {
                Navigator.pop(context);
                await _pickCustomDate();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickCustomDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _customDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue, // Header background (month/year)
              onPrimary: Colors.white, // Header text color
              surface: Colors.white, // Calendar background
              onSurface: Colors.black, // Calendar text color
            ),
            dialogBackgroundColor: Colors.white, // Popup background
          ),
          child: child!,
        );
      },
    );

    if (picked == null) return;

    setState(() {
      _selectedFilter = HeaterDateFilterType.custom;
      _customDate = picked;
    });

    await _refreshDashboardByDate();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(heaterHomeNotifier);

    if (state.isLoading) {
      return Scaffold(
        body: Center(child: ThreeDotsLoader(dotColor: AppColor.darkBlue)),
      );
    }

    // if (state.error != null) {
    //   return Scaffold(
    //     body: Center(
    //       child: Column(
    //         mainAxisSize: MainAxisSize.min,
    //         children: [
    //           Text(state.error!),
    //           SizedBox(height: 12),
    //           ElevatedButton(
    //             onPressed: () {
    //               ref.read(heaterHomeNotifier.notifier).heaterHome();
    //             },
    //             child: Text('Retry'),
    //           ),
    //         ],
    //       ),
    //     ),
    //   );
    // }

    final VendorDashboardResponse? response = state.vendorDashboardResponse;
    final VendorDashboardData? dashboard = response?.data;

    if (dashboard == null) {
      return const Scaffold(
        body: NoDataScreen(showTopBackArrow: false, showBottomButton: false),
      );
    }
    final allPlans =
        dashboard.planCards
            .where((p) => (p.label ?? '') != 'Premium Pro')
            .toList();

    final activePlans = allPlans.where((p) => (p.count ?? 0) > 0).toList();

    // final planCards =
    //     dashboard.planCards
    //         .where((p) => (p.label ?? '') != 'Premium Pro')
    //         .where((p) => (p.count ?? 0) > 0) // ✅ remove zero count plans
    //         .toList();

    final header = dashboard.header;
    // final planCards = dashboard.planCards;
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
                                  header?.displayName ?? '-',
                                  style: AppTextStyles.mulish(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: AppColor.white,
                                  ),
                                ),
                                SizedBox(height: 3),
                                Text(
                                  header?.vendorCode ?? '',
                                  style: AppTextStyles.mulish(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                    color: AppColor.lightGray1,
                                  ),
                                ),
                                Text(
                                  '${header?.employeesCount ?? 0} Employees',
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
                                  header?.avatarUrl != null &&
                                          header!.avatarUrl!.isNotEmpty
                                      ? Image.network(
                                        header!.avatarUrl!,
                                        height: 52,
                                        width: 52,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (_, __, ___) => Center(
                                              child: Icon(
                                                Icons.person,
                                                size: 40,
                                                color: AppColor.white,
                                              ),
                                            ),
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
                        plans: activePlans,
                        value: dashboard.todayTotalCount ?? 0,
                        label: _filterLabel,
                        onTapLabel: _showDateFilterSheet,
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
                            for (final plan in allPlans) ...[
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
                '$_filterLabel Activity',
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
                        'No $_filterLabel Activity',
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
                      // final bool isBlocked = !(data.isActive);
                      // final bool isBlocked = !(data.isActiveSafe);
                      final bool isBlocked = !(data.isActive ?? true);
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Column(
                          children: [
                            Opacity(
                              opacity: isBlocked ? 0.45 : 1.0,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isBlocked
                                      ? AppColor.ivoryGreen.withOpacity(0.4)
                                      : AppColor.ivoryGreen,
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
                                          Row(
                                            children: [
                                              Text(
                                                data.name ?? '-',
                                                style: AppTextStyles.mulish(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 16,
                                                  color: AppColor.darkBlue,
                                                ),
                                              ),
                                              SizedBox(width: 5),
                                              if (isBlocked)
                                                Container(
                                                  margin: const EdgeInsets.only(top: 6),
                                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: Colors.black.withOpacity(0.08),
                                                    borderRadius: BorderRadius.circular(999),
                                                  ),
                                                  child: Text(
                                                    'Blocked',
                                                    style: AppTextStyles.mulish(
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.w700,
                                                      color: AppColor.mildBlack,
                                                    ),
                                                  ),
                                                ),

                                            ],
                                          ),


                                          SizedBox(height: 3),
                                          Text(
                                            data.employeeCode ?? '',
                                            style: AppTextStyles.mulish(
                                              fontSize: 11,
                                              color: AppColor.mildBlack,
                                            ),
                                          ),
                                          SizedBox(height: 20),
                                          Text(
                                            '$_filterLabel Collection',
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
                                              final phone =
                                                  data.phoneNumber ?? '';
                                              if (phone.isNotEmpty) {
                                                _launchDialer(phone);
                                              }
                              
                                              // if (data.phoneNumber!.isNotEmpty) {
                                              //   _launchDialer(data.phoneNumber??'');
                                              // }
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: AppColor.black,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(
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
                                                AppRoutes
                                                    .heaterEmployeeDetailsPath,
                                                extra: data.employeeId,
                                              );
                                              // Navigator.push(
                                              //   context,
                                              //   MaterialPageRoute(
                                              //     builder:
                                              //         (context) =>
                                              //             HeaterBottomNavigationBar(
                                              //               initialIndex: 1,
                                              //             ),
                                              //   ),
                                              // );
                                            },
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
                                                padding: EdgeInsets.symmetric(
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => HeaterBottomNavigationBar(
                                    initialIndex: 1,
                                  ),
                            ),
                          );
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
  final PlanCardItem plan;
  final bool isSelected;
  final VoidCallback? onTap;

  const _PlanCardWidget({
    Key? key,
    required this.plan,
    this.isSelected = false,
    this.onTap,
  }) : super(key: key);
  Decoration _planDecoration(String label) {
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

  // Decoration _planDecoration(String label) {
  //   if (label == "Premium Pro") {
  //     return const BoxDecoration(
  //       gradient: LinearGradient(
  //         colors: [Color(0xFF0797FD), Color(0xFF07C8FD)],
  //         begin: Alignment.topCenter,
  //         end: Alignment.bottomCenter,
  //       ),
  //       borderRadius: BorderRadius.all(Radius.circular(999)),
  //     );
  //   }
  //
  //   return BoxDecoration(
  //     color:
  //         {
  //           "Freemium": AppColor.steelBlueGray,
  //           "Premium": AppColor.blue,
  //         }[label] ??
  //         Colors.grey,
  //     borderRadius: const BorderRadius.all(Radius.circular(999)),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
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
              decoration: _planDecoration(plan.label ?? ""),
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
                      plan.label ?? '',
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
    );
  }
}

class _TotalEntryDonut extends StatelessWidget {
  final List<PlanCardItem> plans;
  final int value;
  final String label;
  final VoidCallback onTapLabel;

  const _TotalEntryDonut({
    Key? key,
    required this.value,
    required this.label,
    required this.plans,
    required this.onTapLabel,
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
            CustomPaint(
              size: const Size(size, size),
              painter: _FigmaRingPainter(plans: plans),
            ),

            Container(
              height: 145,
              width: 145,
              decoration: BoxDecoration(
                color: AppColor.midnightBlue,
                borderRadius: BorderRadius.circular(48),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //  label selector (Today / Yesterday / Date)
                  InkWell(
                    onTap: onTapLabel,
                    borderRadius: BorderRadius.circular(18),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      child: Row(
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
                    ),
                  ),

                  const SizedBox(height: 10),

                  //  employee count
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
  final List<PlanCardItem> plans;

  _FigmaRingPainter({required this.plans});

  final Map<String, Color> planColors = const {
    "Freemium": AppColor.steelBlueGray,
    "Premium": AppColor.blue,
  };

  Color _getColorFrom(PlanCardItem p) {
    return planColors[p.label] ?? Colors.grey;
  }

  @override
  void paint(Canvas canvas, Size size) {
    //  only non-zero count plans should affect colors
    final List<PlanCardItem> activePlans =
        plans.where((p) => (p.count ?? 0) > 0).toList();

    final Rect outerRect = Offset.zero & size;

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

    if (activePlans.isEmpty) {
      //  nothing active → neutral color
      paint.color = Colors.grey;
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
    } else if (activePlans.length == 1) {
      //  single plan → full ring that color
      paint.color = _getColorFrom(activePlans[0]);
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
    } else if (activePlans.length == 2) {
      //  2 plans → left/right split
      paint.color = _getColorFrom(activePlans[0]);
      canvas.drawRect(Rect.fromLTWH(0, 0, halfW, size.height), paint);

      paint.color = _getColorFrom(activePlans[1]);
      canvas.drawRect(Rect.fromLTWH(halfW, 0, halfW, size.height), paint);
    } else {
      //  3+ plans → old layout (right / top-left / bottom-left)
      paint.color = _getColorFrom(activePlans[0]);
      canvas.drawRect(Rect.fromLTWH(halfW, 0, halfW, size.height), paint);

      paint.color = _getColorFrom(activePlans[1]);
      canvas.drawRect(Rect.fromLTWH(0, 0, halfW, halfH), paint);

      paint.color = _getColorFrom(activePlans[2]);
      canvas.drawRect(Rect.fromLTWH(0, halfH, halfW, halfH), paint);
    }

    canvas.restore();

    // INNER DONUT HOLE (same)
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

// class _FigmaRingPainter extends CustomPainter {
//   final List<PlanCardItem> plans;
//
//   _FigmaRingPainter({required this.plans});
//
//   // solid colors for non-gradient plans
//   final Map<String, Color> planColors = const {
//     "Freemium": AppColor.steelBlueGray,
//     "Premium": AppColor.blue,
//   };
//
//   Color _getColor(int index) {
//     if (index >= plans.length) return Colors.grey;
//     final p = plans[index];
//     return planColors[p.label] ?? Colors.grey;
//   }
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     final Rect outerRect = Offset.zero & size;
//
//     final double outerRadius = size.width * 0.37;
//     final RRect outerRRect = RRect.fromRectAndRadius(
//       outerRect,
//       Radius.circular(outerRadius),
//     );
//
//     canvas.save();
//     canvas.clipRRect(outerRRect);
//
//     final Paint paint = Paint()..style = PaintingStyle.fill;
//
//     final double halfW = size.width / 2;
//     final double halfH = size.height / 2;
//
//     // ✅ if only 1 or 2 plans, draw simple split
//     if (plans.length <= 2) {
//       // Left half = index 0
//       paint.color = _getColor(0);
//       canvas.drawRect(Rect.fromLTWH(0, 0, halfW, size.height), paint);
//
//       // Right half = index 1 (if exists else same)
//       paint.color = _getColor(1);
//       canvas.drawRect(Rect.fromLTWH(halfW, 0, halfW, size.height), paint);
//     } else {
//       // ✅ 3 plans - your existing layout (right / top-left / bottom-left)
//       // RIGHT HALF (index 0)
//       paint.color = _getColor(0);
//       canvas.drawRect(Rect.fromLTWH(halfW, 0, halfW, size.height), paint);
//
//       // TOP LEFT (index 1)
//       paint.color = _getColor(1);
//       canvas.drawRect(Rect.fromLTWH(0, 0, halfW, halfH), paint);
//
//       // BOTTOM LEFT (index 2)
//       paint.color = _getColor(2);
//       canvas.drawRect(Rect.fromLTWH(0, halfH, halfW, halfH), paint);
//     }
//
//     canvas.restore();
//
//     // INNER DONUT HOLE (same)
//     final double inset = size.width * 0.18;
//     final Rect innerRect = Rect.fromLTWH(
//       inset,
//       inset,
//       size.width - 2 * inset,
//       size.height - 2 * inset,
//     );
//
//     final double innerRadius = (innerRect.width / 2).clamp(0.0, size.width);
//
//     final RRect innerRRect = RRect.fromRectAndRadius(
//       innerRect,
//       Radius.circular(innerRadius),
//     );
//
//     final Paint cutPaint =
//         Paint()
//           ..color = Colors.white
//           ..style = PaintingStyle.fill;
//
//     canvas.drawRRect(innerRRect, cutPaint);
//   }
//
//   // @override
//   // void paint(Canvas canvas, Size size) {
//   //   final Rect outerRect = Offset.zero & size;
//   //
//   //   // Rounded square container
//   //   final double outerRadius = size.width * 0.37;
//   //   final RRect outerRRect = RRect.fromRectAndRadius(
//   //     outerRect,
//   //     Radius.circular(outerRadius),
//   //   );
//   //
//   //   canvas.save();
//   //   canvas.clipRRect(outerRRect);
//   //
//   //   final Paint paint = Paint()..style = PaintingStyle.fill;
//   //
//   //   final double halfW = size.width / 2;
//   //   final double halfH = size.height / 2;
//   //
//   //   // GRADIENT for Premium Pro
//   //   final Gradient premiumProGradient = const LinearGradient(
//   //     colors: [Color(0xFF0797FD), Color(0xFF07C8FD)],
//   //     begin: Alignment.topCenter,
//   //     end: Alignment.bottomCenter,
//   //   );
//   //
//   //   // ==============================
//   //   // RIGHT HALF (index 0)
//   //   // ==============================
//   //   paint.shader = null;
//   //   paint.color = _getColor(0);
//   //   canvas.drawRect(Rect.fromLTWH(halfW, 0, halfW, size.height), paint);
//   //
//   //   // ==============================
//   //   // TOP LEFT (index 1)
//   //   // ==============================
//   //   paint.shader = null;
//   //   paint.color = _getColor(1);
//   //   canvas.drawRect(Rect.fromLTWH(0, 0, halfW, halfH), paint);
//   //
//   //   // ==============================
//   //   // BOTTOM LEFT (index 2) — Gradient if Premium Pro
//   //   // ==============================
//   //   final rectBottomLeft = Rect.fromLTWH(0, halfH, halfW, halfH);
//   //
//   //   if (plans.length > 2 && plans[2].label == "Premium Pro") {
//   //     paint.shader = premiumProGradient.createShader(rectBottomLeft);
//   //   } else {
//   //     paint.shader = null;
//   //     paint.color = _getColor(2);
//   //   }
//   //
//   //   canvas.drawRect(rectBottomLeft, paint);
//   //
//   //   // reset shader
//   //   paint.shader = null;
//   //
//   //   canvas.restore();
//   //
//   //   // ==============================
//   //   // INNER DONUT HOLE
//   //   // ==============================
//   //   final double inset = size.width * 0.18;
//   //   final Rect innerRect = Rect.fromLTWH(
//   //     inset,
//   //     inset,
//   //     size.width - 2 * inset,
//   //     size.height - 2 * inset,
//   //   );
//   //
//   //   final double innerRadius = (innerRect.width / 2).clamp(0.0, size.width);
//   //
//   //   final RRect innerRRect = RRect.fromRectAndRadius(
//   //     innerRect,
//   //     Radius.circular(innerRadius),
//   //   );
//   //
//   //   final Paint cutPaint =
//   //       Paint()
//   //         ..color = Colors.white
//   //         ..style = PaintingStyle.fill;
//   //
//   //   canvas.drawRRect(innerRRect, cutPaint);
//   // }
//
//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
// }
