import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tringo_vendor_new/Presentation/Heater/Add%20Vendor%20Employee/Model/add_employee_response.dart';
import 'package:tringo_vendor_new/Presentation/Heater/Add%20Vendor%20Employee/Model/employee_list_response.dart';
import 'package:tringo_vendor_new/Presentation/subscription/Model/plan_list_response.dart';
import 'package:tringo_vendor_new/Presentation/subscription/Model/purchase_response.dart';

import '../../../../Api/DataSource/api_data_source.dart';

import '../../Login Screen/Controller/login_notifier.dart';

class SubscriptionState {
  final bool isLoading;
  final bool isInsertLoading;
  final String? error;
  final PlanListResponse? planListResponse;
  final PurchaseResponse? purchaseResponse;

  const SubscriptionState({
    this.isLoading = false,
    this.isInsertLoading = false,
    this.error,
    this.planListResponse,
    this.purchaseResponse,
  });

  factory SubscriptionState.initial() => const SubscriptionState();

  SubscriptionState copyWith({
    bool? isLoading,
    bool? isInsertLoading,
    String? error,
    PurchaseResponse? purchaseResponse,
    PlanListResponse? planListResponse,
    bool clearError = false,
  }) {
    return SubscriptionState(
      isLoading: isLoading ?? this.isLoading,
      isInsertLoading: isInsertLoading ?? this.isInsertLoading,
      error: clearError ? null : (error ?? this.error),
      planListResponse: planListResponse ?? this.planListResponse,
      purchaseResponse: purchaseResponse ?? this.purchaseResponse,
    );
  }
}

class SubscriptionNotifier extends Notifier<SubscriptionState> {
  late final ApiDataSource api;

  @override
  SubscriptionState build() {
    api = ref.read(apiDataSourceProvider);
    return SubscriptionState.initial();
  }

  Future<void> getPlanList() async {
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

  Future<void> purchasePlan({required String planId}) async {
    state = state.copyWith(isInsertLoading: true, purchaseResponse: null);

    final result = await api.purchasePlan(planId: planId);

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
}

final subscriptionNotifier =
    NotifierProvider<SubscriptionNotifier, SubscriptionState>(
      SubscriptionNotifier.new,
    );
