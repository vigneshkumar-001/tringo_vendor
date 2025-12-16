// lib/Core/Routing/app_go_routes.dart
import 'package:go_router/go_router.dart';
import 'package:tringo_vendor_new/Core/Widgets/bottom_navigation_bar.dart';

import '../../Presentation/AddProduct/Screens/add_product_list.dart';
import '../../Presentation/AddProduct/Screens/product_category_screens.dart';
import '../../Presentation/Heater/Add Vendor Employee/Screen/employee_approval_pending.dart';
import '../../Presentation/Heater/Add Vendor Employee/Screen/employee_approval_rejected.dart';
import '../../Presentation/Heater/Add Vendor Employee/Screen/heater_add_employee.dart';
import '../../Presentation/Heater/Employee Details/Screen/heater_employee_details.dart';
import '../../Presentation/Heater/Employee details-edit/Screen/heater_employee_details_edit.dart';
import '../../Presentation/Heater/Heater Register/Screen/heater_register_1.dart';
import '../../Presentation/Heater/Heater Register/Screen/heater_register_2.dart';
import '../../Presentation/Heater/Vendor Company Info/Screen/vendor_company_info.dart';
import '../../Presentation/Heater/Vendor Company Info/Screen/vendor_company_photo.dart';
import '../../Presentation/Home Screen/home_screen.dart';
import '../../Presentation/Login Screen/Screens/login_mobile_number.dart';
import '../../Presentation/Mobile Nomber Verify/Screen/mobile_number_verify.dart';
import '../../Presentation/OTP Screen/Screens/otp_screen.dart';
import '../../Presentation/Owner Screen/owner_info_screens.dart';
import '../../Presentation/Privacy Policy/Screen/privacy_policy.dart';
import '../../Presentation/ShopInfo/Screens/search_keyword.dart';
import '../../Presentation/ShopInfo/Screens/shop_category_info.dart';
import '../../Presentation/ShopInfo/Screens/shop_photo_info.dart';
import '../../Presentation/Shops Details/Screen/shops_details.dart';
import '../../Presentation/subscription/Screen/subscription_screen.dart';
import '../../Splash_screen.dart';
import 'heater_bottom_navigation_bar.dart';

class AppRoutes {
  static const String splashScreen = 'splashScreen';
  static const String login = 'login';
  static const String otp = 'otp';
  static const String home = 'home';
  static const String ownerInfo = 'ownerInfo';
  static const String shopCategoryInfo = 'ShopCategoryInfo';
  static const String shopPhotoInfo = 'ShopPhotoInfo';
  static const String searchKeyword = 'SearchKeyword';
  static const String productCategoryScreens = 'ProductCategoryScreens';
  static const String addProductList = 'AddProductList';
  static const String shopsDetails = 'ShopsDetails';
  static const String heaterRegister1 = 'HeaterRegister1';
  static const String heaterRegister2 = 'HeaterRegister2';
  static const String vendorCompanyInfo = 'VendorCompanyInfo';
  static const String vendorCompanyPhoto = 'VendorCompanyPhoto';
  static const String heaterHomeScreen = 'HeaterHomeScreen';
  static const String employeeApprovalPending = 'EmployeeApprovalPending';
  static const String employeeApprovalRejected = 'EmployeeApprovalRejected';
  static const String heaterAddEmployee = 'heaterAddEmployee';
  static const String mobileNumberVerify = 'MobileNumberVerify';
  static const String privacyPolicy = 'privacyPolicy';
  static const String heaterEmployeeDetails = 'HeaterEmployeeDetails';
  static const String heaterEmployeeDetailsEdit = 'HeaterEmployeeDetailsEdit';
  static const String subscriptionScreen = 'SubscriptionScreen';

