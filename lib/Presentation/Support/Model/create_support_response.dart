class CreateSupportResponse {
  final bool status;
  final SupportData data;

  CreateSupportResponse({
    required this.status,
    required this.data,
  });

  factory CreateSupportResponse.fromJson(Map<String, dynamic> json) {
    return CreateSupportResponse(
      status: json['status'] as bool,
      data: SupportData.fromJson(json['data']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'data': data.toJson(),
    };
  }
}
class SupportData {
  final String id;
  final String status;

  SupportData({
    required this.id,
    required this.status,
  });

  factory SupportData.fromJson(Map<String, dynamic> json) {
    return SupportData(
      id: json['id'] as String,
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
    };
  }
}
