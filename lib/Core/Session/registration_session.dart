enum BusinessType { individual, company }

class RegistrationSession {
  RegistrationSession._internal();
  static final RegistrationSession instance = RegistrationSession._internal();

  BusinessType? businessType;

  // 🔥 NEW: helper getters
  bool get isIndividualBusiness => businessType == BusinessType.individual;
  bool get isCompanyBusiness => businessType == BusinessType.company;

  // bool get isNonPremium => businessType == BusinessType.individual;
  // bool get isPremium => businessType == BusinessType.company;

  void reset() {
    businessType = null;
    // baaki fields reset...
  }
}
