import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tringo_vendor_new/Api/DataSource/api_data_source.dart';
import 'package:tringo_vendor_new/Core/Session/session_manager.dart';
import 'package:tringo_vendor_new/Core/Utility/app_prefs.dart';
import 'package:tringo_vendor_new/Core/Widgets/app_go_routes.dart';

import '../../../../Core/Const/app_color.dart';
import '../../../../Core/Const/app_images.dart';
import '../../../../Core/Utility/app_loader.dart';
import '../../../../Core/Utility/app_textstyles.dart';
import '../../../../Core/Widgets/common_container.dart';

class VendorAccessBlockedScreen extends StatefulWidget {
  const VendorAccessBlockedScreen({super.key});

  @override
  State<VendorAccessBlockedScreen> createState() =>
      _VendorAccessBlockedScreenState();
}

class _VendorAccessBlockedScreenState extends State<VendorAccessBlockedScreen> {
  final ApiDataSource _api = ApiDataSource();

  bool _isRefreshing = false;
  String _blockType = 'SUSPENDED';
  String? _message;

  @override
  void initState() {
    super.initState();
    _loadBlockState();
  }

  Future<void> _loadBlockState() async {
    final blockType = await AppPrefs.getVendorAccessBlockType();
    final message = await AppPrefs.getVendorAccessBlockMessage();
    if (!mounted) return;

    setState(() {
      _blockType = (blockType ?? 'SUSPENDED').trim().toUpperCase();
      _message = message;
    });
  }

  Future<void> _refreshStatus() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    try {
      final result = await _api.getProfile();
      await result.fold((_) async {}, (response) async {
        final approvalStatus =
            response.data.approvalStatus.trim().toUpperCase();

        if (approvalStatus == 'ACTIVE') {
          await AppPrefs.clearVendorAccessBlock();
          await AppPrefs.setVendorApproved(true);
          await AppPrefs.setVendorStatus('ACTIVE');
          await AppPrefs.setOnboardingStep('step-7');

          if (!mounted) return;
          context.go(AppRoutes.heaterHomeScreenPath);
        }
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  Future<void> _signOut() async {
    await AppPrefs.clearVendorAccessBlock();
    await SessionManager.forceLogout();
    if (!mounted) return;
    context.go(AppRoutes.loginPath);
  }

  String get _title {
    if (_blockType == 'REJECTED') {
      return 'Approval Rejected';
    }
    return 'Account Suspended';
  }

  String get _description {
    if ((_message ?? '').trim().isNotEmpty) {
      return _message!.trim();
    }

    if (_blockType == 'REJECTED') {
      return 'Your vendor account was not approved. You cannot use vendor features until the admin restores access.';
    }

    return 'Your vendor account has been suspended by the admin. You cannot use vendor features until access is restored.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
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
                        const SizedBox(height: 15),
                        Text(
                          _title,
                          style: AppTextStyles.mulish(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: AppColor.mildBlack,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          _description,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.mulish(
                            fontSize: 13,
                            color: AppColor.gray84,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 36),
                          child: CommonContainer.button(
                            onTap: _isRefreshing ? null : _refreshStatus,
                            buttonColor: AppColor.darkBlue,
                            imagePath: AppImages.rightStickArrow,
                            text: Text(
                              _isRefreshing
                                  ? 'Checking Status...'
                                  : 'Refresh Status',
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: _isRefreshing ? null : _signOut,
                          child: Text(
                            'Sign out',
                            style: AppTextStyles.mulish(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColor.darkBlue,
                            ),
                          ),
                        ),
                        if (_isRefreshing) ...[
                          const SizedBox(height: 8),
                          Center(
                            child: ThreeDotsLoader(dotColor: AppColor.black),
                          ),
                        ],
                        const SizedBox(height: 36),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
