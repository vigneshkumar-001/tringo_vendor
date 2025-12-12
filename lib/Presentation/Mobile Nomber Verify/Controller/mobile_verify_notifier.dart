import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tringo_vendor_new/Core/Const/app_logger.dart';

import '../../../Api/DataSource/api_data_source.dart';
import '../Model/sim_verify_response.dart';
import 'mobile_verify_notifier.dart';

class mobileVerifyState {
  final bool isLoading;
  final SimVerifyResponse? simVerifyResponse;
  final String? error;

  const mobileVerifyState({
    this.isLoading = false,
    this.simVerifyResponse,
    this.error,
  });

  factory mobileVerifyState.initial() => const mobileVerifyState();

  mobileVerifyState copyWith({
    bool? isLoading,
    SimVerifyResponse? simVerifyResponse,
    String? error,
  }) {
    return mobileVerifyState(
      isLoading: isLoading ?? this.isLoading,
      simVerifyResponse: simVerifyResponse ?? this.simVerifyResponse,
      error: error,
    );
  }
}

class MobileVerifyNotifier extends Notifier<mobileVerifyState> {
  late final ApiDataSource api;

  @override
  mobileVerifyState build() {
    api = ref.read(apiDataSourceProvider);
    return mobileVerifyState.initial();
  }

  Future<void> mobileVerify({
    required String contact,
    required String simToken,
    required String purpose,
  }) async {
    state = const mobileVerifyState(isLoading: true);

    final result = await api.mobileVerify(
      contact: contact,
      purpose: purpose,
      simToken: simToken,
    );

    result.fold(
          (failure) {
        state = mobileVerifyState(isLoading: false, error: failure.message);
      },
          (response) async {
        state = mobileVerifyState(
          isLoading: false,
          simVerifyResponse: response,
        );
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', response.data.accessToken ?? '');
        await prefs.setString('refreshToken', response.data.refreshToken ?? '');
        await prefs.setString('sessionToken', response.data.sessionToken ?? '');
        await prefs.setString('role', response.data.role ?? '');
        //  Print what was actually stored
        final accessToken = prefs.getString('token');
        final refreshToken = prefs.getString('refreshToken');
        final sessionToken = prefs.getString('sessionToken');
        final role = prefs.getString('role');
        AppLogger.log.i(' SharedPreferences stored successfully:');
        AppLogger.log.i('token → $accessToken');
        AppLogger.log.i('refreshToken → $refreshToken');
        AppLogger.log.i('sessionToken → $sessionToken');
        AppLogger.log.i('role → $role');
      },
    );
  }
}

final mobileVerifyProvider =
NotifierProvider<MobileVerifyNotifier, mobileVerifyState>(
  MobileVerifyNotifier.new,
);

final apiDataSourceProvider = Provider<ApiDataSource>((ref) {
  return ApiDataSource();
});
