import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tringo_vendor_new/Api/DataSource/api_data_source.dart';
import 'package:tringo_vendor_new/Presentation/Shop%20Details%20Edit/Model/shop_details_response.dart';

import '../../Login Screen/Controller/login_notifier.dart';
import '../../Shops Details/Model/shop_details_response.dart';

class ShopEditState {
  final bool isLoading;
  final String? error;
  final ShopDetailsResponse? shopDetailsResponse;

  const ShopEditState({
    this.isLoading = false,
    this.error,
    this.shopDetailsResponse,
  });

  factory ShopEditState.initial() => const ShopEditState();
}

class ShopEditNotifier extends Notifier<ShopEditState> {
  late final ApiDataSource api;

  @override
  ShopEditState build() {
    api = ref.read(apiDataSourceProvider);
    return ShopEditState.initial();
  }

  Future<void> fetchShopDetails({String? apiShopId}) async {
    state = const ShopEditState(isLoading: true);

    final result = await api.getShopDetails(apiShopId:apiShopId );

    result.fold(
          (failure) => state = ShopEditState(
        isLoading: false,
        error: failure.message,
        shopDetailsResponse: null,
      ),
          (response) => state = ShopEditState(
        isLoading: false,
        shopDetailsResponse: response,
      ),
    );
  }
}

final shopEditNotifierProvider =
    NotifierProvider<ShopEditNotifier, ShopEditState>(ShopEditNotifier.new);
