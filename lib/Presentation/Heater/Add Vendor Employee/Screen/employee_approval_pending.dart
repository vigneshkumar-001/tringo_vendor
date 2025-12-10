import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tringo_vendor_new/Core/Widgets/app_go_routes.dart';
import 'package:tringo_vendor_new/Core/Widgets/common_container.dart';
import 'package:tringo_vendor_new/Presentation/Heater/Add%20Vendor%20Employee/Controller/add_employee_notifier.dart';

import '../../../../Core/Const/app_color.dart';
import '../../../../Core/Const/app_images.dart';
import '../../../../Core/Utility/app_loader.dart';
import '../../../../Core/Utility/app_textstyles.dart';

class EmployeeApprovalPending extends ConsumerStatefulWidget {
  const EmployeeApprovalPending({super.key});

  @override
  ConsumerState<EmployeeApprovalPending> createState() =>
      _EmployeeApprovalPendingState();
}

class _EmployeeApprovalPendingState
    extends ConsumerState<EmployeeApprovalPending> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(addEmployeeNotifier.notifier).getEmployeeList();
    });
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
      return Center(child: Text('No Data Found'));
    }

    final employeeData = employeeListData.data;
    final status = employeeData.approvalStatus.trim();


    if (status == 'ACTIVE') {
      WidgetsBinding.instance.addPostFrameCallback((_) {

      });

      return Scaffold(
        body: Center(child: ThreeDotsLoader(dotColor: AppColor.black)),
      );
    }
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              employeeData.approvalStatus != 'PENDING'
                  ? rejectedCard()
                  : pendingCard(),
              SizedBox(height: 42),
              Text(
                'Employees',
                style: AppTextStyles.mulish(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: employeeData.employees.length,
                      itemBuilder: (context, index) {
                        final data = employeeData.employees[index];
                        return Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                // color: AppColor.ivoryGreen,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 20,
                                ),
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
                                              (context, url) => Center(
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                    ),
                                              ),
                                          errorWidget:
                                              (context, url, error) =>
                                                  Image.asset(
                                                    AppImages.humanImage1,
                                                    fit: BoxFit.cover,
                                                  ),
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
                                            fontSize: 18,
                                            color: AppColor.darkBlue,
                                          ),
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          data.email,
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
                                    Spacer(),
                                    InkWell(
                                      borderRadius: BorderRadius.circular(10),
                                      onTap: () {},
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: AppColor.whiteSmoke,

                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Padding(
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
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            CommonContainer.horizonalDivider(),
                          ],
                        );
                      },
                    ),

                    CommonContainer.button(
                      onTap: () {
                        context.push(AppRoutes.employeeApprovalRejectedPath);
                      },
                      buttonColor: AppColor.darkBlue,
                      imagePath: AppImages.rightStickArrow,
                      text: Text('Add Employee'),
                    ),
                    SizedBox(height: 30),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
