class LoginResponse {
  final bool status;
  final int code;
  final LoginData? data;

  LoginResponse({required this.status, required this.code, this.data});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      status: json['status'] ?? false,
      code: json['code'] ?? 0,
      data: json['data'] != null ? LoginData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'status': status, 'code': code, 'data': data?.toJson()};
  }
}

class LoginData {
  final String maskedContact;
  final int waitSeconds;

  LoginData({required this.maskedContact, required this.waitSeconds});

  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(
      maskedContact: json['maskedContact'] ?? '',
      waitSeconds: json['waitSeconds'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'maskedContact': maskedContact, 'waitSeconds': waitSeconds};
  }
}
