import 'dart:async';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tringo_vendor_new/Core/Const/app_logger.dart';

class Request {
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
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          return handler.next(options);
        },
        onResponse: (response, handler) {
          AppLogger.log.i(body);
          AppLogger.log.i(
            "API: $url \n Token: $token \n RESPONSE: ${response.toString()}",
          );
          return handler.next(response);
        },
        onError: (DioException error, handler) async {
          final sc = error.response?.statusCode; //int

          if (sc == 402 || sc == 406 || sc == 401 || sc == 429 || sc == 409) {
            return handler.reject(error);
          }

          return handler.next(error);
        },
      ),
    );

    try {
      final headers = <String, dynamic>{
        "Content-Type": "application/json",
        if (token != null && isTokenRequired) "Authorization": "Bearer $token",
        if (sessionToken != null && isTokenRequired)
          "x-session-token": sessionToken,
      };

      final response = await dio
          .post(
            url,
            data: body,
            options: Options(
              headers: headers,
              validateStatus: (status) => status != null && status < 503,
            ),
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw TimeoutException("Request timed out after 10 seconds");
            },
          );

      AppLogger.log.i(
        "RESPONSE \n API: $url \n Token : $token \n session Token : $sessionToken \n Headers : $headers \n RESPONSE: ${response.toString()}",
      );

      return response;
    } on TimeoutException catch (e) {
      AppLogger.log.e('API: $url \n TIMEOUT: $e');
      return e;
    } on DioException catch (e) {
      AppLogger.log.e('API: $url \n DIO ERROR: $e');
      return e;
    } catch (e) {
      AppLogger.log.e('API: $url \n ERROR: $e');
      return Exception(e.toString());
    }
  }
  // static Future<dynamic> sendRequest(
  //   String url,
  //   Map<String, dynamic> body,
  //   String? method,
  //   bool isTokenRequired,
  // ) async
  // {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String? token = prefs.getString('token');
  //   String? sessionToken = prefs.getString('sessionToken');
  //   String? userId = prefs.getString('userId');
  //
  //   // AuthController authController = getx.Get.find();
  //   // // OtpController otpController = getx.Get.find();
  //   Dio dio = Dio(
  //     BaseOptions(
  //       connectTimeout: const Duration(seconds: 10),
  //       receiveTimeout: const Duration(seconds: 15),
  //     ),
  //   );
  //   dio.interceptors.add(
  //     InterceptorsWrapper(
  //       onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
  //         return handler.next(options);
  //       },
  //       onResponse: (
  //         Response<dynamic> response,
  //         ResponseInterceptorHandler handler,
  //       ) {
  //         AppLogger.log.i(body);
  //         AppLogger.log.i(
  //           "sendPostRequest \n API: $url \n Token : $token \n RESPONSE: ${response.toString()}",
  //         );
  //         return handler.next(response);
  //       },
  //       onError: (DioException error, ErrorInterceptorHandler handler) async {
  //         if (error.response?.statusCode == '402') {
  //           // app update new version
  //           return handler.reject(error);
  //         } else if (error.response?.statusCode == '406' ||
  //             error.response?.statusCode == '401') {
  //           return handler.reject(error);
  //         } else if (error.response?.statusCode == '429') {
  //           //Too many Attempts
  //           return handler.reject(error);
  //         } else if (error.response?.statusCode == '409') {
  //           //Too many Attempts
  //           return handler.reject(error);
  //         }
  //         return handler.next(error);
  //       },
  //     ),
  //   );
  //   try {
  //     final headers = {
  //       "Content-Type": "application/json",
  //       if (token != null && isTokenRequired) "Authorization": "Bearer $token",
  //       if (sessionToken != null && isTokenRequired)
  //         "x-session-token": sessionToken,
  //     };
  //
  //     final response = await dio
  //         .post(
  //           url,
  //           data: body,
  //           options: Options(
  //             headers: headers,
  //             validateStatus: (status) => status != null && status < 503,
  //           ),
  //         )
  //         .timeout(
  //           const Duration(seconds: 10),
  //           onTimeout: () {
  //             throw TimeoutException("Request timed out after 10 seconds");
  //           },
  //         );
  //     // 🔹 Debug print
  //
  //     AppLogger.log.i(
  //       "RESPONSE \n API: $url \n Token : $token \n session Token : $sessionToken \n Headers : $headers \n RESPONSE: ${response.toString()}",
  //     );
  //
  //     AppLogger.log.i("$body");
  //
  //     return response;
  //   } catch (e) {
  //     AppLogger.log.e('API: $url \n ERROR: $e ');
  //
  //     return e;
  //   }
  // }

  static Future<dynamic> formData(
    String url,
    dynamic body,
    String? method,
    bool isTokenRequired,
  ) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? userId = prefs.getString('userId');

    // AuthController authController = getx.Get.find();
    // // OtpController otpController = getx.Get.find();
    Dio dio = Dio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
          return handler.next(options);
        },
        onResponse: (
          Response<dynamic> response,
          ResponseInterceptorHandler handler,
        ) {
          AppLogger.log.i(
            "sendPostRequest \n API: $url \n RESPONSE: ${response.toString()}",
          );
          return handler.next(response);
        },
        onError: (DioException error, ErrorInterceptorHandler handler) async {
          if (error.response?.statusCode == '402') {
            // app update new version
            return handler.reject(error);
          } else if (error.response?.statusCode == '406' ||
              error.response?.statusCode == '401') {
            // Unauthorized user navigate to login page

            return handler.reject(error);
          } else if (error.response?.statusCode == '429') {
            //Too many Attempts
            return handler.reject(error);
          } else if (error.response?.statusCode == '409') {
            //Too many Attempts
            return handler.reject(error);
          }
          return handler.next(error);
        },
      ),
    );
    try {
      final response = await dio.post(
        url,
        data: body,
        options: Options(
          headers: {
            "Authorization": token != null ? "Bearer $token" : "",
            "Content-Type":
                body is FormData ? "multipart/form-data" : "application/json",
          },
          validateStatus: (status) {
            // Allow all status codes below 500 to be handled manually
            return status != null && status < 500;
          },
        ),
      );

      AppLogger.log.i(
        "RESPONSE \n API: $url \n RESPONSE: ${response.toString()}",
      );
      AppLogger.log.i("$token");
      AppLogger.log.i("$body");

      return response;
    } catch (e) {
      AppLogger.log.e('API: $url \n ERROR: $e ');

      return e;
    }
  }

  static Future<Response?> sendGetRequest(
    String url,
    Map<String, dynamic> queryParams,
    String method,
    bool isTokenRequired,
  ) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    final String? sessionToken = prefs.getString('sessionToken');
    String? userId = prefs.getString('userId');

    Dio dio = Dio();

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
          return handler.next(options);
        },
        onResponse: (
          Response<dynamic> response,
          ResponseInterceptorHandler handler,
        ) {
          AppLogger.log.i(queryParams);
          AppLogger.log.i(
            "GET Request \n API: $url \n Token: $token \n RESPONSE: ${response.toString()}",
          );
          return handler.next(response);
        },
        onError: (DioException error, ErrorInterceptorHandler handler) async {
          if (error.response?.statusCode == 402) {
            return handler.reject(error);
          } else if (error.response?.statusCode == 406 ||
              error.response?.statusCode == 401) {
            return handler.reject(error);
          } else if (error.response?.statusCode == 429) {
            return handler.reject(error);
          } else if (error.response?.statusCode == 409) {
            return handler.reject(error);
          }
          return handler.next(error);
        },
      ),
    );

    try {
      final headers = <String, dynamic>{
        "Content-Type": "application/json",
        if (token != null && isTokenRequired) "Authorization": "Bearer $token",
        if (sessionToken != null && isTokenRequired)
          "x-session-token": sessionToken,
      };
      Response response = await dio.get(
        url,
        queryParameters: queryParams,
        options: Options(
          headers: headers,
          validateStatus: (status) {
            return status != null && status < 500;
          },
        ),
      );

      AppLogger.log.i(
        "GET RESPONSE \n API: $url \n RESPONSE: ${response.toString()}",
      );
      return response;
    } catch (e) {
      AppLogger.log.e('GET API: $url \n ERROR: $e');
      return null;
    }
  }
}
