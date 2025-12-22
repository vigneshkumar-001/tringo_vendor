class HistoryResponse {
  final bool status;
  final HistoryData? data;

  const HistoryResponse({required this.status, this.data});

  factory HistoryResponse.fromJson(Map<String, dynamic> json) {
    return HistoryResponse(
      status: json['status'] == true,
      data:
          json['data'] is Map<String, dynamic>
              ? HistoryData.fromJson(json['data'] as Map<String, dynamic>)
              : null,
    );
  }

  Map<String, dynamic> toJson() => {'status': status, 'data': data?.toJson()};
}

class HistoryData {
  final List<HistoryItem> items;
  final int page;
  final int limit;
  final int total;
  final AppliedFilters? appliedFilters;

  const HistoryData({
    required this.items,
    required this.page,
    required this.limit,
    required this.total,
    this.appliedFilters,
  });

  factory HistoryData.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    return HistoryData(
      items:
          rawItems is List
              ? rawItems
                  .whereType<Map>()
                  .map(
                    (e) => HistoryItem.fromJson(Map<String, dynamic>.from(e)),
                  )
                  .toList()
              : <HistoryItem>[],
      page: _asInt(json['page']),
      limit: _asInt(json['limit']),
      total: _asInt(json['total']),
      appliedFilters:
          json['appliedFilters'] is Map<String, dynamic>
              ? AppliedFilters.fromJson(
                json['appliedFilters'] as Map<String, dynamic>,
              )
              : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'items': items.map((e) => e.toJson()).toList(),
    'page': page,
    'limit': limit,
    'total': total,
    'appliedFilters': appliedFilters?.toJson(),
  };
}

class HistoryItem {
  final int amount;
  final String employeeId;
  final String employeeName;
  final String shopId;
  final String shopName;
  final String addressEn;
  final String city;
  final String state;
  final String planCategory;
  final String planLabel;
  final String time;
  final String? imageUrl;
  final List<HistoryMedia> media;

  const HistoryItem({
    required this.amount,
    required this.employeeId,
    required this.employeeName,
    required this.shopId,
    required this.shopName,
    required this.addressEn,
    required this.city,
    required this.state,
    required this.planCategory,
    required this.planLabel,
    required this.time,
    this.imageUrl,
    required this.media,
  });

  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    final rawMedia = json['media'];
    return HistoryItem(
      amount: _asInt(json['amount']),
      employeeId: _asString(json['employeeId']),
      employeeName: _asString(json['employeeName']),
      shopId: _asString(json['shopId']),
      shopName: _asString(json['shopName']),
      addressEn: _asString(json['addressEn']),
      city: _asString(json['city']),
      state: _asString(json['state']),
      planCategory: _asString(json['planCategory']),
      planLabel: _asString(json['planLabel']),
      time: _asString(json['time']),
      imageUrl: _asNullableString(json['imageUrl']),
      media:
          rawMedia is List
              ? rawMedia
                  .whereType<Map>()
                  .map(
                    (e) => HistoryMedia.fromJson(Map<String, dynamic>.from(e)),
                  )
                  .toList()
              : <HistoryMedia>[],
    );
  }

  Map<String, dynamic> toJson() => {
    'amount': amount,
    'employeeId': employeeId,
    'employeeName': employeeName,
    'shopId': shopId,
    'shopName': shopName,
    'addressEn': addressEn,
    'city': city,
    'state': state,
    'planCategory': planCategory,
    'planLabel': planLabel,
    'time': time,
    'imageUrl': imageUrl,
    'media': media.map((e) => e.toJson()).toList(),
  };

  /// ✅ helper: use first media url if imageUrl is null
  String? get coverImageUrl =>
      (imageUrl?.isNotEmpty == true)
          ? imageUrl
          : (media.isNotEmpty ? media.first.url : null);
}

class HistoryMedia {
  final String id;
  final String url;
  final int displayOrder;

  const HistoryMedia({
    required this.id,
    required this.url,
    required this.displayOrder,
  });

  factory HistoryMedia.fromJson(Map<String, dynamic> json) {
    return HistoryMedia(
      id: _asString(json['id']),
      url: _asString(json['url']),
      displayOrder: _asInt(json['displayOrder']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'url': url,
    'displayOrder': displayOrder,
  };
}

class AppliedFilters {
  final String? q;
  final String? employeeId;
  final List<String> categories;
  final String? range;
  final String? dateFrom;
  final String? dateTo;
  final String sort;

  const AppliedFilters({
    this.q,
    this.employeeId,
    required this.categories,
    this.range,
    this.dateFrom,
    this.dateTo,
    required this.sort,
  });

  factory AppliedFilters.fromJson(Map<String, dynamic> json) {
    final rawCategories = json['categories'];
    return AppliedFilters(
      q: _asNullableString(json['q']),
      employeeId: _asNullableString(json['employeeId']),
      categories:
          rawCategories is List
              ? rawCategories.map((e) => e.toString()).toList()
              : <String>[],
      range: _asNullableString(json['range']),
      dateFrom: _asNullableString(json['dateFrom']),
      dateTo: _asNullableString(json['dateTo']),
      sort: _asString(json['sort'], fallback: 'recent'),
    );
  }

  Map<String, dynamic> toJson() => {
    'q': q,
    'employeeId': employeeId,
    'categories': categories,
    'range': range,
    'dateFrom': dateFrom,
    'dateTo': dateTo,
    'sort': sort,
  };
}

/// --------------------
/// Safe cast helpers
/// --------------------
int _asInt(dynamic v, {int fallback = 0}) {
  if (v is int) return v;
  if (v is double) return v.toInt();
  if (v is String) return int.tryParse(v) ?? fallback;
  return fallback;
}

String _asString(dynamic v, {String fallback = ''}) {
  if (v == null) return fallback;
  if (v is String) return v;
  return v.toString();
}

String? _asNullableString(dynamic v) {
  if (v == null) return null;
  final s = v.toString();
  return s.isEmpty || s.toLowerCase() == 'null' ? null : s;
}
