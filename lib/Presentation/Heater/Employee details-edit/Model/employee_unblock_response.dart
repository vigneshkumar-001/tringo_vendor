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
      isActive: parseBool(json['isActive'], defaultValue: true),
      blockedAt:
          json['blockedAt'] != null
              ? DateTime.tryParse(json['blockedAt'].toString())
              : null,
      blockedReason: json['blockedReason']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'employeeId': employeeId,
    'isActive': isActive,
    'blockedAt': blockedAt?.toIso8601String(),
    'blockedReason': blockedReason,
  };
}
