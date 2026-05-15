import 'package:shared_preferences/shared_preferences.dart';

class AppPrefs {
  AppPrefs._();

  static const String _kVerificationToken = 'verificationToken';
  static const String _kVerifiedCompanyPhone = 'verifiedCompanyPhone10';

  static const String _shopId = 'shop_id';
  static const String _productId = 'product_id';
  static const String _serviceId = 'service_id';
  static const String _businessProfileId = 'businessProfile_Id';
  static const String _kOfflineSessionId = "offline_session_id";
  static const _kOwnerPhone = 'owner_phone';
  static const String _token = 'token';
  static const String _refreshToken = 'refreshToken';
  static const String _sessionToken = 'sessionToken';
  static const String _role = 'role';
  static const String _kOnboardingStep = 'onboardingStep';
  static const String _kVendorApproved = 'vendorApproved';
  static const String _kVendorId = 'vendorId';
  static const String _kVendorStatus = 'vendorStatus';
  static const String _kIsProfileCompleted = 'isProfileCompleted';
  static const String _kIsNewOwner = 'isNewOwner';
  static const String _kContactsSynced = 'contacts_synced';

  static Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_token, token);
  }

  static Future<void> setRefreshToken(String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_refreshToken, refreshToken);
  }

  static Future<void> setSessionToken(String sessionToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionToken, sessionToken);
  }

  static Future<void> setRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_role, role);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getString(_token);
    if (v == null || v.trim().isEmpty) return null;
    return v.trim();
  }

  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getString(_refreshToken);
    if (v == null || v.trim().isEmpty) return null;
    return v.trim();
  }

  static Future<String?> getSessionToken() async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getString(_sessionToken);
    if (v == null || v.trim().isEmpty) return null;
    return v.trim();
  }

  static Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getString(_role);
    if (v == null || v.trim().isEmpty) return null;
    return v.trim();
  }

  static Future<void> clearAuthSessionForLogout() async {
    final prefs = await SharedPreferences.getInstance();

    // Auth/session tokens
    await prefs.remove(_token);
    await prefs.remove(_refreshToken);
    await prefs.remove(_sessionToken);
    await prefs.remove(_role);

    // Common "session-scoped" cache/state
    await prefs.remove(_kVendorStatus);
    await prefs.remove(_kVendorApproved);
    await prefs.remove(_kVendorId);
    await prefs.remove(_kOnboardingStep);
    await prefs.remove(_kIsProfileCompleted);
    await prefs.remove(_kIsNewOwner);

    // IDs & verification/offline artifacts
    await clearIdsForOffline();
    await clearOfflineSessionId();
    await clearCompanyPhoneVerification();

    // Optional: session-scoped sync flag (safe to resync after login)
    await prefs.remove(_kContactsSynced);
  }

  static Future<void> setOnboardingStep(String? step) async {
    final prefs = await SharedPreferences.getInstance();
    final v = (step ?? '').trim();
    if (v.isEmpty) {
      await prefs.remove(_kOnboardingStep);
      return;
    }
    await prefs.setString(_kOnboardingStep, v);
  }

  static Future<String?> getOnboardingStep() async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getString(_kOnboardingStep);
    if (v == null || v.trim().isEmpty) return null;
    return v.trim();
  }

  static Future<void> setVendorApproved(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kVendorApproved, value);
  }

  static Future<bool?> getVendorApproved() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kVendorApproved);
  }

  static Future<void> setVendorId(String vendorId) async {
    final prefs = await SharedPreferences.getInstance();
    final v = vendorId.trim();
    if (v.isEmpty) {
      await prefs.remove(_kVendorId);
      return;
    }
    await prefs.setString(_kVendorId, v);
  }

  static Future<String?> getVendorId() async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getString(_kVendorId);
    if (v == null || v.trim().isEmpty) return null;
    return v.trim();
  }

  // ---------- Offline session ----------
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

  // ---------- Verification token ----------
  static Future<void> setVerificationToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kVerificationToken, token.trim());
  }

  static Future<void> setOwnerPhone(String phone) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kOwnerPhone, phone);
  }

  static Future<String?> getOwnerPhone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kOwnerPhone);
  }

  static Future<String?> getVerificationToken() async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getString(_kVerificationToken);
    if (v == null || v.trim().isEmpty) return null;
    return v.trim();
  }

  static Future<void> clearVerificationToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kVerificationToken);
  }

  // ---------- Verified Company Phone ----------
  static Future<void> setVerifiedCompanyPhone(String phone10) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kVerifiedCompanyPhone, phone10.trim());
  }

  static Future<String?> getVerifiedCompanyPhone() async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getString(_kVerifiedCompanyPhone);
    if (v == null || v.trim().isEmpty) return null;
    return v.trim();
  }

  static Future<void> clearVerifiedCompanyPhone() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kVerifiedCompanyPhone);
  }

  // ✅ Clear both
  static Future<void> clearCompanyPhoneVerification() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kVerificationToken);
    await prefs.remove(_kVerifiedCompanyPhone);
  }

  // ---------- IDs ----------
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

  // ---------- Read IDs ----------
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

  static Future<void> clearIds() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_productId);
    await prefs.remove(_shopId);
    await prefs.remove(_serviceId);
    await prefs.remove(_kOwnerPhone);
  }

  static Future<void> clearIdsForOffline() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_productId);
    await prefs.remove(_shopId);
    await prefs.remove(_serviceId);
    await prefs.remove(_kVerificationToken);
    await prefs.remove(_businessProfileId);
    await prefs.remove(_kOwnerPhone);
  }
}

