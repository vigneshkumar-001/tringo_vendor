class OtpLoginResponse {
  final bool status;
  final int code;
  final OtpLoginData? data;

  OtpLoginResponse({
    required this.status,
    required this.code,
    this.data,
  });

  factory OtpLoginResponse.fromJson(Map<String, dynamic> json) {
    return OtpLoginResponse(
      status: json['status'] == true,
      code: (json['code'] ?? 0) as int,
      data: json['data'] == null
          ? null
          : OtpLoginData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'code': code,
    'data': data?.toJson(),
  };
}

class OtpLoginData {
  final String? loginMethod;     // "OTP"
  final String? nextStep;        // "VERIFY_OTP"
  final String? maskedContact;   // "***1113"
  final int? waitSeconds;        // 30
  final String? accessToken;     // null before verify
  final String? refreshToken;    // null before verify
  final String? role;            // null before verify
  final String? sessionToken;    // null if you don't use it
  final bool simVerified;        // false
  final bool? isNewOwner;        // null

  OtpLoginData({
    this.loginMethod,
    this.nextStep,
    this.maskedContact,
    this.waitSeconds,
    this.accessToken,
    this.refreshToken,
    this.role,
    this.sessionToken,
    required this.simVerified,
    this.isNewOwner,
  });

  factory OtpLoginData.fromJson(Map<String, dynamic> json) {
    return OtpLoginData(
      loginMethod: json['loginMethod'] as String?,
      nextStep: json['nextStep'] as String?,
      maskedContact: json['maskedContact'] as String?,
      waitSeconds: json['waitSeconds'] is int
          ? json['waitSeconds'] as int
          : int.tryParse('${json['waitSeconds']}'),
      accessToken: json['accessToken'] as String?,
      refreshToken: json['refreshToken'] as String?,
      role: json['role'] as String?,
      sessionToken: json['sessionToken'] as String?,
      simVerified: json['simVerified'] == true,
      isNewOwner: json['isNewOwner'] as bool?,
    );
  }

  Map<String, dynamic> toJson() => {
    'loginMethod': loginMethod,
    'nextStep': nextStep,
    'maskedContact': maskedContact,
    'waitSeconds': waitSeconds,
    'accessToken': accessToken,
    'refreshToken': refreshToken,
    'role': role,
    'sessionToken': sessionToken,
    'simVerified': simVerified,
    'isNewOwner': isNewOwner,
  };
}
