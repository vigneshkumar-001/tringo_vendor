import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tringo_vendor_new/Core/Const/app_logger.dart';

import 'package:tringo_vendor_new/Presentation/Owner%20Screen/Model/owner_register_response.dart';
import 'package:tringo_vendor_new/Presentation/ShopInfo/Model/category_list_response.dart';
import '../../../Api/DataSource/api_data_source.dart';
import '../../../Core/Utility/app_prefs.dart';
import '../../Owner Screen/Model/owner_otp_response.dart';
import '../Model/search_keywords_response.dart';
import '../Model/shop_info_photos_response.dart';

class ShopCategoryState {
  final bool isLoading;
  final String? imageUrl;
  final String? error;
  final OwnerRegisterResponse? ownerRegisterResponse;
  final CategoryListResponse? categoryListResponse;
  final ShopInfoPhotosResponse? shopInfoPhotosResponse;
  final ShopCategoryApiResponse? shopCategoryApiResponse;

  const ShopCategoryState({
    this.isLoading = false,
    this.error,
    this.ownerRegisterResponse,
    this.imageUrl,
    this.categoryListResponse,
    this.shopInfoPhotosResponse,
    this.shopCategoryApiResponse,
  });

  factory ShopCategoryState.initial() => const ShopCategoryState();
  ShopCategoryState copyWith({
    bool? isLoading,
    OwnerRegisterResponse? ownerRegisterResponse,
    CategoryListResponse? categoryListResponse,
    ShopInfoPhotosResponse? shopInfoPhotosResponse,
    ShopCategoryApiResponse? shopCategoryApiResponse,

    String? error,
  }) {
    return ShopCategoryState(
      error: error,
      isLoading: isLoading ?? this.isLoading,

      ownerRegisterResponse:
          ownerRegisterResponse ?? this.ownerRegisterResponse,
      categoryListResponse: categoryListResponse ?? this.categoryListResponse,
      shopInfoPhotosResponse:
          shopInfoPhotosResponse ?? this.shopInfoPhotosResponse,
      shopCategoryApiResponse:
          shopCategoryApiResponse ?? this.shopCategoryApiResponse,
    );
  }
}

class ShopNotifier extends Notifier<ShopCategoryState> {
  final ApiDataSource apiDataSource = ApiDataSource();

  @override
  ShopCategoryState build() => ShopCategoryState.initial();

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
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
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
    List<String?>? existingUrls, // ✅ NEW
  }) async {
    // existingUrls will be used in edit mode so old images won't be lost
    final safeExisting = List<String?>.filled(4, null);
    final inputExisting = existingUrls ?? const [];

    for (int i = 0; i < 4; i++) {
      if (i < inputExisting.length) {
        final u = inputExisting[i];
        if (u != null && u.trim().isNotEmpty) safeExisting[i] = u.trim();
      }
    }

    // if no picked images and no existing urls => nothing to upload
    final nothingPicked = images.isEmpty || images.every((e) => e == null);
    final noExisting = safeExisting.every((e) => e == null);

    if (nothingPicked && noExisting) {
      state = const ShopCategoryState(
        isLoading: false,
        error: 'No images selected',
      );
      return false;
    }

    state = const ShopCategoryState(isLoading: true);

    try {
      final types = ["SIGN_BOARD", "OUTSIDE", "INSIDE", "INSIDE"];
      final List<Map<String, String>> items = [];

      for (int i = 0; i < 4; i++) {
        final file = (i < images.length) ? images[i] : null;

        // ✅ If user picked new file => upload and use new URL
        if (file != null) {
          final uploadResult = await apiDataSource.userProfileUpload(
            imageFile: file,
          );

          final uploadedUrl = uploadResult.fold<String?>(
            (failure) => null,
            (success) => success.message,
          );

          if (uploadedUrl != null && uploadedUrl.trim().isNotEmpty) {
            items.add({"type": types[i], "url": uploadedUrl.trim()});
          }
          continue;
        }

        // ✅ If no new file, keep old url (important for edit flow)
        final oldUrl = safeExisting[i];
        if (oldUrl != null && oldUrl.trim().isNotEmpty) {
          items.add({"type": types[i], "url": oldUrl.trim()});
        }
      }

      if (items.isEmpty) {
        state = const ShopCategoryState(
          isLoading: false,
          error: 'Upload failed',
        );
        return false;
      }

      final apiResult = await apiDataSource.shopPhotoUpload(
        items: items,
        apiShopId: shopId,
      );

      return apiResult.fold(
        (failure) {
          state = ShopCategoryState(isLoading: false, error: failure.message);
          AppLogger.log.e(failure.message);
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

  // Future<bool> uploadShopImages({
  //   required List<File?> images,
  //   required BuildContext context,
  //   String? shopId,
  // })
  // async {
  //   if (images.isEmpty || images.every((e) => e == null)) {
  //     state = const ShopCategoryState(
  //       isLoading: false,
  //       error: 'No images selected',
  //     );
  //     return false;
  //   }
  //
  //   state = const ShopCategoryState(isLoading: true);
  //
  //   final types = ["SIGN_BOARD", "OUTSIDE", "INSIDE", "INSIDE"];
  //   final List<Map<String, String>> items = [];
  //
  //   for (int i = 0; i < images.length; i++) {
  //     final file = images[i];
  //     if (file == null) continue;
  //
  //     final uploadResult = await apiDataSource.userProfileUpload(
  //       imageFile: file,
  //     );
  //
  //     final uploadedUrl = uploadResult.fold<String?>(
  //       (failure) => null,
  //       (success) => success.message,
  //     );
  //
  //     if (uploadedUrl != null) {
  //       items.add({"type": types[i], "url": uploadedUrl});
  //     }
  //   }
  //
  //   if (items.isEmpty) {
  //     state = const ShopCategoryState(isLoading: false, error: 'Upload failed');
  //     return false;
  //   }
  //
  //   final apiResult = await apiDataSource.shopPhotoUpload(
  //     items: items,
  //     apiShopId: shopId,
  //   );
  //
  //   return apiResult.fold(
  //     (failure) {
  //       state = ShopCategoryState(isLoading: false, error: failure.message);
  //       AppLogger.log.e(failure.message);
  //       return false;
  //     },
  //     (response) {
  //       state = ShopCategoryState(
  //         isLoading: false,
  //         shopInfoPhotosResponse: response,
  //       );
  //       return response.status == true;
  //     },
  //   );
  //
  //   // IMPORTANT: do NOT reset state again; that would erase success/error.
  // }

  Future<bool> searchKeywords({required List<String> keywords}) async {
    state = const ShopCategoryState(isLoading: true);

    final result = await apiDataSource.searchKeywords(keywords: keywords);

    bool success = false;

    result.fold(
      (failure) {
        state = ShopCategoryState(isLoading: false, error: failure.message);
        success = false;
      },
      (response) {
        state = ShopCategoryState(
          isLoading: false,
          shopCategoryApiResponse: response,
        );
        success = true;
      },
    );

    return success;
  }

  void resetState() {
    state = ShopCategoryState.initial();
  }
}

final shopCategoryNotifierProvider =
    NotifierProvider<ShopNotifier, ShopCategoryState>(ShopNotifier.new);
