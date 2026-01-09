import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../Core/Const/app_color.dart';
import '../../../Core/Const/app_images.dart';
import '../../../Core/Utility/app_loader.dart';
import '../../../Core/Utility/app_textstyles.dart';
import '../../../Core/Utility/filter_popup_screen.dart';
import '../../../Core/Utility/sortby_popup_screen.dart';
import '../../../Core/Widgets/app_go_routes.dart';
import '../../Home Screen/Contoller/employee_home_notifier.dart';
import '../../Home Screen/Model/employee_home_response.dart';

class EmployeeHistory extends ConsumerStatefulWidget {
  const EmployeeHistory({super.key});

  @override
  ConsumerState<EmployeeHistory> createState() => _EmployeeHistoryState();
}

class _EmployeeHistoryState extends ConsumerState<EmployeeHistory> {
  bool _showSearch = false;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // pagination
  int _page = 1;
  final int _limit = 6;
  bool _isLoadingMore = false;
  bool _hasMore = true;

  // local cached list for smooth append
  final List<BusinessProfile> _items = [];

  // search/filter/sort
  String _q = '';
  String _dateFrom = DateFormat('yyyy-MM-dd').format(DateTime.now());
  String? _dateTo;
  String? _sortBy;
  Map<String, dynamic> _filters = {};

  // debounce for search + top loader
  Timer? _debounce;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _firstLoad(showMainLoader: true); // ✅ no await
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Set<String> _selectedCategories = {};

