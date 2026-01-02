import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tringo_vendor_new/Core/Const/app_logger.dart';
import 'package:tringo_vendor_new/Core/Offline_Data/provider/offline_providers.dart';
import 'package:tringo_vendor_new/Core/Utility/app_prefs.dart';
import 'package:tringo_vendor_new/Core/Utility/call_helper.dart';
import 'package:tringo_vendor_new/Core/Widgets/common_container.dart';

import '../../Utility/app_snackbar.dart';
import '../../../Presentation/Owner Screen/Screens/owner_info_screens.dart';
import '../../../Presentation/Register Screen/Screen/register_screen.dart';
import '../../Const/app_color.dart';
import '../../Const/app_images.dart';
import '../../Utility/app_textstyles.dart';
import '../offline_sync_models.dart';
import 'demo_shop_details.dart';
import 'offline_demo_preview.dart';

class OfflineDemoScreen extends ConsumerStatefulWidget {
  const OfflineDemoScreen({super.key});

  @override
  ConsumerState<OfflineDemoScreen> createState() => _OfflineDemoScreenState();
}

class _OfflineDemoScreenState extends ConsumerState<OfflineDemoScreen> {
  bool _loading = true;

  List<String> _sessionIds = [];

  // per-session state
  final Map<String, bool> _pushing = {};
  final Map<String, bool> _uploaded = {};

  // ✅ NEW: per-session upload percentage 0..100
  final Map<String, double> _progress = {};

  // cached payloads per session
  final Map<String, Map<String, dynamic>?> _shopPayload = {};
  final Map<String, Map<String, dynamic>?> _ownerPayload = {};
  final Map<String, Map<String, dynamic>?> _photosPayload = {};

  String _uploadedKey(String sessionId) => "offline_uploaded_$sessionId";

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    setState(() => _loading = true);

    final db = ref.read(offlineSyncDbProvider);
    final prefs = await SharedPreferences.getInstance();

    final ids = await db.getAllSessionIds();
    _sessionIds = ids;

    _pushing.clear();
    _uploaded.clear();
    _progress.clear();

    _shopPayload.clear();
    _ownerPayload.clear();
    _photosPayload.clear();

    for (final sid in _sessionIds) {
      _pushing[sid] = false;
      _uploaded[sid] = prefs.getBool(_uploadedKey(sid)) ?? false;

      // ✅ if already uploaded -> show 100%
      _progress[sid] = (_uploaded[sid] == true) ? 100 : 0;

      _shopPayload[sid] = await db.getPayload(sid, SyncStepType.shop);
      _ownerPayload[sid] = await db.getPayload(sid, SyncStepType.owner);
      _photosPayload[sid] = await db.getPayload(sid, SyncStepType.photos);
    }

