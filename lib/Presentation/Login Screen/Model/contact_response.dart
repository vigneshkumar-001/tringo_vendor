class ContactResponse {
  final bool status;
  final ResponseData data;

  ContactResponse({required this.status, required this.data});

  factory ContactResponse.fromJson(Map<String, dynamic> json) {
    return ContactResponse(
      status: json['status'] as bool,
      data: ResponseData.fromJson(json['data']),
    );
  }

  Map<String, dynamic> toJson() {
    return {'status': status, 'data': data.toJson()};
  }
}

class ResponseData {
  final int total;
  final int inserted;
  final int touched;
  final int skipped;

  ResponseData({
    required this.total,
    required this.inserted,
    required this.touched,
    required this.skipped,
  });

  factory ResponseData.fromJson(Map<String, dynamic> json) {
    return ResponseData(
      total: json['total'] as int,
      inserted: json['inserted'] as int,
      touched: json['touched'] as int,
      skipped: json['skipped'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'inserted': inserted,
      'touched': touched,
      'skipped': skipped,
    };
  }
}
