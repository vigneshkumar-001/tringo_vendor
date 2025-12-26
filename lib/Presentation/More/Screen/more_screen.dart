// import 'package:flutter/material.dart';
//
// import '../../../../Core/Const/app_color.dart';
// import '../../../../Core/Const/app_images.dart';
// import '../../../../Core/Utility/app_textstyles.dart';
// import '../../../../Core/Widgets/common_container.dart';
//
// class NoDataScreens extends StatefulWidget {
//   const NoDataScreens({super.key});
//
//   @override
//   State<NoDataScreens> createState() => _NoDataScreensState();
// }
//
// class _NoDataScreensState extends State<NoDataScreens> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 160),
//           child: Column(
//             children: [
//               Image.asset(AppImages.noDataGif),
//               SizedBox(height: 40),
//
//               Center(
//                 child: Text(
//                   overflow: TextOverflow.ellipsis,
//                   maxLines: 1,
//                   'This feature is currently under development',
//                   style: AppTextStyles.mulish(
//                     fontSize: 15,
//                     fontWeight: FontWeight.w800,
//                     color: AppColor.darkBlue,
//                   ),
//                 ),
//               ),
//               SizedBox(height: 26),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../Core/Const/app_color.dart';
import '../../../../Core/Const/app_images.dart';
import '../../../../Core/Utility/app_textstyles.dart';
import '../../../../Core/Widgets/app_go_routes.dart';
import '../../../../Core/Widgets/common_container.dart';
import '../../Home Screen/Contoller/employee_home_notifier.dart';
import '../../Home Screen/Model/employee_home_response.dart';

class MoreScreen extends ConsumerStatefulWidget {
  const MoreScreen({super.key});

  @override
  ConsumerState<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends ConsumerState<MoreScreen> {
  void _showLogoutDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            "Logout",
            style: AppTextStyles.mulish(
              fontWeight: FontWeight.w800,
              fontSize: 18,
              color: AppColor.darkBlue,
            ),
          ),
          content: Text(
            "Are you sure you want to logout?",
            style: AppTextStyles.mulish(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColor.lightGray2,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                "Cancel",
                style: AppTextStyles.mulish(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColor.darkBlue,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                // Navigator.pop(context);
                // Navigator.pushAndRemoveUntil(
                //   context,
                //   MaterialPageRoute(builder: (_) => LoginMobileNumber()),
                //   (route) => false,
                // );
                final prefs = await SharedPreferences.getInstance();
                prefs.remove('token');
                prefs.remove('isProfileCompleted');
                prefs.remove('isNewOwner');
                await prefs.clear();

                // Then navigate
                context.goNamed(AppRoutes.login);
              },
              child: Text(
                "Logout",
                style: AppTextStyles.mulish(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColor.lightRed,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(employeeHomeNotifier);
    final EmployeeHomeResponse? response = state.employeeHomeResponse;
    final EmployeeData? dashboard = response?.data;
    final employee = dashboard?.employee;
    final metrics = dashboard?.metrics;
    final recentActivity = dashboard?.recentActivity;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              children: [
                Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(AppImages.settingBCImage),
                        ),
                        gradient: LinearGradient(
                          colors: [AppColor.brightBlue, AppColor.electricBlue],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 21,
                        ),
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  employee!.name.isNotEmpty
                                      ? employee.name
                                      : '-',
                                  style: AppTextStyles.mulish(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 24,
                                    color: AppColor.white,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  employee.employeeCode,
                                  style: AppTextStyles.mulish(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                    color: AppColor.white,
                                  ),
                                ),
                                SizedBox(height: 4),
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
                                    const SizedBox(width: 3),
                                    Text(
                                      '-',
                                      style: AppTextStyles.mulish(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 10,
                                        color: AppColor.white4,
                                      ),
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      employee.vendorName,
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
                            SizedBox(
                              height: 103,
                              width: 103,
                              child: Image.asset(
                                AppImages.settingAvatar,
                                fit: BoxFit.cover,
                              ),
                            ),

                            // ClipRRect(
                            //   borderRadius: BorderRadius.circular(20),
                            //   child: CachedNetworkImage(
                            //     imageUrl: widget.url ?? '',
                            //     height: 120,
                            //     width: 120,
                            //     fit: BoxFit.cover,
                            //
                            //     placeholder: (context, url) => Container(
                            //       height: 120,
                            //       width: 120,
                            //       color: Colors.grey.withOpacity(0.2),
                            //     ),
                            //
                            //     errorWidget: (context, url, error) => Container(
                            //       height: 120,
                            //       width: 120,
                            //       color: Colors.grey.withOpacity(0.2),
                            //       child:   Icon(Icons.broken_image, size: 28),
                            //     ),
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      right: 105,
                      top: 55,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColor.white.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10.5,
                            vertical: 8,
                          ),
                          child: Image.asset(
                            AppImages.downloadImage01,
                            height: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 40),
                CommonContainer.profileList(
                  onTap: () {},
                  label: 'Edit My Personal Details',
                  iconPath: AppImages.settingDark,
                  iconHeight: 25,
                  iconWidth: 19,
                ),
                SizedBox(height: 15),
                CommonContainer.profileList(
                  onTap: () {},
                  label: 'Edit My Bank Account Details',
                  iconPath: AppImages.editBank,
                  iconHeight: 25,
                  iconWidth: 19,
                ),
                SizedBox(height: 15),
                CommonContainer.profileList(
                  onTap: () {},
                  label: 'Edit Company Details',
                  iconPath: AppImages.editCompany,
                  iconHeight: 25,
                  iconWidth: 19,
                ),

                SizedBox(height: 20),
                CommonContainer.horizonalDivider(),
                SizedBox(height: 20),
                CommonContainer.profileList(
                  onTap: () {},
                  label: 'Support',
                  iconPath: AppImages.support,
                  iconHeight: 25,
                  iconWidth: 19,
                ),
                SizedBox(height: 15),
                CommonContainer.profileList(
                  onTap: () {},
                  label: 'Delete Account',
                  iconPath: AppImages.deleteAccount,
                  iconHeight: 25,
                  iconWidth: 19,
                ),
                SizedBox(height: 15),
                CommonContainer.profileList(
                  onTap: () {},
                  label: 'Privacy Policy',
                  iconPath: AppImages.privacyPolicy,
                  iconHeight: 25,
                  iconWidth: 19,
                ),
                SizedBox(height: 20),
                CommonContainer.horizonalDivider(),

                SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      _showLogoutDialog();
                    },
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(
                        color: AppColor.lightRed,
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          20,
                        ), // optional – rounded corners
                      ),
                    ),
                    child: Text(
                      'Logout',
                      style: AppTextStyles.mulish(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColor.lightRed, // text color
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
