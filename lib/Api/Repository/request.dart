import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tringo_vendor_new/Core/Const/app_logger.dart';
import 'package:tringo_vendor_new/Core/Session/session_manager.dart';

// ✅ import your navigatorKey
import 'package:tringo_vendor_new/main.dart';

import '../../Core/Widgets/app_go_routes.dart'; // <-- adjust path where appNavKey is

class Request {
  // =============================
  //  AUTO LOGOUT (NO CONTEXT)
  // =============================
  static Future<void> _forceLogout({String? reason}) async {
    AppLogger.log.e("Force logout: ${reason ?? "Invalid Session"}");
    await SessionManager.forceLogout();
  }

  static Future<void> _forceVendorBlocked({String? reason}) async {
    final prefs = await SharedPreferences.getInstance();
    final role = (prefs.getString('role') ?? '').trim().toUpperCase();
    if (role != 'VENDOR') return;

    AppLogger.log.e("Vendor access blocked: ${reason ?? "ACCOUNT_SUSPENDED"}");
    await SessionManager.forceVendorAccessBlocked(
      blockType: 'SUSPENDED',
      message: reason,
    );

    final ctx = rootNavKey.currentContext;
    if (ctx != null) {
      GoRouter.of(ctx).go(AppRoutes.vendorAccessBlockedPath);
    }
  }

  static bool _isInternalServerMessage(dynamic data) {
    if (data is Map) {
      final msg = (data['message'] ?? '').toString().toLowerCase().trim();
      return msg == 'internal server error';
    }
    return false;
  }

  // ✅ check invalid session in response body
  static bool _isInvalidSessionResponse(dynamic data) {
    if (data is Map) {
      final msg = (data['message'] ?? '').toString().toLowerCase();
      if (msg.contains('account_suspended')) return false;
      if (msg.contains('invalid session token')) return true;
      if (msg.contains('session token') && msg.contains('invalid')) return true;
      if (msg.contains('session expired')) return true;
      return false;
    }

    // sometimes api returns string body
    if (data is String) {
      final s = data.toLowerCase();
      if (s.contains('account_suspended')) return false;
      if (s.contains('invalid session token')) return true;
      if (s.contains('session token') && s.contains('invalid')) return true;
      if (s.contains('session expired')) return true;
    }
    return false;
  }

  static bool _isAccountSuspendedResponse(dynamic data) {
    if (data is Map) {
      final msg = (data['message'] ?? '').toString().toLowerCase().trim();
      return msg.contains('account_suspended') ||
          msg.contains('account suspended');
    }

    if (data is String) {
      final msg = data.toLowerCase().trim();
      return msg.contains('account_suspended') ||
          msg.contains('account suspended');
    }

    return false;
  }

  static String? _extractServerMessage(dynamic data) {
    if (data is Map) {
      final msg = (data['message'] ?? '').toString().trim();
      if (msg.isNotEmpty) return msg;
    }

    if (data is String) {
      final msg = data.trim();
      if (msg.isNotEmpty) return msg;
    }

    return null;
  }

  static Map<String, dynamic> _headers({
    required String? token,
    required String? sessionToken,
    required bool isTokenRequired,
    Map<String, dynamic>? extra,
  }) {
    return <String, dynamic>{
      "Content-Type": "application/json",
      if (token != null && token.trim().isNotEmpty && isTokenRequired)
        "Authorization": "Bearer $token",
      if (sessionToken != null &&
          sessionToken.trim().isNotEmpty &&
          isTokenRequired)
        "x-session-token": sessionToken,
      if (extra != null) ...extra,
    };
  }

