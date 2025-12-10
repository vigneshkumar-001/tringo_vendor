import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../Api/DataSource/api_data_source.dart';
import '../../../Login Screen/Controllre/login_notifier.dart';

class VendorCompanyState {
  final bool isLoading;
  final String? error;
  // final OwnerInfoResponse? ownerResponse;

  const VendorCompanyState({
    this.isLoading = false,
    this.error,
    // this.ownerResponse,
  });

  factory VendorCompanyState.initial() => const VendorCompanyState();
}

class HeaterRegisterNotifier extends Notifier<VendorCompanyState> {
  late final ApiDataSource api;

  @override
  VendorCompanyState build() {
    api = ref.read(apiDataSourceProvider);
    return VendorCompanyState.initial();
  }



  void resetState() {
    state = VendorCompanyState.initial();
  }
}

final ownerInfoNotifierProvider =
    NotifierProvider.autoDispose<HeaterRegisterNotifier, VendorCompanyState>(
      HeaterRegisterNotifier.new,
    );
