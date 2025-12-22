class PurchaseResponse {
  final bool status;
  final SubscriptionData data;

  PurchaseResponse({
    required this.status,
    required this.data,
  });

  factory PurchaseResponse.fromJson(Map<String, dynamic> json) {
    return PurchaseResponse(
      status: json['status'],
      data: SubscriptionData.fromJson(json['data']),
    );
  }
}

class SubscriptionData {
  final String id;

  SubscriptionData({required this.id});

  factory SubscriptionData.fromJson(Map<String, dynamic> json) {
    return SubscriptionData(
      id: json['id'],
    );
  }
}
