class CurrentPlanResponse {
  final bool status;
  final String message;
  final CurrentPlanData? data;

  CurrentPlanResponse({required this.status, required this.message, this.data});

  factory CurrentPlanResponse.fromJson(Map<String, dynamic> json) {
    return CurrentPlanResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? CurrentPlanData.fromJson(json['data'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'message': message,
    'data': data?.toJson(),
  };
}

class CurrentPlanData {
  final String subscriptionId;
  final String businessProfileId;
  final bool isFreemium;
  final String status;
  final Plan plan;
  final Payment? payment;
  final Period period;
  final Invoice? invoice;

  CurrentPlanData({
    required this.subscriptionId,
    required this.businessProfileId,
    required this.isFreemium,
    required this.status,
    required this.plan,
    this.payment,
    required this.period,
    this.invoice,
  });

  factory CurrentPlanData.fromJson(Map<String, dynamic> json) {
    return CurrentPlanData(
      subscriptionId: json['subscriptionId'] ?? '',
      businessProfileId: json['businessProfileId'] ?? '',
      isFreemium: json['isFreemium'] ?? false,
      status: json['status'] ?? '',
      plan: Plan.fromJson(json['plan']),
      payment: json['payment'] != null
          ? Payment.fromJson(json['payment'] as Map<String, dynamic>)
          : null,
      period: Period.fromJson(json['period']),
      invoice: json['invoice'] != null
          ? Invoice.fromJson(json['invoice'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'subscriptionId': subscriptionId,
    'businessProfileId': businessProfileId,
    'isFreemium': isFreemium,
    'status': status,
    'plan': plan.toJson(),
    'payment': payment?.toJson(),
    'period': period.toJson(),
    'invoice': invoice?.toJson(),
  };
}

class Plan {
  final String id;
  final String title;
  final String planCategory;
  final String type;
  final int durationDays;
  final String durationLabel;
  final int price;
  final bool isBestValue;
  final List<PlanFeature> features;

  Plan({
    required this.id,
    required this.title,
    required this.planCategory,
    required this.type,
    required this.durationDays,
    required this.durationLabel,
    required this.price,
    required this.isBestValue,
    required this.features,
  });

  factory Plan.fromJson(Map<String, dynamic> json) {
    return Plan(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      planCategory: json['planCategory'] ?? '',
      type: json['type'] ?? '',
      durationDays: json['durationDays'] ?? 0,
      durationLabel: json['durationLabel'] ?? '',
      price: json['price'] ?? 0,
      isBestValue: json['isBestValue'] == true,
      features: (json['features'] is List)
          ? (json['features'] as List)
              .whereType<Map<String, dynamic>>()
              .map(PlanFeature.fromJson)
              .toList()
          : const [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'planCategory': planCategory,
    'type': type,
    'durationDays': durationDays,
    'durationLabel': durationLabel,
    'price': price,
    'isBestValue': isBestValue,
    'features': features.map((e) => e.toJson()).toList(),
  };
}

class PlanFeature {
  final String key;
  final String label;
  final bool free;
  final bool premium;
  final int sort;

  PlanFeature({
    required this.key,
    required this.label,
    required this.free,
    required this.premium,
    required this.sort,
  });

  factory PlanFeature.fromJson(Map<String, dynamic> json) {
    return PlanFeature(
      key: (json['key'] ?? '').toString(),
      label: (json['label'] ?? '').toString(),
      free: json['free'] == true,
      premium: json['premium'] == true,
      sort: (json['sort'] is num) ? (json['sort'] as num).toInt() : 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'key': key,
    'label': label,
    'free': free,
    'premium': premium,
    'sort': sort,
  };
}

class Payment {
  final String provider;
  final String providerLabel;
  final String source;
  final int paidAmount;
  final String currency;
  final String? orderId;
  final String? paymentId;
  final String txId;
  final String status;
  final String paidAt;

  Payment({
    required this.provider,
    required this.providerLabel,
    required this.source,
    required this.paidAmount,
    required this.currency,
    required this.orderId,
    required this.paymentId,
    required this.txId,
    required this.status,
    required this.paidAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      provider: (json['provider'] ?? '').toString(),
      providerLabel: (json['providerLabel'] ?? '').toString(),
      source: (json['source'] ?? '').toString(),
      paidAmount: (json['paidAmount'] is num)
          ? (json['paidAmount'] as num).toInt()
          : 0,
      currency: (json['currency'] ?? '').toString(),
      orderId: json['orderId']?.toString(),
      paymentId: json['paymentId']?.toString(),
      txId: (json['txId'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      paidAt: (json['paidAt'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'provider': provider,
    'providerLabel': providerLabel,
    'source': source,
    'paidAmount': paidAmount,
    'currency': currency,
    'orderId': orderId,
    'paymentId': paymentId,
    'txId': txId,
    'status': status,
    'paidAt': paidAt,
  };
}

class Invoice {
  final String url;
  final String downloadUrl;
  final String fileName;
  final String expiresAt;

  Invoice({
    required this.url,
    required this.downloadUrl,
    required this.fileName,
    required this.expiresAt,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      url: (json['url'] ?? '').toString(),
      downloadUrl: (json['downloadUrl'] ?? '').toString(),
      fileName: (json['fileName'] ?? '').toString(),
      expiresAt: (json['expiresAt'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'url': url,
    'downloadUrl': downloadUrl,
    'fileName': fileName,
    'expiresAt': expiresAt,
  };
}

class Period {
  final String startsAt;
  final String endsAt;
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
      startsAt: json['startsAt'] ?? '',
      endsAt: json['endsAt'] ?? '',
      startsAtLabel: json['startsAtLabel'] ?? '',
      endsAtLabel: json['endsAtLabel'] ?? '',
      daysLeft: json['daysLeft'] ?? 0,
      durationDays: json['durationDays'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'startsAt': startsAt,
    'endsAt': endsAt,
    'startsAtLabel': startsAtLabel,
    'endsAtLabel': endsAtLabel,
    'daysLeft': daysLeft,
    'durationDays': durationDays,
  };
}
