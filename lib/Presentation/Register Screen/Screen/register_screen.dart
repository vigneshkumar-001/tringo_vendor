import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../Core/Const/app_images.dart';
import '../../../Core/Session/registration_product_seivice.dart';
import '../../../Core/Session/registration_session.dart';
import '../../../Core/Utility/app_textstyles.dart';
import '../../../Core/Widgets/app_go_routes.dart';
import '../../../Core/Widgets/common_container.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  int selectedIndex = -1;
  bool isIndividual = true;

  bool? selectedKind;

  void _goNext() {
    if (selectedKind == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your business type.')),
      );
      return;
    }

    // selectedKind == true  → Individual
    // selectedKind == false → Company
    final bool isIndividual = selectedKind!;
    final BusinessType businessType =
        isIndividual ? BusinessType.individual : BusinessType.company;

    RegistrationSession.instance.businessType = businessType;
    RegistrationProductSeivice.instance.businessType = businessType;

    // Product / Service
    final BusinessCategory businessCategory =
        (selectedIndex == 0)
            ? BusinessCategory.sellingProduct
            : BusinessCategory.services;

    RegistrationProductSeivice.instance.businessCategory = businessCategory;

    // Owner info
    context.pushNamed(
      AppRoutes.ownerInfo,
      extra: {'isService': selectedIndex == 1, 'isIndividual': isIndividual},
    );
  }

  ///new1///
  // void _goNext() {
  //   if (selectedKind == null) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Please select your business type.')),
  //     );
  //     return;
  //   }
  //
  //   // selectedKind == true  → Individual
  //   // selectedKind == false → Company
  //   final bool isIndividual = selectedKind!;
  //   final BusinessType businessType = isIndividual
  //       ? BusinessType.individual
  //       : BusinessType.company;
  //
  //   // 🔹 Save premium / non-premium to both sessions
  //   RegistrationSession.instance.businessType = businessType;
  //   RegistrationProductSeivice.instance.businessType = businessType;
  //
  //   // 🔹 Product / Service selection
  //   final BusinessCategory businessCategory = (selectedIndex == 0)
  //       ? BusinessCategory.product
  //       : BusinessCategory.service;
  //
  //   RegistrationProductSeivice.instance.businessCategory = businessCategory;
  //
  //   // 🔹 Go to owner info with flags
  //   context.pushNamed(
  //     AppRoutes.ownerInfo,
  //     extra: {'isService': selectedIndex == 1, 'isIndividual': isIndividual},
  //   );
  // }

  @override
  void dispose() {
    RegistrationSession.instance.reset();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonContainer.topLeftArrow(
                  onTap: () {
                    Navigator.maybePop(context);
                  },
                ),
                SizedBox(height: 20),

                Text('Choose', style: AppTextStyles.textWithBold(fontSize: 28)),
                Text(
                  'your business type',
                  style: AppTextStyles.textWithBold(fontSize: 28),
                ),
                SizedBox(height: 12),

                Text(
                  'Connect your business to millions of customers. Whether you sell products or services, our platform helps you grow.',
                  style: AppTextStyles.textWithBold(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                SizedBox(height: 20),

                CommonContainer.sellingProduct(
                  image: AppImages.sell,
                  title: 'I’m Selling Products',
                  description:
                      'Gain instant visibility and connect with thousands of local customers actively searching for your goods. Our platform is your direct link to a wider audience and increased sales.',
                  isSelected: selectedIndex == 0,
                  selectedKind: selectedKind,
                  onTap: () {
                    setState(() {
                      selectedIndex = 0;
                      selectedKind =
                          null; // show chooser, hide button until user picks
                    });
                  },
                  onToggle: (bool? value) {
                    setState(() => selectedKind = value);
                  },
                  buttonTap: _goNext,
                ),

                SizedBox(height: 20),

                CommonContainer.sellingProduct(
                  image: AppImages.service,
                  title: 'I Do Services',
                  description:
                      'Grow your client base and fill your schedule with quality leads from our platform. We help you get discovered by new customers who need your expertise right now.',
                  isSelected: selectedIndex == 1,
                  selectedKind: selectedKind,
                  onTap: () {
                    setState(() {
                      selectedIndex = 1;
                      selectedKind = null;
                    });
                  },
                  onToggle: (bool? value) {
                    setState(() => selectedKind = value);
                  },
                  buttonTap: _goNext,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
