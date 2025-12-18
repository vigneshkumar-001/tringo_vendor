import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tringo_vendor_new/Presentation/Heater/Add%20Vendor%20Employee/Model/add_employee_response.dart';
import 'package:tringo_vendor_new/Presentation/Heater/Add%20Vendor%20Employee/Model/employee_list_response.dart';

import '../../../../Api/DataSource/api_data_source.dart';


import '../../../Login Screen/Controller/login_notifier.dart';
import '../Model/heater_employee_edit_res.dart';

class heaterEmployeeEditState {
  final bool isLoading;
  final String? error;
  final EmployeeUpdateResponse? data;
  final EmployeeUpdateResponse? employeeUpdateResponse;

  const heaterEmployeeEditState({
    this.isLoading = false,
    this.error,
    this.data,
    this.employeeUpdateResponse,
  });

  factory heaterEmployeeEditState.initial() => const heaterEmployeeEditState();

  heaterEmployeeEditState copyWith({
    bool? isLoading,
    String? error,
    EmployeeUpdateResponse? data,
    EmployeeUpdateResponse? employeeUpdateResponse,
    bool clearError = false,
  }) {
    return heaterEmployeeEditState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      data: data ?? this.data,
      employeeUpdateResponse:
          employeeUpdateResponse ?? this.employeeUpdateResponse,
    );
  }
}

class HeaterEmployeeEditNotifier extends Notifier<heaterEmployeeEditState> {
  late final ApiDataSource api;

  @override
  heaterEmployeeEditState build() {
    api = ref.read(apiDataSourceProvider);
    return heaterEmployeeEditState.initial();
  }

  Future<void> editEmployee({
    required String employeeId,
    required String phoneNumber,
    required String fullName,
    required String email,
    required String emergencyContactName,
    required String emergencyContactRelationship,
    required String emergencyContactPhone,
    required String aadhaarNumber,

    required File aadhaarFile,
    required File ownerImageFile,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final aadhaarUpload = await api.userProfileUpload(imageFile: aadhaarFile);
    final aadhaarUrl = aadhaarUpload.fold(
      (failure) => throw Exception(failure.message),
      (url) => url,
    );

    final profileUpload = await api.userProfileUpload(
      imageFile: ownerImageFile,
    );
    final profileUrl = profileUpload.fold(
      (failure) => throw Exception(failure.message),
      (url) => url,
    );

    final result = await api.heaterEmployeeEdit(
      employeeId: employeeId,
      phoneNumber: phoneNumber,
      fullName: fullName,
      email: email,
      emergencyContactName: emergencyContactName,
      emergencyContactRelationship: emergencyContactRelationship,
      emergencyContactPhone: emergencyContactPhone,
      aadhaarNumber: aadhaarNumber,
      aadhaarDocumentUrl: aadhaarUrl.message,
      avatarUrl: profileUrl.message,
    );

    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
      },
      (response) {
        state = state.copyWith(isLoading: false, data: response);
      },
    );
  }

  void reset() {
    state = heaterEmployeeEditState.initial();
  }
}

final heaterEmployeeEditNotifier =
    NotifierProvider<HeaterEmployeeEditNotifier, heaterEmployeeEditState>(
      HeaterEmployeeEditNotifier.new,
    );
