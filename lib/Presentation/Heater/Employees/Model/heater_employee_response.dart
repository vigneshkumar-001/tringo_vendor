// ✅ helpers (put at TOP of this file, above classes)
bool parseBool(dynamic v, {bool defaultValue = true}) {
  if (v == null) return defaultValue;
  if (v is bool) return v;
  if (v is num) return v != 0;
  if (v is String) {
    final s = v.trim().toLowerCase();
    if (s == 'true' || s == '1' || s == 'yes') return true;
    if (s == 'false' || s == '0' || s == 'no') return false;
  }
  return defaultValue;
}

int parseInt(dynamic v, {int defaultValue = 0}) {
  if (v == null) return defaultValue;
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v.trim()) ?? defaultValue;
  return defaultValue;
}

String parseString(dynamic v, {String defaultValue = ''}) {
  if (v == null) return defaultValue;
  return v.toString();
}

// ---------------------------------------------------------------------------

class HeaterEmployeeResponse {
  final bool status;
  final EmployeeData data;

  HeaterEmployeeResponse({required this.status, required this.data});

  factory HeaterEmployeeResponse.fromJson(Map<String, dynamic> json) {
    return HeaterEmployeeResponse(
      status: parseBool(json['status'], defaultValue: false),
      data: EmployeeData.fromJson((json['data'] ?? {}) as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {'status': status, 'data': data.toJson()};
}

class EmployeeData {
  final List<EmployeeItem> items;
  final int page;
  final int limit;
  final int total;
  final AppliedFilters appliedFilters;

  EmployeeData({
    required this.items,
    required this.page,
    required this.limit,
    required this.total,
    required this.appliedFilters,
  });

  factory EmployeeData.fromJson(Map<String, dynamic> json) {
    final list = (json['items'] as List?) ?? [];
    return EmployeeData(
      items:
          list
              .map(
                (e) => EmployeeItem.fromJson((e ?? {}) as Map<String, dynamic>),
              )
              .toList(),
      page: parseInt(json['page'], defaultValue: 1),
      limit: parseInt(json['limit'], defaultValue: 10),
      total: parseInt(json['total'], defaultValue: 0),
      appliedFilters: AppliedFilters.fromJson(
        (json['appliedFilters'] ?? {}) as Map<String, dynamic>,
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'items': items.map((e) => e.toJson()).toList(),
    'page': page,
    'limit': limit,
    'total': total,
    'appliedFilters': appliedFilters.toJson(),
  };
}

class EmployeeItem {
  final String id;
  final String employeeCode;
  final String name;
  final String phoneNumber;
  final String email;
  final String? avatarUrl;
  final bool isActive;
  final int collectionCount;
  final int totalAmount;

  EmployeeItem({
    required this.id,
    required this.employeeCode,
    required this.name,
    required this.phoneNumber,
    required this.email,
    this.avatarUrl,
    required this.isActive,
    required this.collectionCount,
    required this.totalAmount,
  });

  factory EmployeeItem.fromJson(Map<String, dynamic> json) {
    return EmployeeItem(
      id: parseString(json['id']),
      employeeCode: parseString(json['employeeCode']),
      name: parseString(json['name']),
      phoneNumber: parseString(json['phoneNumber']),
      email: parseString(json['email']),
      avatarUrl:
          (json['avatarUrl'] == null || '${json['avatarUrl']}'.trim().isEmpty)
              ? null
              : parseString(json['avatarUrl']),
      // ✅ MAIN FIX: defaultValue true so new employee won't show Blocked
      isActive: parseBool(json['isActive'], defaultValue: true),
      collectionCount: parseInt(json['collectionCount'], defaultValue: 0),
      totalAmount: parseInt(json['totalAmount'], defaultValue: 0),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'employeeCode': employeeCode,
    'name': name,
    'phoneNumber': phoneNumber,
    'email': email,
    'avatarUrl': avatarUrl,
    'isActive': isActive,
    'collectionCount': collectionCount,
    'totalAmount': totalAmount,
  };
}

class AppliedFilters {
  final String? q;
  final String active;
  final int? minAmount;
  final int? maxAmount;
  final List<String> categories;
  final String? dateFrom;
  final String? dateTo;
  final String sort;

  AppliedFilters({
    this.q,
    required this.active,
    this.minAmount,
    this.maxAmount,
    required this.categories,
    this.dateFrom,
    this.dateTo,
    required this.sort,
  });

  factory AppliedFilters.fromJson(Map<String, dynamic> json) {
    return AppliedFilters(
      q: json['q'] as String?,
      active: parseString(json['active'], defaultValue: ''),
      minAmount: json['minAmount'] == null ? null : parseInt(json['minAmount']),
      maxAmount: json['maxAmount'] == null ? null : parseInt(json['maxAmount']),
      categories:
          ((json['categories'] as List?) ?? [])
              .map((e) => parseString(e))
              .toList(),
      dateFrom: json['dateFrom'] as String?,
      dateTo: json['dateTo'] as String?,
      sort: parseString(json['sort'], defaultValue: ''),
    );
  }

  Map<String, dynamic> toJson() => {
    'q': q,
    'active': active,
    'minAmount': minAmount,
    'maxAmount': maxAmount,
    'categories': categories,
    'dateFrom': dateFrom,
    'dateTo': dateTo,
    'sort': sort,
  };
}
