class  EmployeeListResponse  {
  final bool status;
  final VendorData data;

  EmployeeListResponse({
    required this.status,
    required this.data,
  });

  factory EmployeeListResponse.fromJson(Map<String, dynamic> json) {
    return EmployeeListResponse(
      status: json['status'] ?? false,
      data: VendorData.fromJson(json['data']),
    );
  }
}
class VendorData {
  final String vendorId;
  final String vendorCode;
  final String displayName;
  final String companyName;
  final String avatarUrl;
  final String approvalStatus;
  final int employeesCount;
  final List<Employee> employees;

  VendorData({
    required this.vendorId,
    required this.vendorCode,
    required this.displayName,
    required this.companyName,
    required this.avatarUrl,
    required this.approvalStatus,
    required this.employeesCount,
    required this.employees,
  });

  factory VendorData.fromJson(Map<String, dynamic> json) {
    return VendorData(
      vendorId: json['vendorId'] ?? '',
      vendorCode: json['vendorCode'] ?? '',
      displayName: json['displayName'] ?? '',
      companyName: json['companyName'] ?? '',
      avatarUrl: json['avatarUrl'] ?? '',
      approvalStatus: json['approvalStatus'] ?? '',
      employeesCount: json['employeesCount'] ?? 0,
      employees: (json['employees'] as List<dynamic>)
          .map((e) => Employee.fromJson(e))
          .toList(),
    );
  }
}
class Employee {
  final String id;
  final String name;
  final String phoneNumber;
  final String email;
  final String avatarUrl;
  final String employeeCode;
  final bool isActive;

  Employee({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.email,
    required this.avatarUrl,
    required this.employeeCode,
    required this.isActive,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      email: json['email'] ?? '',
      avatarUrl: json['avatarUrl'] ?? '',
      employeeCode: json['employeeCode'] ?? '',
      isActive: json['isActive'] ?? false,
    );
  }
}
