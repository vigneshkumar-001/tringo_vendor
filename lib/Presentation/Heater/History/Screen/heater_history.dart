import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:dotted_border/dotted_border.dart' as dotted;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:tringo_vendor_new/Core/Const/app_color.dart';
import 'package:tringo_vendor_new/Core/Utility/app_textstyles.dart';
import 'package:tringo_vendor_new/Core/Widgets/common_container.dart';
import 'package:tringo_vendor_new/Presentation/Heater/History/Controller/vendor_notifier.dart';

import '../../../../Core/Const/app_images.dart';
import '../../../../Core/Utility/filter_popup_screen.dart';
import '../../../../Core/Utility/sortby_popup_screen.dart';

class HeaterHistory extends ConsumerStatefulWidget {
  const HeaterHistory({super.key});

  @override
  ConsumerState<HeaterHistory> createState() => _HeaterHistoryState();
}

class _HeaterHistoryState extends ConsumerState<HeaterHistory> {
  bool _showSearch = false;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  Timer? _debounce;

  Set<String> _selectedCategories = {};
  DateTimeRange? _selectedRange;

  final DateFormat _labelDf = DateFormat('dd MMM yyyy');

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(vendorNotifierProvider.notifier).fetchInitial();
    });

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(vendorNotifierProvider.notifier).fetchMore();
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _mapPlanToCategories(String plan) {
    switch (plan) {
      case "premium":
        return "PREMIUM";
      case "premiumPro":
        return "PREMIUM_PRO";
      case "freemium":
        return "FREEMIUM";
      default:
        return "";
    }
  }

  DateTime _onlyDate(DateTime d) => DateTime(d.year, d.month, d.day);

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

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

  bool _hasAnyFilterApplied() {
    final hasSearch = _searchController.text.trim().isNotEmpty;
    final hasDate = _selectedRange != null;
    final hasCategory = _selectedCategories.isNotEmpty;
    return hasSearch || hasDate || hasCategory;
  }

  void _clearAllFiltersAndReload() {
    setState(() {
      _selectedCategories = {};
      _selectedRange = null;
      _searchController.clear();
      _showSearch = false;
    });

    ref
        .read(vendorNotifierProvider.notifier)
        .updateFilters(
          q: "",
          categories: "",
          dateFrom: "",
          dateTo: "",
          fetch: true,
        );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(vendorNotifierProvider);
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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

            // ✅ Search + Filter + Sort (ALWAYS visible)
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
                                        onChanged: (value) {
                                          _debounce?.cancel();
                                          _debounce = Timer(
                                            const Duration(milliseconds: 500),
                                            () {
                                              ref
                                                  .read(
                                                    vendorNotifierProvider
                                                        .notifier,
                                                  )
                                                  .updateFilters(
                                                    q: value.trim(),
                                                    fetch: true,
                                                  );
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          _searchController.clear();
                                          _showSearch = false;
                                        });
                                        ref
                                            .read(
                                              vendorNotifierProvider.notifier,
                                            )
                                            .updateFilters(q: "", fetch: true);
                                      },
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

                  //  Filter
                  GestureDetector(
                    onTap: () async {
                      final result = await showModalBottomSheet(
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        context: context,
                        showDragHandle: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                        builder:
                            (_) => FilterPopupScreen(
                              initialSelectedCategories: _selectedCategories,
                              initialDateRange: _selectedRange,
                            ),
                      );

                      if (result == null) return;

                      if (result is Map && result["reset"] == true) {
                        _clearAllFiltersAndReload();
                        return;
                      }

                      if (result is Map<String, dynamic>) {
                        final dynamic planRaw = result["filters"]?["plan"];
                        final String? plan =
                            (planRaw == null ||
                                    planRaw.toString().trim().isEmpty)
                                ? null
                                : planRaw.toString();

                        final String categories =
                            plan == null ? "" : _mapPlanToCategories(plan);

                        final String? dateFrom = result["dateFrom"];
                        final String? dateTo = result["dateTo"];

                        setState(() {
                          _selectedCategories =
                              categories.isEmpty ? {} : {categories};

                          if (dateFrom != null &&
                              dateTo != null &&
                              dateFrom.isNotEmpty &&
                              dateTo.isNotEmpty) {
                            _selectedRange = DateTimeRange(
                              start: DateTime.parse(dateFrom),
                              end: DateTime.parse(dateTo),
                            );
                          } else {
                            _selectedRange = null;
                          }
                        });

                        ref
                            .read(vendorNotifierProvider.notifier)
                            .updateFilters(
                              categories: categories,
                              dateFrom: dateFrom ?? "",
                              dateTo: dateTo ?? "",
                              fetch: true,
                            );
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColor.lightGray2),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 17,
                        vertical: 9,
                      ),
                      child: Row(
                        children: [
                          Text(
                            'Filter',
                            style: AppTextStyles.mulish(
                              color: AppColor.lightGray2,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Image.asset(AppImages.drapDownImage, height: 19),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // Sort
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
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
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColor.lightGray2),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 17,
                        vertical: 9,
                      ),
                      child: Row(
                        children: [
                          Text(
                            'Sort By',
                            style: AppTextStyles.mulish(
                              color: AppColor.lightGray2,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Image.asset(AppImages.drapDownImage, height: 19),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            Center(
              child: Text(
                _selectedDateLabel(),
                style: AppTextStyles.mulish(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColor.lightGray2,
                ),
              ),
            ),

            const SizedBox(height: 16),

            if (_hasAnyFilterApplied())
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "Filters applied",
                  style: AppTextStyles.mulish(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColor.lightGray2,
                  ),
                ),
              ),

            const SizedBox(height: 10),

            // ✅ MAIN CONTENT AREA
            Expanded(
              child: Builder(
                builder: (_) {
                  // ✅ A) LOADING => show skeleton list cards
                  if (state.isLoading) {
                    return ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: 6,
                      itemBuilder:
                          (_, __) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Skeletonizer(
                              enabled: true,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColor.ivoryGreen,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          '₹30 Commission',
                                          style: AppTextStyles.mulish(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                            color: AppColor.darkBlue,
                                          ),
                                        ),
                                        const Spacer(),
                                        Text(
                                          'Sivan',
                                          style: AppTextStyles.mulish(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500,
                                            color: AppColor.darkBlue,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 15),
                                    CommonContainer.horizonalDivider(),
                                    const SizedBox(height: 15),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Kandhasamy Mobiles',
                                                style: AppTextStyles.mulish(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                  color: AppColor.darkBlue,
                                                ),
                                              ),
                                              const SizedBox(height: 5),
                                              Text(
                                                '77, Nehru St, Madurai, Tamil Nadu 625016',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: AppTextStyles.mulish(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                  color: AppColor.gray84,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 40),
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          child: SizedBox(
                                            height: 60,
                                            width: 60,
                                            child: Image.asset(
                                              AppImages.homeImage1,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 15),
                                    Row(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            color: AppColor.white,
                                            borderRadius: BorderRadius.circular(
                                              50,
                                            ),
                                          ),
                                          padding: const EdgeInsets.all(10),
                                          child: Image.asset(
                                            AppImages.premiumImage,
                                            height: 16,
                                            width: 17,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: DottedBorder(
                                            color: AppColor.black.withOpacity(
                                              0.2,
                                            ),
                                            dashPattern: const [3.0, 2.0],
                                            borderType: dotted.BorderType.RRect,
                                            padding: const EdgeInsets.all(10),
                                            radius: const Radius.circular(18),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    '2 Months Pro Premium',
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: AppTextStyles.mulish(
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      fontSize: 12,
                                                      color: AppColor.darkBlue,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                Text(
                                                  '10.40Pm',
                                                  style: AppTextStyles.mulish(
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 12,
                                                    color: AppColor.lightGray3,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                    );
                  }

                  // ✅ B) ERROR => show "No data found" screen (your request)
                  if (state.error != null && state.error!.trim().isNotEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.wifi_off_rounded, size: 52),
                            const SizedBox(height: 12),
                            Text(
                              "No data found",
                              style: AppTextStyles.mulish(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColor.darkBlue,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Something went wrong. Please try again.",
                              textAlign: TextAlign.center,
                              style: AppTextStyles.mulish(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColor.lightGray2,
                              ),
                            ),
                            const SizedBox(height: 18),
                            InkWell(
                              onTap:
                                  () =>
                                      ref
                                          .read(vendorNotifierProvider.notifier)
                                          .fetchInitial(),
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
                                  "Retry",
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
                    );
                  }

                  // ✅ C) EMPTY (NO ITEMS) => show empty UI
                  if (state.items.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.inbox_outlined, size: 52),
                            const SizedBox(height: 12),
                            Text(
                              "No history found",
                              style: AppTextStyles.mulish(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColor.darkBlue,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Try changing the date range, category, or search keyword.",
                              textAlign: TextAlign.center,
                              style: AppTextStyles.mulish(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColor.lightGray2,
                              ),
                            ),
                            const SizedBox(height: 18),
                            InkWell(
                              onTap: _clearAllFiltersAndReload,
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
                    );
                  }

                  // ✅ D) DATA => your existing list
                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount:
                        state.items.length + (state.isFetchingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == state.items.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final item = state.items[index];

                      // ✅ Your existing card UI (keep same)
                      return Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: AppColor.ivoryGreen,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        '₹${item.amount} Commission',
                                        style: AppTextStyles.mulish(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: AppColor.darkBlue,
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        item.employeeName,
                                        style: AppTextStyles.mulish(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                          color: AppColor.darkBlue,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 15),
                                  CommonContainer.horizonalDivider(),
                                  const SizedBox(height: 15),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.shopName,
                                              style: AppTextStyles.mulish(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                                color: AppColor.darkBlue,
                                              ),
                                            ),
                                            const SizedBox(height: 5),
                                            Text(
                                              '${item.addressEn},${item.city},${item.state}',
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                              style: AppTextStyles.mulish(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: AppColor.gray84,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 40),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: SizedBox(
                                          height: 60,
                                          width: 60,
                                          child: CachedNetworkImage(
                                            imageUrl: (item.imageUrl ?? ""),
                                            fit: BoxFit.cover,
                                            placeholder:
                                                (context, url) => Container(
                                                  color: Colors.grey.shade200,
                                                  child: const Center(
                                                    child:
                                                        CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                        ),
                                                  ),
                                                ),
                                            errorWidget:
                                                (context, url, error) =>
                                                    const Icon(
                                                      Icons.broken_image,
                                                      size: 30,
                                                    ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 15),
                                  Row(
                                    children: [
                                      item.planCategory == 'FREEMIUM'
                                          ? const SizedBox.shrink()
                                          : Container(
                                            decoration: BoxDecoration(
                                              color: AppColor.white,
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                            ),
                                            padding: const EdgeInsets.all(10),
                                            child: Image.asset(
                                              AppImages.premiumImage,
                                              height: 16,
                                              width: 17,
                                            ),
                                          ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: DottedBorder(
                                          color: AppColor.black.withOpacity(
                                            0.2,
                                          ),
                                          dashPattern: const [3.0, 2.0],
                                          borderType: dotted.BorderType.RRect,
                                          padding: const EdgeInsets.all(10),
                                          radius: const Radius.circular(18),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  item.planCategory ==
                                                          'FREEMIUM'
                                                      ? 'FREEMIUM'
                                                      : (item.planDurationDays
                                                              ?.toString() ??
                                                          ''),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: AppTextStyles.mulish(
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 12,
                                                    color: AppColor.darkBlue,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Text(
                                                item.time,
                                                style: AppTextStyles.mulish(
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 12,
                                                  color: AppColor.lightGray3,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:dotted_border/dotted_border.dart';
// import 'package:dotted_border/dotted_border.dart' as dotted;
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:skeletonizer/skeletonizer.dart';
// import 'package:tringo_vendor_new/Core/Const/app_color.dart';
// import 'package:tringo_vendor_new/Core/Utility/app_textstyles.dart';
// import 'package:tringo_vendor_new/Core/Widgets/common_container.dart';
// import 'package:tringo_vendor_new/Presentation/Heater/History/Controller/vendor_notifier.dart';
//
// import '../../../../Core/Const/app_images.dart';
// import '../../../../Core/Utility/filter_popup_screen.dart';
// import '../../../../Core/Utility/sortby_popup_screen.dart';
//
// class HeaterHistory extends ConsumerStatefulWidget {
//   const HeaterHistory({super.key});
//
//   @override
//   ConsumerState<HeaterHistory> createState() => _HeaterHistoryState();
// }
//
// class _HeaterHistoryState extends ConsumerState<HeaterHistory> {
//   bool _showSearch = false;
//   final TextEditingController _searchController = TextEditingController();
//   final ScrollController _scrollController = ScrollController();
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       ref.read(vendorNotifierProvider.notifier).fetchInitial();
//     });
//
//     _scrollController.addListener(_onScroll);
//   }
//
//   void _onScroll() {
//     if (_scrollController.position.pixels >=
//         _scrollController.position.maxScrollExtent - 200) {
//       ref.read(vendorNotifierProvider.notifier).fetchMore();
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final state = ref.watch(vendorNotifierProvider);
//
//     return Skeletonizer(
//       enabled: state.isLoading,
//       child: Scaffold(
//         body: SafeArea(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Padding(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 10,
//                 ),
//                 child: Text(
//                   'History',
//                   style: AppTextStyles.mulish(
//                     fontWeight: FontWeight.w700,
//                     fontSize: 24,
//                     color: AppColor.darkBlue,
//                   ),
//                 ),
//               ),
//               SizedBox(height: 10),
//
//               SingleChildScrollView(
//                 scrollDirection: Axis.horizontal,
//                 physics: BouncingScrollPhysics(),
//                 padding: EdgeInsets.symmetric(horizontal: 16),
//                 child: Row(
//                   children: [
//                     GestureDetector(
//                       onTap: () {
//                         setState(() {
//                           _showSearch = true;
//                         });
//                       },
//                       child: AnimatedSwitcher(
//                         duration: const Duration(milliseconds: 300),
//                         child:
//                             _showSearch
//                                 ? Container(
//                                   key: const ValueKey('searchField'),
//                                   width: 260,
//                                   padding: const EdgeInsets.symmetric(
//                                     horizontal: 12,
//                                   ),
//                                   decoration: BoxDecoration(
//                                     border: Border.all(
//                                       color: AppColor.darkBlue,
//                                     ),
//                                     borderRadius: BorderRadius.circular(25),
//                                     color: AppColor.white,
//                                   ),
//                                   child: Row(
//                                     children: [
//                                       Image.asset(
//                                         AppImages.searchImage,
//                                         height: 14,
//                                       ),
//                                       const SizedBox(width: 8),
//                                       Expanded(
//                                         child: TextField(
//                                           controller: _searchController,
//                                           autofocus: true,
//                                           decoration: const InputDecoration(
//                                             hintText: 'Search...',
//                                             border: InputBorder.none,
//                                           ),
//                                           onChanged: (value) {
//                                             // 🔍 filter logic here
//                                           },
//                                         ),
//                                       ),
//                                       InkWell(
//                                         onTap: () {
//                                           setState(() {
//                                             _searchController.clear();
//                                             _showSearch = false;
//                                           });
//                                         },
//                                         child: const Icon(
//                                           Icons.close,
//                                           size: 18,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 )
//                                 : Container(
//                                   key: const ValueKey('searchButton'),
//                                   decoration: BoxDecoration(
//                                     border: Border.all(
//                                       color: AppColor.darkBlue,
//                                     ),
//                                     borderRadius: BorderRadius.circular(25),
//                                   ),
//                                   padding: const EdgeInsets.symmetric(
//                                     horizontal: 47,
//                                     vertical: 8,
//                                   ),
//                                   child: Row(
//                                     children: [
//                                       Image.asset(
//                                         AppImages.searchImage,
//                                         height: 14,
//                                       ),
//                                       const SizedBox(width: 10),
//                                       Text(
//                                         'Search',
//                                         style: AppTextStyles.mulish(
//                                           color: AppColor.darkBlue,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                       ),
//                     ),
//
//                     SizedBox(width: 10),
//                     GestureDetector(
//                       onTap: () {
//                         showModalBottomSheet(
//                           isScrollControlled:
//                               true, // needed for tall sheet + keyboard
//                           backgroundColor: Colors.transparent,
//                           context: context,
//                           showDragHandle: true,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.vertical(
//                               top: Radius.circular(20),
//                             ),
//                           ),
//                           builder: (_) => FilterPopupScreen(),
//                         );
//                       },
//                       child: Container(
//                         decoration: BoxDecoration(
//                           border: Border.all(color: AppColor.lightGray2),
//                           borderRadius: BorderRadius.circular(25),
//                         ),
//                         child: Padding(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 17,
//                             vertical: 9,
//                           ),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Text(
//                                 'Filter',
//                                 style: AppTextStyles.mulish(
//                                   color: AppColor.lightGray2,
//                                 ),
//                               ),
//                               SizedBox(width: 10),
//                               Image.asset(AppImages.drapDownImage, height: 19),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                     SizedBox(width: 10),
//                     GestureDetector(
//                       onTap: () {
//                         showModalBottomSheet(
//                           backgroundColor: Colors.transparent,
//                           context: context,
//                           isScrollControlled: true,
//                           showDragHandle: true,
//                           shape: const RoundedRectangleBorder(
//                             borderRadius: BorderRadius.vertical(
//                               top: Radius.circular(20),
//                             ),
//                           ),
//                           builder: (_) => SortbyPopupScreen(),
//                         );
//                       },
//                       child: Container(
//                         decoration: BoxDecoration(
//                           border: Border.all(color: AppColor.lightGray2),
//                           borderRadius: BorderRadius.circular(25),
//                         ),
//                         child: Padding(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 17,
//                             vertical: 9,
//                           ),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Text(
//                                 'Sort By',
//                                 style: AppTextStyles.mulish(
//                                   color: AppColor.lightGray2,
//                                 ),
//                               ),
//                               SizedBox(width: 10),
//                               Image.asset(AppImages.drapDownImage, height: 19),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               SizedBox(height: 20),
//               Center(
//                 child: Text(
//                   'Today',
//                   style: AppTextStyles.mulish(
//                     fontSize: 12,
//                     fontWeight: FontWeight.w600,
//                     color: AppColor.lightGray2,
//                   ),
//                 ),
//               ),
//               SizedBox(height: 20),
//               Expanded(
//                 child: ListView.builder(
//                   physics: BouncingScrollPhysics(),
//                   controller: _scrollController,
//                   padding: const EdgeInsets.symmetric(horizontal: 16),
//                   itemCount:
//                       state.items.length + (state.isFetchingMore ? 1 : 0),
//                   itemBuilder: (context, index) {
//                     if (index == state.items.length) {
//                       return const Padding(
//                         padding: EdgeInsets.symmetric(vertical: 10),
//                         child: Center(child: CircularProgressIndicator()),
//                       );
//                     }
//
//                     final item = state.items[index];
//                     return Column(
//                       children: [
//                         Container(
//                           decoration: BoxDecoration(
//                             color: AppColor.ivoryGreen,
//                             borderRadius: BorderRadius.circular(15),
//                           ),
//                           child: Padding(
//                             padding: const EdgeInsets.all(20),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Row(
//                                   children: [
//                                     Text(
//                                       '₹${item.amount} Commission',
//                                       style: AppTextStyles.mulish(
//                                         fontSize: 18,
//                                         fontWeight: FontWeight.w700,
//                                         color: AppColor.darkBlue,
//                                       ),
//                                     ),
//                                     Spacer(),
//                                     Text(
//                                       item.employeeName,
//                                       style: AppTextStyles.mulish(
//                                         fontSize: 18,
//                                         fontWeight: FontWeight.w500,
//                                         color: AppColor.darkBlue,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 SizedBox(height: 15),
//                                 CommonContainer.horizonalDivider(),
//                                 SizedBox(height: 15),
//                                 Row(
//                                   children: [
//                                     Expanded(
//                                       child: Column(
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.start,
//                                         children: [
//                                           Text(
//                                             item.shopName,
//                                             style: AppTextStyles.mulish(
//                                               fontSize: 16,
//                                               fontWeight: FontWeight.w500,
//                                               color: AppColor.darkBlue,
//                                             ),
//                                           ),
//                                           SizedBox(height: 5),
//                                           Text(
//                                             overflow: TextOverflow.ellipsis,
//                                             maxLines: 1,
//                                             '${item.addressEn},${item.city},${item.state}',
//                                             style: AppTextStyles.mulish(
//                                               fontSize: 12,
//                                               fontWeight: FontWeight.w500,
//                                               color: AppColor.gray84,
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                     SizedBox(width: 40),
//                                     ClipRRect(
//                                       borderRadius: BorderRadius.circular(10),
//                                       child: SizedBox(
//                                         height: 60,
//                                         width: 60,
//                                         child: CachedNetworkImage(
//                                           imageUrl:
//                                               item.imageUrl.toString() ??
//                                               '', // your API image
//                                           fit: BoxFit.cover,
//                                           placeholder:
//                                               (context, url) => Container(
//                                                 color: Colors.grey.shade200,
//                                                 child: const Center(
//                                                   child:
//                                                       CircularProgressIndicator(
//                                                         strokeWidth: 2,
//                                                       ),
//                                                 ),
//                                               ),
//                                           errorWidget:
//                                               (context, url, error) =>
//                                                   const Icon(
//                                                     Icons.broken_image,
//                                                     size: 30,
//                                                   ),
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 SizedBox(height: 15),
//                                 Row(
//                                   children: [
//                                     item.planCategory == 'FREEMIUM'
//                                         ? SizedBox.shrink()
//                                         : Container(
//                                           decoration: BoxDecoration(
//                                             color: AppColor.white,
//                                             borderRadius: BorderRadius.circular(
//                                               50,
//                                             ),
//                                           ),
//                                           child: Padding(
//                                             padding: const EdgeInsets.all(10),
//                                             child: Image.asset(
//                                               AppImages.premiumImage,
//                                               height: 16,
//                                               width: 17,
//                                             ),
//                                           ),
//                                         ),
//                                     SizedBox(width: 8),
//                                     Expanded(
//                                       child: DottedBorder(
//                                         color: AppColor.black.withOpacity(0.2),
//                                         dashPattern: [3.0, 2.0],
//                                         borderType: dotted.BorderType.RRect,
//                                         padding: EdgeInsets.all(10),
//                                         radius: Radius.circular(18),
//                                         child: Padding(
//                                           padding: const EdgeInsets.symmetric(
//                                             horizontal: 5,
//                                           ),
//                                           child: Row(
//                                             mainAxisAlignment:
//                                                 MainAxisAlignment.spaceBetween,
//                                             children: [
//                                               Expanded(
//                                                 child: Text(
//                                                   item.planCategory ==
//                                                           'FREEMIUM'
//                                                       ? 'FREEMIUM'
//                                                       : item.planDurationDays
//                                                               .toString() ??
//                                                           '',
//                                                   maxLines: 1,
//                                                   overflow:
//                                                       TextOverflow.ellipsis,
//                                                   style: AppTextStyles.mulish(
//                                                     fontWeight: FontWeight.w700,
//                                                     fontSize: 12,
//                                                     color: AppColor.darkBlue,
//                                                   ),
//                                                 ),
//                                               ),
//                                               SizedBox(width: 10),
//                                               Text(
//                                                 item.time,
//                                                 style: AppTextStyles.mulish(
//                                                   fontWeight: FontWeight.w400,
//                                                   fontSize: 12,
//                                                   color: AppColor.lightGray3,
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ],
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
