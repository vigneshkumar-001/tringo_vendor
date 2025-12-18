// -----------------------------------------------------------------------------
// ROOT RESPONSE
// -----------------------------------------------------------------------------
class ShopDetailsResponse {
  final bool status;
  final ShopData? data;

  ShopDetailsResponse({required this.status, required this.data});

  factory ShopDetailsResponse.fromJson(Map<String, dynamic> json) {
    return ShopDetailsResponse(
      status: json['status'] as bool? ?? false,
      data: json['data'] != null
          ? ShopData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

// -----------------------------------------------------------------------------
// SHOP DATA
// -----------------------------------------------------------------------------
class ShopData {
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

  final String? category;
  final String? subCategory;

  final String? shopKind;
  final String? shopPhone;
  final String? shopWhatsapp;
  final String? shopContactEmail;

  final bool? shopDoorDelivery;
  final bool? shopIsTrusted;

  final double? shopRating;
  final int? shopReviewCount;

  final List<ShopImage> shopImages;
  final List<Product> products;
  final List<ServiceItem> services;
  final List<dynamic> reviews;

  ShopData({
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

  factory ShopData.fromJson(Map<String, dynamic> json) {
    return ShopData(
      shopId: json['shopId'],
      shopEnglishName: json['shopEnglishName'],
      shopTamilName: json['shopTamilName'],
      shopDescriptionEn: json['shopDescriptionEn'],
      shopDescriptionTa: json['shopDescriptionTa'],
      shopAddressEn: json['shopAddressEn'],
      shopAddressTa: json['shopAddressTa'],
      shopCity: json['shopCity'],
      shopState: json['shopState'],
      shopCountry: json['shopCountry'],
      shopPostalCode: json['shopPostalCode'],
      shopGpsLatitude: json['shopGpsLatitude']?.toString(),
      shopGpsLongitude: json['shopGpsLongitude']?.toString(),

      category: json['category'],
      subCategory: json['subCategory'],

      shopKind: json['shopKind'],
      shopPhone: json['shopPhone'],
      shopWhatsapp: json['shopWhatsapp'],
      shopContactEmail: json['shopContactEmail'],

      shopDoorDelivery: json['shopDoorDelivery'] as bool? ?? false,
      shopIsTrusted: json['shopIsTrusted'] as bool? ?? false,

      shopRating: (json['shopRating'] as num?)?.toDouble(),
      shopReviewCount: (json['shopReviewCount'] as num?)?.toInt() ?? 0,

      shopImages: (json['shopImages'] as List<dynamic>? ?? [])
          .map((e) => ShopImage.fromJson(e))
          .toList(),

      products: (json['products'] as List<dynamic>? ?? [])
          .map((e) => Product.fromJson(e))
          .toList(),

      services: (json['services'] as List<dynamic>? ?? [])
          .map((e) => ServiceItem.fromJson(e))
          .toList(),

      reviews: json['reviews'] ?? [],
    );
  }
}

// -----------------------------------------------------------------------------
// SHOP IMAGE
// -----------------------------------------------------------------------------
class ShopImage {
  final String? id;
  final String? type;
  final String? url;
  final int? displayOrder;

  ShopImage({this.id, this.type, this.url, this.displayOrder});

  factory ShopImage.fromJson(Map<String, dynamic> json) {
    return ShopImage(
      id: json['id'],
      type: json['type'],
      url: json['url'],
      displayOrder: (json['displayOrder'] as num?)?.toInt(),
    );
  }
}

// -----------------------------------------------------------------------------
// PRODUCT
// -----------------------------------------------------------------------------
class Product {
  final String? productId;
  final String? createdAt;
  final String? updatedAt;
  final String? category;
  final String? subCategory;
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
  final List<ProductMedia> media;

  Product({
    this.productId,
    this.createdAt,
    this.updatedAt,
    this.category,
    this.subCategory,
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
      productId: json['productId'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      category: json['category'],
      subCategory: json['subCategory'],
      englishName: json['englishName'],
      tamilName: json['tamilName'],
      price: (json['price'] as num?)?.toInt(),
      offerPrice: (json['offerPrice'] as num?)?.toInt(),
      isFeatured: json['isFeatured'] ?? false,
      offerLabel: json['offerLabel'],
      offerValue: json['offerValue'],
      description: json['description'],
      doorDelivery: json['doorDelivery'] ?? false,
      rating: (json['rating'] as num?)?.toInt(),
      ratingCount: (json['ratingCount'] as num?)?.toInt(),

      media: (json['media'] as List<dynamic>? ?? [])
          .map((e) => ProductMedia.fromJson(e))
          .toList(),
    );
  }
}

// -----------------------------------------------------------------------------
// PRODUCT MEDIA
// -----------------------------------------------------------------------------
class ProductMedia {
  final String? id;
  final String? url;
  final int? displayOrder;

  ProductMedia({this.id, this.url, this.displayOrder});

  factory ProductMedia.fromJson(Map<String, dynamic> json) {
    return ProductMedia(
      id: json['id'],
      url: json['url'],
      displayOrder: (json['displayOrder'] as num?)?.toInt(),
    );
  }
}

// -----------------------------------------------------------------------------
// SERVICE ITEM
// -----------------------------------------------------------------------------
class ServiceItem {
  final String? serviceId;
  final String? createdAt;
  final String? updatedAt;
  final String? category;
  final String? subCategory;
  final String? englishName;
  final String? tamilName;
  final double? startsAt;       // 👈 changed to double?
  final double? offerPrice;
  final int? durationMinutes;
  final String? offerLabel;
  final String? offerValue;
  final String? description;
  final int? rating;
  final int? ratingCount;
  final String? status;

  final List<ServiceFeature> features;
  final List<ServiceMedia> media;

  ServiceItem({
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

  factory ServiceItem.fromJson(Map<String, dynamic> json) {
    return ServiceItem(
      serviceId: json['serviceId'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      category: json['category'],
      subCategory: json['subCategory'],
      englishName: json['englishName'],
      tamilName: json['tamilName'],
      startsAt: (json['startsAt'] as num?)?.toDouble(),
      offerPrice: (json['offerPrice'] as num?)?.toDouble(),
      durationMinutes: (json['durationMinutes'] as num?)?.toInt(),
      offerLabel: json['offerLabel'],
      offerValue: json['offerValue'],
      description: json['description'],
      rating: (json['rating'] as num?)?.toInt(),
      ratingCount: (json['ratingCount'] as num?)?.toInt(),
      status: json['status'],

      features: (json['features'] as List<dynamic>? ?? [])
          .map((e) => ServiceFeature.fromJson(e))
          .toList(),

      media: (json['media'] as List<dynamic>? ?? [])
          .map((e) => ServiceMedia.fromJson(e))
          .toList(),
    );
  }
}

// -----------------------------------------------------------------------------
// SERVICE FEATURE
// -----------------------------------------------------------------------------
class ServiceFeature {
  final String? id;
  final String? label;
  final String? value;
  final String? language;

  ServiceFeature({this.id, this.label, this.value, this.language});

  factory ServiceFeature.fromJson(Map<String, dynamic> json) {
    return ServiceFeature(
      id: json['id'],
      label: json['label'],
      value: json['value'],
      language: json['language'],
    );
  }
}

// -----------------------------------------------------------------------------
// SERVICE MEDIA
// -----------------------------------------------------------------------------
class ServiceMedia {
  final String? id;
  final String? url;
  final int? displayOrder;

  ServiceMedia({this.id, this.url, this.displayOrder});

  factory ServiceMedia.fromJson(Map<String, dynamic> json) {
    return ServiceMedia(
      id: json['id'],
      url: json['url'],
      displayOrder: (json['displayOrder'] as num?)?.toInt(),
    );
  }
}
