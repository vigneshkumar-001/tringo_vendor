class WhatsappResponse {
  final bool status;
  final int code;
  final ContactData data;

  WhatsappResponse({
    required this.status,
    required this.code,
    required this.data,
  });

  factory WhatsappResponse.fromJson(Map<String, dynamic> json) {
    return WhatsappResponse(
      status: json['status'] as bool,
      code: json['code'] as int,
      data: ContactData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'code': code,
      'data': data.toJson(),
    };
  }
}

class ContactData {
  final String contact;
  final String normalized;
  final bool hasWhatsapp;
  final String providerStatus;

  ContactData({
    required this.contact,
    required this.normalized,
    required this.hasWhatsapp,
    required this.providerStatus,
  });

  factory ContactData.fromJson(Map<String, dynamic> json) {
    return ContactData(
      contact: json['contact'] as String,
      normalized: json['normalized'] as String,
      hasWhatsapp: json['hasWhatsapp'] as bool,
      providerStatus: json['providerStatus'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'contact': contact,
      'normalized': normalized,
      'hasWhatsapp': hasWhatsapp,
      'providerStatus': providerStatus,
    };
  }
}
