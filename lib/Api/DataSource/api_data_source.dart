import 'dart:convert';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tringo_vendor_new/Core/Const/app_logger.dart';
import 'package:tringo_vendor_new/Presentation/AddProduct/Model/product_response.dart';
import 'package:tringo_vendor_new/Presentation/Heater/Add%20Vendor%20Employee/Model/add_employee_response.dart';
import 'package:tringo_vendor_new/Presentation/Heater/Add%20Vendor%20Employee/Model/employee_list_response.dart';
import 'package:tringo_vendor_new/Presentation/Heater/Employee%20details-edit/Model/heater_employee_edit_res.dart';

import '../../Presentation/Employee History/Model/employee_history_response.dart';
import 'package:tringo_vendor_new/Presentation/Owner%20Screen/Model/owner_otp_response.dart';
import 'package:tringo_vendor_new/Presentation/Owner%20Screen/Model/owner_register_response.dart';
import 'package:tringo_vendor_new/Presentation/ShopInfo/Model/category_list_response.dart';

import '../../Core/Utility/app_prefs.dart';
import '../../Presentation/Heater/Add Vendor Employee/Model/user_image_response.dart';
import '../../Presentation/Heater/Employee Details/Model/employeeDetailsResponse.dart';
import '../../Presentation/Heater/Employees/Model/heater_employee_response.dart';
import '../../Presentation/Heater/Heater Home Screen/Model/heater_home_response.dart';
import '../../Presentation/Heater/Heater Register/Model/vendorResponse.dart';
import '../../Presentation/Home Screen/Model/employee_home_response.dart';
import '../../Presentation/Login Screen/Model/login_response.dart';
import '../../Presentation/Login Screen/Model/otp_response.dart';
import '../../Presentation/Login Screen/Model/resend_otp_response.dart';
import '../../Presentation/Login Screen/Model/whatsapp_response.dart';
import '../../Presentation/Mobile Nomber Verify/Model/sim_verify_response.dart';
import '../../Presentation/ShopInfo/Model/search_keywords_response.dart';
import '../../Presentation/ShopInfo/Model/shop_info_photos_response.dart';
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
    String simToken, {
    String page = "",
  }) async {
    String url = page == "resendOtp" ? ApiUrl.resendOtp : ApiUrl.register;

    final response = await Request.sendRequest(
      url,
      {"contact": "+91$phone", "purpose": "vendor"},
      'Post',
      false,
    );

    if (response is! DioException) {
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data['status'] == true) {
          return Right(LoginResponse.fromJson(response.data));
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
    String? aadhaarDocumentUrl,

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
          addIfNotEmpty("vendorName", vendorName);
          addIfNotEmpty("ownerNameTamil", vendorNameTamil);
          addIfNotEmpty("phoneNumber", phoneNumber);
          addIfNotEmpty("email", email);
          addIfNotEmpty("gender", gender?.toUpperCase());
          addIfNotEmpty("dateOfBirth", dateOfBirth);
          addIfNotEmpty("aadharNumber", aadharNumber);
          addIfNotEmpty("aadharDocumentUrl", aadhaarDocumentUrl);
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

  Future<Either<Failure, AddEmployeeResponse>> addEmployee({
    // 1st screen
    required String phoneNumber,
    required String fullName,
    required String email,
    required String emergencyContactName,
    required String emergencyContactRelationship,
    required String emergencyContactPhone,
    required String aadhaarNumber,
    required String aadhaarDocumentUrl,
    required String avatarUrl,
  }) async {
    try {
      final url = ApiUrl.addEmployees;

      final payload = {
        "phoneNumber": '+91${phoneNumber}',
        "fullName": fullName,
        "email": email,
        "emergencyContactName": emergencyContactName,
        "emergencyContactRelationship": emergencyContactRelationship,
        "emergencyContactPhone": emergencyContactPhone,
        "aadharNumber": aadhaarNumber,
        "aadharDocumentUrl": aadhaarDocumentUrl,
        "avatarUrl": avatarUrl,
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

      String url = ApiUrl.imageUrl;
      FormData formData = FormData.fromMap({
        'images': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
      });

      final response = await Request.formData(url, formData, 'POST', true);
      Map<String, dynamic> responseData =
          jsonDecode(response.data) as Map<String, dynamic>;
      if (response.statusCode == 200) {
        if (responseData['status'] == true) {
          return Right(UserImageResponse.fromJson(responseData));
        } else {
          return Left(ServerFailure(responseData['message']));
        }
      } else if (response is Response && response.statusCode == 409) {
        return Left(ServerFailure(responseData['message']));
      } else if (response is Response) {
        return Left(ServerFailure(responseData['message'] ?? "Unknown error"));
      } else {
        return Left(ServerFailure("Unexpected error"));
      }
    } catch (e) {
      // CommonLogger.log.e(e);
      print(e);
      return Left(ServerFailure('Something went wrong'));
    }
  }

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
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, VendorDashboardResponse>> heaterHome() async {
    try {
      final url = ApiUrl.heaterHome;

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

  Future<Either<Failure, EmployeeHomeResponse>> employeeHome() async {
    try {
      final url = ApiUrl.employeeHome;

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

  Future<Either<Failure, LoginResponse>> ownerInfoNumberRequest({
    required String phone,
  }) async {
    String url = ApiUrl.ownerInfoNumberRequest;

    final response = await Request.sendRequest(
      url,
      {"ownerPhoneNumber": "+91$phone"},
      'Post',
      true,
    );

    if (response is! DioException) {
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data['status'] == true) {
          return Right(LoginResponse.fromJson(response.data));
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

  Future<Either<Failure, OwnerOtpResponse>> ownerInfoOtpRequest({
    required String phone,
    required String code,
  }) async {
    String url = ApiUrl.ownerInfoNumberOtpRequest;

    final response = await Request.sendRequest(
      url,
      {"ownerPhoneNumber": "+91$phone", "code": code},
      'Post',
      true,
    );

    if (response is! DioException) {
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data['status'] == true) {
          return Right(OwnerOtpResponse.fromJson(response.data));
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
      AppLogger.log.i(e);
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
  }) async {
    try {
      String url = ApiUrl.shops;

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
    } catch (e, st) {
      AppLogger.log.e("PARSE ERROR => $e");
      AppLogger.log.e("STACK => $st");

      return Left(ServerFailure("Response parse error: $e"));
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

  Future<Either<Failure, ShopInfoPhotosResponse>> shopPhotoUpload({
    required List<Map<String, String>> items,
    String? apiShopId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final shopId = await AppPrefs.getSopId();

      // ❗ FIXED: remove `?? ''`
      final url = ApiUrl.shopPhotosUpload(shopId: shopId ?? '');

      final payload = {"items": items};

      final response = await Request.sendRequest(url, payload, 'POST', true);

      AppLogger.log.i(payload);
      AppLogger.log.i(response);

      if (response is! DioException) {
        if (response.statusCode == 200 || response.statusCode == 201) {
          if (response.data['status'] == true) {
            return Right(ShopInfoPhotosResponse.fromJson(response.data));
          } else {
            return Left(
              ServerFailure(response.data['message'] ?? "Upload failed"),
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
    } catch (e) {
      AppLogger.log.e(e);
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, CategoryListResponse>> getProductCategories({
    String? apiShopId,
  }) async {
    try {
      final shopId = await AppPrefs.getSopId();

      // priority: apiShopId → savedShopId → empty
      // final shopId = (apiShopId != null && apiShopId.trim().isNotEmpty)
      //     ? apiShopId
      //     : (savedShopId ?? '');

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
      final prefs = await SharedPreferences.getInstance();

      // 🔹 SHOP ID: can fallback to prefs
      final shopId = await AppPrefs.getSopId();
      String? productId = apiProductId ?? prefs.getString('product_id');

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
              : ApiUrl.addProducts(shopId: shopId ?? ''); // CREATE

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
}
