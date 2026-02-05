import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tringo_vendor_new/Core/Const/app_logger.dart';
import 'package:tringo_vendor_new/Presentation/About%20Me/Model/delete_response.dart';
import 'package:tringo_vendor_new/Presentation/AddProduct/Model/product_response.dart';
import 'package:tringo_vendor_new/Presentation/AddProduct/Model/service_info_response.dart';
import 'package:tringo_vendor_new/Presentation/Heater/Add%20Vendor%20Employee/Model/add_employee_response.dart';
import 'package:tringo_vendor_new/Presentation/Heater/Add%20Vendor%20Employee/Model/employee_list_response.dart';
import 'package:tringo_vendor_new/Presentation/Heater/Employee%20details-edit/Model/heater_employee_edit_res.dart';
import 'package:tringo_vendor_new/Presentation/Heater/History/Model/vendor_history_response.dart';
import 'package:tringo_vendor_new/Presentation/Heater/Setting/Model/get_profile_response.dart';
import 'package:tringo_vendor_new/Presentation/Privacy%20Policy/Model/terms_and_condition_model.dart';
import 'package:tringo_vendor_new/Presentation/ShopInfo/Model/category_keywords_response.dart';
import 'package:tringo_vendor_new/Presentation/Shops%20Details/Model/shop_details_response.dart';
import 'package:tringo_vendor_new/Presentation/subscription/Model/current_plan_response.dart';
import 'package:tringo_vendor_new/Presentation/subscription/Model/plan_list_response.dart';

import '../../Core/Offline_Data/offline_helpers.dart';
import '../../Presentation/AddProduct/Model/delete_response.dart';
import '../../Presentation/AddProduct/Model/image_upload_response.dart';
import '../../Presentation/AddProduct/Model/service_remove_response.dart';
import '../../Presentation/Employee History/Model/employee_history_response.dart';
import 'package:tringo_vendor_new/Presentation/Owner%20Screen/Model/owner_otp_response.dart';
import 'package:tringo_vendor_new/Presentation/Owner%20Screen/Model/owner_register_response.dart';
import 'package:tringo_vendor_new/Presentation/ShopInfo/Model/category_list_response.dart';

import '../../Core/Utility/app_prefs.dart';
import '../../Presentation/Heater/Add Vendor Employee/Model/masked_contact_response.dart';
import '../../Presentation/Heater/Add Vendor Employee/Model/user_image_response.dart';
import '../../Presentation/Heater/Add Vendor Employee/Model/verification_response.dart';
import '../../Presentation/Heater/Employee Details/Model/employeeDetailsResponse.dart';
import '../../Presentation/Heater/Employee details-edit/Model/employee_change_number.dart';
import '../../Presentation/Heater/Employee details-edit/Model/employee_unblock_response.dart';
import '../../Presentation/Heater/Employee details-edit/Model/phone_verification_response.dart';
import '../../Presentation/Heater/Employees/Model/heater_employee_response.dart';
import '../../Presentation/Heater/Heater Home Screen/Model/heater_home_response.dart';
import '../../Presentation/Heater/Heater Register/Model/vendorResponse.dart';
import '../../Presentation/Home Screen/Model/employee_home_response.dart';
import '../../Presentation/Login Screen/Model/app_version_response.dart';
import '../../Presentation/Login Screen/Model/contact_response.dart';
import '../../Presentation/Login Screen/Model/login_new_response.dart';
import '../../Presentation/Login Screen/Model/login_response.dart';
import '../../Presentation/Login Screen/Model/otp_response.dart';
import '../../Presentation/Login Screen/Model/resend_otp_response.dart';
import '../../Presentation/Login Screen/Model/whatsapp_response.dart';
import '../../Presentation/Mobile Nomber Verify/Model/sim_verify_response.dart';
import '../../Presentation/Shop Details Edit/Model/shop_details_response.dart';
import '../../Presentation/ShopInfo/Model/search_keywords_response.dart';
import '../../Presentation/ShopInfo/Model/shop_info_photos_response.dart';
import '../../Presentation/ShopInfo/Model/shop_number_otp_response.dart';
import '../../Presentation/ShopInfo/Model/shop_number_verify_response.dart';
import '../../Presentation/Support/Model/chat_message_response.dart';
import '../../Presentation/Support/Model/create_support_response.dart';
import '../../Presentation/Support/Model/send_message_response.dart';
import '../../Presentation/Support/Model/support_list_response.dart';
import '../../Presentation/subscription/Model/purchase_response.dart';
import '../Repository/api_url.dart';
import '../Repository/failure.dart';
import '../Repository/request.dart';

enum VendorRegisterScreen { screen1, screen2, screen3, screen4 }

String normalizeIndianPhone(String input) {
  var p = input.trim();
  p = p.replaceAll(RegExp(r'[^0-9]'), '');
  if (p.startsWith('91') && p.length == 12) {
    p = p.substring(2);
  }
  return p;
}

String toIndiaE164(String input) {
  var p = input.trim();

  if (p.startsWith('+')) return p; // already e164

  p = p.replaceAll(RegExp(r'[^0-9]'), '');

  if (p.length == 10) return '+91$p';
  if (p.length == 12 && p.startsWith('91')) return '+$p';

  // fallback
  return '+91$p';
}

abstract class BaseApiDataSource {
  Future<Either<Failure, LoginResponse>> mobileNumberLogin(
    String mobileNumber,
    String page,
  );
}

class ApiDataSource {
  Future<Either<Failure, LoginResponse>> mobileNumberLogin(
    String phone,
    String simToken, {
    String page = "",
  }) async {
    try {
      final url = page == "resendOtp" ? ApiUrl.resendOtp : ApiUrl.register;

      final response = await Request.sendRequest(
        url,
        {"contact": "+91$phone", "purpose": "vendor", "simToken": simToken},
        'Post',
        false,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data['status'] == true) {
          return Right(LoginResponse.fromJson(response.data));
        } else {
          return Left(
            ServerFailure(response.data['message'] ?? "Login failed"),
          );
        }
      }

      return Left(
        ServerFailure(response.data['message'] ?? "Something went wrong"),
      );
    } on DioException catch (e) {
      // 🔴 NO INTERNET
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.unknown) {
        return Left(ServerFailure("No internet connection. Please try again"));
      }

      final errorData = e.response?.data;
      if (errorData is Map && errorData['message'] != null) {
        return Left(ServerFailure(errorData['message']));
      }

