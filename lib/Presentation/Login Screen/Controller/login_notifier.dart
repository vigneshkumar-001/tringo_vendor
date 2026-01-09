import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tringo_vendor_new/Core/Const/app_logger.dart';

import '../../../../../Api/DataSource/api_data_source.dart';

import '../../../Api/Repository/failure.dart';
import '../../../Core/contacts/contacts_service.dart';
import '../../../Core/contacts/contacts_sync_manager.dart';
import '../Model/contact_response.dart';
import '../Model/login_response.dart';
import '../Model/otp_response.dart';
import '../Model/resend_otp_response.dart';
import '../Model/whatsapp_response.dart';

/// --- STATE ---
class LoginState {
  final bool isLoading;
  final bool reSendOtpLoading;
  final LoginResponse? loginResponse;
  final OtpResponse? otpResponse;
  final String? error;
  final WhatsappResponse? whatsappResponse;
  final ResendOtpResponse? resendOtpResponse;
  final ContactResponse? contactResponse;

  const LoginState({
    this.isLoading = false,
    this.reSendOtpLoading = false,
    this.loginResponse,
    this.otpResponse,
    this.error,
    this.whatsappResponse,
    this.resendOtpResponse,
    this.contactResponse,
  });

  factory LoginState.initial() => const LoginState();

  LoginState copyWith({
    bool? isLoading,
    bool? reSendOtpLoading,
    LoginResponse? loginResponse,
    OtpResponse? otpResponse,
    String? error,
    WhatsappResponse? whatsappResponse,
    ResendOtpResponse? resendOtpResponse,
    ContactResponse? contactResponse,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      reSendOtpLoading: reSendOtpLoading ?? this.reSendOtpLoading,
      loginResponse: loginResponse ?? this.loginResponse,
      otpResponse: otpResponse ?? this.otpResponse,
      error: error,
      whatsappResponse: whatsappResponse ?? this.whatsappResponse,
      resendOtpResponse: resendOtpResponse ?? this.resendOtpResponse,
      contactResponse: contactResponse ?? this.contactResponse,
    );
  }
}

class LoginNotifier extends Notifier<LoginState> {
  late final ApiDataSource api;

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
      simToken ?? "",
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

  Future<void> verifyOtp({required String contact, required String otp}) async {
    state = state.copyWith(isLoading: true, error: null);

    // ✅ keep this provider alive until we finish starting the background job safely
    final keepAliveLink = ref.keepAlive();

    try {
      final result = await api.otp(contact: contact, otp: otp);

      await result.fold<Future<void>>(
            (failure) async {
          if (!ref.mounted) return;
          state = state.copyWith(isLoading: false, error: failure.message);
        },
            (response) async {
          final prefs = await SharedPreferences.getInstance();
          if (!ref.mounted) return;

          final data = response.data;
          await prefs.setString('token', data?.accessToken ?? '');
          await prefs.setString('refreshToken', data?.refreshToken ?? '');
          await prefs.setString('sessionToken', data?.sessionToken ?? '');
          await prefs.setString('role', data?.role ?? '');

          if (!ref.mounted) return;

          // ✅ OTP success state first (UI can navigate)
          state = state.copyWith(isLoading: false, otpResponse: response);

          // ✅ Start background sync WITHOUT waiting, but safely
          // We DO NOT pass ref anymore.
          // ignore: unawaited_futures
          ContactsSyncManager.syncIfNeeded(
            api: api, // pass ApiDataSource directly
            defaultDialCode: '+91',
            maxContacts: 500,
            chunkSize: 200,
          );
        },
      );
    } catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(isLoading: false, error: e.toString());
    } finally {
      // ✅ release keepAlive
      keepAliveLink.close();
    }
  }


  // Future<void> verifyOtp({required String contact, required String otp}) async {
  //   state = state.copyWith(isLoading: true, error: null);
  //
  //   final result = await api.otp(contact: contact, otp: otp);
  //
  //   result.fold(
  //         (failure) {
  //       state = state.copyWith(isLoading: false, error: failure.message);
  //     },
  //         (response) async {
  //       final prefs = await SharedPreferences.getInstance();
  //
  //       final data = response.data;
  //       await prefs.setString('token', data?.accessToken ?? '');
  //       await prefs.setString('refreshToken', data?.refreshToken ?? '');
  //       await prefs.setString('sessionToken', data?.sessionToken ?? '');
  //       await prefs.setString('role', data?.role ?? '');
  //
  //       // ✅ OTP success state first (UI can navigate)
  //       state = state.copyWith(isLoading: false, otpResponse: response);
  //
  //       final alreadySynced = prefs.getBool('contacts_synced') ?? false;
  //       if (alreadySynced) return;
  //
  //       try {
  //         AppLogger.log.i("✅ Contact sync started");
  //
  //         final contacts = await ContactsService.getAllContacts();
  //         AppLogger.log.i("📞 contacts fetched = ${contacts.length}");
  //
  //         if (contacts.isEmpty) {
  //           AppLogger.log.w(
  //             "⚠️ Contacts empty OR permission denied. Not marking synced.",
  //           );
  //           return;
  //         }
  //
  //         // ✅ Build items array (backend expects items[])
  //         final limited = contacts.take(500).toList(); // increase if you want
  //         final items = limited
  //             .map(
  //               (c) => {
  //             "name": c.name,
  //             "phone": "+91${c.phone}", // or use dialCode dynamic
  //           },
  //         )
  //             .toList();
  //
  //         // ✅ Chunk to avoid huge payload (recommended)
  //         const chunkSize = 200;
  //         for (var i = 0; i < items.length; i += chunkSize) {
  //           final chunk = items.sublist(
  //             i,
  //             (i + chunkSize > items.length) ? items.length : i + chunkSize,
  //           );
  //
  //           final res = await api.syncContacts(items: chunk);
  //
  //           res.fold(
  //                 (l) => AppLogger.log.e("❌ batch sync fail: ${l.message}"),
  //                 (r) => AppLogger.log.i(
  //               "✅ batch ok total=${r.data.total} inserted=${r.data.inserted} touched=${r.data.touched} skipped=${r.data.skipped}",
  //             ),
  //           );
  //         }
  //
  //         await prefs.setBool('contacts_synced', true);
  //         AppLogger.log.i("✅ Contacts synced done: ${limited.length}");
  //       } catch (e) {
  //         AppLogger.log.e("❌ Contact sync failed: $e");
  //       }
  //     },
  //   );
  // }

  Future<void> syncContact({
    required String name,
    required String phone,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final items = [
      {"name": name, "phone": "+91$phone"},
    ];

    final result = await api.syncContacts(items: items);

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
          contactResponse: null,
        );
      },
      (response) {
        state = state.copyWith(
          isLoading: false,
          contactResponse: response,
          error: null,
        );
      },
    );
  }



  Future<void> resendOtp({required String contact}) async {
    state = state.copyWith(reSendOtpLoading: true, error: null);

    final result = await api.resendOtp(contact: contact);

    result.fold(
      (failure) {
        state = state.copyWith(reSendOtpLoading: false, error: failure.message);
      },
      (response) {
        state = state.copyWith(reSendOtpLoading: false, resendOtpResponse: response);
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
