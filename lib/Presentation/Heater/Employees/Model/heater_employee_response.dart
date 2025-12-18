class HeaterEmployeeResponse {
  final bool status;
  final EmployeeData data;

  HeaterEmployeeResponse({required this.status, required this.data});

  factory HeaterEmployeeResponse.fromJson(Map<String, dynamic> json) {
    return HeaterEmployeeResponse(
      status: json['status'] as bool,
      data: EmployeeData.fromJson(json['data'] as Map<String, dynamic>),
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
    return EmployeeData(
      items:
      (json['items'] as List).map((e) => EmployeeItem.fromJson(e)).toList(),
      page: json['page'] as int,
      limit: json['limit'] as int,
      total: json['total'] as int,
      appliedFilters: AppliedFilters.fromJson(
        json['appliedFilters'] as Map<String, dynamic>,
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
  final String ? avatarUrl;
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
      id: json['id'] as String,
      employeeCode: json['employeeCode'] as String,
      name: json['name'] as String,
      phoneNumber: json['phoneNumber'] as String,
      email: json['email'] as String,
      avatarUrl: json['avatarUrl'] ??'',
      isActive: json['isActive'] as bool,
      collectionCount: json['collectionCount'] as int,
      totalAmount: json['totalAmount'] as int,
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
      active: json['active'] as String,
      minAmount: json['minAmount'] as int?,
      maxAmount: json['maxAmount'] as int?,
      categories:
      (json['categories'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      dateFrom: json['dateFrom'] as String?,
      dateTo: json['dateTo'] as String?,
      sort: json['sort'] as String,
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
