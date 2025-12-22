class EmployeeHomeResponse {
  final bool status;
  final EmployeeData data;

  EmployeeHomeResponse({required this.status, required this.data});

  factory EmployeeHomeResponse.fromJson(Map<String, dynamic> json) {
    return EmployeeHomeResponse(
      status: json['status'] == true,
      data: EmployeeData.fromJson((json['data'] as Map?)?.cast<String, dynamic>() ?? {}),
    );
  }
}

class EmployeeData {
  final Employee employee;
  final Metrics metrics;
  final Pagination pagination;
  final AppliedFilters appliedFilters;
  final RecentActivity recentActivity;

  EmployeeData({
    required this.employee,
    required this.metrics,
    required this.pagination,
    required this.appliedFilters,
    required this.recentActivity,
  });

  factory EmployeeData.fromJson(Map<String, dynamic> json) {
    return EmployeeData(
      employee: Employee.fromJson((json['employee'] as Map?)?.cast<String, dynamic>() ?? {}),
      metrics: Metrics.fromJson((json['metrics'] as Map?)?.cast<String, dynamic>() ?? {}),
      pagination: Pagination.fromJson((json['pagination'] as Map?)?.cast<String, dynamic>() ?? {}),
      appliedFilters: AppliedFilters.fromJson((json['appliedFilters'] as Map?)?.cast<String, dynamic>() ?? {}),
      recentActivity: RecentActivity.fromJson((json['recentActivity'] as Map?)?.cast<String, dynamic>() ?? {}),
    );
  }
}

class Employee {
  final String id;
  final String name;
  final String employeeCode;
  final String vendorName;
  final String? avatarUrl;

  Employee({
    required this.id,
    required this.name,
    required this.employeeCode,
    required this.vendorName,
    this.avatarUrl,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      employeeCode: (json['employeeCode'] ?? '').toString(),
      vendorName: (json['vendorName'] ?? '').toString(),
      avatarUrl: json['avatarUrl']?.toString(),
    );
  }
}

class Metrics {
  final int totalEntry;
  final int totalCollectionAmount;
  final int freemiumCount;
  final int premiumCount;
  final int premiumProCount;

  Metrics({
    required this.totalEntry,
    required this.totalCollectionAmount,
    required this.freemiumCount,
    required this.premiumCount,
    required this.premiumProCount,
  });

  factory Metrics.fromJson(Map<String, dynamic> json) {
    int _toInt(dynamic v) => (v is num) ? v.toInt() : int.tryParse('$v') ?? 0;

    return Metrics(
      totalEntry: _toInt(json['totalEntry']),
      totalCollectionAmount: _toInt(json['totalCollectionAmount']),
      freemiumCount: _toInt(json['freemiumCount']),
      premiumCount: _toInt(json['premiumCount']),
      premiumProCount: _toInt(json['premiumProCount']),
    );
  }
}

class Pagination {
  final int page;
  final int limit;
  final int total;
  final bool hasMore;

  Pagination({
    required this.page,
    required this.limit,
    required this.total,
    required this.hasMore,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    int _toInt(dynamic v) => (v is num) ? v.toInt() : int.tryParse('$v') ?? 0;
    bool _toBool(dynamic v) {
      if (v is bool) return v;
      final s = v?.toString().toLowerCase();
      return s == 'true' || s == '1';
    }

    return Pagination(
      page: _toInt(json['page']),
      limit: _toInt(json['limit']),
      total: _toInt(json['total']),
      hasMore: _toBool(json['hasMore']),
    );
  }
}

class AppliedFilters {
  final String? q;
  final String planCategory;
  final String kind;
  final String? category;
  final String? subCategory;
  final String sort;
  final String? dateFrom;
  final String? dateTo;
  final String range;

  AppliedFilters({
    required this.q,
    required this.planCategory,
    required this.kind,
    required this.category,
    required this.subCategory,
    required this.sort,
    required this.dateFrom,
    required this.dateTo,
    required this.range,
  });

  factory AppliedFilters.fromJson(Map<String, dynamic> json) {
    return AppliedFilters(
      q: json['q']?.toString(),
      planCategory: (json['planCategory'] ?? 'all').toString(),
      kind: (json['kind'] ?? 'all').toString(),
      category: json['category']?.toString(),
      subCategory: json['subCategory']?.toString(),
      sort: (json['sort'] ?? 'recent').toString(),
      dateFrom: json['dateFrom']?.toString(),
      dateTo: json['dateTo']?.toString(),
      range: (json['range'] ?? 'all').toString(),
    );
  }
}

class RecentActivity {
  final List<ActivityDayGroup> freemium;
  final List<ActivityDayGroup> premium;
  final List<ActivityDayGroup> premiumPro;

