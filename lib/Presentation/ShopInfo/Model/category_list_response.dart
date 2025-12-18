class  CategoryListResponse  {
  final bool status;
  final List<ShopCategoryListData> data;

  CategoryListResponse({required this.status, required this.data});

  factory CategoryListResponse.fromJson(Map<String, dynamic> json) {
    return CategoryListResponse(
      status: json['status'] ?? false,
      data:
      (json['data'] as List<dynamic>?)
          ?.map((e) => ShopCategoryListData.fromJson(e))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'data': data.map((e) => e.toJson()).toList(),
  };
}

class ShopCategoryListData {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String name;
  final String slug;
  final String type;
  final int displayOrder;
  final String? parentId;
  final List<ShopCategoryListData> children;

  ShopCategoryListData({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.name,
    required this.slug,
    required this.type,
    required this.displayOrder,
    this.parentId,
    this.children = const [],
  });

  factory ShopCategoryListData.fromJson(Map<String, dynamic> json) {
    return ShopCategoryListData(
      id: json['id'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      name: json['name'],
      slug: json['slug'],
      type: json['type'],
      displayOrder: json['displayOrder'] ?? 0,
      parentId: json['parentId'],
      children:
      (json['children'] as List<dynamic>?)
          ?.map((e) => ShopCategoryListData.fromJson(e))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'name': name,
    'slug': slug,
    'type': type,
    'displayOrder': displayOrder,
    'parentId': parentId,
    'children': children.map((e) => e.toJson()).toList(),
  };
}
