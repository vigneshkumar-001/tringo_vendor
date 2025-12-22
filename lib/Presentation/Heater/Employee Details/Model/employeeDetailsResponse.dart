class EmployeeDetailsResponse {
  final bool status;
  final EmployeeDetailsData data;

  EmployeeDetailsResponse({required this.status, required this.data});

  factory EmployeeDetailsResponse.fromJson(Map<String, dynamic> json) {
    return EmployeeDetailsResponse(
      status: json['status'] == true,
      data: EmployeeDetailsData.fromJson(json['data'] ?? {}),
    );
  }
}

class EmployeeDetailsData {
  final Employee employee;
  final Summary summary;
  final ShopsAndServices shopsAndServices;

  EmployeeDetailsData({
    required this.employee,
    required this.summary,
    required this.shopsAndServices,
  });

  factory EmployeeDetailsData.fromJson(Map<String, dynamic> json) {
    return EmployeeDetailsData(
      employee: Employee.fromJson(json['employee'] ?? {}),
      summary: Summary.fromJson(json['summary'] ?? {}),
      shopsAndServices: ShopsAndServices.fromJson(json['shopsAndServices'] ?? {}),
    );
  }
}

class Employee {
  final String id;
  final String employeeCode;
  final String name;
  final String phoneNumber;
  final String email;
  final String? avatarUrl;
  final bool isActive;
  final String emergencyContactName;
  final String emergencyContactRelationship;
  final String emergencyContactPhone;
  final String aadharNumber;
  final String? aadharDocumentUrl;

  Employee({
    required this.id,
    required this.employeeCode,
    required this.name,
    required this.phoneNumber,
    required this.email,
    this.avatarUrl,
    required this.isActive,
    required this.emergencyContactName,
    required this.emergencyContactRelationship,
    required this.emergencyContactPhone,
    required this.aadharNumber,
    this.aadharDocumentUrl,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'] ?? '',
      employeeCode: json['employeeCode'] ?? '',
      name: json['name'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      email: json['email'] ?? '',
      avatarUrl: json['avatarUrl'],
      isActive: json['isActive'] == true,
      emergencyContactName: json['emergencyContactName'] ?? '',
      emergencyContactRelationship: json['emergencyContactRelationship'] ?? '',
      emergencyContactPhone: json['emergencyContactPhone'] ?? '',
      aadharNumber: json['aadharNumber'] ?? '',
      aadharDocumentUrl: json['aadharDocumentUrl'],
    );
  }
}

class Summary {
  final int collectionCount;
  final int totalAmount;

  // ✅ NEW
  final int freemiumCount;
  final int premiumCount;
  final int premiumProCount;

  Summary({
    required this.collectionCount,
    required this.totalAmount,
    required this.freemiumCount,
    required this.premiumCount,
    required this.premiumProCount,
  });

  factory Summary.fromJson(Map<String, dynamic> json) {
    return Summary(
      collectionCount: json['collectionCount'] ?? 0,
      totalAmount: json['totalAmount'] ?? 0,

      // ✅ NEW
      freemiumCount: json['freemiumCount'] ?? 0,
      premiumCount: json['premiumCount'] ?? 0,
      premiumProCount: json['premiumProCount'] ?? 0,
    );
  }
}

class ShopsAndServices {
  final List<ShopItem> items;
  final int page;
  final int limit;

  ShopsAndServices({
    required this.items,
    required this.page,
    required this.limit,
  });

  factory ShopsAndServices.fromJson(Map<String, dynamic> json) {
    final list = (json['items'] as List?) ?? [];
    return ShopsAndServices(
      items: list.map((e) => ShopItem.fromJson(e as Map<String, dynamic>)).toList(),
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
    );
  }
}

class ShopItem {
  final String shopId;
  final String englishName;
  final String tamilName;
  final String typeLabel;

  final String addressEn;
  final String addressTa;

  // ✅ NEW
  final String city;
  final String state;
  final String country;
  final String postalCode;
  final String primaryPhone;

