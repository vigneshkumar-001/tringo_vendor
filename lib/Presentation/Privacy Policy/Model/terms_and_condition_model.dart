class TermsAndConditionResponse {
  final bool status;
  final ApiData data;

  TermsAndConditionResponse({required this.status, required this.data});

  factory TermsAndConditionResponse.fromJson(Map<String, dynamic> json) {
    return TermsAndConditionResponse(
      status: json['status'],
      data: ApiData.fromJson(json['data']),
    );
  }
}

class ApiData {
  final bool ok;
  final PrivacyPolicy data;

  ApiData({required this.ok, required this.data});

  factory ApiData.fromJson(Map<String, dynamic> json) {
    return ApiData(ok: json['ok'], data: PrivacyPolicy.fromJson(json['data']));
  }
}

class PrivacyPolicy {
  final String slug;
  final String title;
  final String contentHtml;
  final String contentText;
  final DateTime updatedAt;

  PrivacyPolicy({
    required this.slug,
    required this.title,
    required this.contentHtml,
    required this.contentText,
    required this.updatedAt,
  });

  factory PrivacyPolicy.fromJson(Map<String, dynamic> json) {
    return PrivacyPolicy(
      slug: json['slug'],
      title: json['title'],
      contentHtml: json['contentHtml'],
      contentText: json['contentText'],
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
