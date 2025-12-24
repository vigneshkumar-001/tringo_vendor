class OwnerRegisterResponse {
  final bool status;
  final OwnerData? data;

  OwnerRegisterResponse({required this.status, this.data});

  factory OwnerRegisterResponse.fromJson(Map<String, dynamic> json) {
    return OwnerRegisterResponse(
      status: json['status'] ?? false,
      data: json['data'] != null ? OwnerData.fromJson(json['data']) : null,
    );
  }
}

class OwnerData {
  final String id;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? businessType;
  final String? ownershipType;
  final String? govtRegisteredName;
  final String? preferredLanguage;
  final String? gender;
  final String? dateOfBirth;
  final String? identityDocumentUrl;
  final String? ownerNameTamil;
  final User? user;
  final String? onboardingStatus;
  final Vendor? vendor;
  final OnboardedByEmployee? onboardedByEmployee;

  OwnerData({
    required this.id,
    this.createdAt,
    this.updatedAt,
    this.businessType,
    this.ownershipType,
    this.govtRegisteredName,
    this.preferredLanguage,
    this.gender,
    this.dateOfBirth,
    this.identityDocumentUrl,
    this.ownerNameTamil,
    this.user,
    this.onboardingStatus,
    this.vendor,
    this.onboardedByEmployee,
  });

  factory OwnerData.fromJson(Map<String, dynamic> json) {
    return OwnerData(
      id: json['id'] ?? '',
      createdAt:
          json['createdAt'] != null
              ? DateTime.tryParse(json['createdAt'])
              : null,
      updatedAt:
          json['updatedAt'] != null
              ? DateTime.tryParse(json['updatedAt'])
              : null,
      businessType: json['businessType'] as String?,
      ownershipType: json['ownershipType'] as String?,
      govtRegisteredName: json['govtRegisteredName'] as String?,
      preferredLanguage: json['preferredLanguage'] as String?,
      gender: json['gender'] as String?,
      dateOfBirth: json['dateOfBirth'] as String?,
      identityDocumentUrl: json['identityDocumentUrl'] as String?,
      ownerNameTamil: json['ownerNameTamil'] as String?,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      onboardingStatus: json['onboardingStatus'] as String?,
      vendor: json['vendor'] != null ? Vendor.fromJson(json['vendor']) : null,
      onboardedByEmployee:
          json['onboardedByEmployee'] != null
              ? OnboardedByEmployee.fromJson(json['onboardedByEmployee'])
              : null,
    );
  }
}

class User {
  final String id;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? fullName;
  final String? phoneNumber;
  final String? email;
  final String? role;
  final String? status;

  User({
    required this.id,
    this.createdAt,
    this.updatedAt,
    this.fullName,
    this.phoneNumber,
    this.email,
    this.role,
    this.status,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      createdAt:
          json['createdAt'] != null
              ? DateTime.tryParse(json['createdAt'])
              : null,
      updatedAt:
          json['updatedAt'] != null
              ? DateTime.tryParse(json['updatedAt'])
              : null,
      fullName: json['fullName'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      email: json['email'] as String?,
      role: json['role'] as String?,
      status: json['status'] as String?,
    );
  }
}

class Vendor {
  final String id;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? vendorCode;
  final String? displayName;
  final String? ownerNameTamil;
  final String? companyName;
  final String? primaryCity;
  final String? primaryState;
  final String? avatarUrl;
  final String? gender;
  final String? dateOfBirth;
  final bool? isActive;
  final String? addressLine1;
  final String? gpsLatitude;
  final String? gpsLongitude;
  final String? aadharNumber;
  final String? aadharDocumentUrl;
  final String? bankAccountNumber;
  final String? bankAccountName;
  final String? bankBranch;
  final String? bankIfsc;
  final String? companyContactNumber;
  final String? alternatePhone;
  final String? companyEmail;
  final String? gstNumber;

  Vendor({
    required this.id,
    this.createdAt,
    this.updatedAt,
    this.vendorCode,
    this.displayName,
    this.ownerNameTamil,
    this.companyName,
    this.primaryCity,
    this.primaryState,
    this.avatarUrl,
    this.gender,
    this.dateOfBirth,
    this.isActive,
    this.addressLine1,
    this.gpsLatitude,
    this.gpsLongitude,
    this.aadharNumber,
    this.aadharDocumentUrl,
    this.bankAccountNumber,
    this.bankAccountName,
    this.bankBranch,
    this.bankIfsc,
    this.companyContactNumber,
    this.alternatePhone,
    this.companyEmail,
    this.gstNumber,
  });
  static bool? _parseBool(dynamic v) {
    if (v == null) return null;
    if (v is bool) return v;
    if (v is int) return v == 1;
    if (v is String) {
      final s = v.toLowerCase().trim();
      if (s == 'true' || s == '1' || s == 'yes') return true;
      if (s == 'false' || s == '0' || s == 'no') return false;
    }
    return null;
  }


  factory Vendor.fromJson(Map<String, dynamic> json) {
    return Vendor(
      id: json['id'] ?? '',
      createdAt:
          json['createdAt'] != null
              ? DateTime.tryParse(json['createdAt'])
              : null,
      updatedAt:
          json['updatedAt'] != null
              ? DateTime.tryParse(json['updatedAt'])
              : null,
      vendorCode: json['vendorCode'] as String?,
      displayName: json['displayName'] as String?,
      ownerNameTamil: json['ownerNameTamil'] as String?,
      companyName: json['companyName'] as String?,
      primaryCity: json['primaryCity'] as String?,
      primaryState: json['primaryState'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      gender: json['gender'] as String?,
      dateOfBirth: json['dateOfBirth'] as String?,
      isActive: _parseBool(json['isActive']),
      addressLine1: json['addressLine1'] as String?,
      gpsLatitude: json['gpsLatitude'] as String?,
      gpsLongitude: json['gpsLongitude'] as String?,
      aadharNumber: json['aadharNumber'] as String?,
      aadharDocumentUrl: json['aadharDocumentUrl'] as String?,
      bankAccountNumber: json['bankAccountNumber'] as String?,
      bankAccountName: json['bankAccountName'] as String?,
      bankBranch: json['bankBranch'] as String?,
      bankIfsc: json['bankIfsc'] as String?,
      companyContactNumber: json['companyContactNumber'] as String?,
      alternatePhone: json['alternatePhone'] as String?,
      companyEmail: json['companyEmail'] as String?,
      gstNumber: json['gstNumber'] as String?,
    );
  }
}

class OnboardedByEmployee {
  final String id;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Vendor? vendor;
  final String? displayName;
  final String? employeeCode;

  OnboardedByEmployee({
    required this.id,
    this.createdAt,
    this.updatedAt,
    this.vendor,
    this.displayName,
    this.employeeCode,
  });

  factory OnboardedByEmployee.fromJson(Map<String, dynamic> json) {
    return OnboardedByEmployee(
      id: json['id'] ?? '',
      createdAt:
          json['createdAt'] != null
              ? DateTime.tryParse(json['createdAt'])
              : null,
      updatedAt:
          json['updatedAt'] != null
              ? DateTime.tryParse(json['updatedAt'])
              : null,
      vendor: json['vendor'] != null ? Vendor.fromJson(json['vendor']) : null,
      displayName: json['displayName'] as String?,
      employeeCode: json['employeeCode'] as String?,
    );
  }
}
