import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tringo_vendor_new/Core/Auth/logout_controller.dart';
import 'package:tringo_vendor_new/Core/Utility/app_snackbar.dart';
import 'package:tringo_vendor_new/Presentation/Support/Screen/support_screen.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../Core/Const/app_color.dart';
import '../../../../Core/Const/app_images.dart';
import '../../../../Core/Utility/app_textstyles.dart';
import '../../../../Core/Widgets/app_go_routes.dart';
import '../../../../Core/Widgets/common_container.dart';
import '../../Home Screen/Contoller/employee_home_notifier.dart';
import '../../Home Screen/Model/employee_home_response.dart';
import '../../Privacy Policy/Screen/privacy_policy.dart';
import '../controller/about_me_notifier.dart';

class EmployeeAboutMe extends ConsumerStatefulWidget {
  const EmployeeAboutMe({super.key});

  @override
  ConsumerState<EmployeeAboutMe> createState() => _EmployeeAboutMeState();
}

class _EmployeeAboutMeState extends ConsumerState<EmployeeAboutMe> {
  Future<void> _openPrivacyPolicy() async {
    final Uri url = Uri.parse('https://bknd.tringobiz.com/privacy-policy.html');

    final launched = await launchUrl(url, mode: LaunchMode.inAppWebView);

    if (!launched && mounted) {
      AppSnackBar.error(context, 'Could not open privacy policy');
    }
  }

  bool _deleteLoading = false;
  bool _logoutLoading = false;