  final String category;
  final String subCategory;
  final String categoryLabel;
  final String subCategoryLabel;
  final String breadcrumb;

  final String? imageUrl;
  final DateTime createdAt;
  final String businessProfileId;
  final String businessType;

  final String? planType;

  // ✅ NEW
  final String? planCategory;

  final String? planEndsAt;

  ShopItem({
    required this.shopId,
    required this.englishName,
    required this.tamilName,
    required this.typeLabel,
    required this.addressEn,
    required this.addressTa,

    required this.city,
    required this.state,
    required this.country,
    required this.postalCode,
    required this.primaryPhone,

    required this.category,
    required this.subCategory,
    required this.categoryLabel,
    required this.subCategoryLabel,
    required this.breadcrumb,
    this.imageUrl,
    required this.createdAt,
    required this.businessProfileId,
    required this.businessType,
    this.planType,
    this.planCategory,
    this.planEndsAt,
  });

  factory ShopItem.fromJson(Map<String, dynamic> json) {
    final createdAtStr = (json['createdAt'] ?? '') as String;

    return ShopItem(
      shopId: json['shopId'] ?? '',
      englishName: json['englishName'] ?? '',
      tamilName: json['tamilName'] ?? '',
      typeLabel: json['typeLabel'] ?? '',

      addressEn: json['addressEn'] ?? '',
      addressTa: json['addressTa'] ?? '',

      //  NEW
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      country: json['country'] ?? '',
      postalCode: json['postalCode'] ?? '',
      primaryPhone: json['primaryPhone'] ?? '',

      category: json['category'] ?? '',
      subCategory: json['subCategory'] ?? '',
      categoryLabel: json['categoryLabel'] ?? '',
      subCategoryLabel: json['subCategoryLabel'] ?? '',
      breadcrumb: json['breadcrumb'] ?? '',

      imageUrl: json['imageUrl'],
      createdAt: createdAtStr.isNotEmpty ? DateTime.parse(createdAtStr) : DateTime.now(),

      businessProfileId: json['businessProfileId'] ?? '',
      businessType: json['businessType'] ?? '',

      planType: json['planType'],
      planCategory: json['planCategory'], //  NEW
      planEndsAt: json['planEndsAt'],
    );
  }
}


// class EmployeeDetailsResponse {
//   final bool status;
//   final EmployeeDetailsData data;
//
//   EmployeeDetailsResponse({required this.status, required this.data});
//
//   factory EmployeeDetailsResponse.fromJson(Map<String, dynamic> json) {
//     return EmployeeDetailsResponse(
//       status: json['status'] == true,
//       data: EmployeeDetailsData.fromJson(json['data'] ?? {}),
//     );
//   }
// }
//
// class EmployeeDetailsData {
//   final Employee employee;
//   final Summary summary;
//   final ShopsAndServices shopsAndServices;
//
//   EmployeeDetailsData({
//     required this.employee,
//     required this.summary,
//     required this.shopsAndServices,
//   });
//
//   factory EmployeeDetailsData.fromJson(Map<String, dynamic> json) {
//     return EmployeeDetailsData(
//       employee: Employee.fromJson(json['employee'] ?? {}),
//       summary: Summary.fromJson(json['summary'] ?? {}),
//       shopsAndServices: ShopsAndServices.fromJson(
//         json['shopsAndServices'] ?? {},
//       ),
//     );
//   }
// }
//
// class Employee {
//   final String id;
//   final String employeeCode;
//   final String name;
//   final String phoneNumber;
//   final String email;
//   final String? avatarUrl;
//   final bool isActive;
//   final String emergencyContactName;
//   final String emergencyContactRelationship;
//   final String emergencyContactPhone;
//   final String aadharNumber;
//   final String? aadharDocumentUrl;
//
//   Employee({
//     required this.id,
//     required this.employeeCode,
//     required this.name,
//     required this.phoneNumber,
//     required this.email,
//     this.avatarUrl,
//     required this.isActive,
//     required this.emergencyContactName,
//     required this.emergencyContactRelationship,
//     required this.emergencyContactPhone,
//     required this.aadharNumber,
//     this.aadharDocumentUrl,
//   });
//
//   factory Employee.fromJson(Map<String, dynamic> json) {
//     return Employee(
//       id: json['id'] ?? '',
//       employeeCode: json['employeeCode'] ?? '',
//       name: json['name'] ?? '',
//       phoneNumber: json['phoneNumber'] ?? '',
//       email: json['email'] ?? '',
//       avatarUrl: json['avatarUrl'],
//       isActive: json['isActive'] ?? false,
//       emergencyContactName: json['emergencyContactName'] ?? '',
//       emergencyContactRelationship: json['emergencyContactRelationship'] ?? '',
//       emergencyContactPhone: json['emergencyContactPhone'] ?? '',
//       aadharNumber: json['aadharNumber'] ?? '',
//       aadharDocumentUrl: json['aadharDocumentUrl'],
//     );
//   }
// }
//
// class Summary {
//   final int collectionCount;
//   final int totalAmount;
//
//   Summary({required this.collectionCount, required this.totalAmount});
//
//   factory Summary.fromJson(Map<String, dynamic> json) {
//     return Summary(
//       collectionCount: json['collectionCount'] ?? 0,
//       totalAmount: json['totalAmount'] ?? 0,
//     );
//   }
// }
//
// class ShopsAndServices {
//   final List<ShopItem> items;
//   final int page;
//   final int limit;
//
//   ShopsAndServices({
//     required this.items,
//     required this.page,
//     required this.limit,
//   });
//
//   factory ShopsAndServices.fromJson(Map<String, dynamic> json) {
//     final list = json['items'] as List? ?? [];
//
//     return ShopsAndServices(
//       items: list.map((e) => ShopItem.fromJson(e)).toList(),
//       page: json['page'] ?? 1,
//       limit: json['limit'] ?? 10,
//     );
//   }
// }
//
// class ShopItem {
//   final String shopId;
//   final String englishName;
//   final String tamilName;
//   final String typeLabel;
//   final String addressEn;
//   final String addressTa;
//   final String category;
//   final String subCategory;
//   final String categoryLabel;
//   final String subCategoryLabel;
//   final String breadcrumb;
//   final String? imageUrl;
//   final DateTime createdAt;
//   final String businessProfileId;
//   final String businessType;
//   final String? planType;
//   final String? planEndsAt;
//
//   ShopItem({
//     required this.shopId,
//     required this.englishName,
//     required this.tamilName,
//     required this.typeLabel,
//     required this.addressEn,
//     required this.addressTa,
//     required this.category,
//     required this.subCategory,
//     required this.categoryLabel,
//     required this.subCategoryLabel,
//     required this.breadcrumb,
//     this.imageUrl,
//     required this.createdAt,
//     required this.businessProfileId,
//     required this.businessType,
//     this.planType,
//     this.planEndsAt,
//   });
//
//   factory ShopItem.fromJson(Map<String, dynamic> json) {
//     return ShopItem(
//       shopId: json['shopId'] ?? '',
//       englishName: json['englishName'] ?? '',
//       tamilName: json['tamilName'] ?? '',
//       typeLabel: json['typeLabel'] ?? '',
//       category: json['category'] ?? '',
//       addressEn: json['addressEn'] ?? '',
//       addressTa: json['addressTa'] ?? '',
//       subCategory: json['subCategory'] ?? '',
//       categoryLabel: json['categoryLabel'] ?? '',
//       subCategoryLabel: json['subCategoryLabel'] ?? '',
//       breadcrumb: json['breadcrumb'] ?? '',
//       imageUrl: json['imageUrl'],
//       createdAt:
//           json['createdAt'] != null && json['createdAt'].isNotEmpty
//               ? DateTime.parse(json['createdAt'])
//               : DateTime.now(), // or handle differently
//       businessProfileId: json['businessProfileId'] ?? '',
//       businessType: json['businessType'] ?? '',
//       planType: json['planType'],
//       planEndsAt: json['planEndsAt'],
//     );
//   }
// }
