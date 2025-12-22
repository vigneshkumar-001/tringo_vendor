class PhoneVerificationResponse {
  final bool status;
  final int code;
  final PhoneVerificationData data;

  PhoneVerificationResponse({
    required this.status,
    required this.code,
    required this.data,
  });

  factory PhoneVerificationResponse.fromJson(Map<String, dynamic> json) {
    return PhoneVerificationResponse(
      status: json['status'] as bool,
      code: json['code'] as int,
      data: PhoneVerificationData.fromJson(json['data']),
    );
  }
}

class PhoneVerificationData {
  final bool verified;
  final String phoneNumber;
  final String verificationToken;
  final DateTime expiresAt;

  PhoneVerificationData({
    required this.verified,
    required this.phoneNumber,
    required this.verificationToken,
    required this.expiresAt,
  });

  factory PhoneVerificationData.fromJson(Map<String, dynamic> json) {
    return PhoneVerificationData(
      verified: json['verified'] as bool,
      phoneNumber: json['phoneNumber'] as String,
      verificationToken: json['verificationToken'] as String,
      expiresAt: DateTime.parse(json['expiresAt']),
    );
  }
}
