class EmployeeDetailsResponse {
  final bool status;
  final EmployeeDetailsData data;

  EmployeeDetailsResponse({required this.status, required this.data});

  factory EmployeeDetailsResponse.fromJson(Map<String, dynamic> json) {
    return EmployeeDetailsResponse(
      status: json['status'] == true,
      data: EmployeeDetailsData.fromJson(json['data'] ?? {}),
    );
  }
}

class EmployeeDetailsData {
  final Employee employee;
  final Summary summary;
  final ShopsAndServices shopsAndServices;
  final bool isActive;

  EmployeeDetailsData({
    required this.employee,
    required this.summary,
    required this.shopsAndServices,
    required this.isActive,
  });

  factory EmployeeDetailsData.fromJson(Map<String, dynamic> json) {
    return EmployeeDetailsData(
      employee: Employee.fromJson(json['employee'] ?? {}),
      summary: Summary.fromJson(json['summary'] ?? {}),
      shopsAndServices: ShopsAndServices.fromJson(
        json['shopsAndServices'] ?? {},
      ),
      // isActive: json['isActive'] == true,
      isActive: parseBool(json['isActive'], defaultValue: true),
    );
  }
}
bool parseBool(dynamic v, {bool defaultValue = true}) {
  if (v == null) return defaultValue;
  if (v is bool) return v;
  if (v is num) return v != 0;

  if (v is String) {
    final s = v.trim().toLowerCase();
    if (s == 'true' || s == '1' || s == 'yes' || s == 'y') return true;
    if (s == 'false' || s == '0' || s == 'no' || s == 'n') return false;
  }
  return defaultValue;
}



class Employee {
  final String id;
  final String employeeCode;
  final String name;
  final String phoneNumber;
  final String email;
  final String? avatarUrl;
  final bool isActive;

  final String emergencyContactName;
  final String emergencyContactRelationship;
  final String emergencyContactPhone;

  final String aadharNumber;
  final String? aadharDocumentUrl;

  Employee({
    required this.id,
    required this.employeeCode,
    required this.name,
    required this.phoneNumber,
    required this.email,
    this.avatarUrl,
    required this.isActive,
    required this.emergencyContactName,
    required this.emergencyContactRelationship,
    required this.emergencyContactPhone,
    required this.aadharNumber,
    this.aadharDocumentUrl,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'] ?? '',
      employeeCode: json['employeeCode'] ?? '',
      name: json['name'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      email: json['email'] ?? '',
      avatarUrl: json['avatarUrl'],
      // isActive: json['isActive'] == true,
      isActive: parseBool(json['isActive'], defaultValue: true),
      emergencyContactName: json['emergencyContactName'] ?? '',
      emergencyContactRelationship: json['emergencyContactRelationship'] ?? '',
      emergencyContactPhone: json['emergencyContactPhone'] ?? '',
      aadharNumber: json['aadharNumber'] ?? '',
      aadharDocumentUrl: json['aadharDocumentUrl'],
    );
  }
}

class Summary {
  final int collectionCount;
  final int totalAmount;
  final int freemiumCount;
  final int premiumCount;
  final int premiumProCount;

  Summary({
    required this.collectionCount,
    required this.totalAmount,
    required this.freemiumCount,
    required this.premiumCount,
    required this.premiumProCount,
  });

  factory Summary.fromJson(Map<String, dynamic> json) {
    return Summary(
      collectionCount: (json['collectionCount'] ?? 0) as int,
      totalAmount: (json['totalAmount'] ?? 0) as int,
      freemiumCount: (json['freemiumCount'] ?? 0) as int,
      premiumCount: (json['premiumCount'] ?? 0) as int,
      premiumProCount: (json['premiumProCount'] ?? 0) as int,
    );
  }
}

class ShopsAndServices {
  final List<ShopSection> sections; // ✅ NEW
  final List<ShopItem> items; // ✅ updated (still exists)
  final Pagination pagination; // ✅ NEW
  final AppliedFilters appliedFilters; // ✅ NEW

  ShopsAndServices({
    required this.sections,
    required this.items,
    required this.pagination,
    required this.appliedFilters,
  });

  factory ShopsAndServices.fromJson(Map<String, dynamic> json) {
    final sectionsList = (json['sections'] as List?) ?? [];
    final itemsList = (json['items'] as List?) ?? [];

    return ShopsAndServices(
      sections:
          sectionsList
              .map((e) => ShopSection.fromJson(e as Map<String, dynamic>))
              .toList(),
      items:
          itemsList
              .map((e) => ShopItem.fromJson(e as Map<String, dynamic>))
              .toList(),
      pagination: Pagination.fromJson(json['pagination'] ?? {}),
      appliedFilters: AppliedFilters.fromJson(json['appliedFilters'] ?? {}),
    );
  }
}

// ✅ NEW: Section (Premium/Freemium/Pro Premium)
class ShopSection {
  final String key;
  final String title;
  final int count;
  final List<ShopGroup> groups;