  RecentActivity({
    required this.freemium,
    required this.premium,
    required this.premiumPro,
  });

  factory RecentActivity.fromJson(Map<String, dynamic> json) {
    List<ActivityDayGroup> _parse(dynamic v) {
      final list = (v as List?) ?? [];
      return list
          .whereType<Map>()
          .map((e) => ActivityDayGroup.fromJson(e.cast<String, dynamic>()))
          .toList();
    }

    return RecentActivity(
      freemium: _parse(json['FREEMIUM']),
      premium: _parse(json['PREMIUM']),
      premiumPro: _parse(json['PREMIUM_PRO']),
    );
  }
}

class ActivityDayGroup {
  final String dateKey;   // "2025-12-19"
  final String dateLabel; // "Today"
  final List<BusinessProfile> items;

  ActivityDayGroup({
    required this.dateKey,
    required this.dateLabel,
    required this.items,
  });

  factory ActivityDayGroup.fromJson(Map<String, dynamic> json) {
    final itemsJson = (json['items'] as List?) ?? [];
    return ActivityDayGroup(
      dateKey: (json['dateKey'] ?? '').toString(),
      dateLabel: (json['dateLabel'] ?? '').toString(),
      items: itemsJson
          .whereType<Map>()
          .map((e) => BusinessProfile.fromJson(e.cast<String, dynamic>()))
          .toList(),
    );
  }
}

class BusinessProfile {
  final String businessProfileId;
  final String shopId;
  final String englishName;
  final String tamilName;
  final String addressEn;
  final String addressTa;
  final String city;
  final String state;
  final String country;
  final String postalCode;
  final String primaryPhone;

  final String category;
  final String subCategory;
  final String categoryLabel;
  final String subCategoryLabel;
  final String breadcrumb;

  final String shopKind;
  final String typeLabel;

  final String? planType;
  final String planCategory;

  final String? planStartsAt;
  final String? planEndsAt;
  final int? planDurationDays;
  final int? daysLeft;

  final List<Media> media;
  final String? imageUrl;

  final String businessType;
  final DateTime createdAt;

  // new but useful
  final DateTime? activityDate;
  final String? activityDateKey;
  final String? activityDateLabel;

  BusinessProfile({
    required this.businessProfileId,
    required this.shopId,
    required this.englishName,
    required this.tamilName,
    required this.addressEn,
    required this.addressTa,
    required this.city,
    required this.state,
    required this.country,
    required this.postalCode,
    required this.primaryPhone,
    required this.category,
    required this.subCategory,
    required this.categoryLabel,
    required this.subCategoryLabel,
    required this.breadcrumb,
    required this.shopKind,
    required this.typeLabel,
    this.planType,
    required this.planCategory,
    this.planStartsAt,
    this.planEndsAt,
    this.planDurationDays,
    this.daysLeft,
    required this.media,
    this.imageUrl,
    required this.businessType,
    required this.createdAt,
    this.activityDate,
    this.activityDateKey,
    this.activityDateLabel,
  });

