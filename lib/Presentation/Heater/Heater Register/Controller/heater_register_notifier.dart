import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../Api/DataSource/api_data_source.dart';
import '../../../Login Screen/Controllre/login_notifier.dart';
import '../Model/vendorResponse.dart';

class HeaterRegisterState {
  final bool isLoading;
  final String? error;
  final VendorResponse? vendorResponse;

  const HeaterRegisterState({
    this.isLoading = false,
    this.error,
    this.vendorResponse,
  });

  factory HeaterRegisterState.initial() => const HeaterRegisterState();

  HeaterRegisterState copyWith({
    bool? isLoading,
    String? error,
    VendorResponse? vendorResponse,
    bool clearError = false,
  }) {
    return HeaterRegisterState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      vendorResponse: vendorResponse ?? this.vendorResponse,
    );
  }
}

class HeaterRegisterNotifier extends Notifier<HeaterRegisterState> {
  late final ApiDataSource api;

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
    // Screen 1
    required String vendorName,
    required String vendorNameTamil,
    required String phoneNumber,
    required String email,
    required String dateOfBirth,
    required String gender,
    required String aadharNumber,
    required String aadharDocumentUrl, // original URL if already exists
    // Screen 2
    required String bankAccountNumber,
    required String bankAccountName,
    required String bankBranch,
    required String bankIfsc,

    // Screen 3
    required String companyName,
    required String companyAddress,
    required String gpsLatitude,
    required String gpsLongitude,
    required String primaryCity,
    required String primaryState,
    required String companyContactNumber,
    required String alternatePhone,
    required String companyEmail,
    required String gstNumber,

    File? aadhaarFile,

    File? avatarFile,
    String? avatarUrl,

  }) async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);

      // STEP 1: Upload Aadhaar ONLY if file is provided
      String finalAadhaarUrl = aadharDocumentUrl;

      if (aadhaarFile != null) {
        final upload = await api.userProfileUpload(imageFile: aadhaarFile);

        finalAadhaarUrl = upload.fold(
          (failure) => throw Exception(failure.message),
          (url) => url.message, // <- don't use url.message, return the URL
        );
      }

      String finalAvatarUrl = avatarUrl ?? '';

      if (avatarFile != null) {
        final uploadAvatar = await api.userProfileUpload(imageFile: avatarFile);

        finalAvatarUrl = uploadAvatar.fold(
              (failure) => throw Exception(failure.message),
              (res) => res.message, // URL returned by API
        );
      }


      // STEP 2: Now call register API ONCE
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
        // <-- correct parameter name
        bankAccountNumber: bankAccountNumber,
        bankAccountName: bankAccountName,
        bankBranch: bankBranch,
        bankIfsc: bankIfsc,
        companyName: companyName,
        companyAddress: companyAddress,
        gpsLatitude: gpsLatitude,
        gpsLongitude: gpsLongitude,
        primaryCity: primaryCity,
        primaryState: primaryState,
        companyContactNumber: companyContactNumber,
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
}

final heaterRegisterNotifier =
    NotifierProvider.autoDispose<HeaterRegisterNotifier, HeaterRegisterState>(
      HeaterRegisterNotifier.new,
    );
