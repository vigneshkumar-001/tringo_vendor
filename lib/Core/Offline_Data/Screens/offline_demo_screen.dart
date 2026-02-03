import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tringo_vendor_new/Core/Const/app_logger.dart';
import 'package:tringo_vendor_new/Core/Const/app_color.dart';
import 'package:tringo_vendor_new/Core/Const/app_images.dart';
import 'package:tringo_vendor_new/Core/Offline_Data/provider/offline_providers.dart';
import 'package:tringo_vendor_new/Core/Utility/app_prefs.dart';
import 'package:tringo_vendor_new/Core/Utility/app_snackbar.dart';
import 'package:tringo_vendor_new/Core/Utility/call_helper.dart';
import 'package:tringo_vendor_new/Core/Widgets/common_container.dart';
import 'package:tringo_vendor_new/Core/Utility/app_textstyles.dart';

import 'package:tringo_vendor_new/Presentation/Register Screen/Screen/register_screen.dart';
import 'package:tringo_vendor_new/Presentation/Owner Screen/Screens/owner_info_screens.dart';
import 'package:tringo_vendor_new/Presentation/ShopInfo/Screens/shop_category_info.dart';

import '../../../Presentation/Home Screen/Contoller/employee_home_notifier.dart';
import '../../../Presentation/Home Screen/Model/employee_home_response.dart';