  factory BusinessProfile.fromJson(Map<String, dynamic> json) {
    int? _toIntOrNull(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toInt();
      return int.tryParse('$v');
    }

    DateTime? _parseDateOrNull(dynamic v) {
      final s = v?.toString();
      if (s == null || s.isEmpty) return null;
      return DateTime.tryParse(s);
    }

    return BusinessProfile(
      businessProfileId: (json['businessProfileId'] ?? '').toString(),
      shopId: (json['shopId'] ?? '').toString(),
      englishName: (json['englishName'] ?? '').toString(),
      tamilName: (json['tamilName'] ?? '').toString(),
      addressEn: (json['addressEn'] ?? '').toString(),
      addressTa: (json['addressTa'] ?? '').toString(),
      city: (json['city'] ?? '').toString(),
      state: (json['state'] ?? '').toString(),
      country: (json['country'] ?? '').toString(),
      postalCode: (json['postalCode'] ?? '').toString(),
      primaryPhone: (json['primaryPhone'] ?? '').toString(),
      category: (json['category'] ?? '').toString(),
      subCategory: (json['subCategory'] ?? '').toString(),
      categoryLabel: (json['categoryLabel'] ?? '').toString(),
      subCategoryLabel: (json['subCategoryLabel'] ?? '').toString(),
      breadcrumb: (json['breadcrumb'] ?? '').toString(),
      shopKind: (json['shopKind'] ?? '').toString(),
      typeLabel: (json['typeLabel'] ?? '').toString(),
      planType: json['planType']?.toString(),
      planCategory: (json['planCategory'] ?? '').toString(),
      planStartsAt: json['planStartsAt']?.toString(),
      planEndsAt: json['planEndsAt']?.toString(),
      planDurationDays: _toIntOrNull(json['planDurationDays']),
      daysLeft: _toIntOrNull(json['daysLeft']),
      media: ((json['media'] as List?) ?? [])
          .whereType<Map>()
          .map((e) => Media.fromJson(e.cast<String, dynamic>()))
          .toList(),
      imageUrl: json['imageUrl']?.toString(),
      businessType: (json['businessType'] ?? '').toString(),
      createdAt: _parseDateOrNull(json['createdAt']) ?? DateTime.now(),
      activityDate: _parseDateOrNull(json['activityDate']),
      activityDateKey: json['activityDateKey']?.toString(),
      activityDateLabel: json['activityDateLabel']?.toString(),
    );
  }
}

class Media {
  final String id;
  final String url;
  final int displayOrder;

  Media({
    required this.id,
    required this.url,
    required this.displayOrder,
  });

