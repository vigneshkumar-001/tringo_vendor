// ignore_for_file: camel_case_types, non_constant_identifier_names

import 'package:dotted_border/dotted_border.dart';
import 'package:dotted_border/dotted_border.dart' as dotted;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../Api/DataSource/api_data_source.dart';
import '../../../../Core/Const/app_color.dart';
import '../../../../Core/Const/app_images.dart';
import '../../../../Core/Utility/app_loader.dart';
import '../../../../Core/Utility/app_textstyles.dart';
import '../../../../Core/Widgets/app_go_routes.dart';
import '../../../../Core/Widgets/common_container.dart';

import '../../../Login Screen/Controller/login_notifier.dart';
import '../../../No Data Screen/Screen/no_data_screen.dart';
import '../Controller/heater_employee_details_notifier.dart';
import '../Model/employeeDetailsResponse.dart' as emp;

class HeaterEmployeeDetails extends ConsumerStatefulWidget {
  final String employeeId;

  const HeaterEmployeeDetails({super.key, required this.employeeId});

  @override
  ConsumerState<HeaterEmployeeDetails> createState() =>
      _HeaterEmployeeDetailsState();
}

class _HeaterEmployeeDetailsState extends ConsumerState<HeaterEmployeeDetails> {
  int selectedIndex = 0;

  List<Map<String, dynamic>> _buildTabsFromSummary(emp.Summary s) {
    return [
      {
        "label": "${s.premiumProCount} Pro Premium User",
        "image": AppImages.premiumImage,
        "key": "PREMIUM_PRO",
      },
      {
        "label": "${s.premiumCount} Premium Users",
        "image": AppImages.premiumImage01,
        "key": "PREMIUM",
      },
      {
        "label": "${s.freemiumCount} Free Users",
        "image": AppImages.premiumImage01,
        "key": "FREEMIUM",
      },
    ];
  }

  // -----------------------------
  // Flat fallback filter (USE emp.ShopItem )
  // -----------------------------
  List<emp.ShopItem> _filterByTab(List<emp.ShopItem> all, String selectedKey) {
    if (selectedKey.isEmpty) return all;

    return all.where((s) {
      final key = (s.planCategory ?? '').toUpperCase();

      if (selectedKey == "FREEMIUM") {
        return key.isEmpty || key == "FREEMIUM";
      }
      return key == selectedKey;
    }).toList();
  }

  // -----------------------------
  // Select section for grouping UI
  // -----------------------------
  emp.ShopSection? _getSelectedSection(
    emp.ShopsAndServices sas,
    String selectedKey,
  ) {
    if (selectedKey.isEmpty) return null;

    if (selectedKey == "FREEMIUM") {
      final exact = sas.sections.where(
        (e) => (e.key).toUpperCase() == "FREEMIUM",
      );
      if (exact.isNotEmpty) return exact.first;
    }

    final match = sas.sections.where(
      (e) => (e.key).toUpperCase() == selectedKey,
    );
    return match.isNotEmpty ? match.first : null;
  }

  // -----------------------------
  // Formatting helpers
  // -----------------------------
  String _formatEndsDate(String? iso) {
    final s = (iso ?? '').trim();
    if (s.isEmpty) return "";
    final dt = DateTime.tryParse(s);
    if (dt == null) return "";
    return DateFormat("dd MMM yyyy").format(dt.toLocal());
  }

  String _formatCreatedAt(DateTime? dt) {
    if (dt == null) return "";
    return DateFormat("hh:mm a").format(dt.toLocal());
  }

  String _planMainLabel(emp.ShopItem shop) {
    final t = (shop.planTitle ?? '').trim();
    if (t.isNotEmpty) return t;

    final cat = (shop.planCategory ?? '').toUpperCase();
    if (cat.isEmpty) return "No Plan";
    if (cat == "FREEMIUM") return "Freemium";
    if (cat == "PREMIUM") return "Premium";
    if (cat == "PREMIUM_PRO") return "Pro Premium";
    return cat;
  }

  String _planSecondaryLabel(emp.ShopItem shop) {
    final dur = (shop.planDurationLabel ?? '').trim();
    final ends = _formatEndsDate(shop.planEndsAt);
    final type = (shop.planType ?? '').trim();

    final parts = <String>[];
    if (dur.isNotEmpty) parts.add(dur);
    if (type.isNotEmpty) parts.add(type);
    if (ends.isNotEmpty) parts.add("Ends $ends");

    return parts.join(" • ");
  }

  String _planBadge(emp.ShopItem shop) {
    final badge = (shop.planBadgeText ?? '').trim();
    if (badge.isNotEmpty) return badge;

    final left = shop.daysLeft;
    if (left == null) return "";
    if (left <= 0) return "Expired";
    return "$left days left";
  }

