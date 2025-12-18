import 'dart:convert';

class ShopRootResponse {
  final bool status;
  final List<Shop> data;

  ShopRootResponse({required this.status, required this.data});

  factory ShopRootResponse.fromJson(Map<String, dynamic> json) {
    return ShopRootResponse(
      status: json["status"] ?? false,
      data:
      (json["data"] as List<dynamic>?)
          ?.map((x) => Shop.fromJson(x as Map<String, dynamic>))
          .toList() ??
          [],
    );
  }
}

// ───────────────────────── SHOP ─────────────────────────

class Shop {
  final String? shopId;
  final String? shopEnglishName;
  final String? shopTamilName;
  final String? shopDescriptionEn;
  final String? shopDescriptionTa;
  final String? shopAddressEn;
  final String? shopAddressTa;
  final String? shopCity;
  final String? shopState;
  final String? shopCountry;
  final String? shopPostalCode;
  final String? shopGpsLatitude;
  final String? shopGpsLongitude;
  final List<ShopWeeklyHour> shopWeeklyHours;

  final String? category;
  final String? subCategory;
  final String? shopKind;
  final String? shopPhone;
  final String? shopWhatsapp;
  final String? shopContactEmail;
  final bool? shopDoorDelivery;
  final bool? shopIsTrusted;

  /// API sends 0 / 0.0 → we safely convert using num?.toInt()
  final int? shopRating;
  final int? shopReviewCount;

  /// NEW: shopImages from API
  final List<ShopImage> shopImages;

  final List<Product> products;
  final List<Service> services;
  final List<Review> reviews;

  Shop({
    this.shopId,
    this.shopEnglishName,
    this.shopTamilName,
    this.shopDescriptionEn,
    this.shopDescriptionTa,
    this.shopAddressEn,
    this.shopAddressTa,
    this.shopCity,
    this.shopState,
    this.shopCountry,
    this.shopPostalCode,
    this.shopGpsLatitude,
    this.shopGpsLongitude,
    this.shopWeeklyHours = const [],

    this.category,
    this.subCategory,
    this.shopKind,
    this.shopPhone,
    this.shopWhatsapp,
    this.shopContactEmail,
    this.shopDoorDelivery,
    this.shopIsTrusted,
    this.shopRating,
    this.shopReviewCount,
    required this.shopImages,
    required this.products,
    required this.services,
    required this.reviews,
  });

  factory Shop.fromJson(Map<String, dynamic> json) {
    final weeklyJson = json['shopWeeklyHours'] ?? json['weeklyHours'];
    return Shop(
      shopId: json["shopId"] as String?,
      shopEnglishName: json["shopEnglishName"] as String?,
      shopTamilName: json["shopTamilName"] as String?,
      shopDescriptionEn: json["shopDescriptionEn"] as String?,
      shopDescriptionTa: json["shopDescriptionTa"] as String?,
      shopAddressEn: json["shopAddressEn"] as String?,
      shopAddressTa: json["shopAddressTa"] as String?,
      shopCity: json["shopCity"] as String?,
      shopState: json["shopState"] as String?,
      shopCountry: json["shopCountry"] as String?,
      shopPostalCode: json["shopPostalCode"] as String?,
      shopGpsLatitude: json["shopGpsLatitude"] as String?,
      shopGpsLongitude: json["shopGpsLongitude"] as String?,

      shopWeeklyHours:
      (json['weeklyHours'] as List<dynamic>?)
          ?.map((e) => ShopWeeklyHour.fromJson(e as Map<String, dynamic>))
          .toList() ??
          const [],
      category: json["category"] as String?,
      subCategory: json["subCategory"] as String?,
      shopKind: json["shopKind"] as String?,
      shopPhone: json["shopPhone"] as String?,
      shopWhatsapp: json["shopWhatsapp"] as String?,
      shopContactEmail: json["shopContactEmail"] as String?,
      shopDoorDelivery: json["shopDoorDelivery"] as bool?,
      shopIsTrusted: json["shopIsTrusted"] as bool?,

      // 🔹 avoids "type 'double' is not a subtype of type 'int?'"
      shopRating: (json["shopRating"] as num?)?.toInt(),
      shopReviewCount: (json["shopReviewCount"] as num?)?.toInt(),

      // 🔹 shopImages
      shopImages:
      (json["shopImages"] as List<dynamic>?)
          ?.map((x) => ShopImage.fromJson(x as Map<String, dynamic>))
          .toList() ??
          [],

      products:
      (json["products"] as List<dynamic>?)
          ?.map((x) => Product.fromJson(x as Map<String, dynamic>))
          .toList() ??
          [],
      services:
      (json["services"] as List<dynamic>?)
          ?.map((x) => Service.fromJson(x as Map<String, dynamic>))
          .toList() ??
          [],
      reviews:
      (json["reviews"] as List<dynamic>?)
          ?.map((x) => Review.fromJson(x as Map<String, dynamic>))
          .toList() ??
          [],
    );
  }
}

// ───────────────────────── SHOP IMAGE ─────────────────────────

