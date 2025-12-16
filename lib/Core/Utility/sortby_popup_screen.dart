import 'package:flutter/material.dart';
import 'package:tringo_vendor_new/Core/Utility/app_textstyles.dart';
import '../Const/app_color.dart';
import '../Const/app_images.dart';
import '../Widgets/common_container.dart';

class SortbyPopupScreen extends StatelessWidget {
  const SortbyPopupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const topRadius = Radius.circular(20);
    final kb = MediaQuery.of(context).viewInsets.bottom;
    return SizedBox.expand(
      child: DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.96,
        expand: false, // <-- important: don’t force to fill
        builder: (context, scrollController) {
          return ClipRRect(
            clipBehavior: Clip.antiAlias,
            borderRadius: const BorderRadius.vertical(top: topRadius),
            child: Material(
              color: AppColor.white,
              child: SafeArea(
                top: false,
                child: ListView(
                  controller: scrollController, // <-- wire the controller
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 25,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                  ),
                  children: [
                    Row(
                      children: [
                        Text(
                          'Filter',
                          style: AppTextStyles.mulish(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColor.darkBlue,
                          ),
                        ),
                        Spacer(),
                        Text(
                          'Clear All',
                          style: AppTextStyles.mulish(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            color: AppColor.lightRed,
                          ),
                        ),
                        SizedBox(width: 15),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColor.lowLightRed,
                              borderRadius: BorderRadius.circular(50),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 17,
                              vertical: 10,
                            ),
                            child: Image.asset(AppImages.closeImage, height: 9),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 30),

                    CommonContainer.sortbyPopup(
                      image: AppImages.rightArrow,
                      iconColor: AppColor.blue,
                      text1: 'Collection Count Low',
                      text2: 'High',
                      onTap: () {},
                      horizontalDivider: true,
                    ),
                    SizedBox(height: 19),

                    CommonContainer.sortbyPopup(
                      image: AppImages.rightArrow,
                      iconColor: AppColor.blue,
                      text1: 'Collection Count High',
                      text2: 'Low',
                      onTap: () {},
                      horizontalDivider: true,
                    ),
                    SizedBox(height: 19),

                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
