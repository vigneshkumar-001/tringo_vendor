class VerificationResponse {
  final bool status;
  final int code;
  final VerificationData data;

  VerificationResponse({
    required this.status,
    required this.code,
    required this.data,
  });

  factory VerificationResponse.fromJson(Map<String, dynamic> json) {
    return VerificationResponse(
      status: json['status'] as bool,
      code: json['code'] as int,
      data: VerificationData.fromJson(json['data']),
    );
  }
}

class VerificationData {
  final bool verified;
  final String phoneNumber;
  final String verificationToken;
  final DateTime expiresAt;

  VerificationData({
    required this.verified,
    required this.phoneNumber,
    required this.verificationToken,
    required this.expiresAt,
  });

  factory VerificationData.fromJson(Map<String, dynamic> json) {
    return VerificationData(
      verified: json['verified'] as bool,
      phoneNumber: json['phoneNumber'] as String,
      verificationToken: json['verificationToken'] as String,
      expiresAt: DateTime.parse(json['expiresAt']),
    );
  }
}
