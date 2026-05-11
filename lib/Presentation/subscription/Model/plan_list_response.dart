class PlanListResponse {
  final bool status;
  final List<PlanModel> data;

  PlanListResponse({
    required this.status,
    required this.data,
  });

  factory PlanListResponse.fromJson(Map<String, dynamic> json) {
    return PlanListResponse(
      status: json['status'] ?? false,
      data: (json['data'] as List<dynamic>? ?? [])
          .map((e) => PlanModel.fromJson(e))
          .toList(),
    );
  }
}

class PlanFeature {
  final String key;
  final String label;
  final bool free;
  final bool premium;
  final int sort;

  PlanFeature({
    required this.key,
    required this.label,
    required this.free,
    required this.premium,
    required this.sort,
  });

  factory PlanFeature.fromJson(Map<String, dynamic> json) {
    return PlanFeature(
      key: (json['key'] ?? '').toString(),
      label: (json['label'] ?? '').toString(),
      free: json['free'] == true,
      premium: json['premium'] == true,
      sort: (json['sort'] is num) ? (json['sort'] as num).toInt() : 0,
    );
  }
}

class PlanModel {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String title;
  final String type;
  final String price;
  final int durationDays;
  final bool isBestValue;
  final List<PlanFeature> features;

  PlanModel({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.title,
    required this.type,
    required this.price,
    required this.durationDays,
    required this.isBestValue,
    required this.features,
  });

  factory PlanModel.fromJson(Map<String, dynamic> json) {
    return PlanModel(
      id: json['id'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      title: json['title'] ?? '',
      type: json['type'] ?? '',
      price: json['price'] ?? '0',
      durationDays: json['durationDays'] ?? 0,
      isBestValue: json['isBestValue'] == true,
      features: (json['features'] is List)
          ? (json['features'] as List)
              .whereType<Map<String, dynamic>>()
              .map(PlanFeature.fromJson)
              .toList()
          : const [],
    );
  }
}
