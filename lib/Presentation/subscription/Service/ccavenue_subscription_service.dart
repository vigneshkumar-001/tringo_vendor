import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tringo_vendor_new/Api/Repository/api_url.dart';
import 'package:tringo_vendor_new/Api/Repository/failure.dart';
import 'package:tringo_vendor_new/Api/Repository/request.dart';
import 'package:tringo_vendor_new/Presentation/subscription/Model/ccavenue_models.dart';
import 'package:tringo_vendor_new/Presentation/subscription/Model/current_plan_response.dart';

class CcAvenueSubscriptionService {
  const CcAvenueSubscriptionService();

  Future<Either<Failure, CcAvenueInitResponse>> init({
    required CcAvenueInitRequest body,
    required bool extend,
  }) async {
    try {
      final url = extend ? ApiUrl.ccAvenueExtendInit : ApiUrl.ccAvenueInit;

      final resp = await Request.sendRequest(url, body.toJson(), 'POST', true)
          as Response;

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        final data = (resp.data is Map<String, dynamic>)
            ? (resp.data as Map<String, dynamic>)
            : <String, dynamic>{};

        if (data['status'] == true) {
          final parsed = CcAvenueInitResponse.fromJson(data);
          if (parsed.data == null) {
            return const Left(
              ServerFailure(
                "Payment initialization failed. Please try again.",
              ),
            );
          }
          return Right(parsed);
        }
        return Left(ServerFailure(data['message']?.toString() ?? "Failed"));
      }

      return Left(
        ServerFailure(resp.data?['message']?.toString() ?? "Something went wrong"),
      );
    } on DioException catch (e) {
      final errorData = e.response?.data;
      if (errorData is Map && errorData.containsKey('message')) {
        return Left(ServerFailure(errorData['message'].toString()));
      }
      return Left(ServerFailure(e.message ?? "Request failed"));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, CcAvenueConfirmResponse>> confirm({
    required CcAvenueConfirmRequest body,
  }) async {
    try {
      final resp = await Request.sendRequest(
        ApiUrl.ccAvenueConfirm,
        body.toJson(),
        'POST',
        true,
      ) as Response;

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        final data = (resp.data is Map<String, dynamic>)
            ? (resp.data as Map<String, dynamic>)
            : <String, dynamic>{};

        if (data['status'] == true) {
          return Right(CcAvenueConfirmResponse.fromJson(data));
        }
        return Left(ServerFailure(data['message']?.toString() ?? "Failed"));
      }

      return Left(
        ServerFailure(resp.data?['message']?.toString() ?? "Something went wrong"),
      );
    } on DioException catch (e) {
      final errorData = e.response?.data;
      if (errorData is Map && errorData.containsKey('message')) {
        return Left(ServerFailure(errorData['message'].toString()));
      }
      return Left(ServerFailure(e.message ?? "Request failed"));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, CurrentPlanResponse>> current({
    required String businessProfileId,
  }) async {
    final id = businessProfileId.trim();
    if (id.isEmpty) {
      return const Left(ServerFailure("Business profile is required"));
    }

    try {
      final url = ApiUrl.currentPlans(businessProfileId: id);
      final resp = await Request.sendGetRequest(url, {}, 'GET', true);
      if (resp == null) {
        return const Left(
          ServerFailure("Unable to fetch subscription. Please try again."),
        );
      }

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        final data = (resp.data is Map<String, dynamic>)
            ? (resp.data as Map<String, dynamic>)
            : <String, dynamic>{};

        if (data['status'] == true) {
          return Right(CurrentPlanResponse.fromJson(data));
        }
        return Left(ServerFailure(data['message']?.toString() ?? "Failed"));
      }

      return Left(
        ServerFailure(resp.data?['message']?.toString() ?? "Something went wrong"),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

final ccAvenueSubscriptionServiceProvider = Provider<CcAvenueSubscriptionService>(
  (ref) => const CcAvenueSubscriptionService(),
);
