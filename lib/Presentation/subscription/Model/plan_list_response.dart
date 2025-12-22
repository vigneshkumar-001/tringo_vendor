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
class PlanModel {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String title;
  final String type;
  final String price;
  final int durationDays;
  final List<String> features;

  PlanModel({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.title,
    required this.type,
    required this.price,
    required this.durationDays,
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
      features: (json['features'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
    );
  }
}
