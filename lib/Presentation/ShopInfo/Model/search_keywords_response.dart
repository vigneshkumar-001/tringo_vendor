class ShopCategoryApiResponse {
  final bool status;
  final List<ShopKeywordItem> data;

  ShopCategoryApiResponse({required this.status, required this.data});

  factory ShopCategoryApiResponse.fromJson(Map<String, dynamic> json) {
    return ShopCategoryApiResponse(
      status: _b(json['status']) ?? false,
      data: (json['data'] as List<dynamic>? ?? const [])
          .map((e) => ShopKeywordItem.fromJson((e ?? {}) as Map<String, dynamic>))
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
      id: _s(json['id']),
      keyword: _s(json['keyword']),
      category: _sn(json['category']),
      shop: Shop.fromJson((json['shop'] ?? const {}) as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'keyword': keyword,
    'category': category,
    'shop': shop.toJson(),
  };
}

/// ---------------- helpers (SAFE) ----------------

String _s(dynamic v, {String fallback = ''}) {
  if (v == null) return fallback;
  if (v is String) return v;
  return v.toString();
}

String? _sn(dynamic v) {
  final s = _s(v, fallback: '');
  return s.trim().isEmpty ? null : s;
}

bool? _b(dynamic value) {
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

DateTime? _tryDate(dynamic v) {
  if (v == null) return null;
  if (v is DateTime) return v;
  if (v is String) {
    final s = v.trim();
    if (s.isEmpty) return null;
    return DateTime.tryParse(s);
  }
  return null;
}

DateTime _dateOrNow(dynamic v) => _tryDate(v) ?? DateTime.now();

/// ------------------------------------------------

class Shop {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final BusinessProfile? businessProfile;

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
    id: _s(json['id']),
    createdAt: _dateOrNow(json['createdAt']),
    updatedAt: _dateOrNow(json['updatedAt']),

    // ✅ businessProfile can be null in API sometimes
    businessProfile: (json['businessProfile'] is Map)
        ? BusinessProfile.fromJson(json['businessProfile'] as Map<String, dynamic>)
        : null,

    category: _sn(json['category']),
    subCategory: _sn(json['subCategory']),
    shopKind: _sn(json['shopKind']),
    englishName: _sn(json['englishName']),
    tamilName: _sn(json['tamilName']),
    descriptionEn: _sn(json['descriptionEn']),
    descriptionTa: _sn(json['descriptionTa']),
    addressEn: _sn(json['addressEn']),
    addressTa: _sn(json['addressTa']),
    gpsLatitude: _toDouble(json['gpsLatitude']),
    gpsLongitude: _toDouble(json['gpsLongitude']),
    primaryPhone: _sn(json['primaryPhone']),
    alternatePhone: _sn(json['alternatePhone']),
    contactEmail: _sn(json['contactEmail']),
    doorDelivery: _b(json['doorDelivery']),
    isTrusted: _b(json['isTrusted']),
    city: _sn(json['city']),
    state: _sn(json['state']),
    country: _sn(json['country']),
    postalCode: _sn(json['postalCode']),
    serviceTags: _sn(json['serviceTags']),
    weeklyHours: (json['weeklyHours'] as List<dynamic>? ?? const [])
        .map((e) => ShopWeeklyHour.fromJson((e ?? {}) as Map<String, dynamic>))
        .toList(),
    averageRating: _toDouble(json['averageRating']),
    reviewCount: _toInt(json['reviewCount']),
    status: _sn(json['status']),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'businessProfile': businessProfile?.toJson(),
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
    'weeklyHours': weeklyHours.map((e) => e.toJson()).toList(),
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

  // ✅ these can be null from backend, so make safe
  final String identityDocumentUrl;
  final String ownerNameTamil;
  final User? user;
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
    id: _s(json['id']),
    createdAt: _dateOrNow(json['createdAt']),
    updatedAt: _dateOrNow(json['updatedAt']),
    businessType: _s(json['businessType']),
    ownershipType: _s(json['ownershipType']),
    govtRegisteredName: _s(json['govtRegisteredName']),
    preferredLanguage: _s(json['preferredLanguage']),
    gender: _s(json['gender']),
    dateOfBirth: _s(json['dateOfBirth']),

    // ✅ FIX: avoid "as String" crash
    identityDocumentUrl: _s(json['identityDocumentUrl']),
    ownerNameTamil: _s(json['ownerNameTamil']),

    // ✅ user can also be null
    user: (json['user'] is Map)
        ? User.fromJson(json['user'] as Map<String, dynamic>)
        : null,

    onboardingStatus: _s(json['onboardingStatus']),
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
    'user': user?.toJson(),
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
      day: _sn(json['day']),
      opensAt: _sn(json['opensAt']),
      closesAt: _sn(json['closesAt']),
      closed: _b(json['closed']),
    );
  }

  Map<String, dynamic> toJson() => {
    'day': day,
    'opensAt': opensAt,
    'closesAt': closesAt,
    'closed': closed,
  };
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
    id: _s(json['id']),
    createdAt: _dateOrNow(json['createdAt']),
    updatedAt: _dateOrNow(json['updatedAt']),
    fullName: _s(json['fullName']),
    phoneNumber: _s(json['phoneNumber']),
    email: _s(json['email']),
    role: _s(json['role']),
    status: _s(json['status']),
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
