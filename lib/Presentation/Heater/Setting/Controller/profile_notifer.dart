import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tringo_vendor_new/Core/Const/app_logger.dart';
import 'package:tringo_vendor_new/Presentation/Heater/History/Model/vendor_history_response.dart';
import 'package:tringo_vendor_new/Presentation/Heater/Setting/Model/get_profile_response.dart';
import '../../../../Api/DataSource/api_data_source.dart';
import '../../../Login Screen/Controller/login_notifier.dart';

class ProfileState {
  final bool isLoading;

  final String? error;
  final GetProfileResponse? getProfileResponse;

  const ProfileState({
    this.isLoading = false,
    this.error,
    this.getProfileResponse,
  });

  factory ProfileState.initial() => const ProfileState();

  ProfileState copyWith({
    bool? isLoading,
    GetProfileResponse? getProfileResponse,
    String? error,

    bool clearError = false,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      getProfileResponse: getProfileResponse ?? this.getProfileResponse,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class ProfileNotifer extends Notifier<ProfileState> {
  late final ApiDataSource api;

  @override
  ProfileState build() {
    api = ref.read(apiDataSourceProvider);
    return ProfileState.initial();
  }

  Future<void> getProfile({bool silent = false}) async {
    if (!silent) {
      state = state.copyWith(isLoading: silent, clearError: true);
    }

    try {
      final result = await api.getProfile();

      result.fold(
        (failure) {
          if (!silent) {
            state = state.copyWith(
              isLoading: silent,
              error: failure.message ?? 'Something went wrong',
            );
          }
        },
        (response) {
          state = state.copyWith(
            isLoading: silent,
            getProfileResponse: response,
            clearError: true,
          );
        },
      );
    } catch (e) {
      AppLogger.log.e(e);
      if (!silent) {
        state = state.copyWith(isLoading: silent, error: e.toString());
      }
    }
  }
}

final profileNotifierProvider = NotifierProvider<ProfileNotifer, ProfileState>(
  ProfileNotifer.new,
);
