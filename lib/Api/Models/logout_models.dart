class LogoutRequest {
  final String refreshToken;
  final String? sessionToken;

  const LogoutRequest({required this.refreshToken, this.sessionToken});

  Map<String, dynamic> toJson() => {
    'refreshToken': refreshToken,
    if (sessionToken != null && sessionToken!.trim().isNotEmpty)
      'sessionToken': sessionToken,
  };
}

class LogoutResponse {
  final bool status;
  final int code;
  final LogoutData? data;

  const LogoutResponse({required this.status, required this.code, this.data});

  factory LogoutResponse.fromJson(Map<String, dynamic> json) {
    return LogoutResponse(
      status: json['status'] == true,
      code: (json['code'] ?? 0) as int,
      data:
          json['data'] == null
              ? null
              : LogoutData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'code': code,
    'data': data?.toJson(),
  };
}

class LogoutData {
  final bool success;

  const LogoutData({required this.success});

  factory LogoutData.fromJson(Map<String, dynamic> json) {
    return LogoutData(success: json['success'] == true);
  }

  Map<String, dynamic> toJson() => {'success': success};
}
