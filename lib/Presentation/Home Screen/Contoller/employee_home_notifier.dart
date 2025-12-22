import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../Api/DataSource/api_data_source.dart';
import '../../Login Screen/Controller/login_notifier.dart';
import '../Model/employee_home_response.dart';

class employeeHomeState {
  final bool isLoading;
  final String? error;
  final EmployeeHomeResponse? employeeHomeResponse;

  const employeeHomeState({
    this.isLoading = false,
    this.error,
    this.employeeHomeResponse,
  });

  factory employeeHomeState.initial() => const employeeHomeState();

  employeeHomeState copyWith({
    bool? isLoading,
    String? error,
    EmployeeHomeResponse? employeeHomeResponse,
    bool clearError = false,
  }) {
    return employeeHomeState(
      isLoading: isLoading ?? this.isLoading,
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
    state = state.copyWith(isLoading: true, employeeHomeResponse: null);

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
}

final employeeHomeNotifier =
    NotifierProvider<EmployeeHomeNotifier, employeeHomeState>(
      EmployeeHomeNotifier.new,
    );
