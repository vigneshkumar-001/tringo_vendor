import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tringo_vendor_new/Core/Widgets/app_go_routes.dart';
import 'package:tringo_vendor_new/Core/Widgets/common_container.dart';

import '../../../../Core/Const/app_color.dart';
import '../../../../Core/Const/app_images.dart';
import '../../../../Core/Utility/app_textstyles.dart';

class EmployeeApprovalPending extends StatefulWidget {
  const EmployeeApprovalPending({super.key});

  @override
  State<EmployeeApprovalPending> createState() =>
      _EmployeeApprovalPendingState();
}

class _EmployeeApprovalPendingState extends State<EmployeeApprovalPending> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
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
              ),
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
                    Container(
                      decoration: BoxDecoration(
                        // color: AppColor.ivoryGreen,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
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
                                    fontSize: 18,
                                    color: AppColor.darkBlue,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  'siva@gmail.com',
                                  style: AppTextStyles.mulish(
                                    fontSize: 16,
                                    color: AppColor.mildBlack,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  '+91 74484 35385',
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

                                  borderRadius: BorderRadius.circular(10),
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
                    SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        // color: AppColor.ivoryGreen,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
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
                                  'Siva',
                                  style: AppTextStyles.mulish(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 18,
                                    color: AppColor.darkBlue,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  'siva@gmail.com',
                                  style: AppTextStyles.mulish(
                                    fontSize: 16,
                                    color: AppColor.mildBlack,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  '+91 74484 35385',
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

                                  borderRadius: BorderRadius.circular(10),
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
                    SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        children: [
                          Text(
                            'Note',
                            style: AppTextStyles.mulish(
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                              color: AppColor.darkBlue,
                            ),
                          ),
                          SizedBox(width: 5),
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
                    SizedBox(height: 30),
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
}
