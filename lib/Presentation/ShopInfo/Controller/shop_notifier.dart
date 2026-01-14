import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tringo_vendor_new/Core/Const/app_logger.dart';

import 'package:tringo_vendor_new/Presentation/Owner%20Screen/Model/owner_register_response.dart';
import 'package:tringo_vendor_new/Presentation/ShopInfo/Model/category_list_response.dart';
import '../../../Api/DataSource/api_data_source.dart';
import '../../../Core/Offline_Data/offline_helpers.dart';
import '../../../Core/Offline_Data/provider/offline_providers.dart';
import '../../../Core/Utility/app_prefs.dart';
import '../../Owner Screen/Model/owner_otp_response.dart';
import '../Model/search_keywords_response.dart';
import '../Model/shop_info_photos_response.dart';
import '../Model/shop_number_otp_response.dart';
import '../Model/shop_number_verify_response.dart';

class ShopCategoryState {
  final bool isLoading;
  final String? imageUrl;
  final bool isSendingOtp;
  final bool isVerifyingOtp;
  final String? error;
  final OwnerRegisterResponse? ownerRegisterResponse;
  final CategoryListResponse? categoryListResponse;
  final ShopInfoPhotosResponse? shopInfoPhotosResponse;
  final ShopCategoryApiResponse? shopCategoryApiResponse;
  final ShopNumberVerifyResponse? shopNumberVerifyResponse;
  final ShopNumberOtpResponse? shopNumberOtpResponse;

  const ShopCategoryState({
    this.isLoading = false,
    this.isSendingOtp = false,
    this.isVerifyingOtp = false,
    this.error,
    this.ownerRegisterResponse,
    this.imageUrl,
    this.categoryListResponse,
    this.shopInfoPhotosResponse,
    this.shopCategoryApiResponse,
    this.shopNumberVerifyResponse,
    this.shopNumberOtpResponse,
  });

  factory ShopCategoryState.initial() => const ShopCategoryState();
  ShopCategoryState copyWith({
    bool? isLoading,
    bool? isSendingOtp,
    bool? isVerifyingOtp,
    bool clearError = false,
    String? error,
    OwnerRegisterResponse? ownerRegisterResponse,
    CategoryListResponse? categoryListResponse,
    ShopInfoPhotosResponse? shopInfoPhotosResponse,
    ShopCategoryApiResponse? shopCategoryApiResponse,
    ShopNumberVerifyResponse? shopNumberVerifyResponse,
    ShopNumberOtpResponse? shopNumberOtpResponse,
  }) {
    return ShopCategoryState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      isSendingOtp: isSendingOtp ?? this.isSendingOtp,
      isVerifyingOtp: isVerifyingOtp ?? this.isVerifyingOtp,
      ownerRegisterResponse:
          ownerRegisterResponse ?? this.ownerRegisterResponse,
      categoryListResponse: categoryListResponse ?? this.categoryListResponse,
      shopInfoPhotosResponse:
          shopInfoPhotosResponse ?? this.shopInfoPhotosResponse,
      shopCategoryApiResponse:
          shopCategoryApiResponse ?? this.shopCategoryApiResponse,
      shopNumberVerifyResponse:
          shopNumberVerifyResponse ?? this.shopNumberVerifyResponse,
      shopNumberOtpResponse:
          shopNumberOtpResponse ?? this.shopNumberOtpResponse,
    );
  }
}

class ShopNotifier extends Notifier<ShopCategoryState> {
  final ApiDataSource apiDataSource = ApiDataSource();

  @override
  ShopCategoryState build() => ShopCategoryState.initial();

  String _onlyIndian10(String input) {
    var p = input.trim();
    p = p.replaceAll(RegExp(r'[^0-9]'), '');
    if (p.startsWith('91') && p.length == 12) p = p.substring(2);
    if (p.length > 10) p = p.substring(p.length - 10);
    return p;
  }

