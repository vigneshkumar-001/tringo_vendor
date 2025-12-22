import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tringo_vendor_new/Core/Const/app_logger.dart';
import 'package:tringo_vendor_new/Presentation/Heater/Add%20Vendor%20Employee/Model/add_employee_response.dart';
import 'package:tringo_vendor_new/Presentation/Heater/Add%20Vendor%20Employee/Model/employee_list_response.dart';

import '../../../../Api/DataSource/api_data_source.dart';
import '../../../../Core/Utility/app_prefs.dart';
import '../../../Login Screen/Controller/login_notifier.dart';
import '../Model/masked_contact_response.dart';
import '../Model/verification_response.dart';

class AddEmployeeState {
  final bool isLoading;
  final String? error;
  final bool isSuccess;
  final bool isSendingOtp;
  final bool isVerifyingOtp;
  final AddEmployeeResponse? addEmployeeResponse;
  final EmployeeListResponse? employeeListResponse;
  final MaskedContactResponse? maskedContactResponse;
  final VerificationResponse? verificationResponse;

  const AddEmployeeState({
    this.isLoading = false,
    this.isSendingOtp = false,
    this.isVerifyingOtp = false,
    this.error,
    this.isSuccess = false,
    this.addEmployeeResponse,
    this.employeeListResponse,
    this.maskedContactResponse,
    this.verificationResponse,
  });

  factory AddEmployeeState.initial() => const AddEmployeeState();

  AddEmployeeState copyWith({
    bool? isLoading,
    bool? isSendingOtp,
    bool? isVerifyingOtp,
    String? error,
    AddEmployeeResponse? addEmployeeResponse,
    EmployeeListResponse? employeeListResponse,
    MaskedContactResponse? maskedContactResponse,
    VerificationResponse? verificationResponse,
    bool clearError = false,
  }) {
    return AddEmployeeState(
      isLoading: isLoading ?? this.isLoading,
      isSendingOtp: isSendingOtp ?? this.isSendingOtp,
      isVerifyingOtp: isVerifyingOtp ?? this.isVerifyingOtp,
      error: clearError ? null : (error ?? this.error),
      addEmployeeResponse: addEmployeeResponse ?? this.addEmployeeResponse,
      employeeListResponse: employeeListResponse ?? this.employeeListResponse,
      maskedContactResponse:
          maskedContactResponse ?? this.maskedContactResponse,
      verificationResponse: verificationResponse ?? this.verificationResponse,
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

  Future<String?> employeeAddNumberRequest({
    required String phoneNumber,
  }) async {
    if (state.isSendingOtp) return "OTP_ALREADY_SENDING";

    state = state.copyWith(isSendingOtp: true, error: null);

    final result = await api.employeeAddNumberRequest(phone: phoneNumber);

    return result.fold(
      (failure) {
        state = state.copyWith(isSendingOtp: false, error: failure.message);
        return failure.message;
      },
      (response) {
        state = state.copyWith(
          isSendingOtp: false,
          maskedContactResponse: response,
        );
        return null;
      },
    );
  }

  Future<bool> employeeAddOtpRequest({
    required String phoneNumber,
    required String code,
  }) async {
    if (state.isVerifyingOtp) return false;

    state = state.copyWith(isVerifyingOtp: true, error: null);

    final result = await api.employeeAddOtpRequest(
      phone: phoneNumber,
      code: code,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(isVerifyingOtp: false, error: failure.message);
        return false;
      },
      (response) async {
        final data = response.data;

        await AppPrefs.setVerificationToken(data?.verificationToken ?? '');
        final verification = await AppPrefs.getVerificationToken();
        AppLogger.log.i('verification Token → $verification');

        // await prefs.setString('refreshToken', data?.refreshToken ?? '');
        // await prefs.setString('sessionToken', data?.sessionToken ?? '');
        // await prefs.setString('role', data?.role ?? '');
        state = state.copyWith(
          isVerifyingOtp: false,
          verificationResponse: response,
        );
        return true;
      },
    );
  }

  void resetState() {
    state = AddEmployeeState.initial();
  }
}

final addEmployeeNotifier =
    NotifierProvider.autoDispose<AddEmployeeNotifier, AddEmployeeState>(
      AddEmployeeNotifier.new,
    );
