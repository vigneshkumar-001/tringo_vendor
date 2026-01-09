// lib/Core/Routing/app_go_routes.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ✅ Offline screens
import 'package:tringo_vendor_new/Core/Offline_Data/Screens/offline_demo_screen.dart';

// ✅ Your existing imports
import 'package:tringo_vendor_new/Core/Widgets/bottom_navigation_bar.dart';
import 'package:tringo_vendor_new/Presentation/Shop%20Details%20Edit/Screen/shop_details_edit.dart';

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
import '../../Presentation/Owner Screen/Screens/owner_info_screens.dart';
import '../../Presentation/Privacy Policy/Screen/privacy_policy.dart';
import '../../Presentation/ShopInfo/Screens/search_keyword.dart';
import '../../Presentation/ShopInfo/Screens/shop_category_info.dart';
import '../../Presentation/ShopInfo/Screens/shop_photo_info.dart';
import '../../Presentation/Shops Details/Screen/shops_details.dart';
import '../../Presentation/subscription/Screen/subscription_screen.dart';
import '../../Splash_screen.dart';
import '../../dummy_screen.dart';
import '../../main.dart';
import 'heater_bottom_navigation_bar.dart';

// ✅ IMPORTANT: make sure these providers exist in your project
import 'package:tringo_vendor_new/Core/Offline_Data/provider/offline_providers.dart';

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
  static const String heaterAddEmployee = 'heaterAddEmployee';
  static const String mobileNumberVerify = 'MobileNumberVerify';
  static const String privacyPolicy = 'privacyPolicy';
  static const String heaterEmployeeDetails = 'HeaterEmployeeDetails';
  static const String heaterEmployeeDetailsEdit = 'HeaterEmployeeDetailsEdit';
  static const String shopDetailsEdit = 'ShopDetailsEdit';

  // ✅ OFFLINE ROUTES (2 screens)
  static const String noInternet = 'NoInternet';
  static const String offlineDemo = 'OfflineDemo';

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
  static const String shopDetailsEditPath = '/ShopDetailsEdit';
  static const String heaterEmployeeDetailsEditPath =
      '/heaterEmployeeDetailsEditPath';

  // ✅ OFFLINE PATHS
  static const String noInternetPath = '/no-internet';
  static const String offlineDemoPath = '/offline-demo';
}

/// ✅ Helps GoRouter refresh when stream emits
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _sub = stream.listen((_) => notifyListeners());
  }
  late final StreamSubscription<dynamic> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
