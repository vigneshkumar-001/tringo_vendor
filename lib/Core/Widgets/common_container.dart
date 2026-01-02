import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tringo_vendor_new/Core/Utility/app_textstyles.dart';

import '../Const/app_color.dart';
import '../Const/app_images.dart';

class AadhaarInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final trimmed = digits.length > 12 ? digits.substring(0, 12) : digits;

    final buffer = StringBuffer();
    for (int i = 0; i < trimmed.length; i++) {
      if (i == 4 || i == 8) buffer.write(' ');
      buffer.write(trimmed[i]);
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

enum DatePickMode { none, single, range }

class CommonContainer {
  static Widget sellingProduct({
    required String image,
    required VoidCallback onTap,
    VoidCallback? buttonTap,
    required String title,
    required String description,
    required bool isSelected,
    required bool? selectedKind, // null until user chooses
    bool isSellingCard = true,
    required ValueChanged<bool?> onToggle, // true/false/null
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border:
              isSelected
                  ? Border(
                    bottom: BorderSide(width: 8, color: Colors.black),
                    top: BorderSide(width: 2, color: Colors.black),
                    left: BorderSide(width: 2, color: Colors.black),
                    right: BorderSide(width: 2, color: Colors.black),
                  )
                  : Border.all(color: Color(0xffD0D0D0), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Image.asset(image, height: 50, width: 50),
            SizedBox(height: 14),

            // Title with bold second half
            RichText(
              text: TextSpan(
                text: title.split(' ').take(2).join(' ') + ' ',
                style: AppTextStyles.mulish(
                  fontSize: 22,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
                children: [
                  TextSpan(
                    text: title.split(' ').skip(2).join(' '),
                    style: AppTextStyles.mulish(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12),

            Text(
              description,
              style: AppTextStyles.mulish(
                fontSize: 13,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),

            if (isSellingCard) ...[
              SizedBox(height: 24),

              if (isSelected) ...[
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Builder(
                    builder: (_) {
                      final bool isIndiv = selectedKind == true;
                      final bool isComp = selectedKind == false;

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // --- Individual ---
                          Expanded(
                            child: GestureDetector(
                              onTap: () => onToggle(true),
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 5),
                                decoration: BoxDecoration(
                                  color:
                                      isIndiv
                                          ? Colors.white
                                          : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow:
                                      isIndiv
                                          ? [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.08,
                                              ),
                                              offset: Offset(0, 2),
                                              blurRadius: 10,
                                            ),
                                          ]
                                          : [],
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      "Individual",
                                      style: AppTextStyles.mulish(
                                        fontWeight:
                                            isIndiv
                                                ? FontWeight.w800
                                                : FontWeight
                                                    .normal, // << change
                                        color: Colors.black,
                                      ),
                                    ),
                                    if (isIndiv)
                                      Text(
                                        "Selected",
                                        style: AppTextStyles.mulish(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // --- Center "or" chip: only BEFORE user chooses ---
                          if (selectedKind == null)
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 15,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 5,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  "or",
                                  style: AppTextStyles.mulish(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),

                          // --- Company ---
                          Expanded(
                            child: GestureDetector(
                              onTap: () => onToggle(false),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      isComp
                                          ? Colors.white
                                          : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow:
                                      isComp
                                          ? [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.08,
                                              ),
                                              offset: Offset(0, 2),
                                              blurRadius: 10,
                                            ),
                                          ]
                                          : [],
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      "Company",
                                      style: AppTextStyles.mulish(
                                        fontWeight:
                                            isComp
                                                ? FontWeight.w800
                                                : FontWeight
                                                    .normal, // << change
                                        color: Colors.black,
                                      ),
                                    ),
                                    if (isComp)
                                      Text(
                                        "Selected",
                                        style: AppTextStyles.mulish(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                SizedBox(height: 20),

                if (selectedKind != null)
                  GestureDetector(
                    onTap: buttonTap,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Save & Continue",
                            style: AppTextStyles.mulish(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 12),
                          Image.asset(AppImages.rightStickArrow, height: 20),
                        ],
                      ),
                    ),
                  ),
              ] else ...[
                // When not selected: show NOTHING (matches screenshot-1)
                SizedBox.shrink(),
              ],
            ],
          ],
        ),
      ),
    );
  }

  static Widget button({
    required GestureTapCallback? onTap,
    required Widget text,
    double? size = double.infinity,
    double? imgHeight = 24,
    double? imgWeight = 24,
    double? borderRadius = 18,
    Widget? loader,
    Color buttonColor = AppColor.blue,
    Color? foreGroundColor,
    Color? borderColor,
    Color? textColor = Colors.white,
    bool? isLoading,
    bool hasBorder = false,
    String? imagePath,
  }) {
    final bool showLoading = isLoading ?? (loader != null); // 👈 auto mode
    return SizedBox(
      width: size,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          foregroundColor: foreGroundColor,
          shape:
              hasBorder
                  ? RoundedRectangleBorder(
                    side: const BorderSide(color: Color(0xff3F5FF2)),
                    borderRadius: BorderRadius.circular(borderRadius!),
                  )
                  : RoundedRectangleBorder(
                    side: BorderSide(color: borderColor ?? Colors.transparent),
                    borderRadius: BorderRadius.circular(borderRadius!),
                  ),
          elevation: 0,
          fixedSize: Size(150.w, 45.h),
          backgroundColor: buttonColor,
        ),
        child:
            showLoading
                ? loader
                : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DefaultTextStyle(
                      style: TextStyle(
                        fontFamily: "Roboto-normal",
                        fontSize: 16.sp,
                        color: textColor,
                        fontWeight: FontWeight.bold,
                      ),
                      child: text,
                    ),
                    if (imagePath != null) ...[
                      SizedBox(width: 15.w),
                      Image.asset(
                        imagePath,
                        height: imgHeight!.sp,
                        width: imgWeight!.sp,
                      ),
                    ],
                  ],
                ),
      ),
    );
  }

  static button2({
    BuildContext? context,
    VoidCallback? onTap,
    required String text,
    Widget? loader,
    double fontSize = 16,
    Color? textColor = Colors.white,
    bool isBorder = false,
    FontWeight fontWeight = FontWeight.w700,
    double? width = 200,
    double? height = 60,
    String? image,
    Color? backgroundColor,
  }) {
    return Center(
      child: SizedBox(
        width: width,
        height: height,
        child: Container(
          decoration: BoxDecoration(
            color:
                backgroundColor ??
                (isBorder ? AppColor.white : AppColor.skyBlue),
            border:
                isBorder
                    ? Border.all(color: const Color(0xff3F5FF2), width: 2)
                    : null,
            borderRadius: BorderRadius.circular(18),
          ),
          child: ElevatedButton(
            style: ButtonStyle(
              padding: MaterialStateProperty.all(EdgeInsets.zero),
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              elevation: MaterialStateProperty.all(0),
              backgroundColor: MaterialStateProperty.all(Colors.transparent),
            ),
            onPressed: onTap,
            child:
                loader != null
                    ? loader
                    : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          text,
                          style: TextStyle(
                            fontFamily: "Roboto-normal",
                            fontSize: fontSize,
                            color: textColor,
                            fontWeight: fontWeight,
                          ),
                        ),
                        if (image != null) ...[
                          const SizedBox(width: 15),
                          Image.asset(image, height: 20),
                        ],
                      ],
                    ),
          ),
        ),
      ),
    );
  }

  static void _showDropdownBottomSheet(
    BuildContext context,
    List<String> items,
    TextEditingController? controller,
    FormFieldState<String> state,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return ListView.separated(
          shrinkWrap: true,
          itemCount: items.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final value = items[index];
            final isSelected = controller?.text == value;
            return ListTile(
              title: Text(
                value,
                style: AppTextStyles.mulish(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? AppColor.skyBlue : Colors.black,
                ),
              ),
              onTap: () {
                controller?.text = value;
                state.didChange(value);
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }

  static Widget fillingContainer({
    String? text,
    String? text1,
    double? textSize = 14,
    Color? textColor = AppColor.mediumGray,
    FontWeight? textFontWeight,
    Key? fieldKey,
    TextEditingController? controller,
    String? imagePath,
    bool verticalDivider = true,
    Function(String)? onChanged,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    VoidCallback? onDetailsTap,
    double imageHight = 30,
    double imageWidth = 11,
    int? maxLine,
    int flex = 4,
    bool isTamil = false,
    bool isAadhaar = false,
    bool isDOB = false,
    bool isMobile = false,
    bool isPincode = false,
    bool readOnly = false,
    bool isDropdown = false,
    List<String>? dropdownItems,
    BuildContext? context,
    FormFieldValidator<String>? validator,
    FocusNode? focusNode,
    Color borderColor = AppColor.red,
    Color? imageColor,
    // VoidCallback? onFieldTap,
    Future<void> Function()? onFieldTap,
    Widget? suffixWidget,

    // 🔹 New
    DatePickMode datePickMode = DatePickMode.none,
    bool styledRangeText = false,
  }) {
    return FormField<String>(
      validator: validator,
      key: fieldKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      builder: (state) {
        final hasError = state.hasError;

        // -------------------- Date Formatting Helper --------------------
        String dd(int v) => v.toString().padLeft(2, '0');
        String fmt(DateTime d) => '${dd(d.day)}-${dd(d.month)}-${d.year}';

        void _handleTap() async {
          if (datePickMode == DatePickMode.single) {
            if (context == null) return;

            final now = DateTime.now();
            final maxDob = DateTime(
              now.year - 18,
              now.month,
              now.day,
            ); // 18 years completed

            final picked = await showDatePicker(
              context: context!,
              initialDate: maxDob, // default = 18 years age
              firstDate: DateTime(1900),
              lastDate: maxDob, // ❌ below 18 not allowed
              builder:
                  (ctx, child) => Theme(
                    data: Theme.of(ctx).copyWith(
                      dialogBackgroundColor: AppColor.white,
                      colorScheme: ColorScheme.light(
                        primary: AppColor.blue,
                        onPrimary: Colors.white,
                        onSurface: AppColor.black,
                      ),
                    ),
                    child: child!,
                  ),
            );

            if (picked != null) {
              controller?.text =
                  '${picked.day.toString().padLeft(2, '0')}-'
                  '${picked.month.toString().padLeft(2, '0')}-${picked.year}';
              state.didChange(controller?.text);
            }
            return;
          }

          // Single Date Picker
          // if (datePickMode == DatePickMode.single) {
          //   if (context == null) return;
          //   final picked = await showDatePicker(
          //     context: context!,
          //     initialDate: DateTime.now(),
          //     firstDate: DateTime(1900),
          //     lastDate: DateTime(2100),
          //     builder:
          //         (ctx, child) => Theme(
          //           data: Theme.of(ctx).copyWith(
          //             dialogBackgroundColor: AppColor.white,
          //             colorScheme: ColorScheme.light(
          //               primary: AppColor.blue,
          //               onPrimary: Colors.white,
          //               onSurface: AppColor.black,
          //             ),
          //             textButtonTheme: TextButtonThemeData(
          //               style: TextButton.styleFrom(
          //                 textStyle: AppTextStyles.mulish(),
          //                 foregroundColor: AppColor.blue,
          //               ),
          //             ),
          //           ),
          //           child: child!,
          //         ),
          //   );
          //   if (picked != null) {
          //     controller?.text =
          //         '${picked.day.toString().padLeft(2, '0')}-'
          //         '${picked.month.toString().padLeft(2, '0')}-${picked.year}';
          //     state.didChange(controller?.text);
          //   }
          //   return;
          // }

          // Range Picker
          if (datePickMode == DatePickMode.range) {
            if (context == null) return;
            final picked = await showDateRangePicker(
              context: context!,
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
              initialDateRange: DateTimeRange(
                start: DateTime.now(),
                end: DateTime.now().add(const Duration(days: 7)),
              ),
              builder:
                  (ctx, child) => Theme(
                    data: Theme.of(ctx).copyWith(
                      dialogBackgroundColor: AppColor.white,
                      colorScheme: ColorScheme.light(
                        primary: AppColor.blue,
                        onPrimary: Colors.white,
                        onSurface: AppColor.black,
                      ),
                      textButtonTheme: TextButtonThemeData(
                        style: TextButton.styleFrom(
                          textStyle: AppTextStyles.mulish(
                            fontWeight: FontWeight.w700,
                          ),
                          foregroundColor: AppColor.lightSkyBlue,
                        ),
                      ),
                    ),
                    child: child!,
                  ),
            );
            if (picked != null) {
              controller?.text =
                  '${picked.start.day.toString().padLeft(2, '0')}-'
                  '${picked.start.month.toString().padLeft(2, '0')}-${picked.start.year}'
                  '  to  '
                  '${picked.end.day.toString().padLeft(2, '0')}-'
                  '${picked.end.month.toString().padLeft(2, '0')}-${picked.end.year}';
              state.didChange(controller?.text);
            }
            return;
          }

          // Dropdown
          if (isDropdown && dropdownItems?.isNotEmpty == true) {
            if (context == null) return;
            FocusScope.of(context!).unfocus();
            await Future.delayed(const Duration(milliseconds: 100));
            _showDropdownBottomSheet(
              context!,
              dropdownItems!,
              controller,
              state,
            );
            return;
          }

          // Default (time fields etc.) — no context required
          if (onFieldTap != null) {
            await onFieldTap!(); // open your showTimePicker
            state.didChange(controller?.text); // sync to FormField
          }
        }

        final effectiveInputFormatters =
            isAadhaar
                ? <TextInputFormatter>[AadhaarInputFormatter()]
                : isMobile
                ? <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ]
                : isPincode
                ? <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ]
                : (inputFormatters ?? const []);

        // final effectiveInputFormatters =
        //     isMobile || isAadhaar || isPincode
        //         ? <TextInputFormatter>[
        //           FilteringTextInputFormatter.digitsOnly,
        //           LengthLimitingTextInputFormatter(
        //             isMobile ? 10 : (isAadhaar ? 12 : 6),
        //           ),
        //         ]
        //         : (inputFormatters ?? const []);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: _handleTap,
              behavior: HitTestBehavior.opaque,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: AppColor.lowGery1,
                  border: Border.all(
                    color: hasError ? AppColor.red : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 15,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: flex,
                        child:
                            datePickMode != DatePickMode.none
                                ? GestureDetector(
                                  onTap: _handleTap,
                                  child: AbsorbPointer(
                                    absorbing: true,
                                    child:
                                        styledRangeText
                                            ? Stack(
                                              alignment: Alignment.centerLeft,
                                              children: [
                                                Opacity(
                                                  opacity: 0,
                                                  child: TextFormField(
                                                    controller: controller,
                                                    validator: validator,
                                                    readOnly: true,
                                                    // style: TextStyle(
                                                    //   fontWeight:
                                                    //       textFontWeight ??
                                                    //       FontWeight
                                                    //           .w700, // <-- THIS IS WHAT YOU WANT
                                                    //   fontSize: 16,
                                                    //   color: AppColor.black,
                                                    // ),
                                                    decoration: InputDecoration(
                                                      border: InputBorder.none,
                                                      isDense: true,
                                                      errorText: null,
                                                      contentPadding:
                                                          EdgeInsets.symmetric(
                                                            horizontal: 10,
                                                          ),
                                                    ),
                                                  ),
                                                ),
                                                ValueListenableBuilder<
                                                  TextEditingValue
                                                >(
                                                  valueListenable: controller!,
                                                  builder: (context, value, _) {
                                                    final raw =
                                                        value.text.trim();
                                                    if (raw.isEmpty) {
                                                      return Text(
                                                        text1 ?? '',
                                                        style:
                                                            AppTextStyles.mulish(
                                                              fontSize: 14,
                                                              color:
                                                                  AppColor
                                                                      .mediumGray,
                                                            ),
                                                      );
                                                    }

                                                    final parts = raw.split(
                                                      RegExp(
                                                        r'\s+to\s+',
                                                        caseSensitive: false,
                                                      ),
                                                    );
                                                    if (parts.length == 1) {
                                                      return Text(
                                                        parts[0],
                                                        style:
                                                            AppTextStyles.mulish(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                              color:
                                                                  AppColor
                                                                      .black,
                                                            ),
                                                      );
                                                    }

                                                    return RichText(
                                                      text: TextSpan(
                                                        children: [
                                                          TextSpan(
                                                            text: parts[0],
                                                            style:
                                                                AppTextStyles.mulish(
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  color:
                                                                      AppColor
                                                                          .black,
                                                                ),
                                                          ),
                                                          TextSpan(
                                                            text: '   to   ',
                                                            style: AppTextStyles.mulish(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color:
                                                                  AppColor
                                                                      .mediumGray,
                                                            ),
                                                          ),
                                                          TextSpan(
                                                            text: parts[1],
                                                            style:
                                                                AppTextStyles.mulish(
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  color:
                                                                      AppColor
                                                                          .black,
                                                                ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ],
                                            )
                                            : TextFormField(
                                              controller: controller,
                                              readOnly: true,
                                              style: TextStyle(
                                                fontWeight:
                                                    textFontWeight ??
                                                    FontWeight
                                                        .w700, // <-- THIS IS WHAT YOU WANT
                                                fontSize: 16,
                                                color: AppColor.black,
                                              ),
                                              decoration: const InputDecoration(
                                                border: InputBorder.none,
                                                isDense: true,
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                    ),
                                              ),
                                            ),
                                  ),
                                )
                                : AbsorbPointer(
                                  absorbing: isDropdown || isDOB || readOnly,
                                  child: TextFormField(
                                    focusNode: focusNode,
                                    controller: controller,
                                    readOnly: readOnly,
                                    maxLines: maxLine,
                                    maxLength:
                                        isMobile
                                            ? 10
                                            : (isAadhaar
                                                ? 14
                                                : (isPincode ? 6 : null)),
                                    keyboardType:
                                        (isMobile || isAadhaar || isPincode)
                                            ? TextInputType.number
                                            : (keyboardType ??
                                                TextInputType.text),
                                    inputFormatters: effectiveInputFormatters,
                                    style: AppTextStyles.textWith700(
                                      fontSize: 18,
                                    ),
                                    decoration: const InputDecoration(
                                      hintText: '',
                                      counterText: '',
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 10,
                                      ),
                                      border: InputBorder.none,
                                      isDense: true,
                                      errorText: null,
                                    ),
                                    onChanged: (v) {
                                      state.didChange(v);
                                      onChanged?.call(v);
                                    },
                                  ),
                                ),
                      ),

                      if (verticalDivider)
                        Container(
                          width: 2,
                          height: 30,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.grey.shade200,
                                Colors.grey.shade300,
                                Colors.grey.shade200,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),

                      if (suffixWidget != null) ...[
                        SizedBox(width: 8),
                        suffixWidget,
                      ],
                      if (text != null) ...[
                        const SizedBox(width: 10),
                        Text(
                          text,
                          style: AppTextStyles.mulish(
                            fontWeight: textFontWeight,
                            fontSize: textSize!,
                            color: textColor,
                          ),
                        ),
                      ],
                      SizedBox(width: 20),
                      if (imagePath != null)
                        InkWell(
                          onTap: () {
                            if (isDropdown) {
                              return null;
                            }
                            controller?.clear();
                            state.didChange('');
                            onDetailsTap?.call();
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(right: 15),
                            child: Image.asset(
                              imagePath,
                              height: imageHight,
                              width: imageWidth,
                              color: imageColor,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(left: 4, top: 5),
                child: Text(
                  state.errorText ?? '',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  static Widget mobileNumberField({
    Key? fieldKey,
    TextEditingController? controller,
    Function(String)? onChanged,
    TextInputType? keyboardType,
    FocusNode? focusNode,
    FormFieldValidator<String>? validator,
    bool isLoading = false,
    bool isOtpVerifying = false,
    bool readOnly = false,

    Future<bool> Function(String mobile)? onSendOtp,
    Future<bool> Function(String mobile, String otp)? onVerifyOtp,
  }) {
    // OTP controllers (created once per widget build)
    final List<TextEditingController> otpControllers = List.generate(
      4,
      (_) => TextEditingController(),
    );

    bool showOtp = false;
    bool isVerified = false;
    bool showOtpError = false;

    int resendSeconds = 30;
    Timer? resendTimer;

    // NOTE: takes StateSetter, not VoidCallback
    void startResendTimer(StateSetter localSetState) {
      resendTimer?.cancel();
      resendSeconds = 30;

      resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (resendSeconds == 0) {
          timer.cancel();
        } else {
          localSetState(() {
            resendSeconds--;
          });
        }
      });
    }

    return StatefulBuilder(
      builder: (context, setState) {
        final textValue = controller?.text ?? '';
        final isTenDigits = textValue.length == 10;
        final hasMobile = textValue.isNotEmpty;
        final last4Digits =
            hasMobile && textValue.length >= 4
                ? textValue.substring(textValue.length - 4)
                : '';

        return FormField<String>(
          key: fieldKey,
          validator: validator,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          builder: (state) {
            final hasError = state.hasError;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mobile Number',
                  style: AppTextStyles.mulish(color: AppColor.mildBlack),
                ),
                const SizedBox(height: 10),

                // MAIN CONTAINER
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Color(0xFFF5F5F5),
                    border: Border.all(
                      color: hasError ? Colors.red : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ───────── MOBILE FIELD + VERIFY / VERIFIED ─────────
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: controller,
                                focusNode: focusNode,
                                readOnly: readOnly,
                                maxLength: 10,
                                keyboardType:
                                    keyboardType ?? TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(10),
                                ],
                                decoration: InputDecoration(
                                  counterText: '',
                                  hintText: ' ',
                                  border: InputBorder.none,
                                ),
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                  letterSpacing: 0.5,
                                ),
                                onChanged: (v) {
                                  state.didChange(v);
                                  onChanged?.call(v);

                                  setState(() {
                                    showOtpError = false;
                                    if (!isVerified) {
                                      showOtp = false;
                                    }
                                  });
                                },
                              ),
                            ),

                            if (hasMobile && !isVerified)
                              GestureDetector(
                                onTap: () {
                                  controller?.clear();
                                  state.didChange('');
                                  setState(() {
                                    showOtp = false;
                                    showOtpError = false;
                                    resendTimer?.cancel();
                                  });
                                },
                                child: Icon(
                                  Icons.close,
                                  color: Colors.grey,
                                  size: 20,
                                ),
                              ),

                            SizedBox(width: 8),

                            // if (verticalDivider)
                            Container(
                              width: 2,
                              height: 30,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.grey.shade200,
                                    Colors.grey.shade300,
                                    Colors.grey.shade200,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(1),
                              ),
                            ),
                            SizedBox(width: 8),
                            if (!hasMobile)
                              Text(
                                'Mobile No',
                                style: AppTextStyles.mulish(
                                  color: AppColor.mediumGray,
                                ),
                              ),

                            // VERIFY BUTTON
                            if (isTenDigits && !isVerified && !showOtp)
                              // GestureDetector(
                              //   onTap:
                              //       (!isVerified && isTenDigits)
                              //           ? () async {
                              //             if (onSendOtp == null) return;
                              //
                              //             final success = await onSendOtp(
                              //               controller!.text,
                              //             );
                              //
                              //             if (!success) return;
                              //
                              //             setState(() {
                              //               showOtp = true;
                              //               showOtpError = false;
                              //               for (final c in otpControllers) {
                              //                 c.clear();
                              //               }
                              //               startResendTimer(setState);
                              //             });
                              //           }
                              //           : null,
                              //
                              //   child: Container(
                              //     padding: const EdgeInsets.symmetric(
                              //       horizontal: 14,
                              //       vertical: 8,
                              //     ),
                              //     decoration: BoxDecoration(
                              //       color: const Color(0xFF2196F3),
                              //       borderRadius: BorderRadius.circular(12),
                              //     ),
                              //     child: Text(
                              //       "Verify",
                              //       style: AppTextStyles.mulish(
                              //         color: Colors.white,
                              //         fontWeight: FontWeight.w700,
                              //       ),
                              //     ),
                              //   ),
                              // ),
                              GestureDetector(
                                onTap:
                                    isLoading
                                        ? null
                                        : () async {
                                          if (onSendOtp == null) return;

                                          final success = await onSendOtp(
                                            controller!.text,
                                          );
                                          if (!success) return;

                                          //  THIS WAS MISSING
                                          setState(() {
                                            showOtp = true;
                                            showOtpError = false;
                                            for (final c in otpControllers) {
                                              c.clear();
                                            }
                                            startResendTimer(setState);
                                          });
                                        },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        isLoading
                                            ? Colors.grey
                                            : const Color(0xFF2196F3),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child:
                                      isLoading
                                          ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                          : Text(
                                            "Verify",
                                            style: AppTextStyles.mulish(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                ),
                              ),

                            // VERIFIED LABEL
                            if (isVerified)
                              Container(
                                decoration: BoxDecoration(
                                  color: AppColor.green,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 15,
                                    vertical: 5,
                                  ),
                                  child: Row(
                                    children: [
                                      Image.asset(
                                        AppImages.tickImage,
                                        height: 11,
                                        color: AppColor.white,
                                      ),
                                      SizedBox(width: 6),
                                      Text(
                                        'Verified',
                                        style: AppTextStyles.mulish(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),

                        // ───────── OTP CARD (screenshot style) ─────────
                        if (showOtp && !isVerified && hasMobile) ...[
                          SizedBox(height: 16),
                          Container(
                            decoration: BoxDecoration(
                              color: Color(0xFFF2F2F2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () async {
                                        final otp =
                                            otpControllers
                                                .map((c) => c.text)
                                                .join();

                                        if (otp.length != 4) {
                                          setState(() => showOtpError = true);
                                          return;
                                        }

                                        if (onVerifyOtp == null) return;

                                        final success = await onVerifyOtp(
                                          controller!.text,
                                          otp,
                                        );

                                        if (!success) {
                                          setState(() => showOtpError = true);
                                          return;
                                        }

                                        setState(() {
                                          isVerified = true;
                                          showOtp = false;
                                          showOtpError = false;
                                          resendTimer?.cancel();
                                        });
                                      },

                                      child: Icon(
                                        Icons.arrow_back_ios_new,
                                        size: 14,
                                        color: AppColor.mediumGray,
                                      ),
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      "OTP Sent to your xxx$last4Digits",
                                      style: AppTextStyles.mulish(
                                        color: AppColor.black,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Text(
                                  "If you didn’t get otp by sms, resend otp using the button",
                                  style: AppTextStyles.mulish(
                                    color: AppColor.darkGrey,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  resendSeconds > 0
                                      ? "Resend in ${resendSeconds}s"
                                      : "Resend OTP",
                                  style: AppTextStyles.mulish(
                                    color: AppColor.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 16),

                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    ...List.generate(4, (index) {
                                      return SizedBox(
                                        width: 53,
                                        height: 52,
                                        child: TextField(
                                          controller: otpControllers[index],
                                          textAlign: TextAlign.center,
                                          keyboardType: TextInputType.number,
                                          maxLength: 1,
                                          style: AppTextStyles.mulish(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                          decoration: InputDecoration(
                                            filled: true,
                                            fillColor: Colors.white,
                                            counterText: '',
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              borderSide: BorderSide(
                                                color:
                                                    showOtpError
                                                        ? Colors.red
                                                        : Colors.white,
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              borderSide: BorderSide(
                                                color:
                                                    showOtpError
                                                        ? Colors.red
                                                        : Colors.white,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              borderSide: const BorderSide(
                                                color: Colors.black,
                                                width: 2.5,
                                              ),
                                            ),
                                          ),
                                          onChanged: (value) {
                                            if (value.isNotEmpty && index < 3) {
                                              FocusScope.of(
                                                context,
                                              ).nextFocus();
                                            } else if (value.isEmpty &&
                                                index > 0) {
                                              FocusScope.of(
                                                context,
                                              ).previousFocus();
                                            }
                                          },
                                        ),
                                      );
                                    }),
                                    GestureDetector(
                                      onTap:
                                          isOtpVerifying
                                              ? null
                                              : () async {
                                                final otp =
                                                    otpControllers
                                                        .map((c) => c.text)
                                                        .join();

                                                if (otp.length != 4) {
                                                  setState(
                                                    () => showOtpError = true,
                                                  );
                                                  return;
                                                }

                                                final success =
                                                    await onVerifyOtp!(
                                                      controller!.text,
                                                      otp,
                                                    );

                                                if (!success) {
                                                  setState(
                                                    () => showOtpError = true,
                                                  );
                                                  return;
                                                }

                                                setState(() {
                                                  isVerified = true;
                                                  showOtp = false;
                                                  showOtpError = false;
                                                  resendTimer?.cancel();
                                                });
                                              },
                                      child: Container(
                                        width: 53,
                                        height: 52,
                                        decoration: BoxDecoration(
                                          color:
                                              isOtpVerifying
                                                  ? Colors.grey
                                                  : Colors.black,
                                          borderRadius: BorderRadius.circular(
                                            15,
                                          ),
                                        ),
                                        child:
                                            isOtpVerifying
                                                ? const Padding(
                                                  padding: EdgeInsets.all(12),
                                                  child:
                                                      CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        color: Colors.white,
                                                      ),
                                                )
                                                : const Icon(
                                                  Icons.check,
                                                  color: Colors.white,
                                                ),
                                      ),
                                    ),

                                    //  button
                                    /*GestureDetector(
                                      onTap: () async {
                                        final otp =
                                            otpControllers
                                                .map((c) => c.text)
                                                .join();

                                        if (otp.length != 4) {
                                          setState(() => showOtpError = true);
                                          return;
                                        }

                                        if (onVerifyOtp == null) return;

                                        final success = await onVerifyOtp(
                                          controller!.text,
                                          otp,
                                        );

                                        if (!success) {
                                          setState(() => showOtpError = true);
                                          return;
                                        }

                                        setState(() {
                                          isVerified = true;
                                          showOtp = false;
                                          showOtpError = false;
                                          resendTimer?.cancel();
                                        });
                                        // final otp =
                                        //     otpControllers
                                        //         .map((c) => c.text)
                                        //         .join();
                                        //
                                        // if (otp.length == 4) {
                                        //   // TODO: call verify-OTP API here
                                        //   setState(() {
                                        //     isVerified = true;
                                        //     showOtp = false;
                                        //     showOtpError = false;
                                        //     resendTimer?.cancel();
                                        //   });
                                        //   ScaffoldMessenger.of(
                                        //     context,
                                        //   ).showSnackBar(
                                        //     const SnackBar(
                                        //       content: Text(
                                        //         'Mobile number verified successfully',
                                        //       ),
                                        //     ),
                                        //   );
                                        // } else {
                                        //   setState(() {
                                        //     showOtpError = true;
                                        //   });
                                        // }
                                      },
                                      child: Container(
                                        width: 53,
                                        height: 52,
                                        decoration: BoxDecoration(
                                          color: Colors.black,
                                          borderRadius: BorderRadius.circular(
                                            15,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 28,
                                        ),
                                      ),
                                    ),*/
                                  ],
                                ),

                                if (showOtpError)
                                  Padding(
                                    padding: EdgeInsets.only(top: 8, left: 4),
                                    child: Text(
                                      "⚠️ Please Enter Valid OTP",
                                      style: AppTextStyles.mulish(
                                        color: Colors.red,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                if (hasError)
                  Padding(
                    padding: const EdgeInsets.only(left: 12.0, top: 4),
                    child: Text(
                      state.errorText ?? '',
                      style: AppTextStyles.mulish(
                        color: Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  static topLeftArrow({required VoidCallback onTap, bool isMenu = false}) {
    return Row(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(50),
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isMenu ? null : AppColor.whiteSmoke,

              border: isMenu ? Border.all(color: AppColor.white4) : null,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            child: Image.asset(
              height: 14,
              width: 14,
              AppImages.leftArrow,
              fit: BoxFit.contain,
              color: isMenu ? AppColor.black : null,
            ),
          ),
        ),
      ],
    );
  }

  static Widget premiumCategory(
    String text, {
    String? appImage,
    bool isSelected = false,
    required VoidCallback onTap,
    Color? ContainerColor,
    Color? BorderColor,
    Color? TextColor,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(25),
      onTap: onTap, //  whole chip tappable
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: ContainerColor!,
          // isSelected ? AppColor.iceBlue : Colors.transparent,
          border: Border.all(
            color: BorderColor!,
            // isSelected ? AppColor.deepTeaBlue : AppColor.frostBlue,
            width: isSelected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          children: [
            Image.asset(appImage!, height: 23),
            SizedBox(width: 10),
            Text(
              text,
              style: AppTextStyles.mulish(
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                fontSize: 14,
                color: TextColor,
                // isSelected ? AppColor.darkBlue : AppColor.deepTeaBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static registerTopContainer({
    Color? gradientColor,
    required String image,
    required String text,
    double? imageHeight,
    double? imageWidth,
    double? value,
  }) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(AppImages.registerBCImage),
          fit: BoxFit.cover,
        ),
        gradient: LinearGradient(
          colors: [AppColor.white, gradientColor!],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(30),
          bottomLeft: Radius.circular(30),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Image.asset(image, height: imageHeight, width: imageWidth),
            SizedBox(height: 15),
            Text(
              text,
              style: AppTextStyles.mulish(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColor.mildBlack,
              ),
            ),
            SizedBox(height: 30),
            LinearProgressIndicator(
              minHeight: 12,
              value: value,
              valueColor: AlwaysStoppedAnimation<Color>(AppColor.green),
              backgroundColor: AppColor.white,
              borderRadius: BorderRadius.circular(16),
            ),
            SizedBox(height: 25),
          ],
        ),
      ),
    );
  }

  static Widget containerTitle({
    required String title,
    required String image,
    String? infoMessage,
    VoidCallback? onTap,
    BuildContext? context,
  }) {
    return Row(
      children: [
        Text(title, style: AppTextStyles.mulish(color: AppColor.mildBlack)),
        SizedBox(width: 7),
        InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () {
            if (onTap != null) {
              onTap();
            } else if (context != null && infoMessage != null) {
              showDialog(
                context: context,
                builder:
                    (_) => AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      backgroundColor: Colors.white,
                      contentPadding: const EdgeInsets.all(20),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Image.asset(image, height: 18, width: 18),
                              SizedBox(width: 8),
                              Text(
                                title,
                                style: AppTextStyles.mulish(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColor.mildBlack,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          Text(
                            infoMessage,
                            style: AppTextStyles.mulish(
                              color: AppColor.mediumLightGray,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: 18),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColor.skyBlue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                'Got it',
                                style: AppTextStyles.mulish(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
              );
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: AppColor.iceBlue,
              borderRadius: BorderRadius.circular(50),
            ),
            padding: const EdgeInsets.all(5),
            child: Image.asset(image, height: 10),
          ),
        ),
      ],
    );
  }

  static Widget gradientContainer({
    required String text,
    String? locationImage,
    String? iconImage,
    Color lIconColor = AppColor.darkBlue,
    Color dIconColor = AppColor.darkBlue,
    Color textColor = AppColor.darkBlue,
    FontWeight? fontWeight,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColor.lowLightBlue,
              AppColor.lowLightBlue.withOpacity(0.5),
              AppColor.white.withOpacity(0.3),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (locationImage != null)
              Image.asset(locationImage, height: 24, color: lIconColor),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                text,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: AppTextStyles.mulish(
                  color: textColor,
                  fontWeight: fontWeight,
                ),
              ),
            ),
            const SizedBox(width: 6),
            if (iconImage != null)
              Image.asset(iconImage, height: 11, color: dIconColor),
          ],
        ),
      ),
    );
  }

  static doorDelivery({
    Color? containerColor = AppColor.iceBlue,
    Color? imageColor,
    Color? textColor,
    String? text,
    FontWeight? fontWeight,
    double fontSize = 0.0,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Row(
          children: [
            Image.asset(AppImages.deliveryImage, height: 14, color: imageColor),
            SizedBox(width: 5),
            Text(
              text ?? '',
              style: AppTextStyles.mulish(
                fontSize: fontSize,
                fontWeight: fontWeight,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static callNowButton({
    VoidCallback? callOnTap,
    VoidCallback? orderOnTap,
    VoidCallback? mapOnTap,
    VoidCallback? messageOnTap,
    VoidCallback? whatsAppOnTap,
    VoidCallback? fireOnTap,
    bool messageContainer = false,
    bool mapBox = false,
    bool whatsAppIcon = false,
    bool MessageIcon = false,
    bool FireIcon = false,
    bool order = false,

    // Custom paddings
    EdgeInsetsGeometry? callNowPadding,
    EdgeInsetsGeometry? mapBoxPadding,
    EdgeInsetsGeometry? iconContainerPadding,

    // Custom sizes
    double? callIconSize,
    double? callTextSize,
    double? mapIconSize,
    double? mapTextSize,
    double? messagesIconSize,
    double? whatsAppIconSize,
    double? fireIconSize,

    Color? callImageColor,

    String? mapImage,
    String? mapText,
    String? callImage,
    String? callText,
    String? orderText,
    String? orderImage,
  }) {
    return Row(
      children: [
        if (order)
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: InkWell(
              onTap: orderOnTap,
              child: Container(
                padding:
                    callNowPadding ??
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColor.blueGradient1,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    Image.asset(orderImage!, height: callIconSize ?? 16),
                    const SizedBox(width: 7),
                    Text(
                      orderText!,
                      style: AppTextStyles.mulish(
                        fontWeight: FontWeight.bold,
                        fontSize: callTextSize ?? 16,
                        color: AppColor.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // ---- Call button (smart flexible) ----
        LayoutBuilder(
          builder: (context, constraints) {
            final bounded =
                constraints.hasBoundedWidth && constraints.maxWidth.isFinite;

            final callBtn = InkWell(
              onTap: callOnTap,
              child: Container(
                padding:
                    callNowPadding ??
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColor.skyBlue,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center, // nice centering
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      callImage!,
                      height: callIconSize ?? 16,
                      color: callImageColor,
                    ),
                    const SizedBox(width: 7),
                    Text(
                      callText!,
                      style: AppTextStyles.mulish(
                        fontWeight: FontWeight.bold,
                        fontSize: callTextSize ?? 14,
                        color: AppColor.white,
                      ),
                    ),
                  ],
                ),
              ),
            );

            // If width is bounded (typical page layout), behave like Expanded.
            // If unbounded (inside horizontal SingleChildScrollView), return intrinsic size.
            return bounded ? Expanded(child: callBtn) : callBtn;
          },
        ),

        if (mapBox)
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: mapOnTap,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColor.skyBlue, width: 1.5),
                ),
                child: Padding(
                  padding:
                      mapBoxPadding ??
                      const EdgeInsets.symmetric(horizontal: 17, vertical: 5),
                  child: Row(
                    children: [
                      Image.asset(
                        mapImage!,
                        height: mapIconSize ?? 21,
                        color: AppColor.skyBlue,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        mapText!,
                        style: AppTextStyles.mulish(
                          fontWeight: FontWeight.bold,
                          fontSize: mapTextSize ?? 16,
                          color: AppColor.skyBlue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

        // ⬇️ only add gap if the pill is going to show
        if (messageContainer && (MessageIcon || whatsAppIcon || FireIcon))
          const SizedBox(width: 9),

        if (messageContainer && (MessageIcon || whatsAppIcon || FireIcon))
          Container(
            padding:
                iconContainerPadding ??
                const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
            decoration: BoxDecoration(
              color: AppColor.white2,
              borderRadius: BorderRadius.circular(16),
            ),
            // ⬇️ auto-size & auto-center the icons based on how many are visible
            child: Wrap(
              spacing: 16, // even spacing for 2+ icons
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (MessageIcon)
                  GestureDetector(
                    onTap: messageOnTap,
                    child: Image.asset(
                      AppImages.messageImage,
                      height: messagesIconSize ?? 19,
                    ),
                  ),
                if (whatsAppIcon)
                  GestureDetector(
                    onTap: whatsAppOnTap,
                    child: Image.asset(
                      AppImages.whatsappImage,
                      height: whatsAppIconSize ?? 19,
                    ),
                  ),
                if (FireIcon)
                  GestureDetector(
                    onTap: fireOnTap,
                    child: Image.asset(
                      AppImages.fireImage,
                      height: fireIconSize ?? 19,
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  static reviewBox() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Container(
        decoration: BoxDecoration(
          color: AppColor.white,
          borderRadius: BorderRadius.circular(16),
          border: Border(
            bottom: BorderSide(color: AppColor.borderLightGrey, width: 8),
            left: BorderSide(color: AppColor.borderLightGrey, width: 2),
            right: BorderSide(color: AppColor.borderLightGrey, width: 2),
            top: BorderSide(color: AppColor.borderLightGrey, width: 2),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Great People',
                    style: AppTextStyles.mulish(
                      fontSize: 16,
                      color: AppColor.darkBlue,
                    ),
                  ),
                  SizedBox(width: 9),
                  Image.asset(AppImages.dratImage, height: 8, width: 6),
                  SizedBox(width: 9),
                  Image.asset(
                    AppImages.starImage,
                    height: 12,
                    color: AppColor.green,
                  ),
                  SizedBox(width: 4),
                  Image.asset(
                    AppImages.starImage,
                    height: 12,
                    color: AppColor.green,
                  ),
                  SizedBox(width: 4),
                  Image.asset(
                    AppImages.starImage,
                    height: 12,
                    color: AppColor.green,
                  ),
                  SizedBox(width: 4),
                  Image.asset(
                    AppImages.starImage,
                    height: 12,
                    color: AppColor.green,
                  ),
                  SizedBox(width: 4),
                  Image.asset(
                    AppImages.starImage,
                    height: 12,
                    color: AppColor.borderGray,
                  ),
                  SizedBox(width: 8),
                  Text(
                    '4',
                    style: AppTextStyles.mulish(
                      fontWeight: FontWeight.bold,
                      color: AppColor.green,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15),
              Text(
                'Praesent viverra volutpat lorem, eu convallis lacus maximus quis. Nam at lorem mi. In tempor commodo bibendum. Donec euismod urna pharetra justo finibus, eget volutpat justo dapibus. ',
                style: AppTextStyles.mulish(color: AppColor.gray84),
              ),
              SizedBox(height: 15),
              CommonContainer.horizonalDivider(),
              SizedBox(height: 15),
              Text(
                '1 Month Ago',
                style: AppTextStyles.mulish(color: AppColor.darkGrey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static horizonalDivider({bool isSubscription = false}) {
    return Container(
      width: double.infinity,
      height: 2,
      decoration: BoxDecoration(
        gradient:
            isSubscription
                ? LinearGradient(
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                  colors: [
                    Color(0xFFFFFFFF),
                    Color(0xFFE1E1E1),
                    Color(0xFFE1E1E1),
                    Color(0xFFE1E1E1),
                    Color(0xFFE1E1E1),
                    Color(0xFFFFFFFF),
                  ],
                )
                : LinearGradient(
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                  colors: [
                    AppColor.white.withOpacity(0.5),
                    AppColor.white3,
                    AppColor.white3,
                    AppColor.white3,
                    AppColor.white3,
                    AppColor.white3,
                    AppColor.white3,
                    AppColor.white.withOpacity(0.5),
                  ],
                ),

        borderRadius: BorderRadius.circular(1),
      ),
    );
  }

  static Widget sortbyPopup({
    required String text1,
    String? text2, // optional
    String connector = ' to ', // e.g. use ' in ' for suggestions
    String? image, // optional trailing image
    VoidCallback? onTap, // optional
    bool horizontalDivider = false,
    Color? iconColor,
  }) {
    final hasSecond = (text2 != null && text2!.trim().isNotEmpty);
    final hasTrailing = (image != null || onTap != null);

    Widget? trailing;
    if (hasTrailing) {
      trailing = ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
        child: InkWell(
          onTap: onTap, // null = no ripple
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              color: AppColor.textWhite,
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 10),
            child:
                image != null
                    ? Image.asset(
                      image,
                      height: 3,
                      width: 12,
                      color: iconColor ?? AppColor.blue,
                    )
                    : Image.asset(AppImages.rightArrow, height: 12),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: text1,
                        style: AppTextStyles.mulish(
                          fontSize: 16,
                          color: AppColor.darkBlue,
                        ),
                      ),
                      if (hasSecond)
                        TextSpan(
                          text: connector,
                          style: AppTextStyles.mulish(
                            fontSize: 16,
                            color: AppColor.lightGray2,
                          ),
                        ),
                      if (hasSecond)
                        TextSpan(
                          text: text2,
                          style: AppTextStyles.mulish(
                            fontSize: 16,
                            color: AppColor.darkBlue,
                          ),
                        ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (trailing != null) const SizedBox(width: 12),
              if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: 19),
          if (horizontalDivider)
            Container(
              width: double.infinity,
              height: 2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                  colors: [
                    AppColor.white.withOpacity(0.5),
                    AppColor.white3,
                    AppColor.white3,
                    AppColor.white3,
                    AppColor.white3,
                    AppColor.white3,
                    AppColor.white3,
                    AppColor.white.withOpacity(0.5),
                  ],
                ),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
        ],
      ),
    );
  }

  static Widget profileList({
    required String label,
    required String iconPath,
    double iconHeight = 25,
    double iconWidth = 19,
    double circleSize = 50,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: circleSize,
                height: circleSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColor.brightGray,
                ),
                child: Center(
                  child: Image.asset(
                    iconPath,
                    height: iconHeight,
                    width: iconWidth,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: AppTextStyles.mulish(
                  fontSize: 16,
                  color: AppColor.darkBlue,
                ),
              ),
            ],
          ),
          Image.asset(
            AppImages.rightArrow,
            height: 14,
            color: AppColor.lightGray2,
          ),
        ],
      ),
    );
  }

  static Widget paidCustomerCard({
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.cover,
            image: AssetImage(AppImages.containerBCImage2),
          ),
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [AppColor.brightBlue, AppColor.electricSkyBlue],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 20),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      title,
                      style: AppTextStyles.mulish(
                        fontSize: 25,
                        fontWeight: FontWeight.w900,
                        color: AppColor.scaffoldColor,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      description,
                      style: AppTextStyles.mulish(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColor.scaffoldColor,
                      ),
                    ),

                    // InkWell(
                    //   onTap: onTap,
                    //   child: Container(
                    //     decoration: BoxDecoration(
                    //       color: AppColor.scaffoldColor,
                    //       borderRadius: BorderRadius.circular(50),
                    //     ),
                    //     child: Padding(
                    //       padding: const EdgeInsets.symmetric(
                    //         horizontal: 14.5,
                    //         vertical: 6.5,
                    //       ),
                    //       child: Image.asset(
                    //         AppImages.rightStickArrow,
                    //         height: 20,
                    //         color: AppColor.royalBlue,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
              // SizedBox(width: 30),
              // Image.asset(AppImages.upgrade, height: 138),
            ],
          ),
        ),
      ),
    );
  }

  static Widget attractCustomerCard({
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppImages.containerBCImage2),
          ),
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [AppColor.brightBlue, AppColor.electricBlue],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      title,
                      style: AppTextStyles.mulish(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: AppColor.white,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      description,
                      style: AppTextStyles.mulish(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColor.white,
                      ),
                    ),
                    SizedBox(height: 20),
                    InkWell(
                      onTap: onTap,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColor.white,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14.5,
                            vertical: 6.5,
                          ),
                          child: Image.asset(
                            AppImages.rightStickArrow,
                            height: 20,
                            color: AppColor.royalBlue,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 30),
              Image.asset(AppImages.upgrade, height: 138),
            ],
          ),
        ),
      ),
    );
  }

  static Widget foodList({
    required String image,
    required String foodName,
    required String ratingStar,
    required String ratingCount,
    required String offAmound,
    required String oldAmound,
    required String km,
    required String location,
    double imageHeight = 160,
    double imageWidth = 155,
    double fontSize = 16,
    FontWeight titleWeight = FontWeight.w800,
    bool Verify = false,
    bool locations = false,
    bool doorDelivery = false,
    bool dummyImage = false,
    bool weight = false,
    bool Ad = false,
    VoidCallback? onTap,
    bool horizontalDivider = false,

    List<String> weightOptions = const ['300Gm', '500Gm'],
    int? selectedWeightIndex, // null = none selected
    ValueChanged<int>? onWeightChanged, // callback when tapped
  }) {
    // Apply filtering logic:
    final List<String> filteredWeightOptions = [
      if (weightOptions.contains('1Kg')) '1Kg',
      ...weightOptions.where((w) => w.toLowerCase().endsWith('gm')).take(2),
    ];

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Row(
              children: [
                Stack(
                  children: [
               dummyImage == true?     ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Container(child: Image.asset(image, height: 135)),
                    ):
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: CachedNetworkImage(
                        imageUrl: image, // 👈 your URL string here
                        width: 130,
                        height: 130,
                        fit: BoxFit.cover, // same effect as FittedBox.cover
                        placeholder:
                            (context, url) => Container(
                              width: 130,
                              height: 130,
                              color: Colors.grey[300],
                              child: const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                        errorWidget:
                            (context, url, error) => Container(
                              width: 130,
                              height: 130,
                              color: Colors.grey[300],
                              child: const Icon(
                                Icons.broken_image,
                                color: Colors.grey,
                              ),
                            ),
                      ),
                    ),

                    // if (Ad)
                    //   Positioned(
                    //     bottom: 10,
                    //     right: 8,
                    //     child: Container(
                    //       decoration: BoxDecoration(
                    //         color: AppColor.black.withOpacity(0.5),
                    //         borderRadius: BorderRadius.circular(50),
                    //       ),
                    //       child: Padding(
                    //         padding: const EdgeInsets.symmetric(
                    //           horizontal: 10,
                    //           vertical: 4,
                    //         ),
                    //         child: Row(
                    //           children: [
                    //             Image.asset(AppImages.alertImage, height: 9),
                    //             SizedBox(width: 4),
                    //             Text(
                    //               'AD',
                    //               style: AppTextStyles.mulish(
                    //                 fontSize: 10,
                    //                 fontWeight: FontWeight.w900,
                    //                 color: AppColor.scaffoldColor,
                    //               ),
                    //             ),
                    //           ],
                    //         ),
                    //       ),
                    //     ),
                    //   ),
                  ],
                ),
                SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // if (Verify) CommonContainer.verifyTick(),
                          // SizedBox(width: 5),
                          doorDelivery
                              ? CommonContainer.doorDelivery(
                                text: 'Door Delivery',
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                textColor: AppColor.skyBlue,
                              )
                              : SizedBox.shrink(),
                        ],
                      ),
                      SizedBox(height: 12),
                      Text(
                        foodName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.mulish(
                          fontWeight: titleWeight,
                          fontSize: fontSize,
                          color: AppColor.darkBlue,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          CommonContainer.greenStarRating(
                            ratingStar: ratingStar,
                            ratingCount: ratingCount,
                          ),
                        ],
                      ),
                      SizedBox(height: 7),
                      Row(
                        children: [
                          Text(
                            offAmound,
                            style: AppTextStyles.mulish(
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                              color: AppColor.darkBlue,
                            ),
                          ),
                          SizedBox(width: 10),
                          oldAmound.isEmpty
                              ? SizedBox.shrink()
                              : Stack(
                                alignment: Alignment.center,
                                children: [
                                  Text(
                                    oldAmound,
                                    style: AppTextStyles.mulish(
                                      fontSize: 14,
                                      color: AppColor.gray84,
                                    ),
                                  ),
                                  Transform.rotate(
                                    angle: -0.1,
                                    child: Container(
                                      height: 1.5,
                                      width: 40,
                                      color: AppColor.gray84,
                                    ),
                                  ),
                                ],
                              ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      if (locations)
                        Container(
                          decoration: BoxDecoration(
                            color: AppColor.white,
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(
                              color: AppColor.iceBlue,
                              width: 1.5,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            child: Row(
                              children: [
                                Image.asset(
                                  AppImages.locationImage,
                                  height: 13,
                                  color: AppColor.skyBlue,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  km,
                                  style: AppTextStyles.mulish(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                    color: AppColor.skyBlue,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Flexible(
                                  child: Text(
                                    location,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.mulish(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 10,
                                      color: AppColor.darkBlue,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      // if (weight)
                      //   Row(
                      //     crossAxisAlignment: CrossAxisAlignment.center,
                      //     children: [
                      //       Text(
                      //         'Weight',
                      //         style: GoogleFont.Mulish(
                      //           fontSize: 12,
                      //           color: AppColor.darkBlue,
                      //         ),
                      //       ),
                      //       const SizedBox(width: 10),
                      //       Expanded(
                      //         child: Wrap(
                      //           spacing: 10,
                      //           runSpacing: 8,
                      //           children: List.generate(
                      //             filteredWeightOptions.length,
                      //                 (i) {
                      //               final bool isSelected =
                      //                   selectedWeightIndex == i;
                      //               return InkWell(
                      //                 borderRadius: BorderRadius.circular(50),
                      //                 onTap: () => onWeightChanged?.call(i),
                      //                 child: Container(
                      //                   decoration: BoxDecoration(
                      //                     color: isSelected
                      //                         ? AppColor.white
                      //                         : Colors.transparent,
                      //                     borderRadius: BorderRadius.circular(
                      //                       50,
                      //                     ),
                      //                     border: Border.all(
                      //                       color: isSelected
                      //                           ? AppColor.blue
                      //                           : AppColor.lightGray2,
                      //                       width: 1.5,
                      //                     ),
                      //                     boxShadow: isSelected
                      //                         ? [
                      //                       BoxShadow(
                      //                         color: AppColor.blue
                      //                             .withOpacity(0.14),
                      //                         blurRadius: 10,
                      //                         offset: const Offset(0, 2),
                      //                       ),
                      //                     ]
                      //                         : null,
                      //                   ),
                      //                   padding: const EdgeInsets.symmetric(
                      //                     horizontal: 12,
                      //                     vertical: 6,
                      //                   ),
                      //                   child: Text(
                      //                     filteredWeightOptions[i],
                      //                     style: GoogleFont.Mulish(
                      //                       fontSize: 12,
                      //                       fontWeight: FontWeight.w800,
                      //                       color: isSelected
                      //                           ? AppColor.blue
                      //                           : AppColor.lightGray2,
                      //                     ),
                      //                   ),
                      //                 ),
                      //               );
                      //             },
                      //           ),
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          if (horizontalDivider) CommonContainer.horizonalDivider(),
        ],
      ),
    );
  }

  static greenStarRating({String? ratingStar, String? ratingCount}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColor.green,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min, // 👈 stops expanding too much
            children: [
              Text(
                ratingStar!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.mulish(
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                  color: AppColor.white,
                ),
              ),
              const SizedBox(width: 5),
              Image.asset(AppImages.starImage, height: 9),
              const SizedBox(width: 5),
              Container(
                width: 1.5,
                height: 13,
                decoration: BoxDecoration(
                  color: AppColor.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
              const SizedBox(width: 5),
              Text(
                ratingCount!,
                style: AppTextStyles.mulish(
                  fontSize: 12,
                  color: AppColor.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
