class VendorResponse {
  final bool status;
  final VendorData data;

  VendorResponse({required this.status, required this.data});

  factory VendorResponse.fromJson(Map<String, dynamic> json) {
    return VendorResponse(
      status: json['status'] as bool,
      data: VendorData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {'status': status, 'data': data.toJson()};
  }
}



class VendorData {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final VendorUser user;

  // nullable fields
  final String? displayName;
  final String? ownerNameTamil;
  final String? companyName;
  final String? primaryCity;
  final String? primaryState;
  final String? avatarUrl;

  final String? gender;                 // 🔄 made nullable
  final DateTime? dateOfBirth;
  final bool isActive;
  final String? addressLine1;
  final double? gpsLatitude;
  final double? gpsLongitude;

  final String? aadharNumber;           // 🔄 made nullable
  final String? aadharDocumentUrl;      // 🔄 made nullable

  final String? bankAccountNumber;
  final String? bankName;
  final String? bankAccountName;
  final String? bankBranch;
  final String? bankIfsc;
  final String? companyContactNumber;
  final String? alternatePhone;
  final String? companyEmail;
  final String? gstNumber;

  VendorData({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.user,
    this.displayName,
    this.ownerNameTamil,
    this.companyName,
    this.primaryCity,
    this.primaryState,
    this.avatarUrl,
    this.gender,
    this.dateOfBirth,
    required this.isActive,
    this.addressLine1,
    this.gpsLatitude,
    this.gpsLongitude,
    this.aadharNumber,
    this.aadharDocumentUrl,
    this.bankAccountNumber,
    this.bankName,
    this.bankAccountName,
    this.bankBranch,
    this.bankIfsc,
    this.companyContactNumber,
    this.alternatePhone,
    this.companyEmail,
    this.gstNumber,
  });

  factory VendorData.fromJson(Map<String, dynamic> json) {
    bool parseIsActive(dynamic v) {
      if (v is bool) return v;
      if (v is int) return v == 1;
      if (v is String) {
        return v == '1' || v.toLowerCase() == 'true';
      }
      return false; // default
    }

    double? parseDouble(dynamic v) {
      if (v == null) return null;
      return double.tryParse(v.toString());
    }

    DateTime? parseDate(dynamic v) {
      if (v == null) return null;
      try {
        return DateTime.parse(v.toString());
      } catch (_) {
        return null;
      }
    }

    return VendorData(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      user: VendorUser.fromJson(json['user'] as Map<String, dynamic>),

      displayName: json['displayName'] as String?,
      ownerNameTamil: json['ownerNameTamil'] as String?,
      companyName: json['companyName'] as String?,
      primaryCity: json['primaryCity'] as String?,
      primaryState: json['primaryState'] as String?,
      avatarUrl: json['avatarUrl'] as String?,

      gender: json['gender'] as String?,                 // ✅ safe
      dateOfBirth: parseDate(json['dateOfBirth']),       // ✅ safe
      isActive: parseIsActive(json['isActive']),         // ✅ supports int/bool/string
      addressLine1: json['addressLine1'] as String?,
      gpsLatitude: parseDouble(json['gpsLatitude']),     // ✅ safe
      gpsLongitude: parseDouble(json['gpsLongitude']),   // ✅ safe

      aadharNumber: json['aadharNumber'] as String?,           // ✅ safe
      aadharDocumentUrl: json['aadharDocumentUrl'] as String?, // ✅ safe

      bankAccountNumber: json['bankAccountNumber'] as String?,
      bankName: json['bankName'] as String?,
      bankAccountName: json['bankAccountName'] as String?,
      bankBranch: json['bankBranch'] as String?,
      bankIfsc: json['bankIfsc'] as String?,
      companyContactNumber: json['companyContactNumber'] as String?,
      alternatePhone: json['alternatePhone'] as String?,
      companyEmail: json['companyEmail'] as String?,
      gstNumber: json['gstNumber'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'user': user.toJson(),
      'displayName': displayName,
      'ownerNameTamil': ownerNameTamil,
      'companyName': companyName,
      'primaryCity': primaryCity,
      'primaryState': primaryState,
      'avatarUrl': avatarUrl,
      'gender': gender,
      'dateOfBirth': dateOfBirth?.toIso8601String().substring(0, 10),
      'isActive': isActive ? 1 : 0,
      'addressLine1': addressLine1,
      'gpsLatitude': gpsLatitude?.toString(),
      'gpsLongitude': gpsLongitude?.toString(),
      'aadharNumber': aadharNumber,
      'aadharDocumentUrl': aadharDocumentUrl,
      'bankAccountNumber': bankAccountNumber,
      'bankName': bankName,
      'bankAccountName': bankAccountName,
      'bankBranch': bankBranch,
      'bankIfsc': bankIfsc,
      'companyContactNumber': companyContactNumber,
      'alternatePhone': alternatePhone,
      'companyEmail': companyEmail,
      'gstNumber': gstNumber,
    };
  }
}


class VendorUser {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? fullName;
  final String phoneNumber;
  final String email;
  final String role;
  final String status;
  final dynamic businessProfile;
  final dynamic customerProfile;
  final dynamic vendorProfile;
  final dynamic employeeProfile;

  VendorUser({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.fullName,
    required this.phoneNumber,
    required this.email,
    required this.role,
    required this.status,
    this.businessProfile,
    this.customerProfile,
    this.vendorProfile,
    this.employeeProfile,
  });

  factory VendorUser.fromJson(Map<String, dynamic> json) {
    return VendorUser(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      fullName: json['fullName'] as String?,
      phoneNumber: json['phoneNumber'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      status: json['status'] as String,
      businessProfile: json['businessProfile'],
      customerProfile: json['customerProfile'],
      vendorProfile: json['vendorProfile'],
      employeeProfile: json['employeeProfile'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'email': email,
      'role': role,
      'status': status,
      'businessProfile': businessProfile,
      'customerProfile': customerProfile,
      'vendorProfile': vendorProfile,
      'employeeProfile': employeeProfile,
    };
  }
}
