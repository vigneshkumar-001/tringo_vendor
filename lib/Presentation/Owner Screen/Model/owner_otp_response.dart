class OwnerOtpResponse {
  final bool status;
  final int code;
  final OwnerOtpOtpData? data;

  OwnerOtpResponse({required this.status, required this.code, this.data});

  factory OwnerOtpResponse.fromJson(Map<String, dynamic> json) {
    return OwnerOtpResponse(
      status: json['status'] ?? false,
      code: json['code'] ?? 0,
      data:
          json['data'] != null ? OwnerOtpOtpData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'status': status, 'code': code, 'data': data?.toJson()};
  }
}

class OwnerOtpOtpData {
  final String ownerPhoneNumber;
  final String verificationToken;
  final String expiresAt;

  final bool verified;

  OwnerOtpOtpData({
    required this.expiresAt,

    required this.ownerPhoneNumber,
    required this.verificationToken,
    required this.verified,
  });

  factory OwnerOtpOtpData.fromJson(Map<String, dynamic> json) {
    return OwnerOtpOtpData(
      verificationToken: json['verificationToken'] ?? '',
      ownerPhoneNumber: json['ownerPhoneNumber'] ?? '',
      expiresAt: json['expiresAt'] ?? '',

      verified: json['verified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ownerPhoneNumber': ownerPhoneNumber,
      'verificationToken': verificationToken,

      'expiresAt': expiresAt,
      'verified': verified,
    };
  }
}
