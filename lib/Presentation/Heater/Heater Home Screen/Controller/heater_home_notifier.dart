import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tringo_vendor_new/Presentation/Heater/Add%20Vendor%20Employee/Model/add_employee_response.dart';
import 'package:tringo_vendor_new/Presentation/Heater/Add%20Vendor%20Employee/Model/employee_list_response.dart';

import '../../../../Api/DataSource/api_data_source.dart';
import '../../../Login Screen/Controllre/login_notifier.dart';
import '../Model/heater_home_response.dart';

class heaterHomeState {
  final bool isLoading;
  final String? error;
  final VendorDashboardResponse? vendorDashboardResponse;

  const heaterHomeState({
    this.isLoading = false,
    this.error,
    this.vendorDashboardResponse,
  });

  factory heaterHomeState.initial() => const heaterHomeState();

  heaterHomeState copyWith({
    bool? isLoading,
    String? error,
    VendorDashboardResponse? vendorDashboardResponse,
    bool clearError = false,
  }) {
    return heaterHomeState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      vendorDashboardResponse:
          vendorDashboardResponse ?? this.vendorDashboardResponse,
    );
  }
}

class HeaterHomeNotifier extends Notifier<heaterHomeState> {
  late final ApiDataSource api;

  @override
  heaterHomeState build() {
    api = ref.read(apiDataSourceProvider);
    return heaterHomeState.initial();
  }

  Future<void> heaterHome() async {
    state = state.copyWith(isLoading: true, vendorDashboardResponse: null);

    final result = await api.heaterHome();

    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, vendorDashboardResponse: null);
      },
      (response) {
        state = state.copyWith(
          isLoading: false,
          vendorDashboardResponse: response,
        );
      },
    );
  }

  // Future<void> fetchHeaterHome() async {
  //   // Start loading, clear old data + error
  //   state = state.copyWith(
  //     isLoading: true,
  //     vendorDashboardResponse: null,
  //     clearError: true,
  //   );
  //
  //   final result = await api.heaterHome();
  //
  //   result.fold(
  //     (failure) {
  //       state = state.copyWith(
  //         isLoading: false,
  //         error: failure.message,
  //         vendorDashboardResponse: null,
  //       );
  //     },
  //     (response) {
  //       state = state.copyWith(
  //         isLoading: false,
  //         vendorDashboardResponse: response,
  //         clearError: true,
  //       );
  //     },
  //   );
  // }

  void resetState() {
    state = heaterHomeState.initial();
  }
}

final heaterHomeNotifier =
NotifierProvider<HeaterHomeNotifier, heaterHomeState>(HeaterHomeNotifier.new);


