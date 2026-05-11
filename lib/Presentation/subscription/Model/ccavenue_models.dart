class CcAvenueInitRequest {
  final String planId;
  final String businessProfileId;
  final String shopId;

  const CcAvenueInitRequest({
    required this.planId,
    required this.businessProfileId,
    required this.shopId,
  });

  Map<String, dynamic> toJson() => {
        "planId": planId,
        "businessProfileId": businessProfileId,
        "shopId": shopId,
      };
}

class CcAvenueInitResponse {
  final bool status;
  final String? message;
  final CcAvenueInitData? data;

  const CcAvenueInitResponse({
    required this.status,
    this.message,
    this.data,
  });

  factory CcAvenueInitResponse.fromJson(Map<String, dynamic> json) {
    return CcAvenueInitResponse(
      status: json["status"] == true,
      message: json["message"]?.toString(),
      data: json["data"] is Map<String, dynamic>
          ? CcAvenueInitData.tryFromJson(json["data"] as Map<String, dynamic>)
          : null,
    );
  }
}

class CcAvenueInitData {
  final String provider;
  final String orderId;
  final String amount;
  final String currency;
  final String mode;
  final String merchantId;
  final String accessCode;
  final String gatewayUrl;
  final String redirectUrl;
  final String cancelUrl;
  final String encRequest;
  final CcAvenueForm form;
  final String planId;
  final String businessProfileId;
  final String shopId;

  const CcAvenueInitData({
    required this.provider,
    required this.orderId,
    required this.amount,
    required this.currency,
    required this.mode,
    required this.merchantId,
    required this.accessCode,
    required this.gatewayUrl,
    required this.redirectUrl,
    required this.cancelUrl,
    required this.encRequest,
    required this.form,
    required this.planId,
    required this.businessProfileId,
    required this.shopId,
  });

  static CcAvenueInitData? tryFromJson(Map<String, dynamic> json) {
    String s(String key) => (json[key] ?? "").toString().trim();

    final provider = s("provider");
    final orderId = s("orderId");
    final amount = s("amount");
    final currency = s("currency");
    final mode = s("mode");
    final merchantId = s("merchantId");
    final accessCode = s("accessCode");
    final gatewayUrl = s("gatewayUrl");
    final redirectUrl = s("redirectUrl");
    final cancelUrl = s("cancelUrl");
    final encRequest = s("encRequest");
    final planId = s("planId");
    final businessProfileId = s("businessProfileId");
    final shopId = s("shopId");

    final formJson = json["form"];
    final form = (formJson is Map<String, dynamic>)
        ? CcAvenueForm.tryFromJson(formJson)
        : null;

    if (provider.isEmpty ||
        orderId.isEmpty ||
        gatewayUrl.isEmpty ||
        encRequest.isEmpty ||
        form == null ||
        form.action.isEmpty ||
        form.fields.encRequest.isEmpty ||
        form.fields.accessCode.isEmpty) {
      return null;
    }

    return CcAvenueInitData(
      provider: provider,
      orderId: orderId,
      amount: amount,
      currency: currency.isEmpty ? "INR" : currency,
      mode: mode,
      merchantId: merchantId,
      accessCode: accessCode,
      gatewayUrl: gatewayUrl,
      redirectUrl: redirectUrl,
      cancelUrl: cancelUrl,
      encRequest: encRequest,
      form: form,
      planId: planId,
      businessProfileId: businessProfileId,
      shopId: shopId,
    );
  }
}

class CcAvenueForm {
  final String action;
  final String method;
  final CcAvenueFormFields fields;

  const CcAvenueForm({
    required this.action,
    required this.method,
    required this.fields,
  });

  static CcAvenueForm? tryFromJson(Map<String, dynamic> json) {
    final action = (json["action"] ?? "").toString().trim();
    final method = (json["method"] ?? "POST").toString().trim();

    final fieldsJson = json["fields"];
    final fields = (fieldsJson is Map<String, dynamic>)
        ? CcAvenueFormFields.tryFromJson(fieldsJson)
        : null;

    if (action.isEmpty || fields == null) return null;

    return CcAvenueForm(action: action, method: method, fields: fields);
  }
}

class CcAvenueFormFields {
  final String encRequest;
  final String accessCode;

  const CcAvenueFormFields({
    required this.encRequest,
    required this.accessCode,
  });

  static CcAvenueFormFields? tryFromJson(Map<String, dynamic> json) {
    final encRequest = (json["encRequest"] ?? "").toString().trim();
    final accessCode = (json["access_code"] ?? json["accessCode"] ?? "")
        .toString()
        .trim();

    if (encRequest.isEmpty || accessCode.isEmpty) return null;

    return CcAvenueFormFields(encRequest: encRequest, accessCode: accessCode);
  }
}

class CcAvenueConfirmRequest {
  final String encResp;

  const CcAvenueConfirmRequest({required this.encResp});

  Map<String, dynamic> toJson() => {"encResp": encResp};
}

/// We keep this response model permissive because backend may evolve.
/// The app should fall back to `GET /subscriptions/current` for the truth.
class CcAvenueConfirmResponse {
  final bool status;
  final String? message;
  final Map<String, dynamic>? data;
  final String? paymentStatus;

  const CcAvenueConfirmResponse({
    required this.status,
    this.message,
    this.data,
    this.paymentStatus,
  });

  factory CcAvenueConfirmResponse.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? data = json["data"] is Map<String, dynamic>
        ? (json["data"] as Map<String, dynamic>)
        : null;

    final paymentStatus = (json["paymentStatus"] ??
            (data == null ? null : (data["paymentStatus"] ?? data["status"])))
        ?.toString()
        .trim();

    return CcAvenueConfirmResponse(
      status: json["status"] == true,
      message: json["message"]?.toString(),
      data: data,
      paymentStatus: paymentStatus,
    );
  }
}
