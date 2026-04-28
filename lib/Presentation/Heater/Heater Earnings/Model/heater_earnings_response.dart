class HeaterEarningsResponse {
  final bool status;
  final HeaterEarningsData data;

  HeaterEarningsResponse({required this.status, required this.data});

  factory HeaterEarningsResponse.fromJson(Map<String, dynamic> json) {
    return HeaterEarningsResponse(
      status: json['status'] == true,
      data: HeaterEarningsData.fromJson(
        json['data'] is Map ? Map<String, dynamic>.from(json['data'] as Map) : const {},
      ),
    );
  }
}

class HeaterEarningsData {
  final HeaterEarningsSummary summary;
  final HeaterEarningsToolbar toolbar;
  final List<HeaterEarningsGroup> groups;
  final int page;
  final int limit;
  final int total;
  final HeaterEarningsAppliedFilters appliedFilters;

  HeaterEarningsData({
    required this.summary,
    required this.toolbar,
    required this.groups,
    required this.page,
    required this.limit,
    required this.total,
    required this.appliedFilters,
  });

  factory HeaterEarningsData.fromJson(Map<String, dynamic> json) {
    return HeaterEarningsData(
      summary: HeaterEarningsSummary.fromJson(
        json['summary'] is Map
            ? Map<String, dynamic>.from(json['summary'] as Map)
            : const {},
      ),
      toolbar: HeaterEarningsToolbar.fromJson(
        json['toolbar'] is Map
            ? Map<String, dynamic>.from(json['toolbar'] as Map)
            : const {},
      ),
      groups: (json['groups'] as List? ?? const [])
          .where((e) => e is Map)
          .map(
            (e) => HeaterEarningsGroup.fromJson(
              Map<String, dynamic>.from(e as Map),
            ),
          )
          .toList(),
      page: (json['page'] as num?)?.toInt() ?? 1,
      limit: (json['limit'] as num?)?.toInt() ?? 20,
      total: (json['total'] as num?)?.toInt() ?? 0,
      appliedFilters: HeaterEarningsAppliedFilters.fromJson(
        json['appliedFilters'] is Map
            ? Map<String, dynamic>.from(json['appliedFilters'] as Map)
            : const {},
      ),
    );
  }
}

class HeaterEarningsSummary {
  final int totalCreditedAmount;
  final String totalCreditedAmountLabel;
  final int filteredCreditedAmount;
  final String filteredCreditedAmountLabel;
  final int totalTransactions;
  final int filteredTransactions;
  final String currency;

  HeaterEarningsSummary({
    required this.totalCreditedAmount,
    required this.totalCreditedAmountLabel,
    required this.filteredCreditedAmount,
    required this.filteredCreditedAmountLabel,
    required this.totalTransactions,
    required this.filteredTransactions,
    required this.currency,
  });

  factory HeaterEarningsSummary.fromJson(Map<String, dynamic> json) {
    return HeaterEarningsSummary(
      totalCreditedAmount: (json['totalCreditedAmount'] as num?)?.toInt() ?? 0,
      totalCreditedAmountLabel:
          (json['totalCreditedAmountLabel'] ?? '').toString(),
      filteredCreditedAmount:
          (json['filteredCreditedAmount'] as num?)?.toInt() ?? 0,
      filteredCreditedAmountLabel:
          (json['filteredCreditedAmountLabel'] ?? '').toString(),
      totalTransactions: (json['totalTransactions'] as num?)?.toInt() ?? 0,
      filteredTransactions: (json['filteredTransactions'] as num?)?.toInt() ?? 0,
      currency: (json['currency'] ?? '').toString(),
    );
  }
}

class HeaterEarningsToolbar {
  final String searchPlaceholder;
  final List<HeaterEarningsSortOption> sortOptions;

  HeaterEarningsToolbar({
    required this.searchPlaceholder,
    required this.sortOptions,
  });

  factory HeaterEarningsToolbar.fromJson(Map<String, dynamic> json) {
    return HeaterEarningsToolbar(
      searchPlaceholder: (json['searchPlaceholder'] ?? 'Search').toString(),
      sortOptions: (json['sortOptions'] as List? ?? const [])
          .where((e) => e is Map)
          .map(
            (e) => HeaterEarningsSortOption.fromJson(
              Map<String, dynamic>.from(e as Map),
            ),
          )
          .toList(),
    );
  }
}

