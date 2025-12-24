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

class AddEmployeeResponse {
  final bool status;
  final AddEmployeeData? data;

  AddEmployeeResponse({required this.status, this.data});

  factory AddEmployeeResponse.fromJson(Map<String, dynamic> json) {
    return AddEmployeeResponse(
      status: json['status'] ?? false,
      data:
          json['data'] != null ? AddEmployeeData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'status': status, 'data': data?.toJson()};
  }
}

class AddEmployeeData {
  final String? id;
  final String? name;
  final String? phoneNumber;
  final String? email;
  final String? avatarUrl;
  final bool? isActive;
  final String? status;
  final String? employeeCode;
  final String? employeeVerificationToken;

  AddEmployeeData({
    this.id,
    this.name,
    this.phoneNumber,
    this.email,
    this.avatarUrl,
    this.isActive,
    this.status,
    this.employeeCode,
    this.employeeVerificationToken,
  });

  factory AddEmployeeData.fromJson(Map<String, dynamic> json) {
    return AddEmployeeData(
      id: json['id'],
      name: json['name'],
      phoneNumber: json['phoneNumber'],
      email: json['email'],
      avatarUrl: json['avatarUrl'],
      // isActive: json['isActive'],
      isActive: parseBool(json['isActive'], defaultValue: true),
      status: json['status'],
      employeeCode: json['employeeCode'],
      employeeVerificationToken: json['employeeVerificationToken'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'email': email,
      'avatarUrl': avatarUrl,
      'isActive': isActive,
      'status': status,
      'employeeCode': employeeCode,
      'employeeVerificationToken': employeeVerificationToken,
    };
  }
}