  static const String splashScreenPath = '/splashScreen';
  static const String loginPath = '/login';
  static const String otpPath = '/otp';
  static const String homePath = '/home';
  static const String ownerInfoPath = '/ownerInfo';
  static const String shopCategoryInfoPath = '/ShopCategoryInfo';
  static const String shopPhotoInfoPath = '/ShopPhotoInfo';
  static const String searchKeywordPath = '/SearchKeyword';
  static const String productCategoryScreensPath = '/ProductCategoryScreens';
  static const String addProductListPath = '/AddProductList';
  static const String shopsDetailsPath = '/ShopsDetails';
  static const String heaterRegister1Path = '/HeaterRegister1';
  static const String heaterRegister2Path = '/HeaterRegister2';
  static const String vendorCompanyInfoPath = '/VendorCompanyInfo';
  static const String vendorCompanyPhotoPath = '/VendorCompanyPhoto';
  static const String heaterHomeScreenPath = '/HeaterHomeScreen';
  static const String employeeApprovalPendingPath = '/EmployeeApprovalPending';
  static const String heaterAddEmployeePath = '/heaterAddEmployeePath';
  static const String mobileNumberVerifyPath = '/MobileNumberVerify';
  static const String privacyPolicyPath = '/privacyPolicy';
  static const String heaterEmployeeDetailsPath = '/HeaterEmployeeDetails';
  static const String subscriptionScreenPath = '/SubscriptionScreen';
  static const String heaterEmployeeDetailsEditPath =
      '/HeaterEmployeeDetailsEdit';

  static const String employeeApprovalRejectedPath =
      '/EmployeeApprovalRejected';
}