  // ----------------------------
  // ✅ LOGOUT DIALOG (FIXED)
  // ----------------------------
  void _showLogoutDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor: AppColor.white,
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
              onPressed: _logoutLoading ? null : () => Navigator.pop(dialogCtx),
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
              onPressed:
                  _logoutLoading
                      ? null
                      : () async {
                        // ✅ close dialog first
                        Navigator.pop(dialogCtx);

                        if (!mounted) return;

                        setState(() => _logoutLoading = true);

                        try {
                          await ref
                              .read(logoutControllerProvider.notifier)
                              .logout();
                        } finally {
                          if (mounted) setState(() => _logoutLoading = false);
                        }

                        if (!mounted) return;

                        // ✅ navigate using page context (NOT dialog context)
                        // Navigation handled by logout flow (repo uses `go` to login).
                      },
              child: Text(
                _logoutLoading ? "..." : "Logout",
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

  // ----------------------------
  // ✅ DELETE ACCOUNT DIALOG (FIXED)
  // ----------------------------
  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: StatefulBuilder(
            builder: (context, setLocalState) {
              return Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.warning_rounded,
                        color: Colors.red.shade600,
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Delete Account?',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently removed.',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey.shade600,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 28),

                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 52,
                            child: OutlinedButton(
                              onPressed:
                                  _deleteLoading
                                      ? null
                                      : () => Navigator.of(dialogCtx).pop(),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: Colors.grey.shade300,
                                  width: 1.5,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                foregroundColor: Colors.grey.shade700,
                              ),
                              child: Text(
                                _deleteLoading ? '...' : 'Cancel',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: 52,
                            child: ElevatedButton(
                              onPressed:
                                  _deleteLoading
                                      ? null
                                      : () async {
                                        // ✅ IMPORTANT: capture safe pageContext BEFORE await
                                        final pageContext = this.context;

                                        setLocalState(
                                          () => _deleteLoading = true,
                                        );

                                        final success =
                                            await ref
                                                .read(
                                                  aboutMeNotifierProvider
                                                      .notifier,
                                                )
                                                .deleteProductAction();

                                        if (!mounted) return;

                                        setLocalState(
                                          () => _deleteLoading = false,
                                        );

                                        // ✅ close dialog using dialogCtx (safe)
                                        if (Navigator.of(dialogCtx).canPop()) {
                                          Navigator.of(dialogCtx).pop();
                                        }

                                        if (!mounted) return;

                                        if (success) {
                                          final prefs =
                                              await SharedPreferences.getInstance();
                                          await prefs.clear();

                                          // ✅ show snackbar BEFORE navigation (page context)
                                          ScaffoldMessenger.of(
                                            pageContext,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Account deleted successfully',
                                              ),
                                            ),
                                          );

                                          // ✅ then navigate (page context)
                                          await Future.delayed(
                                            const Duration(milliseconds: 150),
                                          );
                                          if (!mounted) return;
                                          pageContext.go(AppRoutes.loginPath);
                                        } else {
                                          final error =
                                              ref
                                                  .read(aboutMeNotifierProvider)
                                                  .error;

                                          ScaffoldMessenger.of(
                                            pageContext,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                error ??
                                                    'Account deletion failed',
                                              ),
                                            ),
                                          );
                                        }
                                      },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.shade600,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child:
                                  _deleteLoading
                                      ? const SizedBox(
                                        height: 18,
                                        width: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                      : const Text(
                                        'Delete',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
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
    final avatar = (employee?.avatarUrl ?? '').trim();

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
                                  (employee?.name ?? '').isNotEmpty
                                      ? employee!.name
                                      : '-',
                                  style: AppTextStyles.mulish(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 24,
                                    color: AppColor.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  employee?.employeeCode ?? '-',
                                  style: AppTextStyles.mulish(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                    color: AppColor.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
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
                                      employee?.vendorName ?? '-',
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
                            const Spacer(),
                            SizedBox(
                              height: 103,
                              width: 103,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child:
                                    avatar.isNotEmpty
                                        ? Image.network(
                                          avatar,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (_, __, ___) => Container(
                                                color: AppColor.gray84,
                                                child: const Icon(
                                                  Icons.person,
                                                  size: 40,
                                                  color: Colors.white,
                                                ),
                                              ),
                                        )
                                        : Image.asset(
                                          AppImages.profileImage,
                                          fit: BoxFit.cover,
                                        ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                CommonContainer.profileList(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SupportScreen()),
                    );
                  },
                  label: 'Support',
                  iconPath: AppImages.support,
                  iconHeight: 25,
                  iconWidth: 19,
                ),
                const SizedBox(height: 15),

                CommonContainer.profileList(
                  onTap: _deleteLoading ? null : _showDeleteAccountDialog,
                  label: 'Delete Account',
                  iconPath: AppImages.deleteAccount,
                  iconHeight: 25,
                  iconWidth: 19,
                ),
                const SizedBox(height: 15),

                CommonContainer.profileList(
                  onTap: () async {
                    await _openPrivacyPolicy();
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) =>
                    //         PrivacyPolicy(showAcceptReject: false),
                    //   ),
                    // );
                  },
                  label: 'Privacy Policy',
                  iconPath: AppImages.privacyPolicy,
                  iconHeight: 25,
                  iconWidth: 19,
                ),

                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _logoutLoading ? null : _showLogoutDialog,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(
                        color: AppColor.lightRed,
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child:
                        _logoutLoading
                            ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : Text(
                              'Logout',
                              style: AppTextStyles.mulish(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColor.lightRed,
                              ),
                            ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:tringo_vendor_new/Presentation/Support/Screen/support_screen.dart';
//
// import '../../../../Core/Const/app_color.dart';
// import '../../../../Core/Const/app_images.dart';
// import '../../../../Core/Utility/app_textstyles.dart';
// import '../../../../Core/Widgets/app_go_routes.dart';
// import '../../../../Core/Widgets/common_container.dart';
// import '../../Home Screen/Contoller/employee_home_notifier.dart';
// import '../../Home Screen/Model/employee_home_response.dart';
// import '../../Login Screen/Screens/login_mobile_number.dart';
// import '../../Privacy Policy/Screen/privacy_policy.dart';
// import '../controller/about_me_notifier.dart';
//
// class EmployeeAboutMe extends ConsumerStatefulWidget {
//   const EmployeeAboutMe({super.key});
//
//   @override
//   ConsumerState<EmployeeAboutMe> createState() => _EmployeeAboutMeState();
// }
//
// class _EmployeeAboutMeState extends ConsumerState<EmployeeAboutMe> {
//   void _showLogoutDialog() {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) {
//         return AlertDialog(
//           backgroundColor: AppColor.white,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16),
//           ),
//           title: Text(
//             "Logout",
//             style: AppTextStyles.mulish(
//               fontWeight: FontWeight.w800,
//               fontSize: 18,
//               color: AppColor.darkBlue,
//             ),
//           ),
//           content: Text(
//             "Are you sure you want to logout?",
//             style: AppTextStyles.mulish(
//               fontSize: 15,
//               fontWeight: FontWeight.w600,
//               color: AppColor.lightGray2,
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context);
//               },
//               child: Text(
//                 "Cancel",
//                 style: AppTextStyles.mulish(
//                   fontSize: 14,
//                   fontWeight: FontWeight.bold,
//                   color: AppColor.darkBlue,
//                 ),
//               ),
//             ),
//             TextButton(
//               onPressed: () async {
//                 // Navigator.pop(context);
//                 // Navigator.pushAndRemoveUntil(
//                 //   context,
//                 //   MaterialPageRoute(builder: (_) => LoginMobileNumber()),
//                 //   (route) => false,
//                 // );
//                 final prefs = await SharedPreferences.getInstance();
//                 prefs.remove('token');
//                 prefs.remove('isProfileCompleted');
//                 prefs.remove('isNewOwner');
//                 await prefs.clear();
//
//                 // Then navigate
//                 context.goNamed(AppRoutes.login);
//               },
//               child: Text(
//                 "Logout",
//                 style: AppTextStyles.mulish(
//                   fontSize: 14,
//                   fontWeight: FontWeight.bold,
//                   color: AppColor.lightRed,
//                 ),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   void _showDeleteAccountDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return Dialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(24),
//           ),
//           elevation: 0,
//           backgroundColor: Colors.transparent,
//           child: Container(
//             padding: const EdgeInsets.all(24),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(24),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.15),
//                   blurRadius: 20,
//                   offset: const Offset(0, 10),
//                 ),
//               ],
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 // Icon
//                 Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: Colors.red.shade50,
//                     shape: BoxShape.circle,
//                   ),
//                   child: Icon(
//                     Icons.warning_rounded,
//                     color: Colors.red.shade600,
//                     size: 48,
//                   ),
//                 ),
//
//                 const SizedBox(height: 20),
//
//                 // Title
//                 const Text(
//                   'Delete Account?',
//                   style: TextStyle(
//                     fontSize: 22,
//                     fontWeight: FontWeight.w700,
//                     color: Colors.black87,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//
//                 const SizedBox(height: 12),
//
//                 // Description
//                 Text(
//                   'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently removed.',
//                   style: TextStyle(
//                     fontSize: 15,
//                     color: Colors.grey.shade600,
//                     height: 1.5,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//
//                 const SizedBox(height: 28),
//
//                 // Buttons
//                 Row(
//                   children: [
//                     // Cancel Button
//                     Expanded(
//                       child: SizedBox(
//                         height: 52,
//                         child: OutlinedButton(
//                           onPressed: () {
//                             Navigator.of(context).pop();
//                           },
//                           style: OutlinedButton.styleFrom(
//                             side: BorderSide(
//                               color: Colors.grey.shade300,
//                               width: 1.5,
//                             ),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(14),
//                             ),
//                             foregroundColor: Colors.grey.shade700,
//                           ),
//                           child: const Text(
//                             'Cancel',
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//
//                     const SizedBox(width: 12),
//
//                     // Delete Button
//                     Expanded(
//                       child: SizedBox(
//                         height: 52,
//                         child: ElevatedButton(
//                           onPressed: () async {
//                             Navigator.of(context).pop();
//
//                             final success =
//                                 await ref
//                                     .read(aboutMeNotifierProvider.notifier)
//                                     .deleteProductAction();
//
//                             if (!mounted) return;
//
//                             if (success) {
//                               // 🔥 HARD RESET — account is gone
//                               final prefs =
//                                   await SharedPreferences.getInstance();
//                               await prefs.clear();
//
//                               // context.goNamed(AppRoutes.login);
//                               context.go(AppRoutes.loginPath);
//
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 const SnackBar(
//                                   content: Text('Account deleted successfully'),
//                                 ),
//                               );
//                             } else {
//                               final error =
//                                   ref.read(aboutMeNotifierProvider).error;
//
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 SnackBar(
//                                   content: Text(
//                                     error ?? 'Account deletion failed',
//                                   ),
//                                 ),
//                               );
//                             }
//                           },
//
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.red.shade600,
//                             foregroundColor: Colors.white,
//                             elevation: 0,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(14),
//                             ),
//                           ),
//                           child: const Text(
//                             'Delete',
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final state = ref.watch(employeeHomeNotifier);
//     final EmployeeHomeResponse? response = state.employeeHomeResponse;
//     final EmployeeData? dashboard = response?.data;
//     final employee = dashboard?.employee;
//     final avatar = (employee?.avatarUrl ?? '').trim();
//     return Scaffold(
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
//             child: Column(
//               children: [
//                 Stack(
//                   children: [
//                     Container(
//                       decoration: BoxDecoration(
//                         image: DecorationImage(
//                           image: AssetImage(AppImages.settingBCImage),
//                         ),
//                         gradient: LinearGradient(
//                           colors: [AppColor.brightBlue, AppColor.electricBlue],
//                           begin: Alignment.centerLeft,
//                           end: Alignment.centerRight,
//                         ),
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 20,
//                           vertical: 21,
//                         ),
//                         child: Row(
//                           children: [
//                             Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   employee!.name.isNotEmpty
//                                       ? employee.name
//                                       : '-',
//                                   style: AppTextStyles.mulish(
//                                     fontWeight: FontWeight.w900,
//                                     fontSize: 24,
//                                     color: AppColor.white,
//                                   ),
//                                 ),
//                                 SizedBox(height: 8),
//                                 Text(
//                                   employee.employeeCode,
//                                   style: AppTextStyles.mulish(
//                                     fontWeight: FontWeight.w700,
//                                     fontSize: 12,
//                                     color: AppColor.white,
//                                   ),
//                                 ),
//                                 SizedBox(height: 4),
//                                 Row(
//                                   children: [
//                                     Text(
//                                       'Reporting',
//                                       style: AppTextStyles.mulish(
//                                         fontWeight: FontWeight.w600,
//                                         fontSize: 10,
//                                         color: AppColor.white4,
//                                       ),
//                                     ),
//                                     const SizedBox(width: 3),
//                                     Text(
//                                       '-',
//                                       style: AppTextStyles.mulish(
//                                         fontWeight: FontWeight.w800,
//                                         fontSize: 10,
//                                         color: AppColor.white4,
//                                       ),
//                                     ),
//                                     const SizedBox(width: 3),
//                                     Text(
//                                       employee.vendorName,
//                                       style: AppTextStyles.mulish(
//                                         fontWeight: FontWeight.w800,
//                                         fontSize: 10,
//                                         color: AppColor.white4,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                             Spacer(),
//                             SizedBox(
//                               height: 103,
//                               width: 103,
//                               child: ClipRRect(
//                                 borderRadius: BorderRadius.circular(14),
//                                 child:
//                                     avatar.isNotEmpty
//                                         ? Image.network(
//                                           avatar,
//                                           fit: BoxFit.cover,
//                                           errorBuilder:
//                                               (_, __, ___) => Container(
//                                                 color:
//                                                     AppColor
//                                                         .gray84, // optional background
//                                                 child: const Icon(
//                                                   Icons.person,
//                                                   size: 40,
//                                                   color: Colors.white,
//                                                 ),
//                                               ),
//                                         )
//                                         : Image.asset(
//                                           AppImages.profileImage,
//                                           fit: BoxFit.cover,
//                                         ),
//                               ),
//                             ),
//
//                             // ClipRRect(
//                             //   borderRadius: BorderRadius.circular(20),
//                             //   child: CachedNetworkImage(
//                             //     imageUrl: widget.url ?? '',
//                             //     height: 120,
//                             //     width: 120,
//                             //     fit: BoxFit.cover,
//                             //
//                             //     placeholder: (context, url) => Container(
//                             //       height: 120,
//                             //       width: 120,
//                             //       color: Colors.grey.withOpacity(0.2),
//                             //     ),
//                             //
//                             //     errorWidget: (context, url, error) => Container(
//                             //       height: 120,
//                             //       width: 120,
//                             //       color: Colors.grey.withOpacity(0.2),
//                             //       child:   Icon(Icons.broken_image, size: 28),
//                             //     ),
//                             //   ),
//                             // ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     // Positioned(
//                     //   right: 105,
//                     //   top: 55,
//                     //   child: Container(
//                     //     decoration: BoxDecoration(
//                     //       color: AppColor.white.withOpacity(0.8),
//                     //       borderRadius: BorderRadius.circular(50),
//                     //     ),
//                     //     child: Padding(
//                     //       padding: const EdgeInsets.symmetric(
//                     //         horizontal: 10.5,
//                     //         vertical: 8,
//                     //       ),
//                     //       child: Image.asset(
//                     //         AppImages.downloadImage01,
//                     //         height: 16,
//                     //       ),
//                     //     ),
//                     //   ),
//                     // ),
//                   ],
//                 ),
//                 SizedBox(height: 40),
//                 // CommonContainer.profileList(
//                 //   onTap: () {},
//                 //   label: 'Edit My Personal Details',
//                 //   iconPath: AppImages.settingDark,
//                 //   iconHeight: 25,
//                 //   iconWidth: 19,
//                 // ),
//                 // SizedBox(height: 15),
//                 // CommonContainer.profileList(
//                 //   onTap: () {},
//                 //   label: 'Edit My Bank Account Details',
//                 //   iconPath: AppImages.editBank,
//                 //   iconHeight: 25,
//                 //   iconWidth: 19,
//                 // ),
//                 // SizedBox(height: 15),
//                 // CommonContainer.profileList(
//                 //   onTap: () {},
//                 //   label: 'Edit Company Details',
//                 //   iconPath: AppImages.editCompany,
//                 //   iconHeight: 25,
//                 //   iconWidth: 19,
//                 // ),
//                 //
//                 // SizedBox(height: 20),
//                 // CommonContainer.horizonalDivider(),
//                 // SizedBox(height: 20),
//                 CommonContainer.profileList(
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (context) => SupportScreen()),
//                     );
//                   },
//                   label: 'Support',
//                   iconPath: AppImages.support,
//                   iconHeight: 25,
//                   iconWidth: 19,
//                 ),
//                 SizedBox(height: 15),
//                 CommonContainer.profileList(
//                   onTap: () {
//                     _showDeleteAccountDialog(context);
//                   },
//                   label: 'Delete Account',
//                   iconPath: AppImages.deleteAccount,
//                   iconHeight: 25,
//                   iconWidth: 19,
//                 ),
//                 SizedBox(height: 15),
//                 CommonContainer.profileList(
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder:
//                             (context) => PrivacyPolicy(showAcceptReject: false),
//                       ),
//                     );
//                   },
//                   label: 'Privacy Policy',
//                   iconPath: AppImages.privacyPolicy,
//                   iconHeight: 25,
//                   iconWidth: 19,
//                 ),
//                 SizedBox(height: 20),
//
//                 // CommonContainer.horizonalDivider(),
//                 SizedBox(height: 20),
//                 SizedBox(
//                   width: double.infinity,
//                   child: OutlinedButton(
//                     onPressed: () {
//                       _showLogoutDialog();
//                     },
//                     style: OutlinedButton.styleFrom(
//                       padding: EdgeInsets.symmetric(vertical: 12),
//                       side: const BorderSide(
//                         color: AppColor.lightRed,
//                         width: 1.5,
//                       ),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(
//                           20,
//                         ), // optional – rounded corners
//                       ),
//                     ),
//                     child: Text(
//                       'Logout',
//                       style: AppTextStyles.mulish(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                         color: AppColor.lightRed, // text color
//                       ),
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: 20),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
