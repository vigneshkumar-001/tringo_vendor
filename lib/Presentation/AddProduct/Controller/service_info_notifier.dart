import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tringo_vendor_new/Core/Const/app_logger.dart';

import '../../../../Api/DataSource/api_data_source.dart';
import '../../../Core/Offline_Data/offline_helpers.dart';
import '../../../Core/Offline_Data/provider/offline_providers.dart';
import '../../../Core/Utility/app_prefs.dart';
import '../../Login Screen/Controller/login_notifier.dart';
import '../Model/service_info_response.dart';

class ServiceInfoState {
  final bool isLoading;
  final String? imageUrl;
  final String? error;
  final ServiceInfoResponse? serviceInfoResponse;

  const ServiceInfoState({
    this.isLoading = false,
    this.error,
    this.imageUrl,
    this.serviceInfoResponse,
  });

  factory ServiceInfoState.initial() => const ServiceInfoState();
}

class ServiceInfoNotifier extends Notifier<ServiceInfoState> {
  // final ApiDataSource apiDataSource = ApiDataSource();

  late final ApiDataSource api;

  @override
  ServiceInfoState build() {
    api = ref.read(apiDataSourceProvider);
    return ServiceInfoState.initial();
  }

  Future<bool> saveServiceInfo({
    required String title,
    required String tamilName,
    required String description,
    required int startsAt,
    required String offerLabel,
    required String offerValue,
    required String serviceId,
    required int durationMinutes,
    required String categoryId,
    required String subCategory,
    String? apiShopId,
    required List<String> tags,
  }) async {
    state = const ServiceInfoState(isLoading: true);

    final result = await api.serviceInfo(
      apiServiceId: serviceId,
      title: title,
      tamilName: tamilName,
      apiShopId: apiShopId,
      description: description,
      startsAt: startsAt,
      offerLabel: offerLabel,
      offerValue: offerValue,
      durationMinutes: durationMinutes,
      categoryId: categoryId,
      subCategory: subCategory,
      tags: tags,
    );

    if (!ref.mounted) return false;

    return await result.fold<Future<bool>>(
      (failure) async {
        // ✅ OFFLINE save
        if (isOfflineMessage(failure.message)) {
          final engine = ref.read(offlineSyncEngineProvider);

          await engine.enqueueServiceInfo(
            payload: {
              "apiShopId": apiShopId ?? "",
              "serviceId": serviceId,
              "title": title,
              "tamilName": tamilName,
              "description": description,
              "startsAt": startsAt,
              "offerLabel": offerLabel,
              "offerValue": offerValue,
              "durationMinutes": durationMinutes,
              "categoryId": categoryId,
              "subCategory": subCategory,
              "tags": tags,
              "createdAt": DateTime.now().millisecondsSinceEpoch,
            },
          );

          if (!ref.mounted) return true;
          state = const ServiceInfoState(isLoading: false);
          return true; // ✅ continue next screen even offline
        }

        if (!ref.mounted) return false;
        state = ServiceInfoState(isLoading: false, error: failure.message);
        return false;
      },
      (response) async {
        await AppPrefs.setServiceId(response.data.id ?? '');

        if (!ref.mounted) return true;
        state = ServiceInfoState(
          isLoading: false,
          serviceInfoResponse: response,
        );
        return true;
      },
    );
  }

  Future<bool> uploadServiceImages({
    required List<File?> images,
    required List<Map<String, String>> features,
    required BuildContext context,
  }) async {
    // ✅ validate at least 1 image selected
    if (images.isEmpty || images.every((f) => f == null)) {
      state = const ServiceInfoState(
        isLoading: false,
        error: "Please select at least 1 image",
      );
      return false;
    }

    state = const ServiceInfoState(isLoading: true, error: null);

    Future<bool> _saveOfflineAndContinue({String? reason}) async {
      try {
        final engine = ref.read(offlineSyncEngineProvider);

        final paths =
            images
                .where((e) => e != null)
                .map((e) => e!.path)
                .where((p) => p.trim().isNotEmpty)
                .toList();

        await engine.enqueueServiceImages(
          payload: {
            "imagePaths": paths,
            "features": features, // already List<Map<String,String>>
            "reason": reason ?? "",
            "createdAt": DateTime.now().millisecondsSinceEpoch,
          },
        );

        AppLogger.log.w("✅ OFFLINE: product images saved (${paths.length})");
        state = const ServiceInfoState(isLoading: false);
        return true; // ✅ ServiceInfoState flow even offline
      } catch (e) {
        // if even sqlite insert fails, show real error
        AppLogger.log.e("❌ OFFLINE SAVE FAILED: $e");
        state = ServiceInfoState(
          isLoading: false,
          error: "Offline save failed: $e",
        );
        return false;
      }
    }

    try {
      final List<String> uploadedUrls = [];

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

              state = ServiceInfoState(
                isLoading: false,
                error: failure.message,
              );
              return false;
            },
            (success) async {
              final url = (success.message ?? "").trim();
              if (url.isEmpty) {
                state = const ServiceInfoState(
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
          state = ServiceInfoState(isLoading: false, error: msg);
          return false;
        }
      }

      // If no urls and not offline => error
      if (uploadedUrls.isEmpty) {
        state = const ServiceInfoState(
          isLoading: false,
          error: "No image uploaded",
        );
        return false;
      }

      // ✅ Update product with uploaded urls + feature list
      try {
        final updateRes = await api.serviceList(
          images: uploadedUrls,
          features: features,
        );

        return await updateRes.fold<Future<bool>>(
          (failure) async {
            if (isOfflineMessage(failure.message)) {
              // Update step offline -> save local paths too
              return await _saveOfflineAndContinue(reason: failure.message);
            }
            state = ServiceInfoState(isLoading: false, error: failure.message);
            return false;
          },
          (response) async {
            state = ServiceInfoState(
              isLoading: false,
              serviceInfoResponse: response,
            );
            return response.status == true;
          },
        );
      } catch (e) {
        final msg = e.toString();
        if (isOfflineMessage(msg)) {
          return await _saveOfflineAndContinue(reason: msg);
        }
        state = ServiceInfoState(isLoading: false, error: msg);
        return false;
      }
    } catch (e) {
      final msg = e.toString();
      if (isOfflineMessage(msg)) {
        return await _saveOfflineAndContinue(reason: msg);
      }
      state = ServiceInfoState(isLoading: false, error: msg);
      return false;
    }
  }

