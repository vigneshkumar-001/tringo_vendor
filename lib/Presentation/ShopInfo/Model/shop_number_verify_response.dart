class ShopNumberVerifyResponse {
  final bool status;
  final int code;
  final OtpInitData? data;

  ShopNumberVerifyResponse({
    required this.status,
    required this.code,
    this.data,
  });

  factory ShopNumberVerifyResponse.fromJson(Map<String, dynamic> json) {
    return ShopNumberVerifyResponse(
      status: json['status'] == true,
      code: _asInt(json['code']),
      data: json['data'] is Map
          ? OtpInitData.fromJson(Map<String, dynamic>.from(json['data']))
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'code': code,
    'data': data?.toJson(),
  };
}

class OtpInitData {
  final String maskedContact;
  final int waitSeconds;

  OtpInitData({
    required this.maskedContact,
    required this.waitSeconds,
  });

  factory OtpInitData.fromJson(Map<String, dynamic> json) {
    return OtpInitData(
      maskedContact: (json['maskedContact'] ?? '').toString(),
      waitSeconds: _asInt(json['waitSeconds']),
    );
  }

  Map<String, dynamic> toJson() => {
    'maskedContact': maskedContact,
    'waitSeconds': waitSeconds,
  };
}
int _asInt(dynamic v) {
  if (v == null) return 0;
  if (v is int) return v;
  return int.tryParse(v.toString()) ?? 0;
}

DateTime? _tryParseDate(dynamic v) {
  if (v == null) return null;
  return DateTime.tryParse(v.toString());
}

