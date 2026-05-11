import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../Core/Const/app_color.dart';
import '../../../Core/Const/app_images.dart';
import '../../../Core/Utility/app_textstyles.dart';
import '../../../Core/Widgets/common_container.dart';
import '../Controller/subscription_notifier.dart';
import 'subscription_screen.dart';

class SubscriptionHistory extends ConsumerStatefulWidget {
  final String businessProfileId;
  const SubscriptionHistory({
    super.key,
    required this.businessProfileId,
  });

  @override
  ConsumerState<SubscriptionHistory> createState() =>
      _SubscriptionHistoryState();
}

class _SubscriptionHistoryState extends ConsumerState<SubscriptionHistory> {
  void _extendPlan() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SubscriptionScreen(
          businessProfileId: widget.businessProfileId,
          showSkip: false,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final id = widget.businessProfileId.trim();
      if (id.isEmpty) return;
      ref.read(subscriptionNotifier.notifier).getCurrentPlan(
            businessProfileId: id,
            force: true,
            keepExisting: true,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final subState = ref.watch(subscriptionNotifier);
    final planData = subState.currentPlanResponse?.data;
    final plan = planData?.plan;
    final period = planData?.period;
    final payment = planData?.payment;
    final invoice = planData?.invoice;
    final premiumFeatureLabels = (plan?.features ?? const [])
        .where((f) => f.premium)
        .toList()
      ..sort((a, b) => a.sort.compareTo(b.sort));
    final premiumFeatureTexts = premiumFeatureLabels
        .map((f) => f.label.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    return Scaffold(
      backgroundColor: Color(0xFFF3F3F3),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            children: [
              SizedBox(height: 15),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 25,
                        vertical: 13,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColor.white4),
                        shape: BoxShape.circle,
                        color: AppColor.white,
                      ),
                      child: Image.asset(
                        AppImages.leftArrow,
                        height: 15,
                        color: AppColor.black,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              if (subState.isLoading && planData == null) ...[
                const SizedBox(height: 40),
                const Center(child: CircularProgressIndicator()),
                const SizedBox(height: 40),
              ] else if (subState.error != null) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    subState.error!,
                    style: AppTextStyles.mulish(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Subscription ',
                      style: AppTextStyles.mulish(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                        fontSize: 22,
                      ),
                    ),
                    TextSpan(
                      text: 'History',
                      style: AppTextStyles.mulish(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 25,
                      ),
                      decoration: BoxDecoration(
                        color: AppColor.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    plan != null
                                        ? '${plan.durationLabel} Premium Plan'
                                        : 'Premium Plan',
                                    style: AppTextStyles.mulish(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 15),
                                  Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: 'Paid on ',
                                          style: AppTextStyles.mulish(
                                            color: AppColor.gray84,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        TextSpan(
                                          text:
                                              period?.startsAtLabel ??
                                              (payment?.paidAt ?? 'N/A'),
                                          style: AppTextStyles.mulish(
                                            color: AppColor.gray84,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: 'Expires on ',
                                          style: AppTextStyles.mulish(
                                            color: AppColor.gray84,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        TextSpan(
                                          text: period?.endsAtLabel ?? 'N/A',
                                          style: AppTextStyles.mulish(
                                            color: AppColor.gray84,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Right side image
                            Image.asset(AppImages.crown, height: 90),
                          ],
                        ),
                      ),
                    ),
              ),
              SizedBox(height: 20),
            
                  SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () async {
                            final inv = invoice;
                            if (inv == null) return;

                            final url = inv.downloadUrl.trim().isNotEmpty
                                ? inv.downloadUrl.trim()
                                : inv.url.trim();
                            if (url.isEmpty) return;

                            final uri = Uri.tryParse(url);
                            if (uri == null) return;

                            try {
                              await launchUrl(
                                uri,
                                mode: LaunchMode.externalApplication,
                              );
                            } catch (_) {
                              // no-op
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: AppColor.black,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Row(
                              children: [
                                Image.asset(AppImages.downLoad, height: 20),
                                SizedBox(width: 10),
                                Text(
                                  'Download Invoice',
                                  style: AppTextStyles.mulish(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: AppColor.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        GestureDetector(
                          onTap: _extendPlan,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: AppColor.white,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: AppColor.white4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.autorenew,
                                  size: 18,
                                  color: Colors.black,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Extend My Plan',
                                  style: AppTextStyles.mulish(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        GestureDetector(
                          onTap: () {
                            showDialog<void>(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text('Cancel subscription'),
                                  content: const Text(
                                    'To cancel your subscription, please contact support.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Close'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: AppColor.lightRed,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Row(
                              children: [
                                Image.asset(
                                  AppImages.closeImage,
                                  height: 20,
                                  color: AppColor.white,
                                ),
                                SizedBox(width: 5),
                                Text(
                                  'Cancel Subscription',
                                  style: AppTextStyles.mulish(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
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
                  SizedBox(height: 50),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Column(
                      children: [
                        CommonContainer.horizonalDivider(isSubscription: true),
                        SizedBox(height: 20),
                        Text(
                          "Premium Tringo’s Features",
                          style: AppTextStyles.mulish(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 20),
                        _ComparisonCard(features: premiumFeatureTexts),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ComparisonCard extends StatelessWidget {
  final List<String> features;
  const _ComparisonCard({required this.features});

  @override
  Widget build(BuildContext context) {
    const premiumGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF0797FD), Color(0xFF07C8FD), Color(0xFF0797FD)],
    );

    final rows = this.features.isNotEmpty
        ? this.features.map((t) => (text: t, premium: true)).toList()
        : const <({String text, bool premium})>[
            (text: 'Search engine visibility upto 5km', premium: true),
            (text: 'Unlimited Reply in Smart Connect', premium: true),
            (text: 'Reach your entire district', premium: true),
            (text: 'Search engine priority', premium: true),
            (text: 'Place 2 ads per month', premium: true),
            (text: 'Get Trusted Batch to gain clients', premium: true),
            (text: 'View Followers Picture', premium: true),
          ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0),
      child: Container(
        decoration: BoxDecoration(
          color: AppColor.white, // your container color stays
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              spreadRadius: 12,
              color: Colors.black.withOpacity(.05),
              blurRadius: 25,
              offset: const Offset(8, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            children: [
              // Background bands (left = cardColor shows; middle = Free; right = Premium gradient)
              // Make backgrounds fill the card area
              Positioned.fill(
                child: Row(
                  children: [
                    const Expanded(flex: 3, child: SizedBox.shrink()),
                    // Free
                    Expanded(
                      flex: 1,
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: premiumGradient,
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(18),
                            bottomRight: Radius.circular(18),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(flex: 3, child: Text('')),

                        Expanded(
                          flex: 1,
                          child: Center(
                            child: Text(
                              'Premium',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),

                    ...rows.map(
                      (f) => Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                              ),
                              child: Text(
                                f.text,
                                style: AppTextStyles.mulish(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: AppColor.darkBlue,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Center(
                              child:
                                  f.premium
                                      ? star(color: AppColor.white)
                                      : const SizedBox.shrink(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

///new
// class _ComparisonCard extends StatelessWidget {
//   const _ComparisonCard({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     const premiumGradient = LinearGradient(
//       begin: Alignment.topCenter,
//       end: Alignment.bottomCenter,
//       colors: [Color(0xFF0797FD), Color(0xFF07C8FD), Color(0xFF0797FD)],
//     );
//
//     const features = <({String text, bool premium})>[
//       (text: 'Search engine visibility upto 5km', premium: true),
//       (text: 'Unlimited Reply in Smart Connect', premium: true),
//       (text: 'Reach your entire district', premium: true),
//       (text: 'Search engine priority', premium: true),
//       (text: 'Place 2 ads per month', premium: true),
//       (text: 'Get Trusted Batch to gain clients', premium: true),
//       (text: 'View Followers Picture', premium: true),
//     ];
//
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(18),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             spreadRadius: 3,
//             blurRadius: 10,
//             offset: const Offset(2, 4),
//           ),
//         ],
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Left side: feature texts
//           Expanded(
//             flex: 3,
//             child: Padding(
//               padding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: features
//                     .map(
//                       (f) => Padding(
//                         padding: EdgeInsets.symmetric(vertical: 8),
//                         child: Text(
//                           f.text,
//                           style: AppTextStyles.mulish(
//                             color: AppColor.darkBlue,
//                             fontSize: 14,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ),
//                     )
//                     .toList(),
//               ),
//             ),
//           ),
//
//           // Right side: premium column
//           Expanded(
//             flex: 2,
//             child: Container(
//               decoration: const BoxDecoration(
//                 gradient: premiumGradient,
//                 borderRadius: BorderRadius.only(
//                   topRight: Radius.circular(18),
//                   bottomRight: Radius.circular(18),
//                 ),
//               ),
//               child: Padding(
//                 padding: EdgeInsets.symmetric(vertical: 12, horizontal: 6),
//                 child: Column(
//                   children: [
//                     Text(
//                       'Premium',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontWeight: FontWeight.w700,
//                         fontSize: 14,
//                       ),
//                     ),
//                     SizedBox(height: 8),
//                     ...features.map(
//                       (f) => Padding(
//                         padding: EdgeInsets.symmetric(vertical: 12),
//                         child: Icon(Icons.star, color: Colors.white, size: 18),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

Widget star({Color? color = AppColor.white}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 14),
    child: Icon(Icons.star_rounded, color: color),
  );
}