  bool _hasAnyFilterApplied() {
    final hasSearch = _searchController.text.trim().isNotEmpty;
    final hasDate = _selectedRange != null;
    final hasCategory = _selectedCategories.isNotEmpty;
    return hasSearch || hasDate || hasCategory;
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 2),
      lastDate: now,
      initialDateRange: _selectedRange ?? DateTimeRange(start: now, end: now),
    );

    if (picked == null) return;

    // ✅ Save for label
    _selectedRange = picked;

    // ✅ Convert to API format
    _dateFrom = DateFormat('yyyy-MM-dd').format(picked.start);
    _dateTo = DateFormat('yyyy-MM-dd').format(picked.end);

    _isSearching = true;
    if (mounted) setState(() {});
    await _firstLoad(showMainLoader: true);
    _isSearching = false;
    if (mounted) setState(() {});
  }

  // flatten grouped activity -> items list
  List<BusinessProfile> _flattenAll(EmployeeData data) {
    final freemium = data.recentActivity.freemium.expand((g) => g.items);
    final premium = data.recentActivity.premium.expand((g) => g.items);
    final pro = data.recentActivity.premiumPro.expand((g) => g.items);
    return [...freemium, ...premium, ...pro];
  }

  // helper: unique append by shopId
  void _appendUnique(List<BusinessProfile> incoming) {
    final existingIds = _items.map((e) => e.shopId).toSet();
    for (final it in incoming) {
      if (!existingIds.contains(it.shopId)) {
        _items.add(it);
        existingIds.add(it.shopId);
      }
    }
  }

  DateTime _onlyDate(DateTime d) => DateTime(d.year, d.month, d.day);

  DateTimeRange? _selectedRange;

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  final DateFormat _labelDf = DateFormat('dd MMM yyyy');

  String _selectedDateLabel() {
    final now = DateTime.now();
    final today = _onlyDate(now);
    final yesterday = today.subtract(const Duration(days: 1));

    if (_selectedRange == null) return "Today";

    final start = _onlyDate(_selectedRange!.start);
    final end = _onlyDate(_selectedRange!.end);

    if (_isSameDay(start, end)) {
      if (_isSameDay(start, today)) return "Today";
      if (_isSameDay(start, yesterday)) return "Yesterday";
      return _labelDf.format(start);
    }

    return "${_labelDf.format(start)}  →  ${_labelDf.format(end)}";
  }

  Widget _breadcrumbText(String text) {
    return Text(
      text,
      style: AppTextStyles.mulish(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: AppColor.darkBlue,
      ),
    );
  }

  Widget _breadcrumbArrow() {
    return Image.asset(
      AppImages.rightArrow,
      height: 10,
      color: AppColor.darkGrey,
    );
  }

  Future<void> _firstLoad({bool showMainLoader = false}) async {
    _page = 1;
    _hasMore = true;
    _isLoadingMore = false;
    _items.clear();

    if (mounted) setState(() {});

    final notifier = ref.read(employeeHomeNotifier.notifier);

    await notifier.employeeHome(
      date: _dateFrom,
      page: _page.toString(),
      limit: _limit.toString(),
      q: _q,
    );

    if (!mounted) return;

    final st = ref.read(employeeHomeNotifier);
    final data = st.employeeHomeResponse?.data;

    if (data != null) {
      final fresh = _flattenAll(data);
      _appendUnique(fresh);
      _hasMore = data.pagination.hasMore;
    } else {
      _hasMore = false;
    }

    if (mounted) setState(() {});
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;
    if (mounted) setState(() {});

    _page += 1;

    await ref
        .read(employeeHomeNotifier.notifier)
        .employeeHome(
          date: _dateFrom,
          page: _page.toString(),
          limit: _limit.toString(),
          q: _q,
        );

    final st = ref.read(employeeHomeNotifier);
    final data = st.employeeHomeResponse?.data;

    if (data != null) {
      final next = _flattenAll(data);
      _appendUnique(next);
      _hasMore = data.pagination.hasMore;
    } else {
      _hasMore = false;
    }

    _isLoadingMore = false;
    if (mounted) setState(() {});
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final remaining = _scrollController.position.extentAfter;
    if (remaining < 350) _loadMore();
  }

  // Search debounce + top loader
  void _onSearchChanged(String value) {
    _q = value.trim();

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      if (!mounted) return;
      _isSearching = true;
      setState(() {});
      await _firstLoad();
      _isSearching = false;
      if (mounted) setState(() {});
    });
  }

  Future<void> _clearSearch() async {
    _debounce?.cancel();
    _searchController.clear();
    _q = '';
    _showSearch = false;

    _isSearching = true;
    if (mounted) setState(() {});
    await _firstLoad(showMainLoader: true);
    _isSearching = false;
    if (mounted) setState(() {});
  }

  // Apply filters/sort/date
  Future<void> _applyFilterSort({
    Map<String, dynamic>? filters,
    String? sortBy,
    String? dateFrom,
    String? dateTo,
  }) async {
    if (filters != null) _filters = filters;
    if (sortBy != null) _sortBy = sortBy;
    if (dateFrom != null) _dateFrom = dateFrom;
    _dateTo = dateTo;

    _isSearching = true;
    if (mounted) setState(() {});
    await _firstLoad(showMainLoader: true);
    _isSearching = false;
    if (mounted) setState(() {});
  }

  // ✅ Skeleton dummy item card widget (your design)
  Widget _skeletonCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.iceGray,
        borderRadius: BorderRadius.circular(15),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Category > Subcategory",
            style: AppTextStyles.mulish(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColor.darkBlue,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Container(
              height: 143,
              width: double.infinity,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Shop Name",
            style: AppTextStyles.mulish(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: AppColor.darkBlue,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Address line will be here",
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.mulish(
              fontWeight: FontWeight.w400,
              fontSize: 12,
              color: AppColor.lightGray3,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColor.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "PREMIUM",
                  style: AppTextStyles.mulish(
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                    color: AppColor.darkBlue,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColor.black,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const SizedBox(height: 16, width: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Empty state (scrollable for refresh)
  Widget _emptyState({
    required String title,
    required String subtitle,
    VoidCallback? onClear,
  }) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 90),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            decoration: BoxDecoration(
              color: AppColor.iceGray,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.search_off,
                  size: 44,
                  color: Colors.black.withOpacity(0.35),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.mulish(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: AppColor.darkBlue,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.mulish(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    color: AppColor.lightGray3,
                  ),
                ),
                const SizedBox(height: 14),
                if (onClear != null)
                  InkWell(
                    onTap: onClear,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppColor.black,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Text(
                        "Clear filter",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _rangeText() {
    if (_dateTo == null || _dateTo!.isEmpty) return _dateFrom;
    return "$_dateFrom to $_dateTo";
  }

  Widget _chipButton(String text) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColor.lightGray2),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 9),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(text, style: AppTextStyles.mulish(color: AppColor.lightGray2)),
            const SizedBox(width: 10),
            Image.asset(AppImages.drapDownImage, height: 19),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(employeeHomeNotifier);

    // ✅ initial loading = show skeleton list
    final isInitialLoading = state.isLoading && _items.isEmpty;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Text(
                'History',
                style: AppTextStyles.mulish(
                  fontWeight: FontWeight.w700,
                  fontSize: 24,
                  color: AppColor.darkBlue,
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Search + Filter + Sort Row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => setState(() => _showSearch = true),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child:
                          _showSearch
                              ? Container(
                                key: const ValueKey('searchField'),
                                width: 260,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppColor.darkBlue),
                                  borderRadius: BorderRadius.circular(25),
                                  color: AppColor.white,
                                ),
                                child: Row(
                                  children: [
                                    Image.asset(
                                      AppImages.searchImage,
                                      height: 14,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: TextField(
                                        controller: _searchController,
                                        autofocus: true,
                                        decoration: const InputDecoration(
                                          hintText: 'Search...',
                                          border: InputBorder.none,
                                        ),
                                        onChanged: _onSearchChanged,
                                      ),
                                    ),
                                    InkWell(
                                      onTap: _clearSearch,
                                      child: const Icon(Icons.close, size: 18),
                                    ),
                                  ],
                                ),
                              )
                              : Container(
                                key: const ValueKey('searchButton'),
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppColor.darkBlue),
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 47,
                                  vertical: 8,
                                ),
                                child: Row(
                                  children: [
                                    Image.asset(
                                      AppImages.searchImage,
                                      height: 14,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      'Search',
                                      style: AppTextStyles.mulish(
                                        color: AppColor.darkBlue,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // Filter
                  GestureDetector(
                    onTap: () async {
                      final result =
                          await showModalBottomSheet<Map<String, dynamic>>(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            showDragHandle: true,
                            builder:
                                (_) => FilterPopupScreen(
                                  initialSelectedCategories:
                                      _filters["plan"] == null
                                          ? {"Premium"}
                                          : {
                                            _filters["plan"] == "premiumPro"
                                                ? "Premium Pro"
                                                : (_filters["plan"] ==
                                                        "freemium"
                                                    ? "Freemium"
                                                    : "Premium"),
                                          },
                                  initialDateRange:
                                      (_dateTo != null && _dateTo!.isNotEmpty)
                                          ? DateTimeRange(
                                            start: DateTime.parse(_dateFrom),
                                            end: DateTime.parse(_dateTo!),
                                          )
                                          : null,
                                ),
                          );

                      if (result != null) {
                        await _applyFilterSort(
                          filters:
                              (result["filters"] as Map<String, dynamic>?) ??
                              _filters,
                          dateFrom: result["dateFrom"] as String?,
                          dateTo: result["dateTo"] as String?,
                        );
                      }
                    },
                    child: _chipButton('Filter'),
                  ),

                  const SizedBox(width: 10),

                  // Sort
                  GestureDetector(
                    onTap: () async {
                      final result = await showModalBottomSheet<String>(
                        backgroundColor: Colors.transparent,
                        context: context,
                        isScrollControlled: true,
                        showDragHandle: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                        builder: (_) => const SortbyPopupScreen(),
                      );

                      if (result != null) {
                        await _applyFilterSort(sortBy: result);
                      }
                    },
                    child: _chipButton('Sort By'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // GestureDetector(
            //   onTap: _pickDateRange, // ✅ date select open
            //   child: Center(
            //     child: Text(
            //       _selectedDateLabel(),
            //       style: AppTextStyles.mulish(
            //         fontSize: 12,
            //         fontWeight: FontWeight.w600,
            //         color: AppColor.lightGray2,
            //       ),
            //     ),
            //   ),
            // ),
            // const SizedBox(height: 16),

            // if (_hasAnyFilterApplied())
            //   Padding(
            //     padding: const EdgeInsets.symmetric(horizontal: 16),
            //     child: Text(
            //       "Filters applied",
            //       style: AppTextStyles.mulish(
            //         fontSize: 12,
            //         fontWeight: FontWeight.w700,
            //         color: AppColor.lightGray2,
            //       ),
            //     ),
            //   ),
            SizedBox(height: 10),

            Expanded(
              child: Stack(
                children: [
                  RefreshIndicator(
                    onRefresh: () => _firstLoad(showMainLoader: false),
                    child:
                        isInitialLoading
                            ? Skeletonizer(
                              enabled: true,
                              child: ListView.builder(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 15,
                                  vertical: 10,
                                ),
                                itemCount: _limit,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: _skeletonCard(),
                                  );
                                },
                              ),
                            )
                            : (_items.isEmpty
                                ? _emptyState(
                                  title:
                                      _q.isNotEmpty
                                          ? "No results found"
                                          : "No data for selected date",
                                  subtitle:
                                      _q.isNotEmpty
                                          ? "Try a different keyword or clear search."
                                          : "No records available for ${_rangeText()}. Try another date range.",
                                  onClear: () async {
                                    _debounce?.cancel();
                                    _searchController.clear();
                                    _q = '';
                                    _filters = {};
                                    _sortBy = null;
                                    _dateFrom = DateFormat(
                                      'yyyy-MM-dd',
                                    ).format(DateTime.now());
                                    _dateTo = null;

                                    _isSearching = true;
                                    if (mounted) setState(() {});
                                    await _firstLoad(showMainLoader: true);
                                    _isSearching = false;
                                    if (mounted) setState(() {});
                                  },
                                )
                                : ListView.builder(
                                  controller: _scrollController,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 15,
                                    vertical: 10,
                                  ),
                                  itemCount: _items.length + 1,
                                  itemBuilder: (context, index) {
                                    // bottom loader
                                    if (index == _items.length) {
                                      if (_isLoadingMore) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 16,
                                          ),
                                          child: Center(
                                            child: AppLoader.circularLoader(
                                              color: AppColor.darkBlue,
                                            ),
                                          ),
                                        );
                                      }
                                      return const SizedBox(height: 20);
                                    }

                                    final item = _items[index];

                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 12,
                                      ),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: AppColor.iceGray,
                                          borderRadius: BorderRadius.circular(
                                            15,
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      AppColor.black
                                                          .withOpacity(0.054),
                                                      AppColor.black
                                                          .withOpacity(0.0),
                                                    ],
                                                    begin: Alignment.centerLeft,
                                                    end: Alignment.centerRight,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                ),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 15,
                                                        vertical: 10,
                                                      ),
                                                  child: Wrap(
                                                    crossAxisAlignment:
                                                        WrapCrossAlignment
                                                            .center,
                                                    spacing: 6,
                                                    runSpacing: 6,
                                                    children: [
                                                      _breadcrumbText(
                                                        item.typeLabel,
                                                      ),
                                                      _breadcrumbArrow(),
                                                      _breadcrumbText(
                                                        item.categoryLabel,
                                                      ),
                                                      _breadcrumbArrow(),
                                                      _breadcrumbText(
                                                        item.subCategoryLabel,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 12),
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                child: SizedBox(
                                                  height: 143,
                                                  width: double.infinity,
                                                  child: CachedNetworkImage(
                                                    imageUrl:
                                                        item.imageUrl ?? '',
                                                    fit: BoxFit.cover,
                                                    placeholder:
                                                        (
                                                          context,
                                                          url,
                                                        ) => const Center(
                                                          child: SizedBox(
                                                            height: 22,
                                                            width: 22,
                                                            child:
                                                                CircularProgressIndicator(
                                                                  strokeWidth:
                                                                      2,
                                                                ),
                                                          ),
                                                        ),
                                                    errorWidget:
                                                        (
                                                          context,
                                                          url,
                                                          error,
                                                        ) => Container(
                                                          color: Colors.black
                                                              .withOpacity(
                                                                0.05,
                                                              ),
                                                          alignment:
                                                              Alignment.center,
                                                          child: Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: const [
                                                              Icon(
                                                                Icons
                                                                    .broken_image,
                                                                size: 34,
                                                                color:
                                                                    Colors.grey,
                                                              ),
                                                              SizedBox(
                                                                height: 6,
                                                              ),
                                                              Text(
                                                                "Image not available",
                                                                style: TextStyle(
                                                                  fontSize: 11,
                                                                  color:
                                                                      Colors
                                                                          .grey,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 12),
                                              Text(
                                                item.englishName.isNotEmpty
                                                    ? item.englishName
                                                    : item.tamilName,
                                                style: AppTextStyles.mulish(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 16,
                                                  color: AppColor.darkBlue,
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                item.addressEn,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: AppTextStyles.mulish(
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 12,
                                                  color: AppColor.lightGray3,
                                                ),
                                              ),
                                              const SizedBox(height: 12),
                                              Row(
                                                children: [
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 10,
                                                          vertical: 6,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: AppColor.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            20,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      item.planCategory,
                                                      style:
                                                          AppTextStyles.mulish(
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            fontSize: 11,
                                                            color:
                                                                AppColor
                                                                    .darkBlue,
                                                          ),
                                                    ),
                                                  ),
                                                  const Spacer(),
                                                  GestureDetector(
                                                    onTap: () {
                                                      context.push(
                                                        AppRoutes
                                                            .shopDetailsEditPath,
                                                        extra: {
                                                          'shopId': item.shopId,
                                                          'businessProfileId':
                                                              item.businessProfileId,
                                                        },
                                                      );
                                                    },
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 12,
                                                            vertical: 8,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: AppColor.black,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              25,
                                                            ),
                                                      ),
                                                      child: Image.asset(
                                                        AppImages
                                                            .rightStickArrow,
                                                        height: 16,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                )),
                  ),

                  // small top loader while searching/filtering/sorting
                  if (_isSearching)
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        alignment: Alignment.center,
                        child: const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// import 'dart:async';
//
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import 'package:intl/intl.dart';
//
// import '../../../Core/Const/app_color.dart';
// import '../../../Core/Const/app_images.dart';
// import '../../../Core/Utility/app_loader.dart';
// import '../../../Core/Utility/app_textstyles.dart';
// import '../../../Core/Utility/filter_popup_screen.dart';
// import '../../../Core/Utility/sortby_popup_screen.dart';
// import '../../../Core/Widgets/app_go_routes.dart';
// import '../../Home Support Screen/Contoller/employee_home_notifier.dart';
// import '../../Home Support Screen/Model/employee_home_response.dart';
//
// class EmployeeHistory extends ConsumerStatefulWidget {
//   const EmployeeHistory({super.key});
//
//   @override
//   ConsumerState<EmployeeHistory> createState() => _EmployeeHistoryState();
// }
//
// class _EmployeeHistoryState extends ConsumerState<EmployeeHistory> {
//   bool _showSearch = false;
//   final TextEditingController _searchController = TextEditingController();
//   final ScrollController _scrollController = ScrollController();
//
//   // pagination
//   int _page = 1;
//   final int _limit = 6;
//   bool _isLoadingMore = false;
//   bool _hasMore = true;
//
//   // local cached list for smooth append
//   final List<BusinessProfile> _items = [];
//
//   // search/filter/sort
//   String _q = '';
//   String _dateFrom = DateFormat('yyyy-MM-dd').format(DateTime.now());
//   String? _dateTo; // ✅ date range end
//   String? _sortBy; // ✅ from SortbyPopupScreen
//   Map<String, dynamic> _filters = {}; // ✅ from FilterPopupScreen
//
//   // debounce for search + top loader
//   Timer? _debounce;
//   bool _isSearching = false;
//
//   @override
//   void initState() {
//     super.initState();
//
//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       await _firstLoad(showMainLoader: true);
//     });
//
//     _scrollController.addListener(_onScroll);
//   }
//
//   @override
//   void dispose() {
//     _debounce?.cancel();
//     _scrollController.dispose();
//     _searchController.dispose();
//     super.dispose();
//   }
//
//   // flatten grouped activity -> items list
//   List<BusinessProfile> _flattenAll(EmployeeData data) {
//     final freemium = data.recentActivity.freemium.expand((g) => g.items);
//     final premium = data.recentActivity.premium.expand((g) => g.items);
//     final pro = data.recentActivity.premiumPro.expand((g) => g.items);
//     return [...freemium, ...premium, ...pro];
//   }
//
//   // helper: unique append by shopId
//   void _appendUnique(List<BusinessProfile> incoming) {
//     final existingIds = _items.map((e) => e.shopId).toSet();
//     for (final it in incoming) {
//       if (!existingIds.contains(it.shopId)) {
//         _items.add(it);
//         existingIds.add(it.shopId);
//       }
//     }
//   }
//
//   Future<void> _firstLoad({bool showMainLoader = false}) async {
//     _page = 1;
//     _hasMore = true;
//     _isLoadingMore = false;
//     _items.clear();
//
//     if (showMainLoader && mounted) setState(() {});
//
//     await ref
//         .read(employeeHomeNotifier.notifier)
//         .employeeHome(
//           date: _dateFrom,
//           // ✅ if your notifier supports dateTo/plan/sortBy add params there
//           // dateTo: _dateTo,
//           page: _page.toString(),
//           limit: _limit.toString(),
//           q: _q,
//           // plan: _filters['plan'],
//           // sortBy: _sortBy,
//         );
//
//     final st = ref.read(employeeHomeNotifier);
//     final data = st.employeeHomeResponse?.data;
//
//     if (data != null) {
//       final fresh = _flattenAll(data);
//       _appendUnique(fresh);
//       _hasMore = data.pagination.hasMore;
//     } else {
//       _hasMore = false;
//     }
//
//     if (mounted) setState(() {});
//   }
//
//   Future<void> _loadMore() async {
//     if (_isLoadingMore || !_hasMore) return;
//
//     _isLoadingMore = true;
//     if (mounted) setState(() {});
//
//     _page += 1;
//
//     await ref
//         .read(employeeHomeNotifier.notifier)
//         .employeeHome(
//           date: _dateFrom,
//           // dateTo: _dateTo,
//           page: _page.toString(),
//           limit: _limit.toString(),
//           q: _q,
//           // plan: _filters['plan'],
//           // sortBy: _sortBy,
//         );
//
//     final st = ref.read(employeeHomeNotifier);
//     final data = st.employeeHomeResponse?.data;
//
//     if (data != null) {
//       final next = _flattenAll(data);
//       _appendUnique(next);
//       _hasMore = data.pagination.hasMore;
//     } else {
//       _hasMore = false;
//     }
//
//     _isLoadingMore = false;
//     if (mounted) setState(() {});
//   }
//
//   void _onScroll() {
//     if (!_scrollController.hasClients) return;
//
//     final remaining = _scrollController.position.extentAfter;
//     if (remaining < 350) _loadMore();
//   }
//
//   // Search with debounce + loader
//   void _onSearchChanged(String value) {
//     _q = value.trim();
//
//     _debounce?.cancel();
//     _debounce = Timer(const Duration(milliseconds: 400), () async {
//       if (!mounted) return;
//       _isSearching = true;
//       setState(() {});
//       await _firstLoad();
//       _isSearching = false;
//       if (mounted) setState(() {});
//     });
//   }
//
//   Future<void> _clearSearch() async {
//     _debounce?.cancel();
//     _searchController.clear();
//     _q = '';
//     _showSearch = false;
//
//     _isSearching = true;
//     if (mounted) setState(() {});
//     await _firstLoad(showMainLoader: true);
//     _isSearching = false;
//     if (mounted) setState(() {});
//   }
//
//   // Apply filters/sort/date
//   Future<void> _applyFilterSort({
//     Map<String, dynamic>? filters,
//     String? sortBy,
//     String? dateFrom,
//     String? dateTo,
//   }) async {
//     if (filters != null) _filters = filters;
//     if (sortBy != null) _sortBy = sortBy;
//     if (dateFrom != null) _dateFrom = dateFrom;
//     _dateTo = dateTo;
//
//     _isSearching = true;
//     if (mounted) setState(() {});
//     await _firstLoad(showMainLoader: true);
//     _isSearching = false;
//     if (mounted) setState(() {});
//   }
//
//   // Modern empty state (still scrollable for refresh)
//   Widget _emptyState({
//     required String title,
//     required String subtitle,
//     VoidCallback? onClear,
//   }) {
//     return ListView(
//       physics: const AlwaysScrollableScrollPhysics(),
//       children: [
//         const SizedBox(height: 90),
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 18),
//           child: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
//             decoration: BoxDecoration(
//               color: AppColor.iceGray,
//               borderRadius: BorderRadius.circular(18),
//             ),
//             child: Column(
//               children: [
//                 Icon(
//                   Icons.search_off,
//                   size: 44,
//                   color: Colors.black.withOpacity(0.35),
//                 ),
//                 const SizedBox(height: 12),
//                 Text(
//                   title,
//                   textAlign: TextAlign.center,
//                   style: AppTextStyles.mulish(
//                     fontWeight: FontWeight.w800,
//                     fontSize: 16,
//                     color: AppColor.darkBlue,
//                   ),
//                 ),
//                 const SizedBox(height: 6),
//                 Text(
//                   subtitle,
//                   textAlign: TextAlign.center,
//                   style: AppTextStyles.mulish(
//                     fontWeight: FontWeight.w500,
//                     fontSize: 12,
//                     color: AppColor.lightGray3,
//                   ),
//                 ),
//                 const SizedBox(height: 14),
//                 if (onClear != null)
//                   InkWell(
//                     onTap: onClear,
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 14,
//                         vertical: 10,
//                       ),
//                       decoration: BoxDecoration(
//                         color: AppColor.black,
//                         borderRadius: BorderRadius.circular(30),
//                       ),
//                       child: const Text(
//                         "Clear filter",
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 12,
//                           fontWeight: FontWeight.w700,
//                         ),
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   String _rangeText() {
//     if (_dateTo == null || _dateTo!.isEmpty) return _dateFrom;
//     return "$_dateFrom to $_dateTo";
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final state = ref.watch(employeeHomeNotifier);
//     final isInitialLoading = state.isLoading && _items.isEmpty;
//
//     return Scaffold(
//       body: SafeArea(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Title
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//               child: Text(
//                 'History',
//                 style: AppTextStyles.mulish(
//                   fontWeight: FontWeight.w700,
//                   fontSize: 24,
//                   color: AppColor.darkBlue,
//                 ),
//               ),
//             ),
//
//             const SizedBox(height: 10),
//
//             // Search + Filter + Sort Row
//             SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               physics: const BouncingScrollPhysics(),
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: Row(
//                 children: [
//                   GestureDetector(
//                     onTap: () => setState(() => _showSearch = true),
//                     child: AnimatedSwitcher(
//                       duration: const Duration(milliseconds: 300),
//                       child:
//                           _showSearch
//                               ? Container(
//                                 key: const ValueKey('searchField'),
//                                 width: 260,
//                                 padding: const EdgeInsets.symmetric(
//                                   horizontal: 12,
//                                 ),
//                                 decoration: BoxDecoration(
//                                   border: Border.all(color: AppColor.darkBlue),
//                                   borderRadius: BorderRadius.circular(25),
//                                   color: AppColor.white,
//                                 ),
//                                 child: Row(
//                                   children: [
//                                     Image.asset(
//                                       AppImages.searchImage,
//                                       height: 14,
//                                     ),
//                                     const SizedBox(width: 8),
//
//                                     // ✅ only one Expanded
//                                     Expanded(
//                                       child: TextField(
//                                         controller: _searchController,
//                                         autofocus: true,
//                                         decoration: const InputDecoration(
//                                           hintText: 'Search...',
//                                           border: InputBorder.none,
//                                         ),
//                                         onChanged: _onSearchChanged,
//                                       ),
//                                     ),
//                                     InkWell(
//                                       onTap: _clearSearch,
//                                       child: const Icon(Icons.close, size: 18),
//                                     ),
//                                   ],
//                                 ),
//                               )
//                               : Container(
//                                 key: const ValueKey('searchButton'),
//                                 decoration: BoxDecoration(
//                                   border: Border.all(color: AppColor.darkBlue),
//                                   borderRadius: BorderRadius.circular(25),
//                                 ),
//                                 padding: const EdgeInsets.symmetric(
//                                   horizontal: 47,
//                                   vertical: 8,
//                                 ),
//                                 child: Row(
//                                   children: [
//                                     Image.asset(
//                                       AppImages.searchImage,
//                                       height: 14,
//                                     ),
//                                     const SizedBox(width: 10),
//                                     Text(
//                                       'Search',
//                                       style: AppTextStyles.mulish(
//                                         color: AppColor.darkBlue,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                     ),
//                   ),
//
//                   const SizedBox(width: 10),
//
//                   // Filter
//                   GestureDetector(
//                     onTap: () async {
//                       final result =
//                           await showModalBottomSheet<Map<String, dynamic>>(
//                             context: context,
//                             isScrollControlled: true,
//                             backgroundColor: Colors.transparent,
//                             showDragHandle: true,
//                             builder:
//                                 (_) => FilterPopupScreen(
//                                   initialSelectedCategories:
//                                       _filters["plan"] == null
//                                           ? {"Premium"}
//                                           : {
//                                             _filters["plan"] == "premiumPro"
//                                                 ? "Premium Pro"
//                                                 : (_filters["plan"] ==
//                                                         "freemium"
//                                                     ? "Freemium"
//                                                     : "Premium"),
//                                           },
//                                   initialDateRange:
//                                       (_dateTo != null && _dateTo!.isNotEmpty)
//                                           ? DateTimeRange(
//                                             start: DateTime.parse(_dateFrom),
//                                             end: DateTime.parse(_dateTo!),
//                                           )
//                                           : null,
//                                 ),
//                           );
//
//                       if (result != null) {
//                         await _applyFilterSort(
//                           filters:
//                               (result["filters"] as Map<String, dynamic>?) ??
//                               _filters,
//                           dateFrom: result["dateFrom"] as String?,
//                           dateTo: result["dateTo"] as String?,
//                         );
//                       }
//                     },
//                     child: _chipButton('Filter'),
//                   ),
//
//                   const SizedBox(width: 10),
//
//                   // Sort
//                   GestureDetector(
//                     onTap: () async {
//                       final result = await showModalBottomSheet<String>(
//                         backgroundColor: Colors.transparent,
//                         context: context,
//                         isScrollControlled: true,
//                         showDragHandle: true,
//                         shape: const RoundedRectangleBorder(
//                           borderRadius: BorderRadius.vertical(
//                             top: Radius.circular(20),
//                           ),
//                         ),
//                         builder: (_) => const SortbyPopupScreen(),
//                       );
//
//                       if (result != null) {
//                         await _applyFilterSort(sortBy: result);
//                       }
//                     },
//                     child: _chipButton('Sort By'),
//                   ),
//                 ],
//               ),
//             ),
//
//             const SizedBox(height: 16),
//
//             Expanded(
//               child:
//                   isInitialLoading
//                       ? const Center(
//                         child: ThreeDotsLoader(dotColor: AppColor.darkBlue),
//                       )
//                       : Stack(
//                         children: [
//                           RefreshIndicator(
//                             onRefresh: () => _firstLoad(showMainLoader: false),
//                             child:
//                                 _items.isEmpty
//                                     ? _emptyState(
//                                       title:
//                                           _q.isNotEmpty
//                                               ? "No results found"
//                                               : "No data for selected date",
//                                       subtitle:
//                                           _q.isNotEmpty
//                                               ? "Try a different keyword or clear search."
//                                               : "No records available for ${_rangeText()}. Try another date range.",
//                                       onClear: () async {
//                                         _debounce?.cancel();
//                                         _searchController.clear();
//                                         _q = '';
//                                         _filters = {};
//                                         _sortBy = null;
//                                         _dateFrom = DateFormat(
//                                           'yyyy-MM-dd',
//                                         ).format(DateTime.now());
//                                         _dateTo = null;
//
//                                         _isSearching = true;
//                                         if (mounted) setState(() {});
//                                         await _firstLoad(showMainLoader: true);
//                                         _isSearching = false;
//                                         if (mounted) setState(() {});
//                                       },
//                                     )
//                                     : ListView.builder(
//                                       controller: _scrollController,
//                                       padding: const EdgeInsets.symmetric(
//                                         horizontal: 15,
//                                         vertical: 10,
//                                       ),
//                                       itemCount: _items.length + 1,
//                                       itemBuilder: (context, index) {
//                                         // bottom loader
//                                         if (index == _items.length) {
//                                           if (_isLoadingMore) {
//                                             return Padding(
//                                               padding:
//                                                   const EdgeInsets.symmetric(
//                                                     vertical: 16,
//                                                   ),
//                                               child: Center(
//                                                 child: AppLoader.circularLoader(
//                                                   color: AppColor.darkBlue,
//                                                 ),
//                                               ),
//                                             );
//                                           }
//                                           // if (!_hasMore && _items.isNotEmpty) {
//                                           //   return const Padding(
//                                           //     padding: EdgeInsets.symmetric(
//                                           //         vertical: 18),
//                                           //     child: Center(
//                                           //         child: Text("No more data")),
//                                           //   );
//                                           // }
//                                           return const SizedBox(height: 20);
//                                         }
//
//                                         final item = _items[index];
//
//                                         return Padding(
//                                           padding: const EdgeInsets.only(
//                                             bottom: 12,
//                                           ),
//                                           child: Container(
//                                             decoration: BoxDecoration(
//                                               color: AppColor.iceGray,
//                                               borderRadius:
//                                                   BorderRadius.circular(15),
//                                             ),
//                                             child: Padding(
//                                               padding: const EdgeInsets.all(16),
//                                               child: Column(
//                                                 crossAxisAlignment:
//                                                     CrossAxisAlignment.start,
//                                                 children: [
//                                                   Text(
//                                                     item.breadcrumb.isNotEmpty
//                                                         ? item.breadcrumb
//                                                         : "${item.categoryLabel} > ${item.subCategoryLabel}",
//                                                     style: AppTextStyles.mulish(
//                                                       fontSize: 12,
//                                                       fontWeight:
//                                                           FontWeight.bold,
//                                                       color: AppColor.darkBlue,
//                                                     ),
//                                                   ),
//                                                   const SizedBox(height: 12),
//
//                                                   ClipRRect(
//                                                     borderRadius:
//                                                         BorderRadius.circular(
//                                                           15,
//                                                         ),
//                                                     child: SizedBox(
//                                                       height: 143,
//                                                       width: double.infinity,
//                                                       child: CachedNetworkImage(
//                                                         imageUrl:
//                                                             item.imageUrl ?? '',
//                                                         fit: BoxFit.cover,
//                                                         placeholder:
//                                                             (
//                                                               context,
//                                                               url,
//                                                             ) => const Center(
//                                                               child: SizedBox(
//                                                                 height: 22,
//                                                                 width: 22,
//                                                                 child:
//                                                                     CircularProgressIndicator(
//                                                                       strokeWidth:
//                                                                           2,
//                                                                     ),
//                                                               ),
//                                                             ),
//                                                         errorWidget:
//                                                             (
//                                                               context,
//                                                               url,
//                                                               error,
//                                                             ) => Container(
//                                                               color: Colors
//                                                                   .black
//                                                                   .withOpacity(
//                                                                     0.05,
//                                                                   ),
//                                                               alignment:
//                                                                   Alignment
//                                                                       .center,
//                                                               child: Column(
//                                                                 mainAxisSize:
//                                                                     MainAxisSize
//                                                                         .min,
//                                                                 children: const [
//                                                                   Icon(
//                                                                     Icons
//                                                                         .broken_image,
//                                                                     size: 34,
//                                                                     color:
//                                                                         Colors
//                                                                             .grey,
//                                                                   ),
//                                                                   SizedBox(
//                                                                     height: 6,
//                                                                   ),
//                                                                   Text(
//                                                                     "Image not available",
//                                                                     style: TextStyle(
//                                                                       fontSize:
//                                                                           11,
//                                                                       color:
//                                                                           Colors
//                                                                               .grey,
//                                                                     ),
//                                                                   ),
//                                                                 ],
//                                                               ),
//                                                             ),
//                                                       ),
//                                                     ),
//                                                   ),
//
//                                                   const SizedBox(height: 12),
//                                                   Text(
//                                                     item.englishName.isNotEmpty
//                                                         ? item.englishName
//                                                         : item.tamilName,
//                                                     style: AppTextStyles.mulish(
//                                                       fontWeight:
//                                                           FontWeight.w700,
//                                                       fontSize: 16,
//                                                       color: AppColor.darkBlue,
//                                                     ),
//                                                   ),
//                                                   const SizedBox(height: 6),
//                                                   Text(
//                                                     item.addressEn,
//                                                     maxLines: 2,
//                                                     overflow:
//                                                         TextOverflow.ellipsis,
//                                                     style: AppTextStyles.mulish(
//                                                       fontWeight:
//                                                           FontWeight.w400,
//                                                       fontSize: 12,
//                                                       color:
//                                                           AppColor.lightGray3,
//                                                     ),
//                                                   ),
//                                                   const SizedBox(height: 12),
//                                                   Row(
//                                                     children: [
//                                                       Container(
//                                                         padding:
//                                                             const EdgeInsets.symmetric(
//                                                               horizontal: 10,
//                                                               vertical: 6,
//                                                             ),
//                                                         decoration: BoxDecoration(
//                                                           color: AppColor.white,
//                                                           borderRadius:
//                                                               BorderRadius.circular(
//                                                                 20,
//                                                               ),
//                                                         ),
//                                                         child: Text(
//                                                           item.planCategory,
//                                                           style:
//                                                               AppTextStyles.mulish(
//                                                                 fontWeight:
//                                                                     FontWeight
//                                                                         .w700,
//                                                                 fontSize: 11,
//                                                                 color:
//                                                                     AppColor
//                                                                         .darkBlue,
//                                                               ),
//                                                         ),
//                                                       ),
//                                                       const Spacer(),
//                                                       GestureDetector(
//                                                         onTap: () {
//                                                           context.push(
//                                                             AppRoutes
//                                                                 .shopDetailsEditPath,
//                                                             extra: item.shopId,
//                                                           );
//                                                         },
//                                                         child: Container(
//                                                           padding:
//                                                               const EdgeInsets.symmetric(
//                                                                 horizontal: 12,
//                                                                 vertical: 8,
//                                                               ),
//                                                           decoration: BoxDecoration(
//                                                             color:
//                                                                 AppColor.black,
//                                                             borderRadius:
//                                                                 BorderRadius.circular(
//                                                                   25,
//                                                                 ),
//                                                           ),
//                                                           child: Image.asset(
//                                                             AppImages
//                                                                 .rightStickArrow,
//                                                             height: 16,
//                                                           ),
//                                                         ),
//                                                       ),
//                                                     ],
//                                                   ),
//                                                 ],
//                                               ),
//                                             ),
//                                           ),
//                                         );
//                                       },
//                                     ),
//                           ),
//
//                           // small top loader while searching/filtering/sorting
//                           if (_isSearching)
//                             Positioned(
//                               top: 0,
//                               left: 0,
//                               right: 0,
//                               child: Container(
//                                 padding: const EdgeInsets.symmetric(
//                                   vertical: 8,
//                                 ),
//                                 alignment: Alignment.center,
//                                 child: const SizedBox(
//                                   height: 18,
//                                   width: 18,
//                                   child: CircularProgressIndicator(
//                                     strokeWidth: 2,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                         ],
//                       ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _chipButton(String text) {
//     return Container(
//       decoration: BoxDecoration(
//         border: Border.all(color: AppColor.lightGray2),
//         borderRadius: BorderRadius.circular(25),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 9),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(text, style: AppTextStyles.mulish(color: AppColor.lightGray2)),
//             const SizedBox(width: 10),
//             Image.asset(AppImages.drapDownImage, height: 19),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
