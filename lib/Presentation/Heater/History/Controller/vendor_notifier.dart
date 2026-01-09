import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tringo_vendor_new/Presentation/Heater/History/Model/vendor_history_response.dart';
import '../../../../Api/DataSource/api_data_source.dart';
import '../../../Login Screen/Controller/login_notifier.dart';

class VendorState {
  final bool isLoading;
  final bool isFetchingMore;
  final bool hasMore;
  final String? error;
  final List<ShopItem> items;

  const VendorState({
    this.isLoading = false,
    this.isFetchingMore = false,
    this.hasMore = true,
    this.error,
    this.items = const [],
  });

  factory VendorState.initial() => const VendorState();

  VendorState copyWith({
    bool? isLoading,
    bool? isFetchingMore,
    bool? hasMore,
    String? error,
    List<ShopItem>? items,
    bool clearError = false,
  }) {
    return VendorState(
      isLoading: isLoading ?? this.isLoading,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
      hasMore: hasMore ?? this.hasMore,
      error: clearError ? null : (error ?? this.error),
      items: items ?? this.items,
    );
  }
}

class VendorNotifier extends Notifier<VendorState> {
  late final ApiDataSource api;

  int _page = 1;
  final int _limit = 10;

  // ✅ Filters saved inside notifier (used for pagination)
  String _q = "";
  String _categories = ""; // empty => no category filter
  String _dateFrom = ""; // empty => no date filter
  String _dateTo = ""; // empty => no date filter

  @override
  VendorState build() {
    api = ref.read(apiDataSourceProvider);
    return VendorState.initial();
  }

  void updateFilters({
    String? q,
    String? categories,
    String? dateFrom,
    String? dateTo,
    bool fetch = true,
  }) {
    if (q != null) _q = q;
    if (categories != null) _categories = categories;
    if (dateFrom != null) _dateFrom = dateFrom;
    if (dateTo != null) _dateTo = dateTo;

    if (fetch) fetchInitial();
  }

  Future<void> fetchInitial() async {
    _page = 1;

    state = state.copyWith(
      isLoading: true,
      isFetchingMore: false,
      hasMore: true,
      items: [],
      clearError: true,
    );

    final result = await api.vendorHistory(
      limit: _limit.toString(),
      page: _page.toString(),
      q: _q,
      categories: _categories,
      dateFrom: _dateFrom,
      dateTo: _dateTo,
    );

    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
      },
      (response) {
        final items = response.data.items;
        state = state.copyWith(
          isLoading: false,
          items: items,
          hasMore: items.length == _limit,
        );
      },
    );
  }

  Future<void> fetchMore() async {
    if (state.isFetchingMore || !state.hasMore) return;

    state = state.copyWith(isFetchingMore: true);
    final nextPage = _page + 1;

    final result = await api.vendorHistory(
      limit: _limit.toString(),
      page: nextPage.toString(),
      q: _q,
      categories: _categories,
      dateFrom: _dateFrom,
      dateTo: _dateTo,
    );

    result.fold(
      (failure) {
        state = state.copyWith(isFetchingMore: false);
      },
      (response) {
        _page = nextPage;
        final newItems = response.data.items;

        state = state.copyWith(
          isFetchingMore: false,
          items: [...state.items, ...newItems],
          hasMore: newItems.length == _limit,
        );
      },
    );
  }

  void resetAllAndReload() {
    _q = "";
    _categories = "";
    _dateFrom = "";
    _dateTo = "";
    fetchInitial();
  }
}

final vendorNotifierProvider = NotifierProvider<VendorNotifier, VendorState>(
  VendorNotifier.new,
);

// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:tringo_vendor_new/Presentation/Heater/History/Model/vendor_history_response.dart';
//
// import '../../../../Api/DataSource/api_data_source.dart';
// import '../../../Login Support Screen/Controller/login_notifier.dart';
//
// class VendorState {
//   final bool isLoading;
//   final bool isFetchingMore;
//   final bool hasMore;
//   final String? error;
//   final List<ShopItem> items;
//
//   const VendorState({
//     this.isLoading = false,
//     this.isFetchingMore = false,
//     this.hasMore = true,
//     this.error,
//     this.items = const [],
//   });
//
//   factory VendorState.initial() => const VendorState();
//
//   VendorState copyWith({
//     bool? isLoading,
//     bool? isFetchingMore,
//     bool? hasMore,
//     String? error,
//     List<ShopItem>? items,
//     bool clearError = false,
//   }) {
//     return VendorState(
//       isLoading: isLoading ?? this.isLoading,
//       isFetchingMore: isFetchingMore ?? this.isFetchingMore,
//       hasMore: hasMore ?? this.hasMore,
//       error: clearError ? null : (error ?? this.error),
//       items: items ?? this.items,
//     );
//   }
// }
//
// class VendorNotifier extends Notifier<VendorState> {
//   late final ApiDataSource api;
//
//   int _page = 1;
//   final int _limit = 10;
//
//   @override
//   VendorState build() {
//     api = ref.read(apiDataSourceProvider);
//
//     return VendorState.initial();
//   }
//
//   Future<void> fetchInitial() async {
//     _page = 1;
//     state = state.copyWith(
//       isLoading: true,
//       clearError: true,
//       hasMore: true,
//       items: [],
//     );
//
//     final result = await api.vendorHistory(
//       date: ,
//       search: ,
//       limit: _limit.toString(),
//       page: _page.toString(),
//     );
//
//     result.fold(
//       (failure) {
//         state = state.copyWith(isLoading: false, error: failure.message);
//       },
//       (response) {
//         final items = response.data.items;
//         state = state.copyWith(
//           isLoading: false,
//           items: items,
//           hasMore: items.length == _limit,
//         );
//       },
//     );
//   }
//
//   Future<void> fetchMore() async {
//     if (state.isFetchingMore || !state.hasMore) return;
//
//     state = state.copyWith(isFetchingMore: true);
//     _page++;
//
//     final result = await api.vendorHistory(
//       date: date,
//        search : search,
//       limit: _limit.toString(),
//       page: _page.toString(),
//     );
//
//     result.fold(
//       (failure) {
//         _page--;
//         state = state.copyWith(isFetchingMore: false);
//       },
//       (response) {
//         final newItems = response.data.items;
//         state = state.copyWith(
//           isFetchingMore: false,
//           items: [...state.items, ...newItems],
//           hasMore: newItems.length == _limit,
//         );
//       },
//     );
//   }
//
//   void reset() {
//     _page = 1;
//     state = VendorState.initial();
//   }
// }
//
// final vendorNotifierProvider = NotifierProvider<VendorNotifier, VendorState>(
//   VendorNotifier.new,
// );
