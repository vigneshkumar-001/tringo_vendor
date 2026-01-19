import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Core/Const/app_color.dart';
import '../../../Core/Const/app_images.dart';
import '../../../Core/Utility/app_textstyles.dart';
import '../../../Core/Widgets/app_go_routes.dart';

class PrivacyPolicy extends StatefulWidget {
  const PrivacyPolicy({super.key});

  @override
  State<PrivacyPolicy> createState() => _PrivacyPolicyState();
}

class _PrivacyPolicyState extends State<PrivacyPolicy> {
  @override
  Widget build(BuildContext context) {
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

            Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 35, top: 50),
                      child: Image.asset(AppImages.logo, height: 88, width: 85),
                    ),

                    SizedBox(height: 81),

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
                              SizedBox(width: 5),
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

                    SizedBox(height: 35),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 35),
                      child: Text(
                        '''Lorem ipsum dolor sit amet, consectetur adipiscing elit. Pellentesque commodo vitae lectus at mattis. Pellentesque tincidunt ultricies blandit. In auctor euismod velit sit amet laoreet. Mauris pretium, erat non congue vehicula, mauris mi interdum felis, a efficitur velit libero vitae nisl. Nulla sed lorem vel ipsum tristique ullamcorper sed eget felis.

Sed odio purus, tristique eu risus in, volutpat malesuada lectus. Aenean et fringilla turpis. Phasellus laoreet leo vel pulvinar aliquam. Nulla nec commodo nulla. Cras varius nisi ac urna aliquam, sit amet laoreet sem commodo.

Nulla malesuada pellentesque porta. Maecenas sollicitudin sodales dolor, vel lacinia enim finibus vitae. Aliquam consectetur, magna in tristique blandit, augue turpis lacinia lacus, at faucibus leo libero eleifend justo. Proin lobortis vehicula viverra. Etiam in arcu condimentum, fermentum tortor vel, malesuada augue.

Sed euismod lectus ut mi varius, a tempor mi rhoncus. Sed sodales sollicitudin est. Aenean non lacinia nisi, eu interdum augue. Sed volutpat justo non ex convallis efficitur. Vestibulum blandit quam ante, sit amet vehicula felis fermentum faucibus. Mauris vestibulum quam sit amet dui ullamcorper pretium.''',
                        style: AppTextStyles.ibmPlexSans(
                          fontSize: 14,
                          height: 1.6,
                          color: AppColor.darkGrey,
                        ),
                        textAlign: TextAlign.justify,
                      ),
                    ),

                    SizedBox(height: 35),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 35),
                      child: Row(
                        children: [
                          InkWell(
                            borderRadius: BorderRadius.circular(15),
                            onTap: () {},
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColor.iceBlue,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Padding(
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
                          ),

                          SizedBox(width: 15),

                          InkWell(
                            borderRadius: BorderRadius.circular(15),
                            onTap: () async {
                              // final SharedPreferences prefs =
                              // await SharedPreferences.getInstance();
                              // prefs.clear( );

                              context.pushNamed(AppRoutes.heaterRegister1);
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //     builder: (context) => HomeScreen(),
                              //   ),
                              // );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColor.skyBlue,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 65,
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
                          ),
                        ],
                      ),
                    ),
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