  // =============================
  //   MAIN REQUEST (GET/POST/PUT/PATCH/DELETE)
  // =============================
  static Future<dynamic> sendRequest(
    String url,
    Map<String, dynamic> body,
    String? method,
    bool isTokenRequired,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final String? sessionToken = prefs.getString('sessionToken');

    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 120),
        receiveTimeout: const Duration(seconds: 120),
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          return handler.next(options);
        },
        onResponse: (response, handler) async {
          // ✅ LOG
          AppLogger.log.i(
            "RESPONSE\nAPI: $url\nSTATUS: ${response.statusCode}\nDATA: ${response.data}",
          );

          if (_isAccountSuspendedResponse(response.data)) {
            await _forceVendorBlocked(
              reason:
                  _extractServerMessage(response.data) ??
                  "Your vendor account is suspended.",
            );
            return handler.reject(
              DioException(
                requestOptions: response.requestOptions,
                response: response,
                type: DioExceptionType.badResponse,
                message: "ACCOUNT_SUSPENDED",
              ),
            );
          }

          // ✅ DETECT invalid session token even if status is 200
          if (_isInvalidSessionResponse(response.data)) {
            await _forceLogout(reason: "Invalid session token (body)");
            return handler.reject(
              DioException(
                requestOptions: response.requestOptions,
                response: response,
                type: DioExceptionType.badResponse,
                message: "INVALID_SESSION_TOKEN",
              ),
            );
          }

          return handler.next(response);
        },
        onError: (DioException error, handler) async {
          final status = error.response?.statusCode;

          // ✅ If backend uses 401/403 for invalid session / blocked access
          if (status == 401 || status == 403) {
            final data = error.response?.data;
            if (_isAccountSuspendedResponse(data)) {
              await _forceVendorBlocked(
                reason:
                    _extractServerMessage(data) ??
                    "Your vendor account is suspended.",
              );
            }
            if (_isInvalidSessionResponse(data)) {
              await _forceLogout(
                reason: "Invalid session token (status $status)",
              );
            }
          }

          return handler.next(error);
        },
      ),
    );

    try {
      final headers = _headers(
        token: token,
        sessionToken: sessionToken,
        isTokenRequired: isTokenRequired,
      );

      final httpMethod = (method ?? 'POST').toUpperCase();

      AppLogger.log.i(
        "REQUEST\nMETHOD: $httpMethod\nAPI: $url\nBODY: $body\nHEADERS: $headers\n Body : $body",
      );

      late Response response;

      switch (httpMethod) {
        case 'GET':
          response = await dio.get(
            url,
            queryParameters: body.isEmpty ? null : body,
            options: Options(
              headers: headers,
              validateStatus: (status) => status != null && status < 503,
            ),
          );
          break;

        case 'PUT':
          response = await dio.put(
            url,
            data: body,
            options: Options(
              headers: headers,
              validateStatus: (status) => status != null && status < 503,
            ),
          );
          break;

        case 'PATCH':
          response = await dio.patch(
            url,
            data: body,
            options: Options(
              headers: headers,
              validateStatus: (status) => status != null && status < 503,
            ),
          );
          break;

        case 'DELETE':
          response = await dio.delete(
            url,
            data: body.isEmpty ? null : body,
            options: Options(
              headers: headers,
              validateStatus: (status) => status != null && status < 503,
            ),
          );
          break;

        case 'POST':
        default:
          response = await dio.post(
            url,
            data: body,
            options: Options(
              headers: headers,
              validateStatus: (status) => status != null && status < 503,
            ),
          );
          break;
      }

      if (_isAccountSuspendedResponse(response.data)) {
        await _forceVendorBlocked(
          reason:
              _extractServerMessage(response.data) ??
              "Your vendor account is suspended.",
        );
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          message: "ACCOUNT_SUSPENDED",
        );
      }

      // ✅ also check here (extra safety if interceptor not triggered)
      if (_isInvalidSessionResponse(response.data)) {
        await _forceLogout(reason: "Invalid session token (post-check)");
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          message: "INVALID_SESSION_TOKEN",
        );
      }

      return response;
    } on DioException catch (e) {
      throw e;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // =============================
  //   GET REQUEST (OLD FUNCTION) - UPDATED TOO
  // =============================
  static Future<Response?> sendGetRequest(
    String url,
    Map<String, dynamic> queryParams,
    String method,
    bool isTokenRequired, {
    String? appName,
    String? appVersion,
    String? appPlatForm,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final String? sessionToken = prefs.getString('sessionToken');

    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 60),
        validateStatus: (status) => status != null && status < 503,
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onResponse: (response, handler) async {
          AppLogger.log.i(
            "GET RESPONSE\nAPI: $url\nToken: $token\nSessionToken: $sessionToken\nDATA: ${response.data}",
          );

          if (_isAccountSuspendedResponse(response.data)) {
            await _forceVendorBlocked(
              reason:
                  _extractServerMessage(response.data) ??
                  "Your vendor account is suspended.",
            );
            return handler.reject(
              DioException(
                requestOptions: response.requestOptions,
                response: response,
                type: DioExceptionType.badResponse,
                message: "ACCOUNT_SUSPENDED",
              ),
            );
          }

          // 1) your existing invalid session check
          if (_isInvalidSessionResponse(response.data)) {
            await _forceLogout(reason: "Invalid session token (GET body)");
            return handler.reject(
              DioException(
                requestOptions: response.requestOptions,
                response: response,
                type: DioExceptionType.badResponse,
                message: "INVALID_SESSION_TOKEN",
              ),
            );
          }

          // 2) internal server error message check (your case)
          if (_isInternalServerMessage(response.data)) {
            await _forceLogout(reason: "Internal server error (body message)");
            return handler.reject(
              DioException(
                requestOptions: response.requestOptions,
                response: response,
                type: DioExceptionType.badResponse,
                message: "INTERNAL_SERVER_ERROR",
              ),
            );
          }

          return handler.next(response);
        },

        // onResponse: (response, handler) async {
        //   AppLogger.log.i(
        //     "GET RESPONSE\nAPI: $url\nDATA: ${response.data} \n Token = $token \n session Token = $sessionToken",
        //   );
        //
        //   if (_isInvalidSessionResponse(response.data)) {
        //     await _forceLogout(reason: "Invalid session token (GET body)");
        //     return handler.reject(
        //       DioException(
        //         requestOptions: response.requestOptions,
        //         response: response,
        //         type: DioExceptionType.badResponse,
        //         message: "INVALID_SESSION_TOKEN",
        //       ),
        //     );
        //   }
        //
        //   return handler.next(response);
        // },
        onError: (error, handler) async {
          final status = error.response?.statusCode;
          if (status == 401 || status == 403) {
            final data = error.response?.data;
            if (_isAccountSuspendedResponse(data)) {
              await _forceVendorBlocked(
                reason:
                    _extractServerMessage(data) ??
                    "Your vendor account is suspended.",
              );
            }
            if (_isInvalidSessionResponse(data)) {
              await _forceLogout(
                reason: "Invalid session token (GET status $status)",
              );
            }
          }
          return handler.next(error);
        },
      ),
    );

    try {
      final headers = _headers(
        token: token,
        sessionToken: sessionToken,
        isTokenRequired: isTokenRequired,
        extra: {
          if (appName != null) "X-App-Id": appName,
          if (appVersion != null) "X-App-Version": appVersion,
          if (appPlatForm != null) "X-Platform": appPlatForm,
        },
      );

      final Response response = await dio.get(
        url,
        queryParameters: queryParams.isEmpty ? null : queryParams,
        options: Options(headers: headers),
      );

      if (_isAccountSuspendedResponse(response.data)) {
        await _forceVendorBlocked(
          reason:
              _extractServerMessage(response.data) ??
              "Your vendor account is suspended.",
        );
        return null;
      }

      // extra safety
      if (_isInvalidSessionResponse(response.data)) {
        await _forceLogout(reason: "Invalid session token (GET post-check)");
        return null;
      }

      return response;
    } catch (e) {
      AppLogger.log.e('GET API: $url\nERROR: $e');
      return null;
    }
  }

  static Future<Response<dynamic>> formData(
    String url,
    dynamic body,
    String? method,
    bool isTokenRequired,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final String? sessionToken = prefs.getString('sessionToken');

    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 20),
        sendTimeout: const Duration(seconds: 45),
        receiveTimeout: const Duration(seconds: 45),
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          AppLogger.log.i(
            "FORMDATA REQUEST\n"
            "API: $url\n"
            "METHOD: ${(method ?? "POST").toUpperCase()}\n"
            "TOKEN: $token\n"
            "SESSION: $sessionToken\n"
            "HEADERS: ${options.headers}\n",
          );
          return handler.next(options);
        },
        onResponse: (response, handler) {
          AppLogger.log.i("FORMDATA RESPONSE\nAPI: $url\nRESPONSE: $response");
          return handler.next(response);
        },
        onError: (DioException error, handler) async {
          final status = error.response?.statusCode;
          AppLogger.log.e(
            "FORMDATA ERROR\n"
            "API: $url\n"
            "STATUS: $status\n"
            "MESSAGE: ${error.message}\n"
            "DATA: ${error.response?.data}\n",
          );

          if ((status == 401 || status == 403) &&
              _isAccountSuspendedResponse(error.response?.data)) {
            await _forceVendorBlocked(
              reason:
                  _extractServerMessage(error.response?.data) ??
                  "Your vendor account is suspended.",
            );
          }
          return handler.next(error);
        },
      ),
    );

    final headers = <String, dynamic>{
      if (token != null && isTokenRequired) "Authorization": "Bearer $token",
      if (sessionToken != null && isTokenRequired)
        "x-session-token": sessionToken,
      "Content-Type":
          body is FormData ? "multipart/form-data" : "application/json",
    };

    try {
      final httpMethod = (method ?? 'POST').toUpperCase();

      late Response<dynamic> response;

      if (httpMethod == "PUT") {
        response = await dio.put(
          url,
          data: body,
          options: Options(headers: headers),
        );
      } else if (httpMethod == "PATCH") {
        response = await dio.patch(
          url,
          data: body,
          options: Options(headers: headers),
        );
      } else if (httpMethod == "DELETE") {
        response = await dio.delete(
          url,
          data: body,
          options: Options(headers: headers),
        );
      } else {
        response = await dio.post(
          url,
          data: body,
          options: Options(headers: headers),
        );
      }

      // ✅ handle non-2xx as error (so loading stops in notifier catch)
      if (response.statusCode == null || response.statusCode! >= 400) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          message: "HTTP ${response.statusCode}",
        );
      }

      return response;
    } on TimeoutException catch (e) {
      throw Exception("Upload timeout: ${e.message}");
    } on DioException catch (e) {
      // ✅ throw, do not return
      throw e;
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}

