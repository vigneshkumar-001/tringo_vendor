// import 'package:flutter/material.dart';
//
// import '../../../../Core/Const/app_color.dart';
// import '../../../../Core/Const/app_images.dart';
// import '../../../../Core/Utility/app_textstyles.dart';
// import '../../../../Core/Widgets/common_container.dart';
//
// class NoDataScreens extends StatefulWidget {
//   const NoDataScreens({super.key});
//
//   @override
//   State<NoDataScreens> createState() => _NoDataScreensState();
// }
//
// class _NoDataScreensState extends State<NoDataScreens> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 160),
//           child: Column(
//             children: [
//               Image.asset(AppImages.noDataGif),
//               SizedBox(height: 40),
//
//               Center(
//                 child: Text(
//                   overflow: TextOverflow.ellipsis,
//                   maxLines: 1,
//                   'This feature is currently under development',
//                   style: AppTextStyles.mulish(
//                     fontSize: 15,
//                     fontWeight: FontWeight.w800,
//                     color: AppColor.darkBlue,
//                   ),
//                 ),
//               ),
//               SizedBox(height: 26),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../Core/Const/app_color.dart';
import '../../../../Core/Const/app_images.dart';
import '../../../../Core/Utility/app_textstyles.dart';
import '../../../../Core/Widgets/app_go_routes.dart';
import '../../../../Core/Widgets/common_container.dart';
import '../../Home Screen/Contoller/employee_home_notifier.dart';
import '../../Home Screen/Model/employee_home_response.dart';

class MoreScreen extends ConsumerStatefulWidget {
  const MoreScreen({super.key});

  @override
  ConsumerState<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends ConsumerState<MoreScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(children: []),
          ),
        ),
      ),
    );
  }
}
