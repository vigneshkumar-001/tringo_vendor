class ShopCategoryApiResponse {
  final bool status;
  final List<ShopKeywordItem> data;

  ShopCategoryApiResponse({required this.status, required this.data});

  factory ShopCategoryApiResponse.fromJson(Map<String, dynamic> json) {
    return ShopCategoryApiResponse(
      status: json['status'] as bool,
      data: (json['data'] as List<dynamic>)
          .map((e) => ShopKeywordItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'data': data.map((e) => e.toJson()).toList(),
  };
}

class ShopKeywordItem {
  final String id;
  final String keyword;
  final String? category;
  final Shop shop;

  ShopKeywordItem({
    required this.id,
    required this.keyword,
    this.category,
    required this.shop,
  });

  factory ShopKeywordItem.fromJson(Map<String, dynamic> json) {
    return ShopKeywordItem(
      id: json['id'] as String,
      keyword: json['keyword'] as String,
      category: json['category'] as String?,
      shop: Shop.fromJson(json['shop'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'keyword': keyword,
    'category': category,
    'shop': shop.toJson(),
  };
}

/// --- helpers --------------------------------------------------------------

double? _toDouble(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  if (v is String) {
    final s = v.trim();
    if (s.isEmpty) return null;
    return double.tryParse(s);
  }
  return null;
}

int? _toInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) {
    final s = v.trim();
    if (s.isEmpty) return null;
    return int.tryParse(s);
  }
  return null;
}

DateTime _parseDateTime(String v) => DateTime.parse(v);

/// -------------------------------------------------------------------------

class Shop {
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
  final bool? doorDelivery;
  final bool? isTrusted;
  final String? city;
  final String? state;
  final String? country;
  final String? postalCode;
  final String? serviceTags;
  final List<ShopWeeklyHour> weeklyHours;
  final double? averageRating;
  final int? reviewCount;
  final String? status;

  Shop({
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

  factory Shop.fromJson(Map<String, dynamic> json) => Shop(
    id: json['id'] as String,
    createdAt: _parseDateTime(json['createdAt'] as String),
    updatedAt: _parseDateTime(json['updatedAt'] as String),
    businessProfile:
    BusinessProfile.fromJson(json['businessProfile'] as Map<String, dynamic>),
    category: json['category'] as String?,
    subCategory: json['subCategory'] as String?,
    shopKind: json['shopKind'] as String?,
    englishName: json['englishName'] as String?,
    tamilName: json['tamilName'] as String?,
    descriptionEn: json['descriptionEn'] as String?,
    descriptionTa: json['descriptionTa'] as String?,
    addressEn: json['addressEn'] as String?,
    addressTa: json['addressTa'] as String?,
    gpsLatitude: _toDouble(json['gpsLatitude']),
    gpsLongitude: _toDouble(json['gpsLongitude']),
    primaryPhone: json['primaryPhone'] as String?,
    alternatePhone: json['alternatePhone'] as String?,
    contactEmail: json['contactEmail'] as String?,
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
    averageRating: _toDouble(json['averageRating']),
    reviewCount: _toInt(json['reviewCount']),
    status: json['status'] as String?,
  );

  Map<String, dynamic> toJson() => {
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

class BusinessProfile {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String businessType;
  final String ownershipType;
  final String govtRegisteredName;
  final String preferredLanguage;
  final String gender;
  final String dateOfBirth;
  final String identityDocumentUrl;
  final String ownerNameTamil;
  final User user;
  final String onboardingStatus;

  BusinessProfile({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.businessType,
    required this.ownershipType,
    required this.govtRegisteredName,
    required this.preferredLanguage,
    required this.gender,
    required this.dateOfBirth,
    required this.identityDocumentUrl,
    required this.ownerNameTamil,
    required this.user,
    required this.onboardingStatus,
  });

  factory BusinessProfile.fromJson(Map<String, dynamic> json) => BusinessProfile(
    id: json['id'] as String,
    createdAt: _parseDateTime(json['createdAt'] as String),
    updatedAt: _parseDateTime(json['updatedAt'] as String),
    businessType: json['businessType'] as String,
    ownershipType: json['ownershipType'] as String,
    govtRegisteredName: json['govtRegisteredName'] as String,
    preferredLanguage: json['preferredLanguage'] as String,
    gender: json['gender'] as String,
    dateOfBirth: json['dateOfBirth'] as String,
    identityDocumentUrl: json['identityDocumentUrl'] as String,
    ownerNameTamil: json['ownerNameTamil'] as String,
    user: User.fromJson(json['user'] as Map<String, dynamic>),
    onboardingStatus: json['onboardingStatus'] as String,
  );

  Map<String, dynamic> toJson() => {
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
    'user': user.toJson(),
    'onboardingStatus': onboardingStatus,
  };
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
class User {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String fullName;
  final String phoneNumber;
  final String email;
  final String role;
  final String status;

  User({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.fullName,
    required this.phoneNumber,
    required this.email,
    required this.role,
    required this.status,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'] as String,
    createdAt: _parseDateTime(json['createdAt'] as String),
    updatedAt: _parseDateTime(json['updatedAt'] as String),
    fullName: json['fullName'] as String,
    phoneNumber: json['phoneNumber'] as String,
    email: json['email'] as String,
    role: json['role'] as String,
    status: json['status'] as String,
  );

  Map<String, dynamic> toJson() => {
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