// import 'dart:async';
//
// import 'package:dio/dio.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import 'package:tringo_vendor_new/Core/Const/app_logger.dart';
//  class Request {
//   static Future<dynamic> sendRequest(
//     String url,
//     Map<String, dynamic> body,
//     String? method,
//     bool isTokenRequired,
//   ) async {
//     final prefs = await SharedPreferences.getInstance();
//     final String? token = prefs.getString('token');
//     final String? sessionToken = prefs.getString('sessionToken');
//     final String? userId = prefs.getString('userId'); // (currently unused)
//
//     final dio = Dio(
//       BaseOptions(
//         connectTimeout: const Duration(seconds: 30),
//         sendTimeout: const Duration(seconds: 120),
//         receiveTimeout: const Duration(seconds: 120),
//       ),
//     );
//
//     dio.interceptors.add(
//       InterceptorsWrapper(
//         onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
//           return handler.next(options);
//         },
//         onResponse: (
//           Response<dynamic> response,
//           ResponseInterceptorHandler handler,
//         ) {
//           AppLogger.log.i(body);
//           AppLogger.log.i(
//             "sendRequest \n"
//             " API: $url \n"
//             " Token : $token \n"
//             " RESPONSE: ${response.toString()}",
//           );
//           return handler.next(response);
//         },
//         onError: (DioException error, ErrorInterceptorHandler handler) async {
//           final status = error.response?.statusCode;
//
//           if (status == 402) {
//             // app update new versionq
//             return handler.reject(error);
//           } else if (status == 406 || status == 401) {
//             // unauthorized, etc.
//             return handler.reject(error);
//           } else if (status == 429) {
//             // too many attempts
//             return handler.reject(error);
//           } else if (status == 409) {
//             // conflict
//             return handler.reject(error);
//           }
//           return handler.next(error);
//         },
//       ),
//     );
//
//     try {
//       final headers = <String, dynamic>{
//         "Content-Type": "application/json",
//         if (token != null && isTokenRequired) "Authorization": "Bearer $token",
//         if (sessionToken != null && isTokenRequired)
//           "x-session-token": sessionToken,
//       };
//
//       final httpMethod = (method ?? 'POST').toUpperCase();
//
//       AppLogger.log.i(
//         "REQUEST \n"
//         " METHOD: $httpMethod \n"
//         " API   : $url \n"
//         " BODY  : $body \n"
//         " HEADERS: $headers",
//       );
//
//       late Response response;
//
//       switch (httpMethod) {
//         case 'GET':
//           response = await dio
//               .get(
//                 url,
//                 queryParameters: body.isEmpty ? null : body,
//                 options: Options(
//                   headers: headers,
//                   validateStatus: (status) => status != null && status < 503,
//                 ),
//               )
//               .timeout(
//                 const Duration(seconds: 10),
//                 onTimeout: () {
//                   throw TimeoutException("Request timed out after 10 seconds");
//                 },
//               );
//           break;
//
//         case 'PUT':
//           response = await dio
//               .put(
//                 url,
//                 data: body,
//                 options: Options(
//                   headers: headers,
//                   validateStatus: (status) => status != null && status < 503,
//                 ),
//               )
//               .timeout(
//                 const Duration(seconds: 10),
//                 onTimeout: () {
//                   throw TimeoutException("Request timed out after 10 seconds");
//                 },
//               );
//           break;
//
//         case 'PATCH':
//           response = await dio
//               .patch(
//                 url,
//                 data: body,
//                 options: Options(
//                   headers: headers,
//                   validateStatus: (status) => status != null && status < 503,
//                 ),
//               )
//               .timeout(
//                 const Duration(seconds: 10),
//                 onTimeout: () {
//                   throw TimeoutException("Request timed out after 10 seconds");
//                 },
//               );
//           break;
//
//         ///  DELETE SUPPORT (THIS IS WHAT YOU NEEDED)
//         case 'DELETE':
//           response = await dio
//               .delete(
//                 url,
//                 data: body.isEmpty ? null : body,
//                 options: Options(
//                   headers: headers,
//                   validateStatus: (status) => status != null && status < 503,
//                 ),
//               )
//               .timeout(
//                 const Duration(seconds: 10),
//                 onTimeout: () {
//                   throw TimeoutException("Request timed out after 10 seconds");
//                 },
//               );
//           break;
//
//         /// Default → POST (for your existing usages)
//         case 'POST':
//         default:
//           response = await dio
//               .post(
//                 url,
//                 data: body,
//                 options: Options(
//                   headers: headers,
//                   validateStatus: (status) => status != null && status < 503,
//                 ),
//               )
//               .timeout(
//                 const Duration(seconds: 10),
//                 onTimeout: () {
//                   throw TimeoutException("Request timed out after 10 seconds");
//                 },
//               );
//           break;
//       }
//
//       AppLogger.log.i(
//         "RESPONSE \n"
//         " API: $url \n"
//         " Token : $token \n"
//         " session Token : $sessionToken \n"
//         " Headers : $headers \n"
//         " RESPONSE: ${response.toString()}",
//       );
//
//       AppLogger.log.i("$body");
//
//       return response;
//     } on DioException catch (e) {
//       // THROW the DioException, do not return it
//       throw e;
//     } catch (e) {
//       // Throw clean exception
//       throw Exception(e.toString());
//     }
//   }
//
//
//   static Future<Response<dynamic>> formData(
//     String url,
//     dynamic body,
//     String? method,
//     bool isTokenRequired,
//   ) async {
//     final prefs = await SharedPreferences.getInstance();
//     final String? token = prefs.getString('token');
//     final String? sessionToken = prefs.getString('sessionToken');
//
//     final dio = Dio(
//       BaseOptions(
//         connectTimeout: const Duration(seconds: 20),
//         sendTimeout: const Duration(seconds: 45),
//         receiveTimeout: const Duration(seconds: 45),
//         validateStatus: (status) => status != null && status < 500,
//       ),
//     );
//
//     dio.interceptors.add(
//       InterceptorsWrapper(
//         onRequest: (options, handler) {
//           AppLogger.log.i(
//             "FORMDATA REQUEST\n"
//             "API: $url\n"
//             "METHOD: ${(method ?? "POST").toUpperCase()}\n"
//             "TOKEN: $token\n"
//             "SESSION: $sessionToken\n"
//             "HEADERS: ${options.headers}\n",
//           );
//           return handler.next(options);
//         },
//         onResponse: (response, handler) {
//           AppLogger.log.i("FORMDATA RESPONSE\nAPI: $url\nRESPONSE: $response");
//           return handler.next(response);
//         },
//         onError: (DioException error, handler) {
//           final status = error.response?.statusCode;
//           AppLogger.log.e(
//             "FORMDATA ERROR\n"
//             "API: $url\n"
//             "STATUS: $status\n"
//             "MESSAGE: ${error.message}\n"
//             "DATA: ${error.response?.data}\n",
//           );
//           return handler.next(error);
//         },
//       ),
//     );
//
//     final headers = <String, dynamic>{
//       if (token != null && isTokenRequired) "Authorization": "Bearer $token",
//       if (sessionToken != null && isTokenRequired)
//         "x-session-token": sessionToken,
//       "Content-Type":
//           body is FormData ? "multipart/form-data" : "application/json",
//     };
//
//     try {
//       final httpMethod = (method ?? 'POST').toUpperCase();
//
//       late Response<dynamic> response;
//
//       if (httpMethod == "PUT") {
//         response = await dio.put(
//           url,
//           data: body,
//           options: Options(headers: headers),
//         );
//       } else if (httpMethod == "PATCH") {
//         response = await dio.patch(
//           url,
//           data: body,
//           options: Options(headers: headers),
//         );
//       } else if (httpMethod == "DELETE") {
//         response = await dio.delete(
//           url,
//           data: body,
//           options: Options(headers: headers),
//         );
//       } else {
//         response = await dio.post(
//           url,
//           data: body,
//           options: Options(headers: headers),
//         );
//       }
//
//       // ✅ handle non-2xx as error (so loading stops in notifier catch)
//       if (response.statusCode == null || response.statusCode! >= 400) {
//         throw DioException(
//           requestOptions: response.requestOptions,
//           response: response,
//           type: DioExceptionType.badResponse,
//           message: "HTTP ${response.statusCode}",
//         );
//       }
//
//       return response;
//     } on TimeoutException catch (e) {
//       throw Exception("Upload timeout: ${e.message}");
//     } on DioException catch (e) {
//       // ✅ throw, do not return
//       throw e;
//     } catch (e) {
//       throw Exception(e.toString());
//     }
//   }
//
//   // static Future<dynamic> formData(
//   //   String url,
//   //   dynamic body,
//   //   String? method,
//   //   bool isTokenRequired,
//   // ) async
//   // {
//   //   SharedPreferences prefs = await SharedPreferences.getInstance();
//   //   String? token = prefs.getString('token');
//   //   String? userId = prefs.getString('userId');
//   //
//   //   // AuthController authController = getx.Get.find();
//   //   // // OtpController otpController = getx.Get.find();
//   //   Dio dio = Dio();
//   //   dio.interceptors.add(
//   //     InterceptorsWrapper(
//   //       onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
//   //         return handler.next(options);
//   //       },
//   //       onResponse: (
//   //         Response<dynamic> response,
//   //         ResponseInterceptorHandler handler,
//   //       ) {
//   //         AppLogger.log.i(
//   //           "sendPostRequest \n API: $url \n RESPONSE: ${response.toString()}",
//   //         );
//   //         return handler.next(response);
//   //       },
//   //       onError: (DioException error, ErrorInterceptorHandler handler) async {
//   //         if (error.response?.statusCode == '402') {
//   //           // app update new version
//   //           return handler.reject(error);
//   //         } else if (error.response?.statusCode == '406' ||
//   //             error.response?.statusCode == '401') {
//   //           // Unauthorized user navigate to login page
//   //
//   //           return handler.reject(error);
//   //         } else if (error.response?.statusCode == '429') {
//   //           //Too many Attempts
//   //           return handler.reject(error);
//   //         } else if (error.response?.statusCode == '409') {
//   //           //Too many Attempts
//   //           return handler.reject(error);
//   //         }
//   //         return handler.next(error);
//   //       },
//   //     ),
//   //   );
//   //   try {
//   //     final response = await dio.post(
//   //       url,
//   //       data: body,
//   //       options: Options(
//   //         headers: {
//   //           "Authorization": token != null ? "Bearer $token" : "",
//   //           "Content-Type":
//   //               body is FormData ? "multipart/form-data" : "application/json",
//   //         },
//   //         validateStatus: (status) {
//   //           // Allow all status codes below 500 to be handled manually
//   //           return status != null && status < 500;
//   //         },
//   //       ),
//   //     );
//   //
//   //     AppLogger.log.i(
//   //       "RESPONSE \n API: $url \n RESPONSE: ${response.toString()}",
//   //     );
//   //     AppLogger.log.i("$token");
//   //     AppLogger.log.i("$body");
//   //
//   //     return response;
//   //   } catch (e) {
//   //     AppLogger.log.e('API: $url \n ERROR: $e ');
//   //
//   //     return e;
//   //   }
//   // }
//
//   static Future<Response?> sendGetRequest(
//     String url,
//     Map<String, dynamic> queryParams,
//     String method,
//     bool isTokenRequired,
//       {
//         String? appName,
//         String? appVersion,
//         String? appPlatForm,
//       }
//   ) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? token = prefs.getString('token');
//     final String? sessionToken = prefs.getString('sessionToken');
//     String? userId = prefs.getString('userId');
//
//     Dio dio = Dio();
//
//     dio.interceptors.add(
//       InterceptorsWrapper(
//         onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
//           return handler.next(options);
//         },
//         onResponse: (
//           Response<dynamic> response,
//           ResponseInterceptorHandler handler,
//         ) {
//           AppLogger.log.i(queryParams);
//           AppLogger.log.i(
//             "GET Request \n API: $url \n Token: $token \n Session Token : $sessionToken \n RESPONSE: ${response.toString()}",
//           );
//           return handler.next(response);
//         },
//         onError: (DioException error, ErrorInterceptorHandler handler) async {
//           if (error.response?.statusCode == 402) {
//             return handler.reject(error);
//           } else if (error.response?.statusCode == 406 ||
//               error.response?.statusCode == 401) {
//             return handler.reject(error);
//           } else if (error.response?.statusCode == 429) {
//             return handler.reject(error);
//           } else if (error.response?.statusCode == 409) {
//             return handler.reject(error);
//           }
//           return handler.next(error);
//         },
//       ),
//     );
//
//     try {
//       final headers = <String, dynamic>{
//         "Content-Type": "application/json",
//         if (token != null && isTokenRequired) "Authorization": "Bearer $token",
//         if (sessionToken != null && isTokenRequired)
//           "x-session-token": sessionToken,
//         "X-App-Id": appName,
//         "X-App-Version": appVersion,
//         "X-Platform": appPlatForm,
//       };
//       Response response = await dio.get(
//         url,
//         queryParameters: queryParams,
//         options: Options(
//           headers: headers,
//           validateStatus: (status) {
//             return status != null && status < 500;
//           },
//         ),
//       );
//
//       AppLogger.log.i(
//         "GET RESPONSE \n API: $url \n sessionToken : $sessionToken \n RESPONSE: ${response.toString()}",
//       );
//       return response;
//     } catch (e) {
//       AppLogger.log.e('GET API: $url \n ERROR: $e');
//       return null;
//     }
//   }
// }
