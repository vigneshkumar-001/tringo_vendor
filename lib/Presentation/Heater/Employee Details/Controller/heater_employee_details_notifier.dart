import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tringo_vendor_new/Presentation/Heater/Add%20Vendor%20Employee/Model/add_employee_response.dart';
import 'package:tringo_vendor_new/Presentation/Heater/Add%20Vendor%20Employee/Model/employee_list_response.dart';

import '../../../../Api/DataSource/api_data_source.dart';


import '../../../Login Screen/Controller/login_notifier.dart';
import '../Model/employeeDetailsResponse.dart';

class heaterEmployeeDetailsState {
  final bool isLoading;
  final String? error;
  final EmployeeDetailsResponse? employeeDetailsResponse;

  const heaterEmployeeDetailsState({
    this.isLoading = false,
    this.error,
    this.employeeDetailsResponse,
  });

  factory heaterEmployeeDetailsState.initial() =>
      const heaterEmployeeDetailsState();

  heaterEmployeeDetailsState copyWith({
    bool? isLoading,
    String? error,
    EmployeeDetailsResponse? employeeDetailsResponse,
    bool clearError = false,
  }) {
    return heaterEmployeeDetailsState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      employeeDetailsResponse:
          employeeDetailsResponse ?? this.employeeDetailsResponse,
    );
  }
}

class HeaterEmployeeDetailsNotifier
    extends Notifier<heaterEmployeeDetailsState> {
  late final ApiDataSource api;

  @override
  heaterEmployeeDetailsState build() {
    api = ref.read(apiDataSourceProvider);
    return heaterEmployeeDetailsState.initial();
  }

  Future<void> heaterEmployee({required String employeeId}) async {
    state = state.copyWith(isLoading: true, employeeDetailsResponse: null);

    final result = await api.heaterEmployeeDetails(employeeId: employeeId);

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
          employeeDetailsResponse: null,
        );
      },
      (response) {
        state = state.copyWith(
          isLoading: false,
          error: null,
          employeeDetailsResponse: response,
        );
      },
    );
  }

  void resetState() {
    state = heaterEmployeeDetailsState.initial();
  }
}

final heaterEmployeeDetailsNotifier =
    NotifierProvider<HeaterEmployeeDetailsNotifier, heaterEmployeeDetailsState>(
      HeaterEmployeeDetailsNotifier.new,
    );