      return Left(ServerFailure("Request failed"));
    } catch (_) {
      return Left(ServerFailure("Unexpected error occurred"));
    }
  }

  Future<Either<Failure, OtpLoginResponse>> mobileNewNumberLogin(
    String phone,
    String simToken, {
    String page = "",
  }) async {
    try {
      // final url = page == "resendOtp" ? ApiUrl.resendOtp : ApiUrl.register;
      final url = ApiUrl.requestLogin;
      final method = simToken.isEmpty ? 'OTP' : 'SIM';
      final response = await Request.sendRequest(
        url,
        {
          "contact": "+91$phone",
          "purpose": "vendor",
          "loginMethod": method,
          "simToken": simToken,
        },
        'Post',
        false,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data['status'] == true) {
          return Right(OtpLoginResponse.fromJson(response.data));
        } else {
          return Left(
            ServerFailure(response.data['message'] ?? "Login failed"),
          );
        }
      }

      return Left(
        ServerFailure(response.data['message'] ?? "Something went wrong"),
      );
    } on DioException catch (e) {
      // 🔴 NO INTERNET
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.unknown) {
        return Left(ServerFailure("No internet connection. Please try again"));
      }

      final errorData = e.response?.data;
      if (errorData is Map && errorData['message'] != null) {
        return Left(ServerFailure(errorData['message']));
      }

      return Left(ServerFailure("Request failed"));
    } catch (_) {
      return Left(ServerFailure("Unexpected error occurred"));
    }
  }

  // Future<Either<Failure, LoginResponse>> mobileNumberLogin(
  //   String phone,
  //   String simToken, {
  //   String page = "",
  // }) async {
  //   try {
  //     String url = page == "resendOtp" ? ApiUrl.resendOtp : ApiUrl.register;
  //
  //     final response = await Request.sendRequest(
  //       url,
  //       {"contact": "+91$phone", "purpose": "vendor"},
  //       'Post',
  //       false,
  //     ).timeout(const Duration(seconds: 10)); // explicitly set timeout
  //
  //     if (response is! DioException) {
  //       if (response.statusCode == 200 || response.statusCode == 201) {
  //         if (response.data['status'] == true) {
  //           return Right(LoginResponse.fromJson(response.data));
  //         } else {
  //           return Left(
  //             ServerFailure(response.data['message'] ?? "Login failed"),
  //           );
  //         }
  //       } else {
  //         return Left(
  //           ServerFailure(response.data['message'] ?? "Something went wrong"),
  //         );
  //       }
  //     } else {
  //       final errorData = response.response?.data;
  //       if (errorData is Map && errorData.containsKey('message')) {
  //         return Left(ServerFailure(errorData['message']));
  //       }
  //       return Left(ServerFailure(response.message ?? "Unknown Dio error"));
  //     }
  //   } on TimeoutException {
  //     return Left(ServerFailure("Request timed out. Please try again."));
  //   } catch (e) {
  //     return Left(ServerFailure(e.toString()));
  //   }
  // }

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

  Future<Either<Failure, SimVerifyResponse>> mobileVerify({
    required String contact,
    required String simToken,
    required String purpose,
  }) async {
    try {
      final url = ApiUrl.mobileVerify;

      final payload = {
        'contact': "+91$contact",
        'simToken': simToken,
        'purpose': 'vendor',
      };

      // Use your normal POST helper
      dynamic response = await Request.sendRequest(url, payload, 'Post', true);

      AppLogger.log.i(response);

      if (response is! DioException) {
        if (response.statusCode == 200 || response.statusCode == 201) {
          if (response.data['status'] == true) {
            // ✅ API returns the same JSON you showed
            return Right(SimVerifyResponse.fromJson(response.data));
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
      AppLogger.log.e(e);
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

      final data = response.data;

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (data['status'] == true) {
          return Right(WhatsappResponse.fromJson(data));
        } else {
          return Left(ServerFailure(data['message'] ?? "Verification failed"));
        }
      }

      return Left(ServerFailure(data['message'] ?? "Something went wrong"));
    }
    // 🔴 NETWORK / INTERNET ERRORS
    on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.unknown) {
        return Left(ServerFailure("No internet connection. Please try again"));
      }

      final errorData = e.response?.data;
      if (errorData is Map && errorData['message'] != null) {
        return Left(ServerFailure(errorData['message']));
      }

      return Left(ServerFailure("Request failed"));
    } catch (_) {
      return Left(ServerFailure("Unexpected error occurred"));
    }
  }

  // Future<Either<Failure, VendorResponse>> heaterRegister({
  //   required VendorRegisterScreen screen,
  //
  //   // 1st screen
  //   String? vendorName,
  //   String? vendorNameTamil,
  //   String? phoneNumber,
  //   String? email,
  //   String? dateOfBirth, // format: YYYY-MM-DD
  //   String? gender,
  //   String? aadharNumber,
  //   String? aadhaarDocumentUrl,
  //
  //   // 2nd screen
  //   String? bankAccountNumber,
  //   String? bankName,
  //   String? bankAccountName,
  //   String? bankBranch,
  //   String? bankIfsc,
  //
  //   // 3rd screen
  //   String? companyName,
  //   String? companyAddress,
  //   String? gpsLatitude,
  //   String? gpsLongitude,
  //   String? primaryCity,
  //   String? primaryState,
  //   String? companyContactNumber,
  //   String? companyContactVerificationToken,
  //   String? alternatePhone,
  //   String? companyEmail,
  //   String? gstNumber,
  //
  //   // 4th screen
  //   String? avatarUrl,
  // }) async {
  //   try {
  //     final url = ApiUrl.vendorRegister;
  //
  //     final Map<String, dynamic> payload = {};
  //
  //     // helper → only add if not null/empty
  //     void addIfNotEmpty(String key, String? value) {
  //       if (value != null && value.trim().isNotEmpty) {
  //         payload[key] = value;
  //       }
  //     }
  //
  //     /// ---- Build payload only for the current screen ----
  //     switch (screen) {
  //       case VendorRegisterScreen.screen1:
  //         // Support Screen 1 – owner basic info
  //         addIfNotEmpty("vendorName", vendorName);
  //         addIfNotEmpty("ownerNameTamil", vendorNameTamil);
  //         addIfNotEmpty("phoneNumber", phoneNumber);
  //         addIfNotEmpty("email", email);
  //         addIfNotEmpty("gender", gender?.toUpperCase());
  //         addIfNotEmpty("dateOfBirth", dateOfBirth);
  //         addIfNotEmpty("aadharNumber", aadharNumber);
  //         addIfNotEmpty("aadharDocumentUrl", aadhaarDocumentUrl);
  //         break;
  //
  //       case VendorRegisterScreen.screen2:
  //         // Support Screen 2 – bank details only
  //         addIfNotEmpty("bankAccountNumber", bankAccountNumber);
  //         addIfNotEmpty("bankName", bankName);
  //         addIfNotEmpty("bankAccountName", bankAccountName);
  //         addIfNotEmpty("bankBranch", bankBranch);
  //         addIfNotEmpty("bankIfsc", bankIfsc);
  //         break;
  //
  //       case VendorRegisterScreen.screen3:
  //         // Support Screen 3 – company & location only
  //         addIfNotEmpty("companyName", companyName);
  //         addIfNotEmpty("addressLine1", companyAddress);
  //         addIfNotEmpty("gpsLatitude", gpsLatitude);
  //         addIfNotEmpty("gpsLongitude", gpsLongitude);
  //         addIfNotEmpty("primaryCity", primaryCity);
  //         addIfNotEmpty("primaryState", primaryState);
  //         addIfNotEmpty("companyContactNumber", companyContactNumber);
  //         addIfNotEmpty("companyContactVerificationToken", companyContactVerificationToken);
  //         addIfNotEmpty("alternatePhone", alternatePhone);
  //         addIfNotEmpty("companyEmail", companyEmail);
  //         addIfNotEmpty("gstNumber", gstNumber);
  //         break;
  //
  //       case VendorRegisterScreen.screen4:
  //         // Support Screen 4 – avatar only
  //         addIfNotEmpty("avatarUrl", avatarUrl);
  //         break;
  //     }
  //
  //     final response = await Request.sendRequest(url, payload, 'Post', true);
  //
  //     AppLogger.log.i(response);
  //
  //     final data = response.data;
  //
  //     if (response.statusCode == 200 || response.statusCode == 201) {
  //       if (data['status'] == true) {
  //         return Right(VendorResponse.fromJson(data));
  //       } else {
  //         return Left(ServerFailure(data['message'] ?? "Login failed"));
  //       }
  //     } else {
  //       return Left(ServerFailure(data['message'] ?? "Something went wrong"));
  //     }
  //   } on DioException catch (dioError) {
  //     final errorData = dioError.response?.data;
  //     if (errorData is Map && errorData.containsKey('message')) {
  //       return Left(ServerFailure(errorData['message']));
  //     }
  //     return Left(ServerFailure(dioError.message ?? "Unknown Dio error"));
  //   } catch (e) {
  //     AppLogger.log.e(e);
  //     return Left(ServerFailure(e.toString()));
  //   }
  // }

  Future<Either<Failure, VendorResponse>> heaterRegister({
    required VendorRegisterScreen screen,

    // 1st screen
    String? vendorName,
    String? vendorNameTamil,
    String? phoneNumber,
    String? email,
    String? dateOfBirth, // YYYY-MM-DD
    String? gender,
    String? aadharNumber,
    String? aadhaarDocumentUrl,

    // 2nd screen
    String? bankAccountNumber,
    String? bankName,
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
    String? companyContactVerificationToken,
    String? alternatePhone,
    String? companyEmail,
    String? gstNumber,

    // 4th screen
    String? avatarUrl,
  }) async {
    try {
      final url = ApiUrl.vendorRegister;

      // ✅ helper: convert Map<dynamic,dynamic> -> Map<String,dynamic>
      Map<String, dynamic> _asStringKeyedMap(dynamic data) {
        if (data is Map<String, dynamic>) return data;
        if (data is Map) {
          return data.map((k, v) => MapEntry(k.toString(), v));
        }
        throw Exception("Response is not a Map");
      }

      // ✅ helper: only add if not null/empty + trim
      void addIfNotEmpty(
        Map<String, dynamic> payload,
        String key,
        String? value,
      ) {
        final v = value?.trim();
        if (v != null && v.isNotEmpty) payload[key] = v;
      }

      // ✅ phone normalize helper (India)
      // String normalize10(String? input) {
      //   var p = (input ?? '').trim();
      //   p = p.replaceAll(RegExp(r'[^0-9]'), '');
      //   if (p.startsWith('91') && p.length == 12) p = p.substring(2);
      //   if (p.length > 10) p = p.substring(p.length - 10);
      //   return p;
      // }

      // ✅ Validate screen3 before sending request
      // if (screen == VendorRegisterScreen.screen3) {
      //   final phone10 = companyContactNumber;
      //   if (phone10!.isEmpty) {
      //     return Left(ServerFailure("Company phone required"));
      //   }
      //   if ((companyContactVerificationToken ?? '').trim().isEmpty) {
      //     return Left(ServerFailure("Company phone OTP not verified"));
      //   }
      // }

      final Map<String, dynamic> payload = {};

      // ---- Build payload only for the current screen ----
      switch (screen) {
        case VendorRegisterScreen.screen1:
          addIfNotEmpty(payload, "vendorName", vendorName);
          addIfNotEmpty(payload, "ownerNameTamil", vendorNameTamil);

          // ✅ normalize vendor phone (recommended)
          final phone10 = phoneNumber;
          addIfNotEmpty(
            payload,
            "phoneNumber",
            phone10!.isEmpty ? "+91$phoneNumber" : "+91$phone10",
          );

          addIfNotEmpty(payload, "email", email);
          addIfNotEmpty(payload, "gender", gender?.toUpperCase());
          addIfNotEmpty(payload, "dateOfBirth", dateOfBirth);
          addIfNotEmpty(payload, "aadharNumber", aadharNumber);

          // ✅ SAFETY: backend might accept either key
          addIfNotEmpty(payload, "aadharDocumentUrl", aadhaarDocumentUrl);
          addIfNotEmpty(payload, "aadhaarDocumentUrl", aadhaarDocumentUrl);
          break;

        case VendorRegisterScreen.screen2:
          addIfNotEmpty(payload, "bankAccountNumber", bankAccountNumber);
          addIfNotEmpty(payload, "bankName", bankName);
          addIfNotEmpty(payload, "bankAccountName", bankAccountName);
          addIfNotEmpty(payload, "bankBranch", bankBranch);
          addIfNotEmpty(payload, "bankIfsc", bankIfsc);
          break;

        case VendorRegisterScreen.screen3:
          addIfNotEmpty(payload, "companyName", companyName);
          addIfNotEmpty(payload, "addressLine1", companyAddress);
          addIfNotEmpty(payload, "gpsLatitude", gpsLatitude);
          addIfNotEmpty(payload, "gpsLongitude", gpsLongitude);
          addIfNotEmpty(payload, "primaryCity", primaryCity);
          addIfNotEmpty(payload, "primaryState", primaryState);

          // ✅ normalize numbers to match OTP verification
          addIfNotEmpty(
            payload,
            "companyContactNumber",
            '+91$companyContactNumber',
          );
          addIfNotEmpty(
            payload,
            "companyContactVerificationToken",
            companyContactVerificationToken,
          );
          addIfNotEmpty(payload, "alternatePhone", alternatePhone);

          addIfNotEmpty(payload, "companyEmail", companyEmail);
          addIfNotEmpty(payload, "gstNumber", gstNumber);
          break;

        case VendorRegisterScreen.screen4:
          addIfNotEmpty(payload, "avatarUrl", avatarUrl);
          break;
      }

      final response = await Request.sendRequest(url, payload, 'Post', true);

      AppLogger.log.i("✅ API: $url");
      AppLogger.log.i("✅ PAYLOAD: $payload");
      AppLogger.log.i("✅ STATUS: ${response.statusCode}");
      AppLogger.log.i("✅ DATA: ${response.data}");

      final dataDyn = response.data;

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonMap = _asStringKeyedMap(dataDyn);

        if (jsonMap['status'] == true) {
          return Right(VendorResponse.fromJson(jsonMap));
        } else {
          return Left(
            ServerFailure(jsonMap['message']?.toString() ?? "Failed"),
          );
        }
      }

      // handle non-200/201
      if (dataDyn is Map) {
        final jsonMap = _asStringKeyedMap(dataDyn);
        return Left(
          ServerFailure(
            jsonMap['message']?.toString() ?? "Something went wrong",
          ),
        );
      }

      return Left(ServerFailure("Something went wrong"));
    } on DioException catch (dioError) {
      final errorData = dioError.response?.data;
      if (errorData is Map) {
        final msg = (errorData['message'] ?? '').toString();
        if (msg.isNotEmpty) return Left(ServerFailure(msg));
      }
      return Left(ServerFailure(dioError.message ?? "Unknown Dio error"));
    } catch (e) {
      AppLogger.log.e(e);
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, AddEmployeeResponse>> addEmployee({
    // 1st screen
    required String phoneNumber,
    final String? employeeVerificationToken,
    required String fullName,
    required String email,
    required String emergencyContactName,
    required String emergencyContactRelationship,
    required String emergencyContactPhone,
    required String aadhaarNumber,
    required String aadhaarDocumentUrl,
    required String avatarUrl,
    bool isActive = true,
  }) async {
    try {
      final url = ApiUrl.addEmployees;
      final verification = await AppPrefs.getVerificationToken();
      final payload = {
        // "phoneNumber": '+91${phoneNumber}',
        "phoneNumber": toIndiaE164(phoneNumber),
        "employeeVerificationToken": verification,
        "fullName": fullName,
        "email": email,
        "emergencyContactName": emergencyContactName,
        "emergencyContactRelationship": emergencyContactRelationship,
        "emergencyContactPhone": emergencyContactPhone,
        "aadharNumber": aadhaarNumber,
        "aadharDocumentUrl": aadhaarDocumentUrl,
        "avatarUrl": avatarUrl,
        "isActive": isActive,
      };

      final response = await Request.sendRequest(url, payload, 'Post', true);

      AppLogger.log.i(response);

      final data = response.data;

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (data['status'] == true) {
          return Right(AddEmployeeResponse.fromJson(data));
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

  Future<Either<Failure, UserImageResponse>> userProfileUpload({
    required File imageFile,
  }) async {
    try {
      if (!await imageFile.exists()) {
        return Left(ServerFailure('Image file does not exist.'));
      }

      final url = ApiUrl.imageUrl;

      final formData = FormData.fromMap({
        'images': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
      });

      final response = await Request.formData(url, formData, 'POST', true);

      if (response is! Response) {
        return Left(ServerFailure('Invalid server response'));
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data as Map<String, dynamic>;

        if (data['status'] == true) {
          return Right(UserImageResponse.fromJson(data));
        } else {
          return Left(ServerFailure(data['message'] ?? 'Upload failed'));
        }
      }

      return Left(
        ServerFailure((response.data as Map?)?['message'] ?? 'Unknown error'),
      );
    } catch (e, st) {
      final msg = e.toString();
      AppLogger.log.e("userProfileUpload error => $msg");
      return Left(ServerFailure(msg));
    }
  }

  //
  // Future<Either<Failure, UserImageResponse>> userProfileUpload({
  //   required File imageFile,
  // }) async
  // {
  //   try {
  //     if (!await imageFile.exists()) {
  //       return Left(ServerFailure('Image file does not exist.'));
  //     }
  //
  //     final url = ApiUrl.imageUrl;
  //
  //     final formData = FormData.fromMap({
  //       'images': await MultipartFile.fromFile(
  //         imageFile.path,
  //         filename: imageFile.path.split('/').last,
  //       ),
  //     });
  //
  //     final response = await Request.formData(url, formData, 'POST', true);
  //
  //     final Map<String, dynamic> responseData =
  //         jsonDecode(response.data) as Map<String, dynamic>;
  //
  //     if (response.statusCode == 200) {
  //       if (responseData['status'] == true) {
  //         return Right(UserImageResponse.fromJson(responseData));
  //       }
  //       return Left(
  //         ServerFailure(
  //           (responseData['message'] ?? 'Upload failed').toString(),
  //         ),
  //       );
  //     }
  //
  //     // Non-200 but got response body
  //     return Left(
  //       ServerFailure((responseData['message'] ?? 'Upload failed').toString()),
  //     );
  //   } catch (e) {
  //     // ✅ IMPORTANT: keep original error text for isOfflineMessage()
  //     final msg = e.toString();
  //     AppLogger.log.e("userProfileUpload error => $msg");
  //     return Left(ServerFailure(msg));
  //   }
  // }

  Future<Either<Failure, EmployeeListResponse>> getEmployeeList() async {
    try {
      final url = ApiUrl.employeeOverview;

      final response = await Request.sendGetRequest(url, {}, 'GET', true);

      AppLogger.log.i(response);

      final data = response?.data;

      if (response?.statusCode == 200 || response?.statusCode == 201) {
        if (data['status'] == true) {
          return Right(EmployeeListResponse.fromJson(data));
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
      print(e);
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, VendorDashboardResponse>> heaterHome({
    required String dateFrom,
    required String dateTo,
  }) async {
    try {
      final url = ApiUrl.heaterHome(dateFrom: dateFrom, dateTo: dateFrom);

      dynamic response = await Request.sendGetRequest(url, {}, 'GET', true);

      AppLogger.log.i(response);

      if (response is! DioException) {
        // If status code is success
        if (response.statusCode == 200 || response.statusCode == 201) {
          if (response.data['status'] == true) {
            return Right(VendorDashboardResponse.fromJson(response.data));
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
      AppLogger.log.e(e);
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, EmployeeHomeResponse>> employeeHome({
    required String date,
    required String page,
    required String limit,
    required String q,
  }) async {
    try {
      final url = ApiUrl.employeeHome(
        date: date,
        page: page,
        limit: limit,
        q: q,
      );

      dynamic response = await Request.sendGetRequest(url, {}, 'GET', true);

      AppLogger.log.i(response);

      if (response is! DioException) {
        // If status code is success
        if (response.statusCode == 200 || response.statusCode == 201) {
          if (response.data['status'] == true) {
            return Right(EmployeeHomeResponse.fromJson(response.data));
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
      AppLogger.log.e(e);
      return Left(ServerFailure(e.toString()));
    }
  }

  // Future<Either<Failure, LoginResponse>> ownerInfoNumberRequest({
  //   required String phone,
  // }) async {
  //   String url = ApiUrl.ownerInfoNumberRequest;
  //
  //   final response = await Request.sendRequest(
  //     url,
  //     {"ownerPhoneNumber": "+91$phone"},
  //     'Post',
  //     true,
  //   );
  //
  //   if (response is! DioException) {
  //     if (response.statusCode == 200 || response.statusCode == 201) {
  //       if (response.data['status'] == true) {
  //         return Right(LoginResponse.fromJson(response.data));
  //       } else {
  //         return Left(
  //           ServerFailure(response.data['message'] ?? "Login failed"),
  //         );
  //       }
  //     } else {
  //       return Left(
  //         ServerFailure(response.data['message'] ?? "Something went wrong"),
  //       );
  //     }
  //   } else {
  //     final errorData = response.response?.data;
  //     if (errorData is Map && errorData.containsKey('message')) {
  //       return Left(ServerFailure(errorData['message']));
  //     }
  //     return Left(ServerFailure(response.message ?? "Unknown Dio error"));
  //   }
  // }
  Future<Either<Failure, LoginResponse>> ownerInfoNumberRequest({
    required String phone,
  }) async {
    try {
      final response = await Request.sendRequest(
        ApiUrl.ownerInfoNumberRequest,
        {"ownerPhoneNumber": "+91$phone"},
        'Post',
        true,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data['status'] == true) {
          return Right(LoginResponse.fromJson(response.data));
        } else {
          return Left(ServerFailure(response.data['message']));
        }
      }

      return Left(
        ServerFailure(response.data['message'] ?? 'Something went wrong'),
      );
    }
    // 🔴 TIMEOUT
    on TimeoutException {
      return Left(ServerFailure('Request timed out. Please try again.'));
    }
    // 🔴 DIO ERRORS (4xx, 5xx, cancel, etc.)
    on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map && data['message'] != null) {
        return Left(ServerFailure(data['message']));
      }
      return Left(ServerFailure(e.message ?? 'Network error'));
    }
    // 🔴 INTERNET OFF / SOCKET
    on SocketException {
      return Left(ServerFailure('No internet connection'));
    }
    // 🔴 ANYTHING ELSE
    catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, OwnerOtpResponse>> ownerInfoOtpRequest({
    required String phone,
    required String code,
  }) async {
    try {
      final response = await Request.sendRequest(
        ApiUrl.ownerInfoNumberOtpRequest,
        {"ownerPhoneNumber": "+91$phone", "code": code},
        'POST',
        true,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data['status'] == true) {
          return Right(OwnerOtpResponse.fromJson(response.data));
        }
        return Left(ServerFailure(response.data['message'] ?? "OTP failed"));
      }

      return Left(ServerFailure("Unexpected server response"));
    } on DioException catch (e) {
      // ⛔ timeout handling
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return Left(
          ServerFailure("Request timed out. Check your internet connection."),
        );
      }

      // ⛔ server error message
      final data = e.response?.data;
      if (data is Map && data['message'] != null) {
        return Left(ServerFailure(data['message']));
      }

      return Left(ServerFailure("Network error occurred"));
    } catch (_) {
      return Left(ServerFailure("Unexpected error"));
    }
  }

  Future<Either<Failure, OwnerRegisterResponse>> ownerInfoRegister({
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
    try {
      String url = ApiUrl.business;
      final verification = await AppPrefs.getVerificationToken();
      final response = await Request.sendRequest(
        url,
        {
          "businessType": businessType, //SERVICES or SELLING_PRODUCTS
          "ownershipType": ownershipType,
          "govtRegisteredName": govtRegisteredName,
          "preferredLanguage": preferredLanguage,
          "gender": gender.toUpperCase(),
          "dateOfBirth": dateOfBirth,
          "fullName": fullName,
          "ownerNameTamil": ownerNameTamil,
          "email": email,
          "ownerPhoneNumber": '+91${ownerPhoneNumber}',
          "phoneVerificationToken": verification,
        },

        'Post',
        true,
      );

      if (response is! DioException) {
        if (response.statusCode == 200 || response.statusCode == 201) {
          final body = response.data;

          if (body is Map && body['status'] == true) {
            // ✅ pass full response JSON here
            final shopResponse = OwnerRegisterResponse.fromJson(
              body as Map<String, dynamic>,
            );
            return Right(shopResponse);
          } else {
            return Left(
              ServerFailure(body['message'] ?? "Something went wrong"),
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
      AppLogger.log.e(e);
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, OwnerRegisterResponse>> shopInfoRegister({
    required String businessProfileId,
    required String category,
    required String subCategory,
    required String englishName,
    required String tamilName,
    required String descriptionEn,
    required String descriptionTa,
    required String addressEn,
    required String addressTa,
    required double gpsLatitude,
    required double gpsLongitude,
    required String primaryPhone,
    required String alternatePhone,
    required String contactEmail,
    required bool doorDelivery,
    required String ownerImageUrl,
    required String weeklyHours,
    required String apiShopId,
    String? primaryPhoneVerificationToken,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedShopId = prefs.getString('shop_id');

      String? finalShopId;
      if (savedShopId != null && savedShopId.trim().isNotEmpty) {
        finalShopId = savedShopId.trim();
      } else if (apiShopId.trim().isNotEmpty) {
        finalShopId = apiShopId.trim();
      }

      final bool isUpdate = finalShopId != null;
      final url =
          isUpdate ? ApiUrl.updateShop(shopId: finalShopId!) : ApiUrl.shops;

      final phoneVerifyToken = await AppPrefs.getVerificationToken();

      final body = <String, dynamic>{
        "businessProfileId": businessProfileId,
        "category": category,
        "subCategory": subCategory,
        "englishName": englishName,
        "tamilName": tamilName,
        "descriptionEn": descriptionEn,
        "descriptionTa": descriptionTa,
        "addressEn": addressEn,
        "addressTa": addressTa,
        "gpsLatitude": gpsLatitude,
        "gpsLongitude": gpsLongitude,
        "primaryPhone": primaryPhone,
        "alternatePhone": alternatePhone,
        "contactEmail": contactEmail,
        "doorDelivery": doorDelivery,
        "ownerImageUrl": ownerImageUrl,
        "weeklyHours": weeklyHours,
      };

      if (phoneVerifyToken != null && phoneVerifyToken.trim().isNotEmpty) {
        body["primaryPhoneVerificationToken"] = phoneVerifyToken.trim();
        body["phoneVerifyToken"] = phoneVerifyToken.trim();
      }

      final response = await Request.sendRequest(url, body, 'Post', true);

      if (response is! DioException) {
        if (response.statusCode == 200 || response.statusCode == 201) {
          final body = response.data;

          if (body is Map && body['status'] == true) {
            final shopResponse = OwnerRegisterResponse.fromJson(
              body as Map<String, dynamic>,
            );
            return Right(shopResponse);
          } else {
            return Left(
              ServerFailure(body['message'] ?? "Something went wrong"),
            );
          }
        } else {
          return Left(
            ServerFailure(response.data['message'] ?? "Something went wrong"),
          );
        }
      } else {
        // ✅ response is DioException
        final err = response.error;

        final isNetwork =
            err is SocketException ||
            response.type == DioExceptionType.connectionError ||
            response.type == DioExceptionType.connectionTimeout ||
            response.type == DioExceptionType.receiveTimeout ||
            response.type == DioExceptionType.sendTimeout;

        if (isNetwork) {
          final msg =
              "SocketException: ${err is SocketException ? err.message : (response.message ?? "Network error")}";
          return Left(ServerFailure(msg));
        }

        final errorData = response.response?.data;
        if (errorData is Map && errorData.containsKey('message')) {
          return Left(ServerFailure(errorData['message'].toString()));
        }

        return Left(ServerFailure(response.message ?? "Unknown Dio error"));
      }
    } catch (e) {
      // ✅ if socket happens here, still matches offline
      AppLogger.log.e(e);
      return Left(ServerFailure(e.toString()));
    }
  }

  /* Future<Either<Failure, OwnerRegisterResponse>> shopInfoRegister({
    required String businessProfileId,
    required String category,
    required String subCategory,
    required String englishName,
    required String tamilName,
    required String descriptionEn,
    required String descriptionTa,
    required String addressEn,
    required String addressTa,
    required double gpsLatitude,
    required double gpsLongitude,
    String? primaryPhoneVerificationToken,
    required String primaryPhone,
    required String alternatePhone,
    required String contactEmail,
    required bool doorDelivery,
    required String ownerImageUrl,
    required String weeklyHours,
    required String apiShopId,
  }) async {
    try {
      // String url = ApiUrl.shops;

      final prefs = await SharedPreferences.getInstance();

      final savedShopId = prefs.getString('shop_id');

      // ✅ Priority: 1) SharedPrefs → 2) apiShopId → 3) create new
      String? finalShopId;
      if (savedShopId != null && savedShopId.isNotEmpty) {
        finalShopId = savedShopId;
      } else if (apiShopId != null && apiShopId.isNotEmpty) {
        finalShopId = apiShopId;
      }

      final bool isUpdate = finalShopId != null;
      final url =
          isUpdate
              ? ApiUrl.updateShop(shopId: finalShopId)
              : ApiUrl.shops; // create

      final phoneVerifyToken = await AppPrefs.getVerificationToken();

      final response = await Request.sendRequest(
        url,
        {
          "businessProfileId": businessProfileId,
          "category": category,
          "subCategory": subCategory,
          "englishName": englishName,
          "tamilName": tamilName,
          "descriptionEn": descriptionEn,
          "descriptionTa": descriptionTa,
          "addressEn": addressEn,
          "addressTa": addressTa,
          "gpsLatitude": gpsLatitude,
          "gpsLongitude": gpsLongitude,
          "primaryPhone": primaryPhone,
          "alternatePhone": alternatePhone,
          "contactEmail": contactEmail,
          "doorDelivery": doorDelivery,
          "ownerImageUrl": ownerImageUrl,
          "weeklyHours": weeklyHours,

          // ✅ IMPORTANT: backend expects this
          if (phoneVerifyToken != null && phoneVerifyToken.isNotEmpty)
            "primaryPhoneVerificationToken": phoneVerifyToken,

          // ✅ keep this also (safe fallback)
          if (phoneVerifyToken != null && phoneVerifyToken.isNotEmpty)
            "phoneVerifyToken": phoneVerifyToken,
        },

        'Post',
        true,
      );

      if (response is! DioException) {
        if (response.statusCode == 200 || response.statusCode == 201) {
          final body = response.data;

          if (body is Map && body['status'] == true) {
            //  pass full response JSON here
            final shopResponse = OwnerRegisterResponse.fromJson(
              body as Map<String, dynamic>,
            );
            return Right(shopResponse);
          } else {
            return Left(
              ServerFailure(body['message'] ?? "Something went wrong"),
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
      AppLogger.log.e(e);
      return Left(ServerFailure(e.toString()));
    }
  }
*/

  Future<Either<Failure, ShopNumberVerifyResponse>> shopAddNumberRequest({
    required String phone,
    required String type,
  }) async {
    try {
      final String url = ApiUrl.shopNumberVerify;

      final response = await Request.sendRequest(
        url,
        {"phone": "+91$phone", "type": type},
        'Post',
        true,
      );

      // If your Request.sendRequest sometimes returns DioException instead of throwing
      if (response is DioException) {
        final errorData = response.response?.data;

        if (errorData is Map && errorData['message'] != null) {
          return Left(ServerFailure(errorData['message'].toString()));
        }

        return Left(ServerFailure(response.message ?? "Unknown Dio error"));
      }

      // Normal success response path
      final statusCode = response.statusCode ?? 0;

      if (statusCode == 200 || statusCode == 201) {
        final data = response.data;

        // Defensive: ensure it's a map-like json
        if (data is Map && data['status'] == true) {
          return Right(ShopNumberVerifyResponse.fromJson(response.data));
        }

        final message =
            (data is Map && data['message'] != null)
                ? data['message'].toString()
                : "Login failed";
        return Left(ServerFailure(message));
      }

      final message =
          (response.data is Map && response.data['message'] != null)
              ? response.data['message'].toString()
              : "Something went wrong";

      return Left(ServerFailure(message));
    } on DioException catch (e) {
      // If DioException is thrown (common Dio behavior)
      final errorData = e.response?.data;

      if (errorData is Map && errorData['message'] != null) {
        return Left(ServerFailure(errorData['message'].toString()));
      }

      return Left(ServerFailure(e.message ?? "Dio error"));
    } catch (e) {
      // Any other unexpected error
      print(e);
      AppLogger.log.e(e);
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, ShopNumberOtpResponse>> shopAddOtpRequest({
    required String phone,
    required String type,
    required String code,
  }) async {
    final url = ApiUrl.shopNumberOtpVerify;

    try {
      final response = await Request.sendRequest(
        url,
        {"phone": "+91$phone", "code": code, "type": type},
        'Post',
        true,
      );

      // assuming response is a Dio Response
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data['status'] == true) {
          return Right(ShopNumberOtpResponse.fromJson(response.data));
        } else {
          return Left(
            ServerFailure(response.data['message'] ?? "Login failed"),
          );
        }
      }

      return Left(
        ServerFailure(response.data?['message'] ?? "Something went wrong"),
      );
    } on DioException catch (e) {
      final data = e.response?.data;

      // best-effort message extraction
      if (data is Map && data['message'] != null) {
        return Left(ServerFailure(data['message'].toString()));
      }

      // 522 often means gateway/origin timeout
      if (e.response?.statusCode == 522) {
        return Left(ServerFailure("Server timeout (522). Please try again."));
      }

      return Left(ServerFailure(e.message ?? "Network error"));
    } catch (e) {
      print(e);
      AppLogger.log.e(e);
      return Left(ServerFailure("Unexpected error: $e"));
    }
  }

  Future<Either<Failure, CategoryListResponse>> getShopCategories() async {
    try {
      String url = ApiUrl.categoriesShop;

      dynamic response = await Request.sendGetRequest(url, {}, 'Get', true);

      AppLogger.log.i(response);

      if (response is! DioException) {
        // If status code is success
        if (response.statusCode == 200 || response.statusCode == 201) {
          return Right(CategoryListResponse.fromJson(response.data));
          // if (response.data['status'] == true) {
          //   return Right(ShopCategoryListResponse.fromJson(response.data));
          // } else {
          //   return Left(
          //     ServerFailure(response.data['message'] ?? "Login failed"),
          //   );
          // }
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
      print(e);
      return Left(ServerFailure(e.toString()));
    }
  }
  //
  // Future<Either<Failure, ShopInfoPhotosResponse>> shopPhotoUpload({
  //   required List<Map<String, String>> items,
  //   String? apiShopId,
  // }) async {
  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //
  //     final shopId = await AppPrefs.getSopId();
  //
  //     // ❗ FIXED: remove `?? ''`
  //     final url = ApiUrl.shopPhotosUpload(shopId: shopId ?? '');
  //
  //     final payload = {"items": items};
  //
  //     final response = await Request.sendRequest(url, payload, 'POST', true);
  //
  //     AppLogger.log.i(payload);
  //     AppLogger.log.i(response);
  //
  //     if (response is! DioException) {
  //       if (response.statusCode == 200 || response.statusCode == 201) {
  //         if (response.data['status'] == true) {
  //           return Right(ShopInfoPhotosResponse.fromJson(response.data));
  //         } else {
  //           return Left(
  //             ServerFailure(response.data['message'] ?? "Upload failed"),
  //           );
  //         }
  //       } else {
  //         return Left(
  //           ServerFailure(response.data['message'] ?? "Something went wrong"),
  //         );
  //       }
  //     } else {
  //       final errorData = response.response?.data;
  //       if (errorData is Map && errorData.containsKey('message')) {
  //         return Left(ServerFailure(errorData['message']));
  //       }
  //       return Left(ServerFailure(response.message ?? "Unknown Dio error"));
  //     }
  //   } catch (e) {
  //     return Left(ServerFailure(e.toString()));
  //   }
  // }

  Future<Either<Failure, ShopInfoPhotosResponse>> shopPhotoUpload({
    required List<Map<String, String>> items,
    String? apiShopId,
  }) async {
    try {
      final shopId = await AppPrefs.getSopId();
      final url = ApiUrl.shopPhotosUpload(shopId: shopId ?? '');

      final payload = {"items": items};

      final response = await Request.sendRequest(url, payload, 'POST', true);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data['status'] == true) {
          return Right(ShopInfoPhotosResponse.fromJson(response.data));
        }
        return Left(ServerFailure(response.data['message'] ?? "Upload failed"));
      }

      return Left(
        ServerFailure(response.data['message'] ?? "Something went wrong"),
      );
    } on DioException catch (e) {
      final errorData = e.response?.data;
      if (errorData is Map && errorData['message'] != null) {
        return Left(ServerFailure(errorData['message'].toString()));
      }
      return Left(ServerFailure(e.message ?? "Network error"));
    } catch (e) {
      AppLogger.log.e(e);
      print(e);
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, ShopCategoryApiResponse>> searchKeywords({
    required List<String> keywords,
  }) async {
    try {
      final shopId = await AppPrefs.getSopId();
      final url = ApiUrl.searchKeyWords(shopId: shopId ?? '');

      final payload = {"keywords": keywords};

      final response = await Request.sendRequest(url, payload, 'POST', true);

      AppLogger.log.i(payload);
      AppLogger.log.i(response);

      if (response is! DioException) {
        if (response.statusCode == 200 || response.statusCode == 201) {
          if (response.data['status'] == true) {
            return Right(ShopCategoryApiResponse.fromJson(response.data));
          } else {
            return Left(
              ServerFailure(response.data['message'] ?? "Something went wrong"),
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
    } catch (e, st) {
      AppLogger.log.e(e);
      AppLogger.log.e(st);
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, CategoryListResponse>> getProductCategories({
    String? apiShopId,
  }) async {
    try {
      final savedShopId = await AppPrefs.getSopId();

      // priority: apiShopId → savedShopId → empty
      final shopId =
          (apiShopId != null && apiShopId.trim().isNotEmpty)
              ? apiShopId
              : (savedShopId ?? '');

      final url = ApiUrl.productCategoryList(shopId: shopId ?? '');
      dynamic response = await Request.sendGetRequest(url, {}, 'Get', true);

      AppLogger.log.i(response);

      if (response is! DioException) {
        // If status code is success
        if (response.statusCode == 200 || response.statusCode == 201) {
          return Right(CategoryListResponse.fromJson(response.data));
          // if (response.data['status'] == true) {
          //   return Right(ShopCategoryListResponse.fromJson(response.data));
          // } else {
          //   return Left(
          //     ServerFailure(response.data['message'] ?? "Login failed"),
          //   );
          // }
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
      print(e);
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, ProductResponse>> addProduct({
    required String category,
    required String subCategory,
    required String englishName,
    required int price,
    required String offerLabel,
    required String offerValue,
    String? apiShopId,
    String? apiProductId,
    required String description,
    required bool doorDelivery,
  }) async {
    try {
      // 🔹 SHOP ID: can fallback to prefs
      final shopId = await AppPrefs.getSopId();
      String? productId = apiProductId ?? await AppPrefs.getProductId();

      final shopIdToUse =
          (apiShopId != null && apiShopId.trim().isNotEmpty)
              ? apiShopId
              : (shopId ?? '');

      // if (shopIdToUse == null || shopIdToUse.isEmpty) {
      //   return Left(
      //     ServerFailure("Shop not found. Please complete shop setup first."),
      //   );
      // }

      // 🔹 PRODUCT ID: ONLY use what caller sends
      // final String? productId = apiProductId; // ❗ no prefs fallback here

      final String url =
          (productId != null && productId.isNotEmpty)
              ? ApiUrl.updateProducts(productId: productId) // UPDATE
              : ApiUrl.addProducts(shopId: shopIdToUse ?? ''); // CREATE

      final payload = {
        "category": category,
        "subCategory": subCategory,
        "englishName": englishName,
        "price": price,
        "offerLabel": offerLabel,
        "offerValue": offerValue,
        "description": description,
        "doorDelivery": doorDelivery,
      };

      final response = await Request.sendRequest(url, payload, 'Post', true);

      if (response is! Response) {
        return Left(ServerFailure("Invalid response from server"));
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;

        if (data["status"] == true) {
          return Right(ProductResponse.fromJson(data));
        } else {
          return Left(ServerFailure(data['message'] ?? "Request failed"));
        }
      }

      return Left(
        ServerFailure(response.data['message'] ?? "Something went wrong"),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, ProductResponse>> updateProducts({
    required List<String> images,
    required List<Map<String, String>> features,
  }) async {
    try {
      final getProductId = await AppPrefs.getProductId();

      String url = ApiUrl.updateProducts(productId: getProductId ?? '');

      // ✅ Use the actual images + features passed from caller
      final payload = {"images": images, "features": features};

      dynamic response = await Request.sendRequest(url, payload, 'Post', true);

      AppLogger.log.i(response);
      AppLogger.log.i(payload);

      if (response is! DioException) {
        if (response.statusCode == 200 || response.statusCode == 201) {
          if (response.data['status'] == true) {
            return Right(ProductResponse.fromJson(response.data));
          } else {
            return Left(
              ServerFailure(response.data['message'] ?? "Update failed"),
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
      AppLogger.log.e(e);
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, ProductResponse>> updateSearchKeyWords({
    required List<String> keywords,
  }) async {
    try {
      final productId = await AppPrefs.getProductId();

      String url = ApiUrl.updateProducts(productId: productId ?? '');

      final payload = {"keywords": keywords};

      dynamic response = await Request.sendRequest(url, payload, 'Post', true);

      AppLogger.log.i(response);
      AppLogger.log.i(payload);

      if (response is! DioException) {
        if (response.statusCode == 200 || response.statusCode == 201) {
          if (response.data['status'] == true) {
            return Right(ProductResponse.fromJson(response.data));
          } else {
            return Left(
              ServerFailure(response.data['message'] ?? "Update failed"),
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
      AppLogger.log.e(e);
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, ShopDetailsResponse>> getShopDetails({
    String? apiShopId,
  }) async {
    try {
      final savedShopId = await AppPrefs.getSopId();

      // Priority: apiShopId > savedShopId > ""
      final shopId =
          (apiShopId != null && apiShopId.trim().isNotEmpty)
              ? apiShopId
              : (savedShopId ?? '');

      final url = ApiUrl.shopDetails(shopId: shopId);

      dynamic response = await Request.sendGetRequest(url, {}, 'Post', true);

      AppLogger.log.i(response);

      if (response is! DioException) {
        // If status code is success
        if (response.statusCode == 200 || response.statusCode == 201) {
          if (response.data['status'] == true) {
            return Right(ShopDetailsResponse.fromJson(response.data));
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
      AppLogger.log.e(e);
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, EmployeeDetailsResponse>> heaterEmployeeDetails({
    required String employeeId,
  }) async {
    try {
      final url = ApiUrl.heaterEmployeeDetails(employeeId: employeeId);

      dynamic response = await Request.sendGetRequest(url, {}, 'GET', true);

      AppLogger.log.i(response);

      if (response is! DioException) {
        if (response.statusCode == 200 || response.statusCode == 201) {
          if (response.data['status'] == true) {
            return Right(EmployeeDetailsResponse.fromJson(response.data));
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
      AppLogger.log.e(e);
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, EmployeeUpdateResponse>> heaterEmployeeEdit({
    required String employeeId,
    String? employeeVerificationToken,
    String? phoneNumber,
    String? fullName,
    String? email,
    String? emergencyContactName,
    String? emergencyContactRelationship,
    String? emergencyContactPhone,
    String? aadhaarNumber,
    String? aadhaarDocumentUrl,
    String? avatarUrl,
  }) async {
    try {
      final url = ApiUrl.heaterEmployeeEdit(employeeId: employeeId);
      final verification = await AppPrefs.getVerificationToken();

      // ✅ start with only required key(s)
      final Map<String, dynamic> payload = {
        "employeeVerificationToken": verification,
      };

      // ✅ helper: add only if not null & not empty
      void put(String key, String? value) {
        if (value == null) return;
        final v = value.trim();
        if (v.isEmpty) return;
        payload[key] = v;
      }

      // ✅ phone number: add only if present
      if (phoneNumber != null && phoneNumber.trim().isNotEmpty) {
        payload["phoneNumber"] = '+91${normalizeIndianPhone(phoneNumber)}';
      }

      // ✅ normal fields
      put("fullName", fullName);
      put("email", email);

      put("emergencyContactName", emergencyContactName);
      put("emergencyContactRelationship", emergencyContactRelationship);

      // ✅ emergency phone: add only if present
      if (emergencyContactPhone != null &&
          emergencyContactPhone.trim().isNotEmpty) {
        payload["emergencyContactPhone"] =
            '+91${normalizeIndianPhone(emergencyContactPhone)}';
      }

      put("aadharNumber", aadhaarNumber);
      put("aadharDocumentUrl", aadhaarDocumentUrl);
      put("avatarUrl", avatarUrl);

      final response = await Request.sendRequest(url, payload, 'Post', true);

      AppLogger.log.i(response);

      if (response is! DioException) {
        if (response.statusCode == 200 || response.statusCode == 201) {
          if (response.data['status'] == true) {
            return Right(EmployeeUpdateResponse.fromJson(response.data));
          } else {
            return Left(
              ServerFailure(response.data['message'] ?? "Update failed"),
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
      AppLogger.log.e(e);
      return Left(ServerFailure(e.toString()));
    }
  }

  // Future<Either<Failure, EmployeeUpdateResponse>> heaterEmployeeEdit({
  //   required String employeeId,
  //   String? employeeVerificationToken,
  //   String? phoneNumber,
  //   String? fullName,
  //   String? email,
  //   String? emergencyContactName,
  //   String? emergencyContactRelationship,
  //   String? emergencyContactPhone,
  //   String? aadhaarNumber,
  //   String? aadhaarDocumentUrl,
  //   String? avatarUrl,
  // }) async {
  //   try {
  //     final url = ApiUrl.heaterEmployeeEdit(employeeId: employeeId);
  //     final verification = await AppPrefs.getVerificationToken();
  //
  //     final payload = {
  //       // "phoneNumber": '+91${phoneNumber}',
  //       "phoneNumber":
  //           phoneNumber == null || phoneNumber.trim().isEmpty
  //               ? null
  //               : '+91${normalizeIndianPhone(phoneNumber)}',
  //       "employeeVerificationToken": verification,
  //       "fullName": fullName,
  //       "email": email,
  //       "emergencyContactName": emergencyContactName,
  //       "emergencyContactRelationship": emergencyContactRelationship,
  //       // "emergencyContactPhone": '+91${emergencyContactPhone}',
  //       "emergencyContactPhone":
  //           emergencyContactPhone == null ||
  //                   emergencyContactPhone.trim().isEmpty
  //               ? null
  //               : '+91${normalizeIndianPhone(emergencyContactPhone)}',
  //
  //       "aadharNumber": aadhaarNumber,
  //       "aadharDocumentUrl": aadhaarDocumentUrl,
  //       "avatarUrl": avatarUrl,
  //     };
  //
  //
  //     final response = await Request.sendRequest(url, payload, 'Post', true);
  //
  //     AppLogger.log.i(response);
  //
  //     if (response is! DioException) {
  //       if (response.statusCode == 200 || response.statusCode == 201) {
  //         if (response.data['status'] == true) {
  //           return Right(EmployeeUpdateResponse.fromJson(response.data));
  //         } else {
  //           return Left(
  //             ServerFailure(response.data['message'] ?? "Login failed"),
  //           );
  //         }
  //       } else {
  //         // ❗ API returned non-success code but has JSON error message
  //         return Left(
  //           ServerFailure(response.data['message'] ?? "Something went wrong"),
  //         );
  //       }
  //     } else {
  //       final errorData = response.response?.data;
  //       if (errorData is Map && errorData.containsKey('message')) {
  //         return Left(ServerFailure(errorData['message']));
  //       }
  //       return Left(ServerFailure(response.message ?? "Unknown Dio error"));
  //     }
  //   } catch (e) {
  //     AppLogger.log.e(e);
  //     return Left(ServerFailure(e.toString()));
  //   }
  // }

  Future<Either<Failure, HeaterEmployeeResponse>> heaterEmployee() async {
    try {
      final url = ApiUrl.heaterEmployee;

      dynamic response = await Request.sendGetRequest(url, {}, 'GET', true);

      AppLogger.log.i(response);

      if (response is! DioException) {
        if (response.statusCode == 200 || response.statusCode == 201) {
          if (response.data['status'] == true) {
            return Right(HeaterEmployeeResponse.fromJson(response.data));
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
      AppLogger.log.e(e);
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, ServiceInfoResponse>> serviceInfo({
    required String title,
    required String tamilName,
    required String description,
    required int startsAt,
    required String offerLabel,
    required String offerValue,
    required int durationMinutes,
    required String categoryId,
    String? apiShopId,
    required String apiServiceId,
    required String subCategory,
    required List<String> tags,
  }) async {
    try {
      final savedServiceId = await AppPrefs.getServiceId();

      final serviceIdToUse =
          (apiServiceId != null && apiServiceId.trim().isNotEmpty)
              ? apiServiceId
              : (savedServiceId ?? '');
      AppLogger.log.i('Service id - $apiServiceId');

      final savedShopId = await AppPrefs.getSopId();
      final shopIdToUse =
          (apiShopId != null && apiShopId.trim().isNotEmpty)
              ? apiShopId
              : (savedShopId ?? '');
      AppLogger.log.i('ShopId Using -> $shopIdToUse');
      AppLogger.log.i('Shared prefs ShopId Using -> $savedShopId');

      // DECIDE CREATE OR EDIT API
      // apiServiceId is required but may be "", so we check empty only
      final url =
          serviceIdToUse.isNotEmpty
              ? ApiUrl.serviceEdit(serviceId: serviceIdToUse)
              : ApiUrl.serviceInfo(shopId: shopIdToUse);
      AppLogger.log.i("SERVICE URL → $url");
      final payload = {
        "title": title,
        "tamilName": tamilName,
        "description": description,
        "startsAt": startsAt,
        "offerLabel": offerLabel,
        "offerValue": offerValue,
        "durationMinutes": durationMinutes,
        "categoryId": categoryId,
        "subCategory": subCategory,
        "tags": tags,
      };

      final response = await Request.sendRequest(url, payload, 'Post', true);

      AppLogger.log.i(response);
      AppLogger.log.i(payload);

      if (response is! DioException) {
        if (response.statusCode == 200 || response.statusCode == 201) {
          final root = response.data as Map<String, dynamic>;
          if (root['status'] == true) {
            return Right(ServiceInfoResponse.fromJson(root));
          } else {
            return Left(
              ServerFailure(root['message'] ?? "Something went wrong"),
            );
          }
        } else {
          return Left(
            ServerFailure(
              (response.data is Map && response.data['message'] != null)
                  ? response.data['message']
                  : "Something went wrong",
            ),
          );
        }
      } else {
        final errorData = response.response?.data;
        if (errorData is Map && errorData['message'] != null) {
          return Left(ServerFailure(errorData['message'].toString()));
        }
        return Left(ServerFailure(response.message ?? "Unknown Dio error"));
      }
    } catch (e) {
      AppLogger.log.i(e);
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, ServiceInfoResponse>> serviceList({
    required List<String> images,
    required List<Map<String, String>> features,
  }) async {
    try {
      final serviceId = await AppPrefs.getServiceId();

      // Example: PATCH /api/v1/services/{serviceId}/info
      final String url = ApiUrl.serviceList(serviceId: serviceId ?? '');
      // Make sure ApiUrl.serviceList builds a SERVICE URL, not PRODUCTS

      final payload = {"images": images, "features": features};

      // If your backend uses PATCH → 'Patch'
      // If it uses PUT → 'Put'
      // Only keep 'Post' if your backend really expects POST here.
      dynamic response = await Request.sendRequest(url, payload, 'Post', true);

      AppLogger.log.i(response);
      AppLogger.log.i(payload);

      if (response is! DioException) {
        if (response.statusCode == 200 || response.statusCode == 201) {
          if (response.data['status'] == true) {
            return Right(ServiceInfoResponse.fromJson(response.data));
          } else {
            return Left(
              ServerFailure(response.data['message'] ?? "Update failed"),
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
      AppLogger.log.e(e);
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, ServiceInfoResponse>> serviceSearchKeyWords({
    required List<String> keywords,
  }) async {
    try {
      final serviceId = await AppPrefs.getServiceId();

      String url = ApiUrl.serviceList(serviceId: serviceId ?? '');

      // ✅ Use the actual images + features passed from caller
      final payload = {"keywords": keywords};

      dynamic response = await Request.sendRequest(url, payload, 'Post', true);

      AppLogger.log.i(response);
      AppLogger.log.i(payload);

      if (response is! DioException) {
        if (response.statusCode == 200 || response.statusCode == 201) {
          if (response.data['status'] == true) {
            return Right(ServiceInfoResponse.fromJson(response.data));
          } else {
            return Left(
              ServerFailure(response.data['message'] ?? "Update failed"),
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
      AppLogger.log.e(e);
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, ImageUploadResponse>> serviceImageUpload({
    required File imageFile,
  }) async {
    try {
      if (!await imageFile.exists()) {
        return Left(ServerFailure('Image file does not exist.'));
      }

      final String url = ApiUrl.imageUrl;

      final formData = FormData.fromMap({
        'images': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
      });

      final response = await Request.formData(url, formData, 'POST', true);

      if (response is! Response) {
        return Left(ServerFailure("Unexpected error type"));
      }

      // ✅ Safely handle both String and Map
      late final Map<String, dynamic> responseData;
      if (response.data is String) {
        responseData =
            jsonDecode(response.data as String) as Map<String, dynamic>;
      } else if (response.data is Map<String, dynamic>) {
        responseData = response.data as Map<String, dynamic>;
      } else {
        return Left(ServerFailure("Invalid response format"));
      }

      if (response.statusCode == 200) {
        if (responseData['status'] == true) {
          return Right(ImageUploadResponse.fromJson(responseData));
        } else {
          return Left(
            ServerFailure(responseData['message'] ?? 'Upload failed'),
          );
        }
      } else if (response.statusCode == 409) {
        return Left(ServerFailure(responseData['message'] ?? 'Conflict error'));
      } else {
        return Left(ServerFailure(responseData['message'] ?? "Unknown error"));
      }
    } catch (e) {
      print(e);
      return Left(ServerFailure('Something went wrong'));
    }
  }

  Future<Either<Failure, DeleteResponse>> deleteProduct({
    String? productId,
  }) async {
    try {
      final id = productId ?? await AppPrefs.getProductId();

      if (id == null || id.isEmpty) {
        return Left(ServerFailure("Product not found."));
      }

      final url = ApiUrl.deleteProduct(productId: id);

      final response = await Request.sendRequest(url, {}, 'DELETE', true);

      if (response is DioException) {
        return Left(ServerFailure(response.message ?? 'Delete failed'));
      }

      final map = response.data;
      if (map == null || map is! Map<String, dynamic>) {
        return const Right(DeleteResponse(status: true));
      }

      return Right(DeleteResponse.fromJson(map));
    } catch (_) {
      return Left(ServerFailure('Unexpected error'));
    }
  }

  Future<Either<Failure, ServiceRemoveResponse>> deleteService({
    String? serviceId,
  }) async {
    try {
      final id = serviceId ?? await AppPrefs.getServiceId();

      if (id == null || id.isEmpty) {
        return Left(ServerFailure("Service not found."));
      }

      final url = ApiUrl.serviceDelete(serviceId: id);

      final response = await Request.sendRequest(url, {}, 'DELETE', true);

      if (response is DioException) {
        AppLogger.log.e('❌ Dio error: ${response.message}');
        return Left(ServerFailure(response.message ?? 'Delete failed'));
      }

      // 🔴 LOG RAW RESPONSE
      AppLogger.log.i('🟢 RAW RESPONSE: ${response.data}');

      final map = response.data;

      if (map == null || map is! Map<String, dynamic>) {
        AppLogger.log.e('❌ Invalid response format');
        return Left(ServerFailure('Invalid response from server'));
      }

      // 🔴 LOG IMPORTANT VALUES
      AppLogger.log.i('🟢 status: ${map['status']}');
      AppLogger.log.i('🟢 success: ${map['data']?['success']}');

      final result = ServiceRemoveResponse.fromJson(map);

      // 🔴 LOG PARSED MODEL
      AppLogger.log.i(
        '🟢 Parsed → status=${result.status}, success=${result.data.success}',
      );

      return Right(result);
    } catch (e, st) {
      AppLogger.log.e('❌ deleteService exception: $e\n$st');
      return Left(ServerFailure('Unexpected error'));
    }
  }

  Future<Either<Failure, EmployeeUnblockResponse>> employeeUnblock({
    required String employeeId,
  }) async {
    try {
      final url = ApiUrl.employeeUnblock(employeeId: employeeId);

      final payload = {
        "isActive": true, // unblock = always true
      };

      final response = await Request.sendRequest(url, payload, 'POST', true);

      if (response is DioException) {
        final errorData = response.response?.data;
        return Left(
          ServerFailure(
            errorData is Map
                ? errorData['message'] ?? 'Request failed'
                : 'Network error',
          ),
        );
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data['status'] == true) {
          return Right(EmployeeUnblockResponse.fromJson(response.data));
        } else {
          return Left(
            ServerFailure(response.data['message'] ?? 'Unblock failed'),
          );
        }
      }

      return Left(ServerFailure('Unexpected status code'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, EmployeeUnblockResponse>> employeeBlock({
    required String employeeId,
    String? reason,
  }) async {
    try {
      final url = ApiUrl.employeeUnblock(
        employeeId: employeeId,
      ); // same endpoint

      final payload = {
        "isActive": false,
        if (reason != null) "blockedReason": reason,
      };

      final response = await Request.sendRequest(url, payload, 'POST', true);

      if (response is DioException) {
        final errorData = response.response?.data;
        return Left(
          ServerFailure(
            errorData is Map
                ? errorData['message'] ?? 'Request failed'
                : 'Network error',
          ),
        );
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data['status'] == true) {
          return Right(EmployeeUnblockResponse.fromJson(response.data));
        } else {
          return Left(
            ServerFailure(response.data['message'] ?? 'Block failed'),
          );
        }
      }

      return Left(ServerFailure('Unexpected status code'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, MaskedContactResponse>> employeeAddNumberRequest({
    required String phone,
  }) async {
    String url = ApiUrl.employeeAddNumber;

    final response = await Request.sendRequest(
      url,
      {"phoneNumber": "+91$phone"},
      'Post',
      true,
    );

    if (response is! DioException) {
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data['status'] == true) {
          return Right(MaskedContactResponse.fromJson(response.data));
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
  }

  Future<Either<Failure, VerificationResponse>> employeeAddOtpRequest({
    required String phone,
    required String code,
  }) async {
    String url = ApiUrl.employeeAddOtp;

    final response = await Request.sendRequest(
      url,
      {"phoneNumber": "+91$phone", "code": code},
      'Post',
      true,
    );

    if (response is! DioException) {
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data['status'] == true) {
          return Right(VerificationResponse.fromJson(response.data));
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
  }

  Future<Either<Failure, EmployeeChangeNumber>> employeeUpdateNumberRequest({
    required String phone,
  }) async {
    String url = ApiUrl.employeeUpdateNumber;

    final response = await Request.sendRequest(
      url,
      {"phoneNumber": "+91$phone"},
      'Post',
      true,
    );

    if (response is! DioException) {
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data['status'] == true) {
          return Right(EmployeeChangeNumber.fromJson(response.data));
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
  }

  Future<Either<Failure, PhoneVerificationResponse>> employeeUpdateOtpRequest({
    required String phone,
    required String code,
  }) async {
    String url = ApiUrl.employeeUpdateOtp;

    final response = await Request.sendRequest(
      url,
      {"phoneNumber": "+91$phone", "code": code},
      'Post',
      true,
    );

    if (response is! DioException) {
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data['status'] == true) {
          return Right(PhoneVerificationResponse.fromJson(response.data));
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
  }

  Future<Either<Failure, VendorHistoryResponse>> vendorHistory({
    required String limit,
    required String page,
    String? q,
    String? categories,
    String? dateFrom,
    String? dateTo,
  }) async {
    try {
      final url = ApiUrl.vendorHistory(
        page: page,
        limit: limit,
        categories: categories,
        dateFrom: dateFrom,
        dateTo: dateTo,
        search: q,
      );

      dynamic response = await Request.sendGetRequest(url, {}, 'get', true);

      AppLogger.log.i(response);

      if (response is! DioException) {
        // If status code is success
        if (response.statusCode == 200 || response.statusCode == 201) {
          if (response.data['status'] == true) {
            return Right(VendorHistoryResponse.fromJson(response.data));
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
      AppLogger.log.e(e);
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, PlanListResponse>> getPlanList() async {
    try {
      final url = ApiUrl.plans;

      dynamic response = await Request.sendGetRequest(url, {}, 'GET', true);

      AppLogger.log.i(response);

      if (response is! DioException) {
        if (response.statusCode == 200 || response.statusCode == 201) {
          if (response.data['status'] == true) {
            return Right(PlanListResponse.fromJson(response.data));
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
    } catch (e, st) {
      AppLogger.log.e(e);
      AppLogger.log.e(st);
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, PurchaseResponse>> purchasePlan({
    required String planId,
    required String businessProfileId,
  }) async {
    try {
      final url = ApiUrl.purchase;

      dynamic response = await Request.sendRequest(
        url,
        {"planId": planId, "businessProfileId": businessProfileId},
        'POST',
        true,
      );

      AppLogger.log.i(response);

      if (response is! DioException) {
        if (response.statusCode == 200 || response.statusCode == 201) {
          if (response.data['status'] == true) {
            return Right(PurchaseResponse.fromJson(response.data));
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
      AppLogger.log.e(e);
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, CurrentPlanResponse>> getCurrentPlan({
    required String businessProfileId,
  }) async {
    try {
      final url = ApiUrl.currentPlans(businessProfileId: businessProfileId);

      dynamic response = await Request.sendGetRequest(url, {}, 'GET', true);

      AppLogger.log.i(response);

      if (response is! DioException) {
        if (response.statusCode == 200 || response.statusCode == 201) {
          if (response.data['status'] == true) {
            return Right(CurrentPlanResponse.fromJson(response.data));
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
      AppLogger.log.e(e);
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, AppVersionResponse>> getAppVersion({
    required String appName,
    required String appVersion,
    required String appPlatForm,
  }) async {
    try {
      final url = ApiUrl.version;

      dynamic response = await Request.sendGetRequest(
        url,
        {},
        'GET',
        false,
        appName: appName,
        appPlatForm: appPlatForm,
        appVersion: appVersion,
      );

      AppLogger.log.i(response);

      if (response is! DioException) {
        if (response.statusCode == 200 || response.statusCode == 201) {
          if (response.data['status'] == true) {
            return Right(AppVersionResponse.fromJson(response.data));
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
      AppLogger.log.e(e);
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, ContactResponse>> syncContacts({
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      final url = ApiUrl.contactInfo;
      final payload = {"items": items};

      final response = await Request.sendRequest(url, payload, 'Post', true);

      AppLogger.log.i(response);

      if (response is DioException) {
        final errorData = response.response?.data;
        if (errorData is Map && errorData.containsKey('message')) {
          return Left(ServerFailure("${errorData['message']}"));
        }
        return Left(ServerFailure(response.message ?? "Unknown Dio error"));
      }

      final code = response.statusCode ?? 0;
      if (code == 200 || code == 201) {
        final data = response.data;
        if (data is Map && data['status'] == true) {
          return Right(
            ContactResponse.fromJson(Map<String, dynamic>.from(data)),
          );
        }
        return Left(
          ServerFailure("${response.data?['message'] ?? "Sync failed"}"),
        );
      }

      return Left(
        ServerFailure("${response.data?['message'] ?? "Something went wrong"}"),
      );
    } catch (e) {
      AppLogger.log.e(e);
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, AccountDeleteResponse>> accountDelete() async {
    try {
      final url = ApiUrl.accountDelete;

      final response = await Request.sendRequest(url, {}, 'DELETE', true);

      // dynamic response = await Request.sendGetRequest(url, {}, 'GET', true);

      AppLogger.log.i(response);

      if (response is! DioException) {
        if (response.statusCode == 200 || response.statusCode == 201) {
          if (response.data['status'] == true) {
            return Right(AccountDeleteResponse.fromJson(response.data));
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
      AppLogger.log.e(e);
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, SupportListResponse>> supportList() async {
    try {
      final String url = ApiUrl.supportTicketsList;

      final response = await Request.sendGetRequest(url, {}, 'GET', true);

      AppLogger.log.i(response);

      final data = response?.data;

      if (response?.statusCode == 200 || response?.statusCode == 201) {
        if (data['status'] == true) {
          return Right(SupportListResponse.fromJson(data));
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
      print(e);
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, CreateSupportResponse>> createSupportTicket({
    required String subject,
    required String description,
    required String imageUrl,
    required dynamic attachments,
  }) async {
    try {
      final String url = ApiUrl.supportTicketsList;
      final Map<String, dynamic> body = {
        "subject": subject,
        "description": description,
        "attachments": [
          {"url": imageUrl},
        ],
      };

      final response = await Request.sendRequest(url, body, 'POST', true);

      AppLogger.log.i(response);

      if (response is! DioException) {
        if (response.statusCode == 200 || response.statusCode == 201) {
          if (response.data['status'] == true) {
            return Right(CreateSupportResponse.fromJson(response.data));
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

  Future<Either<Failure, ChatMessageResponse>> getChatMessages({
    required String id,
  }) async {
    try {
      final String url = ApiUrl.getChatMessages(id: id);

      final response = await Request.sendGetRequest(url, {}, 'GET', true);

      AppLogger.log.i(response);

      final data = response?.data;

      if (response?.statusCode == 200 || response?.statusCode == 201) {
        if (data['status'] == true) {
          return Right(ChatMessageResponse.fromJson(data));
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
      print(e);
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, SendMessageResponse>> sendMessage({
    required String subject,

    required String imageUrl,
    required String ticketId,
    required dynamic attachments,
  }) async {
    try {
      final String url = ApiUrl.sendMessage(ticketId: ticketId);
      final Map<String, dynamic> body = {
        "message": subject,

        "attachments": [
          {"url": imageUrl},
        ],
      };

      final response = await Request.sendRequest(url, body, 'POST', true);

      AppLogger.log.i(response);

      if (response is! DioException) {
        if (response.statusCode == 200 || response.statusCode == 201) {
          if (response.data['status'] == true) {
            return Right(SendMessageResponse.fromJson(response.data));
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

  Future<Either<Failure, GetProfileResponse>> getProfile() async {
    try {
      final url = ApiUrl.vendorRegister;

      final response = await Request.sendGetRequest(url, {}, 'GET', true);

      AppLogger.log.i(response);

      final data = response?.data;

      if (response?.statusCode == 200 || response?.statusCode == 201) {
        if (data['status'] == true) {
          return Right(GetProfileResponse.fromJson(data));
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
      print(e);
      AppLogger.log.e(e);
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, VendorResponse>> onlyProfileChange({
    String? avatarUrl,
  }) async {
    try {
      final url = ApiUrl.vendorRegister;

      final payload = {"avatarUrl": avatarUrl};

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

  Future<Either<Failure, TermsAndConditionResponse>>
  fetchTermsAndCondition() async {
    try {
      final url = ApiUrl.privacyPolicy;

      final response = await Request.sendGetRequest(url, {}, 'GET', true);

      AppLogger.log.i(response);

      final data = response?.data;

      if (response?.statusCode == 200 || response?.statusCode == 201) {
        if (data['status'] == true) {
          return Right(TermsAndConditionResponse.fromJson(data));
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
      print(e);
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, CategoryKeywordsResponse>> getKeyWords({required String type, required String query}) async {
    try {
      String url = ApiUrl.getKeyWords(type: type, query: query);

      dynamic response = await Request.sendGetRequest(url, {}, 'Get', true);

      AppLogger.log.i(response);

      if (response is! DioException) {
        // If status code is success
        if (response.statusCode == 200 || response.statusCode == 201) {
          return Right(CategoryKeywordsResponse.fromJson(response.data));
          // if (response.data['status'] == true) {
          //   return Right(ShopCategoryListResponse.fromJson(response.data));
          // } else {
          //   return Left(
          //     ServerFailure(response.data['message'] ?? "Login failed"),
          //   );
          // }
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
      print(e);
      return Left(ServerFailure(e.toString()));
    }
  }
}
