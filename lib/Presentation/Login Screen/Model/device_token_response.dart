class DeviceTokenRequest {
  final String fcmToken;
  final String platform; // "android" | "ios"
  final String? deviceId;

  DeviceTokenRequest({
    required this.fcmToken,
    required this.platform,
    this.deviceId,
  });

  Map<String, dynamic> toJson() => {
    "fcmToken": fcmToken,
    "platform": platform,
    if (deviceId != null && deviceId!.trim().isNotEmpty) "deviceId": deviceId,
  };
}

class DeviceTokenResponse {
  final bool status;
  final int code;
  final bool saved;

  DeviceTokenResponse({
    required this.status,
    required this.code,
    required this.saved,
  });

  factory DeviceTokenResponse.fromJson(Map<String, dynamic> json) {
    final data = (json["data"] is Map<String, dynamic>)
        ? (json["data"] as Map<String, dynamic>)
        : <String, dynamic>{};

    return DeviceTokenResponse(
      status: json["status"] == true,
      code: (json["code"] is int) ? json["code"] as int : int.tryParse("${json["code"]}") ?? 0,
      saved: data["saved"] == true,
    );
  }
}