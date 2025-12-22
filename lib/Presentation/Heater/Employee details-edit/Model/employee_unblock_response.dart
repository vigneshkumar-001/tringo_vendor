class EmployeeUnblockResponse {
  final bool status;
  final String message;
  final EmployeeUnblockData data;

  const EmployeeUnblockResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory EmployeeUnblockResponse.fromJson(Map<String, dynamic> json) {
    return EmployeeUnblockResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: EmployeeUnblockData.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'message': message,
    'data': data.toJson(),
  };
}

class EmployeeUnblockData {
  final String employeeId;
  final bool isActive;
  final DateTime? blockedAt;
  final String? blockedReason;

  const EmployeeUnblockData({
    required this.employeeId,
    required this.isActive,
    this.blockedAt,
    this.blockedReason,
  });

  factory EmployeeUnblockData.fromJson(Map<String, dynamic> json) {
    return EmployeeUnblockData(
      employeeId: json['employeeId'] ?? '',
      isActive: json['isActive'] ?? false,
      blockedAt:
      json['blockedAt'] != null ? DateTime.parse(json['blockedAt']) : null,
      blockedReason: json['blockedReason'],
    );
  }

  Map<String, dynamic> toJson() => {
    'employeeId': employeeId,
    'isActive': isActive,
    'blockedAt': blockedAt?.toIso8601String(),
    'blockedReason': blockedReason,
  };
}
