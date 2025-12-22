import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:tringo_vendor_new/Api/DataSource/api_data_source.dart';
import 'package:tringo_vendor_new/Core/Const/app_logger.dart';
import 'package:tringo_vendor_new/Core/Utility/app_prefs.dart';
import 'package:tringo_vendor_new/Presentation/Login%20Screen/Model/login_response.dart';

import '../../Login Screen/Controller/login_notifier.dart';
import '../Model/owner_otp_response.dart';
import '../Model/owner_register_response.dart' show OwnerRegisterResponse;

class OwnerInfoState {
  final bool isLoading;
  final bool isSendingOtp;
  final bool isVerifyingOtp;
  final LoginResponse? loginResponse;
  final OwnerOtpResponse? ownerOtpResponse;
  final OwnerRegisterResponse? ownerRegisterResponse;
  final String? error;

  const OwnerInfoState({
    this.isLoading = false,
    this.isSendingOtp = false,
    this.isVerifyingOtp = false,
    this.error,
    this.loginResponse,
    this.ownerOtpResponse,
    this.ownerRegisterResponse,
  });

  factory OwnerInfoState.initial() => const OwnerInfoState();

  OwnerInfoState copyWith({
    bool? isLoading,
    bool? isSendingOtp,
    bool? isVerifyingOtp,
    LoginResponse? loginResponse,
    OwnerOtpResponse? ownerOtpResponse,
    OwnerRegisterResponse? ownerRegisterResponse,
    String? error,
  }) {
    return OwnerInfoState(
      error: error,
      isLoading: isLoading ?? this.isLoading,
      isSendingOtp: isSendingOtp ?? this.isSendingOtp,
      isVerifyingOtp: isVerifyingOtp ?? this.isVerifyingOtp,
      loginResponse: loginResponse ?? this.loginResponse,
      ownerOtpResponse: ownerOtpResponse ?? this.ownerOtpResponse,
      ownerRegisterResponse:
          ownerRegisterResponse ?? this.ownerRegisterResponse,
    );
  }
}

class OwnerInfoNotifier extends Notifier<OwnerInfoState> {
  late final ApiDataSource api;

  bool _isRequestingOtp = false;
  bool _isVerifyingOtp = false;

  @override
  OwnerInfoState build() {
    api = ref.read(apiDataSourceProvider);
    return OwnerInfoState.initial();
  }

  void resetState() {
    _isRequestingOtp = false;

    state = OwnerInfoState.initial();
  }
  Future<String?> ownerInfoNumberRequest({
    required String phoneNumber,
  }) async {
    if (state.isSendingOtp) return "OTP_ALREADY_SENDING";

    state = state.copyWith(isSendingOtp: true, error: null);

    final result = await api.ownerInfoNumberRequest(phone: phoneNumber);

    return result.fold(
          (failure) {
        state = state.copyWith(
          isSendingOtp: false,
          error: failure.message,
        );
        return failure.message;
      },
          (response) {
        state = state.copyWith(
          isSendingOtp: false,
          loginResponse: response,
        );
        return null; //  success
      },
    );
  }

  Future<bool> ownerInfoOtpRequest({
    required String phoneNumber,
    required String code,
  }) async {
    if (state.isVerifyingOtp) return false;

    state = state.copyWith(isVerifyingOtp: true, error: null);

    final result = await api.ownerInfoOtpRequest(
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
          ownerOtpResponse: response,
        );
        return true;
      },
    );
  }

  Future<bool> ownerInfoRegister({
    required String businessType,
    required String ownershipType,
    required String govtRegisteredName,
    required String preferredLanguage,
    required String gender,
    required String dateOfBirth,
    required String fullName,
    required String ownerNameTamil,
    required String email,
    required String ownerPhoneNumber,
  }) async {
    if (state.isVerifyingOtp) return false;

    state = state.copyWith(isLoading: true, error: null);

    final result = await api.ownerInfoRegister(
      businessType: businessType,
      ownershipType: ownershipType,
      govtRegisteredName: govtRegisteredName,
      preferredLanguage: preferredLanguage,
      gender: gender,
      dateOfBirth: dateOfBirth,
      fullName: fullName,
      ownerNameTamil: ownerNameTamil,
      email: email,
      ownerPhoneNumber: ownerPhoneNumber,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (response) async {
        final data = response.data;

        // await prefs.setString('refreshToken', data?.refreshToken ?? '');
        // await prefs.setString('sessionToken', data?.sessionToken ?? '');
        // await prefs.setString('role', data?.role ?? '');
        state = state.copyWith(
          isLoading: false,
          ownerRegisterResponse: response,
        );
        return true;
      },
    );
  }



}

final ownerInfoNotifierProvider =
    NotifierProvider<OwnerInfoNotifier, OwnerInfoState>(OwnerInfoNotifier.new);
