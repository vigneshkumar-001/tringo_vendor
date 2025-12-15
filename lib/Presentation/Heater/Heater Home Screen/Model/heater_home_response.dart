class VendorDashboardResponse {
  final bool status;
  final VendorDashboardData? data;

  VendorDashboardResponse({required this.status, this.data});

  factory VendorDashboardResponse.fromJson(Map<String, dynamic> json) {
    return VendorDashboardResponse(
      status: json['status'] ?? false,
      data:
          json['data'] != null
              ? VendorDashboardData.fromJson(json['data'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'status': status, 'data': data?.toJson()};
  }
}

class VendorDashboardData {
  final VendorHeader header;
  final int todayTotalCount;
  final num todayTotalAmount;
  final List<PlanCard> planCards;
  final List<TodayActivity> todayActivity;

  VendorDashboardData({
    required this.header,
    required this.todayTotalCount,
    required this.todayTotalAmount,
    required this.planCards,
    required this.todayActivity,
  });

  factory VendorDashboardData.fromJson(Map<String, dynamic> json) {
    return VendorDashboardData(
      header: VendorHeader.fromJson(json['header'] ?? {}),
      todayTotalCount: json['todayTotalCount'] ?? 0,
      todayTotalAmount: json['todayTotalAmount'] ?? 0,
      planCards:
          (json['planCards'] as List<dynamic>? ?? [])
              .map((e) => PlanCard.fromJson(e))
              .toList(),
      todayActivity:
          (json['todayActivity'] as List<dynamic>? ?? [])
              .map((e) => TodayActivity.fromJson(e))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'header': header.toJson(),
      'todayTotalCount': todayTotalCount,
      'todayTotalAmount': todayTotalAmount,
      'planCards': planCards.map((e) => e.toJson()).toList(),
      'todayActivity': todayActivity.map((e) => e.toJson()).toList(),
    };
  }
}

class VendorHeader {
  final String? vendorId;
  final String? vendorCode;
  final String? displayName;
  final String? avatarUrl;
  final int employeesCount;
  final String? approvalStatus;

  VendorHeader({
    this.vendorId,
    this.vendorCode,
    this.displayName,
    this.avatarUrl,
    required this.employeesCount,
    this.approvalStatus,
  });

  factory VendorHeader.fromJson(Map<String, dynamic> json) {
    return VendorHeader(
      vendorId: json['vendorId'],
      vendorCode: json['vendorCode'],
      displayName: json['displayName'],
      avatarUrl: json['avatarUrl'],
      employeesCount: json['employeesCount'] ?? 0,
      approvalStatus: json['approvalStatus'],
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

class PlanCard {
  final String label;
  final int count;
  final num amount;

  PlanCard({required this.label, required this.count, required this.amount});

  factory PlanCard.fromJson(Map<String, dynamic> json) {
    return PlanCard(
      label: json['label'] ?? '',
      count: json['count'] ?? 0,
      amount: json['amount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'label': label, 'count': count, 'amount': amount};
  }
}

class TodayActivity {
  final String employeeId;
  final String employeeCode;
  final String name;
  final String phoneNumber;
  final String avatarUrl;
  final num todayAmount;

  TodayActivity({
    required this.employeeId,
    required this.employeeCode,
    required this.name,
    required this.phoneNumber,
    required this.avatarUrl,
    required this.todayAmount,
  });

  factory TodayActivity.fromJson(Map<String, dynamic> json) {
    return TodayActivity(
      employeeId: json['employeeId'] ?? '',
      employeeCode: json['employeeCode'] ?? '',
      name: json['name'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      avatarUrl: json['avatarUrl'] ?? '',
      todayAmount: json['todayAmount'] ?? 0,
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
    };
  }
}
