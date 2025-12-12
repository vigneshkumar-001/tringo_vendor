import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tringo_vendor_new/Core/Const/app_logger.dart';

import '../../../../../Api/DataSource/api_data_source.dart';

import '../../../Api/Repository/failure.dart';
import '../Model/login_response.dart';
import '../Model/otp_response.dart';
import '../Model/resend_otp_response.dart';
import '../Model/whatsapp_response.dart';

/// --- STATE ---
class LoginState {
  final bool isLoading;
  final LoginResponse? loginResponse;
  final OtpResponse? otpResponse;
  final String? error;
  final WhatsappResponse? whatsappResponse;
  final ResendOtpResponse? resendOtpResponse;

  const LoginState({
    this.isLoading = false,
    this.loginResponse,
    this.otpResponse,
    this.error,
    this.whatsappResponse,
    this.resendOtpResponse,
  });

  factory LoginState.initial() => const LoginState();

  LoginState copyWith({
    bool? isLoading,
    LoginResponse? loginResponse,
    OtpResponse? otpResponse,
    String? error,
    WhatsappResponse? whatsappResponse,
    ResendOtpResponse? resendOtpResponse,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      loginResponse: loginResponse ?? this.loginResponse,
      otpResponse: otpResponse ?? this.otpResponse,
      error: error,
      whatsappResponse: whatsappResponse ?? this.whatsappResponse,
      resendOtpResponse: resendOtpResponse ?? this.resendOtpResponse,
    );
  }
}

class LoginNotifier extends Notifier<LoginState> {
  late final ApiDataSource api;

  // 🔒 guard to prevent multiple OTP requests
  bool _isRequestingOtp = false;

  @override
  LoginState build() {
    api = ref.read(apiDataSourceProvider);
    return LoginState.initial();
  }

  void resetState() {
    _isRequestingOtp = false;
    state = LoginState.initial();
  }

  Future<void> loginUser({
    required String phoneNumber,
    String? simToken,
    String? page,
  }) async {
    state = const LoginState(isLoading: true);

    final result = await api.mobileNumberLogin(
      phoneNumber,
      simToken!,
      page: page ?? '',
    );

    result.fold(
      (failure) {
        state = LoginState(isLoading: false, error: failure.message);
      },
      (response) {
        state = LoginState(isLoading: false, loginResponse: response);
      },
    );
  }

  // Future<void> verifyOtp({required String contact, required String otp}) async {
  //   state = const LoginState(isLoading: true);
  //
  //   final result = await api.otp(contact: contact, otp: otp);
  //
  //   await result.fold<Future<void>>(
  //     (Failure failure) async {
  //       state = LoginState(isLoading: false, error: failure.message);
  //     },
  //     (OtpResponse response) async {
  //       final data = response.data;
  //
  //       final prefs = await SharedPreferences.getInstance();
  //
  //       await prefs.setString('token', data?.accessToken ?? '');
  //       await prefs.setString('refreshToken', data?.refreshToken ?? '');
  //       await prefs.setString('sessionToken', data?.sessionToken ?? '');
  //       await prefs.setString('role', data?.role ?? '');
  //
  //       final accessToken = prefs.getString('token');
  //       final refreshToken = prefs.getString('refreshToken');
  //       final sessionToken = prefs.getString('sessionToken');
  //       final role = prefs.getString('role');
  //
  //       AppLogger.log.i(' SharedPreferences stored successfully:');
  //       AppLogger.log.i('token → $accessToken');
  //       AppLogger.log.i('refreshToken → $refreshToken');
  //       AppLogger.log.i('sessionToken → $sessionToken');
  //       AppLogger.log.i('role → $role');
  //
  //       state = LoginState(isLoading: false, otpResponse: response);
  //     },
  //   );
  // }

  Future<void> verifyOtp({required String contact, required String otp}) async {
    state = const LoginState(isLoading: true);

    final result = await api.otp(contact: contact, otp: otp);

    await result.fold<Future<void>>(
      (Failure failure) async {
        state = LoginState(isLoading: false, error: failure.message);
      },
      (OtpResponse response) async {
        final data = response.data;

        final prefs = await SharedPreferences.getInstance();

        await prefs.setString('token', data?.accessToken ?? '');
        await prefs.setString('refreshToken', data?.refreshToken ?? '');
        await prefs.setString('sessionToken', data?.sessionToken ?? '');
        await prefs.setString('role', data?.role ?? '');
        // NEW: store isNewOwner
        await prefs.setBool('isNewOwner', data?.isNewOwner ?? false);

        final accessToken = prefs.getString('token');
        final refreshToken = prefs.getString('refreshToken');
        final sessionToken = prefs.getString('sessionToken');
        final role = prefs.getString('role');
        final isNewOwner = prefs.getBool('isNewOwner') ?? false;

        AppLogger.log.i('SharedPreferences stored successfully:');
        AppLogger.log.i('token → $accessToken');
        AppLogger.log.i('refreshToken → $refreshToken');
        AppLogger.log.i('sessionToken → $sessionToken');
        AppLogger.log.i('role → $role');
        AppLogger.log.i('isNewOwner → $isNewOwner');

        state = LoginState(isLoading: false, otpResponse: response);

        // If you want, you can use `isNewOwner` here to navigate:
        // if (isNewOwner) { goToOnboarding(); } else { goToHome(); }
      },
    );
  }

  Future<void> resendOtp({required String contact}) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await api.resendOtp(contact: contact);

    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
      },
      (response) {
        state = state.copyWith(isLoading: false, resendOtpResponse: response);
      },
    );
  }

  Future<void> verifyWhatsappNumber({
    required String contact,
    required String purpose,
  }) async {
    state = const LoginState(isLoading: true);

    try {
      final result = await api.whatsAppNumberVerify(
        contact: contact,
        purpose: purpose,
      );

      result.fold(
        (Failure failure) {
          state = LoginState(isLoading: false, error: failure.message);
        },
        (WhatsappResponse response) {
          state = LoginState(isLoading: false, whatsappResponse: response);
        },
      );
    } catch (e) {
      state = LoginState(isLoading: false, error: e.toString());
    }
  }
}

/// --- PROVIDERS ---
final apiDataSourceProvider = Provider<ApiDataSource>((ref) {
  return ApiDataSource();
});

final loginNotifierProvider =
    NotifierProvider.autoDispose<LoginNotifier, LoginState>(LoginNotifier.new);
