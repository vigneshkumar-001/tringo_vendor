import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tringo_vendor_new/Presentation/Login%20Screen/Model/app_version_response.dart';
import 'package:tringo_vendor_new/Presentation/Login%20Screen/Model/device_token_response.dart';

import '../../../Api/DataSource/api_data_source.dart';
import '../../Mobile Nomber Verify/Controller/mobile_verify_notifier.dart';

class AppVersionState {
  final String? appVersion;
  final AppVersionResponse? appVersionResponse;
  final DeviceTokenResponse? deviceTokenResponse;
  final bool isSendingToken;
  final String? error;

  const AppVersionState({
    this.appVersion,
    this.appVersionResponse,
    this.deviceTokenResponse,
    this.isSendingToken = false,
    this.error,
  });

  factory AppVersionState.initial() => const AppVersionState();

  AppVersionState copyWith({
    String? appVersion,
    AppVersionResponse? appVersionResponse,
    DeviceTokenResponse? deviceTokenResponse,
    bool? isSendingToken,
    String? error,
  }) {
    return AppVersionState(
      appVersion: appVersion ?? this.appVersion,
      appVersionResponse:
      appVersionResponse ?? this.appVersionResponse,
      deviceTokenResponse:
      deviceTokenResponse ?? this.deviceTokenResponse,
      isSendingToken: isSendingToken ?? this.isSendingToken,
      error: error,
    );
  }
}

class AppVersionNotifier extends Notifier<AppVersionState> {
  late final ApiDataSource api;

  @override
  AppVersionState build() {
    api = ref.read(apiDataSourceProvider);
    return AppVersionState.initial();
  }

  Future<void> getAppVersion({
    required String appName,
    required String appVersion,
    required String appPlatForm,
  }) async {
    final results = await api.getAppVersion(
      appName: appName,
      appVersion: appVersion,
      appPlatForm: appPlatForm,
    );

    results.fold(
          (failure) {
        state = state.copyWith(error: failure.message);
      },
          (response) {
        state = state.copyWith(
          appVersion: response.data?.currentVersion,
          appVersionResponse: response,
          error: null,
        );
      },
    );
  }

  Future<void> fcmTokenSend({
    required String fcmToken,
    required String platform,
    required String deviceId,
  }) async {
    state = state.copyWith(isSendingToken: true, error: null);

    final results = await api.fcmTokenSend(
      deviceId: deviceId,
      fcmToken: fcmToken,
      platform: platform,
    );

    results.fold(
          (failure) {
        state = state.copyWith(
          isSendingToken: false,
          error: failure.message,
        );
      },
          (response) {
        state = state.copyWith(
          isSendingToken: false,
          deviceTokenResponse: response,
          error: null,
        );
      },
    );
  }
}

final appVersionNotifierProvider =
NotifierProvider<AppVersionNotifier, AppVersionState>(
  AppVersionNotifier.new,
);