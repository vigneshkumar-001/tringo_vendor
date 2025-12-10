import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:tringo_vendor_new/Core/Const/app_logger.dart';

import '../../Presentation/Heater/Heater Register/Model/vendorResponse.dart';
import '../../Presentation/Login Screen/Model/login_response.dart';
import '../../Presentation/Login Screen/Model/otp_response.dart';
import '../../Presentation/Login Screen/Model/resend_otp_response.dart';
import '../../Presentation/Login Screen/Model/whatsapp_response.dart';
import '../Repository/api_url.dart';
import '../Repository/failure.dart';
import '../Repository/request.dart';

enum VendorRegisterScreen { screen1, screen2, screen3, screen4 }

abstract class BaseApiDataSource {
  Future<Either<Failure, LoginResponse>> mobileNumberLogin(
    String mobileNumber,
    String page,
  );
}

class ApiDataSource {
  Future<Either<Failure, LoginResponse>> mobileNumberLogin(
    String phone,
    String page,
  ) async {
    try {
      String url = ApiUrl.register;
      // String url = page == "resendOtp" ? ApiUrl.resendOtp : ApiUrl.register;
      AppLogger.log.i(url);

      dynamic response = await Request.sendRequest(
        url,
        {"contact": "+91$phone", "purpose": "vendor"},
        'Post',
        false,
      );

      AppLogger.log.i(response);

      if (response is! DioException) {
        // If status code is success
        if (response.statusCode == 200 || response.statusCode == 201) {
          if (response.data['status'] == true) {
            return Right(LoginResponse.fromJson(response.data));
          } else {
            return Left(
              ServerFailure(response.data['message'] ?? "Login failed"),
            );
          }
        } else {
          // ❗ API returned non-success code but has JSON error message
          return Left(
            ServerFailure(response.data['message'] ?? "Something went wrong"),
          );
        }
      } else {
        final errorData = response.response?.data;
        if (errorData is Map && errorData.containsKey('message')) {
          return Left(ServerFailure(errorData['message']));
        }
        return Left(ServerFailure(response.message ?? "Unknown Dio error"));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, OtpResponse>> otp({
    required String contact,
    required String otp,
  }) async {
    try {
      final String url = ApiUrl.verifyOtp;

      final response = await Request.sendRequest(
        url,
        {"contact": "+91$contact", "code": otp, "purpose": "vendor"},
        'POST',
        false,
      );

      AppLogger.log.i(response);

      if (response is! DioException) {
        if (response.statusCode == 200 || response.statusCode == 201) {
          if (response.data['status'] == true) {
            return Right(OtpResponse.fromJson(response.data));
          } else {
            return Left(
              ServerFailure(response.data['message'] ?? "Login failed"),
            );
          }
        } else {
          return Left(
            ServerFailure(response.data['message'] ?? "Something went wrong"),
          );
        }
      } else {
        final errorData = response.response?.data;
        if (errorData is Map && errorData.containsKey('message')) {
          return Left(ServerFailure(errorData['message']));
        }
        return Left(ServerFailure(response.message ?? "Unknown Dio error"));
      }
    } catch (e) {
      AppLogger.log.e(e.toString());
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, ResendOtpResponse>> resendOtp({
    required String contact,
  }) async {
    try {
      final String url = ApiUrl.resendOtp;

      final response = await Request.sendRequest(
        url,
        {"contact": "+91$contact", "purpose": "vendor"},
        'POST',
        false,
      );

      AppLogger.log.i(response);

      if (response is! DioException) {
        if (response.statusCode == 200 || response.statusCode == 201) {
          if (response.data['status'] == true) {
            return Right(ResendOtpResponse.fromJson(response.data));
          } else {
            return Left(
              ServerFailure(response.data['message'] ?? "Login failed"),
            );
          }
        } else {
          return Left(
            ServerFailure(response.data['message'] ?? "Something went wrong"),
          );
        }
      } else {
        final errorData = response.response?.data;
        if (errorData is Map && errorData.containsKey('message')) {
          return Left(ServerFailure(errorData['message']));
        }
        return Left(ServerFailure(response.message ?? "Unknown Dio error"));
      }
    } catch (e) {
      AppLogger.log.e(e.toString());
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, WhatsappResponse>> whatsAppNumberVerify({
    required String contact,
    required String purpose,
  }) async {
    try {
      final url = ApiUrl.whatsAppVerify;

      final payload = {"contact": "+91$contact", "purpose": purpose};

      final response = await Request.sendRequest(url, payload, 'Post', true);

      AppLogger.log.i(response);

      final data = response.data;

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (data['status'] == true) {
          return Right(WhatsappResponse.fromJson(data));
        } else {
          return Left(ServerFailure(data['message'] ?? "Login failed"));
        }
      } else {
        return Left(ServerFailure(data['message'] ?? "Something went wrong"));
      }
    } on DioException catch (dioError) {
      final errorData = dioError.response?.data;
      if (errorData is Map && errorData.containsKey('message')) {
        return Left(ServerFailure(errorData['message']));
      }
      return Left(ServerFailure(dioError.message ?? "Unknown Dio error"));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, VendorResponse>> heaterRegister({
    required VendorRegisterScreen screen,

    // 1st screen
    String? vendorName,
    String? vendorNameTamil,
    String? phoneNumber,
    String? email,
    String? dateOfBirth, // format: YYYY-MM-DD
    String? gender,
    String? aadharNumber,
    String? aadharDocumentUrl,

    // 2nd screen
    String? bankAccountNumber,
    String? bankAccountName,
    String? bankBranch,
    String? bankIfsc,

    // 3rd screen
    String? companyName,
    String? companyAddress,
    String? gpsLatitude,
    String? gpsLongitude,
    String? primaryCity,
    String? primaryState,
    String? companyContactNumber,
    String? alternatePhone,
    String? companyEmail,
    String? gstNumber,

    // 4th screen
    String? avatarUrl,
  }) async {
    try {
      final url = ApiUrl.vendorRegister;

      final Map<String, dynamic> payload = {};

      // helper → only add if not null/empty
      void addIfNotEmpty(String key, String? value) {
        if (value != null && value.trim().isNotEmpty) {
          payload[key] = value;
        }
      }

      /// ---- Build payload only for the current screen ----
      switch (screen) {
        case VendorRegisterScreen.screen1:
          // Screen 1 – owner basic info
          addIfNotEmpty("displayName", vendorName);
          addIfNotEmpty("ownerNameTamil", vendorNameTamil);
          addIfNotEmpty("phoneNumber", phoneNumber);
          addIfNotEmpty("email", email);
          addIfNotEmpty("gender", gender?.toUpperCase());
          addIfNotEmpty("dateOfBirth", dateOfBirth);
          addIfNotEmpty("aadharNumber", aadharNumber);
          addIfNotEmpty("aadharDocumentUrl", aadharDocumentUrl);
          break;

        case VendorRegisterScreen.screen2:
          // Screen 2 – bank details only
          addIfNotEmpty("bankAccountNumber", bankAccountNumber);
          addIfNotEmpty("bankAccountName", bankAccountName);
          addIfNotEmpty("bankBranch", bankBranch);
          addIfNotEmpty("bankIfsc", bankIfsc);
          break;

        case VendorRegisterScreen.screen3:
          // Screen 3 – company & location only
          addIfNotEmpty("companyName", companyName);
          addIfNotEmpty("addressLine1", companyAddress);
          addIfNotEmpty("gpsLatitude", gpsLatitude);
          addIfNotEmpty("gpsLongitude", gpsLongitude);
          addIfNotEmpty("primaryCity", primaryCity);
          addIfNotEmpty("primaryState", primaryState);
          addIfNotEmpty("companyContactNumber", companyContactNumber);
          addIfNotEmpty("alternatePhone", alternatePhone);
          addIfNotEmpty("companyEmail", companyEmail);
          addIfNotEmpty("gstNumber", gstNumber);
          break;

        case VendorRegisterScreen.screen4:
          // Screen 4 – avatar only
          addIfNotEmpty("avatarUrl", avatarUrl);
          break;
      }

      final response = await Request.sendRequest(url, payload, 'Post', true);

      AppLogger.log.i(response);

      final data = response.data;

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (data['status'] == true) {
          return Right(VendorResponse.fromJson(data));
        } else {
          return Left(ServerFailure(data['message'] ?? "Login failed"));
        }
      } else {
        return Left(ServerFailure(data['message'] ?? "Something went wrong"));
      }
    } on DioException catch (dioError) {
      final errorData = dioError.response?.data;
      if (errorData is Map && errorData.containsKey('message')) {
        return Left(ServerFailure(errorData['message']));
      }
      return Left(ServerFailure(dioError.message ?? "Unknown Dio error"));
    } catch (e) {
      AppLogger.log.e(e);
      return Left(ServerFailure(e.toString()));
    }
  }
}
