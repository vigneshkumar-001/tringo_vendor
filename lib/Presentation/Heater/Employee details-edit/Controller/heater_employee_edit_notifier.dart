import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tringo_vendor_new/Core/Const/app_logger.dart';
import 'package:tringo_vendor_new/Presentation/Heater/Add%20Vendor%20Employee/Model/add_employee_response.dart';
import 'package:tringo_vendor_new/Presentation/Heater/Add%20Vendor%20Employee/Model/employee_list_response.dart';

import '../../../../Api/DataSource/api_data_source.dart';

import '../../../../Core/Utility/app_prefs.dart';
import '../../../Login Screen/Controller/login_notifier.dart';
import '../Model/employee_change_number.dart';
import '../Model/employee_unblock_response.dart';
import '../Model/heater_employee_edit_res.dart';
import '../Model/phone_verification_response.dart';

class heaterEmployeeEditState {
  final bool isLoading;
  final bool isBlockLoading;
  final bool isSendingOtp;
  final bool isVerifyingOtp;
  final String? error;
  final EmployeeUpdateResponse? data;
  final EmployeeUpdateResponse? employeeUpdateResponse;
  final EmployeeUnblockResponse? employeeUnblockResponse;
  final EmployeeChangeNumber? employeeChangeNumber;
  final PhoneVerificationResponse? phoneVerificationResponse;

  const heaterEmployeeEditState({
    this.isLoading = false,
    this.isBlockLoading = false,
    this.isSendingOtp = false,
    this.isVerifyingOtp = false,
    this.error,
    this.data,
    this.employeeUpdateResponse,
    this.employeeUnblockResponse,
    this.employeeChangeNumber,
    this.phoneVerificationResponse,
  });

  factory heaterEmployeeEditState.initial() => const heaterEmployeeEditState();

