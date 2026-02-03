class GetProfileResponse {
  final bool status;
  final VendorProfile data;

  GetProfileResponse({
    required this.status,
    required this.data,
  });

  factory GetProfileResponse.fromJson(Map<String, dynamic> json) {
    return GetProfileResponse(
      status: json['status'],
      data: VendorProfile.fromJson(json['data']),
    );
  }
}
class VendorProfile {
  final String id;
  final String createdAt;
  final String updatedAt;

  final User user;

  final String vendorCode;
  final String displayName;
  final String? ownerNameTamil;
  final String companyName;

  final String? primaryCity;
  final String? primaryState;

  final String avatarUrl;
  final String gender;
  final String dateOfBirth;

  final bool isActive;

  final String? addressLine1;

  final String gpsLatitude;
  final String gpsLongitude;

  final String aadharNumber;
  final String aadharDocumentUrl;

  final String bankAccountNumber;
  final String bankAccountName;
  final String bankName;
  final String bankBranch;
  final String bankIfsc;

  final String companyContactNumber;
  final String alternatePhone;
  final String companyEmail;

  final String gstNumber;
  final String approvalStatus;

  final OwnerMeta ownerMeta;

  VendorProfile({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.user,
    required this.vendorCode,
    required this.displayName,
    this.ownerNameTamil,
    required this.companyName,
    this.primaryCity,
    this.primaryState,
    required this.avatarUrl,
    required this.gender,
    required this.dateOfBirth,
    required this.isActive,
    this.addressLine1,
    required this.gpsLatitude,
    required this.gpsLongitude,
    required this.aadharNumber,
    required this.aadharDocumentUrl,
    required this.bankAccountNumber,
    required this.bankAccountName,
    required this.bankName,
    required this.bankBranch,
    required this.bankIfsc,
    required this.companyContactNumber,
    required this.alternatePhone,
    required this.companyEmail,
    required this.gstNumber,
    required this.approvalStatus,
    required this.ownerMeta,
  });

  factory VendorProfile.fromJson(Map<String, dynamic> json) {
    return VendorProfile(
      id: json['id'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      user: User.fromJson(json['user']),
      vendorCode: json['vendorCode'],
      displayName: json['displayName'],
      ownerNameTamil: json['ownerNameTamil'],
      companyName: json['companyName'],
      primaryCity: json['primaryCity'],
      primaryState: json['primaryState'],
      avatarUrl: json['avatarUrl'],
      gender: json['gender'],
      dateOfBirth: json['dateOfBirth'],
      isActive: json['isActive'],
      addressLine1: json['addressLine1'],
      gpsLatitude: json['gpsLatitude'],
      gpsLongitude: json['gpsLongitude'],
      aadharNumber: json['aadharNumber'],
      aadharDocumentUrl: json['aadharDocumentUrl'],
      bankAccountNumber: json['bankAccountNumber'],
      bankAccountName: json['bankAccountName'],
      bankName: json['bankName'],
      bankBranch: json['bankBranch'],
      bankIfsc: json['bankIfsc'],
      companyContactNumber: json['companyContactNumber'],
      alternatePhone: json['alternatePhone'],
      companyEmail: json['companyEmail'],
      gstNumber: json['gstNumber'],
      approvalStatus: json['approvalStatus'],
      ownerMeta: OwnerMeta.fromJson(json['ownerMeta']),
    );
  }
}
class User {
  final String id;
  final String createdAt;
  final String updatedAt;

  final String fullName;
  final String phoneNumber;
  final String activePhoneNumber;
  final String email;
  final String role;
  final String status;

  final bool isDeleted;
  final String? deletedAt;

  User({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.fullName,
    required this.phoneNumber,
    required this.activePhoneNumber,
    required this.email,
    required this.role,
    required this.status,
    required this.isDeleted,
    this.deletedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      fullName: json['fullName'],
      phoneNumber: json['phoneNumber'],
      activePhoneNumber: json['activePhoneNumber'],
      email: json['email'],
      role: json['role'],
      status: json['status'],
      isDeleted: json['isDeleted'],
      deletedAt: json['deletedAt'],
    );
  }
}
class OwnerMeta {
  final String phoneNumber;
  final bool phoneVerified;
  final String fullName;
  final String email;

  OwnerMeta({
    required this.phoneNumber,
    required this.phoneVerified,
    required this.fullName,
    required this.email,
  });

  factory OwnerMeta.fromJson(Map<String, dynamic> json) {
    return OwnerMeta(
      phoneNumber: json['phoneNumber'],
      phoneVerified: json['phoneVerified'],
      fullName: json['fullName'],
      email: json['email'],
    );
  }
}
