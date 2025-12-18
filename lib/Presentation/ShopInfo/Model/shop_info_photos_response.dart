class ShopInfoPhotosResponse {
  final bool status;
  final List<ShopMedia> data;

  const ShopInfoPhotosResponse({required this.status, required this.data});

  factory ShopInfoPhotosResponse.fromJson(Map<String, dynamic> json) {
    final list = json['data'] as List<dynamic>? ?? const [];

    return ShopInfoPhotosResponse(
      status: json['status'] ?? false,
      data: list
          .map((e) => ShopMedia.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'status': status, 'data': data.map((e) => e.toJson()).toList()};
  }
}

class ShopMedia {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ShopDetails shop;

  /// SIGN_BOARD, OUTSIDE, INSIDE, ...
  final String? type;
  final String? url;
  final int? displayOrder;

  const ShopMedia({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.shop,
    this.type,
    this.url,
    this.displayOrder,
  });

  factory ShopMedia.fromJson(Map<String, dynamic> json) {
    int? _parseInt(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toInt();
      if (v is String && v.trim().isNotEmpty) return int.tryParse(v);
      return null;
    }

    return ShopMedia(
      id: json['id'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
      shop: ShopDetails.fromJson(json['shop'] ?? const {}),
      type: json['type'] as String?,
      url: json['url'] as String?,
      // ✅ FIXED
      displayOrder: _parseInt(json['displayOrder']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'shop': shop.toJson(),
      'type': type,
      'url': url,
      'displayOrder': displayOrder,
    };
  }
}

class ShopDetails {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final BusinessProfile businessProfile;

  final String? category;
  final String? subCategory;
  final String? shopKind;
  final String? englishName;
  final String? tamilName;
  final String? descriptionEn;
  final String? descriptionTa;
  final String? addressEn;
  final String? addressTa;
  final double? gpsLatitude;
  final double? gpsLongitude;
  final String? primaryPhone;
  final String? alternatePhone;
  final String? contactEmail;
  final String? ownerImageUrl;
  final bool? doorDelivery;
  final bool? isTrusted;
  final String? city;
  final String? state;
  final String? country;
  final String? postalCode;
  final String? serviceTags;
  final List<ShopWeeklyHour> weeklyHours;
  final String? averageRating;
  final int? reviewCount;
  final String? status;

  const ShopDetails({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.businessProfile,
    this.category,
    this.subCategory,
    this.shopKind,
    this.englishName,
    this.tamilName,
    this.descriptionEn,
    this.descriptionTa,
    this.addressEn,
    this.addressTa,
    this.gpsLatitude,
    this.gpsLongitude,
    this.primaryPhone,
    this.alternatePhone,
    this.contactEmail,
    this.ownerImageUrl,
    this.doorDelivery,
    this.isTrusted,
    this.city,
    this.state,
    this.country,
    this.postalCode,
    this.serviceTags,
    this.weeklyHours = const [],
    this.averageRating,
    this.reviewCount,
    this.status,
  });

  factory ShopDetails.fromJson(Map<String, dynamic> json) {
    double? _parseDouble(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      if (v is String && v.trim().isNotEmpty) {
        return double.tryParse(v);
      }
      return null;
    }

    int? _parseInt(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toInt();
      if (v is String && v.trim().isNotEmpty) {
        return int.tryParse(v);
      }
      return null;
    }

    return ShopDetails(
      id: json['id'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
      businessProfile:
      BusinessProfile.fromJson(json['businessProfile'] ?? const {}),
      category: json['category'] as String?,
      subCategory: json['subCategory'] as String?,
      shopKind: json['shopKind'] as String?,
      englishName: json['englishName'] as String?,
      tamilName: json['tamilName'] as String?,
      descriptionEn: json['descriptionEn'] as String?,
      descriptionTa: json['descriptionTa'] as String?,
      addressEn: json['addressEn'] as String?,
      addressTa: json['addressTa'] as String?,
      gpsLatitude: _parseDouble(json['gpsLatitude']),
      gpsLongitude: _parseDouble(json['gpsLongitude']),
      primaryPhone: json['primaryPhone'] as String?,
      alternatePhone: json['alternatePhone'] as String?,
      contactEmail: json['contactEmail'] as String?,
      ownerImageUrl: json['ownerImageUrl'] as String?,
      doorDelivery: json['doorDelivery'] as bool?,
      isTrusted: json['isTrusted'] as bool?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      country: json['country'] as String?,
      postalCode: json['postalCode'] as String?,
      serviceTags: json['serviceTags'] as String?,
      weeklyHours:
      (json['weeklyHours'] as List<dynamic>?)
          ?.map((e) => ShopWeeklyHour.fromJson(e as Map<String, dynamic>))
          .toList() ??
          const [],
      averageRating: json['averageRating'] as String?,
      // ✅ FIXED
      reviewCount: _parseInt(json['reviewCount']),
      status: json['status'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'businessProfile': businessProfile.toJson(),
      'category': category,
      'subCategory': subCategory,
      'shopKind': shopKind,
      'englishName': englishName,
      'tamilName': tamilName,
      'descriptionEn': descriptionEn,
      'descriptionTa': descriptionTa,
      'addressEn': addressEn,
      'addressTa': addressTa,
      'gpsLatitude': gpsLatitude,
      'gpsLongitude': gpsLongitude,
      'primaryPhone': primaryPhone,
      'alternatePhone': alternatePhone,
      'contactEmail': contactEmail,
      'ownerImageUrl': ownerImageUrl,
      'doorDelivery': doorDelivery,
      'isTrusted': isTrusted,
      'city': city,
      'state': state,
      'country': country,
      'postalCode': postalCode,
      'serviceTags': serviceTags,
      'weeklyHours': weeklyHours,
      'averageRating': averageRating,
      'reviewCount': reviewCount,
      'status': status,
    };
  }
}
class ShopWeeklyHour {
  final String? day;
  final String? opensAt;
  final String? closesAt;
  final bool? closed;

  const ShopWeeklyHour({this.day, this.opensAt, this.closesAt, this.closed});

  factory ShopWeeklyHour.fromJson(Map<String, dynamic> json) {
    return ShopWeeklyHour(
      day: json['day'],
      opensAt: json['opensAt'],
      closesAt: json['closesAt'],
      closed: _parseBool(json['closed']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'opensAt': opensAt,
      'closesAt': closesAt,
      'closed': closed,
    };
  }
}
class BusinessProfile {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;

  final String? businessType;
  final String? ownershipType;
  final String? govtRegisteredName;
  final String? preferredLanguage;
  final String? gender;
  final String? dateOfBirth;
  final String? identityDocumentUrl;
  final String? ownerNameTamil;
  final AppUser? user;
  final String? onboardingStatus;

  const BusinessProfile({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
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
  });

  factory BusinessProfile.fromJson(Map<String, dynamic> json) {
    return BusinessProfile(
      id: json['id'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
      businessType: json['businessType'] as String?,
      ownershipType: json['ownershipType'] as String?,
      govtRegisteredName: json['govtRegisteredName'] as String?,
      preferredLanguage: json['preferredLanguage'] as String?,
      gender: json['gender'] as String?,
      dateOfBirth: json['dateOfBirth'] as String?,
      identityDocumentUrl: json['identityDocumentUrl'] as String?,
      ownerNameTamil: json['ownerNameTamil'] as String?,
      user: json['user'] != null
          ? AppUser.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      onboardingStatus: json['onboardingStatus'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'businessType': businessType,
      'ownershipType': ownershipType,
      'govtRegisteredName': govtRegisteredName,
      'preferredLanguage': preferredLanguage,
      'gender': gender,
      'dateOfBirth': dateOfBirth,
      'identityDocumentUrl': identityDocumentUrl,
      'ownerNameTamil': ownerNameTamil,
      'user': user?.toJson(),
      'onboardingStatus': onboardingStatus,
    };
  }
}

class AppUser {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? fullName;
  final String? phoneNumber;
  final String? email;
  final String? role;
  final String? status;

  const AppUser({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.fullName,
    this.phoneNumber,
    this.email,
    this.role,
    this.status,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
      fullName: json['fullName'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      email: json['email'] as String?,
      role: json['role'] as String?,
      status: json['status'] as String?,
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
    };
  }
}
bool? _parseBool(dynamic value) {
  if (value == null) return null;
  if (value is bool) return value;

  if (value is num) {
    if (value == 1) return true;
    if (value == 0) return false;
  }

  if (value is String) {
    final lower = value.toLowerCase().trim();
    if (lower == 'true' || lower == 'yes' || lower == '1') return true;
    if (lower == 'false' || lower == 'no' || lower == '0') return false;
  }

  return null;
}