// import 'package:shared_preferences/shared_preferences.dart';
//
// class AppPrefs {
//   AppPrefs._(); // no instance
//
//   static const String _kVerificationToken = 'verificationToken';
//   static const String _shopId = 'shop_id';
//   static const String _productId = 'product_id';
//   static const String _serviceId = 'service_id';
//   static const String _businessProfileId = 'businessProfile_Id';
//   static const _kOfflineSessionId = "offline_session_id";
//
//   static Future<void> setOfflineSessionId(String id) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString(_kOfflineSessionId, id);
//   }
//
//   static Future<String?> getOfflineSessionId() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString(_kOfflineSessionId);
//   }
//
//   static Future<void> clearOfflineSessionId() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove(_kOfflineSessionId);
//   }
//
//
//      static Future<void> setVerificationToken(String token) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString(_kVerificationToken, token);
//   }
//
//   static Future<void> setBusinessProfileId(String businessProfileId) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString(_businessProfileId, businessProfileId);
//   }
//
//   static Future<void> setShopId(String shopId) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString(_shopId, shopId);
//   }
//
//   static Future<void> setServiceId(String shopId) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString(_serviceId, shopId);
//   }
//
//   static Future<void> setProductId(String productId) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString(_productId, productId);
//   }
//
//   /// Read
//   static Future<String?> getVerificationToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString(_kVerificationToken);
//   }
//
//   static Future<String?> getSopId() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString(_shopId);
//   }
//
//   static Future<String?> getServiceId() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString(_serviceId);
//   }
//
//   static Future<String?> getProductId() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString(_productId);
//   }
//
//   static Future<String?> getBusinessProfileId() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString(_businessProfileId);
//   }
//   // /// Optional: sync-like getter (only after init)
//   // static String? _cachedVerificationToken;
//   //
//   // static Future<void> initCache() async {
//   //   final prefs = await SharedPreferences.getInstance();
//   //   _cachedVerificationToken = prefs.getString(_kVerificationToken);
//   // }
//   //
//   // static String? get verificationTokenCached => _cachedVerificationToken;
//
//   static Future<void> clearVerificationToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove(_kVerificationToken);
//     // _cachedVerificationToken = null;
//   }
//
//   static Future<void> clearIds() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove(_productId);
//     await prefs.remove(_shopId);
//     await prefs.remove(_serviceId);
//     // _cachedVerificationToken = null;
//   }
// }
