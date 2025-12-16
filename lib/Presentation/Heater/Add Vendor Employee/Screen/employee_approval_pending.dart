import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tringo_vendor_new/Core/Widgets/app_go_routes.dart';
import 'package:tringo_vendor_new/Core/Widgets/common_container.dart';
import 'package:tringo_vendor_new/Presentation/Heater/Add%20Vendor%20Employee/Controller/add_employee_notifier.dart';
import 'package:tringo_vendor_new/Presentation/No%20Data%20Screen/Screen/no_data_screen.dart';

import '../../../../Core/Const/app_color.dart';
import '../../../../Core/Const/app_images.dart';
import '../../../../Core/Utility/app_loader.dart';
import '../../../../Core/Utility/app_textstyles.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EmployeeApprovalPending extends ConsumerStatefulWidget {
  const EmployeeApprovalPending({super.key});

  @override
  ConsumerState<EmployeeApprovalPending> createState() =>
      _EmployeeApprovalPendingState();
}

class _EmployeeApprovalPendingState
    extends ConsumerState<EmployeeApprovalPending> {
  Timer? _pollTimer;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(addEmployeeNotifier.notifier).getEmployeeList();

      //  poll every 5 seconds until approved
      _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
        ref.read(addEmployeeNotifier.notifier).getEmployeeList(silent: true);
      });
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(addEmployeeNotifier);

    if (state.isLoading) {
      return Scaffold(
        body: Center(child: ThreeDotsLoader(dotColor: AppColor.black)),
      );
    }
    final employeeListData = state.employeeListResponse;
    if (employeeListData == null) {
      return NoDataScreen(showBottomButton: false, showTopBackArrow: false);
    }

    final employeeData = employeeListData.data;

    final status = employeeData.approvalStatus.trim().toUpperCase();

    // Widget topCard;
    // if (status == 'PENDING') {
    //   topCard = pendingCard();
    // } else if (status == 'REJECTED') {
    //   topCard = rejectedCard();
    // } else {
    //   topCard = const SizedBox.shrink();
    // }

    if (status == 'ACTIVE' && !_navigated) {
      _navigated = true;

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('vendorStatus', 'ACTIVE');

        _pollTimer?.cancel(); // stop polling
        if (!mounted) return;

        context.go(AppRoutes.heaterHomeScreenPath);

        
      });

      return Scaffold(
        body: Center(child: ThreeDotsLoader(dotColor: AppColor.black)),
      );
    }

    // if (status == 'ACTIVE') {
    //   WidgetsBinding.instance.addPostFrameCallback((_) async {
    //     final prefs = await SharedPreferences.getInstance();
    //     await prefs.setString('vendorStatus', 'ACTIVE');
    //   });
    // }
    // if (status == 'ACTIVE') {
    //   WidgetsBinding.instance.addPostFrameCallback((_) {
    //     if (mounted) {
    //       context.go(AppRoutes.heaterHomeScreenPath);
    //     }
    //   });
    //
    //   return Scaffold(
    //     body: Center(child: ThreeDotsLoader(dotColor: AppColor.black)),
    //   );
    // }

    final Widget topCard =
        (status == 'PENDING') ? pendingCard() : rejectedCard();

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await ref.read(addEmployeeNotifier.notifier).getEmployeeList();
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: topCard),
              const SliverToBoxAdapter(child: SizedBox(height: 42)),
              SliverToBoxAdapter(
                child: Center(
                  child: Text(
                    'Employees',
                    style: AppTextStyles.mulish(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(child: SizedBox(height: 20)),

              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final data = employeeData.employees[index];
                    return Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: SizedBox(
                                    height: 115,
                                    width: 92,
                                    child: CachedNetworkImage(
                                      imageUrl: data.avatarUrl,
                                      fit: BoxFit.cover,
                                      placeholder:
                                          (context, url) => const Center(
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          ),
                                      errorWidget:
                                          (context, url, error) => Image.asset(
                                            AppImages.humanImage1,
                                            fit: BoxFit.cover,
                                          ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 20),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        data.name,
                                        style: AppTextStyles.mulish(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 18,
                                          color: AppColor.darkBlue,
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        data.email,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style: AppTextStyles.mulish(
                                          fontSize: 16,
                                          color: AppColor.mildBlack,
                                        ),
                                      ),
                                      SizedBox(height: 6),
                                      Text(
                                        data.phoneNumber,
                                        style: AppTextStyles.mulish(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14,
                                          color: AppColor.blueGradient1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                InkWell(
                                  borderRadius: BorderRadius.circular(10),
                                  onTap: () {},
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: AppColor.whiteSmoke,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14.5,
                                      vertical: 36.5,
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
                          ),
                        ),
                        SizedBox(height: 0),
                        CommonContainer.horizonalDivider(),
                        SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            children: [
                              Text(
                                'Note',
                                style: AppTextStyles.mulish(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                  color: AppColor.darkBlue,
                                ),
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Once you get approval employees will also get email',
                                style: AppTextStyles.mulish(
                                  fontSize: 12,
                                  color: AppColor.gray84,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // CommonContainer.button(
                        //                 onTap: () {
                        //                   context.push(AppRoutes.heaterAddEmployeePath);
                        //                 },
                        //                 buttonColor: AppColor.darkBlue,
                        //                 imagePath:
                        //                     state.isLoading ? null : AppImages.rightStickArrow,
                        //                 text:
                        //                     state.isLoading
                        //                         ? ThreeDotsLoader()
                        //                         : Text('Add Employee'),
                        //               ),
                      ],
                    );
                  }, childCount: employeeData.employees.length),
                ),
              ),

              SliverToBoxAdapter(child: SizedBox(height: 30)),
            ],
          ),
        ),
      ),
    );

    // return Scaffold(
    //   body: SafeArea(
    //     child: RefreshIndicator(
    //       onRefresh: () async {
    //         await ref.read(addEmployeeNotifier.notifier).getEmployeeList();
    //       },
    //       child: SingleChildScrollView(
    //         physics: const AlwaysScrollableScrollPhysics(),
    //         child: Column(
    //           children: [
    //             topCard,
    //             // employeeData.approvalStatus != 'PENDING'
    //             //     ? rejectedCard()
    //             //     : pendingCard(),
    //             SizedBox(height: 42),
    //             Text(
    //               'Employees',
    //               style: AppTextStyles.mulish(
    //                 fontSize: 22,
    //                 fontWeight: FontWeight.w700,
    //               ),
    //             ),
    //             SizedBox(height: 20),
    //
    //             Padding(
    //               padding: const EdgeInsets.symmetric(horizontal: 16),
    //               child: Column(
    //                 children: [
    //                   ListView.builder(
    //                     shrinkWrap: true,
    //                     physics: const NeverScrollableScrollPhysics(),
    //                     itemCount: employeeData.employees.length,
    //                     itemBuilder: (context, index) {
    //                       final data = employeeData.employees[index];
    //                       return Column(
    //                         children: [
    //                           Container(
    //                             decoration: BoxDecoration(
    //                               // color: AppColor.ivoryGreen,
    //                               borderRadius: BorderRadius.circular(15),
    //                             ),
    //                             child: Padding(
    //                               padding: const EdgeInsets.symmetric(
    //                                 vertical: 20,
    //                               ),
    //                               child: Row(
    //                                 children: [
    //                                   ClipRRect(
    //                                     borderRadius: BorderRadius.circular(15),
    //                                     child: SizedBox(
    //                                       height: 115,
    //                                       width: 92,
    //                                       child: CachedNetworkImage(
    //                                         imageUrl: data.avatarUrl,
    //                                         fit: BoxFit.cover,
    //                                         placeholder:
    //                                             (context, url) => Center(
    //                                               child:
    //                                                   CircularProgressIndicator(
    //                                                     strokeWidth: 2,
    //                                                   ),
    //                                             ),
    //                                         errorWidget:
    //                                             (context, url, error) =>
    //                                                 Image.asset(
    //                                                   AppImages.humanImage1,
    //                                                   fit: BoxFit.cover,
    //                                                 ),
    //                                       ),
    //                                     ),
    //                                   ),
    //
    //                                   SizedBox(width: 20),
    //                                   Expanded(
    //                                     child: Column(
    //                                       crossAxisAlignment:
    //                                           CrossAxisAlignment.start,
    //                                       mainAxisSize: MainAxisSize.min,
    //                                       children: [
    //                                         Text(
    //                                           data.name,
    //                                           style: AppTextStyles.mulish(
    //                                             fontWeight: FontWeight.w700,
    //                                             fontSize: 18,
    //                                             color: AppColor.darkBlue,
    //                                           ),
    //                                         ),
    //                                         SizedBox(height: 5),
    //                                         Text(
    //                                           overflow: TextOverflow.ellipsis,
    //                                           maxLines: 1,
    //                                           data.email,
    //                                           style: AppTextStyles.mulish(
    //                                             fontSize: 16,
    //                                             color: AppColor.mildBlack,
    //                                           ),
    //                                         ),
    //                                         SizedBox(height: 6),
    //                                         Text(
    //                                           data.phoneNumber,
    //                                           style: AppTextStyles.mulish(
    //                                             fontWeight: FontWeight.w700,
    //                                             fontSize: 14,
    //                                             color: AppColor.blueGradient1,
    //                                           ),
    //                                         ),
    //                                       ],
    //                                     ),
    //                                   ),
    //                                   Spacer(),
    //                                   InkWell(
    //                                     borderRadius: BorderRadius.circular(10),
    //                                     onTap: () {},
    //                                     child: Container(
    //                                       decoration: BoxDecoration(
    //                                         color: AppColor.whiteSmoke,
    //
    //                                         borderRadius: BorderRadius.circular(
    //                                           10,
    //                                         ),
    //                                       ),
    //                                       child: Padding(
    //                                         padding: const EdgeInsets.symmetric(
    //                                           horizontal: 14.5,
    //                                           vertical: 36.5,
    //                                         ),
    //                                         child: Image.asset(
    //                                           AppImages.rightArrow,
    //                                           color: AppColor.darkBlue,
    //                                           height: 12,
    //                                         ),
    //                                       ),
    //                                     ),
    //                                   ),
    //                                 ],
    //                               ),
    //                             ),
    //                           ),
    //                           SizedBox(height: 10),
    //                           CommonContainer.horizonalDivider(),
    //                         ],
    //                       );
    //                     },
    //                   ),
    //
    //                   // CommonContainer.button(
    //                   //   onTap: () {
    //                   //     context.push(AppRoutes.heaterAddEmployeePath);
    //                   //   },
    //                   //   buttonColor: AppColor.darkBlue,
    //                   //   imagePath:
    //                   //       state.isLoading ? null : AppImages.rightStickArrow,
    //                   //   text:
    //                   //       state.isLoading
    //                   //           ? ThreeDotsLoader()
    //                   //           : Text('Add Employee'),
    //                   // ),
    //                   SizedBox(height: 30),
    //                 ],
    //               ),
    //             ),
    //           ],
    //         ),
    //       ),
    //     ),
    //   ),
    // );
  }

  Widget pendingCard() {
    return Padding(
      padding: const EdgeInsets.only(top: 80),
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppImages.registerBCImage),
            fit: BoxFit.cover,
          ),
          gradient: LinearGradient(
            colors: [AppColor.white, AppColor.lightSkyBlue],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: const BorderRadius.only(
            bottomRight: Radius.circular(30),
            bottomLeft: Radius.circular(30),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Image.asset(AppImages.approvalPending, height: 149),
              SizedBox(height: 15),
              Text(
                'Approval Pending',
                style: AppTextStyles.mulish(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColor.mildBlack,
                ),
              ),
              SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Text(
                  'Once admin approved you can move forward,now you can add employees',
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.visible,
                  style: AppTextStyles.mulish(
                    fontSize: 12,
                    color: AppColor.gray84,
                  ),
                ),
              ),

              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget rejectedCard() {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppImages.registerBCImage),
            fit: BoxFit.cover,
          ),
          gradient: LinearGradient(
            colors: [AppColor.white, AppColor.softRose],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: const BorderRadius.only(
            bottomRight: Radius.circular(30),
            bottomLeft: Radius.circular(30),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Image.asset(AppImages.approvalRejected, height: 175),
              SizedBox(height: 15),
              Text(
                'Approval Rejected',
                style: AppTextStyles.mulish(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColor.mildBlack,
                ),
              ),
              SizedBox(height: 15),
              Text(
                'Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.',
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.visible,
                style: AppTextStyles.mulish(
                  fontSize: 12,
                  color: AppColor.gray84,
                ),
              ),
              SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 60),
                child: CommonContainer.button(
                  onTap: () {
                    // context.push(AppRoutes.employeeApprovalRejectedPath);
                  },
                  buttonColor: AppColor.darkBlue,
                  imagePath: AppImages.rightStickArrow,
                  text: Text('Fix the Issue'),
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
