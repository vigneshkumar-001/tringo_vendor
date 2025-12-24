import 'package:flutter/material.dart';
import '../../../Core/Const/app_color.dart';
import '../../../Core/Const/app_images.dart';
import '../../../Core/Utility/app_textstyles.dart';
import '../../../Core/Widgets/common_container.dart';

class NoDataScreen extends StatelessWidget {
  final String title;
  final String message;
  final String buttonText;
  final VoidCallback? onBackTap;
  final VoidCallback? onTopBackTap;
  final String? imagePath;
  final bool showTopBackArrow;
  final bool showBottomButton;
  final double? fontSize;
  final double? messageFontSize;
  final FontWeight? messageFontWeight;

  final EdgeInsetsGeometry padding;

  const NoDataScreen({
    super.key,
    this.title = 'No Data Found',
    this.message =
        'No matching records were detected. Kindly adjust your inputs and try again.',
    this.buttonText = 'Back',
    this.onBackTap,
    this.onTopBackTap,
    this.imagePath,
    this.fontSize = 24,
    this.messageFontSize = 14,
    this.messageFontWeight = FontWeight.w500,
    this.showTopBackArrow = true,
    this.showBottomButton = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white,
      body: SafeArea(
        child: Padding(
          padding: padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showTopBackArrow)
                CommonContainer.topLeftArrow(
                  onTap: onTopBackTap ?? () => Navigator.of(context).maybePop(),
                ),
              SizedBox(height: 160),

              Image.asset(imagePath ?? AppImages.noDataGif),

              SizedBox(height: 30),

              Center(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.mulish(
                    fontSize: fontSize!,
                    fontWeight: FontWeight.bold,
                    color: AppColor.darkBlue,
                  ),
                ),
              ),

              SizedBox(height: 11),

              Text(
                message,
                textAlign: TextAlign.center,
                style: AppTextStyles.mulish(
                  fontSize: messageFontSize!,
                  fontWeight: messageFontWeight!,
                  color: AppColor.darkGrey,
                ),
              ),

              SizedBox(height: 26),

              if (showBottomButton)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 120),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.skyBlue,
                      foregroundColor: AppColor.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        // side: BorderSide(color: AppColor.blue, width: 2),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed:
                        onBackTap ?? () => Navigator.of(context).maybePop(),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          AppImages.leftStickArrow,
                          height: 19,
                          color: AppColor.white,
                        ),
                        SizedBox(width: 8),
                        Text(
                          buttonText,
                          style: AppTextStyles.mulish(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            color: AppColor.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:tringo_app/Core/Utility/app_Images.dart';
// import 'package:tringo_app/Core/Utility/app_color.dart';
// import 'package:tringo_app/Core/Utility/google_font.dart';
// import 'package:tringo_app/Core/Widgets/common_container.dart';
//
// class NoDataScreen extends StatefulWidget {
//   const NoDataScreen({super.key});
//
//   @override
//   State<NoDataScreen> createState() => _NoDataScreenState();
// }
//
// class _NoDataScreenState extends State<NoDataScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16),
//           child: Column(
//             children: [
//               CommonContainer.leftSideArrow(onTap: () {}),
//               Image.asset(AppImages.noDataGif),
//               SizedBox(height: 30),
//               Text(
//                 'No Data Found',
//                 style: AppTextStyles.mulish(
//                   fontSize: 24,
//                   fontWeight: FontWeight.w800,
//                   color: AppColor.darkBlue,
//                 ),
//               ),
//               SizedBox(height: 11),
//               Text(
//                 overflow: TextOverflow.ellipsis,
//                 maxLines: 2,
//                 'No matching records were detected. Kindly adjust your inputs and try again.',
//                 style: AppTextStyles.mulish(
//                   fontSize: 24,
//                   fontWeight: FontWeight.w800,
//                   color: AppColor.darkBlue,
//                 ),
//               ),
//               SizedBox(height: 26),
//               ElevatedButton(
//                 onPressed: () {},
//                 child: Row(
//                   children: [
//                     Image.asset(
//                       AppImages.leftSideArrow,
//                       height: 19,
//                       color: AppColor.white,
//                     ),
//                     SizedBox(width: 8),
//                     Text(
//                       'Back',
//                       style: AppTextStyles.mulish(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 16,
//                         color: AppColor.white,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
