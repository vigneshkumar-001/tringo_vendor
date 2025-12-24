import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tringo_vendor_new/Core/Const/app_color.dart';
import 'package:tringo_vendor_new/Core/Const/app_images.dart';
import 'package:tringo_vendor_new/Core/Utility/app_textstyles.dart';

import '../Core/Widgets/app_go_routes.dart';

class PaySuccessAndCancel extends StatefulWidget {
  final String planId;
  final String startAt;
  final String endsAt;
  final String tittle;
  const PaySuccessAndCancel({
    super.key,
    required this.planId,
    required this.startAt,
    required this.endsAt,
    required this.tittle,
  });

  @override
  State<PaySuccessAndCancel> createState() => _PaySuccessAndCancelState();
}

class _PaySuccessAndCancelState extends State<PaySuccessAndCancel> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColor.emeraldGreen, AppColor.green],
          ),
          image: DecorationImage(
            image: AssetImage(AppImages.paymentBCImage),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 230),
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 30,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                          20,
                        ), // Make sure blur follows the shape
                        child: BackdropFilter(
                          filter: ImageFilter.blur(
                            sigmaX: 10,
                            sigmaY: 10,
                          ), // This creates the frosted effect
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 24,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(
                                0.15,
                              ), // translucent color
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withOpacity(
                                  0.3,
                                ), // glass border
                                width: 1.5,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                top: 95,
                                right: 25,
                                left: 25,
                                bottom: 25,
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    'Activated',
                                    textAlign: TextAlign.center,
                                    style: AppTextStyles.mulish(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                      color: AppColor.white,
                                    ),
                                  ),
                                  Text(
                                    '${widget.tittle} Plan',
                                    textAlign: TextAlign.center,
                                    style: AppTextStyles.mulish(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                      color: AppColor.white,
                                    ),
                                  ),
                                  SizedBox(height: 12),
                                  Text(
                                    'Paid for ${widget.startAt} to ${widget.endsAt}',
                                    style: AppTextStyles.mulish(
                                      fontSize: 14,
                                      color: AppColor.white,
                                    ),
                                  ),
                                  // SizedBox(height: 6),
                                  // Text(
                                  //   'TXN Id: HGH8J9G8HGU',
                                  //   style: AppTextStyles.mulish(
                                  //     fontSize: 14,
                                  //     fontWeight: FontWeight.w700,
                                  //     color: AppColor.white,
                                  //   ),
                                  // ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Container(
                    //   margin: const EdgeInsets.symmetric(
                    //     horizontal: 24,
                    //     vertical: 30,
                    //   ),
                    //   padding: const EdgeInsets.symmetric(
                    //     horizontal: 20,
                    //     vertical: 24,
                    //   ),
                    //   decoration: BoxDecoration(
                    //     color: AppColor.black.withOpacity(0.35),
                    //     borderRadius: BorderRadius.circular(20),
                    //   ),
                    //   child: Padding(
                    //     padding: const EdgeInsets.only(
                    //       top: 95,
                    //       right: 25,
                    //       left: 25,
                    //       bottom: 25,
                    //     ),
                    //     child: Column(
                    //       children: [
                    //         Text(
                    //           'Activated',
                    //           textAlign: TextAlign.center,
                    //           style: AppTextStyles.mulish(
                    //             fontSize: 22,
                    //             fontWeight: FontWeight.w900,
                    //             color: AppColor.white,
                    //           ),
                    //         ),
                    //         Text(
                    //           '1 Year Premium Plan',
                    //           textAlign: TextAlign.center,
                    //           style: AppTextStyles.mulish(
                    //             fontSize: 22,
                    //             fontWeight: FontWeight.w900,
                    //             color: AppColor.white,
                    //           ),
                    //         ),
                    //         SizedBox(height: 12),
                    //         Text(
                    //           'Paid for 18-Jun-2025 to 18-Jun-2026',
                    //           style: AppTextStyles.mulish(
                    //             fontSize: 14,
                    //             color: AppColor.white,
                    //           ),
                    //         ),
                    //         SizedBox(height: 6),
                    //         Text(
                    //           'TXN Id: HGH8J9G8HGU',
                    //           style: AppTextStyles.mulish(
                    //             fontSize: 14,
                    //             fontWeight: FontWeight.w700,
                    //             color: AppColor.white,
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                    SizedBox(height: 20),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: AppColor.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 17.5,
                                horizontal: 33,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(AppImages.shareImage, height: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'Share',
                                    style: AppTextStyles.mulish(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppColor.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          SizedBox(width: 12),

                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                context.goNamed(
                                  AppRoutes.home,
                                  extra: {"forceHome": true},
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColor.black,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 17.5,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Go to Shop',
                                        style: AppTextStyles.mulish(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: AppColor.white,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Image.asset(
                                        AppImages.rightStickArrow,
                                        height: 18,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 30),
                  ],
                ),
              ),
              Positioned(
                top: 75,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 58,
                    vertical: 60,
                  ),
                  child: Image.asset(
                    AppImages.crown,
                    height: 219,
                    width: 264,
                    fit: BoxFit.contain,
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
