import 'package:dartz/dartz.dart' as employee;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tringo_vendor_new/Core/Const/app_color.dart';
import 'package:tringo_vendor_new/Core/Utility/app_textstyles.dart';
import 'package:tringo_vendor_new/Core/Widgets/app_go_routes.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../Core/Const/app_images.dart';
import '../../../../Core/Utility/app_loader.dart';
import '../../../../Core/Utility/filter_popup_screen.dart';
import '../../../../Core/Utility/sortby_popup_screen.dart';
import '../../../../Core/Widgets/bottom_navigation_bar.dart';
import '../../Add Vendor Employee/Screen/heater_add_employee.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Condroller/heater_employee_notifier.dart';
import '../Model/heater_employee_response.dart';

class HeaterEmployeesList extends ConsumerStatefulWidget {
  const HeaterEmployeesList({super.key});

  @override
  ConsumerState<HeaterEmployeesList> createState() =>
      _HeaterEmployeesListState();
}

class _HeaterEmployeesListState extends ConsumerState<HeaterEmployeesList> {

  bool _showSearch = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Fetch once after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(heaterEmployeeNotifier.notifier).heaterEmployee();
    });

    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
    final heaterState = ref.watch(heaterEmployeeNotifier);

    final response = heaterState.heaterEmployeeResponse;
    final items = response?.data.items ?? [];

    // Client-side search
    final q = _searchController.text.trim().toLowerCase();
    final filteredItems =
        q.isEmpty
            ? items
            : items.where((e) {
              return e.name.toLowerCase().contains(q) ||
                  e.employeeCode.toLowerCase().contains(q) ||
                  e.phoneNumber.toLowerCase().contains(q) ||
                  e.email.toLowerCase().contains(q);
            }).toList();

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh:
              () => ref.read(heaterEmployeeNotifier.notifier).heaterEmployee(),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _header(context)),
              SliverToBoxAdapter(child: SizedBox(height: 10)),
              SliverToBoxAdapter(child: _searchFilterSortRow(context)),
              SliverToBoxAdapter(child: SizedBox(height: 25)),

              // STATES
              if (heaterState.isLoading)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: ThreeDotsLoader(dotColor: AppColor.darkBlue),
                  ),
                )
              // else if (heaterState.error != null)
              //   SliverToBoxAdapter(
              //     child: Padding(
              //       padding: EdgeInsets.all(16),
              //       child: Column(
              //         children: [
              //           Text(
              //             heaterState.error!,
              //             style: TextStyle(color: Colors.red),
              //           ),
              //           SizedBox(height: 12),
              //           ElevatedButton(
              //             onPressed:
              //                 () =>
              //                     ref
              //                         .read(heaterEmployeeNotifier.notifier)
              //                         .heaterEmployee(),
              //             child: Text("Retry"),
              //           ),
              //         ],
              //       ),
              //     ),
              //   )
              else if (filteredItems.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(top: 60),
                    child: Center(
                      child: Text(
                        q.isEmpty
                            ? "No employees found"
                            : "No results for “${_searchController.text}”",
                        // use your AppTextStyles if you want
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  sliver: SliverList.separated(
                    itemCount: filteredItems.length,
                    separatorBuilder: (_, __) => SizedBox(height: 15),
                    itemBuilder: (context, index) {
                      final data = filteredItems[index];
                      return _employeeCard(context, data);
                    },
                  ),
                ),

              SliverToBoxAdapter(child: SizedBox(height: 30)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                MaterialPageRoute(builder: (context) => HeaterAddEmployee()),
              );
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              decoration: BoxDecoration(
                color: AppColor.black,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Image.asset(AppImages.rightStickArrow, height: 19),
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchFilterSortRow(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => setState(() => _showSearch = true),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child:
                  _showSearch
                      ? Container(
                        key: const ValueKey('searchField'),
                        width: 260,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColor.darkBlue),
                          borderRadius: BorderRadius.circular(25),
                          color: AppColor.white,
                        ),
                        child: Row(
                          children: [
                            Image.asset(AppImages.searchImage, height: 14),
                            SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                autofocus: true,
                                decoration: InputDecoration(
                                  hintText: 'Search...',
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _searchController.clear();
                                  _showSearch = false;
                                });
                              },
                              child: Icon(Icons.close, size: 18),
                            ),
                          ],
                        ),
                      )
                      : Container(
                        key: ValueKey('searchButton'),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColor.darkBlue),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 47,
                          vertical: 8,
                        ),
                        child: Row(
                          children: [
                            Image.asset(AppImages.searchImage, height: 14),
                            SizedBox(width: 10),
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

          // Filter
          GestureDetector(
            onTap: () {
              showModalBottomSheet(
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                context: context,
                showDragHandle: true,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (_) => FilterPopupScreen(),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColor.lightGray2),
                borderRadius: BorderRadius.circular(25),
              ),
              padding: EdgeInsets.symmetric(horizontal: 17, vertical: 9),
              child: Row(
                children: [
                  Text(
                    'Filter',
                    style: AppTextStyles.mulish(color: AppColor.lightGray2),
                  ),
                  SizedBox(width: 10),
                  Image.asset(AppImages.drapDownImage, height: 19),
                ],
              ),
            ),
          ),
          SizedBox(width: 10),

          // Sort
          GestureDetector(
            onTap: () {
              showModalBottomSheet(
                backgroundColor: Colors.transparent,
                context: context,
                isScrollControlled: true,
                showDragHandle: true,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (_) => SortbyPopupScreen(),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColor.lightGray2),
                borderRadius: BorderRadius.circular(25),
              ),
              padding: EdgeInsets.symmetric(horizontal: 17, vertical: 9),
              child: Row(
                children: [
                  Text(
                    'Sort By',
                    style: AppTextStyles.mulish(color: AppColor.lightGray2),
                  ),
                  SizedBox(width: 10),
                  Image.asset(AppImages.drapDownImage, height: 19),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _employeeCard(BuildContext context, EmployeeItem data) {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.ivoryGreen,
        borderRadius: BorderRadius.circular(15),
      ),
      padding: EdgeInsets.all(20),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: SizedBox(
              height: 115,
              width: 92,
              child: Image.network(
                data.avatarUrl ?? '',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) {
                  return Container(
                    width: 92,
                    height: 115,
                    color: Colors.grey[300],
                    child: Icon(Icons.broken_image, color: Colors.grey),
                  );
                },
              ),
            ),
          ),
          SizedBox(width: 20),

          // Left info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                  'Collections',
                  style: AppTextStyles.mulish(
                    fontSize: 10,
                    color: AppColor.gray84,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  '${data.collectionCount}',
                  style: AppTextStyles.mulish(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: AppColor.mildBlack,
                  ),
                ),
              ],
            ),
          ),

          // Right actions
          Column(
            children: [
              InkWell(
                onTap: () {
                  if (data.phoneNumber.trim().isNotEmpty) {
                    _launchDialer(data.phoneNumber);
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColor.black,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.5,
                    vertical: 19.5,
                  ),
                  child: Image.asset(AppImages.callImage1, height: 12),
                ),
              ),
              SizedBox(height: 15),
              InkWell(
                // onTap: () {
                //   final id = employee.id;
                //   context.push('${AppRoutes.heaterEmployeeDetailsEditPath}/$id');
                // },
                onTap: () {
                  // Pass employee id if needed
                  // context.push(
                  //   '${AppRoutes.heaterEmployeeDetailsPath}/${data.id}',
                  // );
                  context.push(
                    AppRoutes.heaterEmployeeDetailsPath,
                    extra: data.id,
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColor.black.withOpacity(0.5)),
                    borderRadius: BorderRadius.circular(10),
                  ),
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
            ],
          ),
        ],
      ),
    );
  }
}

/*
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
*/
