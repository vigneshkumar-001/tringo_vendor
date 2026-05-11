class ShopNumberOtpResponse {
  final bool status;
  final int code;
  final PhoneVerifyData? data;

  ShopNumberOtpResponse({
    required this.status,
    required this.code,
    this.data,
  });

  factory ShopNumberOtpResponse.fromJson(Map<String, dynamic> json) {
    return ShopNumberOtpResponse(
      status: json['status'] == true,
      code: _asInt(json['code']),
      data: json['data'] is Map
          ? PhoneVerifyData.fromJson(Map<String, dynamic>.from(json['data']))
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status,
        'code': code,
        'data': data?.toJson(),
      };
}

class PhoneVerifyData {
  final bool verified;
  final String phoneNumber;
  final String verificationToken;
  final DateTime? expiresAt;
  final bool hasWhatsapp;

  PhoneVerifyData({
    required this.verified,
    required this.phoneNumber,
    required this.verificationToken,
    required this.expiresAt,
    required this.hasWhatsapp,
  });

  factory PhoneVerifyData.fromJson(Map<String, dynamic> json) {
    return PhoneVerifyData(
      verified: json['verified'] == true,
      phoneNumber: (json['phoneNumber'] ?? '').toString(),
      verificationToken: (json['verificationToken'] ?? '').toString(),
      expiresAt: _tryParseDate(json['expiresAt']),
      hasWhatsapp: json['hasWhatsapp'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
        'verified': verified,
        'phoneNumber': phoneNumber,
        'verificationToken': verificationToken,
        'expiresAt': expiresAt?.toUtc().toIso8601String(),
        'hasWhatsapp': hasWhatsapp,
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
