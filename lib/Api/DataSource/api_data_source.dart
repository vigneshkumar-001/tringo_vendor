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
    // 1st screen
    required String vendorName,
    required String vendorNameTamil,
    required String phoneNumber,
    required String email,
    required String dateOfBirth, // format: YYYY-MM-DD
    required String gender,
    required String aadharNumber,
    required String aadharDocumentUrl,

    // 2nd screen
    required String bankAccountNumber,
    required String bankAccountName,
    required String bankBranch,
    required String bankIfsc,

    // 3rd screen
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

    // 4th screen
    required String avatarUrl,
  }) async {
    try {
      final url = ApiUrl.vendorRegister;

      //  Correct, full payload mapped to your VendorData & VendorUser model
      final payload = {
        //  Screen 1 – owner basic info
        "displayName": vendorName, // maps to VendorData.displayName
        "ownerNameTamil": vendorNameTamil, // maps to VendorData.ownerNameTamil
        "phoneNumber": phoneNumber, // VendorUser.phoneNumber
        "email": email, // VendorUser.email
        "gender": gender.toUpperCase(), // VendorData.gender
        "dateOfBirth": dateOfBirth, // "YYYY-MM-DD" string
        "aadharNumber": aadharNumber, // VendorData.aadharNumber
        "aadharDocumentUrl": aadharDocumentUrl, // VendorData.aadharDocumentUrl
        //  Screen 2 – bank details
        "bankAccountNumber": bankAccountNumber,
        "bankAccountName": bankAccountName,
        "bankBranch": bankBranch,
        "bankIfsc": bankIfsc,

        //  Screen 3 – company & location
        "companyName": companyName,
        "addressLine1": companyAddress, // maps to VendorData.addressLine1
        "gpsLatitude": gpsLatitude,
        "gpsLongitude": gpsLongitude,
        "primaryCity": primaryCity,
        "primaryState": primaryState,

        "companyContactNumber": companyContactNumber,
        "alternatePhone": alternatePhone,
        "companyEmail": companyEmail,
        "gstNumber": gstNumber,

        //  Screen 4 – avatar
        "avatarUrl": avatarUrl,
      };

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
      return Left(ServerFailure(e.toString()));
    }
  }
}
