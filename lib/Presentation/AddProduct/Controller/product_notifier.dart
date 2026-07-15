import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tringo_vendor_new/Core/Const/app_logger.dart';

import '../../../Api/DataSource/api_data_source.dart';
import '../../../Api/Repository/failure.dart';
import '../../../Core/Offline_Data/offline_helpers.dart';
import '../../../Core/Offline_Data/provider/offline_providers.dart';
import '../../../Core/Offline_Data/offline_db/offline_sync_db.dart';
import '../../../Core/Offline_Data/offline_sync_models.dart';
import '../../../Core/Utility/app_prefs.dart';
import '../../Login Screen/Controller/login_notifier.dart';
import '../../ShopInfo/Model/category_list_response.dart';
import '../Model/delete_response.dart';
import '../Model/product_response.dart';
import '../Model/service_remove_response.dart';

class ProductState {
  final bool isLoading;
  final bool isGetLoading;
  final String? error;
  final ProductResponse? productResponse;
  final CategoryListResponse? shopCategoryListResponse;
  final DeleteResponse? deleteResponses;
  final ServiceRemoveResponse? serviceRemoveResponse;

  // final ServiceEditResponse? serviceEditResponse;

  // Category of the shop's FIRST-created product/service, suggested when
  // adding the NEXT one (most shops repeat the same category). Null when
  // the shop has no prior item yet, or the suggestion hasn't loaded.
  final String? suggestedCategorySlug;
  final String? suggestedSubCategorySlug;

  const ProductState({
    this.isLoading = false,
    this.isGetLoading = false,
    this.error,
    this.productResponse,
    this.shopCategoryListResponse,
    this.deleteResponses,
    this.serviceRemoveResponse,
    // this.serviceEditResponse,
    this.suggestedCategorySlug,
    this.suggestedSubCategorySlug,
  });

  factory ProductState.initial() => const ProductState();
}

class ProductNotifier extends Notifier<ProductState> {
  late final ApiDataSource api;

  @override
  ProductState build() {
    api = ref.read(apiDataSourceProvider);
    return ProductState.initial();
  }

  Future<bool> addProduct({
    required String category,
    required String subCategory,
    required String englishName,
    required int price,
    required String offerLabel,
    required String offerValue,
    required String description,
    String? shopId,
    String? productId, // from widget / route
    required bool doorDelivery,
    String? priceType,
  }) async {
    state = const ProductState(isLoading: true);

    // Only use id if non-empty
    // final String? productIdToUse = (productId != null && productId.isNotEmpty)
    //     ? productId
    //     : null;

    final result = await api.addProduct(
      apiProductId: productId, // only this
      subCategory: subCategory,
      apiShopId: shopId,
      englishName: englishName,
      category: category,
      description: description,
      offerLabel: offerLabel,
      offerValue: offerValue,
      price: price,
      doorDelivery: doorDelivery,
      priceType: priceType,
    );

    final isSuccess = await result.fold<Future<bool>>(
      (failure) async {
        // ✅ OFFLINE -> SAVE SQLITE & CONTINUE
        if (isOfflineMessage(failure.message)) {
          final engine = ref.read(offlineSyncEngineProvider);

          await engine.enqueueProductInfo(
            payload: {
              "shopId": shopId ?? "",
              "productId": productId ?? "",
              "category": category,
              "subCategory": subCategory,
              "englishName": englishName,
              "price": price,
              "offerLabel": offerLabel,
              "offerValue": offerValue,
              "description": description,
              "doorDelivery": doorDelivery,
              "priceType": priceType,
              "createdAt": DateTime.now().millisecondsSinceEpoch,
            },
          );

          state = const ProductState(isLoading: false);
          return true; // ✅ continue even offline
        }

        state = ProductState(isLoading: false, error: failure.message);
        return false;
      },
      (response) async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('product_id', response.data.id);
        state = ProductState(isLoading: false, productResponse: response);
        return true;
      },
    );

