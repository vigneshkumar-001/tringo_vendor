class  OfflineShopModel  {
  final String sessionId;

  // required payload
  final String businessProfileId; // owner/businessProfileId
  final String type; // "service" or "product"

  final String categorySlug;
  final String subCategorySlug;

  final String englishName;
  final String tamilName;

  final String descriptionEn;
  final String descriptionTa;

  final String addressEn;
  final String addressTa;

  final double gpsLatitude;
  final double gpsLongitude;

  final String primaryPhone;
  final String alternatePhone;
  final String contactEmail;

  final bool doorDelivery;
  final String weeklyHours;

  // local images (offline)
  final String? ownerPhotoPath; // only for service
  final List<String?> shopPhotoPaths; // length 4 (sign/out/inside/inside)

  // sync results
  final String? shopId; // after push

  OfflineShopModel({
    required this.sessionId,
    required this.businessProfileId,
    required this.type,
    required this.categorySlug,
    required this.subCategorySlug,
    required this.englishName,
    required this.tamilName,
    required this.descriptionEn,
    required this.descriptionTa,
    required this.addressEn,
    required this.addressTa,
    required this.gpsLatitude,
    required this.gpsLongitude,
    required this.primaryPhone,
    required this.alternatePhone,
    required this.contactEmail,
    required this.doorDelivery,
    required this.weeklyHours,
    required this.ownerPhotoPath,
    required this.shopPhotoPaths,
    required this.shopId,
  });

  Map<String, dynamic> toJson() => {
    "sessionId": sessionId,
    "businessProfileId": businessProfileId,
    "type": type,
    "categorySlug": categorySlug,
    "subCategorySlug": subCategorySlug,
    "englishName": englishName,
    "tamilName": tamilName,
    "descriptionEn": descriptionEn,
    "descriptionTa": descriptionTa,
    "addressEn": addressEn,
    "addressTa": addressTa,
    "gpsLatitude": gpsLatitude,
    "gpsLongitude": gpsLongitude,
    "primaryPhone": primaryPhone,
    "alternatePhone": alternatePhone,
    "contactEmail": contactEmail,
    "doorDelivery": doorDelivery,
    "weeklyHours": weeklyHours,
    "ownerPhotoPath": ownerPhotoPath,
    "shopPhotoPaths": shopPhotoPaths,
    "shopId": shopId,
  };

  factory OfflineShopModel.fromJson(Map<String, dynamic> j) {
    final photos = (j["shopPhotoPaths"] as List?)?.map((e) => e?.toString()).toList() ?? [];
    while (photos.length < 4) photos.add(null);

    return OfflineShopModel(
      sessionId: j["sessionId"] ?? "",
      businessProfileId: j["businessProfileId"] ?? "",
      type: j["type"] ?? "product",
      categorySlug: j["categorySlug"] ?? "",
      subCategorySlug: j["subCategorySlug"] ?? "",
      englishName: j["englishName"] ?? "",
      tamilName: j["tamilName"] ?? "",
      descriptionEn: j["descriptionEn"] ?? "",
      descriptionTa: j["descriptionTa"] ?? "",
      addressEn: j["addressEn"] ?? "",
      addressTa: j["addressTa"] ?? "",
      gpsLatitude: (j["gpsLatitude"] as num?)?.toDouble() ?? 0.0,
      gpsLongitude: (j["gpsLongitude"] as num?)?.toDouble() ?? 0.0,
      primaryPhone: j["primaryPhone"] ?? "",
      alternatePhone: j["alternatePhone"] ?? "",
      contactEmail: j["contactEmail"] ?? "",
      doorDelivery: j["doorDelivery"] == true,
      weeklyHours: j["weeklyHours"] ?? "",
      ownerPhotoPath: j["ownerPhotoPath"],
      shopPhotoPaths: photos.take(4).toList(),
      shopId: j["shopId"],
    );
  }

  OfflineShopModel copyWith({
    String? businessProfileId,
    String? shopId,
    String? ownerPhotoPath,
    List<String?>? shopPhotoPaths,
  }) {
    return OfflineShopModel(
      sessionId: sessionId,
      businessProfileId: businessProfileId ?? this.businessProfileId,
      type: type,
      categorySlug: categorySlug,
      subCategorySlug: subCategorySlug,
      englishName: englishName,
      tamilName: tamilName,
      descriptionEn: descriptionEn,
      descriptionTa: descriptionTa,
      addressEn: addressEn,
      addressTa: addressTa,
      gpsLatitude: gpsLatitude,
      gpsLongitude: gpsLongitude,
      primaryPhone: primaryPhone,
      alternatePhone: alternatePhone,
      contactEmail: contactEmail,
      doorDelivery: doorDelivery,
      weeklyHours: weeklyHours,
      ownerPhotoPath: ownerPhotoPath ?? this.ownerPhotoPath,
      shopPhotoPaths: shopPhotoPaths ?? this.shopPhotoPaths,
      shopId: shopId ?? this.shopId,
    );
  }
}