class HeaterEarningsSortOption {
  final String label;
  final String value;

  const HeaterEarningsSortOption({required this.label, required this.value});

  factory HeaterEarningsSortOption.fromJson(Map<String, dynamic> json) {
    return HeaterEarningsSortOption(
      label: (json['label'] ?? '').toString(),
      value: (json['value'] ?? '').toString(),
    );
  }
}

class HeaterEarningsGroup {
  final String dateKey;
  final String dateLabel;
  final List<HeaterEarningsItem> items;

  HeaterEarningsGroup({
    required this.dateKey,
    required this.dateLabel,
    required this.items,
  });

  factory HeaterEarningsGroup.fromJson(Map<String, dynamic> json) {
    return HeaterEarningsGroup(
      dateKey: (json['dateKey'] ?? '').toString(),
      dateLabel: (json['dateLabel'] ?? '').toString(),
      items: (json['items'] as List? ?? const [])
          .where((e) => e is Map)
          .map(
            (e) => HeaterEarningsItem.fromJson(
              Map<String, dynamic>.from(e as Map),
            ),
          )
          .toList(),
    );
  }
}

class HeaterEarningsItem {
  final String id;
  final int amount;
  final String amountLabel;
  final String title;
  final String description;
  final String paymentMonthLabel;
  final String notes;
  final String paidAt;
  final String dateKey;
  final String dateLabel;
  final String timeLabel;
  final String toBankAccount;
  final String maskedBankAccount;
  final String bankAccountHolderName;
  final String bankName;
  final String bankIfsc;
  final String? proofDocumentUrl;
  final String? receiptUrl;
  final String? referenceNo;

  HeaterEarningsItem({
    required this.id,
    required this.amount,
    required this.amountLabel,
    required this.title,
    required this.description,
    required this.paymentMonthLabel,
    required this.notes,
    required this.paidAt,
    required this.dateKey,
    required this.dateLabel,
    required this.timeLabel,
    required this.toBankAccount,
    required this.maskedBankAccount,
    required this.bankAccountHolderName,
    required this.bankName,
    required this.bankIfsc,
    required this.proofDocumentUrl,
    required this.receiptUrl,
    required this.referenceNo,
  });

  factory HeaterEarningsItem.fromJson(Map<String, dynamic> json) {
    return HeaterEarningsItem(
      id: (json['id'] ?? '').toString(),
      amount: (json['amount'] as num?)?.toInt() ?? 0,
      amountLabel: (json['amountLabel'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      paymentMonthLabel: (json['paymentMonthLabel'] ?? '').toString(),
      notes: (json['notes'] ?? '').toString(),
      paidAt: (json['paidAt'] ?? '').toString(),
      dateKey: (json['dateKey'] ?? '').toString(),
      dateLabel: (json['dateLabel'] ?? '').toString(),
      timeLabel: (json['timeLabel'] ?? '').toString(),
      toBankAccount: (json['toBankAccount'] ?? '').toString(),
      maskedBankAccount: (json['maskedBankAccount'] ?? '').toString(),
      bankAccountHolderName: (json['bankAccountHolderName'] ?? '').toString(),
      bankName: (json['bankName'] ?? '').toString(),
      bankIfsc: (json['bankIfsc'] ?? '').toString(),
      proofDocumentUrl: json['proofDocumentUrl']?.toString(),
      receiptUrl: json['receiptUrl']?.toString(),
      referenceNo: json['referenceNo']?.toString(),
    );
  }
}

class HeaterEarningsAppliedFilters {
  final String? q;
  final String? dateFrom;
  final String? dateTo;
  final String sort;

  HeaterEarningsAppliedFilters({
    required this.q,
    required this.dateFrom,
    required this.dateTo,
    required this.sort,
  });

  factory HeaterEarningsAppliedFilters.fromJson(Map<String, dynamic> json) {
    return HeaterEarningsAppliedFilters(
      q: json['q']?.toString(),
      dateFrom: json['dateFrom']?.toString(),
      dateTo: json['dateTo']?.toString(),
      sort: (json['sort'] ?? 'recent').toString(),
    );
  }
}
