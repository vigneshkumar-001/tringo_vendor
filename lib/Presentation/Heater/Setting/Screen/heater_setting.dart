import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../Core/Const/app_color.dart';
import '../../../../Core/Const/app_images.dart';
import '../../../../Core/Utility/app_snackbar.dart';
import '../../../../Core/Utility/app_textstyles.dart';
import '../../../../Core/Widgets/app_go_routes.dart';
import '../../../../Core/Widgets/common_container.dart';
import '../../../About Me/Controller/about_me_notifier.dart';
import '../../Heater Home Screen/Controller/heater_home_notifier.dart';
import '../../Heater Home Screen/Model/heater_home_response.dart';

class HeaterSetting extends ConsumerStatefulWidget {
  const HeaterSetting({super.key});

  @override
  ConsumerState<HeaterSetting> createState() => _HeaterSettingState();
}

class _HeaterSettingState extends ConsumerState<HeaterSetting> {
  Future<bool> _confirmDeleteAccount(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
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
                    color: Colors.grey,
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
                          onPressed: () {
                            Navigator.of(
                              dialogContext,
                            ).pop(false); // <-- return false
                          },
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
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
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
                          onPressed: () {
                            Navigator.of(
                              dialogContext,
                            ).pop(true); // <-- return true
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade600,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
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
          ),
        );
      },
    );

    return result ?? false; // if dialog is dismissed unexpectedly
  }

  Future<void> _handleDeleteAccount() async {
    final confirmed = await _confirmDeleteAccount(context);
    if (!confirmed) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await ref.read(aboutMeNotifierProvider.notifier).deleteProductAction();
    } finally {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop(); // always close loader
      }
    }

    final st = ref.read(aboutMeNotifierProvider);

    final success =
        st.accountDeleteResponse?.status == true &&
        st.accountDeleteResponse?.data.deleted == true;

    if (!mounted) return;

    if (success) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      AppSnackBar.success(context, "Account deleted successfully");
      context.goNamed(AppRoutes.login);
    } else {
      AppSnackBar.error(context, st.error ?? "Delete failed");
    }
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
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
                // Icon
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

                // Title
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

                // Description
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

                // Buttons
                Row(
                  children: [
                    // Cancel Button
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
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
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Delete Button
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () async {
                            // ✅ close dialog first
                            Navigator.of(context).pop();

                            final success =
                                await ref
                                    .read(aboutMeNotifierProvider.notifier)
                                    .deleteProductAction();

                            if (!mounted) return;

                            if (success) {
                              final prefs =
                                  await SharedPreferences.getInstance();
                              await prefs.clear();

                              if (!mounted) return;

                              // ✅ navigate to login and clear stack
                              context.goNamed(AppRoutes.login);
                              // or: context.go(AppRoutes.loginPath);
                            } else {
                              final error =
                                  ref.read(aboutMeNotifierProvider).error;

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    error ?? 'Account deletion failed',
                                  ),
                                ),
                              );
                            }
                          },

                          // onPressed: () async {
                          //   // Navigator.of(context).pop();
                          //
                          //   final success =
                          //       await ref
                          //           .read(aboutMeNotifierProvider.notifier)
                          //           .deleteProductAction();
                          //
                          //   if (!mounted) return;
                          //
                          //   if (success) {
                          //     final prefs =
                          //         await SharedPreferences.getInstance();
                          //     await prefs.clear();
                          //
                          //     // context.goNamed(AppRoutes.login);
                          //     context.go(AppRoutes.loginPath);
                          //
                          //     ScaffoldMessenger.of(context).showSnackBar(
                          //       const SnackBar(
                          //         content: Text('Account deleted successfully'),
                          //       ),
                          //     );
                          //   } else {
                          //     final error =
                          //         ref.read(aboutMeNotifierProvider).error;
                          //
                          //     ScaffoldMessenger.of(context).showSnackBar(
                          //       SnackBar(
                          //         content: Text(
                          //           error ?? 'Account deletion failed',
                          //         ),
                          //       ),
                          //     );
                          //   }
                          // },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade600,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
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
          ),
        );
      },
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
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
    final state = ref.watch(heaterHomeNotifier);
    final VendorDashboardResponse? response = state.vendorDashboardResponse;
    final VendorDashboardData? dashboard = response?.data;

    final header = dashboard?.header;
    final planCards = dashboard?.planCards;
    final todayTotalCount = dashboard?.todayTotalCount;
    final todayActivity = dashboard?.todayActivity;
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
                                  header?.displayName ?? '-',
                                  style: AppTextStyles.mulish(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 24,
                                    color: AppColor.white,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  header?.vendorCode ?? '',
                                  style: AppTextStyles.mulish(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                    color: AppColor.white,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '${header?.employeesCount ?? 0} Employees',
                                  style: AppTextStyles.mulish(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                    color: AppColor.white,
                                  ),
                                ),
                              ],
                            ),
                            Spacer(),
                            SizedBox(
                              height: 103,
                              width: 103,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                clipBehavior: Clip.hardEdge, // 👈 important
                                child:
                                    (header != null &&
                                            header!.avatarUrl != null &&
                                            header!.avatarUrl!.isNotEmpty)
                                        ? Image.network(
                                          header!.avatarUrl!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) {
                                            return const Center(
                                              child: Icon(
                                                Icons.person,
                                                size: 40,
                                                color: Colors.white,
                                              ),
                                            );
                                          },
                                        )
                                        : Image.asset(
                                          AppImages.profileImage,
                                          fit: BoxFit.cover,
                                        ),
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
                  onTap: _handleDeleteAccount,
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