final goRouter = GoRouter(
  initialLocation: AppRoutes.splashScreenPath,
  routes: [
    GoRoute(
      path: AppRoutes.splashScreenPath,
      name: AppRoutes.splashScreen,
      builder: (context, state) => SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.loginPath,
      name: AppRoutes.login,
      builder: (context, state) => LoginMobileNumber(),
    ),

    GoRoute(
      path: AppRoutes.otpPath,
      name: AppRoutes.otp,
      builder: (context, state) {
        final phone = state.extra as String?;
        return OtpScreen(phoneNumber: phone ?? '');
      },
    ),

    GoRoute(
      path: AppRoutes.mobileNumberVerifyPath,
      name: AppRoutes.mobileNumberVerify,
      builder: (context, state) {
        final args = state.extra as Map<String, dynamic>? ?? {};
        final phone = args['phone'] as String? ?? '';
        final simToken = args['simToken'] as String? ?? '';

        return MobileNumberVerify(
          loginNumber: phone,
          simToken: simToken, // pass it to the screen
        );
      },
    ),
    GoRoute(
      path: AppRoutes.privacyPolicyPath,
      name: AppRoutes.privacyPolicy,
      builder: (context, state) => const PrivacyPolicy(),
    ),

    GoRoute(
      path: AppRoutes.homePath,
      name: AppRoutes.home,
      builder: (context, state) => CommonBottomNavigation(initialIndex: 0),
    ),
    GoRoute(
      path: AppRoutes.ownerInfoPath,
      name: AppRoutes.ownerInfo,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;

        final isService = (extra?['isService'] as bool?) ?? false;
        final isIndividual = (extra?['isIndividual'] as bool?) ?? true;

        return OwnerInfoScreens(
          isService: isService,
          isIndividual: isIndividual,
        );
      },
    ),

    GoRoute(
      path: AppRoutes.shopCategoryInfoPath,
      name: AppRoutes.shopCategoryInfo,
      builder: (context, state) {
        final args = state.extra as Map<String, dynamic>? ?? {};
        final isService = args['isService'] as bool? ?? false;
        final isIndividual = args['isIndividual'] as bool? ?? true;

        return ShopCategoryInfo(
          isService: isService,
          isIndividual: isIndividual,
          initialShopNameEnglish: args['initialShopNameEnglish'] as String?,
          initialShopNameTamil: args['initialShopNameTamil'] as String?,
          pages: args['pages'] as String?,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.shopPhotoInfoPath,
      name: AppRoutes.shopPhotoInfo,
      builder: (context, state) {
        final pageName = state.extra as String? ?? '';
        return ShopPhotoInfo(pages: pageName);
      },
    ),

    GoRoute(
      path: AppRoutes.searchKeywordPath,
      name: AppRoutes.searchKeyword,
      builder: (context, state) => const SearchKeyword(),
    ),

    GoRoute(
      path: AppRoutes.productCategoryScreensPath,
      name: AppRoutes.productCategoryScreens,
      builder: (context, state) => const ProductCategoryScreens(),
    ),
    GoRoute(
      path: AppRoutes.addProductListPath,
      name: AppRoutes.addProductList,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;

        return AddProductList(isService: extra?['isService'] ?? false);
      },
    ),

    GoRoute(
      path: AppRoutes.shopsDetailsPath,
      name: AppRoutes.shopsDetails,
      builder: (context, state) {
        final extra = state.extra;

        bool backDisabled = false;
        bool fromSubscription = false;
        String? shopId;

        if (extra is Map<String, dynamic>) {
          backDisabled = extra['backDisabled'] as bool? ?? false;
          fromSubscription = extra['fromSubscriptionSkip'] as bool? ?? false;
          shopId = extra['shopId'] as String?;
        } else if (extra is bool) {
          fromSubscription = extra;
        }

        return ShopsDetails(
          backDisabled: backDisabled,
          fromSubscriptionSkip: fromSubscription,
          shopId: shopId,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.heaterRegister1Path,
      name: AppRoutes.heaterRegister1,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;

        final isService = (extra?['isService'] as bool?) ?? false;
        final isIndividual = (extra?['isIndividual'] as bool?) ?? true;

        return HeaterRegister1(
          isService: isService,
          isIndividual: isIndividual,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.heaterRegister2Path,
      name: AppRoutes.heaterRegister2,
      builder: (context, state) => const HeaterRegister2(),
    ),
    GoRoute(
      path: AppRoutes.vendorCompanyInfoPath,
      name: AppRoutes.vendorCompanyInfo,
      builder: (context, state) => const VendorCompanyInfo(),
    ),
    GoRoute(
      path: AppRoutes.vendorCompanyPhotoPath,
      name: AppRoutes.vendorCompanyPhoto,
      builder: (context, state) {
        final pageName = state.extra as String? ?? '';
        return VendorCompanyPhoto(pages: pageName);
      },
    ),
    GoRoute(
      path: AppRoutes.heaterAddEmployeePath,
      name: AppRoutes.heaterAddEmployee,
      builder: (context, state) => HeaterAddEmployee(),
    ),
    GoRoute(
      path: AppRoutes.heaterHomeScreenPath,
      name: AppRoutes.heaterHomeScreen,
      builder: (context, state) => HeaterBottomNavigationBar(initialIndex: 0),
    ),

    GoRoute(
      path: AppRoutes.employeeApprovalPendingPath,
      name: AppRoutes.employeeApprovalPending,
      builder: (context, state) => EmployeeApprovalPending(),
    ),
    GoRoute(
      path: AppRoutes.employeeApprovalRejectedPath,
      name: AppRoutes.employeeApprovalRejected,
      builder: (context, state) => EmployeeApprovalRejected(),
    ),
    GoRoute(
      path: AppRoutes.heaterEmployeeDetailsPath,
      name: AppRoutes.heaterEmployeeDetails,
      builder: (context, state) => HeaterEmployeeDetails(),
    ),
    GoRoute(
      path: AppRoutes.heaterEmployeeDetailsEditPath,
      name: AppRoutes.heaterEmployeeDetailsEdit,
      builder: (context, state) => HeaterEmployeeDetailsEdit(),
    ),

    GoRoute(
      path: AppRoutes.subscriptionScreenPath,
      name: AppRoutes.subscriptionScreen,
      builder: (context, state) {
        final extra = state.extra;

        bool showSkip = false;
        if (extra is bool) {
          showSkip = extra;
        } else if (extra is Map<String, dynamic>) {
          showSkip = extra['showSkip'] as bool? ?? false;
        }

        return SubscriptionScreen(showSkip: showSkip);
      },
    ),
  ],
);