  // -----------------------------
  // Dialer
  // -----------------------------
  Future<void> _launchDialer(String phoneNumber) async {
    final Uri uri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      debugPrint('Could not launch dialer for $phoneNumber');
    }
  }

  // -----------------------------
  // Image widget
  // -----------------------------
  Widget _shopImage(String? url) {
    final u = (url ?? '').trim();
    if (u.isEmpty) {
      return Container(
        color: AppColor.black.withOpacity(0.05),
        child: const Center(child: Icon(Icons.store, size: 40)),
      );
    }

    return Image.network(
      u,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) {
        return Container(
          color: AppColor.black.withOpacity(0.05),
          child: const Center(child: Icon(Icons.broken_image, size: 40)),
        );
      },
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(
          color: AppColor.black.withOpacity(0.03),
          child: const Center(child: CircularProgressIndicator()),
        );
      },
    );
  }

  // -----------------------------
  // Section header (Today / Yesterday)
  // -----------------------------
  Widget _sectionHeader(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 18, right: 18, top: 14, bottom: 6),
      child: Row(
        children: [
          Text(
            text,
            style: AppTextStyles.mulish(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColor.darkGrey,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              height: 1,
              color: AppColor.black.withOpacity(0.08),
            ),
          ),
        ],
      ),
    );
  }

  // -----------------------------
  // Plan chip row
  // -----------------------------
  Widget _planChip(emp.ShopItem shop) {
    final main = _planMainLabel(shop);
    final sub = _planSecondaryLabel(shop);
    final time = _formatCreatedAt(shop.createdAt);
    final badge = _planBadge(shop);

    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColor.white,
            borderRadius: BorderRadius.circular(50),
          ),
          padding: const EdgeInsets.all(10),
          child: Image.asset(AppImages.premiumImage, height: 16, width: 17),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: DottedBorder(
            color: AppColor.black.withOpacity(0.2),
            dashPattern: const [3.0, 2.0],
            borderType: dotted.BorderType.RRect,
            padding: const EdgeInsets.all(10),
            radius: const Radius.circular(18),
            child: Row(
              children: [
                // Expanded(
                //   child: Column(
                //     crossAxisAlignment: CrossAxisAlignment.start,
                //     children: [
                //       // Text(
                //       //   main,
                //       //   maxLines: 1,
                //       //   overflow: TextOverflow.ellipsis,
                //       //   style: AppTextStyles.mulish(
                //       //     fontWeight: FontWeight.w800,
                //       //     fontSize: 12,
                //       //     color: AppColor.darkBlue,
                //       //   ),
                //       // ),
                //       // const SizedBox(height: 3),
                //       // Text(
                //       //   sub.isNotEmpty ? sub : badge,
                //       //   maxLines: 1,
                //       //   overflow: TextOverflow.ellipsis,
                //       //   style: AppTextStyles.mulish(
                //       //     fontWeight: FontWeight.w400,
                //       //     fontSize: 11,
                //       //     color: AppColor.lightGray3,
                //       //   ),
                //       // ),
                //     ],
                //   ),
                // ),
                if (badge.isNotEmpty) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      badge,
                      style: AppTextStyles.mulish(
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                        color: AppColor.darkBlue,
                      ),
                    ),
                  ),
                ],

                if (time.isNotEmpty) ...[
                  const SizedBox(width: 10),
                  Text(
                    time,
                    style: AppTextStyles.mulish(
                      fontWeight: FontWeight.w500,
                      fontSize: 11,
                      color: AppColor.lightGray3,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: () {
            // TODO: Navigate to shop details
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7.5),
            decoration: BoxDecoration(
              color: AppColor.black,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Image.asset(AppImages.rightStickArrow, height: 19),
          ),
        ),
      ],
    );
  }

  // -----------------------------
  // Shop card
  // -----------------------------
  Widget _shopCard(emp.ShopItem shop) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          color: AppColor.iceGray,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppColor.ivoryGreen,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColor.black.withOpacity(0.054),
                              AppColor.black.withOpacity(0.0),
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                shop.breadcrumb,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.mulish(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColor.darkBlue,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: AspectRatio(
                          aspectRatio: 328 / 143,
                          child: _shopImage(shop.imageUrl),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        shop.englishName,
                        style: AppTextStyles.mulish(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          color: AppColor.darkBlue,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        shop.addressEn,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.mulish(
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          color: AppColor.lightGray3,
                        ),
                      ),
                      const SizedBox(height: 18),
                      _planChip(shop),
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

  // -----------------------------
  // Init
  // -----------------------------
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(heaterEmployeeDetailsNotifier.notifier)
          .heaterEmployee(employeeId: widget.employeeId);
    });
  }

  // ==============================
  // BUILD
  // ==============================
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(heaterEmployeeDetailsNotifier);

    if (state.isLoading) {
      return const Scaffold(
        body: Center(child: ThreeDotsLoader(dotColor: AppColor.darkBlue)),
      );
    }

    // if (state.error != null) {
    //   return Scaffold(body: Center(child: Text(state.error!)));
    // }
    if (state.error != null) {
      return const Scaffold(
        body: NoDataScreen(showTopBackArrow: false, showBottomButton: false),
      );
    }

    final data = state.employeeDetailsResponse?.data;
    if (data == null) {
      return const Scaffold(body: Center(child: Text("No data available")));
    }

    final employee = data.employee;
    final summary = data.summary;
    final sas = data.shopsAndServices;

    final tabs = _buildTabsFromSummary(summary);
    final selectedKey =
        tabs.isNotEmpty ? (tabs[selectedIndex]["key"] ?? "") : "";

    final selectedSection = _getSelectedSection(sas, selectedKey);
    final fallbackFiltered = _filterByTab(sas.items, selectedKey);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // HEADER
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    CommonContainer.topLeftArrow(
                      onTap: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 80),
                    Text(
                      'Employee Details',
                      style: AppTextStyles.mulish(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColor.mildBlack,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 35),

              // EMPLOYEE CARD
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(AppImages.registerBCImage),
                  ),
                  gradient: LinearGradient(
                    colors: [AppColor.white, AppColor.mintCream],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: SizedBox(
                          height: 115,
                          width: 92,
                          child:
                              (employee.avatarUrl ?? '').isNotEmpty
                                  ? Image.network(
                                    employee.avatarUrl ?? '',
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (_, __, ___) =>
                                            const Icon(Icons.person, size: 40),
                                  )
                                  : const Icon(Icons.person, size: 40),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            employee.name,
                            style: AppTextStyles.mulish(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: AppColor.darkBlue,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            employee.employeeCode,
                            style: AppTextStyles.mulish(
                              fontSize: 11,
                              color: AppColor.mildBlack,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Today Collection',
                            style: AppTextStyles.mulish(
                              fontSize: 10,
                              color: AppColor.gray84,
                            ),
                          ),
                          Text(
                            'Rs. ${summary.totalAmount}',
                            style: AppTextStyles.mulish(
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                              color: AppColor.mildBlack,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Column(
                        children: [
                          InkWell(
                            onTap: () {
                              if (employee.phoneNumber.isNotEmpty) {
                                _launchDialer(employee.phoneNumber);
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColor.black,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14.5,
                                  vertical: 15,
                                ),
                                child: Image.asset(
                                  AppImages.callImage1,
                                  height: 12,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          InkWell(
                            onTap: () {
                              context.push(
                                AppRoutes.heaterEmployeeDetailsEditPath,
                                extra: {
                                  'employeeId': employee.id,
                                  'name': employee.name,
                                  'employeeCode': employee.employeeCode,
                                  'phoneNumber': employee.phoneNumber,
                                  'avatarUrl': employee.avatarUrl,
                                  'email': employee.email.toString(),
                                  'emergencyContactName':
                                      employee.emergencyContactName.toString(),
                                  'emergencyContactRelationship':
                                      employee.emergencyContactRelationship
                                          .toString(),
                                  'emergencyContactPhone':
                                      employee.emergencyContactPhone.toString(),
                                  'aadharNumber':
                                      employee.aadharNumber.toString(),
                                  'aadharDocumentUrl':
                                      employee.aadharDocumentUrl.toString(),
                                  'totalAmount': summary.totalAmount.toString(),
                                },
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: AppColor.black.withOpacity(0.1),
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14.5,
                                  vertical: 17.5,
                                ),
                                child: Image.asset(
                                  AppImages.editImage,
                                  color: AppColor.darkBlue,
                                  height: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 25),

              Center(
                child: Text(
                  'Shops & Services',
                  style: AppTextStyles.mulish(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColor.darkBlue,
                  ),
                ),
              ),

              // TABS
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 25,
                ),
                child: Row(
                  children: List.generate(tabs.length, (index) {
                    final isSelected = selectedIndex == index;
                    final tab = tabs[index];

                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () => setState(() => selectedIndex = index),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color:
                                isSelected
                                    ? AppColor.white
                                    : AppColor.black.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color:
                                  isSelected
                                      ? AppColor.deepTeaBlue
                                      : Colors.transparent,
                            ),
                          ),
                          child: Row(
                            children: [
                              Image.asset(
                                tab["image"] ?? '',
                                height: 18,
                                width: 18,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                tab["label"] ?? '',
                                style: AppTextStyles.mulish(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: AppColor.darkBlue,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),

              const SizedBox(height: 10),

              // GROUPED LIST
              if ((selectedSection?.groups.isNotEmpty ?? false))
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: selectedSection!.groups.length,
                  itemBuilder: (context, gIndex) {
                    final group = selectedSection.groups[gIndex];
                    final items = group.items;

                    if (items.isEmpty) return const SizedBox.shrink();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionHeader(group.dateLabel),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: items.length,
                          itemBuilder: (context, i) => _shopCard(items[i]),
                        ),
                      ],
                    );
                  },
                )
              else if (fallbackFiltered.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 140,
                  ),
                  child: Text(
                    'No Shops & Services',
                    style: AppTextStyles.mulish(
                      fontSize: 14,
                      color: AppColor.darkGrey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              else
                // FLAT LIST FALLBACK
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: fallbackFiltered.length,
                  itemBuilder:
                      (context, index) => _shopCard(fallbackFiltered[index]),
                ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

/*import 'package:dotted_border/dotted_border.dart';
import 'package:dotted_border/dotted_border.dart' as dotted;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:tringo_vendor_new/Core/Utility/app_loader.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../Core/Const/app_color.dart';
import '../../../../Core/Const/app_images.dart';
import '../../../../Core/Utility/app_textstyles.dart';
import '../../../../Core/Widgets/app_go_routes.dart';
import '../../../../Core/Widgets/common_container.dart';
import '../../Employee details-edit/Screen/heater_employee_details_edit.dart';
import '../../History/Model/vendor_history_response.dart';
import '../Controller/heater_employee_details_notifier.dart';
import '../Model/employeeDetailsResponse.dart' hide ShopItem;

class HeaterEmployeeDetails extends ConsumerStatefulWidget {
  final String employeeId;

  const HeaterEmployeeDetails({super.key, required this.employeeId});

  @override
  ConsumerState<HeaterEmployeeDetails> createState() =>
      _HeaterEmployeeDetailsState();
}

class _HeaterEmployeeDetailsState extends ConsumerState<HeaterEmployeeDetails> {
  int selectedIndex = 0;

  List<Map<String, dynamic>> _buildTabsFromSummary(Summary s) {
    return [
      {
        "label": "${s.premiumProCount} Pro Premium User",
        "image": AppImages.premiumImage,
        "key": "PREMIUM_PRO",
      },
      {
        "label": "${s.premiumCount} Premium Users",
        "image": AppImages.premiumImage01,
        "key": "PREMIUM",
      },
      {
        "label": "${s.freemiumCount} Free Users",
        "image": AppImages.premiumImage01,
        "key": "FREEMIUM",
      },
    ];
  }

  List<ShopItem> _filterByTab(List<ShopItem> all, String selectedKey) {
    if (selectedKey.isEmpty) return all;

    return all.where((s) {
      final key = (s.planCategory ?? '').toUpperCase();

      // FREEMIUM match also when planCategory null
      if (selectedKey == "FREEMIUM") {
        return key.isEmpty || key == "FREEMIUM";
      }

      return key == selectedKey;
    }).toList();
  }

  String _planTitle(ShopItem shop) {
    final cat = (shop.planCategory ?? '').toUpperCase();
    if (cat.isEmpty) return "No Plan";
    if (cat == "FREEMIUM") return "Freemium";
    if (cat == "PREMIUM") return "Premium";
    if (cat == "PREMIUM_PRO") return "Pro Premium";
    return cat;
  }

  String _planSubtitle(ShopItem shop) {
    // show: MONTHLY • Ends 20 Jun 2026
    final type = (shop.planType ?? '').toUpperCase();
    final endsStr = (shop.planEndsAt ?? '').trim();

    String ends = "";
    if (endsStr.isNotEmpty) {
      final dt = DateTime.tryParse(endsStr);
      if (dt != null) {
        ends = DateFormat("dd MMM yyyy").format(dt.toLocal());
      }
    }

    final parts = <String>[];
    if (type.isNotEmpty) parts.add(type);
    if (ends.isNotEmpty) parts.add("Ends $ends");

    if (parts.isEmpty) return "";
    return parts.join(" • ");
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref
          .read(heaterEmployeeDetailsNotifier.notifier)
          .heaterEmployee(employeeId: widget.employeeId);
    });
  }

  Future<void> _launchDialer(String phoneNumber) async {
    final Uri uri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      debugPrint('Could not launch dialer for $phoneNumber');
    }
  }

  Widget _shopImage(String? url) {
    final u = (url ?? '').trim();
    if (u.isEmpty) {
      return Container(
        color: AppColor.black.withOpacity(0.05),
        child: const Center(child: Icon(Icons.store, size: 40)),
      );
    }

    return Image.network(
      u,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) {
        return Container(
          color: AppColor.black.withOpacity(0.05),
          child: const Center(child: Icon(Icons.broken_image, size: 40)),
        );
      },
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(
          color: AppColor.black.withOpacity(0.03),
          child: const Center(child: CircularProgressIndicator()),
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    final state = ref.watch(heaterEmployeeDetailsNotifier);

    if (state.isLoading) {
      return const Scaffold(
        body: Center(child: ThreeDotsLoader(dotColor: AppColor.darkBlue)),
      );
    }

    if (state.error != null) {
      return Scaffold(body: Center(child: Text(state.error!)));
    }

    final data = state.employeeDetailsResponse?.data;
    if (data == null) {
      return const Scaffold(body: Center(child: Text("No data available")));
    }

    final employee = data.employee;
    final summary = data.summary;
    final shops = data.shopsAndServices.items;

    final tabs = _buildTabsFromSummary(summary);

    final selectedKey =
        tabs.isNotEmpty ? (tabs[selectedIndex]["key"] ?? "") : "";
    // final filteredShops = _filterByTab(shops, selectedKey);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    CommonContainer.topLeftArrow(
                      onTap: () => Navigator.pop(context),
                    ),
                    SizedBox(width: 80),
                    Text(
                      'Employee Details',
                      style: AppTextStyles.mulish(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColor.mildBlack,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 35),
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(AppImages.registerBCImage),
                  ),
                  gradient: LinearGradient(
                    colors: [AppColor.white, AppColor.mintCream],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: SizedBox(
                          height: 115,
                          width: 92,
                          child:
                              employee.avatarUrl != null
                                  ? Image.network(
                                    employee.avatarUrl ?? '',
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (_, __, ___) =>
                                            Icon(Icons.person, size: 40),
                                  )
                                  : Icon(Icons.person, size: 40),
                        ),
                      ),

                      SizedBox(width: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            employee.name,
                            // data.name,
                            style: AppTextStyles.mulish(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: AppColor.darkBlue,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            employee.employeeCode,
                            // data.employeeCode,
                            style: AppTextStyles.mulish(
                              fontSize: 11,
                              color: AppColor.mildBlack,
                            ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            'Today Collection',
                            style: AppTextStyles.mulish(
                              fontSize: 10,
                              color: AppColor.gray84,
                            ),
                          ),
                          Text(
                            'Rs. ${summary.totalAmount}',
                            style: AppTextStyles.mulish(
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                              color: AppColor.mildBlack,
                            ),
                          ),
                        ],
                      ),
                      Spacer(),
                      Column(
                        children: [
                          InkWell(
                            onTap: () {
                              if (employee.phoneNumber.isNotEmpty) {
                                _launchDialer(employee.phoneNumber);
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColor.black,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14.5,
                                  vertical: 15,
                                ),
                                child: Image.asset(
                                  AppImages.callImage1,
                                  height: 12,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 15),
                          InkWell(
                            onTap: () {
                              context.push(
                                AppRoutes.heaterEmployeeDetailsEditPath,
                                extra: {
                                  'employeeId': employee.id,
                                  'name': employee.name,
                                  'employeeCode': employee.employeeCode,
                                  'phoneNumber': employee.phoneNumber,
                                  'avatarUrl': employee.avatarUrl,
                                  'email': employee.email.toString(),
                                  'emergencyContactName':
                                      employee.emergencyContactName.toString(),
                                  'emergencyContactRelationship':
                                      employee.emergencyContactRelationship
                                          .toString(),
                                  'emergencyContactPhone':
                                      employee.emergencyContactPhone.toString(),
                                  'aadharNumber':
                                      employee.aadharNumber.toString(),
                                  'aadharDocumentUrl':
                                      employee.aadharDocumentUrl.toString(),
                                  'totalAmount': summary.totalAmount.toString(),
                                  // 'isActive': employee.isActive,
                                },
                              );
                            },

                            // onTap: () {
                            //   final id = employee.id;
                            //   context.push('${AppRoutes.heaterEmployeeDetailsEditPath}/$id');
                            // },
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: AppColor.black.withOpacity(0.1),
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14.5,
                                  vertical: 17.5,
                                ),
                                child: Image.asset(
                                  AppImages.editImage,
                                  color: AppColor.darkBlue,
                                  height: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 25),
              Center(
                child: Text(
                  'Shops & Services',
                  style: AppTextStyles.mulish(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColor.darkBlue,
                  ),
                ),
              ),
              SizedBox(height: 0),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 25,
                ),
                child: Row(
                  children: List.generate(tabs.length, (index) {
                    final isSelected = selectedIndex == index;
                    final tab = tabs[index];

                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () => setState(() => selectedIndex = index),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color:
                                isSelected
                                    ? AppColor.white
                                    : AppColor.black.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color:
                                  isSelected
                                      ? AppColor.deepTeaBlue
                                      : Colors.transparent,
                            ),
                          ),
                          child: Row(
                            children: [
                              Image.asset(
                                tab["image"] ?? '',
                                height: 18,
                                width: 18,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                tab["label"] ?? '',
                                style: AppTextStyles.mulish(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: AppColor.darkBlue,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              // SizedBox(height: 0),
              // Center(
              //   child: Text(
              //     'Today',
              //     style: AppTextStyles.mulish(
              //       fontSize: 12,
              //       fontWeight: FontWeight.w700,
              //       color: AppColor.darkGrey,
              //     ),
              //   ),
              // ),
              SizedBox(height: 20),
              if (shops.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 140,
                  ),
                  child: Text(
                    'No Shops & Services',
                    style: AppTextStyles.mulish(
                      fontSize: 14,
                      color: AppColor.darkGrey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: shops.length,
                  itemBuilder: (context, index) {
                    final shop = shops[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColor.iceGray,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: AppColor.ivoryGreen,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              AppColor.black.withOpacity(0.054),
                                              AppColor.black.withOpacity(0.0),
                                            ],
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 15,
                                            vertical: 10,
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  shop.breadcrumb,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: AppTextStyles.mulish(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    color: AppColor.darkBlue,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 20),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(15),
                                        child: AspectRatio(
                                          aspectRatio: 328 / 143,
                                          child: _shopImage(shop.imageUrl),
                                        ),
                                      ),

                                      // ClipRRect(
                                      //   borderRadius: BorderRadius.circular(15),
                                      //   child: AspectRatio(
                                      //     aspectRatio:
                                      //         328 /
                                      //         143, // your original image ratio
                                      //     child: Image.network(
                                      //       shop.imageUrl ?? '',
                                      //       width: double.infinity,
                                      //       fit: BoxFit.cover,
                                      //     ),
                                      //   ),
                                      // ),
                                      SizedBox(height: 20),
                                      Text(
                                        shop.englishName,
                                        style: AppTextStyles.mulish(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 18,
                                          color: AppColor.darkBlue,
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                        shop.addressEn,
                                        style: AppTextStyles.mulish(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 12,
                                          color: AppColor.lightGray3,
                                        ),
                                      ),
                                      SizedBox(height: 20),
                                      Row(
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              color: AppColor.white,
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(10),
                                              child: Image.asset(
                                                AppImages.premiumImage,
                                                height: 16,
                                                width: 17,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          DottedBorder(
                                            color: AppColor.black.withOpacity(
                                              0.2,
                                            ),
                                            dashPattern: [3.0, 2.0],
                                            borderType: dotted.BorderType.RRect,
                                            padding: EdgeInsets.all(10),
                                            radius: Radius.circular(18),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 5,
                                                  ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    '2Months Pro Premium',
                                                    style: AppTextStyles.mulish(
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      fontSize: 12,
                                                      color: AppColor.darkBlue,
                                                    ),
                                                  ),
                                                  SizedBox(width: 10),
                                                  Text(
                                                    '10.40Pm',
                                                    style: AppTextStyles.mulish(
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontSize: 12,
                                                      color:
                                                          AppColor.lightGray3,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Spacer(),
                                          GestureDetector(
                                            onTap: () {
                                              // Navigator.push(
                                              //   context,
                                              //   MaterialPageRoute(
                                              //     builder: (context) =>
                                              //         CommonBottomNavigation(initialIndex: 1),
                                              //   ),
                                              // );
                                            },
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 13,
                                                vertical: 7.5,
                                              ),
                                              decoration: BoxDecoration(
                                                color: AppColor.black,
                                                borderRadius:
                                                    BorderRadius.circular(25),
                                              ),
                                              child: Image.asset(
                                                AppImages.rightStickArrow,
                                                height: 19,
                                              ),
                                            ),
                                          ),
                                        ],
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
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}*/

// Padding(
//   padding: const EdgeInsets.symmetric(horizontal: 15),
//   child: Column(
//     children: [
//       Container(
//         decoration: BoxDecoration(
//           color: AppColor.ivoryGreen,
//           borderRadius: BorderRadius.circular(15),
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Container(
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [
//                       AppColor.black.withOpacity(0.054),
//                       AppColor.black.withOpacity(0.0),
//                     ],
//                     begin: Alignment.centerLeft,
//                     end: Alignment.centerRight,
//                   ),
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 15,
//                     vertical: 10,
//                   ),
//                   child: Row(
//                     children: [
//                       Text(
//                         'Product',
//                         style: AppTextStyles.mulish(
//                           fontSize: 12,
//                           fontWeight: FontWeight.bold,
//                           color: AppColor.darkBlue,
//                         ),
//                       ),
//                       SizedBox(width: 6),
//                       Image.asset(
//                         AppImages.rightArrow,
//                         height: 10,
//                         color: AppColor.darkGrey,
//                       ),
//                       SizedBox(width: 6),
//                       Text(
//                         'Textiles',
//                         style: AppTextStyles.mulish(
//                           fontSize: 12,
//                           fontWeight: FontWeight.bold,
//                           color: AppColor.darkBlue,
//                         ),
//                       ),
//                       SizedBox(width: 6),
//                       Image.asset(
//                         AppImages.rightArrow,
//                         height: 10,
//                         color: AppColor.darkGrey,
//                       ),
//                       SizedBox(width: 6),
//                       Text(
//                         'Mens Wear',
//                         style: AppTextStyles.mulish(
//                           fontSize: 12,
//                           fontWeight: FontWeight.bold,
//                           color: AppColor.darkBlue,
//                         ),
//                       ),
//                       SizedBox(width: 6),
//                       Image.asset(
//                         AppImages.rightArrow,
//                         height: 10,
//                         color: AppColor.darkGrey,
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               SizedBox(height: 20),
//               ClipRRect(
//                 borderRadius: BorderRadius.circular(15),
//                 child: AspectRatio(
//                   aspectRatio:
//                       328 / 143, // your original image ratio
//                   child: Image.asset(
//                     AppImages.homeImage1,
//                     width: double.infinity,
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//               ),
//
//               SizedBox(height: 20),
//               Text(
//                 'Kandhasamy Mobiles',
//                 style: AppTextStyles.mulish(
//                   fontWeight: FontWeight.w700,
//                   fontSize: 18,
//                   color: AppColor.darkBlue,
//                 ),
//               ),
//               SizedBox(height: 10),
//               Text(
//                 overflow: TextOverflow.ellipsis,
//                 maxLines: 2,
//                 '77, Nehru St, Sathyamoorthy Nagar, State Bank Supervisors Colony, Madurai, Tamil Nadu 625016',
//                 style: AppTextStyles.mulish(
//                   fontWeight: FontWeight.w400,
//                   fontSize: 12,
//                   color: AppColor.lightGray3,
//                 ),
//               ),
//               SizedBox(height: 20),
//               Row(
//                 children: [
//                   Container(
//                     decoration: BoxDecoration(
//                       color: AppColor.white,
//                       borderRadius: BorderRadius.circular(50),
//                     ),
//                     child: Padding(
//                       padding: const EdgeInsets.all(10),
//                       child: Image.asset(
//                         AppImages.premiumImage,
//                         height: 16,
//                         width: 17,
//                       ),
//                     ),
//                   ),
//                   SizedBox(width: 8),
//                   DottedBorder(
//                     color: AppColor.black.withOpacity(0.2),
//                     dashPattern: [3.0, 2.0],
//                     borderType: dotted.BorderType.RRect,
//                     padding: EdgeInsets.all(10),
//                     radius: Radius.circular(18),
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 5,
//                       ),
//                       child: Row(
//                         mainAxisAlignment:
//                             MainAxisAlignment.center,
//                         children: [
//                           Text(
//                             '2Months Pro Premium',
//                             style: AppTextStyles.mulish(
//                               fontWeight: FontWeight.w700,
//                               fontSize: 12,
//                               color: AppColor.darkBlue,
//                             ),
//                           ),
//                           SizedBox(width: 10),
//                           Text(
//                             '10.40Pm',
//                             style: AppTextStyles.mulish(
//                               fontWeight: FontWeight.w400,
//                               fontSize: 12,
//                               color: AppColor.lightGray3,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   Spacer(),
//                   GestureDetector(
//                     onTap: () {
//                       // Navigator.push(
//                       //   context,
//                       //   MaterialPageRoute(
//                       //     builder: (context) =>
//                       //         CommonBottomNavigation(initialIndex: 1),
//                       //   ),
//                       // );
//                     },
//                     child: Container(
//                       padding: EdgeInsets.symmetric(
//                         horizontal: 13,
//                         vertical: 7.5,
//                       ),
//                       decoration: BoxDecoration(
//                         color: AppColor.black,
//                         borderRadius: BorderRadius.circular(25),
//                       ),
//                       child: Image.asset(
//                         AppImages.rightStickArrow,
//                         height: 19,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     ],
//   ),
// ),
// SizedBox(height: 25),
// Padding(
//   padding: const EdgeInsets.symmetric(horizontal: 15),
//   child: Column(
//     children: [
//       Container(
//         decoration: BoxDecoration(
//           color: AppColor.iceGray,
//           borderRadius: BorderRadius.circular(15),
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Container(
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [
//                       AppColor.black.withOpacity(0.054),
//                       AppColor.black.withOpacity(0.0),
//                     ],
//                     begin: Alignment.centerLeft,
//                     end: Alignment.centerRight,
//                   ),
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 15,
//                     vertical: 10,
//                   ),
//                   child: Row(
//                     children: [
//                       Text(
//                         'Product',
//                         style: AppTextStyles.mulish(
//                           fontSize: 12,
//                           fontWeight: FontWeight.bold,
//                           color: AppColor.darkBlue,
//                         ),
//                       ),
//                       SizedBox(width: 6),
//                       Image.asset(
//                         AppImages.rightArrow,
//                         height: 10,
//                         color: AppColor.darkGrey,
//                       ),
//                       SizedBox(width: 6),
//                       Text(
//                         'Daily',
//                         style: AppTextStyles.mulish(
//                           fontSize: 12,
//                           fontWeight: FontWeight.bold,
//                           color: AppColor.darkBlue,
//                         ),
//                       ),
//                       SizedBox(width: 6),
//                       Image.asset(
//                         AppImages.rightArrow,
//                         height: 10,
//                         color: AppColor.darkGrey,
//                       ),
//                       SizedBox(width: 6),
//                       Text(
//                         'Grocery',
//                         style: AppTextStyles.mulish(
//                           fontSize: 12,
//                           fontWeight: FontWeight.bold,
//                           color: AppColor.darkBlue,
//                         ),
//                       ),
//                       SizedBox(width: 6),
//                       Image.asset(
//                         AppImages.rightArrow,
//                         height: 10,
//                         color: AppColor.darkGrey,
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               SizedBox(height: 20),
//               ClipRRect(
//                 borderRadius: BorderRadius.circular(15),
//                 child: AspectRatio(
//                   aspectRatio:
//                       328 / 143, // your original image ratio
//                   child: Image.asset(
//                     AppImages.homeImage2,
//                     width: double.infinity,
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//               ),
//
//               SizedBox(height: 20),
//               Text(
//                 'HJ Grocery Stores',
//                 style: AppTextStyles.mulish(
//                   fontWeight: FontWeight.w700,
//                   fontSize: 18,
//                   color: AppColor.darkBlue,
//                 ),
//               ),
//               SizedBox(height: 10),
//               Text(
//                 overflow: TextOverflow.ellipsis,
//                 maxLines: 2,
//                 '77, Nehru St, Sathyamoorthy Nagar, State Bank Supervisors Colony, Madurai, Tamil Nadu 625016',
//                 style: AppTextStyles.mulish(
//                   fontWeight: FontWeight.w400,
//                   fontSize: 12,
//                   color: AppColor.lightGray3,
//                 ),
//               ),
//               SizedBox(height: 20),
//               Row(
//                 children: [
//                   Container(
//                     decoration: BoxDecoration(
//                       color: AppColor.white,
//                       borderRadius: BorderRadius.circular(50),
//                     ),
//                     child: Padding(
//                       padding: const EdgeInsets.all(10),
//                       child: Image.asset(
//                         AppImages.premiumImage01,
//                         height: 16,
//                         width: 17,
//                       ),
//                     ),
//                   ),
//                   SizedBox(width: 8),
//                   DottedBorder(
//                     color: AppColor.black.withOpacity(0.2),
//                     dashPattern: [3.0, 2.0],
//                     borderType: dotted.BorderType.RRect,
//                     padding: EdgeInsets.all(10),
//                     radius: Radius.circular(18),
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 5,
//                       ),
//                       child: Row(
//                         mainAxisAlignment:
//                             MainAxisAlignment.center,
//                         children: [
//                           Text(
//                             '1Year Premium ',
//                             style: AppTextStyles.mulish(
//                               fontWeight: FontWeight.w700,
//                               fontSize: 12,
//                               color: AppColor.darkBlue,
//                             ),
//                           ),
//                           SizedBox(width: 10),
//                           Text(
//                             '10.40Pm',
//                             style: AppTextStyles.mulish(
//                               fontWeight: FontWeight.w400,
//                               fontSize: 12,
//                               color: AppColor.lightGray3,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   Spacer(),
//                   // SizedBox(width: 10),
//                   GestureDetector(
//                     onTap: () {
//                       // Navigator.push(
//                       //   context,
//                       //   MaterialPageRoute(
//                       //     builder: (context) =>
//                       //         CommonBottomNavigation(initialIndex: 1),
//                       //   ),
//                       // );
//                     },
//                     child: Container(
//                       padding: EdgeInsets.symmetric(
//                         horizontal: 13,
//                         vertical: 7.5,
//                       ),
//                       decoration: BoxDecoration(
//                         color: AppColor.black,
//                         borderRadius: BorderRadius.circular(25),
//                       ),
//                       child: Image.asset(
//                         AppImages.rightStickArrow,
//                         height: 19,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     ],
//   ),
// ),
// SizedBox(height: 44),
