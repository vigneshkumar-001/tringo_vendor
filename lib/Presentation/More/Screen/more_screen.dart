

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:dotted_border/dotted_border.dart' as dotted;
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
import '../../More Details/Screen/more_details.dart';
import '../../pay_success_and_cancel.dart';

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Offline Pages for Demo',
                  style: AppTextStyles.mulish(
                    fontWeight: FontWeight.w700,
                    fontSize: 24,
                    color: AppColor.darkBlue,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'If you need more offline demo here ask to admin',
                  style: AppTextStyles.mulish(color: AppColor.gray84),
                ),
                SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: AppColor.iceGray,
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
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 15,
                                    vertical: 10,
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        'Product',
                                        style: AppTextStyles.mulish(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: AppColor.darkBlue,
                                        ),
                                      ),
                                      SizedBox(width: 6),
                                      Image.asset(
                                        AppImages.rightArrow,
                                        height: 10,
                                        color: AppColor.darkGrey,
                                      ),
                                      SizedBox(width: 6),
                                      Text(
                                        'Daily',
                                        style: AppTextStyles.mulish(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: AppColor.darkBlue,
                                        ),
                                      ),
                                      SizedBox(width: 6),
                                      Image.asset(
                                        AppImages.rightArrow,
                                        height: 10,
                                        color: AppColor.darkGrey,
                                      ),
                                      SizedBox(width: 6),
                                      Text(
                                        'Grocery',
                                        style: AppTextStyles.mulish(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: AppColor.darkBlue,
                                        ),
                                      ),
                                      SizedBox(width: 6),
                                      Image.asset(
                                        AppImages.rightArrow,
                                        height: 10,
                                        color: AppColor.darkGrey,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 20),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: AspectRatio(
                                  aspectRatio:
                                      328 / 143, // your original image ratio
                                  child: Image.asset(
                                    AppImages.homeImage2,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),

                              SizedBox(height: 20),
                              Text(
                                'Kandhasamy Mobiles',
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
                                '77, Nehru St, Sathyamoorthy Nagar, State Bank Supervisors Colony, Madurai, Tamil Nadu 625016',
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
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Image.asset(
                                        AppImages.premiumImage01,
                                        height: 16,
                                        width: 17,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  DottedBorder(
                                    color: AppColor.black.withOpacity(0.2),
                                    dashPattern: [3.0, 2.0],
                                    borderType: dotted.BorderType.RRect,
                                    padding: EdgeInsets.all(10),
                                    radius: Radius.circular(18),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 5,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            '1Year Premium ',
                                            style: AppTextStyles.mulish(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 12,
                                              color: AppColor.darkBlue,
                                            ),
                                          ),
                                          SizedBox(width: 10),
                                          Text(
                                            '10.40Pm',
                                            style: AppTextStyles.mulish(
                                              fontWeight: FontWeight.w400,
                                              fontSize: 12,
                                              color: AppColor.lightGray3,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Spacer(),
                                  // SizedBox(width: 10),
                                  GestureDetector(
                                    onTap: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => MoreDetails()));
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 13,
                                        vertical: 7.5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColor.black,
                                        borderRadius: BorderRadius.circular(25),
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
                SizedBox(height: 25),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: AppColor.iceGray,
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
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 15,
                                    vertical: 10,
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        'Product',
                                        style: AppTextStyles.mulish(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: AppColor.darkBlue,
                                        ),
                                      ),
                                      SizedBox(width: 6),
                                      Image.asset(
                                        AppImages.rightArrow,
                                        height: 10,
                                        color: AppColor.darkGrey,
                                      ),
                                      SizedBox(width: 6),
                                      Text(
                                        'Daily',
                                        style: AppTextStyles.mulish(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: AppColor.darkBlue,
                                        ),
                                      ),
                                      SizedBox(width: 6),
                                      Image.asset(
                                        AppImages.rightArrow,
                                        height: 10,
                                        color: AppColor.darkGrey,
                                      ),
                                      SizedBox(width: 6),
                                      Text(
                                        'Grocery',
                                        style: AppTextStyles.mulish(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: AppColor.darkBlue,
                                        ),
                                      ),
                                      SizedBox(width: 6),
                                      Image.asset(
                                        AppImages.rightArrow,
                                        height: 10,
                                        color: AppColor.darkGrey,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 20),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: AspectRatio(
                                  aspectRatio:
                                      328 / 143, // your original image ratio
                                  child: Image.asset(
                                    AppImages.homeImage2,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),

                              SizedBox(height: 20),
                              Text(
                                'HJ Grocery Stores',
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
                                '77, Nehru St, Sathyamoorthy Nagar, State Bank Supervisors Colony, Madurai, Tamil Nadu 625016',
                                style: AppTextStyles.mulish(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12,
                                  color: AppColor.lightGray3,
                                ),
                              ),
                              SizedBox(height: 20),
                              Row(
                                children: [
                                  Expanded(
                                    child: DottedBorder(
                                      color: AppColor.black.withOpacity(0.2),
                                      dashPattern: const [3.0, 2.0],
                                      borderType: dotted.BorderType.RRect,
                                      radius: const Radius.circular(18),
                                      padding: EdgeInsets.zero,
                                      child: Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 12,
                                        ),
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          'Freemium',
                                          style: AppTextStyles.mulish(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 12,
                                            color: AppColor.darkBlue,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 12),

                                  GestureDetector(
                                    onTap: () {

                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 13,
                                        vertical: 7.5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColor.black,
                                        borderRadius: BorderRadius.circular(25),
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
                SizedBox(height: 25),
                InkWell(
                  borderRadius: BorderRadius.circular(15),
                  onTap: () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) => HomeScreen(),
                    //   ),
                    // );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColor.black,
                      borderRadius: BorderRadius.circular(15),
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
                            'Create New Shop',
                            style: AppTextStyles.mulish(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColor.white,
                            ),
                          ),
                          SizedBox(width: 10),
                          Image.asset(
                            AppImages.rightStickArrow,
                            height: 23,
                            width: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 54),
                Text(
                  'Need Attention',
                  style: AppTextStyles.mulish(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColor.darkBlue,
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColor.iceGray,
                      borderRadius: BorderRadius.circular(15),
                    ),
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
                              Text(
                                'Product',
                                style: AppTextStyles.mulish(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColor.darkBlue,
                                ),
                              ),
                              SizedBox(width: 6),
                              Image.asset(
                                AppImages.rightArrow,
                                height: 10,
                                color: AppColor.darkGrey,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Daily',
                                style: AppTextStyles.mulish(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColor.darkBlue,
                                ),
                              ),
                              SizedBox(width: 6),
                              Image.asset(
                                AppImages.rightArrow,
                                height: 10,
                                color: AppColor.darkGrey,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Grocery',
                                style: AppTextStyles.mulish(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColor.darkBlue,
                                ),
                              ),
                              SizedBox(width: 6),
                              Image.asset(
                                AppImages.rightArrow,
                                height: 10,
                                color: AppColor.darkGrey,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: SizedBox(
                                width: 112,
                                height: 113,
                                child: Image.asset(
                                  AppImages.homeImage2,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            SizedBox(width: 20),

                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 18.0,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'HJ Grocery Stores',
                                      style: AppTextStyles.mulish(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 18,
                                        color: AppColor.darkBlue,
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      '77, Nehru St, Sathyamoorthy Nagar, State Bank Supervisors Colony, Madurai, Tamil Nadu 625016',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTextStyles.mulish(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 12,
                                        color: AppColor.lightGray3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 20),

                        Row(
                          children: [
                            Expanded(
                              child: DottedBorder(
                                color: AppColor.black.withOpacity(0.2),
                                dashPattern: const [3, 2],
                                borderType: dotted.BorderType.RRect,
                                radius: const Radius.circular(18),
                                padding: EdgeInsets.zero,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Waiting to Upload',
                                    style: AppTextStyles.mulish(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                      color: AppColor.darkBlue,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            GestureDetector(
                              onTap: () {},
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColor.white,
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: Image.asset(
                                  AppImages.uploadPhoto,
                                  color: AppColor.darkBlue,
                                  height: 19,
                                ),
                              ),
                            ),
                            SizedBox(width: 12),

                            GestureDetector(
                              onTap: () {},
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 19.5,
                                  vertical: 11.5,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColor.black,
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: Image.asset(
                                  AppImages.callImage,
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
                SizedBox(height: 25),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColor.iceGray,
                      borderRadius: BorderRadius.circular(15),
                    ),
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
                              Text(
                                'Product',
                                style: AppTextStyles.mulish(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColor.darkBlue,
                                ),
                              ),
                              SizedBox(width: 6),
                              Image.asset(
                                AppImages.rightArrow,
                                height: 10,
                                color: AppColor.darkGrey,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Daily',
                                style: AppTextStyles.mulish(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColor.darkBlue,
                                ),
                              ),
                              SizedBox(width: 6),
                              Image.asset(
                                AppImages.rightArrow,
                                height: 10,
                                color: AppColor.darkGrey,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Grocery',
                                style: AppTextStyles.mulish(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColor.darkBlue,
                                ),
                              ),
                              SizedBox(width: 6),
                              Image.asset(
                                AppImages.rightArrow,
                                height: 10,
                                color: AppColor.darkGrey,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: SizedBox(
                                width: 112,
                                height: 113,
                                child: Image.asset(
                                  AppImages.homeImage2,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            SizedBox(width: 20),

                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 18.0,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'HJ Grocery Stores',
                                      style: AppTextStyles.mulish(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 18,
                                        color: AppColor.darkBlue,
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      '77, Nehru St, Sathyamoorthy Nagar, State Bank Supervisors Colony, Madurai, Tamil Nadu 625016',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTextStyles.mulish(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 12,
                                        color: AppColor.lightGray3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 20),

                        Row(
                          children: [
                            Expanded(
                              child: DottedBorder(
                                color: AppColor.black.withOpacity(0.2),
                                dashPattern: const [3, 2],
                                borderType: dotted.BorderType.RRect,
                                radius: const Radius.circular(18),
                                padding: EdgeInsets.zero,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    '50% Uploading',
                                    style: AppTextStyles.mulish(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                      color: AppColor.darkBlue,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            GestureDetector(
                              onTap: () {},
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColor.white,
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: Image.asset(
                                  AppImages.timeLoading,
                                  color: AppColor.darkBlue,
                                  height: 19,
                                ),
                              ),
                            ),
                            SizedBox(width: 12),

                            GestureDetector(
                              onTap: () {},
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 19.5,
                                  vertical: 11.5,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColor.black,
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: Image.asset(
                                  AppImages.callImage,
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
                SizedBox(height: 25),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColor.iceGray,
                      borderRadius: BorderRadius.circular(15),
                    ),
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
                              Text(
                                'Product',
                                style: AppTextStyles.mulish(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColor.darkBlue,
                                ),
                              ),
                              SizedBox(width: 6),
                              Image.asset(
                                AppImages.rightArrow,
                                height: 10,
                                color: AppColor.darkGrey,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Daily',
                                style: AppTextStyles.mulish(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColor.darkBlue,
                                ),
                              ),
                              SizedBox(width: 6),
                              Image.asset(
                                AppImages.rightArrow,
                                height: 10,
                                color: AppColor.darkGrey,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Grocery',
                                style: AppTextStyles.mulish(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColor.darkBlue,
                                ),
                              ),
                              SizedBox(width: 6),
                              Image.asset(
                                AppImages.rightArrow,
                                height: 10,
                                color: AppColor.darkGrey,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: SizedBox(
                                width: 112,
                                height: 113,
                                child: Image.asset(
                                  AppImages.homeImage2,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            SizedBox(width: 20),

                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 18.0,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'HJ Grocery Stores',
                                      style: AppTextStyles.mulish(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 18,
                                        color: AppColor.darkBlue,
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      '77, Nehru St, Sathyamoorthy Nagar, State Bank Supervisors Colony, Madurai, Tamil Nadu 625016',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTextStyles.mulish(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 12,
                                        color: AppColor.lightGray3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 20),

                        Row(
                          children: [
                            Expanded(
                              child: DottedBorder(
                                color: AppColor.black.withOpacity(0.2),
                                dashPattern: const [3, 2],
                                borderType: dotted.BorderType.RRect,
                                radius: const Radius.circular(18),
                                padding: EdgeInsets.zero,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Rejected, Please Check',
                                    style: AppTextStyles.mulish(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                      color: AppColor.darkBlue,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            GestureDetector(
                              onTap: () {},
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColor.red,
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: Image.asset(
                                  AppImages.rightStickArrow,
                                  color: AppColor.white,
                                  height: 19,
                                ),
                              ),
                            ),
                            SizedBox(width: 12),

                            GestureDetector(
                              onTap: () {},
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 19.5,
                                  vertical: 11.5,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColor.black,
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: Image.asset(
                                  AppImages.callImage,
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
                SizedBox(height: 25),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColor.iceGray,
                      borderRadius: BorderRadius.circular(15),
                    ),
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
                              Text(
                                'Product',
                                style: AppTextStyles.mulish(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColor.darkBlue,
                                ),
                              ),
                              SizedBox(width: 6),
                              Image.asset(
                                AppImages.rightArrow,
                                height: 10,
                                color: AppColor.darkGrey,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Daily',
                                style: AppTextStyles.mulish(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColor.darkBlue,
                                ),
                              ),
                              SizedBox(width: 6),
                              Image.asset(
                                AppImages.rightArrow,
                                height: 10,
                                color: AppColor.darkGrey,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Grocery',
                                style: AppTextStyles.mulish(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColor.darkBlue,
                                ),
                              ),
                              SizedBox(width: 6),
                              Image.asset(
                                AppImages.rightArrow,
                                height: 10,
                                color: AppColor.darkGrey,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: SizedBox(
                                width: 112,
                                height: 113,
                                child: Image.asset(
                                  AppImages.homeImage2,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            SizedBox(width: 20),

                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 18.0,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'HJ Grocery Stores',
                                      style: AppTextStyles.mulish(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 18,
                                        color: AppColor.darkBlue,
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      '77, Nehru St, Sathyamoorthy Nagar, State Bank Supervisors Colony, Madurai, Tamil Nadu 625016',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTextStyles.mulish(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 12,
                                        color: AppColor.lightGray3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 20),

                        Row(
                          children: [
                            Expanded(
                              child: DottedBorder(
                                color: AppColor.black.withOpacity(0.2),
                                dashPattern: const [3, 2],
                                borderType: dotted.BorderType.RRect,
                                radius: const Radius.circular(18),
                                padding: EdgeInsets.zero,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Verify Mobile Number',
                                    style: AppTextStyles.mulish(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                      color: AppColor.darkBlue,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            GestureDetector(
                              onTap: () {

                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColor.green,
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: Image.asset(
                                  AppImages.rightStickArrow,
                                  color: AppColor.white,
                                  height: 19,
                                ),
                              ),
                            ),
                            SizedBox(width: 12),

                            GestureDetector(
                              onTap: () {},
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 19.5,
                                  vertical: 11.5,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColor.black,
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: Image.asset(
                                  AppImages.callImage,
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
                SizedBox(height: 25),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
