class MaskedContactResponse {
  final bool status;
  final int code;
  final MaskedContactData data;

  MaskedContactResponse({
    required this.status,
    required this.code,
    required this.data,
  });

  factory MaskedContactResponse.fromJson(Map<String, dynamic> json) {
    return MaskedContactResponse(
      status: json['status'] as bool,
      code: json['code'] as int,
      data: MaskedContactData.fromJson(json['data']),
    );
  }
}

class MaskedContactData {
  final String maskedContact;
  final int waitSeconds;

  MaskedContactData({
    required this.maskedContact,
    required this.waitSeconds,
  });

  factory MaskedContactData.fromJson(Map<String, dynamic> json) {
    return MaskedContactData(
      maskedContact: json['maskedContact'] as String,
      waitSeconds: json['waitSeconds'] as int,
    );
  }
}
