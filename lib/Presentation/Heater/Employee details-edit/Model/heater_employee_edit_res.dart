class EmployeeUpdateResponse {
  final bool status;
  final String message;
  final EmployeeUpdateData data;

  EmployeeUpdateResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory EmployeeUpdateResponse.fromJson(Map<String, dynamic> json) {
    return EmployeeUpdateResponse(
      status: json['status'] as bool,
      message: json['message'] as String,
      data: EmployeeUpdateData.fromJson(
        json['data'] as Map<String, dynamic>,
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'message': message,
    'data': data.toJson(),
  };
}
class EmployeeUpdateData {
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
  final String aadharDocumentUrl;

  EmployeeUpdateData({
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
    required this.aadharDocumentUrl,
  });

  factory EmployeeUpdateData.fromJson(Map<String, dynamic> json) {
    return EmployeeUpdateData(
      id: json['id'] as String,
      employeeCode: json['employeeCode'] as String,
      name: json['name'] as String,
      phoneNumber: json['phoneNumber'] as String,
      email: json['email'] as String,
      avatarUrl: json['avatarUrl'] ??"",
      isActive: json['isActive'] as bool,
      emergencyContactName: json['emergencyContactName'] as String,
      emergencyContactRelationship:
      json['emergencyContactRelationship'] as String,
      emergencyContactPhone: json['emergencyContactPhone'] as String,
      aadharNumber: json['aadharNumber'] as String,
      aadharDocumentUrl: json['aadharDocumentUrl'] as String,
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
    'emergencyContactName': emergencyContactName,
    'emergencyContactRelationship': emergencyContactRelationship,
    'emergencyContactPhone': emergencyContactPhone,
    'aadharNumber': aadharNumber,
    'aadharDocumentUrl': aadharDocumentUrl,
  };
}
