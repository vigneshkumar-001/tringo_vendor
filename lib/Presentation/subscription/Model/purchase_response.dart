class PurchaseResponse {
  final bool status;
  final String message;
  final SubscriptionData data;

  PurchaseResponse({
    required this.status,
    required this. message ,
    required this.data,
  });

  factory PurchaseResponse.fromJson(Map<String, dynamic> json) {
    return PurchaseResponse(
      status: json['status'],
      message: json['message'],
      data: SubscriptionData.fromJson(json['data']),
    );
  }
}

class SubscriptionData {
  final String subscriptionId;
  final String businessProfileId;
  final bool isFreemium;
  final String status;
  final Plan plan;
  final Payment payment;
  final Period period;

  SubscriptionData({
    required this.subscriptionId,
    required this.businessProfileId,
    required this.isFreemium,
    required this.status,
    required this.plan,
    required this.payment,
    required this.period,
  });

  factory SubscriptionData.fromJson(Map<String, dynamic> json) {
    return SubscriptionData(
      subscriptionId: json['subscriptionId'],
      businessProfileId: json['businessProfileId'],
      isFreemium: json['isFreemium'],
      status: json['status'],
      plan: Plan.fromJson(json['plan']),
      payment: Payment.fromJson(json['payment']),
      period: Period.fromJson(json['period']),
    );
  }
}

class Plan {
  final String id;
  final String title;
  final String planCategory;
  final String type;
  final int durationDays;
  final String durationLabel;
  final int price;

  Plan({
    required this.id,
    required this.title,
    required this.planCategory,
    required this.type,
    required this.durationDays,
    required this.durationLabel,
    required this.price,
  });

  factory Plan.fromJson(Map<String, dynamic> json) {
    return Plan(
      id: json['id'],
      title: json['title'],
      planCategory: json['planCategory'],
      type: json['type'],
      durationDays: json['durationDays'],
      durationLabel: json['durationLabel'],
      price: json['price'],
    );
  }
}
class Payment {
  final String provider;
  final int paidAmount;
  final String currency;
  final String? orderId;
  final String? paymentId;
  final String txId;
  final String status;
  final DateTime paidAt;

  Payment({
    required this.provider,
    required this.paidAmount,
    required this.currency,
    this.orderId,
    this.paymentId,
    required this.txId,
    required this.status,
    required this.paidAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      provider: json['provider'],
      paidAmount: json['paidAmount'],
      currency: json['currency'],
      orderId: json['orderId'],
      paymentId: json['paymentId'],
      txId: json['txId'],
      status: json['status'],
      paidAt: DateTime.parse(json['paidAt']),
    );
  }
}
class Period {
  final DateTime startsAt;
  final DateTime endsAt;
  final String startsAtLabel;
  final String endsAtLabel;
  final int daysLeft;
  final int durationDays;

  Period({
    required this.startsAt,
    required this.endsAt,
    required this.startsAtLabel,
    required this.endsAtLabel,
    required this.daysLeft,
    required this.durationDays,
  });

  factory Period.fromJson(Map<String, dynamic> json) {
    return Period(
      startsAt: DateTime.parse(json['startsAt']),
      endsAt: DateTime.parse(json['endsAt']),
      startsAtLabel: json['startsAtLabel'],
      endsAtLabel: json['endsAtLabel'],
      daysLeft: json['daysLeft'],
      durationDays: json['durationDays'],
    );
  }
}