  ShopSection({
    required this.key,
    required this.title,
    required this.count,
    required this.groups,
  });

  factory ShopSection.fromJson(Map<String, dynamic> json) {
    final groupsList = (json['groups'] as List?) ?? [];
    return ShopSection(
      key: json['key'] ?? '',
      title: json['title'] ?? '',
      count: (json['count'] ?? 0) as int,
      groups:
          groupsList
              .map((e) => ShopGroup.fromJson(e as Map<String, dynamic>))
              .toList(),
    );
  }
}

// ✅ NEW: Group (Yesterday/Today etc.)
class ShopGroup {
  final String dateKey;
  final String dateLabel;
  final List<ShopItem> items;

  ShopGroup({
    required this.dateKey,
    required this.dateLabel,
    required this.items,
  });

  factory ShopGroup.fromJson(Map<String, dynamic> json) {
    final itemsList = (json['items'] as List?) ?? [];
    return ShopGroup(
      dateKey: json['dateKey'] ?? '',
      dateLabel: json['dateLabel'] ?? '',
      items:
          itemsList
              .map((e) => ShopItem.fromJson(e as Map<String, dynamic>))
              .toList(),
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
    return Pagination(
      page: (json['page'] ?? 1) as int,
      limit: (json['limit'] ?? 10) as int,
      total: (json['total'] ?? 0) as int,
      hasMore: json['hasMore'] == true,
    );
  }
}

class AppliedFilters {
  final String? dateFrom;
  final String? dateTo;

  AppliedFilters({this.dateFrom, this.dateTo});

  factory AppliedFilters.fromJson(Map<String, dynamic> json) {
    return AppliedFilters(dateFrom: json['dateFrom'], dateTo: json['dateTo']);
  }
}

class ShopItem {
  final String shopId;
  final String businessProfileId;

  final String englishName;
  final String tamilName;
  final String typeLabel;

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

  final String? imageUrl;
  final DateTime? createdAt;

  final String businessType;

  final String? planType;
  final String? planCategory;

  // ✅ NEW plan fields
  final String? planTitle;
  final String? planStartsAt;
  final String? planEndsAt;
  final int? planDurationDays;
  final int? daysLeft;
  final String? planDurationLabel;
  final String? planBadgeText;

  ShopItem({
    required this.shopId,
    required this.businessProfileId,
    required this.englishName,
    required this.tamilName,
    required this.typeLabel,
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
    this.imageUrl,
    this.createdAt,
    required this.businessType,
    this.planType,
    this.planCategory,
    this.planTitle,
    this.planStartsAt,
    this.planEndsAt,
    this.planDurationDays,
    this.daysLeft,
    this.planDurationLabel,
    this.planBadgeText,
  });

  factory ShopItem.fromJson(Map<String, dynamic> json) {
    final createdAtStr = (json['createdAt'] ?? '') as String;

    return ShopItem(
      shopId: json['shopId'] ?? '',
      businessProfileId: json['businessProfileId'] ?? '',
      englishName: json['englishName'] ?? '',
      tamilName: json['tamilName'] ?? '',
      typeLabel: json['typeLabel'] ?? '',
      addressEn: json['addressEn'] ?? '',
      addressTa: json['addressTa'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      country: json['country'] ?? '',
      postalCode: json['postalCode'] ?? '',
      primaryPhone: json['primaryPhone'] ?? '',
      category: json['category'] ?? '',
      subCategory: json['subCategory'] ?? '',
      categoryLabel: json['categoryLabel'] ?? '',
      subCategoryLabel: json['subCategoryLabel'] ?? '',
      breadcrumb: json['breadcrumb'] ?? '',
      imageUrl: json['imageUrl'],
      createdAt:
          createdAtStr.isNotEmpty ? DateTime.tryParse(createdAtStr) : null,
      businessType: json['businessType'] ?? '',
      planType: json['planType'],
      planCategory: json['planCategory'],
      planTitle: json['planTitle'],
      planStartsAt: json['planStartsAt'],
      planEndsAt: json['planEndsAt'],
      planDurationDays: json['planDurationDays'],
      daysLeft: json['daysLeft'],
      planDurationLabel: json['planDurationLabel'],
      planBadgeText: json['planBadgeText'],
    );
  }
}
