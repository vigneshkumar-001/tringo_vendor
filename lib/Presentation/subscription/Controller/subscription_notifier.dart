import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tringo_vendor_new/Presentation/Heater/Add%20Vendor%20Employee/Model/add_employee_response.dart';
import 'package:tringo_vendor_new/Presentation/Heater/Add%20Vendor%20Employee/Model/employee_list_response.dart';
import 'package:tringo_vendor_new/Presentation/subscription/Model/ccavenue_models.dart';
import 'package:tringo_vendor_new/Presentation/subscription/Model/current_plan_response.dart';
import 'package:tringo_vendor_new/Presentation/subscription/Model/plan_list_response.dart';
import 'package:tringo_vendor_new/Presentation/subscription/Model/purchase_response.dart';
import 'package:tringo_vendor_new/Presentation/subscription/Service/ccavenue_subscription_service.dart';

import '../../../../Api/DataSource/api_data_source.dart';

import '../../Login Screen/Controller/login_notifier.dart';

class SubscriptionState {
  final bool isLoading;
  final bool isInsertLoading;
  final String? error;
  final PlanListResponse? planListResponse;
  final PurchaseResponse? purchaseResponse;
  final CurrentPlanResponse? currentPlanResponse;
  final String? currentPlanBusinessProfileId;
  final CcAvenueInitResponse? ccAvenueInitResponse;
  final CcAvenueConfirmResponse? ccAvenueConfirmResponse;

  const SubscriptionState({
    this.isLoading = false,
    this.isInsertLoading = false,
    this.error,
    this.planListResponse,
    this.purchaseResponse,
    this.currentPlanResponse,
    this.currentPlanBusinessProfileId,
    this.ccAvenueInitResponse,
    this.ccAvenueConfirmResponse,
  });

  factory SubscriptionState.initial() => const SubscriptionState();

  SubscriptionState copyWith({
    bool? isLoading,
    bool? isInsertLoading,
    String? error,
    PurchaseResponse? purchaseResponse,
    PlanListResponse? planListResponse,
    CurrentPlanResponse? currentPlanResponse,
    String? currentPlanBusinessProfileId,
    CcAvenueInitResponse? ccAvenueInitResponse,
    CcAvenueConfirmResponse? ccAvenueConfirmResponse,
    bool clearError = false,
  }) {
    return SubscriptionState(
      isLoading: isLoading ?? this.isLoading,
      isInsertLoading: isInsertLoading ?? this.isInsertLoading,
      error: clearError ? null : (error ?? this.error),
      planListResponse: planListResponse ?? this.planListResponse,
      purchaseResponse: purchaseResponse ?? this.purchaseResponse,
      currentPlanResponse: currentPlanResponse ?? this.currentPlanResponse,
      currentPlanBusinessProfileId:
          currentPlanBusinessProfileId ?? this.currentPlanBusinessProfileId,
      ccAvenueInitResponse: ccAvenueInitResponse ?? this.ccAvenueInitResponse,
      ccAvenueConfirmResponse:
          ccAvenueConfirmResponse ?? this.ccAvenueConfirmResponse,
    );
  }
}

class SubscriptionNotifier extends Notifier<SubscriptionState> {
  late final ApiDataSource api;
  late final CcAvenueSubscriptionService ccApi;

  @override
  SubscriptionState build() {
    api = ref.read(apiDataSourceProvider);
    ccApi = ref.read(ccAvenueSubscriptionServiceProvider);
    Future.microtask(() async {
      await getPlanList();
    });
    return SubscriptionState.initial();
  }

  Future<void> getPlanList() async {
    if (state.isLoading || state.planListResponse != null) return;
    state = state.copyWith(isLoading: true, planListResponse: null);

    final result = await api.getPlanList();

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
          planListResponse: null,
        );
      },
      (response) {
        state = state.copyWith(
          isLoading: false,
          error: null,
          planListResponse: response,
        );
      },
    );
  }

  Future<void> getCurrentPlan({
    required String businessProfileId,
    bool force = false,
    bool keepExisting = true,
  }) async {
    final id = businessProfileId.trim();
    if (id.isEmpty) return;

    if (!force &&
        !state.isLoading &&
        state.currentPlanResponse != null &&
        state.currentPlanBusinessProfileId == id) {
      return;
    }

    state = state.copyWith(
      isLoading: state.currentPlanResponse == null,
      currentPlanResponse: keepExisting ? state.currentPlanResponse : null,
      currentPlanBusinessProfileId: id,
      clearError: true,
    );

    final result = await ccApi.current(businessProfileId: id);

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
          currentPlanResponse: null,
        );
      },
      (response) {
        state = state.copyWith(
          isLoading: false,
          error: null,
          currentPlanResponse: response,
          currentPlanBusinessProfileId: id,
        );
      },
    );
  }

  Future<void> purchasePlan({
    required String planId,
    required String businessProfileId,
  }) async {
    state = state.copyWith(isInsertLoading: true, purchaseResponse: null);

    final result = await api.purchasePlan(
      planId: planId,
      businessProfileId: businessProfileId,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          isInsertLoading: false,
          error: failure.message,
          purchaseResponse: null,
        );
      },
      (response) {
        state = state.copyWith(
          isInsertLoading: false,
          error: null,
          purchaseResponse: response,
        );
      },
    );
  }

  void resetState() {
    state = SubscriptionState.initial();
  }

  Future<CcAvenueInitData?> initCcAvenue({
    required String planId,
    required String businessProfileId,
    required String shopId,
    required bool extend,
  }) async {
    final p = planId.trim();
    final b = businessProfileId.trim();
    final s = shopId.trim();
    if (p.isEmpty || b.isEmpty || s.isEmpty) {
      state = state.copyWith(
        isInsertLoading: false,
        error: "Missing required data. Please try again.",
        ccAvenueInitResponse: null,
      );
      return null;
    }

    state = state.copyWith(
      isInsertLoading: true,
      clearError: true,
      ccAvenueInitResponse: null,
    );

    final result = await ccApi.init(
      body: CcAvenueInitRequest(
        planId: p,
        businessProfileId: b,
        shopId: s,
      ),
      extend: extend,
    );

    return result.fold((failure) {
      state = state.copyWith(
        isInsertLoading: false,
        error: failure.message,
        ccAvenueInitResponse: null,
      );
      return null;
    }, (resp) {
      state = state.copyWith(
        isInsertLoading: false,
        error: null,
        ccAvenueInitResponse: resp,
      );
      return resp.data;
    });
  }

  Future<CcAvenueConfirmResponse?> confirmCcAvenue({
    required String encResp,
  }) async {
    final v = encResp.trim();
    if (v.isEmpty) return null;

    state = state.copyWith(
      isInsertLoading: true,
      clearError: true,
      ccAvenueConfirmResponse: null,
    );

    final result =
        await ccApi.confirm(body: CcAvenueConfirmRequest(encResp: v));

    return result.fold((failure) {
      state = state.copyWith(
        isInsertLoading: false,
        error: failure.message,
        ccAvenueConfirmResponse: null,
      );
      return null;
    }, (resp) {
      state = state.copyWith(
        isInsertLoading: false,
        error: null,
        ccAvenueConfirmResponse: resp,
      );
      return resp;
    });
  }
}

final subscriptionNotifier =
    NotifierProvider<SubscriptionNotifier, SubscriptionState>(
      SubscriptionNotifier.new,
    );