  factory Media.fromJson(Map<String, dynamic> json) {
    int _toInt(dynamic v) => (v is num) ? v.toInt() : int.tryParse('$v') ?? 0;

    return Media(
      id: (json['id'] ?? '').toString(),
      url: (json['url'] ?? '').toString(),
      displayOrder: _toInt(json['displayOrder']),
    );
  }
}


// class EmployeeHomeResponse {
//   final bool status;
//   final EmployeeData data;
//
//   EmployeeHomeResponse({required this.status, required this.data});
//
//   factory EmployeeHomeResponse.fromJson(Map<String, dynamic> json) {
//     return EmployeeHomeResponse(
//       status: json['status'] == true,
//       data: EmployeeData.fromJson(json['data'] ?? {}),
//     );
//   }
// }
//
// class EmployeeData {
//   final Employee employee;
//   final Metrics metrics;
//   final RecentActivity recentActivity;
//
//   EmployeeData({
//     required this.employee,
//     required this.metrics,
//     required this.recentActivity,
//   });
//
//   factory EmployeeData.fromJson(Map<String, dynamic> json) {
//     return EmployeeData(
//       employee: Employee.fromJson(json['employee'] ?? {}),
//       metrics: Metrics.fromJson(json['metrics'] ?? {}),
//       recentActivity: RecentActivity.fromJson(json['recentActivity'] ?? {}),
//     );
//   }
// }
//
// class Employee {
//   final String id;
//   final String name;
//   final String employeeCode;
//   final String vendorName;
//   final String? avatarUrl;
//
//   Employee({
//     required this.id,
//     required this.name,
//     required this.employeeCode,
//     required this.vendorName,
//     this.avatarUrl,
//   });
//
//   factory Employee.fromJson(Map<String, dynamic> json) {
//     return Employee(
//       id: (json['id'] ?? '').toString(),
//       name: (json['name'] ?? '').toString(),
//       employeeCode: (json['employeeCode'] ?? '').toString(),
//       vendorName: (json['vendorName'] ?? '').toString(),
//       avatarUrl: json['avatarUrl']?.toString(),
//     );
//   }
// }
//
// class Metrics {
//   final int totalEntry;
//   final int totalCollectionAmount;
//   final int freemiumCount;
//   final int premiumCount;
//   final int premiumProCount;
//
//   Metrics({
//     required this.totalEntry,
//     required this.totalCollectionAmount,
//     required this.freemiumCount,
//     required this.premiumCount,
//     required this.premiumProCount,
//   });
//
//   factory Metrics.fromJson(Map<String, dynamic> json) {
//     int _toInt(dynamic v) => (v is num) ? v.toInt() : int.tryParse('$v') ?? 0;
//
//     return Metrics(
//       totalEntry: _toInt(json['totalEntry']),
//       totalCollectionAmount: _toInt(json['totalCollectionAmount']),
//       freemiumCount: _toInt(json['freemiumCount']),
//       premiumCount: _toInt(json['premiumCount']),
//       premiumProCount: _toInt(json['premiumProCount']),
//     );
//   }
// }
//
// class RecentActivity {
//   final List<ActivityDayGroup> freemium;
//   final List<ActivityDayGroup> premium;
//   final List<ActivityDayGroup> premiumPro;
//
//   RecentActivity({
//     required this.freemium,
//     required this.premium,
//     required this.premiumPro,
//   });
//
//   factory RecentActivity.fromJson(Map<String, dynamic> json) {
//     List<ActivityDayGroup> _parse(dynamic v) {
//       final list = (v as List?) ?? [];
//       return list.map((e) => ActivityDayGroup.fromJson(e as Map<String, dynamic>)).toList();
//     }
//
//     return RecentActivity(
//       freemium: _parse(json['FREEMIUM']),
//       premium: _parse(json['PREMIUM']),
//       premiumPro: _parse(json['PREMIUM_PRO']),
//     );
//   }
// }
//
// class ActivityDayGroup {
//   final String dateKey;   // "2025-12-19"
//   final String dateLabel; // "Today"
//   final List<BusinessProfile> items;
//
//   ActivityDayGroup({
//     required this.dateKey,
//     required this.dateLabel,
//     required this.items,
//   });
//
//   factory ActivityDayGroup.fromJson(Map<String, dynamic> json) {
//     final itemsJson = (json['items'] as List?) ?? [];
//     return ActivityDayGroup(
//       dateKey: (json['dateKey'] ?? '').toString(),
//       dateLabel: (json['dateLabel'] ?? '').toString(),
//       items: itemsJson.map((e) => BusinessProfile.fromJson(e as Map<String, dynamic>)).toList(),
//     );
//   }
// }
//
// class BusinessProfile {
//   final String businessProfileId;
//   final String shopId;
//   final String englishName;
//   final String tamilName;
//   final String addressEn;
//   final String addressTa;
//   final String categoryLabel;
//   final String subCategoryLabel;
//   final String breadcrumb;
//   final String? planType;
//   final String planCategory;
//   final String? imageUrl;
//   final DateTime createdAt;
//   final List<Media> media;
//
//   BusinessProfile({
//     required this.businessProfileId,
//     required this.shopId,
//     required this.englishName,
//     required this.tamilName,
//     required this.addressEn,
//     required this.addressTa,
//     required this.categoryLabel,
//     required this.subCategoryLabel,
//     required this.breadcrumb,
//     this.planType,
//     required this.planCategory,
//     this.imageUrl,
//     required this.createdAt,
//     required this.media,
//   });
//
//   factory BusinessProfile.fromJson(Map<String, dynamic> json) {
//     DateTime _parseDate(dynamic v) {
//       final s = v?.toString();
//       if (s == null || s.isEmpty) return DateTime.now();
//       return DateTime.tryParse(s) ?? DateTime.now();
//     }
//
//     return BusinessProfile(
//       businessProfileId: (json['businessProfileId'] ?? '').toString(),
//       shopId: (json['shopId'] ?? '').toString(),
//       englishName: (json['englishName'] ?? '').toString(),
//       tamilName: (json['tamilName'] ?? '').toString(),
//       addressEn: (json['addressEn'] ?? '').toString(),
//       addressTa: (json['addressTa'] ?? '').toString(),
//       categoryLabel: (json['categoryLabel'] ?? '').toString(),
//       subCategoryLabel: (json['subCategoryLabel'] ?? '').toString(),
//       breadcrumb: (json['breadcrumb'] ?? '').toString(),
//       planType: json['planType']?.toString(),
//       planCategory: (json['planCategory'] ?? '').toString(),
//       imageUrl: json['imageUrl']?.toString(),
//       createdAt: _parseDate(json['createdAt']),
//       media: ((json['media'] as List?) ?? [])
//           .map((e) => Media.fromJson(e as Map<String, dynamic>))
//           .toList(),
//     );
//   }
// }
//
// class Media {
//   final String id;
//   final String url;
//   final int displayOrder;
//
//   Media({required this.id, required this.url, required this.displayOrder});
//
//   factory Media.fromJson(Map<String, dynamic> json) {
//     int _toInt(dynamic v) => (v is num) ? v.toInt() : int.tryParse('$v') ?? 0;
//
//     return Media(
//       id: (json['id'] ?? '').toString(),
//       url: (json['url'] ?? '').toString(),
//       displayOrder: _toInt(json['displayOrder']),
//     );
//   }
// }
