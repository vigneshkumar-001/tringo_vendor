class SendMessageResponse {
  final bool status;
  final Data data;

  SendMessageResponse({required this.status, required this.data});

  factory SendMessageResponse.fromJson(Map<String, dynamic> json) {
    return SendMessageResponse(
      status: json['status'] ?? false,
      data: Data.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {'status': status, 'data': data.toJson()};
  }
}

class Data {
  final bool ok;

  Data({required this.ok});

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(ok: json['ok'] ?? false);
  }

  Map<String, dynamic> toJson() {
    return {'ok': ok};
  }
}
