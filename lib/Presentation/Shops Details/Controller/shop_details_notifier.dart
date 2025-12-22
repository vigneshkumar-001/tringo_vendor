import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../Api/DataSource/api_data_source.dart';

import '../../Login Screen/Controller/login_notifier.dart';

import '../Model/shop_details_response.dart';

class ShopDetailsState {
  final bool isLoading;
  final String? error;
  final ShopDetailsResponse? shopDetailsResponse;

  const ShopDetailsState({
    this.isLoading = false,
    this.error,

    this.shopDetailsResponse,
  });

  factory ShopDetailsState.initial() => const ShopDetailsState();
}

class ShopDetailsNotifier extends Notifier<ShopDetailsState> {
  late final ApiDataSource api;

  @override
  ShopDetailsState build() {
    api = ref.read(apiDataSourceProvider);
    return ShopDetailsState.initial();
  }

  Future<void> fetchShopDetails({String? apiShopId}) async {
    state = const ShopDetailsState(isLoading: true, shopDetailsResponse: null, );

    final result = await api.getShopDetails(apiShopId: apiShopId);

    result.fold(
      (failure) =>
          state = ShopDetailsState(
            isLoading: false,
            error: failure.message,
            shopDetailsResponse: null,
          ),
      (response) =>
          state = ShopDetailsState(
            isLoading: false,
            shopDetailsResponse: response,
          ),
    );
  }

  void resetState() {
    state = ShopDetailsState.initial();
  }
}


final shopDetailsNotifierProvider =
NotifierProvider<ShopDetailsNotifier, ShopDetailsState>(
  ShopDetailsNotifier.new,
);
