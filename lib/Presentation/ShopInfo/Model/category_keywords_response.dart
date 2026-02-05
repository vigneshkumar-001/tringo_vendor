class CategoryKeywordsResponse {
  final bool status;
  final List<String> data;

  CategoryKeywordsResponse({required this.status, required this.data});

  factory CategoryKeywordsResponse.fromJson(Map<String, dynamic> json) {
    return CategoryKeywordsResponse(
      status: json['status'] as bool,
      data: List<String>.from(json['data']),
    );
  }

  Map<String, dynamic> toJson() {
    return {'status': status, 'data': data};
  }
}