  heaterEmployeeEditState copyWith({
    bool? isLoading,
    bool? isBlockLoading,
    bool? isSendingOtp,
    bool? isVerifyingOtp,

    String? error,
    EmployeeUpdateResponse? data,
    EmployeeUpdateResponse? employeeUpdateResponse,
    EmployeeUnblockResponse? employeeUnblockResponse,
    EmployeeChangeNumber? employeeChangeNumber,
    PhoneVerificationResponse? phoneVerificationResponse,
    bool clearError = false,
  }) {
    return heaterEmployeeEditState(
      isLoading: isLoading ?? this.isLoading,
      isBlockLoading: isBlockLoading ?? this.isBlockLoading,
      isSendingOtp: isSendingOtp ?? this.isSendingOtp,
      isVerifyingOtp: isVerifyingOtp ?? this.isVerifyingOtp,
      error: clearError ? null : (error ?? this.error),
      data: data ?? this.data,
      employeeUpdateResponse:
          employeeUpdateResponse ?? this.employeeUpdateResponse,
      employeeUnblockResponse:
          employeeUnblockResponse ?? this.employeeUnblockResponse,
      employeeChangeNumber: employeeChangeNumber ?? this.employeeChangeNumber,
      phoneVerificationResponse:
          phoneVerificationResponse ?? this.phoneVerificationResponse,
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

    File? aadhaarFile,
    File? ownerImageFile,

    // add these so API always gets String
    String existingAadhaarUrl = "",
    String existingAvatarUrl = "",
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      String aadhaarFinalUrl = existingAadhaarUrl;
      String avatarFinalUrl = existingAvatarUrl;

      if (aadhaarFile != null) {
        final aadhaarUpload = await api.userProfileUpload(
          imageFile: aadhaarFile,
        );
        final aadhaarRes = aadhaarUpload.fold(
          (failure) => throw Exception(failure.message),
          (url) => url,
        );
        aadhaarFinalUrl = aadhaarRes.message;
      }

      if (ownerImageFile != null) {
        final profileUpload = await api.userProfileUpload(
          imageFile: ownerImageFile,
        );
        final profileRes = profileUpload.fold(
          (failure) => throw Exception(failure.message),
          (url) => url,
        );
        avatarFinalUrl = profileRes.message;
      }

      final result = await api.heaterEmployeeEdit(
        employeeId: employeeId,
        phoneNumber: phoneNumber,
        fullName: fullName,
        email: email,
        emergencyContactName: emergencyContactName,
        emergencyContactRelationship: emergencyContactRelationship,
        emergencyContactPhone: emergencyContactPhone,
        aadhaarNumber: aadhaarNumber,
        aadhaarDocumentUrl: aadhaarFinalUrl, // String
        avatarUrl: avatarFinalUrl, // String
      );

      result.fold(
        (failure) =>
            state = state.copyWith(isLoading: false, error: failure.message),
        (response) => state = state.copyWith(isLoading: false, data: response),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // Future<void> editEmployee({
  //   required String employeeId,
  //   required String phoneNumber,
  //   required String fullName,
  //   required String email,
  //   required String emergencyContactName,
  //   required String emergencyContactRelationship,
  //   required String emergencyContactPhone,
  //   required String aadhaarNumber,
  //
  //   required File aadhaarFile,
  //   required File ownerImageFile,
  // }) async {
  //   state = state.copyWith(isLoading: true, clearError: true);
  //
  //   final aadhaarUpload = await api.userProfileUpload(imageFile: aadhaarFile);
  //   final aadhaarUrl = aadhaarUpload.fold(
  //     (failure) => throw Exception(failure.message),
  //     (url) => url,
  //   );
  //
  //   final profileUpload = await api.userProfileUpload(
  //     imageFile: ownerImageFile,
  //   );
  //   final profileUrl = profileUpload.fold(
  //     (failure) => throw Exception(failure.message),
  //     (url) => url,
  //   );
  //
  //   final result = await api.heaterEmployeeEdit(
  //     employeeId: employeeId,
  //     phoneNumber: phoneNumber,
  //     fullName: fullName,
  //     email: email,
  //     emergencyContactName: emergencyContactName,
  //     emergencyContactRelationship: emergencyContactRelationship,
  //     emergencyContactPhone: emergencyContactPhone,
  //     aadhaarNumber: aadhaarNumber,
  //     aadhaarDocumentUrl: aadhaarUrl.message,
  //     avatarUrl: profileUrl.message,
  //   );
  //
  //   result.fold(
  //     (failure) {
  //       state = state.copyWith(isLoading: false, error: failure.message);
  //     },
  //     (response) {
  //       state = state.copyWith(isLoading: false, data: response);
  //     },
  //   );
  // }

  Future<void> unblockEmployee({required String employeeId}) async {
    state = state.copyWith(isBlockLoading: true, clearError: true);

    final result = await api.employeeUnblock(employeeId: employeeId);

    result.fold(
      (failure) {
        state = state.copyWith(isBlockLoading: false, error: failure.message);
      },
      (response) {
        state = state.copyWith(
          isBlockLoading: false,
          employeeUnblockResponse: response,
        );
      },
    );
  }

  Future<void> blockEmployee({
    required String employeeId,
    String? reason,
  }) async {
    state = state.copyWith(isBlockLoading: true, clearError: true);

    final result = await api.employeeBlock(
      employeeId: employeeId,
      reason: reason,
    );

    result.fold(
      (failure) =>
          state = state.copyWith(isBlockLoading: false, error: failure.message),
      (response) =>
          state = state.copyWith(
            isBlockLoading: false,
            employeeUnblockResponse: response,
          ),
    );
  }

  Future<bool> employeeUpdateNumberRequest({
    required String phoneNumber,
  }) async {
    if (state.isSendingOtp) return false;

    state = state.copyWith(isSendingOtp: true, error: null);

    try {
      final result = await api.employeeUpdateNumberRequest(phone: phoneNumber);

      return result.fold(
        (failure) {
          state = state.copyWith(isSendingOtp: false, error: failure.message);
          return false;
        },
        (response) {
          state = state.copyWith(
            isSendingOtp: false,
            employeeChangeNumber: response,
          );
          return true;
        },
      );
    } catch (e) {
      state = state.copyWith(isSendingOtp: false, error: e.toString()); // reset
      return false;
    }
  }

  // Future<bool> employeeUpdateNumberRequest({
  //   required String phoneNumber,
  // }) async {
  //   if (state.isSendingOtp) return false;
  //
  //   state = state.copyWith(isSendingOtp: true, error: null);
  //
  //   final result = await api.employeeUpdateNumberRequest(phone: phoneNumber);
  //
  //   return result.fold(
  //     (failure) {
  //       state = state.copyWith(isSendingOtp: false, error: failure.message);
  //       return false;
  //     },
  //     (response) {
  //       state = state.copyWith(
  //         isSendingOtp: false,
  //         employeeChangeNumber: response,
  //       );
  //       return true;
  //     },
  //   );
  //
  // }
  //

  Future<bool> employeeUpdateOtpRequest({
    required String phoneNumber,
    required String code,
  }) async {
    if (state.isVerifyingOtp) return false;

    state = state.copyWith(isVerifyingOtp: true, error: null);

    final result = await api.employeeUpdateOtpRequest(
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
          phoneVerificationResponse: response,
        );
        return true;
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
