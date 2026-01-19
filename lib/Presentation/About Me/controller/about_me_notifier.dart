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

class AboutMeState {
  final bool isLoading;
  final bool isGetLoading;
  final String? error;
  final AccountDeleteResponse? accountDeleteResponse;

  // final ServiceEditResponse? serviceEditResponse;

  const AboutMeState({
    this.isLoading = false,
    this.isGetLoading = false,
    this.error,
    this.accountDeleteResponse,
  });

  factory AboutMeState.initial() => const AboutMeState();
}

class AboutMeNotifier extends Notifier<AboutMeState> {
  late final ApiDataSource api;

  @override
  AboutMeState build() {
    api = ref.read(apiDataSourceProvider);
    return AboutMeState.initial();
  }

  Future<bool> deleteProductAction( ) async {
    if (!ref.mounted) return false;

    state = const AboutMeState(isLoading: true, error: null);

    final result = await api.accountDelete();

    if (!ref.mounted) return false;

    return result.fold(
      (failure) {
        if (!ref.mounted) return false;
        AppLogger.log.e('❌ deleteProduct failure: ${failure.message}');
        state = AboutMeState(isLoading: false, error: failure.message);
        return false;
      },
      (response) {
        if (!ref.mounted) return false;
        AppLogger.log.i('✅ deleteProduct status: ${response.status}');
        state = AboutMeState(isLoading: false, accountDeleteResponse: response);
        return response.status == true;
      },
    );
  }

  void resetState() {
    state = AboutMeState.initial();
  }
}

final aboutMeNotifierProvider = NotifierProvider<AboutMeNotifier, AboutMeState>(
  AboutMeNotifier.new,
);