final GlobalKey<NavigatorState> rootNavKey = GlobalKey<NavigatorState>();
/// ✅ Use provider-based router (important for redirect)
final goRouterProvider = Provider<GoRouter>((ref) {
  // watch so router rebuilds with provider changes
  final internetAsync = ref.watch(internetStatusProvider);
  final isOnline = internetAsync.value ?? true;

  return GoRouter(
    navigatorKey: rootNavKey, // ✅ IMPORTANT
    initialLocation: AppRoutes.splashScreenPath,

    // ✅ refreshes redirects when provider updates
    refreshListenable: ref.watch(routerRefreshProvider),

    // ✅ ROLE + OFFLINE REDIRECT LOGIC
    redirect: (context, state) async {
      final isOnline = ref.read(internetStatusProvider).value ?? true;
      final prefs = await SharedPreferences.getInstance();
      final role = (prefs.getString('role') ?? '').toUpperCase();

      final location = state.matchedLocation;

      final isOnNoInternet = location == AppRoutes.noInternetPath;
      final isOnOfflineDemo = location == AppRoutes.offlineDemoPath;

      // ✅ Pages EMPLOYEE is allowed to use even when offline (registration flow)
      const employeeOfflineAllowed = <String>{
        AppRoutes.offlineDemoPath,
        AppRoutes.ownerInfoPath,
        AppRoutes.shopCategoryInfoPath,
        AppRoutes.shopPhotoInfoPath,
        AppRoutes.searchKeywordPath,
        AppRoutes.heaterRegister1Path,
        AppRoutes.heaterRegister2Path,
        AppRoutes.vendorCompanyInfoPath,
        AppRoutes.vendorCompanyPhotoPath,
        AppRoutes.addProductListPath,
        AppRoutes.productCategoryScreensPath,
      };

      if (!isOnline) {
        // ✅ EMPLOYEE: allow registration flow pages
        if (role == 'EMPLOYEE') {
          if (employeeOfflineAllowed.contains(location)) return null;

          // anything else -> back to offline demo
          return AppRoutes.offlineDemoPath;
        }

        // ✅ NON-EMPLOYEE: only no-internet page
        return isOnNoInternet ? null : AppRoutes.noInternetPath;
      }

      return null;
    },

    routes: [
      // ✅ OFFLINE: No Internet (for non-employee)
      GoRoute(
        path: AppRoutes.noInternetPath,
        name: AppRoutes.noInternet,
        builder: (context, state) => const NoInternetScreen(),
      ),

      // ✅ OFFLINE: Demo mode (only for EMPLOYEE)
      GoRoute(
        path: AppRoutes.offlineDemoPath,
        name: AppRoutes.offlineDemo,
        builder: (context, state) => const OfflineDemoScreen(),
      ),

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
          return MobileNumberVerify(loginNumber: phone, simToken: simToken);
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
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          final forceHome = extra['forceHome'] == true;
          return CommonBottomNavigation(initialIndex: 0, forceHome: forceHome);
        },
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
          final employeeId = args['employeeId'] as String?;

          return ShopCategoryInfo(
            isService: isService,
            isIndividual: isIndividual,
            initialShopNameEnglish: args['initialShopNameEnglish'] as String?,
            initialShopNameTamil: args['initialShopNameTamil'] as String?,
            pages: args['pages'] as String?,
            employeeId: employeeId,
          );
        },
      ),

      GoRoute(
        path: AppRoutes.shopPhotoInfoPath,
        name: AppRoutes.shopPhotoInfo,
        builder: (context, state) {
          final extra = state.extra;

          String pageName = '';
          List<String?>? initialImageUrls;

          if (extra is String) {
            pageName = extra;
          } else if (extra is Map) {
            pageName = (extra["from"] as String?) ?? '';
            initialImageUrls =
                (extra["initialImageUrls"] as List?)?.cast<String?>();
          }

          return ShopPhotoInfo(
            pages: pageName,
            initialImageUrls: initialImageUrls,
          );
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
      // GoRoute(
      //   path: AppRoutes.shopsDetailsPath,
      //   name: AppRoutes.shopsDetails,
      //   builder: (context, state) {
      //     final extra = state.extra;
      //
      //     bool backDisabled = false;
      //     bool fromSubscription = false;
      //     String? shopId;
      //
      //     if (extra is Map<String, dynamic>) {
      //       backDisabled = extra['backDisabled'] as bool? ?? false;
      //       fromSubscription = extra['fromSubscriptionSkip'] as bool? ?? false;
      //       shopId = extra['shopId'] as String?;
      //     } else if (extra is bool) {
      //       fromSubscription = extra;
      //     }
      //
      //     return ShopsDetails(
      //       backDisabled: backDisabled,
      //       fromSubscriptionSkip: fromSubscription,
      //       shopId: shopId,
      //     );
      //   },
      // ),
      GoRoute(
        path: AppRoutes.shopsDetailsPath,
        name: AppRoutes.shopsDetails,
        builder: (context, state) {
          final Map<String, dynamic> extra =
              state.extra as Map<String, dynamic>? ?? {};

          return ShopsDetails(
            backDisabled: extra['backDisabled'] as bool? ?? false,
            fromSubscriptionSkip:
            extra['fromSubscriptionSkip'] as bool? ?? false,
            shopId: extra['shopId'] as String?,
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
        path: AppRoutes.heaterEmployeeDetailsPath,
        name: AppRoutes.heaterEmployeeDetails,
        builder: (context, state) {
          final employeeId = state.extra as String;
          return HeaterEmployeeDetails(employeeId: employeeId);
        },
      ),
      GoRoute(
        path: AppRoutes.heaterEmployeeDetailsEditPath,
        name: AppRoutes.heaterEmployeeDetailsEdit,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;

          return HeaterEmployeeDetailsEdit(
            employeeId: (extra['employeeId'] ?? '') as String,
            name: extra['name'] as String?,
            employeeCode: extra['employeeCode'] as String?,
            phoneNumber: extra['phoneNumber'] as String?,
            avatarUrl: extra['avatarUrl'] as String?,
            totalAmount: extra['totalAmount']?.toString(),
            isActive: (extra['isActive'] as bool?) ?? true,
            email: extra['email'] as String?,
            emergencyContactName: extra['emergencyContactName'] as String?,
            emergencyContactRelationship:
                extra['emergencyContactRelationship'] as String?,
            emergencyContactPhone: extra['emergencyContactPhone'] as String?,
            aadharNumber: extra['aadharNumber'] as String?,
            aadharDocumentUrl: extra['aadharDocumentUrl'] as String?,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.shopDetailsEditPath,
        name: AppRoutes.shopDetailsEdit,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>; // ← LINE 429
          final String shopId = extra['shopId'];
          final String businessProfileId = extra['businessProfileId'];

          return ShopDetailsEdit(
            shopId: shopId,
            businessProfileId: businessProfileId,
          );
        },
      ),

    ],
  );
});

/// ---------------------------------------------------------------------------
/// ✅ Dummy NoInternetScreen (REMOVE if you already have your own screen)
/// Replace with your existing NoInternet UI widget if available.
/// ---------------------------------------------------------------------------
class NoInternetScreen extends StatelessWidget {
  const NoInternetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('No Internet Connection', style: TextStyle(fontSize: 18)),
      ),
    );
  }
}

