import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../Api/DataSource/api_data_source.dart';
import '../../Login Screen/Controller/login_notifier.dart';
import '../Model/employee_home_response.dart';

class employeeHomeState {
  final bool isLoading;
  final bool isDeletingOwner;
  final String? error;
  final EmployeeHomeResponse? employeeHomeResponse;

  const employeeHomeState({
    this.isLoading = false,
    this.isDeletingOwner = false,
    this.error,
    this.employeeHomeResponse,
  });

  factory employeeHomeState.initial() => const employeeHomeState();

  employeeHomeState copyWith({
    bool? isLoading,
    bool? isDeletingOwner,
    String? error,
    EmployeeHomeResponse? employeeHomeResponse,
    bool clearError = false,
  }) {
    return employeeHomeState(
      isLoading: isLoading ?? this.isLoading,
      isDeletingOwner: isDeletingOwner ?? this.isDeletingOwner,
      error: clearError ? null : (error ?? this.error),
      employeeHomeResponse: employeeHomeResponse ?? this.employeeHomeResponse,
    );
  }
}

class EmployeeHomeNotifier extends Notifier<employeeHomeState> {
  late final ApiDataSource api;

  @override
  employeeHomeState build() {
    api = ref.read(apiDataSourceProvider);
    return employeeHomeState.initial();
  }

  Future<void> employeeHome({
    required String date,
    required String page,
    required String limit,
    required String q,
  }) async {
    state = state.copyWith(
      isLoading: true,
      employeeHomeResponse: null,
      clearError: true,
    );

    final result = await api.employeeHome(
      date: date,
      page: page,
      limit: limit,
      q: q,
    );

    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, employeeHomeResponse: null);
      },
      (response) {
        state = state.copyWith(
          isLoading: false,
          employeeHomeResponse: response,
        );
      },
    );
  }

  void resetState() {
    state = employeeHomeState.initial();
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  Future<String?> deletePendingOwnerOnboarding({
    required String ownerUserId,
  }) async {
    if (state.isDeletingOwner) return 'DELETE_IN_PROGRESS';
    state = state.copyWith(isDeletingOwner: true, clearError: true);

    final result = await api.deletePendingOwnerOnboarding(
      ownerUserId: ownerUserId,
    );

    return result.fold(
      (failure) {
        // Don't set `error` here; HomeScreen shows a full-page error UI when
        // `error` is not null. Delete failures should be handled via snackbar
        // while keeping the existing dashboard visible.
        state = state.copyWith(isDeletingOwner: false);
        return failure.message;
      },
      (message) {
        state = state.copyWith(isDeletingOwner: false);
        return null;
      },
    );
  }
}

final employeeHomeNotifier =
    NotifierProvider<EmployeeHomeNotifier, employeeHomeState>(
      EmployeeHomeNotifier.new,
    );
