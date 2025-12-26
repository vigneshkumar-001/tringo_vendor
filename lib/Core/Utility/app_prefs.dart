import 'package:shared_preferences/shared_preferences.dart';

class AppPrefs {
  AppPrefs._(); // no instance

  static const String _kVerificationToken = 'verificationToken';
  static const String _shopId = 'shop_id';
  static const String _productId = 'product_id';
  static const String _serviceId = 'service_id';
  static const String _businessProfileId = 'businessProfile_Id';
  static const _kOfflineSessionId = "offline_session_id";

  static Future<void> setOfflineSessionId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kOfflineSessionId, id);
  }

  static Future<String?> getOfflineSessionId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kOfflineSessionId);
  }

  static Future<void> clearOfflineSessionId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kOfflineSessionId);
  }


     static Future<void> setVerificationToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kVerificationToken, token);
  }

  static Future<void> setBusinessProfileId(String businessProfileId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_businessProfileId, businessProfileId);
  }

  static Future<void> setShopId(String shopId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_shopId, shopId);
  }

  static Future<void> setServiceId(String shopId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_serviceId, shopId);
  }

  static Future<void> setProductId(String productId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_productId, productId);
  }

  /// Read
  static Future<String?> getVerificationToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kVerificationToken);
  }

  static Future<String?> getSopId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_shopId);
  }

  static Future<String?> getServiceId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_serviceId);
  }

  static Future<String?> getProductId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_productId);
  }

  static Future<String?> getBusinessProfileId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_businessProfileId);
  }
  // /// Optional: sync-like getter (only after init)
  // static String? _cachedVerificationToken;
  //
  // static Future<void> initCache() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   _cachedVerificationToken = prefs.getString(_kVerificationToken);
  // }
  //
  // static String? get verificationTokenCached => _cachedVerificationToken;

  static Future<void> clearVerificationToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kVerificationToken);
    // _cachedVerificationToken = null;
  }

  static Future<void> clearIds() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_productId);
    await prefs.remove(_shopId);
    await prefs.remove(_serviceId);
    // _cachedVerificationToken = null;
  }
}
