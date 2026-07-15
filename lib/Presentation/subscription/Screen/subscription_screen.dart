import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:tringo_vendor_new/Core/Const/app_logger.dart';
import 'package:tringo_vendor_new/Presentation/subscription/Model/plan_list_response.dart';

import '../../../Core/Const/app_color.dart';
import '../../../Core/Const/app_images.dart';
import '../../../Core/Session/registration_product_seivice.dart';
import '../../../Core/Utility/app_textstyles.dart';
import '../../../Core/Utility/app_prefs.dart';
import '../../../Core/Widgets/app_go_routes.dart';
import '../../pay_success_and_cancel.dart';
import '../Controller/subscription_notifier.dart';
import 'ccavenue_checkout_screen.dart';

// e.g. price="3999", durationDays=365 -> 333 (30-day month, rounded)
int? formatPricePerMonth(String? price, int? durationDays) {
  final numericPrice = double.tryParse(price ?? '');
  if (numericPrice == null || durationDays == null || durationDays <= 0) {
    return null;
  }
  final months = durationDays / 30;
  if (months <= 0) return null;
  return (numericPrice / months).round();
}

class SubscriptionScreen extends ConsumerStatefulWidget {
  final bool showSkip;
  final String businessProfileId;

  const SubscriptionScreen({
    super.key,
    this.showSkip = false,
    required this.businessProfileId,
  });

