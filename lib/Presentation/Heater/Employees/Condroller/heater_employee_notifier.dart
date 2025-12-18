import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tringo_vendor_new/Presentation/Heater/Add%20Vendor%20Employee/Model/add_employee_response.dart';
import 'package:tringo_vendor_new/Presentation/Heater/Add%20Vendor%20Employee/Model/employee_list_response.dart';

import '../../../../Api/DataSource/api_data_source.dart';


import '../../../Login Screen/Controller/login_notifier.dart';
import '../Model/heater_employee_response.dart';

class heaterEmployeeState {
  final bool isLoading;
  final String? error;
  final HeaterEmployeeResponse? heaterEmployeeResponse;

  const heaterEmployeeState({
    this.isLoading = false,
    this.error,
    this.heaterEmployeeResponse,
  });

  factory heaterEmployeeState.initial() => const heaterEmployeeState();

  heaterEmployeeState copyWith({
    bool? isLoading,
    String? error,
    HeaterEmployeeResponse? heaterEmployeeResponse,
    bool clearError = false,
  }) {
    return heaterEmployeeState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      heaterEmployeeResponse:
      heaterEmployeeResponse ?? this.heaterEmployeeResponse,
    );
  }
}

class HeaterEmployeeNotifier extends Notifier<heaterEmployeeState> {
  late final ApiDataSource api;

  @override
  heaterEmployeeState build() {
    api = ref.read(apiDataSourceProvider);
    return heaterEmployeeState.initial();
  }

  Future<void> heaterEmployee() async {
    state = state.copyWith(isLoading: true, heaterEmployeeResponse: null);

    final result = await api.heaterEmployee();

    result.fold(
          (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
          heaterEmployeeResponse: null,
        );
      },
          (response) {
        state = state.copyWith(
          isLoading: false,
          error: null,
          heaterEmployeeResponse: response,
        );
      },
    );
  }

  void resetState() {
    state = heaterEmployeeState.initial();
  }
}

final heaterEmployeeNotifier =
NotifierProvider<HeaterEmployeeNotifier, heaterEmployeeState>(
  HeaterEmployeeNotifier.new,
);
