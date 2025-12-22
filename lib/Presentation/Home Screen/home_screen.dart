import 'dart:math' as math;

import 'package:dotted_border/dotted_border.dart';
import 'package:dotted_border/dotted_border.dart' as dotted;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:tringo_vendor_new/Core/Const/app_color.dart';
import 'package:tringo_vendor_new/Core/Const/app_images.dart';
import 'package:tringo_vendor_new/Core/Utility/app_textstyles.dart';
import 'package:tringo_vendor_new/Core/Widgets/app_go_routes.dart';
import 'package:tringo_vendor_new/Presentation/Home%20Screen/Contoller/employee_home_notifier.dart';
import 'package:tringo_vendor_new/Presentation/Home%20Screen/Model/employee_home_response.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../Core/Utility/app_loader.dart';
import '../../Core/Widgets/bottom_navigation_bar.dart';
import '../../Core/Widgets/common_container.dart';
import '../No Data Screen/Screen/no_data_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

enum DateFilterType { today, yesterday, custom }

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int selectedIndex = 0;
  DateFilterType _selectedFilter = DateFilterType.today;
  DateTime? _customDate;

  int getTotalEntryForSelectedDate(EmployeeData dashboard) {
    if (dashboard.recentActivity.isEmpty) return 0;

    DateTime filterDate;
    switch (_selectedFilter) {
      case DateFilterType.today:
        filterDate = DateTime.now();
        break;
      case DateFilterType.yesterday:
        filterDate = DateTime.now().subtract(const Duration(days: 1));
        break;
      case DateFilterType.custom:
        if (_customDate != null) {
          filterDate = _customDate!;
        } else {
          return 0;
        }
        break;
    }

    // Sum entryCount for matching date
    return dashboard.recentActivity
        .where((activity) => DateUtils.isSameDay(activity.date, filterDate))
        .fold(0, (sum, activity) => sum + activity.entryCount);
  }

  String get _filterLabel {
    switch (_selectedFilter) {
      case DateFilterType.today:
        return 'Today';
      case DateFilterType.yesterday:
        return 'Yesterday';
      case DateFilterType.custom:
        if (_customDate == null) return 'Select Date';
        return DateFormat('dd MMM yyyy').format(_customDate!);
    }
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
            _buildFilterTile(
              title: 'Today',
              onTap: () {
                setState(() {
                  _selectedFilter = DateFilterType.today;
                  _customDate = null;
                });
                Navigator.pop(context);
              },
            ),
            _buildFilterTile(
              title: 'Yesterday',
              onTap: () {
                setState(() {
                  _selectedFilter = DateFilterType.yesterday;
                  _customDate = null;
                });
                Navigator.pop(context);
              },
            ),
            _buildFilterTile(
              title: 'Custom Date',
              onTap: () async {
                Navigator.pop(context);
                _pickCustomDate();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilterTile({
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(title: Text(title), onTap: onTap);
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
              primary: Colors
                  .blue, // Header background (month/year)
              onPrimary:
              Colors.white, // Header text color
              surface:
              Colors.white, // Calendar background
              onSurface:
              Colors.black, // Calendar text color
            ),
            dialogBackgroundColor:
            Colors.white, // Popup background
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (DateUtils.isSameDay(picked, DateTime.now())) {
          _selectedFilter = DateFilterType.today;
          _customDate = null;
        } else {
          _selectedFilter = DateFilterType.custom;
          _customDate = picked;
        }
      });
    }
  }

  // Future<void> _pickCustomDate() async {
  //   final picked = await showDatePicker(
  //     context: context,
  //     initialDate: DateTime.now(),
  //     firstDate: DateTime(2020),
  //     lastDate: DateTime.now(),
  //   );
  //
  //   if (picked != null) {
  //     setState(() {
  //       _selectedFilter = DateFilterType.custom;
  //       _customDate = picked;
  //     });
  //   }
  // }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      ref.read(employeeHomeNotifier.notifier).employeeHome();
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

  final List<Map<String, dynamic>> categoryTabs = [
    {"label": "22 Pro Premium User", "image": AppImages.premiumImage},
    {"label": "4 Premium Users", "image": AppImages.premiumImage01},
    {"label": "4 Free Users", "image": AppImages.premiumImage01},
  ];

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(employeeHomeNotifier);

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
                  ref.read(employeeHomeNotifier.notifier).employeeHome();
                },
                child: Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final EmployeeHomeResponse? response = state.employeeHomeResponse;
    final EmployeeData? dashboard = response?.data;

    if (dashboard == null) {
      return const Scaffold(
        body: NoDataScreen(showTopBackArrow: false, showBottomButton: false),
      );
    }

    final employee = dashboard.employee;
    final metrics = dashboard.metrics;
    final recentActivity = dashboard.recentActivity;
    // final todayActivity = dashboard.todayActivity;

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
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                employee?.name ?? '-',
                                style: AppTextStyles.mulish(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: AppColor.white,
                                ),
                              ),
                              Text(
                                employee?.employeeCode ?? '',
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
                                    employee?.vendorName ?? '',
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
                            child:
                                employee!.avatarUrl.isNotEmpty
                                    ? Image.network(
                                      employee.avatarUrl,
                                      height: 52,
                                      width: 52,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (_, __, ___) => Icon(
                                            Icons.person,
                                            size: 40,
                                            color: AppColor.white,
                                          ),
                                    )
                                    : Image.asset(
                                      AppImages.profileImage,
                                      height: 52,
                                      width: 52,
                                      fit: BoxFit.cover,
                                    ),
                          ),

                          // ClipOval(
                          //   child: Image.asset(
                          //     AppImages.profileImage,
                          //     height: 52,
                          //     width: 52,
                          //     fit: BoxFit.cover,
                          //   ),
                          // ),
                        ],
                      ),
                      SizedBox(height: 40),

                      // _TotalEntryDonut(value: 26, label: 'Total Entry'),
                      _TotalEntryDonut(
                        value: getTotalEntryForSelectedDate(dashboard),
                        label: 'Total Entry',
                      ),

                      // _TotalEntryDonut(
                      //   value: metrics?.totalEntry ?? 0,
                      //   label: 'Total Entry',
                      // ),
                      SizedBox(height: 25),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: InkWell(
                          onTap: _showDateFilterSheet,
                          child: IntrinsicWidth(
                            // THIS IS THE KEY
                            child: DottedBorder(
                              color: AppColor.lightBlueBorder,
                              dashPattern: const [4, 5],
                              borderType: BorderType.RRect,
                              radius: const Radius.circular(18),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min, //  IMPORTANT
                                children: [
                                  Text(
                                    _filterLabel, // Today / Yesterday / 12 Sep 2025
                                    style: AppTextStyles.mulish(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 12,
                                      color: AppColor.white,
                                    ),
                                  ),
                                  const SizedBox(width: 7),
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
                      ),

                      // Padding(
                      //   padding: const EdgeInsets.symmetric(
                      //     vertical: 8,
                      //     horizontal: 120,
                      //   ),
                      //   child: InkWell(
                      //     onTap: () {},
                      //     child: DottedBorder(
                      //       color: AppColor.lightBlueBorder,
                      //       dashPattern: [4.0, 5.0],
                      //       borderType: dotted.BorderType.RRect,
                      //       padding: EdgeInsets.all(10),
                      //       radius: Radius.circular(18),
                      //       child: Row(
                      //         mainAxisAlignment: MainAxisAlignment.center,
                      //         children: [
                      //           Text(
                      //             'Today',
                      //             style: AppTextStyles.mulish(
                      //               fontWeight: FontWeight.w900,
                      //               fontSize: 12,
                      //               color: AppColor.white,
                      //             ),
                      //           ),
                      //           SizedBox(width: 7),
                      //           Image.asset(
                      //             AppImages.drapDownImage,
                      //             height: 14,
                      //             width: 10,
                      //           ),
                      //         ],
                      //       ),
                      //     ),
                      //   ),
                      // ),
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
                                    context.push(
                                      AppRoutes.shopDetailsEditPath,
                                      extra: 'f55414f1-9787-4f7d-84a6-affede17675e',
                                    );
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

double _intensityFromValue(int value) {
  if (value <= 0) return 0.2;

  // scale: 0 → 0.2 , 50+ → 1.0
  final normalized = (value / 50).clamp(0.2, 1.0);
  return normalized;
}

class _TotalEntryDonut extends StatelessWidget {
  final int value;
  final String label;

  const _TotalEntryDonut({Key? key, required this.value, required this.label})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    const double size = 220;
    final intensity = _intensityFromValue(value);

    return Center(
      child: SizedBox(
        height: size,
        width: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            /// Ring
            CustomPaint(
              size: const Size(size, size),
              painter: _FigmaRingPainter(
                backgroundColor: AppColor.steelNavy.withOpacity(
                  0.3 + intensity * 0.3,
                ),
                startColor: AppColor.blueGradient3.withOpacity(intensity),
                endColor: AppColor.blueGradient3.withOpacity(intensity),
              ),
            ),

            /// Inner box
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

// class _TotalEntryDonut extends StatelessWidget {
//   final int value;
//   final String label;
//
//   const _TotalEntryDonut({Key? key, required this.value, required this.label})
//     : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     const double size = 220;
//
//     return Center(
//       child: SizedBox(
//         height: size,
//         width: size,
//         child: Stack(
//           alignment: Alignment.center,
//           children: [
//             ///  Figma-style ring
//             CustomPaint(
//               size: const Size(size, size),
//               painter: _FigmaRingPainter(
//                 backgroundColor: AppColor.steelNavy,
//                 startColor: AppColor.blueGradient3, // bright blue
//                 endColor:
//                     AppColor.blueGradient2, // another blue (no dark shadow)
//               ),
//             ),
//
//             /// ⬛ Inner rounded square
//             Container(
//               height: 140,
//               width: 140,
//               decoration: BoxDecoration(
//                 color: AppColor.midnightBlue,
//                 borderRadius: BorderRadius.circular(50),
//               ),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(
//                     value.toString(),
//                     style: AppTextStyles.mulish(
//                       fontWeight: FontWeight.w800,
//                       fontSize: 26,
//                       color: AppColor.white,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     label,
//                     style: AppTextStyles.mulish(
//                       fontWeight: FontWeight.w600,
//                       fontSize: 12,
//                       color: AppColor.white4,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
