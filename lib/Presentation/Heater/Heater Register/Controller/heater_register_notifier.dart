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
    // 1️⃣ Screen 1
    required String vendorName,
    required String vendorNameTamil,
    required String phoneNumber,
    required String email,
    required String dateOfBirth,
    required String gender,
    required String aadharNumber,
    required String aadharDocumentUrl,

    // 2️⃣ Screen 2
    required String bankAccountNumber,
    required String bankAccountName,
    required String bankBranch,
    required String bankIfsc,

    // 3️⃣ Screen 3
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

    //  Screen 4
    required String avatarUrl,
  }) async {
    try {
      //  Start loading
      state = state.copyWith(isLoading: true, clearError: true);

      final result = await api.heaterRegister(
        vendorName: vendorName,
        vendorNameTamil: vendorNameTamil,
        phoneNumber: phoneNumber,
        email: email,
        dateOfBirth: dateOfBirth,
        gender: gender,
        aadharNumber: aadharNumber,
        aadharDocumentUrl: aadharDocumentUrl,
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
        avatarUrl: avatarUrl,
      );

      result.fold(
        (failure) {
          // ❌ Error from backend
          state = state.copyWith(
            isLoading: false,
            error: failure.message ?? 'Something went wrong',
          );
        },
        (vendor) {
          // ✅ Success
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
