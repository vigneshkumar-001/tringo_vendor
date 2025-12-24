import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tringo_vendor_new/Presentation/Login%20Screen/Model/app_version_response.dart';

import '../../../Api/DataSource/api_data_source.dart';
import '../../Mobile Nomber Verify/Controller/mobile_verify_notifier.dart';

class AppVersionState {
  final String? appVersion;
  final AppVersionResponse? appVersionResponse;

  const AppVersionState({this.appVersion, this.appVersionResponse});

  factory AppVersionState.initial() => AppVersionState();
}

class AppVersionNotifier extends Notifier<AppVersionState> {
  late final ApiDataSource api;
  @override
  AppVersionState build() {
    api = ref.read(apiDataSourceProvider);
    return AppVersionState();
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
    results.fold((failure) {}, (response) {
      state = AppVersionState(
        appVersion: response.data?.currentVersion,
        appVersionResponse: response,
      );
    });
  }
}

final appVersionNotifierProvider =
NotifierProvider<AppVersionNotifier, AppVersionState>(
  AppVersionNotifier.new,
);
