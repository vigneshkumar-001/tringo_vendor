class DeleteResponse {
  final bool status;
  final String? message;

  const DeleteResponse({required this.status, this.message});

  factory DeleteResponse.fromJson(Map<String, dynamic> json) {
    return DeleteResponse(
      status: json['status'] ?? false,
      message: json['message']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'status': status, if (message != null) 'message': message};
  }
}
