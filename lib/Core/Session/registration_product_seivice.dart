import 'package:tringo_vendor_new/Core/Session/registration_session.dart';

enum BusinessCategory { sellingProduct, services }

class RegistrationProductSeivice {
  RegistrationProductSeivice._internal();
  static final RegistrationProductSeivice instance =
      RegistrationProductSeivice._internal();

  /// Individual / Company
  BusinessType? businessType;

  /// Product / Service
  BusinessCategory? businessCategory;

  /// 🔹 Subscription status (true = paid, false = free)
  bool _isSubscribed = false;

  /// Helpers: product vs service
  bool get isProductBusiness =>
      businessCategory == BusinessCategory.sellingProduct;
  bool get isServiceBusiness => businessCategory == BusinessCategory.services;

  /// Helpers: premium vs non-premium
  ///  Premium ONLY if: Company + Subscribed
  bool get isPremium => businessType == BusinessType.company && _isSubscribed;

  /// ✅ Non-premium = not subscribed (even if company)
  bool get isNonPremium => !_isSubscribed;

  /// Call when payment/subscription success
  void markSubscribed() {
    _isSubscribed = true;
  }

  /// Call when user skips / cancels subscription
  void markUnsubscribed() {
    _isSubscribed = false;
  }

  void reset() {
    businessType = null;
    businessCategory = null;
    _isSubscribed = false;
    // baaki fields irundha inga reset pannunga...
  }
}
