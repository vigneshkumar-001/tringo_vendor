class ApiUrl {
  static const String base =
      "https://fenizo-tringo-backend-12ebb106711d.herokuapp.com/";
  static const String register = "${base}api/v1/auth/request-otp";
  static const String verifyOtp = "${base}api/v1/auth/verify-otp";
  static const String whatsAppVerify = "${base}api/v1/auth/check-whatsapp";
  static const String resendOtp = "${base}api/v1/auth/resend-otp";
  static const String employeeAddNumber =
      "${base}api/v1/vendor/employees/request-otp";
  static const String employeeAddOtp =
      "${base}api/v1/vendor/employees/verify-otp";
  static const String employeeUpdateNumber =
      "${base}api/v1/vendor/employees/phone-change/request-otp";
  static const String employeeUpdateOtp =
      "${base}api/v1/vendor/employees/phone-change/verify-otp";
  static const String ownerInfoNumberRequest =
      "${base}api/v1/auth/verify-owner-phone/request-otp";
  static const String ownerInfoNumberOtpRequest =
      "${base}api/v1/auth/verify-owner-phone/verify-otp";
  static const String business = "${base}api/v1/business";
  static const String shops = "${base}api/v1/shops";
  static const String vendorRegister = "${base}api/v1/vendor/profile";
  static const String addEmployees = "${base}api/v1/vendor/employees";
  static const String heaterHome = "${base}api/v1/vendor/dashboard";

  static const String mobileVerify = "${base}api/v1/auth/login-by-sim";
  static const String heaterEmployee = "${base}api/v1/vendor/employees";

  static const String categoriesShop =
      "${base}api/v1/public/categories?type=shop";
  static const String employeeOverview =
      "${base}api/v1/vendor/dashboard/overview";
  static String imageUrl =
      "https://next.fenizotechnologies.com/Adrox/api/image-save";

  static String heaterEmployeeEdit({required String employeeId}) {
    return "${base}api/v1/vendor/employees/$employeeId";
  }

  static String employeeUnblock({required String employeeId}) {
    return "${base}api/v1/vendor/employees/$employeeId/status";
  }

  static String heaterEmployeeDetails({required String employeeId}) {
    return "${base}api/v1/vendor/employees/$employeeId";
  }

  static String shopPhotosUpload({required String shopId}) {
    return "${base}api/v1/shops/$shopId/media";
  }

  static String searchKeyWords({required String shopId}) {
    return "${base}api/v1/shops/$shopId/keywords";
  }

  static String productCategoryList({required String shopId}) {
    return "${base}api/v1/public/shops/$shopId/product-categories";
  }

  static String addProducts({required String shopId}) {
    return "${base}api/v1/shops/$shopId/products";
  }

  static String updateProducts({required String productId}) {
    return "${base}api/v1/products/$productId";
  }

  static String shopDetails({required String shopId}) {
    return "${base}api/v1/shops/$shopId";
  }

  static String serviceEdit({required String serviceId}) {
    return "${base}api/v1/services/$serviceId";
  }

  static String serviceInfo({required String shopId}) {
    //  no slash before api
    return "${base}api/v1/shops/$shopId/services";
  }

  static String serviceList({required String serviceId}) {
    return "${base}api/v1/services/$serviceId";
  }

  static String deleteProduct({required String productId}) {
    return "${base}api/v1/products/$productId";
  }

  static String serviceDelete({required String serviceId}) {
    return "${base}api/v1/services/delete/$serviceId";
  }

  static String employeeHome({
    required String date,
    required String page,
    required String limit,
    required String q,
  }) {
    // date must be "yyyy-MM-dd" (example: 2025-12-18)
    return "${base}api/v1/employee/dashboard/home?dateTo=$date&page=$page&limit=$limit&q=$q&dateFrom=$date";
  }

  static String updateShop({required String shopId}) {
    return "${base}api/v1/shops/edit/$shopId";
  }
}