class ShopImage {
  final String? id;
  final String? type;
  final String? url;
  final int? displayOrder;

  ShopImage({this.id, this.type, this.url, this.displayOrder});

  factory ShopImage.fromJson(Map<String, dynamic> json) {
    return ShopImage(
      id: json["id"] as String?,
      type: json["type"] as String?,
      url: json["url"] as String?,
      displayOrder: (json["displayOrder"] as num?)?.toInt(),
    );
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
// ───────────────────────── PRODUCT ─────────────────────────

class Product {
  final String? productId;
  final String? createdAt;
  final String? updatedAt;
  final String? category;
  final String? subCategory;
  final String? categorySlug;
  final String? subCategorySlug;
  final String? englishName;
  final String? tamilName;
  final int? price;
  final int? offerPrice;
  final bool? isFeatured;
  final String? offerLabel;
  final String? offerValue;
  final String? description;
  final bool? doorDelivery;
  final int? rating;
  final int? ratingCount;
  final List<Media> media;

  Product({
    this.productId,
    this.createdAt,
    this.updatedAt,
    this.category,
    this.subCategory,
    this.categorySlug,
    this.subCategorySlug,
    this.englishName,
    this.tamilName,
    this.price,
    this.offerPrice,
    this.isFeatured,
    this.offerLabel,
    this.offerValue,
    this.description,
    this.doorDelivery,
    this.rating,
    this.ratingCount,
    required this.media,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productId: json["productId"] as String?,
      createdAt: json["createdAt"] as String?,
      updatedAt: json["updatedAt"] as String?,
      category: json["category"] as String?,
      subCategory: json["subCategory"] as String?,
      categorySlug: json["categorySlug"] as String?,
      subCategorySlug: json["subCategorySlug"] as String?,
      englishName: json["englishName"] as String?,
      tamilName: json["tamilName"] as String?,
      price: (json["price"] as num?)?.toInt(),
      offerPrice: (json["offerPrice"] as num?)?.toInt(),
      isFeatured: json["isFeatured"] as bool?,
      offerLabel: json["offerLabel"] as String?,
      offerValue: json["offerValue"] as String?,
      description: json["description"] as String?,
      doorDelivery: json["doorDelivery"] as bool?,
      rating: (json["rating"] as num?)?.toInt(),
      ratingCount: (json["ratingCount"] as num?)?.toInt(),
      media:
      (json["media"] as List<dynamic>?)
          ?.map((x) => Media.fromJson(x as Map<String, dynamic>))
          .toList() ??
          [],
    );
  }
}

// ───────────────────────── SERVICE ─────────────────────────

class Service {
  final String? serviceId;
  final String? createdAt;
  final String? updatedAt;
  final String? category;
  final String? subCategory;
  final String? englishName;
  final String? tamilName;
  final int? startsAt;
  final int? offerPrice;
  final int? durationMinutes;
  final String? offerLabel;
  final String? offerValue;
  final String? description;
  final int? rating;
  final int? ratingCount;
  final String? status;

  final List<dynamic> features;
  final List<Media> media;

  Service({
    this.serviceId,
    this.createdAt,
    this.updatedAt,
    this.category,
    this.subCategory,
    this.englishName,
    this.tamilName,
    this.startsAt,
    this.offerPrice,
    this.durationMinutes,
    this.offerLabel,
    this.offerValue,
    this.description,
    this.rating,
    this.ratingCount,
    this.status,
    required this.features,
    required this.media,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      serviceId: json["serviceId"] as String?,
      createdAt: json["createdAt"] as String?,
      updatedAt: json["updatedAt"] as String?,
      category: json["category"] as String?,
      subCategory: json["subCategory"] as String?,
      englishName: json["englishName"] as String?,
      tamilName: json["tamilName"] as String?,
      startsAt: (json["startsAt"] as num?)?.toInt(),
      offerPrice: (json["offerPrice"] as num?)?.toInt(),
      durationMinutes: (json["durationMinutes"] as num?)?.toInt(),
      offerLabel: json["offerLabel"] as String?,
      offerValue: json["offerValue"] as String?,
      description: json["description"] as String?,
      rating: (json["rating"] as num?)?.toInt(),
      ratingCount: (json["ratingCount"] as num?)?.toInt(),
      status: json["status"] as String?,
      features: json["features"] ?? [],
      media:
      (json["media"] as List<dynamic>?)
          ?.map((x) => Media.fromJson(x as Map<String, dynamic>))
          .toList() ??
          [],
    );
  }
}

// ───────────────────────── MEDIA ─────────────────────────

class Media {
  final String? id;
  final String? url;
  final String? type;
  final int? displayOrder;

  Media({this.id, this.url, this.type, this.displayOrder});

  factory Media.fromJson(Map<String, dynamic> json) {
    return Media(
      id: json["id"] as String?,
      url: json["url"] as String?,
      type: json["type"] as String?,             // 👈 NEW
      displayOrder: (json["displayOrder"] as num?)?.toInt(),
    );
  }
}


// ───────────────────────── REVIEW ─────────────────────────

class Review {
  Review();

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review();
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