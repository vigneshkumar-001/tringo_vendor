import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../Api/DataSource/api_data_source.dart';
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

  Future<ServiceInfoResponse?> saveServiceInfo({
    required String title,
    required String tamilName,
    required String description,
    required int startsAt,
    required String offerLabel,
    required String offerValue,
    required String ServiceId,
    required int durationMinutes,
    required String categoryId,
    required String subCategory,
    String? apiShopId,
    required List<String> tags,
  }) async {
    state = const ServiceInfoState(isLoading: true);

    final result = await api.serviceInfo(
      apiServiceId: ServiceId,
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

    // Provider may have been disposed while waiting for API
    if (!ref.mounted) return null;

    return await result.fold<Future<ServiceInfoResponse?>>(
      (failure) async {
        if (!ref.mounted) return null;
        state = ServiceInfoState(isLoading: false, error: failure.message);
        return null;
      },
      (response) async {
        await AppPrefs.setServiceId(response.data.id ?? '');

        if (!ref.mounted) return null;
        state = ServiceInfoState(
          isLoading: false,
          serviceInfoResponse: response,
        );
        return response;
      },
    );
  }

  Future<bool> uploadServiceImages({
    required List<File?> images,
    required List<Map<String, String>> features,
    required BuildContext context,
  }) async {
    // ---- VALIDATION ----
    if (images.isEmpty || images.every((f) => f == null)) {
      state = const ServiceInfoState(
        isLoading: false,
        error: "Please select at least 1 image",
      );
      return false;
    }

    state = const ServiceInfoState(isLoading: true);

    // ---- STEP 1: UPLOAD IMAGES ONE BY ONE ----
    final List<String> uploadedUrls = [];

    for (final file in images) {
      if (file == null) continue;

      final uploadResult = await api.serviceImageUpload(imageFile: file);

      final uploadedUrl = uploadResult.fold<String?>(
        (failure) => null,
        (success) => success.message,
      );

      if (uploadedUrl == null) {
        state = const ServiceInfoState(
          isLoading: false,
          error: "Image upload failed",
        );
        return false;
      }

      uploadedUrls.add(uploadedUrl);
    }

    if (uploadedUrls.isEmpty) {
      state = const ServiceInfoState(
        isLoading: false,
        error: "No image uploaded",
      );
      return false;
    }

    // ---- STEP 2: CALL SERVICE API WITH FULL BODY ----
    final result = await api.serviceList(
      images: uploadedUrls,
      features: features,
    );

    return result.fold(
      (failure) {
        state = ServiceInfoState(isLoading: false, error: failure.message);
        return false;
      },
      (response) {
        state = ServiceInfoState(
          isLoading: false,
          serviceInfoResponse: response,
        );
        return response.status == true;
      },
    );
  }

  Future<bool> serviceSearchWords({required List<String> keywords}) async {
    state = const ServiceInfoState(isLoading: true);

    final result = await api.serviceSearchKeyWords(keywords: keywords);

    bool success = false;

    result.fold(
      (failure) {
        state = ServiceInfoState(isLoading: false, error: failure.message);
        success = false;
      },
      (response) async {

        state = ServiceInfoState(
          isLoading: false,
          serviceInfoResponse: response,
        );
        success = true;
      },
    );

    return success;
  }


}

final serviceInfoNotifierProvider =
    NotifierProvider<ServiceInfoNotifier, ServiceInfoState>(
      ServiceInfoNotifier.new,
    );
