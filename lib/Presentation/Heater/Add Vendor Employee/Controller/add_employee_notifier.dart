import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tringo_vendor_new/Presentation/Heater/Add%20Vendor%20Employee/Model/add_employee_response.dart';
import 'package:tringo_vendor_new/Presentation/Heater/Add%20Vendor%20Employee/Model/employee_list_response.dart';

import '../../../../Api/DataSource/api_data_source.dart';
import '../../../Login Screen/Controllre/login_notifier.dart';

class AddEmployeeState {
  final bool isLoading;
  final String? error;
  final AddEmployeeResponse? addEmployeeResponse;
  final EmployeeListResponse? employeeListResponse;

  const AddEmployeeState({
    this.isLoading = false,
    this.error,
    this.addEmployeeResponse,
    this.employeeListResponse,
  });

  factory AddEmployeeState.initial() => const AddEmployeeState();

  AddEmployeeState copyWith({
    bool? isLoading,
    String? error,
    AddEmployeeResponse? addEmployeeResponse,
    EmployeeListResponse? employeeListResponse,
    bool clearError = false,
  }) {
    return AddEmployeeState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      addEmployeeResponse: addEmployeeResponse ?? this.addEmployeeResponse,
      employeeListResponse: employeeListResponse ?? this.employeeListResponse,
    );
  }
}

class AddEmployeeNotifier extends Notifier<AddEmployeeState> {
  late final ApiDataSource api;

  @override
  AddEmployeeState build() {
    api = ref.read(apiDataSourceProvider);
    return AddEmployeeState.initial();
  }

  Future<void> addEmployeeVendor({
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
    try {
      state = state.copyWith(isLoading: true, clearError: true);

      // ----------------------
      // STEP 1: UPLOAD AADHAAR
      // ----------------------
      final aadhaarUpload = await api.userProfileUpload(imageFile: aadhaarFile);
      final aadhaarUrl = aadhaarUpload.fold(
        (failure) => throw Exception(failure.message),
        (url) => url,
      );

      // ----------------------
      // STEP 2: UPLOAD PROFILE IMAGE
      // ----------------------
      final profileUpload = await api.userProfileUpload(
        imageFile: ownerImageFile,
      );
      final profileUrl = profileUpload.fold(
        (failure) => throw Exception(failure.message),
        (url) => url,
      );

      // ----------------------
      // STEP 3: CALL CREATE API
      // ----------------------
      final result = await api.addEmployee(
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
          state = state.copyWith(
            isLoading: false,
            error: failure.message ?? "Something went wrong",
          );
        },
        (vendor) {
          state = state.copyWith(
            isLoading: false,
            addEmployeeResponse: vendor,
            clearError: true,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> getEmployeeList({bool silent = false}) async {
    if (!silent) {
      state = state.copyWith(isLoading: true, clearError: true);
    }

    try {
      final result = await api.getEmployeeList();

      result.fold(
        (failure) {
          if (!silent) {
            state = state.copyWith(
              isLoading: false,
              error: failure.message ?? 'Something went wrong',
            );
          }
        },
        (response) {
          state = state.copyWith(
            isLoading: false,
            employeeListResponse: response,
            clearError: true,
          );
        },
      );
    } catch (e) {
      if (!silent) {
        state = state.copyWith(isLoading: false, error: e.toString());
      }
    }
  }

  // Future<void> getEmployeeList( ) async {
  //   state = state.copyWith(isLoading: true, employeeListResponse: null);
  //
  //   final result = await api.getEmployeeList( );
  //
  //   result.fold(
  //         (failure) {
  //       state = state.copyWith(isLoading: false, employeeListResponse: null);
  //     },
  //         (response) {
  //       state = state.copyWith(isLoading: false, employeeListResponse: response);
  //     },
  //   );
  // }

  void resetState() {
    state = AddEmployeeState.initial();
  }
}

final addEmployeeNotifier =
    NotifierProvider.autoDispose<AddEmployeeNotifier, AddEmployeeState>(
      AddEmployeeNotifier.new,
    );
