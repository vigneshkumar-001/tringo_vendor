import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../Api/DataSource/api_data_source.dart';
import '../../../../Core/Utility/app_prefs.dart';
import '../../../Login Screen/Controller/login_notifier.dart';
import '../../../ShopInfo/Model/shop_number_otp_response.dart';
import '../../../ShopInfo/Model/shop_number_verify_response.dart';
import '../Model/vendorResponse.dart';

class HeaterRegisterState {
  final bool isLoading;
  final String? error;
  final bool isSendingOtp;
  final bool isVerifyingOtp;
  final VendorResponse? vendorResponse;
  final ShopNumberVerifyResponse? shopNumberVerifyResponse;
  final ShopNumberOtpResponse? shopNumberOtpResponse;

  const HeaterRegisterState({
    this.isLoading = false,
    this.error,
    this.isSendingOtp = false,
    this.isVerifyingOtp = false,
    this.vendorResponse,
    this.shopNumberVerifyResponse,
    this.shopNumberOtpResponse,
  });

  factory HeaterRegisterState.initial() => const HeaterRegisterState();

  HeaterRegisterState copyWith({
    bool? isLoading,
    String? error,
    bool? isSendingOtp,
    bool? isVerifyingOtp,
    VendorResponse? vendorResponse,
    ShopNumberVerifyResponse? shopNumberVerifyResponse,
    ShopNumberOtpResponse? shopNumberOtpResponse,
    bool clearError = false,
  }) {
    return HeaterRegisterState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      isSendingOtp: isSendingOtp ?? this.isSendingOtp,
      isVerifyingOtp: isVerifyingOtp ?? this.isVerifyingOtp,
      vendorResponse: vendorResponse ?? this.vendorResponse,
      shopNumberVerifyResponse:
          shopNumberVerifyResponse ?? this.shopNumberVerifyResponse,
      shopNumberOtpResponse:
          shopNumberOtpResponse ?? this.shopNumberOtpResponse,
    );
  }
}

class HeaterRegisterNotifier extends Notifier<HeaterRegisterState> {
  late final ApiDataSource api;

    String _onlyIndian10(String input) {
      var p = input.trim();
      p = p.replaceAll(RegExp(r'[^0-9]'), '');
      if (p.startsWith('91') && p.length == 12) p = p.substring(2);
      if (p.length > 10) p = p.substring(p.length - 10);
      return p;
    }

  @override
  HeaterRegisterState build() {
    api = ref.read(apiDataSourceProvider);
    return HeaterRegisterState.initial();
  }

  void resetState() {
    state = HeaterRegisterState.initial();
  }


