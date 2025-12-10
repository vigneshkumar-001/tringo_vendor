class UserImageResponse {
  final bool status;
  final String message;

  UserImageResponse({required this.status, required this.message});

  factory UserImageResponse.fromJson(Map<String, dynamic> json) {
    return UserImageResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
    );
  }
}
