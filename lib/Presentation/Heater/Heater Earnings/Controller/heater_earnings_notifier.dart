import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../Api/DataSource/api_data_source.dart';
import '../../../Login Screen/Controller/login_notifier.dart';
import '../Model/heater_earnings_response.dart';

class HeaterEarningsState {
  final bool isLoading;
  final bool isFetchingMore;
  final bool hasMore;
  final String? error;

  final HeaterEarningsSummary? summary;
  final HeaterEarningsToolbar? toolbar;
  final List<HeaterEarningsGroup> groups;
  final int total;
  final String appliedSort;

  const HeaterEarningsState({
    this.isLoading = false,
    this.isFetchingMore = false,
    this.hasMore = true,
    this.error,
    this.summary,
    this.toolbar,
    this.groups = const [],
    this.total = 0,
    this.appliedSort = 'recent',
  });

  factory HeaterEarningsState.initial() => const HeaterEarningsState();

  HeaterEarningsState copyWith({
    bool? isLoading,
    bool? isFetchingMore,
    bool? hasMore,
    String? error,
    HeaterEarningsSummary? summary,
    HeaterEarningsToolbar? toolbar,
    List<HeaterEarningsGroup>? groups,
    int? total,
    String? appliedSort,
    bool clearError = false,
  }) {
    return HeaterEarningsState(
      isLoading: isLoading ?? this.isLoading,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
      hasMore: hasMore ?? this.hasMore,
      error: clearError ? null : (error ?? this.error),
      summary: summary ?? this.summary,
      toolbar: toolbar ?? this.toolbar,
      groups: groups ?? this.groups,
      total: total ?? this.total,
      appliedSort: appliedSort ?? this.appliedSort,
    );
  }
}

class HeaterEarningsNotifier extends Notifier<HeaterEarningsState> {
  late final ApiDataSource api;

  int _page = 1;
  final int _limit = 20;

  String _q = "";
  String _dateFrom = "";
  String _dateTo = "";
  String _sort = "recent";

  @override
  HeaterEarningsState build() {
    api = ref.read(apiDataSourceProvider);
    return HeaterEarningsState.initial();
  }

  void updateFilters({
    String? q,
    String? dateFrom,
    String? dateTo,
    String? sort,
    bool fetch = true,
  }) {
    if (q != null) _q = q;
    if (dateFrom != null) _dateFrom = dateFrom;
    if (dateTo != null) _dateTo = dateTo;
    if (sort != null) _sort = sort;

    if (fetch) fetchInitial();
  }

  int _itemsCount(List<HeaterEarningsGroup> groups) {
    var total = 0;
    for (final g in groups) {
      total += g.items.length;
    }
    return total;
  }

  List<HeaterEarningsGroup> _mergeGroups({
    required List<HeaterEarningsGroup> existing,
    required List<HeaterEarningsGroup> incoming,
  }) {
    if (existing.isEmpty) return incoming;
    if (incoming.isEmpty) return existing;

    final merged = [...existing];
    final last = merged.last;
    final firstIncoming = incoming.first;

    if (last.dateKey == firstIncoming.dateKey) {
      merged[merged.length - 1] = HeaterEarningsGroup(
        dateKey: last.dateKey,
        dateLabel: last.dateLabel,
        items: [...last.items, ...firstIncoming.items],
      );
      merged.addAll(incoming.skip(1));
      return merged;
    }

    merged.addAll(incoming);
    return merged;
  }

  Future<void> fetchInitial() async {
    _page = 1;

    state = state.copyWith(
      isLoading: true,
      isFetchingMore: false,
      hasMore: true,
      groups: const [],
      total: 0,
      clearError: true,
    );

    final result = await api.vendorEarnings(
      limit: _limit.toString(),
      page: _page.toString(),
      q: _q,
      dateFrom: _dateFrom,
      dateTo: _dateTo,
      sort: _sort,
    );

    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
      },
      (response) {
        final data = response.data;
        final groups = data.groups;
        final loaded = _itemsCount(groups);
        final hasMore = loaded < data.total;

        _sort = data.appliedFilters.sort;

        state = state.copyWith(
          isLoading: false,
          summary: data.summary,
          toolbar: data.toolbar,
          groups: groups,
          total: data.total,
          hasMore: hasMore,
          appliedSort: data.appliedFilters.sort,
        );
      },
    );
  }

  Future<void> fetchMore() async {
    if (state.isFetchingMore || !state.hasMore) return;

    state = state.copyWith(isFetchingMore: true);
    final nextPage = _page + 1;

    final result = await api.vendorEarnings(
      limit: _limit.toString(),
      page: nextPage.toString(),
      q: _q,
      dateFrom: _dateFrom,
      dateTo: _dateTo,
      sort: _sort,
    );

    result.fold(
      (failure) {
        state = state.copyWith(isFetchingMore: false);
      },
      (response) {
        _page = nextPage;
        final data = response.data;
        final merged = _mergeGroups(existing: state.groups, incoming: data.groups);
        final loaded = _itemsCount(merged);
        final hasMore = loaded < data.total;

        _sort = data.appliedFilters.sort;

        state = state.copyWith(
          isFetchingMore: false,
          summary: data.summary,
          toolbar: data.toolbar,
          groups: merged,
          total: data.total,
          hasMore: hasMore,
          appliedSort: data.appliedFilters.sort,
        );
      },
    );
  }
}

final heaterEarningsNotifierProvider =
    NotifierProvider<HeaterEarningsNotifier, HeaterEarningsState>(
      HeaterEarningsNotifier.new,
    );