  // Future<bool> uploadServiceImages({
  //   required List<File?> images,
  //   required List<Map<String, String>> features,
  //   required BuildContext context,
  // }) async
  // {
  //   if (images.isEmpty || images.every((f) => f == null)) {
  //     state = const ServiceInfoState(
  //       isLoading: false,
  //       error: "Please select at least 1 image",
  //     );
  //     return false;
  //   }
  //
  //   state = const ServiceInfoState(isLoading: true);
  //
  //   try {
  //     final List<String> uploadedUrls = [];
  //
  //     for (final file in images) {
  //       if (file == null) continue;
  //
  //       final uploadResult = await api.serviceImageUpload(imageFile: file);
  //
  //       final uploadedUrl = uploadResult.fold<String?>(
  //         (failure) => null,
  //         (success) => success.message,
  //       );
  //
  //       if (uploadedUrl == null || uploadedUrl.trim().isEmpty) {
  //         final retry = await api.serviceImageUpload(imageFile: file);
  //         final failureMsg = retry.fold<String?>((f) => f.message, (_) => null);
  //
  //         if (failureMsg != null && isOfflineMessage(failureMsg)) {
  //           final engine = ref.read(offlineSyncEngineProvider);
  //           final paths =
  //               images.where((e) => e != null).map((e) => e!.path).toList();
  //
  //           await engine.enqueueServiceImages(
  //             payload: {
  //               "imagePaths": paths,
  //               "features": features,
  //               "createdAt": DateTime.now().millisecondsSinceEpoch,
  //             },
  //           );
  //
  //           state = const ServiceInfoState(isLoading: false);
  //           return true; // ✅ continue next screen
  //         }
  //
  //         state = ServiceInfoState(
  //           isLoading: false,
  //           error: failureMsg ?? "Image upload failed",
  //         );
  //         return false;
  //       }
  //
  //       uploadedUrls.add(uploadedUrl.trim());
  //     }
  //
  //     if (uploadedUrls.isEmpty) {
  //       state = const ServiceInfoState(
  //         isLoading: false,
  //         error: "No image uploaded",
  //       );
  //       return false;
  //     }
  //
  //     final result = await api.serviceList(
  //       images: uploadedUrls,
  //       features: features,
  //     );
  //
  //     return result.fold(
  //       (failure) async {
  //         if (isOfflineMessage(failure.message)) {
  //           final engine = ref.read(offlineSyncEngineProvider);
  //           final paths =
  //               images.where((e) => e != null).map((e) => e!.path).toList();
  //
  //           await engine.enqueueServiceImages(
  //             payload: {
  //               "imagePaths": paths,
  //               "features": features,
  //               "createdAt": DateTime.now().millisecondsSinceEpoch,
  //             },
  //           );
  //
  //           state = const ServiceInfoState(isLoading: false);
  //           return true;
  //         }
  //
  //         state = ServiceInfoState(isLoading: false, error: failure.message);
  //         return false;
  //       },
  //       (response) async {
  //         state = ServiceInfoState(
  //           isLoading: false,
  //           serviceInfoResponse: response,
  //         );
  //         return response.status == true;
  //       },
  //     );
  //   } catch (e) {
  //     state = ServiceInfoState(isLoading: false, error: e.toString());
  //     return false;
  //   }
  // }