    return isSuccess;
  }

  Future<void> fetchProductCategories({String? apiShopId}) async {
    // Preserve any already-fetched suggestion — this method is re-called
    // every time the category picker opens, and shouldn't wipe it.
    state = ProductState(
      isGetLoading: true,
      suggestedCategorySlug: state.suggestedCategorySlug,
      suggestedSubCategorySlug: state.suggestedSubCategorySlug,
    );

    final result = await api.getProductCategories(apiShopId: apiShopId);

    result.fold(
      (failure) => state = ProductState(
        isGetLoading: false,
        error: failure.message,
        suggestedCategorySlug: state.suggestedCategorySlug,
        suggestedSubCategorySlug: state.suggestedSubCategorySlug,
      ),
      (response) => state = ProductState(
        isGetLoading: false,
        shopCategoryListResponse: response,
        suggestedCategorySlug: state.suggestedCategorySlug,
        suggestedSubCategorySlug: state.suggestedSubCategorySlug,
      ),
    );
  }

  // Fetches the shop's first-created product/service category to suggest it
  // when adding the next one. Best-effort: failures are swallowed since this
  // is a UX nicety, not required for the add-product/service flow to work.
  Future<void> fetchSuggestedCategory({
    required String shopId,
    required bool isService,
  }) async {
    if (shopId.trim().isEmpty) return;

    final result = isService
        ? await api.getFirstServiceCategory(apiShopId: shopId)
        : await api.getFirstProductCategory(apiShopId: shopId);

    result.fold((failure) {}, (data) {
      final category = (data['category'] as String?)?.trim();
      final subCategory = (data['subCategory'] as String?)?.trim();
      if ((category == null || category.isEmpty) &&
          (subCategory == null || subCategory.isEmpty)) {
        return;
      }

      state = ProductState(
        isLoading: state.isLoading,
        isGetLoading: state.isGetLoading,
        error: state.error,
        productResponse: state.productResponse,
        shopCategoryListResponse: state.shopCategoryListResponse,
        deleteResponses: state.deleteResponses,
        serviceRemoveResponse: state.serviceRemoveResponse,
        suggestedCategorySlug: category,
        suggestedSubCategorySlug: subCategory,
      );
    });
  }

  Future<bool> uploadProductImages({
    required List<File?> images,
    required List<Map<String, String>> features,
    List<String> existingImageUrls = const [],
    required BuildContext context,
  }) async
  {
    // ✅ validate at least 1 image selected
    final hasNew = images.isNotEmpty && images.any((f) => f != null);
    final hasExisting = existingImageUrls.any((e) => e.trim().isNotEmpty);

    if (!hasNew && !hasExisting) {
      state = const ProductState(
        isLoading: false,
        error: "Please select at least 1 image",
      );
      return false;
    }

    state = const ProductState(isLoading: true, error: null);

    Future<bool> _saveOfflineAndContinue({String? reason}) async {
      try {
        final engine = ref.read(offlineSyncEngineProvider);

        final paths =
            images
                .where((e) => e != null)
                .map((e) => e!.path)
                .where((p) => p.trim().isNotEmpty)
                .toList();

        await engine.enqueueProductImages(
          payload: {
            "imagePaths": paths,
            "features": features, // already List<Map<String,String>>
            "reason": reason ?? "",
            "createdAt": DateTime.now().millisecondsSinceEpoch,
          },
        );

        AppLogger.log.w("✅ OFFLINE: product images saved (${paths.length})");
        state = const ProductState(isLoading: false);
        return true; // ✅ continue flow even offline
      } catch (e) {
        // if even sqlite insert fails, show real error
        AppLogger.log.e("❌ OFFLINE SAVE FAILED: $e");
        state = ProductState(
          isLoading: false,
          error: "Offline save failed: $e",
        );
        return false;
      }
    }

    try {
      final List<String> uploadedUrls = [
        ...existingImageUrls.where((e) => e.trim().isNotEmpty),
      ];

      // ✅ Upload each selected image
      for (final file in images) {
        if (file == null) continue;

        try {
          final uploadResult = await api.userProfileUpload(imageFile: file);

          final ok = await uploadResult.fold<Future<bool>>(
            (failure) async {
              // ✅ Offline / DNS / no internet -> save local paths
              if (isOfflineMessage(failure.message)) {
                return await _saveOfflineAndContinue(reason: failure.message);
              }

              state = ProductState(isLoading: false, error: failure.message);
              return false;
            },
            (success) async {
              final url = (success.message ?? "").trim();
              if (url.isEmpty) {
                state = const ProductState(
                  isLoading: false,
                  error: "Image upload failed (empty url)",
                );
                return false;
              }
              uploadedUrls.add(url);
              return true;
            },
          );

          // ✅ If we saved offline, stop uploading and continue
          if (ok && uploadedUrls.isEmpty) return true;

          if (!ok) return false;
        } catch (e) {
          // ✅ IMPORTANT: if api.userProfileUpload() throws, handle here
          final msg = e.toString();
          if (isOfflineMessage(msg)) {
            return await _saveOfflineAndContinue(reason: msg);
          }
          state = ProductState(isLoading: false, error: msg);
          return false;
        }
      }

      // If no urls and not offline => error
      if (uploadedUrls.isEmpty) {
        state = const ProductState(
          isLoading: false,
          error: "No image uploaded",
        );
        return false;
      }

      // ✅ Update product with uploaded urls + feature list
      try {
        final updateRes = await api.updateProducts(
          images: uploadedUrls,
          features: features,
        );

        return await updateRes.fold<Future<bool>>(
          (failure) async {
            if (isOfflineMessage(failure.message)) {
              // Update step offline -> save local paths too
              return await _saveOfflineAndContinue(reason: failure.message);
            }
            state = ProductState(isLoading: false, error: failure.message);
            return false;
          },
          (response) async {
            state = ProductState(isLoading: false, productResponse: response);
            return response.status == true;
          },
        );
      } catch (e) {
        final msg = e.toString();
        if (isOfflineMessage(msg)) {
          return await _saveOfflineAndContinue(reason: msg);
        }
        state = ProductState(isLoading: false, error: msg);
        return false;
      }
    } catch (e) {
      final msg = e.toString();
      if (isOfflineMessage(msg)) {
        return await _saveOfflineAndContinue(reason: msg);
      }
      state = ProductState(isLoading: false, error: msg);
      return false;
    }
  }

  Future<bool> updateProductSearchWords({
    required List<String> keywords,
  }) async {
    state = const ProductState(isLoading: true);

    final result = await api.updateSearchKeyWords(keywords: keywords);

    return await result.fold<Future<bool>>(
      (failure) async {
        // ✅ OFFLINE -> SAVE SQLITE & CONTINUE
        if (isOfflineMessage(failure.message)) {
          final engine = ref.read(offlineSyncEngineProvider);

          await engine.enqueueProductKeywords(
            payload: {
              "keywords": keywords,
              "createdAt": DateTime.now().millisecondsSinceEpoch,
            },
          );

          state = const ProductState(isLoading: false);
          return true; // ✅ continue next screen
        }

        state = ProductState(isLoading: false, error: failure.message);
        return false;
      },
      (response) async {
        state = ProductState(isLoading: false, productResponse: response);
        return true;
      },
    );
  }

  Future<bool> deleteProductAction({String? productId}) async {
    if (!ref.mounted) return false;

    state = const ProductState(isLoading: true, error: null);

    final result = await api.deleteProduct(productId: productId);

    if (!ref.mounted) return false;

    return result.fold(
      (failure) {
        if (!ref.mounted) return false;
        AppLogger.log.e('❌ deleteProduct failure: ${failure.message}');
        state = ProductState(isLoading: false, error: failure.message);
        return false;
      },
      (response) {
        if (!ref.mounted) return false;
        AppLogger.log.i('✅ deleteProduct status: ${response.status}');
        state = ProductState(isLoading: false, deleteResponses: response);
        return response.status == true;
      },
    );
  }

  Future<bool> deleteServiceAction({String? serviceId}) async {
    if (!ref.mounted) return false;

    state = const ProductState(isLoading: true, error: null);

    final result = await api.deleteService(serviceId: serviceId);

    if (!ref.mounted) return false;

    return result.fold(
      (failure) {
        if (!ref.mounted) return false;
        AppLogger.log.e('❌ deleteService failure: ${failure.message}');
        state = ProductState(isLoading: false, error: failure.message);
        return false;
      },
      (response) {
        if (!ref.mounted) return false;

        AppLogger.log.i(
          '✅ deleteService status: ${response.status}, success: ${response.data.success}',
        );

        state = ProductState(isLoading: false, serviceRemoveResponse: response);

        // both flags must be true
        return response.status && response.data.success;
      },
    );
  }

  void resetState() {
    state = ProductState.initial();
  }
}

final productNotifierProvider = NotifierProvider<ProductNotifier, ProductState>(
  ProductNotifier.new,
);
