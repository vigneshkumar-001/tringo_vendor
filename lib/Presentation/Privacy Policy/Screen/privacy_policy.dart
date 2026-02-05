import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:tringo_vendor_new/Core/Const/app_images.dart';
import 'package:tringo_vendor_new/Core/Utility/app_textstyles.dart';

import '../../../Core/Const/app_color.dart';
import '../../../Core/Utility/app_loader.dart';

import '../../../Core/Widgets/app_go_routes.dart';
import '../controller/terms_and_condition_notifier.dart';

class PrivacyPolicy extends ConsumerStatefulWidget {
  final bool showAcceptReject;
  const PrivacyPolicy({super.key, this.showAcceptReject = true});

  @override
  ConsumerState<PrivacyPolicy> createState() => _PrivacyPolicyState();
}

class _PrivacyPolicyState extends ConsumerState<PrivacyPolicy> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(termsAndConditionNotifierProvider.notifier)
          .fetchTermsAndCondition();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(termsAndConditionNotifierProvider);

    final doc = state.termsAndConditionResponse?.data.data;
    final htmlString = (doc?.contentHtml ?? "").trim();

    final bool hasContent = htmlString.isNotEmpty;
    final bool hasError = state.error != null && state.error!.trim().isNotEmpty;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Image.asset(
              AppImages.loginBCImage,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),

            Positioned.fill(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 35, top: 50),
                      child: Image.asset(AppImages.logo, height: 88, width: 85),
                    ),

                    Padding(
                      padding: const EdgeInsets.only(left: 35, top: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Privacy Policy',
                                style: AppTextStyles.mulish(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 24,
                                  color: AppColor.darkBlue,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                'and',
                                style: AppTextStyles.mulish(
                                  fontSize: 24,
                                  color: AppColor.darkBlue,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'Terms of Service in Tringo',
                            style: AppTextStyles.mulish(
                              fontSize: 24,
                              color: AppColor.darkBlue,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 35),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 35),
                      child: Builder(
                        builder: (_) {
                          if (state.isLoading) {
                            return const Center(
                              child: ThreeDotsLoader(dotColor: AppColor.black),
                            );
                          }

                          if (hasError) {
                            return Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.red.shade200),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "We couldn't load the policy",
                                    style: AppTextStyles.mulish(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: AppColor.darkBlue,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Please check your internet connection and try again.",
                                    style: AppTextStyles.ibmPlexSans(
                                      fontSize: 13,
                                      height: 1.5,
                                      color: AppColor.lightGray2,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    "Details: ${state.error}",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.red,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColor.blue,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 14,
                                        ),
                                      ),
                                      onPressed: () {
                                        ref
                                            .read(
                                              termsAndConditionNotifierProvider
                                                  .notifier,
                                            )
                                            .fetchTermsAndCondition();
                                      },
                                      child: Text(
                                        "Retry",
                                        style: AppTextStyles.mulish(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                          color: AppColor.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          if (!hasContent) {
                            return Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Text(
                                "No policy content available at the moment.",
                                style: AppTextStyles.mulish(
                                  fontSize: 13,
                                  height: 1.5,
                                  color: AppColor.lightGray2,
                                ),
                              ),
                            );
                          }

                          return Html(
                            data: htmlString,
                            style: {
                              "body": Style(
                                margin: Margins.zero,
                                padding: HtmlPaddings.zero,
                                lineHeight: LineHeight.number(1.6),
                                fontSize: FontSize(14),
                                color: AppColor.lightGray2, // match your design
                              ),
                              "p": Style(margin: Margins.only(bottom: 12)),
                              "span": Style(
                                fontSize: FontSize(14),
                                color: AppColor.lightGray2,
                              ),
                            },
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 35),

                    if (widget.showAcceptReject &&
                        hasContent &&
                        !state.isLoading)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 35),
                        child: Row(
                          children: [
                            InkWell(
                              borderRadius: BorderRadius.circular(15),
                              onTap: () {
                                // TODO: Reject action
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColor.textWhite,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 34,
                                  vertical: 20,
                                ),
                                child: Text(
                                  'Reject',
                                  style: AppTextStyles.mulish(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: AppColor.darkBlue,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 15),
                            InkWell(
                              borderRadius: BorderRadius.circular(15),
                              onTap: () {
                                context.pushNamed(AppRoutes.heaterRegister1);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColor.blue,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 50,
                                  vertical: 20,
                                ),
                                child: Text(
                                  'Accept',
                                  style: AppTextStyles.mulish(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: AppColor.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      const SizedBox.shrink(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