  Future<void> registerVendor({
    required VendorRegisterScreen screen,

    required String vendorName,
    required String vendorNameTamil,
    required String phoneNumber,
    required String email,
    required String dateOfBirth,
    required String gender,
    required String aadharNumber,
    required String aadharDocumentUrl,

    required String bankAccountNumber,
    required String bankName,
    required String bankAccountName,
    required String bankBranch,
    required String bankIfsc,

    required String companyName,
    required String companyAddress,
    required String gpsLatitude,
    required String gpsLongitude,
    required String primaryCity,
    required String primaryState,
    required String companyContactNumber,
    String? companyContactVerificationToken,
    required String alternatePhone,
    required String companyEmail,
    required String gstNumber,

    File? aadhaarFile,
    File? avatarFile,
    String? avatarUrl,
  }) async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);



      final alternatePhone10 = _onlyIndian10(alternatePhone);

      // ✅ IMPORTANT: Screen3 token must match verified phone
      if (screen == VendorRegisterScreen.screen3) {
        final savedToken = await AppPrefs.getVerificationToken();
        final savedPhone = await AppPrefs.getVerifiedCompanyPhone();

        if (savedToken == null || savedToken.isEmpty) {
          state = state.copyWith(
            isLoading: false,
            error: "Please verify OTP for company phone",
          );
          return;
        }

        if (savedPhone == null || savedPhone != companyContactNumber) {
          state = state.copyWith(
            isLoading: false,
            error: "Phone changed. Please verify OTP again",
          );
          return;
        }

        // use saved token (safer)
        companyContactVerificationToken = savedToken;
      }

      // upload aadhaar
      String finalAadhaarUrl = aadharDocumentUrl;
      if (aadhaarFile != null) {
        final upload = await api.userProfileUpload(imageFile: aadhaarFile);
        finalAadhaarUrl = upload.fold(
              (failure) => throw Exception(failure.message),
              (res) => res.message,
        );
      }

      // upload avatar
      String finalAvatarUrl = avatarUrl ?? '';
      if (avatarFile != null) {
        final uploadAvatar = await api.userProfileUpload(imageFile: avatarFile);
        finalAvatarUrl = uploadAvatar.fold(
              (failure) => throw Exception(failure.message),
              (res) => res.message,
        );
      }

      final result = await api.heaterRegister(
        screen: screen,

        vendorName: vendorName,
        vendorNameTamil: vendorNameTamil,
        phoneNumber: phoneNumber,
        email: email,
        dateOfBirth: dateOfBirth,
        gender: gender,
        aadharNumber: aadharNumber,
        aadhaarDocumentUrl: finalAadhaarUrl,

        bankAccountNumber: bankAccountNumber,
        bankAccountName: bankAccountName,
        bankName: bankName,
        bankBranch: bankBranch,
        bankIfsc: bankIfsc,

        companyName: companyName,
        companyAddress: companyAddress,
        gpsLatitude: gpsLatitude,
        gpsLongitude: gpsLongitude,
        primaryCity: primaryCity,
        primaryState: primaryState,
        companyContactNumber: companyContactNumber,
        companyContactVerificationToken: companyContactVerificationToken,
        alternatePhone: alternatePhone,
        companyEmail: companyEmail,
        gstNumber: gstNumber,

        avatarUrl: finalAvatarUrl,
      );

      result.fold(
            (failure) {
          state = state.copyWith(
            isLoading: false,
            error: failure.message ?? 'Something went wrong',
          );
        },
            (vendor) {
          state = state.copyWith(
            isLoading: false,
            vendorResponse: vendor,
            clearError: true,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<String?> shopAddNumberRequest({
    required String phoneNumber,
    required String type,
  }) async {
    if (state.isSendingOtp) return "OTP_ALREADY_SENDING";

    // ✅ clear old token + verified phone
    await AppPrefs.clearCompanyPhoneVerification();

    final phone10 = _onlyIndian10(phoneNumber);

    state = state.copyWith(isSendingOtp: true, clearError: true);

    final result = await api.shopAddNumberRequest(phone: phone10, type: type);

    return result.fold(
          (failure) {
        state = state.copyWith(isSendingOtp: false, error: failure.message);
        return failure.message;
      },
          (response) {
        state = state.copyWith(
          isSendingOtp: false,
          shopNumberVerifyResponse: response,
        );
        return null;
      },
    );
  }

  // ✅ OTP Verify
  Future<bool> shopAddOtpRequest({
    required String phoneNumber,
    required String type,
    required String code,
  }) async {
    if (state.isVerifyingOtp) return false;

    final phone10 = _onlyIndian10(phoneNumber);

    state = state.copyWith(isVerifyingOtp: true, clearError: true);

    final result = await api.shopAddOtpRequest(
      phone: phone10,
      type: type,
      code: code,
    );

    return result.fold(
          (failure) {
        state = state.copyWith(isVerifyingOtp: false, error: failure.message);
        return false;
      },
          (response) async {
        final verified = response.data?.verified == true;
        final token = response.data?.verificationToken ?? '';

        if (verified && token.trim().isNotEmpty) {
          // ✅ store both
          await AppPrefs.setVerificationToken(token);
          await AppPrefs.setVerifiedCompanyPhone(phone10);
        }

        state = state.copyWith(
          isVerifyingOtp: false,
          shopNumberOtpResponse: response,
        );

        return verified;
      },
    );
  }
}

final heaterRegisterNotifier =
    NotifierProvider.autoDispose<HeaterRegisterNotifier, HeaterRegisterState>(
      HeaterRegisterNotifier.new,
    );
