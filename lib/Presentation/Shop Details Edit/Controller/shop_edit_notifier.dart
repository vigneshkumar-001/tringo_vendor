import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tringo_vendor_new/Api/DataSource/api_data_source.dart';
import 'package:tringo_vendor_new/Presentation/Shop%20Details%20Edit/Model/shop_root_response.dart';

import '../../Login Screen/Controller/login_notifier.dart';

class ShopEditState {
  final bool isLoading;
  final String? error;
  final ShopRootResponse? shopRootResponse;

  const ShopEditState({
    this.isLoading = false,
    this.error,
    this.shopRootResponse,
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

  Future<void> fetchAllShopDetails({String? shopId}) async {
    state = ShopEditState(isLoading: true);

    final result = await api.getAllShopDetails(shopId: shopId ?? '');

    result.fold(
      (failure) =>
          state = ShopEditState(
            isLoading: false,
            error: failure.message,
            shopRootResponse: null,
          ),
      (response) =>
          state = ShopEditState(isLoading: false, shopRootResponse: response),
    );
  }
}

final shopEditNotifierProvider =
    NotifierProvider<ShopEditNotifier, ShopEditState>(ShopEditNotifier.new);
