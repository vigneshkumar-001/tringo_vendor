class SimVerifyResponse {
  final bool status;
  final int code;
  final SimData data;

  SimVerifyResponse({
    required this.status,
    required this.code,
    required this.data,
  });

  factory SimVerifyResponse.fromJson(Map<String, dynamic> json) {
    return SimVerifyResponse(
      status: json['status'] as bool,
      code: json['code'] as int,
      data: SimData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {'status': status, 'code': code, 'data': data.toJson()};
  }
}

class SimData {
  final String accessToken;
  final String refreshToken;
  final String role;
  final String sessionToken;
  final bool simVerified;
  final bool isNewOwner;

  SimData({
    required this.accessToken,
    required this.refreshToken,
    required this.role,
    required this.sessionToken,
    required this.simVerified,
    required this.isNewOwner,
  });

  factory SimData.fromJson(Map<String, dynamic> json) {
    return SimData(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      role: json['role'] as String,
      sessionToken: json['sessionToken'] as String,
      simVerified: json['simVerified'] as bool,
      isNewOwner: json['isNewOwner'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'role': role,
      'sessionToken': sessionToken,
      'simVerified': simVerified,
      'isNewOwner': isNewOwner,
    };
  }
}