import '../../Widgets/app_go_routes.dart';
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

  // per-session upload percentage 0..100
  final Map<String, double> _progress = {};

  // cached payloads per session
  final Map<String, Map<String, dynamic>?> _shopPayload = {};
  final Map<String, Map<String, dynamic>?> _ownerPayload = {};
  final Map<String, Map<String, dynamic>?> _photosPayload = {};

  // ✅ API cache
  bool _apiNamesLoading = false;

  /// normalized englishName => BusinessProfile
  final Map<String, BusinessProfile> _apiByName = {};

  /// normalized englishName set (for UI match only)
  Set<String> _apiProductNames = {};

  String _apiDate(DateTime date) => DateFormat('yyyy-MM-dd').format(date);
  String _uploadedKey(String sessionId) => "offline_uploaded_$sessionId";

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  // ==========================================================
  // ✅ NEW: Read owner phone from multiple keys (so updated number is used)
  // ==========================================================
  String _readOwnerPhone(Map<String, dynamic>? owner) {
    final keys = <String>[
      "ownerPhoneNumber",
      "phoneNumber",
      "phone",
      "mobile",
      "mobileNumber",
    ];

    for (final k in keys) {
      final v = (owner?[k] ?? "").toString().trim();
      if (v.isNotEmpty) return v;
    }
    return "";
  }

  // ==========================================================
  // ✅ Sessions load
  // ==========================================================
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
      _progress[sid] = (_uploaded[sid] == true) ? 100 : 0;

      _shopPayload[sid] = await db.getPayload(sid, SyncStepType.shop);
      _ownerPayload[sid] = await db.getPayload(sid, SyncStepType.owner);
      _photosPayload[sid] = await db.getPayload(sid, SyncStepType.photos);
    }

    // ✅ Load API items
    await _loadApiProductNames();

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

  // ==========================================================
  // ✅ UI helpers
  // ==========================================================
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

  Widget _breadcrumbArrow() {
    return Image.asset(
      AppImages.rightArrow,
      height: 10,
      color: AppColor.darkGrey,
    );
  }

  String _normalizeName(String v) {
    return v
        .toLowerCase()
        .replaceAll(RegExp(r'[\u200B-\u200D\uFEFF]'), '')
        .replaceAll(RegExp(r'[^a-z0-9\s]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  String _localProductName(String sid) {
    final shop = _shopPayload[sid];
    return (shop?["englishName"] ?? "").toString().trim();
  }

  bool _isLocalProductMatchedWithApi(String sid) {
    final localRaw = _localProductName(sid);
    if (localRaw.trim().isEmpty) return false;
    final key = _normalizeName(localRaw);
    return _apiByName.containsKey(key);
  }

  BusinessProfile? _getApiProfileByName(String localEnglishName) {
    final key = _normalizeName(localEnglishName);
    return _apiByName[key];
  }

  String? _getApiBusinessProfileIdByName(String localEnglishName) {
    return _getApiProfileByName(localEnglishName)?.businessProfileId;
  }

  String? _getApiShopIdByName(String localEnglishName) {
    return _getApiProfileByName(localEnglishName)?.shopId;
  }

  void _printApiBusinessProfileIdForSession(String sid) {
    final localName = _localProductName(sid);
    final apiItem = _getApiProfileByName(localName);

    AppLogger.log.i("=======================================");
    AppLogger.log.i("SESSION => $sid");
    AppLogger.log.i("LOCAL englishName => [$localName]");
    AppLogger.log.i(
      "API businessProfileId => ${apiItem?.businessProfileId ?? 'NOT FOUND'}",
    );
    AppLogger.log.i("API shopId => ${apiItem?.shopId ?? 'NOT FOUND'}");
    AppLogger.log.i(
      "API englishName => ${apiItem?.englishName ?? 'NOT FOUND'}",
    );
    AppLogger.log.i("=======================================");
  }

  Future<void> _loadApiProductNames() async {
    if (_apiNamesLoading) return;
    if (!mounted) return;

    setState(() => _apiNamesLoading = true);

    try {
      await ref
          .read(employeeHomeNotifier.notifier)
          .employeeHome(date: '', page: '1', limit: '50', q: '');

      final apiRes = ref.read(employeeHomeNotifier).employeeHomeResponse;

      if (apiRes == null) {
        AppLogger.log.e("employeeHomeResponse is null");
        _apiByName.clear();
        _apiProductNames = {};
        return;
      }

      _apiByName.clear();

      final ra = apiRes.data.recentActivity;

      void addGroups(List<ActivityDayGroup> groups) {
        for (final day in groups) {
          for (final item in day.items) {
            final n = item.englishName.trim();
            if (n.isEmpty) continue;

            final key = _normalizeName(n);
            _apiByName.putIfAbsent(key, () => item);
          }
        }
      }

      addGroups(ra.freemium);
      addGroups(ra.premium);
      addGroups(ra.premiumPro);

      _apiProductNames = _apiByName.keys.toSet();
    } catch (e) {
      AppLogger.log.e("Load API product names error => $e");
      _apiByName.clear();
      _apiProductNames = {};
    } finally {
      if (!mounted) return;
      setState(() => _apiNamesLoading = false);
    }
  }

  // ==========================================================
  // ✅ Sync session
  // ==========================================================
  Future<void> _syncSession(String sid) async {
    // ❌ DO NOT clear token here

    if (_uploadDisabled(sid)) return;

    setState(() {
      _pushing[sid] = true;
      _progress[sid] = 1;
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

      // ✅ success ஆன பிறகு clear பண்ணலாம் (optional)
      await AppPrefs.clearIdsForOffline();

      await _setUploadedFlag(sid, true);
      await _loadSessions();
      return;
    }

    // -------------------------
    // ✅ HANDLE VERIFY ERRORS
    // -------------------------
    final e = err.toLowerCase();

    // ✅ 1) Owner verify error -> navigate to Owner screen
    if (e.contains("verify the owner phone") ||
        e.contains("owner phone") && e.contains("otp")) {
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
        await _loadSessions();
        await _syncSession(sid); // ✅ retry
      }
      return;
    }

    // ✅ 2) Shop/Primary phone verify error -> navigate to Shop page
    if (e.contains("please verify") &&
        (e.contains("phone number") ||
            e.contains("primary mobile") ||
            e.contains("primary phone") ||
            e.contains("shop phone") ||
            e.contains("otp"))) {
      final verified = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder:
              (_) => ShopCategoryInfo(
                fromOffline: true,
                offlineSessionId: sid,
                isService: false,
                isIndividual: true,
              ),
        ),
      );

      if (verified == true && mounted) {
        await _loadSessions();
        await _syncSession(sid); // ✅ retry
      }
      return;
    }

    // default error
    AppSnackBar.error(context, err);
  }

  /*Future<void> _syncSession(String sid) async {
    AppPrefs.clearVerificationToken();
    if (_uploadDisabled(sid)) return;

    setState(() {
      _pushing[sid] = true;
      _progress[sid] = 1;
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

    if (err.contains("Please verify the owner phone with OTP first.")) {
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
        // ✅ IMPORTANT: reload sessions to get UPDATED owner phone from DB
        await _loadSessions();

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

      return;
    }
  }*/

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

                // ------------------
                // Your existing UI...
                // ------------------
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
                        const SizedBox(height: 12),
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
                        const SizedBox(height: 12),
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
                          final uploadedOk = _uploaded[sid] == true;

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
                                        if (uploadedOk) ...[
                                          GestureDetector(
                                            onTap: () async {
                                              final internet =
                                                  InternetConnection();
                                              final hasInternet =
                                                  await internet
                                                      .hasInternetAccess;
                                              if (!hasInternet) {
                                                AppSnackBar.error(
                                                  context,
                                                  "No internet connection. Please connect to the internet and try again.",
                                                );
                                                return;
                                              }
                                              // ✅ DO NOT NAVIGATE
                                              // ✅ Just print API businessProfileId + shopId
                                              _printApiBusinessProfileIdForSession(
                                                sid,
                                              );

                                              // Optional: also show toast/snack
                                              final localName =
                                                  _localProductName(sid);
                                              final apiBpId =
                                                  _getApiBusinessProfileIdByName(
                                                    localName,
                                                  );
                                              final apiShopId =
                                                  _getApiShopIdByName(
                                                    localName,
                                                  );
                                              context.push(
                                                AppRoutes.shopDetailsEditPath,
                                                extra: {
                                                  'shopId': apiShopId,
                                                  'businessProfileId': apiBpId,
                                                },
                                              );
                                              // AppSnackBar.success(
                                              //   context,
                                              //   "API businessProfileId: ${apiBpId ?? 'NOT FOUND'}\nAPI shopId: ${apiShopId ?? 'NOT FOUND'}",
                                              // );
                                            },
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 18,
                                                    vertical: 12,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: AppColor.darkBlue,
                                                borderRadius:
                                                    BorderRadius.circular(25),
                                              ),
                                              child: const Icon(
                                                Icons.edit,
                                                color: Colors.white,
                                                size: 16,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                        ] else ...[
                                          // ✅ Upload button
                                          GestureDetector(
                                            onTap: () async {
                                              final internet =
                                                  InternetConnection();
                                              final hasInternet =
                                                  await internet
                                                      .hasInternetAccess;
                                              if (!hasInternet) {
                                                AppSnackBar.error(
                                                  context,
                                                  "No internet connection. Please connect to the internet and try again.",
                                                );
                                                return;
                                              }
                                              _syncSession(sid);
                                            },
                                            child: Opacity(
                                              opacity:
                                                  _uploadDisabled(sid)
                                                      ? 0.4
                                                      : 1,
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
                                                      offset: const Offset(
                                                        0,
                                                        6,
                                                      ),
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
                                        ],
                                        // GestureDetector(
                                        //   onTap: () async {
                                        //     final internet =
                                        //         InternetConnection();
                                        //     final hasInternet =
                                        //         await internet
                                        //             .hasInternetAccess;
                                        //     if (!hasInternet) {
                                        //       AppSnackBar.error(
                                        //         context,
                                        //         "No internet connection. Please connect to the internet and try again.",
                                        //       );
                                        //       return;
                                        //     }
                                        //     _syncSession(sid);
                                        //   },
                                        //   child: Opacity(
                                        //     opacity:
                                        //         _uploadDisabled(sid) ? 0.4 : 1,
                                        //     child: Container(
                                        //       padding:
                                        //           const EdgeInsets.symmetric(
                                        //             horizontal: 20,
                                        //             vertical: 12,
                                        //           ),
                                        //       decoration: BoxDecoration(
                                        //         boxShadow: [
                                        //           BoxShadow(
                                        //             color: Colors.black
                                        //                 .withOpacity(0.12),
                                        //             blurRadius: 12,
                                        //             offset: const Offset(0, 6),
                                        //           ),
                                        //         ],
                                        //         color: AppColor.white,
                                        //         borderRadius:
                                        //             BorderRadius.circular(25),
                                        //       ),
                                        //       child: Image.asset(
                                        //         AppImages.downloadImage01,
                                        //         height: 17,
                                        //       ),
                                        //     ),
                                        //   ),
                                        // ),
                                        const SizedBox(width: 12),
                                        GestureDetector(
                                          // onTap: () async {await AppPrefs.clearIdsForOffline();},
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
