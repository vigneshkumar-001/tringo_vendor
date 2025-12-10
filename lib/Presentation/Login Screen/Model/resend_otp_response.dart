class ResendOtpResponse {
  final bool status;
  final int code;
  final OtpSendData? data;

  ResendOtpResponse({required this.status, required this.code, this.data});

  factory ResendOtpResponse.fromJson(Map<String, dynamic> json) {
    return ResendOtpResponse(
      status: json['status'] ?? false,
      code: json['code'] ?? 0,
      data: json['data'] != null ? OtpSendData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'status': status, 'code': code, 'data': data?.toJson()};
  }
}

class OtpSendData {
  final String maskedContact;
  final int waitSeconds;

  OtpSendData({required this.maskedContact, required this.waitSeconds});

  factory OtpSendData.fromJson(Map<String, dynamic> json) {
    return OtpSendData(
      maskedContact: json['maskedContact'] ?? '',
      waitSeconds: json['waitSeconds'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'maskedContact': maskedContact, 'waitSeconds': waitSeconds};
  }
}
