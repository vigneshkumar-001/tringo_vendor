import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tringo_vendor_new/Core/Utility/app_textstyles.dart';

import '../Const/app_color.dart';
import '../Const/app_images.dart';

enum DatePickMode { none, single, range }

class CommonContainer {
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
            border: isBorder
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
            child: loader != null
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
                  color: isSelected ? AppColor.lightSkyBlue : Colors.black,
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
          // Single Date Picker
          if (datePickMode == DatePickMode.single) {
            if (context == null) return;
            final picked = await showDatePicker(
              context: context!,
              initialDate: DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime(2100),
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
                          textStyle: AppTextStyles.mulish(),
                          foregroundColor: AppColor.blue,
                        ),
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
            isMobile || isAadhaar || isPincode
                ? <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(
                    isMobile ? 10 : (isAadhaar ? 12 : 6),
                  ),
                ]
                : (inputFormatters ?? const []);

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
                                                        text ?? '',
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
                                                ? 12
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
}
