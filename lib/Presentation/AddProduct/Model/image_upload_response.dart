class ImageUploadResponse {
  final bool status;
  final String url;      // or message, based on your API
  final String? message; // optional display msg

  ImageUploadResponse({
    required this.status,
    required this.url,
    this.message,
  });

  factory ImageUploadResponse.fromJson(Map<String, dynamic> json) {
    // adjust mapping based on your backend
    // Example 1: {status:true, data:{url:"https://..."}}
    final data = json['data'] as Map<String, dynamic>? ?? {};
    return ImageUploadResponse(
      status: json['status'] as bool? ?? false,
      url: data['url'] as String? ?? '',
      message: json['message'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'url': url,
      'message': message,
    };
  }
}