    if (!mounted) return;
    setState(() => _loading = false);
  }

  Future<void> _setUploadedFlag(String sessionId, bool v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_uploadedKey(sessionId), v);
    if (!mounted) return;
    setState(() {
      _uploaded[sessionId] = v;
      if (v) _progress[sessionId] = 100;
    });
  }

  String _shopAddress(Map<String, dynamic>? shop) {
    final en = (shop?["addressEn"] ?? "").toString().trim();
    if (en.isNotEmpty) return en;

    final ta = (shop?["addressTa"] ?? "").toString().trim();
    if (ta.isNotEmpty) return ta;

    return "-";
  }

  String? _firstShopPhotoPath(Map<String, dynamic>? photosPayload) {
    final items = ((photosPayload?["items"] as List?) ?? []);
    for (final e in items) {
      if (e is Map) {
        final p = (e["localPath"] ?? "").toString().trim();
        if (p.isNotEmpty) return p;
      }
    }
    return null;
  }

  Widget _shopThumb(String? path) {
    if (path == null || path.trim().isEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 85,
          height: 85,
          color: AppColor.white,
          alignment: Alignment.center,
          child: Icon(Icons.storefront, color: AppColor.lightGray3),
        ),
      );
    }

    final f = File(path);
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.file(
        f,
        width: 85,
        height: 85,
        fit: BoxFit.cover,
        errorBuilder:
            (_, __, ___) => Container(
              width: 85,
              height: 85,
              color: AppColor.white,
              alignment: Alignment.center,
              child: const Icon(Icons.broken_image),
            ),
      ),
    );
  }

  String _statusText(String sid) {
    if (_uploaded[sid] == true) return "Uploaded Successfully";

    if (_pushing[sid] == true) {
      final p = (_progress[sid] ?? 0).round().clamp(0, 99);
      return "$p% Uploading";
    }

    return "Waiting to Upload";
  }

  bool _uploadDisabled(String sid) =>
      (_uploaded[sid] == true) || (_pushing[sid] == true);

  Widget _breadcrumbText(String text) {
    return Text(
      text,
      style: AppTextStyles.mulish(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: AppColor.darkBlue,
      ),
    );
  }

  Future<void> _syncSession(String sid) async {
    AppPrefs.clearVerificationToken();
    if (_uploadDisabled(sid)) return;

    setState(() {
      _pushing[sid] = true;
      _progress[sid] = 1; // start
    });

    final engine = ref.read(offlineSyncEngineProvider);

    final err = await engine.syncSessionResumeWithProgress(
      sid,
      onProgress: (percent) {
        if (!mounted) return;
        setState(() => _progress[sid] = percent);
      },
    );

    if (!mounted) return;
    setState(() => _pushing[sid] = false);

    if (err == null) {
      AppSnackBar.success(context, "Offline data synced successfully!");
      await _setUploadedFlag(sid, true);
      await _loadSessions();
      return;
    }

    AppSnackBar.error(context, err);

    if (err.contains("Phone verification token is required")) {
      final verified = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder:
              (_) => OwnerInfoScreens(
                isService: true,
                isIndividual: true,
                fromOffline: true,
                offlineSessionId: sid,
              ),
        ),
      );

      if (verified == true && mounted) {
        setState(() {
          _pushing[sid] = true;
          _progress[sid] = 1;
        });

        final err2 = await engine.syncSessionResumeWithProgress(
          sid,
          onProgress: (percent) {
            if (!mounted) return;
            setState(() => _progress[sid] = percent);
          },
        );

        if (!mounted) return;
        setState(() => _pushing[sid] = false);

        if (err2 == null) {
          AppSnackBar.success(context, "Offline data synced successfully!");
          await _setUploadedFlag(sid, true);
          await _loadSessions();
        } else {
          AppSnackBar.error(context, err2);
        }
      }
    }
  }

  Widget _breadcrumbArrow() {
    return Image.asset(
      AppImages.rightArrow,
      height: 10,
      color: AppColor.darkGrey,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Offline Pages for Demo',
                  style: AppTextStyles.mulish(
                    fontWeight: FontWeight.w700,
                    fontSize: 25,
                    color: AppColor.darkBlue,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'If you need more offline demo here ask to admin',
                  style: AppTextStyles.mulish(
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: AppColor.lightGray3,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    color: AppColor.iceGray,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
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
                            child: Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 6,
                              runSpacing: 6,
                              children: [
                                _breadcrumbText('product'),
                                _breadcrumbArrow(),
                                _breadcrumbText('textiles'),
                                _breadcrumbArrow(),
                                _breadcrumbText('Mens Wear'),
                              ],
                            ),
                          ),
                        ),
                        // Text(
                        //   /*item.breadcrumb.isNotEmpty
                        //       ? item.breadcrumb
                        //       :*/
                        //   "${item.categoryLabel} > ${item.subCategoryLabel}",
                        //   style: AppTextStyles.mulish(
                        //     fontSize: 12,
                        //     fontWeight: FontWeight.bold,
                        //     color: AppColor.darkBlue,
                        //   ),
                        // ),
                        const SizedBox(height: 12),

                        //  Cached image with error icon
                        ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: SizedBox(
                            height: 143,
                            width: double.infinity,
                            child: Container(
                              color: Colors.black.withOpacity(0.05),
                              alignment: Alignment.center,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [Image.asset(AppImages.homeImage1)],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),
                        Text(
                          'Kandhasamy Mobiles',
                          style: AppTextStyles.mulish(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: AppColor.darkBlue,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '77, Nehru St, Sathyamoorthy Nagar, State Bank Supervisors Colony, Madurai, Tamil Nadu 625016',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.mulish(
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                            color: AppColor.lightGray3,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 11,
                              ),
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.12),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                                color: AppColor.white,
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: Image.asset(
                                AppImages.premiumImage,
                                height: 17,
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: DottedBorder(
                                borderType: BorderType.RRect,
                                radius: const Radius.circular(24),
                                dashPattern: const [4, 2],
                                strokeWidth: 1.2,
                                color: AppColor.darkGrey.withOpacity(0.2),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 12,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '2Months Pro Premium',
                                        style: AppTextStyles.mulish(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 12,
                                          color: AppColor.darkBlue,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),

                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => DemoShopDetails(),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 15,
                                  vertical: 8,
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
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    color: AppColor.iceGray,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
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
                            child: Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 6,
                              runSpacing: 6,
                              children: [
                                _breadcrumbText('product'),
                                _breadcrumbArrow(),
                                _breadcrumbText('Daily'),
                                _breadcrumbArrow(),
                                _breadcrumbText('Mens Wear'),
                              ],
                            ),
                          ),
                        ),
                        // Text(
                        //   /*item.breadcrumb.isNotEmpty
                        //       ? item.breadcrumb
                        //       :*/
                        //   "${item.categoryLabel} > ${item.subCategoryLabel}",
                        //   style: AppTextStyles.mulish(
                        //     fontSize: 12,
                        //     fontWeight: FontWeight.bold,
                        //     color: AppColor.darkBlue,
                        //   ),
                        // ),
                        const SizedBox(height: 12),

                        //  Cached image with error icon
                        ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: SizedBox(
                            height: 143,
                            width: double.infinity,
                            child: Container(
                              color: Colors.black.withOpacity(0.05),
                              alignment: Alignment.center,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [Image.asset(AppImages.homeImage2)],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),
                        Text(
                          'Kandhasamy Mobiles',
                          style: AppTextStyles.mulish(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: AppColor.darkBlue,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '77, Nehru St, Sathyamoorthy Nagar, State Bank Supervisors Colony, Madurai, Tamil Nadu 625016',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.mulish(
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                            color: AppColor.lightGray3,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: DottedBorder(
                                borderType: BorderType.RRect,
                                radius: const Radius.circular(24),
                                dashPattern: const [4, 2],
                                strokeWidth: 1.2,
                                color: AppColor.darkGrey.withOpacity(0.2),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 12,
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        'FREEMIUM',
                                        style: AppTextStyles.mulish(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 12,
                                          color: AppColor.darkBlue,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),

                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => DemoShopDetails(),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 15,
                                  vertical: 8,
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
                SizedBox(height: 20),
                CommonContainer.button2(
                  backgroundColor: AppColor.black,
                  width: double.infinity,
                  image: AppImages.rightStickArrow,
                  onTap: () async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => RegisterScreen()),
                    );
                  },
                  text: 'Create New Shop',
                ),

                const SizedBox(height: 60),
                if (_sessionIds.isNotEmpty) ...[
                  Text(
                    'Need Attention',
                    style: AppTextStyles.mulish(
                      fontWeight: FontWeight.w700,
                      fontSize: 25,
                      color: AppColor.darkBlue,
                    ),
                  ),
                  const SizedBox(height: 14),

                  _loading
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.separated(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: _sessionIds.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 14),
                        itemBuilder: (_, i) {
                          final sid = _sessionIds[i];

                          final shop = _shopPayload[sid];
                          final owner = _ownerPayload[sid];
                          final photos = _photosPayload[sid];

                          final shopName =
                              (shop?["englishName"] ?? "-").toString();
                          final shopType =
                              (shop?["type"] ?? "Product").toString();
                          final address = _shopAddress(shop);

                          final ownerPhone =
                              (owner?["ownerPhoneNumber"] ?? "").toString();
                          final thumbPath = _firstShopPhotoPath(photos);

                          return GestureDetector(
                            onTap: () {
                              AppLogger.log.i(sid);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => OfflineShopPreviewScreen(
                                        sessionId: sid,
                                      ),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColor.iceGray,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // top breadcrumb
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
                                        child: Wrap(
                                          children: [
                                            _breadcrumbText(
                                              shopType.isEmpty
                                                  ? "Product"
                                                  : shopType,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 14),

                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _shopThumb(thumbPath),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                              top: 10,
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  shopName,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: AppTextStyles.mulish(
                                                    fontWeight: FontWeight.w800,
                                                    fontSize: 18,
                                                    color: AppColor.darkBlue,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  address,
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: AppTextStyles.mulish(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 12.5,
                                                    color: AppColor.lightGray3,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 16),

                                    Row(
                                      children: [
                                        Expanded(
                                          child: DottedBorder(
                                            borderType: BorderType.RRect,
                                            radius: const Radius.circular(24),
                                            dashPattern: const [4, 2],
                                            strokeWidth: 1.2,
                                            color: AppColor.darkGrey
                                                .withOpacity(0.2),
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 14,
                                                    vertical: 12,
                                                  ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  if (_pushing[sid] ==
                                                      true) ...[
                                                    const SizedBox(
                                                      height: 14,
                                                      width: 14,
                                                      child:
                                                          CircularProgressIndicator(
                                                            strokeWidth: 2,
                                                            color:
                                                                AppColor
                                                                    .darkBlue,
                                                          ),
                                                    ),
                                                    const SizedBox(width: 10),
                                                  ],
                                                  Text(
                                                    _statusText(sid),
                                                    style: AppTextStyles.mulish(
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      fontSize: 12,
                                                      color: AppColor.darkBlue,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),

                                        // upload button
                                        GestureDetector(
                                          onTap:
                                              _uploadDisabled(sid)
                                                  ? null
                                                  : () => _syncSession(sid),
                                          child: Opacity(
                                            opacity:
                                                _uploadDisabled(sid) ? 0.4 : 1,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 20,
                                                    vertical: 12,
                                                  ),
                                              decoration: BoxDecoration(
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.12),
                                                    blurRadius: 12,
                                                    offset: const Offset(0, 6),
                                                  ),
                                                ],
                                                color: AppColor.white,
                                                borderRadius:
                                                    BorderRadius.circular(25),
                                              ),
                                              child: Image.asset(
                                                AppImages.downloadImage01,
                                                height: 17,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),

                                        // call button
                                        GestureDetector(
                                          onTap:
                                              ownerPhone.trim().isEmpty
                                                  ? null
                                                  : () => CallHelper.openDialer(
                                                    context: context,
                                                    rawPhone: ownerPhone,
                                                  ),
                                          child: Opacity(
                                            opacity:
                                                ownerPhone.trim().isEmpty
                                                    ? 0.4
                                                    : 1,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 20,
                                                    vertical: 12,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: AppColor.black,
                                                borderRadius:
                                                    BorderRadius.circular(25),
                                              ),
                                              child: const Icon(
                                                Icons.call,
                                                color: Colors.white,
                                                size: 15,
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
                          );
                        },
                      ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// import 'dart:io';
//
// import 'package:dotted_border/dotted_border.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:tringo_vendor_new/Core/Offline_Data/provider/offline_providers.dart';
// import 'package:tringo_vendor_new/Core/Utility/app_prefs.dart';
// import 'package:tringo_vendor_new/Core/Utility/call_helper.dart';
// import 'package:tringo_vendor_new/Core/Widgets/common_container.dart';
//
// import '../../Core/Utility/app_snackbar.dart';
// import '../../Presentation/Owner Screen/Screens/owner_info_screens.dart';
//
// import '../Const/app_color.dart';
// import '../Const/app_images.dart';
// import '../Utility/app_textstyles.dart';
// import 'offline_sync_models.dart';
//
// class OfflineDemoScreen extends ConsumerStatefulWidget {
//   final String sessionId;
//   const OfflineDemoScreen({super.key, required this.sessionId});
//
//   @override
//   ConsumerState<OfflineDemoScreen> createState() => _OfflineDemoScreenState();
// }
//
// class _OfflineDemoScreenState extends ConsumerState<OfflineDemoScreen> {
//   bool _loading = true;
//   bool _pushing = false;
//
//   /// ✅ after successful upload -> true -> disable upload button
//   bool _uploaded = false;
//
//   Map<String, dynamic>? _ownerPayload;
//   Map<String, dynamic>? _shopPayload;
//
//   Map<String, dynamic>? _photosPayload;
//   Map<String, dynamic>? _productImagesPayload;
//   Map<String, dynamic>? _serviceImagesPayload;
//
//   Map<String, dynamic>? _productKeywordsPayload;
//   Map<String, dynamic>? _serviceKeywordsPayload;
//
//   String get _uploadedKey => "offline_uploaded_${widget.sessionId}";
//
//   @override
//   void initState() {
//     super.initState();
//     _init();
//   }
//
//   Future<void> _init() async {
//     await _loadUploadedFlag();
//     await _loadAll();
//   }
//
//   Future<void> _loadUploadedFlag() async {
//     final prefs = await SharedPreferences.getInstance();
//     final v = prefs.getBool(_uploadedKey) ?? false;
//     if (!mounted) return;
//     setState(() => _uploaded = v);
//   }
//
//   Future<void> _setUploadedFlag(bool v) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setBool(_uploadedKey, v);
//     if (!mounted) return;
//     setState(() => _uploaded = v);
//   }
//
//   Future<void> _loadAll() async {
//     final db = ref.read(offlineSyncDbProvider);
//
//     final owner = await db.getPayload(widget.sessionId, SyncStepType.owner);
//     final shop = await db.getPayload(widget.sessionId, SyncStepType.shop);
//
//     final photos = await db.getPayload(widget.sessionId, SyncStepType.photos);
//
//     final productImages = await db.getPayload(
//       widget.sessionId,
//       SyncStepType.productImages,
//     );
//     final serviceImages = await db.getPayload(
//       widget.sessionId,
//       SyncStepType.serviceImages,
//     );
//
//     final productKeywords = await db.getPayload(
//       widget.sessionId,
//       SyncStepType.productKeywords,
//     );
//     final serviceKeywords = await db.getPayload(
//       widget.sessionId,
//       SyncStepType.serviceKeywords,
//     );
//
//     if (!mounted) return;
//     setState(() {
//       _ownerPayload = owner;
//       _shopPayload = shop;
//
//       _photosPayload = photos;
//       _productImagesPayload = productImages;
//       _serviceImagesPayload = serviceImages;
//
//       _productKeywordsPayload = productKeywords;
//       _serviceKeywordsPayload = serviceKeywords;
//
//       _loading = false;
//     });
//   }
//
//   double get progress {
//     int total = 0;
//     int has = 0;
//
//     void add(bool ok) {
//       total++;
//       if (ok) has++;
//     }
//
//     add(_ownerPayload != null);
//     add(_shopPayload != null);
//     add(_photosPayload != null);
//     add(_productImagesPayload != null);
//     add(_productKeywordsPayload != null);
//     add(_serviceImagesPayload != null);
//     add(_serviceKeywordsPayload != null);
//
//     if (total == 0) return 0.0;
//     return has / total;
//   }
//
//   /// ✅ Shop address from offline payload
//   String _shopAddress() {
//     final en = (_shopPayload?["addressEn"] ?? "").toString().trim();
//     if (en.isNotEmpty) return en;
//
//     final ta = (_shopPayload?["addressTa"] ?? "").toString().trim();
//     if (ta.isNotEmpty) return ta;
//
//     final area = (_shopPayload?["area"] ?? "").toString().trim();
//     final city = (_shopPayload?["city"] ?? "").toString().trim();
//     final state = (_shopPayload?["state"] ?? "").toString().trim();
//
//     final parts = [area, city, state].where((e) => e.isNotEmpty).toList();
//     return parts.isEmpty ? "-" : parts.join(", ");
//   }
//
//   /// ✅ Fix: breadcrumb text should display the passed value
//   Widget _breadcrumbText(String text) {
//     return Text(
//       text,
//       style: AppTextStyles.mulish(
//         fontSize: 12,
//         fontWeight: FontWeight.bold,
//         color: AppColor.darkBlue,
//       ),
//     );
//   }
//
//   Widget _breadcrumbArrow() {
//     return Image.asset(
//       AppImages.rightArrow,
//       height: 10,
//       color: AppColor.darkGrey,
//     );
//   }
//
//   /// ✅ For card thumbnail: take first shop photo only
//   String? _firstShopPhotoPath() {
//     final items = ((_photosPayload?["items"] as List?) ?? []);
//     for (final e in items) {
//       if (e is Map) {
//         final p = (e["localPath"] ?? "").toString().trim();
//         if (p.isNotEmpty) return p;
//       }
//     }
//     return null;
//   }
//
//   Widget _shopThumb(String? path) {
//     if (path == null || path.trim().isEmpty) {
//       return ClipRRect(
//         borderRadius: BorderRadius.circular(16),
//         child: Container(
//           width: 85,
//           height: 85,
//           color: AppColor.white,
//           alignment: Alignment.center,
//           child: Icon(Icons.storefront, color: AppColor.lightGray3),
//         ),
//       );
//     }
//
//     final f = File(path);
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(16),
//       child: Image.file(
//         f,
//         width: 85,
//         height: 85,
//         fit: BoxFit.cover,
//         errorBuilder:
//             (_, __, ___) => Container(
//               width: 85,
//               height: 85,
//               color: AppColor.white,
//               alignment: Alignment.center,
//               child: const Icon(Icons.broken_image),
//             ),
//       ),
//     );
//   }
//
//   /// ✅ UI label for status pill
//   String get _statusText {
//     if (_uploaded) return "Uploaded Successfully";
//     if (_pushing) return "10% Uploading";
//     return "Waiting to Upload";
//   }
//
//   /// ✅ Disable upload when pushing or already uploaded
//   bool get _uploadDisabled => _pushing || _uploaded;
//
//   Future<void> _syncAllResume() async {
//     AppPrefs.clearVerificationToken();
//
//     if (_uploadDisabled) return;
//
//     setState(() => _pushing = true);
//
//     final engine = ref.read(offlineSyncEngineProvider);
//     final err = await engine.syncSessionResume(widget.sessionId);
//
//     if (!mounted) return;
//     setState(() => _pushing = false);
//
//     if (err == null) {
//       AppSnackBar.success(context, "Offline data synced successfully!");
//       await _setUploadedFlag(true); // ✅ mark uploaded & disable button
//       await _loadAll();
//       return;
//     }
//
//     AppSnackBar.error(context, err);
//
//     if (err.contains("Phone verification token is required")) {
//       final verified = await Navigator.push<bool>(
//         context,
//         MaterialPageRoute(
//           builder:
//               (_) => OwnerInfoScreens(
//                 isService: true,
//                 isIndividual: true,
//                 fromOffline: true,
//                 offlineSessionId: widget.sessionId,
//               ),
//         ),
//       );
//
//       if (verified == true && mounted) {
//         setState(() => _pushing = true);
//         final err2 = await engine.syncSessionResume(widget.sessionId);
//         if (!mounted) return;
//         setState(() => _pushing = false);
//
//         if (err2 == null) {
//           AppSnackBar.success(context, "Offline data synced successfully!");
//           await _setUploadedFlag(true); // ✅ mark uploaded & disable button
//           await _loadAll();
//         } else {
//           AppSnackBar.error(context, err2);
//         }
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final ownerName =
//         (_ownerPayload?["fullName"] ??
//                 _ownerPayload?["govtRegisteredName"] ??
//                 "")
//             .toString();
//     final ownerPhone = (_ownerPayload?["ownerPhoneNumber"] ?? "").toString();
//     final shopName = (_shopPayload?["englishName"] ?? "").toString();
//     final shopType = (_shopPayload?["type"] ?? "Product").toString();
//     final category = (_shopPayload?["category"] ?? "").toString();
//     final subCategory = (_shopPayload?["subCategory"] ?? "").toString();
//
//     final thumbPath = _firstShopPhotoPath();
//
//     return Scaffold(
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Offline Pages for Demo',
//                 style: AppTextStyles.mulish(
//                   fontWeight: FontWeight.w700,
//                   fontSize: 25,
//                   color: AppColor.darkBlue,
//                 ),
//               ),
//               SizedBox(height: 5,),
//               Text('If you need more offline demo here ask to admin',       style: AppTextStyles.mulish(
//                 fontWeight: FontWeight.w400,
//                 fontSize: 14,
//                 color: AppColor.lightGray3,
//               ),),
//               SizedBox(height: 20),
//               CommonContainer.button2(backgroundColor: AppColor.black,
//                 width: double.infinity,
//                  image : AppImages.rightStickArrow,
//
//                 onTap: () {},
//                 text: 'Create New Shop',
//               ),
//               SizedBox(height: 20),
//
//               _loading
//                   ? const Center(child: CircularProgressIndicator())
//                   : Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Need Attention',
//                         style: AppTextStyles.mulish(
//                           fontWeight: FontWeight.w700,
//                           fontSize: 25,
//                           color: AppColor.darkBlue,
//                         ),
//                       ),
//                       const SizedBox(height: 20),
//
//                       // ✅ CARD
//                       Container(
//                         decoration: BoxDecoration(
//                           color: AppColor.iceGray,
//                           borderRadius: BorderRadius.circular(18),
//                         ),
//                         child: Padding(
//                           padding: const EdgeInsets.all(16),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               // breadcrumb bar
//                               Container(
//                                 decoration: BoxDecoration(
//                                   gradient: LinearGradient(
//                                     colors: [
//                                       AppColor.black.withOpacity(0.054),
//                                       AppColor.black.withOpacity(0.0),
//                                     ],
//                                     begin: Alignment.centerLeft,
//                                     end: Alignment.centerRight,
//                                   ),
//                                   borderRadius: BorderRadius.circular(16),
//                                 ),
//                                 child: Padding(
//                                   padding: const EdgeInsets.symmetric(
//                                     horizontal: 15,
//                                     vertical: 10,
//                                   ),
//                                   child: Wrap(
//                                     crossAxisAlignment:
//                                         WrapCrossAlignment.center,
//                                     spacing: 6,
//                                     runSpacing: 6,
//                                     children: [
//                                       _breadcrumbText(
//                                         shopType.isEmpty ? "Product" : shopType,
//                                       ),
//                                       // _breadcrumbArrow(),
//                                       // _breadcrumbText(
//                                       //   category.isEmpty ? "-" : category,
//                                       // ),
//                                       // if (subCategory.trim().isNotEmpty) ...[
//                                       //   _breadcrumbArrow(),
//                                       //   _breadcrumbText(subCategory),
//                                       // ],
//                                     ],
//                                   ),
//                                 ),
//                               ),
//
//                               const SizedBox(height: 14),
//
//                               // ✅ Row: image + details
//                               Row(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   _shopThumb(thumbPath),
//                                   const SizedBox(width: 14),
//                                   Expanded(
//                                     child: Padding(
//                                       padding: const EdgeInsets.only(top: 10),
//                                       child: Column(
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.start,
//                                         children: [
//                                           Text(
//                                             shopName.isEmpty ? "-" : shopName,
//                                             maxLines: 1,
//                                             overflow: TextOverflow.ellipsis,
//                                             style: AppTextStyles.mulish(
//                                               fontWeight: FontWeight.w800,
//                                               fontSize: 18,
//                                               color: AppColor.darkBlue,
//                                             ),
//                                           ),
//                                           const SizedBox(height: 8),
//                                           Text(
//                                             _shopAddress(),
//                                             maxLines: 2,
//                                             overflow: TextOverflow.ellipsis,
//                                             style: AppTextStyles.mulish(
//                                               fontWeight: FontWeight.w500,
//                                               fontSize: 12.5,
//                                               color: AppColor.lightGray3,
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//
//                               const SizedBox(height: 16),
//
//                               // ✅ bottom row: status + action buttons
//                               Row(
//                                 children: [
//                                   Expanded(
//                                     child: DottedBorder(
//                                       borderType: BorderType.RRect,
//                                       radius: const Radius.circular(24),
//                                       dashPattern: const [
//                                         4,
//                                         2,
//                                       ], // 👈 dot length & gap
//                                       strokeWidth: 1.2,
//                                       color: AppColor.darkGrey.withOpacity(0.2),
//                                       child: Container(
//                                         padding: const EdgeInsets.symmetric(
//                                           horizontal: 14,
//                                           vertical: 12,
//                                         ),
//                                         child: Row(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.center,
//                                           children: [
//                                             if (_pushing) ...[
//                                               const SizedBox(
//                                                 height: 14,
//                                                 width: 14,
//                                                 child:
//                                                     CircularProgressIndicator(
//                                                       strokeWidth: 2,
//                                                       color: AppColor.darkBlue,
//                                                     ),
//                                               ),
//                                               const SizedBox(width: 10),
//                                             ],
//                                             Text(
//                                               _statusText,
//                                               style: AppTextStyles.mulish(
//                                                 fontWeight: FontWeight.w800,
//                                                 fontSize: 12,
//                                                 color: AppColor.darkBlue,
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                   const SizedBox(width: 12),
//
//                                   // ✅ upload button (disabled after success)
//                                   GestureDetector(
//                                     onTap:
//                                         _uploadDisabled ? null : _syncAllResume,
//                                     child: Opacity(
//                                       opacity: _uploadDisabled ? 0.4 : 1,
//                                       child: Container(
//                                         padding: EdgeInsets.symmetric(
//                                           horizontal: 20,
//                                           vertical: 12,
//                                         ),
//                                         decoration: BoxDecoration(
//                                           boxShadow: [
//                                             BoxShadow(
//                                               color: Colors.black.withOpacity(
//                                                 0.12,
//                                               ), // shadow color
//                                               blurRadius: 12, // softness
//                                               spreadRadius: 0, // no spread
//                                               offset: const Offset(
//                                                 0,
//                                                 6,
//                                               ), // vertical shadow
//                                             ),
//                                           ],
//
//                                           color: AppColor.white,
//                                           borderRadius: BorderRadius.circular(
//                                             25,
//                                           ),
//                                         ),
//                                         child: Image.asset(
//                                           AppImages.downloadImage01,
//                                           height: 17,
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//
//                                   const SizedBox(width: 12),
//
//                                   // call button
//                                   GestureDetector(
//                                     onTap: () {
//                                       CallHelper.openDialer(
//                                         context: context,
//                                         rawPhone: ownerPhone,
//                                       );
//                                     },
//                                     child: Container(
//                                       padding: EdgeInsets.symmetric(
//                                         horizontal: 20,
//                                         vertical: 12,
//                                       ),
//                                       decoration: BoxDecoration(
//                                         color: AppColor.black,
//                                         borderRadius: BorderRadius.circular(25),
//                                       ),
//                                       child: const Icon(
//                                         Icons.call,
//                                         color: Colors.white,
//                                         size: 15,
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//
//                       const SizedBox(height: 18),
//                       // Text(
//                       //   "Saved offline: ${(progress * 100).round()}%",
//                       //   style: AppTextStyles.mulish(
//                       //     fontWeight: FontWeight.w700,
//                       //     fontSize: 13,
//                       //     color: AppColor.darkBlue,
//                       //   ),
//                       // ),
//                       // const SizedBox(height: 6),
//                       // Text(
//                       //   ownerName.isEmpty ? "" : "Owner: $ownerName",
//                       //   style: AppTextStyles.mulish(
//                       //     fontWeight: FontWeight.w500,
//                       //     fontSize: 12,
//                       //     color: AppColor.lightGray3,
//                       //   ),
//                       // ),
//                     ],
//                   ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
