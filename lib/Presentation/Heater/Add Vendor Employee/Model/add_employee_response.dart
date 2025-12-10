class  AddEmployeeResponse  {
  final bool status;
  final AddEmployeeData? data;

  AddEmployeeResponse({
    required this.status,
    this.data,
  });

  factory AddEmployeeResponse.fromJson(Map<String, dynamic> json) {
    return AddEmployeeResponse(
      status: json['status'] ?? false,
      data: json['data'] != null ? AddEmployeeData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'data': data?.toJson(),
    };
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

  AddEmployeeData({
    this.id,
    this.name,
    this.phoneNumber,
    this.email,
    this.avatarUrl,
    this.isActive,
    this.status,
    this.employeeCode,
  });

  factory AddEmployeeData.fromJson(Map<String, dynamic> json) {
    return AddEmployeeData(
      id: json['id'],
      name: json['name'],
      phoneNumber: json['phoneNumber'],
      email: json['email'],
      avatarUrl: json['avatarUrl'],
      isActive: json['isActive'],
      status: json['status'],
      employeeCode: json['employeeCode'],
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
    };
  }
}
