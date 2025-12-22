class ServiceRemoveResponse {
  final bool status;
  final String? message;
  final SimpleData data;

  const ServiceRemoveResponse({
    required this.status,
    this.message,
    required this.data,
  });

  factory ServiceRemoveResponse.fromJson(Map<String, dynamic> json) {
    return ServiceRemoveResponse(
      status: json['status'] ?? false,
      message: json['message'] as String?,
      data: SimpleData.fromJson(
        (json['data'] ?? {}) as Map<String, dynamic>,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data.toJson(),
    };
  }
}

class SimpleData {
  final bool success;

  const SimpleData({
    required this.success,
  });

  factory SimpleData.fromJson(Map<String, dynamic> json) {
    return SimpleData(
      success: json['success'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
    };
  }
}
