class EmployeeChangeNumber {
  final bool status;
  final int code;
  final OtpWaitData data;

  const EmployeeChangeNumber({
    required this.status,
    required this.code,
    required this.data,
  });

  factory EmployeeChangeNumber.fromJson(Map<String, dynamic> json) {
    return EmployeeChangeNumber(
      status: json['status'] as bool,
      code: (json['code'] as num).toInt(),
      data: OtpWaitData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'code': code,
    'data': data.toJson(),
  };

  EmployeeChangeNumber copyWith({
    bool? status,
    int? code,
    OtpWaitData? data,
  }) {
    return EmployeeChangeNumber(
      status: status ?? this.status,
      code: code ?? this.code,
      data: data ?? this.data,
    );
  }
}

class OtpWaitData {
  final String maskedContact;
  final int waitSeconds;

  const OtpWaitData({
    required this.maskedContact,
    required this.waitSeconds,
  });

  factory OtpWaitData.fromJson(Map<String, dynamic> json) {
    return OtpWaitData(
      maskedContact: (json['maskedContact'] ?? '') as String,
      waitSeconds: (json['waitSeconds'] as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
    'maskedContact': maskedContact,
    'waitSeconds': waitSeconds,
  };

  OtpWaitData copyWith({
    String? maskedContact,
    int? waitSeconds,
  }) {
    return OtpWaitData(
      maskedContact: maskedContact ?? this.maskedContact,
      waitSeconds: waitSeconds ?? this.waitSeconds,
    );
  }
}
