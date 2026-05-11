import 'dart:async';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../Core/Const/app_color.dart';
import '../../../../Core/Const/app_images.dart';
import '../../../../Core/Utility/app_loader.dart';
import '../../../../Core/Utility/app_textstyles.dart';
import '../Controller/heater_earnings_notifier.dart';
import '../Model/heater_earnings_response.dart';

class HeaterEarnings extends ConsumerStatefulWidget {
  const HeaterEarnings({super.key});

  @override
  ConsumerState<HeaterEarnings> createState() => _HeaterEarningsState();
}

class _HeaterEarningsState extends ConsumerState<HeaterEarnings> {
  bool _showSearch = false;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(heaterEarningsNotifierProvider.notifier).fetchInitial();
    });

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(heaterEarningsNotifierProvider.notifier).fetchMore();
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _openUrl(String url) async {
    final u = url.trim();
    if (u.isEmpty) return;

    final uri = Uri.tryParse(u);
    if (uri == null) return;

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _showSortSheet({
    required List<HeaterEarningsSortOption> options,
    required String selectedValue,
  }) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColor.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          top: false,
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            children: [
              Row(
                children: [
                  Text(
                    'Sort By',
                    style: AppTextStyles.mulish(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColor.darkBlue,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.pop(context, 'recent'),
                    child: Text(
                      'Clear',
                      style: AppTextStyles.mulish(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: AppColor.lightRed,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColor.lowLightRed,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      child: Image.asset(AppImages.closeImage, height: 9),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...options.map((o) {
                final bool isSelected = o.value == selectedValue;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    o.label,
                    style: AppTextStyles.mulish(
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: AppColor.darkBlue,
                    ),
                  ),
                  trailing:
                      isSelected
                          ? Icon(Icons.check, color: AppColor.blue)
                          : null,
                  onTap: () => Navigator.pop(context, o.value),
                );
              }),
            ],
          ),
        );
      },
    );

    if (selected == null) return;
    ref
        .read(heaterEarningsNotifierProvider.notifier)
        .updateFilters(sort: selected, fetch: true);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(heaterEarningsNotifierProvider);

    final toolbar = state.toolbar;
    final sortOptions = toolbar?.sortOptions ?? const <HeaterEarningsSortOption>[
      HeaterEarningsSortOption(label: 'Most recent', value: 'recent'),
      HeaterEarningsSortOption(label: 'Oldest', value: 'oldest'),
      HeaterEarningsSortOption(label: 'Amount low to high', value: 'amountAsc'),
      HeaterEarningsSortOption(label: 'Amount high to low', value: 'amountDesc'),
    ];

    final sortLabel =
        sortOptions
            .firstWhere(
              (o) => o.value == state.appliedSort,
              orElse: () => const HeaterEarningsSortOption(
                label: 'Most recent',
                value: 'recent',
              ),
            )
            .label;

    final entries = _flatten(state.groups);
    final hasList = entries.isNotEmpty;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Text(
                'Earnings',
                style: AppTextStyles.mulish(
                  fontWeight: FontWeight.w700,
                  fontSize: 24,
                  color: AppColor.darkBlue,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _summaryCard(state.summary),
            ),
            const SizedBox(height: 12),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => setState(() => _showSearch = true),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child:
                          _showSearch
                              ? _searchField(
                                hint: toolbar?.searchPlaceholder ?? 'Search',
                              )
                              : _chip(
                                icon: AppImages.searchImage,
                                label: 'Search',
                              ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap:
                        () => _showSortSheet(
                          options: sortOptions,
                          selectedValue: state.appliedSort,
                        ),
                    child: _chip(
                      icon: AppImages.drapDownImage,
                      label: 'Sort: $sortLabel',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            Expanded(
              child: RefreshIndicator(
                onRefresh:
                    () =>
                        ref
                            .read(heaterEarningsNotifierProvider.notifier)
                            .fetchInitial(),
                child: ListView.builder(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  itemCount:
                      hasList
                          ? entries.length + 1
                          : 1, // single placeholder cell
                  itemBuilder: (context, index) {
                    if (!hasList) {
                      if (state.isLoading) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 80),
                          child: Center(
                            child: ThreeDotsLoader(dotColor: AppColor.darkBlue),
                          ),
                        );
                      }

                      if (state.error != null) {
                        return _statusState(
                          title: 'Unable to load earnings',
                          subtitle: _friendlyError(state.error!),
                          image: AppImages.cloudImage,
                        );
                      }

                      return _statusState(
                        title: 'No earnings yet',
                        subtitle: 'Credited transactions will appear here.',
                        image: AppImages.noDataGif,
                      );
                    }

                    if (index == entries.length) {
                      if (state.isFetchingMore) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: ThreeDotsLoader(dotColor: AppColor.darkBlue),
                          ),
                        );
                      }
                      return const SizedBox(height: 6);
                    }

                    final entry = entries[index];
                    if (entry.isHeader) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Center(
                          child: Text(
                            entry.header!,
                            style: AppTextStyles.mulish(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColor.lightGray2,
                            ),
                          ),
                        ),
                      );
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _earningCard(entry.item!, onReceiptTap: () {
                        final url =
                            (entry.item!.receiptUrl ??
                                    entry.item!.proofDocumentUrl ??
                                    '')
                                .trim();
                        if (url.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Receipt not available'),
                            ),
                          );
                          return;
                        }
                        _openUrl(url);
                      }),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryCard(HeaterEarningsSummary? summary) {
    final amount = summary?.filteredCreditedAmountLabel ?? '₹0';
    final tx = summary?.filteredTransactions ?? 0;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColor.iceGray,
        borderRadius: BorderRadius.circular(15),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        children: [
          Text(
            amount,
            style: AppTextStyles.mulish(
              fontWeight: FontWeight.w800,
              fontSize: 42,
              color: AppColor.blueGradient1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Credited Amount',
            style: AppTextStyles.mulish(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: AppColor.lightGray3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$tx Transactions',
            style: AppTextStyles.mulish(
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: AppColor.gray84,
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchField({required String hint}) {
    return Container(
      key: const ValueKey('search'),
      width: 260,
      decoration: BoxDecoration(
        color: AppColor.iceGray,
        borderRadius: BorderRadius.circular(50),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Row(
        children: [
          Image.asset(AppImages.searchImage, height: 18),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: hint,
                hintStyle: AppTextStyles.mulish(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColor.lightGray2,
                ),
              ),
              style: AppTextStyles.mulish(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColor.darkBlue,
              ),
              onChanged: (value) {
                _debounce?.cancel();
                _debounce = Timer(const Duration(milliseconds: 400), () {
                  ref
                      .read(heaterEarningsNotifierProvider.notifier)
                      .updateFilters(q: value.trim(), fetch: true);
                });
              },
            ),
          ),
          if (_searchController.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchController.clear();
                setState(() => _showSearch = false);
                ref
                    .read(heaterEarningsNotifierProvider.notifier)
                    .updateFilters(q: "", fetch: true);
              },
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Icon(Icons.close, size: 18, color: AppColor.darkGrey),
              ),
            )
          else
            GestureDetector(
              onTap: () => setState(() => _showSearch = false),
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Icon(Icons.close, size: 18, color: AppColor.darkGrey),
              ),
            ),
        ],
      ),
    );
  }

  Widget _chip({required String icon, required String label}) {
    return Container(
      key: ValueKey(label),
      decoration: BoxDecoration(
        color: AppColor.iceGray,
        borderRadius: BorderRadius.circular(50),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(icon, height: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: AppTextStyles.mulish(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColor.darkBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _earningCard(HeaterEarningsItem item, {required VoidCallback onReceiptTap}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.iceGray,
        borderRadius: BorderRadius.circular(15),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title.isNotEmpty ? item.title : '${item.amountLabel} Credited',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.mulish(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColor.darkBlue,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.description.isNotEmpty ? item.description : item.paymentMonthLabel,
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
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    item.toBankAccount.isNotEmpty ? item.toBankAccount : 'to Bank A/c No',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.mulish(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColor.lightGray2,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.maskedBankAccount.isNotEmpty ? item.maskedBankAccount : '****',
                    style: AppTextStyles.mulish(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColor.gray84,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          InkWell(
            onTap: onReceiptTap,
            borderRadius: BorderRadius.circular(18),
            child: DottedBorder(
              color: AppColor.black.withOpacity(0.2),
              dashPattern: const [3, 2],
              borderType: BorderType.RRect,
              radius: const Radius.circular(18),
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Image.asset(AppImages.downloadImage, height: 18, width: 17),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Download Receipt',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.mulish(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: AppColor.darkBlue,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    item.timeLabel,
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
    );
  }

  String _friendlyError(String message) {
    final m = message.trim();
    final lower = m.toLowerCase();
    if (lower.startsWith('cannot get') || lower.contains('cannot get /api/')) {
      return 'Earnings are temporarily unavailable. Please try again later.';
    }
    if (lower.contains('not found') || lower.contains('404')) {
      return 'Earnings are temporarily unavailable. Please try again later.';
    }
    if (lower.contains('method not allowed') || lower.contains('405')) {
      return 'Earnings are temporarily unavailable. Please try again later.';
    }
    return 'Something went wrong. Please try again later.';
  }

  Widget _statusState({
    required String title,
    required String subtitle,
    required String image,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 16),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(image, height: 140),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.mulish(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: AppColor.darkBlue,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.mulish(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: AppColor.gray84,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EarningsEntry {
  final String? header;
  final HeaterEarningsItem? item;

  const _EarningsEntry.header(this.header) : item = null;
  const _EarningsEntry.item(this.item) : header = null;

  bool get isHeader => header != null;
}

List<_EarningsEntry> _flatten(List<HeaterEarningsGroup> groups) {
  final out = <_EarningsEntry>[];
  for (final g in groups) {
    if (g.dateLabel.trim().isNotEmpty) {
      out.add(_EarningsEntry.header(g.dateLabel));
    }
    for (final it in g.items) {
      out.add(_EarningsEntry.item(it));
    }
  }
  return out;
}
