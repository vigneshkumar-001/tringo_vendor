class  VendorHistoryResponse  {
  final bool status;
  final VendorHistoryListData data;

  VendorHistoryResponse({
    required this.status,
    required this.data,
  });

  factory VendorHistoryResponse.fromJson(Map<String, dynamic> json) {
    return VendorHistoryResponse(
      status: json['status'] ?? false,
      data: VendorHistoryListData.fromJson(json['data'] ?? {}),
    );
  }
}
class VendorHistoryListData {
  final List<ShopItem> items;
  final int page;
  final int limit;
  final int total;
  final AppliedFilters appliedFilters;

  VendorHistoryListData({
    required this.items,
    required this.page,
    required this.limit,
    required this.total,
    required this.appliedFilters,
  });

  factory VendorHistoryListData.fromJson(Map<String, dynamic> json) {
    return VendorHistoryListData(
      items: (json['items'] as List? ?? [])
          .map((e) => ShopItem.fromJson(e))
          .toList(),
      page: json['page'] ?? 0,
      limit: json['limit'] ?? 0,
      total: json['total'] ?? 0,
      appliedFilters:
      AppliedFilters.fromJson(json['appliedFilters'] ?? {}),
    );
  }
}
class ShopItem {
  final int amount;
  final String employeeId;
  final String employeeName;
  final String businessProfileId;
  final String shopId;
  final String shopName;
  final String addressEn;
  final String city;
  final String state;

  final String planCategory;
  final String planLabel;
  final String? planType;
  final String? planStartsAt;
  final String? planEndsAt;
  final int? planDurationDays;
  final int? daysLeft;

  final String time;
  final String? imageUrl;
  final List<ShopMedia> media;

  ShopItem({
    required this.amount,
    required this.employeeId,
    required this.employeeName,
    required this.businessProfileId,
    required this.shopId,
    required this.shopName,
    required this.addressEn,
    required this.city,
    required this.state,
    required this.planCategory,
    required this.planLabel,
    required this.planType,
    required this.planStartsAt,
    required this.planEndsAt,
    required this.planDurationDays,
    required this.daysLeft,
    required this.time,
    required this.imageUrl,
    required this.media,
  });

  factory ShopItem.fromJson(Map<String, dynamic> json) {
    return ShopItem(
      amount: json['amount'] ?? 0,
      employeeId: json['employeeId'] ?? '',
      employeeName: json['employeeName'] ?? '',
      businessProfileId: json['businessProfileId'] ?? '',
      shopId: json['shopId'] ?? '',
      shopName: json['shopName'] ?? '',
      addressEn: json['addressEn'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      planCategory: json['planCategory'] ?? '',
      planLabel: json['planLabel'] ?? '',
      planType: json['planType'],
      planStartsAt: json['planStartsAt'],
      planEndsAt: json['planEndsAt'],
      planDurationDays: json['planDurationDays'],
      daysLeft: json['daysLeft'],
      time: json['time'] ?? '',
      imageUrl: json['imageUrl'],
      media: (json['media'] as List? ?? [])
          .map((e) => ShopMedia.fromJson(e))
          .toList(),
    );
  }
}
class ShopMedia {
  final String id;
  final String url;
  final int displayOrder;

  ShopMedia({
    required this.id,
    required this.url,
    required this.displayOrder,
  });

  factory ShopMedia.fromJson(Map<String, dynamic> json) {
    return ShopMedia(
      id: json['id'] ?? '',
      url: json['url'] ?? '',
      displayOrder: json['displayOrder'] ?? 0,
    );
  }
}
class AppliedFilters {
  final String? q;
  final String? employeeId;
  final List<dynamic> categories;
  final String? range;
  final String? dateFrom;
  final String? dateTo;
  final String sort;

  AppliedFilters({
    required this.q,
    required this.employeeId,
    required this.categories,
    required this.range,
    required this.dateFrom,
    required this.dateTo,
    required this.sort,
  });

  factory AppliedFilters.fromJson(Map<String, dynamic> json) {
    return AppliedFilters(
      q: json['q'],
      employeeId: json['employeeId'],
      categories: json['categories'] ?? [],
      range: json['range'],
      dateFrom: json['dateFrom'],
      dateTo: json['dateTo'],
      sort: json['sort'] ?? '',
    );
  }
}
