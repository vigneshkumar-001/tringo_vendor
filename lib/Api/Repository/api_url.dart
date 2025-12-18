class ApiUrl {
  static const String base =
      "https://fenizo-tringo-backend-12ebb106711d.herokuapp.com/";
  static const String register = "${base}api/v1/auth/request-otp";
  static const String verifyOtp = "${base}api/v1/auth/verify-otp";
  static const String whatsAppVerify = "${base}api/v1/auth/check-whatsapp";
  static const String resendOtp = "${base}api/v1/auth/resend-otp";
  static const String vendorRegister = "${base}api/v1/vendor/profile";
  static const String addEmployees = "${base}api/v1/vendor/employees";
  static const String heaterHome = "${base}api/v1/vendor/dashboard";
  static const String employeeHome = "${base}api/v1/employee/dashboard/home";
  static const String mobileVerify = "${base}api/v1/auth/login-by-sim";
  static const String heaterEmployee = "${base}api/v1/vendor/employees";

  static const String employeeOverview =
      "${base}api/v1/vendor/dashboard/overview";
  static String imageUrl =
      "https://next.fenizotechnologies.com/Adrox/api/image-save";

  static String heaterEmployeeEdit({required String employeeId}) {
    return "${base}api/v1/vendor/employees/$employeeId";
  }

  static String heaterEmployeeDetails({required String employeeId}) {
    return "${base}api/v1/vendor/employees/$employeeId";
  }
}