// // lib/Core/Routing/app_go_routes.dart
// import 'package:go_router/go_router.dart';
// import 'package:tringo_vendor_new/Core/Widgets/bottom_navigation_bar.dart';
// import 'package:tringo_vendor_new/Presentation/Shop%20Details%20Edit/Screen/shop_details_edit.dart';
//
// import '../../Presentation/AddProduct/Screens/add_product_list.dart';
// import '../../Presentation/AddProduct/Screens/product_category_screens.dart';
// import '../../Presentation/Heater/Add Vendor Employee/Screen/employee_approval_pending.dart';
// import '../../Presentation/Heater/Add Vendor Employee/Screen/employee_approval_rejected.dart';
// import '../../Presentation/Heater/Add Vendor Employee/Screen/heater_add_employee.dart';
// import '../../Presentation/Heater/Employee Details/Screen/heater_employee_details.dart';
// import '../../Presentation/Heater/Employee details-edit/Screen/heater_employee_details_edit.dart';
// import '../../Presentation/Heater/Heater Register/Screen/heater_register_1.dart';
// import '../../Presentation/Heater/Heater Register/Screen/heater_register_2.dart';
// import '../../Presentation/Heater/Vendor Company Info/Screen/vendor_company_info.dart';
// import '../../Presentation/Heater/Vendor Company Info/Screen/vendor_company_photo.dart';
// import '../../Presentation/Home Screen/home_screen.dart';
// import '../../Presentation/Login Screen/Screens/login_mobile_number.dart';
// import '../../Presentation/Mobile Nomber Verify/Screen/mobile_number_verify.dart';
// import '../../Presentation/OTP Screen/Screens/otp_screen.dart';
// import '../../Presentation/Owner Screen/Screens/owner_info_screens.dart';
// import '../../Presentation/Privacy Policy/Screen/privacy_policy.dart';
// import '../../Presentation/ShopInfo/Screens/search_keyword.dart';
// import '../../Presentation/ShopInfo/Screens/shop_category_info.dart';
// import '../../Presentation/ShopInfo/Screens/shop_photo_info.dart';
// import '../../Presentation/Shops Details/Screen/shops_details.dart';
// import '../../Presentation/subscription/Screen/subscription_screen.dart';
// import '../../Splash_screen.dart';
// import 'heater_bottom_navigation_bar.dart';
//
// class AppRoutes {
//   static const String splashScreen = 'splashScreen';
//   static const String login = 'login';
//   static const String otp = 'otp';
//   static const String home = 'home';
//   static const String ownerInfo = 'ownerInfo';
//   static const String shopCategoryInfo = 'ShopCategoryInfo';
//   static const String shopPhotoInfo = 'ShopPhotoInfo';
//   static const String searchKeyword = 'SearchKeyword';
//   static const String productCategoryScreens = 'ProductCategoryScreens';
//   static const String addProductList = 'AddProductList';
//   static const String shopsDetails = 'ShopsDetails';
//   static const String heaterRegister1 = 'HeaterRegister1';
//   static const String heaterRegister2 = 'HeaterRegister2';
//   static const String vendorCompanyInfo = 'VendorCompanyInfo';
//   static const String vendorCompanyPhoto = 'VendorCompanyPhoto';
//   static const String heaterHomeScreen = 'HeaterHomeScreen';
//   static const String employeeApprovalPending = 'EmployeeApprovalPending';
//   static const String heaterAddEmployee = 'heaterAddEmployee';
//   static const String mobileNumberVerify = 'MobileNumberVerify';
//   static const String privacyPolicy = 'privacyPolicy';
//   static const String heaterEmployeeDetails = 'HeaterEmployeeDetails';
//   static const String heaterEmployeeDetailsEdit = 'HeaterEmployeeDetailsEdit';
//   // static const String subscriptionScreen = 'SubscriptionScreen';
//   static const String shopDetailsEdit = 'ShopDetailsEdit';
//
//   static const String splashScreenPath = '/splashScreen';
//   static const String loginPath = '/login';
//   static const String otpPath = '/otp';
//   static const String homePath = '/home';
//   static const String ownerInfoPath = '/ownerInfo';
//   static const String shopCategoryInfoPath = '/ShopCategoryInfo';
//   static const String shopPhotoInfoPath = '/ShopPhotoInfo';
//   static const String searchKeywordPath = '/SearchKeyword';
//   static const String productCategoryScreensPath = '/ProductCategoryScreens';
//   static const String addProductListPath = '/AddProductList';
//   static const String shopsDetailsPath = '/ShopsDetails';
//   static const String heaterRegister1Path = '/HeaterRegister1';
//   static const String heaterRegister2Path = '/HeaterRegister2';
//   static const String vendorCompanyInfoPath = '/VendorCompanyInfo';
//   static const String vendorCompanyPhotoPath = '/VendorCompanyPhoto';
//   static const String heaterHomeScreenPath = '/HeaterHomeScreen';
//   static const String employeeApprovalPendingPath = '/EmployeeApprovalPending';
//   static const String heaterAddEmployeePath = '/heaterAddEmployeePath';
//   static const String mobileNumberVerifyPath = '/MobileNumberVerify';
//   static const String privacyPolicyPath = '/privacyPolicy';
//   static const String heaterEmployeeDetailsPath = '/HeaterEmployeeDetails';
//   // static const String subscriptionScreenPath = '/SubscriptionScreen';
//   static const String shopDetailsEditPath = '/ShopDetailsEdit';
//
//   static const String heaterEmployeeDetailsEditPath =
//       '/heaterEmployeeDetailsEditPath';
// }
//
// final goRouter = GoRouter(
//   initialLocation: AppRoutes.splashScreenPath,
//   routes: [
//     GoRoute(
//       path: AppRoutes.splashScreenPath,
//       name: AppRoutes.splashScreen,
//       builder: (context, state) => SplashScreen(),
//     ),
//     GoRoute(
//       path: AppRoutes.loginPath,
//       name: AppRoutes.login,
//       builder: (context, state) => LoginMobileNumber(),
//     ),
//
//     GoRoute(
//       path: AppRoutes.otpPath,
//       name: AppRoutes.otp,
//       builder: (context, state) {
//         final phone = state.extra as String?;
//         return OtpScreen(phoneNumber: phone ?? '');
//       },
//     ),
//
//     GoRoute(
//       path: AppRoutes.mobileNumberVerifyPath,
//       name: AppRoutes.mobileNumberVerify,
//       builder: (context, state) {
//         final args = state.extra as Map<String, dynamic>? ?? {};
//         final phone = args['phone'] as String? ?? '';
//         final simToken = args['simToken'] as String? ?? '';
//
//         return MobileNumberVerify(
//           loginNumber: phone,
//           simToken: simToken, // pass it to the screen
//         );
//       },
//     ),
//     GoRoute(
//       path: AppRoutes.privacyPolicyPath,
//       name: AppRoutes.privacyPolicy,
//       builder: (context, state) => const PrivacyPolicy(),
//     ),
//     GoRoute(
//       path: AppRoutes.homePath,
//       name: AppRoutes.home,
//       builder: (context, state) {
//         final extra = state.extra as Map<String, dynamic>? ?? {};
//         final forceHome = extra['forceHome'] == true;
//
//         return CommonBottomNavigation(
//           initialIndex: 0,
//           forceHome: forceHome,
//         );
//       },
//     ),
//
//     // GoRoute(
//     //   path: AppRoutes.homePath,
//     //   name: AppRoutes.home,
//     //   builder: (context, state) => CommonBottomNavigation(initialIndex: 0),
//     // ),
//     GoRoute(
//       path: AppRoutes.ownerInfoPath,
//       name: AppRoutes.ownerInfo,
//       builder: (context, state) {
//         final extra = state.extra as Map<String, dynamic>?;
//
//         final isService = (extra?['isService'] as bool?) ?? false;
//         final isIndividual = (extra?['isIndividual'] as bool?) ?? true;
//
//         return OwnerInfoScreens(
//           isService: isService,
//           isIndividual: isIndividual,
//         );
//       },
//     ),
//
//     GoRoute(
//       path: AppRoutes.shopCategoryInfoPath,
//       name: AppRoutes.shopCategoryInfo,
//       builder: (context, state) {
//         final args = state.extra as Map<String, dynamic>? ?? {};
//         final isService = args['isService'] as bool? ?? false;
//         final isIndividual = args['isIndividual'] as bool? ?? true;
//         final employeeId = args['employeeId'] as String?; // ✅ NEW
//
//         return ShopCategoryInfo(
//           isService: isService,
//           isIndividual: isIndividual,
//           initialShopNameEnglish: args['initialShopNameEnglish'] as String?,
//           initialShopNameTamil: args['initialShopNameTamil'] as String?,
//           pages: args['pages'] as String?,
//           employeeId: employeeId,
//         );
//       },
//     ),
//     // GoRoute(
//     //   path: AppRoutes.shopPhotoInfoPath,
//     //   name: AppRoutes.shopPhotoInfo,
//     //   builder: (context, state) {
//     //     final pageName = state.extra as String? ?? '';
//     //     return ShopPhotoInfo(pages: pageName);
//     //   },
//     // ),
//     GoRoute(
//       path: AppRoutes.shopPhotoInfoPath,
//       name: AppRoutes.shopPhotoInfo,
//       builder: (context, state) {
//         final extra = state.extra;
//
//         String pageName = '';
//         List<String?>? initialImageUrls;
//
//         if (extra is String) {
//           // ✅ Old call: extra: 'shopCategory'
//           pageName = extra;
//         } else if (extra is Map) {
//           // ✅ New call: extra: {"from": "...", "initialImageUrls": [...]}
//           pageName = (extra["from"] as String?) ?? '';
//           initialImageUrls =
//               (extra["initialImageUrls"] as List?)?.cast<String?>();
//         }
//
//         return ShopPhotoInfo(
//           pages: pageName,
//           initialImageUrls: initialImageUrls,
//         );
//       },
//     ),
//
//     GoRoute(
//       path: AppRoutes.searchKeywordPath,
//       name: AppRoutes.searchKeyword,
//       builder: (context, state) => const SearchKeyword(),
//     ),
//
//     GoRoute(
//       path: AppRoutes.productCategoryScreensPath,
//       name: AppRoutes.productCategoryScreens,
//       builder: (context, state) => const ProductCategoryScreens(),
//     ),
//     GoRoute(
//       path: AppRoutes.addProductListPath,
//       name: AppRoutes.addProductList,
//       builder: (context, state) {
//         final extra = state.extra as Map<String, dynamic>?;
//
//         return AddProductList(isService: extra?['isService'] ?? false);
//       },
//     ),
//
//     GoRoute(
//       path: AppRoutes.shopsDetailsPath,
//       name: AppRoutes.shopsDetails,
//       builder: (context, state) {
//         final extra = state.extra;
//
//         bool backDisabled = false;
//         bool fromSubscription = false;
//         String? shopId;
//
//         if (extra is Map<String, dynamic>) {
//           backDisabled = extra['backDisabled'] as bool? ?? false;
//           fromSubscription = extra['fromSubscriptionSkip'] as bool? ?? false;
//           shopId = extra['shopId'] as String?;
//         } else if (extra is bool) {
//           fromSubscription = extra;
//         }
//
//         return ShopsDetails(
//           backDisabled: backDisabled,
//           fromSubscriptionSkip: fromSubscription,
//           shopId: shopId,
//         );
//       },
//     ),
//     GoRoute(
//       path: AppRoutes.heaterRegister1Path,
//       name: AppRoutes.heaterRegister1,
//       builder: (context, state) {
//         final extra = state.extra as Map<String, dynamic>?;
//
//         final isService = (extra?['isService'] as bool?) ?? false;
//         final isIndividual = (extra?['isIndividual'] as bool?) ?? true;
//
//         return HeaterRegister1(
//           isService: isService,
//           isIndividual: isIndividual,
//         );
//       },
//     ),
//     GoRoute(
//       path: AppRoutes.heaterRegister2Path,
//       name: AppRoutes.heaterRegister2,
//       builder: (context, state) => const HeaterRegister2(),
//     ),
//     GoRoute(
//       path: AppRoutes.vendorCompanyInfoPath,
//       name: AppRoutes.vendorCompanyInfo,
//       builder: (context, state) => const VendorCompanyInfo(),
//     ),
//     GoRoute(
//       path: AppRoutes.vendorCompanyPhotoPath,
//       name: AppRoutes.vendorCompanyPhoto,
//       builder: (context, state) {
//         final pageName = state.extra as String? ?? '';
//         return VendorCompanyPhoto(pages: pageName);
//       },
//     ),
//     GoRoute(
//       path: AppRoutes.heaterAddEmployeePath,
//       name: AppRoutes.heaterAddEmployee,
//       builder: (context, state) => HeaterAddEmployee(),
//     ),
//     GoRoute(
//       path: AppRoutes.heaterHomeScreenPath,
//       name: AppRoutes.heaterHomeScreen,
//       builder: (context, state) => HeaterBottomNavigationBar(initialIndex: 0),
//     ),
//
//     GoRoute(
//       path: AppRoutes.employeeApprovalPendingPath,
//       name: AppRoutes.employeeApprovalPending,
//       builder: (context, state) => EmployeeApprovalPending(),
//     ),
//     GoRoute(
//       path: AppRoutes.heaterEmployeeDetailsPath,
//       name: AppRoutes.heaterEmployeeDetails,
//       builder: (context, state) {
//         final employeeId = state.extra as String;
//         return HeaterEmployeeDetails(employeeId: employeeId);
//       },
//     ),
//
//     GoRoute(
//       path: AppRoutes.heaterEmployeeDetailsEditPath,
//       name: AppRoutes.heaterEmployeeDetailsEdit,
//       builder: (context, state) {
//         final extra = state.extra as Map<String, dynamic>;
//
//         return HeaterEmployeeDetailsEdit(
//           employeeId: (extra['employeeId'] ?? '') as String,
//           name: extra['name'] as String?,
//           employeeCode: extra['employeeCode'] as String?,
//           phoneNumber: extra['phoneNumber'] as String?,
//           avatarUrl: extra['avatarUrl'] as String?,
//           totalAmount: extra['totalAmount']?.toString(),
//
//           isActive: (extra['isActive'] as bool?) ?? true,
//
//           email: extra['email'] as String?,
//           emergencyContactName: extra['emergencyContactName'] as String?,
//           emergencyContactRelationship:
//               extra['emergencyContactRelationship'] as String?,
//           emergencyContactPhone: extra['emergencyContactPhone'] as String?,
//           aadharNumber: extra['aadharNumber'] as String?,
//           aadharDocumentUrl: extra['aadharDocumentUrl'] as String?,
//         );
//       },
//     ),
//     //
//     // GoRoute(
//     //   path: AppRoutes.subscriptionScreenPath,
//     //   name: AppRoutes.subscriptionScreen,
//     //   builder: (context, state) {
//     //     final extra = state.extra;
//     //
//     //     bool showSkip = false;
//     //     if (extra is bool) {
//     //       showSkip = extra;
//     //     } else if (extra is Map<String, dynamic>) {
//     //       showSkip = extra['showSkip'] as bool? ?? false;
//     //     }
//     //
//     //     return SubscriptionScreen(showSkip: showSkip);
//     //   },
//     // ),
//     GoRoute(
//       path: AppRoutes.shopDetailsEditPath,
//       name: AppRoutes.shopDetailsEdit,
//       builder: (context, state) {
//         final extra = state.extra as Map<String, dynamic>;
//
//         final String shopId = extra['shopId'];
//         final String businessProfileId = extra['businessProfileId'];
//
//         return ShopDetailsEdit(
//           shopId: shopId,
//           businessProfileId: businessProfileId,
//         );
//       },
//     ),
//   ],
// );