  Future<bool> shopInfoRegister({
    required String businessProfileId,
    required String category,
    required String subCategory,
    required String englishName,
    required String tamilName,
    required String descriptionEn,
    required String descriptionTa,
    required String addressEn,
    String? shopId,
    required String addressTa,
    required double gpsLatitude,
    required double gpsLongitude,
    required String primaryPhone,
    required String alternatePhone,
    required String contactEmail,
    required bool doorDelivery,
    File? ownerImageUrl,
    required String type,
    required String weeklyHours,
    File? ownerImageFile,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    String ownerImageUrl = '';

    if (type == 'service' && ownerImageFile != null) {
      final uploadResult = await apiDataSource.userProfileUpload(
        imageFile: ownerImageFile,
      );

      ownerImageUrl =
          uploadResult.fold<String?>(
            (failure) => null,
            (success) => success.message,
          ) ??
          '';
    }

    final result = await apiDataSource.shopInfoRegister(
      apiShopId: shopId ?? '',
      businessProfileId: businessProfileId,
      category: category,
      subCategory: subCategory,
      englishName: englishName,
      tamilName: tamilName,
      descriptionEn: descriptionEn,
      descriptionTa: descriptionTa,
      addressEn: addressEn,
      addressTa: addressTa,
      gpsLatitude: gpsLatitude,
      gpsLongitude: gpsLongitude,
      primaryPhone: primaryPhone,
      alternatePhone: alternatePhone,
      contactEmail: contactEmail,
      doorDelivery: doorDelivery,
      ownerImageUrl: ownerImageUrl,
      weeklyHours: weeklyHours,
    );

    return result.fold(
      (failure) async {
        state = state.copyWith(isLoading: false, error: failure.message);
        if (isOfflineMessage(failure.message)) {
          final engine = ref.read(offlineSyncEngineProvider);

          final payload = {
            "type": type, // "service" / "product"
            "apiShopId": shopId ?? "",
            "businessProfileId":
                businessProfileId, // if empty, engine can read from prefs later
            "category": category,
            "subCategory": subCategory,
            "englishName": englishName,
            "tamilName": tamilName,
            "descriptionEn": descriptionEn,
            "descriptionTa": descriptionTa,
            "addressEn": addressEn,
            "addressTa": addressTa,
            "gpsLatitude": gpsLatitude,
            "gpsLongitude": gpsLongitude,
            "primaryPhone": primaryPhone,
            "alternatePhone": alternatePhone,
            "contactEmail": contactEmail,
            "doorDelivery": doorDelivery,
            "weeklyHours": weeklyHours,
            "ownerImageLocalPath":
                (type == "service" && ownerImageFile != null)
                    ? ownerImageFile.path
                    : "",
          };

          final sessionId = await engine.enqueueShop(shopPayload: payload);

          await AppPrefs.setOfflineSessionId(sessionId);

          // ✅ continue next screen even offline
          return true;
        }
        return false;
      },
      (response) async {
        final data = response.data;
        await AppPrefs.setShopId(data?.id ?? '');

        final sopId = await AppPrefs.getSopId();
        AppLogger.log.i('shop Id → $sopId');

        state = state.copyWith(
          isLoading: false,
          ownerRegisterResponse: response,
        );
        return true;
      },
    );
  }

  Future<void> fetchCategories() async {
    state = const ShopCategoryState(isLoading: true);

    final result = await apiDataSource.getShopCategories();

    result.fold(
      (failure) =>
          state = ShopCategoryState(isLoading: false, error: failure.message),
      (response) =>
          state = ShopCategoryState(
            isLoading: false,
            categoryListResponse: response,
          ),
    );
  }

  Future<bool> uploadShopImages({
    required List<File?> images,
    required BuildContext context,
    String? shopId,
    List<String?>? existingUrls,
  }) async {
    state = const ShopCategoryState(isLoading: true);

    // existing urls safe copy
    final safeExisting = List<String?>.filled(4, null);
    final inputExisting = existingUrls ?? const [];

    for (int i = 0; i < 4; i++) {
      if (i < inputExisting.length) {
        final u = inputExisting[i];
        if (u != null && u.trim().isNotEmpty) safeExisting[i] = u.trim();
      }
    }

    // ✅ If no picked images and no existing urls => nothing to upload/save
    final nothingPicked = images.isEmpty || images.every((e) => e == null);
    final noExisting = safeExisting.every((e) => e == null);

    if (nothingPicked && noExisting) {
      state = const ShopCategoryState(
        isLoading: false,
        error: "No images selected",
      );
      return false;
    }

    final types = ["SIGN_BOARD", "OUTSIDE", "INSIDE", "INSIDE"];

    // ✅ QUICK OFFLINE CHECK: if no internet -> directly save to sqlite (NO upload)
    final isOffline = await _isProbablyOffline();
    if (isOffline) {
      final engine = ref.read(offlineSyncEngineProvider);

      final List<Map<String, dynamic>> offlineItems = [];
      for (int i = 0; i < 4; i++) {
        offlineItems.add({
          "type": types[i],
          "localPath": images[i]?.path ?? "",
          "url": safeExisting[i] ?? "",
        });
      }

      await engine.enqueuePhotos(photosPayload: {"items": offlineItems});

      state = const ShopCategoryState(isLoading: false);
      return true;
    }

    // ✅ ONLINE FLOW: upload new files -> get urls -> shopPhotoUpload
    try {
      final List<Map<String, String>> itemsForApi = [];

      for (int i = 0; i < 4; i++) {
        final file = (i < images.length) ? images[i] : null;

        // ✅ new file -> upload -> url
        if (file != null) {
          final uploadResult = await apiDataSource.userProfileUpload(
            imageFile: file,
          );

          final uploadedUrl = uploadResult.fold<String?>(
            (failure) => null,
            (success) => success.message,
          );

          if (uploadedUrl != null && uploadedUrl.trim().isNotEmpty) {
            itemsForApi.add({"type": types[i], "url": uploadedUrl.trim()});
          }
          continue;
        }

        // ✅ else keep existing url
        final oldUrl = safeExisting[i];
        if (oldUrl != null && oldUrl.trim().isNotEmpty) {
          itemsForApi.add({"type": types[i], "url": oldUrl.trim()});
        }
      }

      if (itemsForApi.isEmpty) {
        state = const ShopCategoryState(
          isLoading: false,
          error: "Upload failed",
        );
        return false;
      }

      final apiResult = await apiDataSource.shopPhotoUpload(
        items: itemsForApi,
        apiShopId: shopId,
      );

      return apiResult.fold(
        (failure) async {
          // ✅ If network dropped AFTER upload attempt -> save offline now
          if (isOfflineMessage(failure.message)) {
            final engine = ref.read(offlineSyncEngineProvider);

            final List<Map<String, dynamic>> offlineItems = [];
            for (int i = 0; i < 4; i++) {
              offlineItems.add({
                "type": types[i],
                "localPath": images[i]?.path ?? "",
                "url": safeExisting[i] ?? "",
              });
            }

            await engine.enqueuePhotos(photosPayload: {"items": offlineItems});

            state = const ShopCategoryState(isLoading: false);
            return true;
          }

          state = ShopCategoryState(isLoading: false, error: failure.message);
          return false;
        },
        (response) {
          state = ShopCategoryState(
            isLoading: false,
            shopInfoPhotosResponse: response,
          );
          return response.status == true;
        },
      );
    } catch (e) {
      state = ShopCategoryState(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// ✅ simple offline check (no extra package)
  Future<bool> _isProbablyOffline() async {
    try {
      final result = await InternetAddress.lookup("example.com");
      return result.isEmpty || result.first.rawAddress.isEmpty;
    } catch (_) {
      return true;
    }
  }

  Future<bool> searchKeywords({required List<String> keywords}) async {
    state = const ShopCategoryState(isLoading: true, error: null);

    final result = await apiDataSource.searchKeywords(keywords: keywords);

    return await result.fold<Future<bool>>(
      (failure) async {
        // ✅ OFFLINE -> save in sqlite and continue
        if (isOfflineMessage(failure.message)) {
          final engine = ref.read(offlineSyncEngineProvider);

          await engine.enqueueKeywords(
            keywordsPayload: {
              "keywords": keywords,
              "createdAt": DateTime.now().millisecondsSinceEpoch,
            },
          );

          state = const ShopCategoryState(isLoading: false);
          return true; // ✅ continue next screen even offline
        }

        // ❌ real error
        state = ShopCategoryState(isLoading: false, error: failure.message);
        return false;
      },
      (response) async {
        state = ShopCategoryState(
          isLoading: false,
          shopCategoryApiResponse: response,
        );
        return true;
      },
    );
  }

  Future<String?> shopAddNumberRequest({
    required String phoneNumber,
    required String type,
  }) async {
    if (state.isSendingOtp) return "OTP_ALREADY_SENDING";
    final phone10 = _onlyIndian10(phoneNumber);

    state = state.copyWith(isSendingOtp: true, clearError: true);

    final result = await apiDataSource.shopAddNumberRequest(
      phone: phone10,
      type: type,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(isSendingOtp: false, error: failure.message);
        return failure.message;
      },
      (response) {
        state = state.copyWith(
          isSendingOtp: false,
          shopNumberVerifyResponse: response,
        );
        return null; // ✅ success
      },
    );
  }

  Future<bool> shopAddOtpRequest({
    required String phoneNumber,
    required String type,
    required String code,
  }) async {
    if (state.isVerifyingOtp) return false;

    final phone10 = _onlyIndian10(phoneNumber);

    state = state.copyWith(isVerifyingOtp: true, clearError: true);

    final result = await apiDataSource.shopAddOtpRequest(
      phone: phone10,
      type: type,
      code: code,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(isVerifyingOtp: false, error: failure.message);
        return false;
      },
      (response) async {
        final token = response.data?.verificationToken ?? '';
        if (token.isNotEmpty) {
          await AppPrefs.setVerificationToken(token);
        }

        state = state.copyWith(
          isVerifyingOtp: false,
          shopNumberOtpResponse: response,
        );
        return response.data?.verified == true; // ✅ verified true/false
      },
    );
  }

  void resetState() {
    state = ShopCategoryState.initial();
  }
}

final shopCategoryNotifierProvider =
    NotifierProvider<ShopNotifier, ShopCategoryState>(ShopNotifier.new);