  // Future<ServiceInfoResponse?> saveServiceInfo({
  //   required String title,
  //   required String tamilName,
  //   required String description,
  //   required int startsAt,
  //   required String offerLabel,
  //   required String offerValue,
  //   required String ServiceId,
  //   required int durationMinutes,
  //   required String categoryId,
  //   required String subCategory,
  //   String? apiShopId,
  //   required List<String> tags,
  // }) async
  // {
  //   state = const ServiceInfoState(isLoading: true);
  //
  //   final result = await api.serviceInfo(
  //     apiServiceId: ServiceId,
  //     title: title,
  //     tamilName: tamilName,
  //     apiShopId: apiShopId,
  //     description: description,
  //     startsAt: startsAt,
  //     offerLabel: offerLabel,
  //     offerValue: offerValue,
  //     durationMinutes: durationMinutes,
  //     categoryId: categoryId,
  //     subCategory: subCategory,
  //     tags: tags,
  //   );
  //
  //   // Provider may have been disposed while waiting for API
  //   if (!ref.mounted) return null;
  //
  //   return await result.fold<Future<ServiceInfoResponse?>>(
  //         (failure) async {
  //       // ✅ OFFLINE save
  //       if (isOfflineMessage(failure.message)) {
  //         final engine = ref.read(offlineSyncEngineProvider);
  //
  //         await engine.enqueueServiceInfo(
  //           payload: {
  //             "apiShopId": apiShopId ?? "",
  //             "ServiceId": ServiceId,
  //             "title": title,
  //             "tamilName": tamilName,
  //             "description": description,
  //             "startsAt": startsAt,
  //             "offerLabel": offerLabel,
  //             "offerValue": offerValue,
  //             "durationMinutes": durationMinutes,
  //             "categoryId": categoryId,
  //             "subCategory": subCategory,
  //             "tags": tags,
  //             "createdAt": DateTime.now().millisecondsSinceEpoch,
  //           },
  //         );
  //
  //         state = const ServiceInfoState(isLoading: false);
  //         return ServiceInfoResponse(status: true, data: ServiceInfoData(id: ""));
  //         // 👉 if your model requires fields, adjust.
  //       }
  //
  //       state = ServiceInfoState(isLoading: false, error: failure.message);
  //       return null;
  //     },
  //         (response) async {
  //       await AppPrefs.setServiceId(response.data.id ?? '');
  //       state = ServiceInfoState(isLoading: false, serviceInfoResponse: response);
  //       return response;
  //     },
  //   );
  //
  // }

  // Future<bool> uploadServiceImages({
  //   required List<File?> images,
  //   required List<Map<String, String>> features,
  //   required BuildContext context,
  // }) async
  // {
  //   // ---- VALIDATION ----
  //   if (images.isEmpty || images.every((f) => f == null)) {
  //     state = const ServiceInfoState(
  //       isLoading: false,
  //       error: "Please select at least 1 image",
  //     );
  //     return false;
  //   }
  //
  //   state = const ServiceInfoState(isLoading: true);
  //
  //   // ---- STEP 1: UPLOAD IMAGES ONE BY ONE ----
  //   final List<String> uploadedUrls = [];
  //
  //   for (final file in images) {
  //     if (file == null) continue;
  //
  //     final uploadResult = await api.serviceImageUpload(imageFile: file);
  //
  //     final uploadedUrl = uploadResult.fold<String?>(
  //       (failure) => null,
  //       (success) => success.message,
  //     );
  //
  //     if (uploadedUrl == null) {
  //       state = const ServiceInfoState(
  //         isLoading: false,
  //         error: "Image upload failed",
  //       );
  //       return false;
  //     }
  //
  //     uploadedUrls.add(uploadedUrl);
  //   }
  //
  //   if (uploadedUrls.isEmpty) {
  //     state = const ServiceInfoState(
  //       isLoading: false,
  //       error: "No image uploaded",
  //     );
  //     return false;
  //   }
  //
  //   // ---- STEP 2: CALL SERVICE API WITH FULL BODY ----
  //   final result = await api.serviceList(
  //     images: uploadedUrls,
  //     features: features,
  //   );
  //
  //   return result.fold(
  //     (failure) {
  //       state = ServiceInfoState(isLoading: false, error: failure.message);
  //       return false;
  //     },
  //     (response) {
  //       state = ServiceInfoState(
  //         isLoading: false,
  //         serviceInfoResponse: response,
  //       );
  //       return response.status == true;
  //     },
  //   );
  // }

  Future<bool> serviceSearchWords({required List<String> keywords}) async {
    state = const ServiceInfoState(isLoading: true);

    final result = await api.serviceSearchKeyWords(keywords: keywords);

    return await result.fold<Future<bool>>(
      (failure) async {
        // ✅ OFFLINE -> SAVE SQLITE & CONTINUE
        if (isOfflineMessage(failure.message)) {
          final engine = ref.read(offlineSyncEngineProvider);

          await engine.enqueueServiceKeywords(
            payload: {
              "keywords": keywords,
              "createdAt": DateTime.now().millisecondsSinceEpoch,
            },
          );

          state = const ServiceInfoState(isLoading: false);
          return true; // ✅ continue next screen
        }

        state = ServiceInfoState(isLoading: false, error: failure.message);
        return false;
      },
      (response) async {
        state = ServiceInfoState(
          isLoading: false,
          serviceInfoResponse: response,
        );
        return true;
      },
    );
  }
}

final serviceInfoNotifierProvider =
    NotifierProvider<ServiceInfoNotifier, ServiceInfoState>(
      ServiceInfoNotifier.new,
    );