  @override
  ConsumerState<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends ConsumerState<SubscriptionScreen> {
  // Selected billing index: 0 = 1 Year, 1 = 6 Month, 2 = 3 Month
  int _selectedBilling = 0;

  @override
  void initState() {
    super.initState();
      AppLogger.log.e(widget.businessProfileId);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(subscriptionNotifier.notifier).getPlanList();
      await ref
          .read(subscriptionNotifier.notifier)
          .getCurrentPlan(
            businessProfileId: widget.businessProfileId,
            force: true,
            keepExisting: true,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(subscriptionNotifier);

    final planAmount = state.planListResponse?.data;

    final List<PlanFeature> comparisonFeatures = () {
      final plans = planAmount ?? const <PlanModel>[];
      if (plans.isEmpty) return <PlanFeature>[];

      if (_selectedBilling >= 0 && _selectedBilling < plans.length) {
        final selected = plans[_selectedBilling].features;
        if (selected.isNotEmpty) {
          return selected;
        }
      }

      for (final p in plans) {
        if (p.features.isNotEmpty) return p.features;
      }

      return <PlanFeature>[];
    }();
    return Scaffold(
      backgroundColor: Color(0xFFF3F3F3),
      body: SafeArea(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
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

                          //Spacer(),
                          // if (widget.showSkip)
                          //   InkWell(
                          //     onTap: () {
                          //       RegistrationProductSeivice.instance
                          //           .markUnsubscribed();
                          //
                          //       final router = GoRouter.of(context);
                          //
                          //       // 1️⃣ Close this SubscriptionScreen if it was pushed via Navigator
                          //       if (Navigator.of(context).canPop()) {
                          //         Navigator.of(context).pop();
                          //       }
                          //
                          //       // 2️⃣ Now use go_router to show ShopsDetails
                          //       router.goNamed(
                          //         AppRoutes.shopsDetails,
                          //         extra: {
                          //           'backDisabled': false,
                          //           'fromSubscriptionSkip': true,
                          //         },
                          //       );
                          //     },
                          //     borderRadius: BorderRadius.circular(16),
                          //     child: Padding(
                          //       padding: const EdgeInsets.symmetric(
                          //         horizontal: 18,
                          //         vertical: 5,
                          //       ),
                          //       child: Text(
                          //         'Skip',
                          //         style: AppTextStyles.mulish(
                          //           fontSize: 20,
                          //           fontWeight: FontWeight.w700,
                          //           color: AppColor.darkBlue,
                          //         ),
                          //       ),
                          //     ),
                          //   ),
                          //
                          //
                        ],
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Unlock your business growth",
                        style: AppTextStyles.mulish(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Get more customers .Close more deals faster",
                        style: AppTextStyles.mulish(
                          fontSize: 12,
                          color: AppColor.darkGrey,
                        ),
                      ),
                      SizedBox(height: 15),
                      _ComparisonCard(features: comparisonFeatures),
                       SizedBox(height: 20),
                      // Center(
                      //   child: Text(
                      //     'Cancel Subscription Any time',
                      //     style: AppTextStyles.mulish(color: AppColor.darkGrey),
                      //   ),
                      // ),
                      // SizedBox(height: 20),
                       if (widget.showSkip)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 31),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            RegistrationProductSeivice.instance
                                .markUnsubscribed();

                            final router = GoRouter.of(context);

                            //  Close this SubscriptionScreen if it was pushed via Navigator
                            if (Navigator.of(context).canPop()) {
                              Navigator.of(context).pop();
                            }

                            //  Now use go_router to show ShopsDetails
                            router.goNamed(
                              AppRoutes.shopsDetails,
                              extra: {
                                'backDisabled': false,
                                'fromSubscriptionSkip': true,
                              },
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColor.silverGray),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 0,
                                vertical: 20,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Continue as Free',
                                    style: AppTextStyles.mulish(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppColor.darkBlue,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Image.asset(
                                    AppImages.rightStickArrow,
                                    height: 20,
                                    width: 17,
                                    color: AppColor.darkBlue,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 25),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 15),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: _UpgradeNoticeCard(),
              ),
              const SizedBox(height: 10),

              // SizedBox(
              //   height: 90,
              //   child: Padding(
              //     padding: const EdgeInsets.symmetric(
              //       vertical: 8.0,
              //       horizontal: 5,
              //     ),
              //     child: ListView.builder(
              //       scrollDirection: Axis.horizontal,
              //       itemCount: planAmount?.length ?? 0,
              //       itemBuilder: (context, index) {
              //         final data = planAmount?[index];
              //         return Padding(
              //           padding: const EdgeInsets.symmetric(horizontal: 5),
              //           child: _BillingChip(
              //             labelTop: '₹ ${data?.price}',
              //             labelBottom: data?.type.toString() ?? '',
              //             selected: _selectedBilling == 0,
              //             onTap: () {},
              //             highlight: true,
              //           ),
              //         );
              //       },
              //     ),
              //   ),
              // ),
              SizedBox(
                height: 90,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 5,
                  ),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: planAmount?.length ?? 0,
                    itemBuilder: (context, index) {
                      final data = planAmount![index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: _BillingOptions(
                          index: index, //  add this
                          price: data.price.toString(),
                          durationDays: data.durationDays,
                          isBestValue: data.isBestValue,
                          boxColor: _colorFromHex(
                            data.color,
                            fallback: Colors.white,
                          ),

                          type:
                              data.type
                                  .toString(), // better: show duration text
                          selectedIndex: _selectedBilling,
                          onChanged:
                              (i) => setState(() {
                                _selectedBilling = i;
                              }),
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 5),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF0797FD),
                        Color(0xFF07C8FD),
                        Color(0xFF0797FD),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ElevatedButton(
                    onPressed:
                        state.isInsertLoading
                            ? null
                            : () async {
                              if (planAmount == null || planAmount.isEmpty)
                                return;

                              final selectedPlan = planAmount[_selectedBilling];
                              final planId = selectedPlan.id.toString();

                              debugPrint('Selected planId: $planId');

                              final shopId = (await AppPrefs.getSopId() ?? '')
                                  .trim();
                              if (shopId.isEmpty) {
                                showTopSnackBar(
                                  context,
                                  const CustomSnackBar.error(
                                    message: "Please select a shop and try again",
                                  ),
                                );
                                return;
                              }

                              final current = ref
                                  .read(subscriptionNotifier)
                                  .currentPlanResponse
                                  ?.data;
                              final shouldExtend =
                                  (current?.isFreemium == false) &&
                                  ((current?.status ?? '')
                                          .trim()
                                          .toUpperCase() ==
                                      'ACTIVE');

                              final initData = await ref
                                  .read(subscriptionNotifier.notifier)
                                  .initCcAvenue(
                                    planId: planId,
                                    businessProfileId: widget.businessProfileId,
                                    shopId: shopId,
                                    extend: shouldExtend,
                                  );

                              if (!mounted) return;
                              if (initData == null) {
                                final subState = ref.read(subscriptionNotifier);
                                showTopSnackBar(
                                  context,
                                  CustomSnackBar.error(
                                    message:
                                        subState.error ??
                                        "Unable to start payment",
                                  ),
                                );
                                return;
                              }

                              final result = await Navigator.of(context)
                                  .push<CcAvenueCheckoutResult>(
                                MaterialPageRoute(
                                  builder: (_) => CcAvenueCheckoutScreen(
                                    initData: initData,
                                  ),
                                ),
                              );

                              if (!mounted) return;
                              if (result == null) return;

                              if (result.cancelled) {
                                showTopSnackBar(
                                  context,
                                  const CustomSnackBar.info(
                                    message: "Payment cancelled",
                                  ),
                                );
                                return;
                              }

                              // Optional fallback ONLY when encResp is directly available.
                              if (result.encResp != null &&
                                  result.encResp!.trim().isNotEmpty) {
                                await ref
                                    .read(subscriptionNotifier.notifier)
                                    .confirmCcAvenue(encResp: result.encResp!.trim());
                              }

                              // Always refresh the subscription state from backend.
                              await ref
                                  .read(subscriptionNotifier.notifier)
                                  .getCurrentPlan(
                                    businessProfileId: widget.businessProfileId,
                                    force: true,
                                    keepExisting: true,
                                  );

                              final refreshed = ref
                                  .read(subscriptionNotifier)
                                  .currentPlanResponse
                                  ?.data;

                              final status =
                                  (refreshed?.status ?? '').trim().toUpperCase();

                              if (status == 'ACTIVE' && refreshed != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PaySuccessAndCancel(
                                      isSuccess: true,
                                      tittle:
                                          (refreshed.plan?.durationLabel ??
                                                  selectedPlan.type)
                                              .toString(),
                                      planId: planId,
                                      startAt:
                                          (refreshed.period?.startsAtLabel ??
                                                  '')
                                              .toString(),
                                      endsAt:
                                          (refreshed.period?.endsAtLabel ?? '')
                                              .toString(),
                                    ),
                                  ),
                                );
                              } else if (status == 'PENDING') {
                                showTopSnackBar(
                                  context,
                                  const CustomSnackBar.info(
                                    message:
                                        "Payment submitted. Awaiting confirmation.",
                                  ),
                                );
                              } else {
                                showTopSnackBar(
                                  context,
                                  CustomSnackBar.error(
                                    message:
                                        ref.read(subscriptionNotifier).error ??
                                        "Payment failed. Please try again.",
                                  ),
                                );
                              }
                            },

                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 40,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        state.isInsertLoading
                            ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                            : Text(
                              'Upgrade now and get leads',
                              style: AppTextStyles.mulish(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                        SizedBox(width: 10),
                        state.isInsertLoading
                            ? SizedBox.shrink()
                            : Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                            ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

void showTopSnackBar(
  BuildContext context,
  Widget snackBar, {
  Duration duration = const Duration(seconds: 3),
}) {
  final overlay = Overlay.of(context);

  final overlayEntry = OverlayEntry(
    builder:
        (context) => Positioned(
          top: MediaQuery.of(context).padding.top + 12,
          left: 16,
          right: 16,
          child: Material(color: Colors.transparent, child: snackBar),
        ),
  );

  overlay.insert(overlayEntry);

  Future.delayed(duration, () {
    overlayEntry.remove();
  });
}

class _ComparisonCard extends StatelessWidget {
  final List<PlanFeature> features;
  const _ComparisonCard({required this.features});

  @override
  Widget build(BuildContext context) {
    const premiumGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF0797FD), Color(0xFF07C8FD), Color(0xFF0797FD)],
    );

    final rows = features.isNotEmpty
        ? (List<PlanFeature>.from(features)
          ..sort((a, b) => a.sort.compareTo(b.sort)))
        : <PlanFeature>[
            PlanFeature(
              key: 'limited_visibility_5_km_only',
              label: 'Limited visibility (5 km only)',
              free: true,
              premium: false,
              sort: 1,
            ),
            PlanFeature(
              key: 'get_priority_in_search',
              label: 'Get priority in search',
              free: false,
              premium: true,
              sort: 2,
            ),
          ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
                    const Expanded(flex: 2, child: Text('')),
                    Expanded(
                      flex: 1,
                      child: Container(color: AppColor.textWhite),
                    ), // Free
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
                      children: const [
                        Expanded(flex: 3, child: Text('')),
                        Expanded(
                          flex: 3,
                          child: Center(
                            child: Text(
                              'Free',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
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
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                            Expanded(
                              flex: 4,
                              child: Text(
                                f.label,
                                style: AppTextStyles.mulish(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                  color: AppColor.darkBlue,
                                ),
                              ),
                            ),

                            Expanded(
                              flex: 3,
                              child: Center(
                                child:
                                    f.free
                                        ? star(color: AppColor.skyBlue)
                                        : SizedBox.shrink(),
                              ),
                            ),

                          Expanded(
                            flex: 2,
                            child: Center(
                              child:
                                  f.premium
                                      ? star(color: AppColor.white)
                                      : SizedBox.shrink(),
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

Widget star({Color? color = AppColor.white}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 14),
    child: Icon(Icons.star_rounded, color: color),
  );
}

/// Parse an API color string like "#c123fb", "c123fb", "#fff" or
/// "#aarrggbb" into a [Color]. Returns [fallback] when empty/invalid so a bad
/// value never crashes the UI.
Color _colorFromHex(String? hex, {Color fallback = Colors.white}) {
  if (hex == null) return fallback;
  var s = hex.trim().replaceAll('#', '');
  if (s.isEmpty) return fallback;
  if (s.length == 3) {
    // #rgb -> #rrggbb
    s = s.split('').map((c) => '$c$c').join();
  }
  if (s.length == 6) s = 'FF$s'; // assume fully opaque
  if (s.length != 8) return fallback;
  final value = int.tryParse(s, radix: 16);
  if (value == null) return fallback;
  return Color(value);
}

/// Pick a readable foreground color (black or white) for [background] so the
/// price/year text stays visible whatever color the API sends.
Color _onColorFor(Color background) {
  return background.computeLuminance() > 0.5 ? AppColor.black : Colors.white;
}

class _BillingOptions extends StatelessWidget {
  const _BillingOptions({
    required this.index,
    required this.selectedIndex,
    required this.type,
    required this.onChanged,
    required this.price,
    required this.durationDays,
    required this.isBestValue,
    required this.boxColor,
  });

  final int index; // ✅ current item index
  final int selectedIndex; // ✅ selected index in parent
  final ValueChanged<int> onChanged;

  final String type;
  final String price;
  final int durationDays;
  final bool isBestValue;
  final Color boxColor; // per-plan color from API

  @override
  Widget build(BuildContext context) {
    final perMonth = formatPricePerMonth(price, durationDays);
    return _BillingChip(
      labelTop: '₹ $price',
      labelMid: perMonth != null ? '(₹$perMonth/mo)' : null,
      labelBottom: type,
      boxColor: boxColor,
      selected: selectedIndex == index, // ✅ compare with index
      onTap: () => onChanged(index), // ✅ send index
      highlight: isBestValue,
    );
  }
}

class _BillingChip extends StatelessWidget {
  const _BillingChip({
    required this.labelTop,
    this.labelMid,
    required this.labelBottom,
    required this.selected,
    required this.onTap,
    required this.boxColor,
    this.highlight = false,
  });

  final String labelTop;
  // Optional "(₹xxx/mo)" line shown between the price and the duration.
  final String? labelMid;

  final String labelBottom;
  final bool selected;
  final bool highlight;
  final Color boxColor; // per-plan background color from API

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Readable text color for whatever color the API sends.
    final Color onColor = _onColorFor(boxColor);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          SizedBox(
            width: 160,
            height: labelMid != null ? 84 : 72,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: EdgeInsets.only(
                top: highlight ? 16 : 10,
                bottom: 10,
                left: 12,
                right: 12,
              ),
              decoration: BoxDecoration(
                color: boxColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  // Brand-blue ring on the selected box (visible on any color);
                  // a subtle edge otherwise.
                  color: selected
                      ? const Color(0xFF0797FD)
                      : onColor.withOpacity(0.15),
                  width: selected ? 2 : 1.5,
                ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: const Color(0xFF0797FD).withOpacity(0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    labelTop,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: onColor,
                      fontSize: 17,
                      height: 1.0,
                    ),
                  ),
                  if (labelMid != null) ...[
                    const SizedBox(height: 1),
                    Text(
                      labelMid!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: onColor.withOpacity(0.85),
                        fontSize: 10,
                        height: 1.0,
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    labelBottom,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.mulish(
                      fontWeight:
                          selected ? FontWeight.bold : FontWeight.normal,
                      color: onColor.withOpacity(selected ? 1.0 : 0.85),
                      fontSize: 11,
                      height: 1.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (highlight)
            Positioned(
              top: 6,
              right: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x33000000),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 95),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.local_fire_department_rounded,
                          size: 10,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          'Best Value',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.mulish(
                            fontSize: 8,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _UpgradeNoticeCard extends StatelessWidget {
  const _UpgradeNoticeCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFFFFE7C7), Color(0xFFFFF3E3)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Color(0xFFF59E0B),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Don't miss customers",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.mulish(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    style: AppTextStyles.mulish(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColor.black,
                    ),
                    children: const [
                      TextSpan(text: 'Customers choose vendors '),
                      TextSpan(
                        text: 'who reply first',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                      TextSpan(text: '.\n'),
                      TextSpan(
                        text: 'Upgrade now and stay ahead of competitors.',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// old///
//   Scaffold(
//   backgroundColor: Color(0xFFF3F3F3),
//   body: SafeArea(
//     child: ConstrainedBox(
//       constraints: const BoxConstraints(maxWidth: 420),
//       child: ListView(
//         children: [
//           Row(
//             children: [
//               GestureDetector(
//                 onTap: () => Navigator.pop(context),
//                 child: Container(
//                   padding: EdgeInsets.symmetric(horizontal: 25, vertical: 13),
//                   decoration: BoxDecoration(
//                     border: Border.all(color: AppColor.border),
//                     shape: BoxShape.circle,
//                     color: AppColor.white,
//                   ),
//                   child: Image.asset(
//                     AppImages.leftArrow,
//                     height: 15,
//                     color: AppColor.black,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           Column(
//             children: [
//               Image.asset(
//                 AppImages.crown,
//                 height: 105,
//                 fit: BoxFit.contain,
//               ),
//                SizedBox(height: 10),
//               Text(
//                 "Unlock the Tringo’s",
//                 style: AppTextStyles.mulish(fontSize: 22),
//               ),
//               Text(
//                 "Super Power",
//                 style: AppTextStyles.mulish(
//                   fontSize: 22,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//                SizedBox(height: 20),
//               _ComparisonCard(),
//
//                SizedBox(height: 20),
//               Center(
//                 child: Text(
//                   'Cancel Subscription Any time',
//                   style: AppTextStyles.mulish(color: AppColor.darkGrey),
//                 ),
//               ),
//                SizedBox(height: 30),
//
//               // Billing options
//               _BillingOptions(
//                 selected: _selectedBilling,
//                 onChanged: (i) => setState(() => _selectedBilling = i),
//               ),
//
//               const SizedBox(height: 16),
//
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 15),
//                 child: Container(
//                   padding: EdgeInsets.symmetric(vertical: 5),
//                   decoration: BoxDecoration(
//                     gradient: const LinearGradient(
//                       colors: [
//                         Color(0xFF0797FD),
//                         Color(0xFF07C8FD),
//                         Color(0xFF0797FD),
//                       ],
//                       begin: Alignment.centerLeft,
//                       end: Alignment.centerRight,
//                     ),
//                     borderRadius: BorderRadius.circular(16),
//                   ),
//                   child: ElevatedButton(
//                     onPressed: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => SubscriptionHistory(),
//                         ),
//                       );
//                     },
//                     style: ElevatedButton.styleFrom(
//                       elevation: 0,
//                       backgroundColor:
//                           Colors.transparent,
//                       shadowColor: Colors.transparent,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(16),
//                       ),
//                       padding: const EdgeInsets.symmetric(
//                         vertical: 14,
//                         horizontal: 40,
//                       ),
//                     ),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Text(
//                           'Get Super Power Now',
//                           style: AppTextStyles.mulish(
//                             fontSize: 18,
//                             fontWeight: FontWeight.w900,
//                             color: Colors.white,
//                           ),
//                         ),
//                         SizedBox(width: 10),
//                         Icon(
//                           Icons.arrow_forward_rounded,
//                           color: Colors.white,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 16),
//             ],
//           ),
//         ],
//       ),
//     ),
//   ),
// );
