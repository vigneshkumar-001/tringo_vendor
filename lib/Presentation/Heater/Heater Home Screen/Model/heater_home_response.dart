// heater_home_response.dart

class VendorDashboardResponse {
  final bool? status;
  final VendorDashboardData? data;

  const VendorDashboardResponse({
    this.status,
    this.data,
  });

  factory VendorDashboardResponse.fromJson(Map<String, dynamic> json) {
    return VendorDashboardResponse(
      status: json['status'] as bool?,
      data: json['data'] == null
          ? null
          : VendorDashboardData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'data': data?.toJson(),
    };
  }
}

class VendorDashboardData {
  final VendorHeader? header;
  final int? todayTotalCount;
  final num? todayTotalAmount;
  final List<PlanCardItem> planCards;
  final List<TodayActivityItem> todayActivity;
  final String? activityTitle;
  final AppliedFilters? appliedFilters;

  const VendorDashboardData({
    this.header,
    this.todayTotalCount,
    this.todayTotalAmount,
    this.planCards = const [],
    this.todayActivity = const [],
    this.activityTitle,
    this.appliedFilters,
  });

  factory VendorDashboardData.fromJson(Map<String, dynamic> json) {
    return VendorDashboardData(
      header: json['header'] == null
          ? null
          : VendorHeader.fromJson(json['header'] as Map<String, dynamic>),
      todayTotalCount: _asInt(json['todayTotalCount']),
      todayTotalAmount: _asNum(json['todayTotalAmount']),
      planCards: (json['planCards'] as List<dynamic>?)
          ?.map((e) => PlanCardItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
          const [],
      todayActivity: (json['todayActivity'] as List<dynamic>?)
          ?.map((e) => TodayActivityItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
          const [],
      activityTitle: json['activityTitle'] as String?,
      appliedFilters: json['appliedFilters'] == null
          ? null
          : AppliedFilters.fromJson(
        json['appliedFilters'] as Map<String, dynamic>,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'header': header?.toJson(),
      'todayTotalCount': todayTotalCount,
      'todayTotalAmount': todayTotalAmount,
      'planCards': planCards.map((e) => e.toJson()).toList(),
      'todayActivity': todayActivity.map((e) => e.toJson()).toList(),
      'activityTitle': activityTitle,
      'appliedFilters': appliedFilters?.toJson(),
    };
  }
}

class VendorHeader {
  final String? vendorId;
  final String? vendorCode;
  final String? displayName;
  final String? avatarUrl;
  final int? employeesCount;
  final String? approvalStatus;

  const VendorHeader({
    this.vendorId,
    this.vendorCode,
    this.displayName,
    this.avatarUrl,
    this.employeesCount,
    this.approvalStatus,
  });

  factory VendorHeader.fromJson(Map<String, dynamic> json) {
    return VendorHeader(
      vendorId: json['vendorId'] as String?,
      vendorCode: json['vendorCode'] as String?,
      displayName: json['displayName'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      employeesCount: _asInt(json['employeesCount']),
      approvalStatus: json['approvalStatus'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vendorId': vendorId,
      'vendorCode': vendorCode,
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'employeesCount': employeesCount,
      'approvalStatus': approvalStatus,
    };
  }
}

class PlanCardItem {
  final String? label;
  final int? count;
  final num? amount;

  const PlanCardItem({
    this.label,
    this.count,
    this.amount,
  });

  factory PlanCardItem.fromJson(Map<String, dynamic> json) {
    return PlanCardItem(
      label: json['label'] as String?,
      count: _asInt(json['count']),
      amount: _asNum(json['amount']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'count': count,
      'amount': amount,
    };
  }
}

class TodayActivityItem {
  final String? employeeId;
  final String? employeeCode;
  final String? name;
  final String? phoneNumber;
  final String? avatarUrl;
  final num? todayAmount;
  final bool isActive;

  const TodayActivityItem({
    this.employeeId,
    this.employeeCode,
    this.name,
    this.phoneNumber,
    this.avatarUrl,
    this.todayAmount,
    required this.isActive,
  });

  factory TodayActivityItem.fromJson(Map<String, dynamic> json) {
    return TodayActivityItem(
      employeeId: json['employeeId'] as String?,
      employeeCode: json['employeeCode'] as String?,
      name: json['name'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      todayAmount: _asNum(json['todayAmount']),
      isActive: json['isActive'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'employeeId': employeeId,
      'employeeCode': employeeCode,
      'name': name,
      'phoneNumber': phoneNumber,
      'avatarUrl': avatarUrl,
      'todayAmount': todayAmount,
      'isActive': isActive,
    };
  }
}

class AppliedFilters {
  final String? dateFrom; // "2025-12-23"
  final String? dateTo;   // "2025-12-23"
  final String? timezone; // "Asia/Kolkata"

  const AppliedFilters({
    this.dateFrom,
    this.dateTo,
    this.timezone,
  });

  factory AppliedFilters.fromJson(Map<String, dynamic> json) {
    return AppliedFilters(
      dateFrom: json['dateFrom'] as String?,
      dateTo: json['dateTo'] as String?,
      timezone: json['timezone'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dateFrom': dateFrom,
      'dateTo': dateTo,
      'timezone': timezone,
    };
  }
}

// -------------------- helpers --------------------

int? _asInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString());
}

num? _asNum(dynamic v) {
  if (v == null) return null;
  if (v is num) return v;
  return num.tryParse(v.toString());
}
