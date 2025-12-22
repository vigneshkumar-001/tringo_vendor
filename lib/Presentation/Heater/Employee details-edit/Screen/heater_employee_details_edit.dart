import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../Core/Const/app_color.dart';
import '../../../../Core/Const/app_images.dart';
import '../../../../Core/Utility/app_loader.dart';
import '../../../../Core/Utility/app_snackbar.dart';
import '../../../../Core/Utility/app_textstyles.dart';
import '../../../../Core/Widgets/app_go_routes.dart';
import '../../../../Core/Widgets/common_container.dart';
import '../../../../Core/Widgets/owner_verify_feild.dart';
import '../../Add Vendor Employee/Controller/add_employee_notifier.dart';
import '../Controller/heater_employee_edit_notifier.dart';

String _normalizeIndianPhone(String input) {
  var p = input.trim();
  p = p.replaceAll(RegExp(r'[^0-9]'), '');
  if (p.startsWith('91') && p.length == 12) {
    p = p.substring(2);
  }
  return p;
}

class HeaterEmployeeDetailsEdit extends ConsumerStatefulWidget {
  final String employeeId;
  final String? name;
  final String? employeeCode;
  final String? phoneNumber;
  final String? avatarUrl;
  final String? totalAmount;
  final bool? isActive;
  final String? email;
  final String? emergencyContactName;
  final String? emergencyContactRelationship;
  final String? emergencyContactPhone;
  final String? aadharNumber;
  final String? aadharDocumentUrl;

  const HeaterEmployeeDetailsEdit({
    super.key,
    required this.employeeId,
    this.name,
    this.employeeCode,
    this.phoneNumber,
    this.avatarUrl,
    this.totalAmount,
    this.isActive,
    this.email,
    this.emergencyContactName,
    this.emergencyContactRelationship,
    this.emergencyContactPhone,
    this.aadharNumber,
    this.aadharDocumentUrl,
  });

  @override
  ConsumerState<HeaterEmployeeDetailsEdit> createState() =>
      _HeaterEmployeeDetailsEditState();
}

class _HeaterEmployeeDetailsEditState
    extends ConsumerState<HeaterEmployeeDetailsEdit> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitted = false;
  bool _initialized = false;
  bool _isActiveLocal = true;
  bool _isBlockActionLoading = false;

  final TextEditingController englishNameController = TextEditingController();
  final TextEditingController employeeNameController = TextEditingController();
  final TextEditingController employeeNumberController =
      TextEditingController();
  final TextEditingController emergencyNameController = TextEditingController();
  final TextEditingController emergencyRelationShipController =
      TextEditingController();
  final TextEditingController emailIdController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController aadharController = TextEditingController();
  final TextEditingController emergencyMobileController =
      TextEditingController();

  final ImagePicker _picker = ImagePicker();

  List<File?> _pickedImages = List<File?>.filled(2, null, growable: false);
  List<bool> _hasError = List<bool>.filled(2, false, growable: false);
  List<String?> _existingUrls = List<String?>.filled(2, null, growable: false);

  @override
  void initState() {
    super.initState();

    englishNameController.text = widget.name ?? '';

    mobileController.text = _normalizeIndianPhone(widget.phoneNumber ?? '');

    // mobileController.text = widget.phoneNumber ?? '';

    emailIdController.text = widget.email ?? '';

    emergencyNameController.text = widget.emergencyContactName ?? '';
    emergencyRelationShipController.text =
        widget.emergencyContactRelationship ?? '';
    emergencyMobileController.text = widget.emergencyContactPhone ?? '';

    aadharController.text = widget.aadharNumber ?? '';

    _existingUrls[0] = widget.aadharDocumentUrl;
    _existingUrls[1] = widget.avatarUrl;

    _isActiveLocal = widget.isActive ?? true;
  }

  @override
  void dispose() {
    englishNameController.dispose();
    emergencyNameController.dispose();
    emergencyRelationShipController.dispose();
    mobileController.dispose();
    emailIdController.dispose();
    emergencyMobileController.dispose();
    aadharController.dispose();
    super.dispose();
  }

  Future<void> _launchDialer(String phoneNumber) async {
    final Uri uri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      debugPrint('Could not launch dialer for $phoneNumber');
    }
  }

  void _showImageSourcePicker(int index) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromSource(index, ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromSource(index, ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImageFromSource(int index, ImageSource source) async {
    final pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 85,
    );

    if (pickedFile == null) return;

    setState(() {
      _pickedImages[index] = File(pickedFile.path);
      _hasError[index] = false;
    });
  }

  Widget _imageBox({required int index}) {
    final file = _pickedImages[index];
    final hasError = _hasError[index];
    final existingUrl = _existingUrls[index];

    final hasFile = file != null;
    final hasExisting = (existingUrl != null && existingUrl.trim().isNotEmpty);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            GestureDetector(
              onTap: () => _showImageSourcePicker(index),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColor.lowGery1,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color:
                        hasError
                            ? Colors.red
                            : (hasFile || hasExisting)
                            ? AppColor.lightSkyBlue
                            : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child:
                    (!hasFile && !hasExisting)
                        ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 22.5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(AppImages.addImage, height: 20),
                              SizedBox(width: 10),
                              Text(
                                'Upload Image',
                                style: AppTextStyles.mulish(
                                  color: AppColor.darkGrey,
                                ),
                              ),
                            ],
                          ),
                        )
                        : ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child:
                              hasFile
                                  ? Image.file(
                                    file!,
                                    fit: BoxFit.cover,
                                    height: 150,
                                    width: double.infinity,
                                  )
                                  : Image.network(
                                    existingUrl!,
                                    fit: BoxFit.cover,
                                    height: 150,
                                    width: double.infinity,
                                    errorBuilder:
                                        (_, __, ___) => SizedBox(
                                          height: 150,
                                          child: Center(
                                            child: Icon(
                                              Icons.image_not_supported,
                                            ),
                                          ),
                                        ),
                                  ),
                        ),
              ),
            ),

            if (hasFile || hasExisting)
              Positioned(
                top: 15,
                right: 16,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _pickedImages[index] = null;
                      _existingUrls[index] = null; //  clear existing url also
                      _hasError[index] = false;
                    });
                  },
                  child: Column(
                    children: [
                      Image.asset(
                        AppImages.closeImage,
                        height: 28,
                        color: AppColor.white,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Clear',
                        style: AppTextStyles.mulish(
                          color: AppColor.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),

        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 5),
            child: Text(
              'Please add this image',
              style: AppTextStyles.mulish(
                color: Colors.red,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
      ],
    );
  }

  // Widget _imageBox({required int index}) {
  //   final file = _pickedImages[index];
  //   final hasError = _hasError[index];
  //   final hasImage = file != null;
  //
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Stack(
  //         children: [
  //           GestureDetector(
  //             // onTap: () => _pickImage(index),
  //             onTap: () => _showImageSourcePicker(index),
  //             child: Container(
  //               width: double.infinity,
  //               decoration: BoxDecoration(
  //                 color: AppColor.lowGery1,
  //                 borderRadius: BorderRadius.circular(16),
  //                 border: Border.all(
  //                   color:
  //                       hasError
  //                           ? Colors.red
  //                           : hasImage
  //                           ? AppColor.lightSkyBlue
  //                           : Colors.transparent,
  //                   width: 1.5,
  //                 ),
  //               ),
  //               child:
  //                   !hasImage
  //                       ? Padding(
  //                         padding: const EdgeInsets.symmetric(vertical: 22.5),
  //                         child: Row(
  //                           mainAxisAlignment: MainAxisAlignment.center,
  //                           children: [
  //                             Image.asset(AppImages.addImage, height: 20),
  //                             SizedBox(width: 10),
  //                             Text(
  //                               'Upload Image',
  //                               style: AppTextStyles.mulish(
  //                                 color: AppColor.darkGrey,
  //                               ),
  //                             ),
  //                           ],
  //                         ),
  //                       )
  //                       : ClipRRect(
  //                         borderRadius: BorderRadius.circular(16),
  //                         child: Image.file(
  //                           file!,
  //                           fit: BoxFit.cover,
  //                           height: 150,
  //                           width: double.infinity,
  //                         ),
  //                       ),
  //             ),
  //           ),
  //           if (hasImage)
  //             Positioned(
  //               top: 15,
  //               right: 16,
  //               child: InkWell(
  //                 onTap: () {
  //                   setState(() {
  //                     _pickedImages[index] = null;
  //                     _existingUrls[index] = null;
  //                     _hasError[index] = false;
  //                   });
  //                 },
  //                 child: Column(
  //                   children: [
  //                     Image.asset(
  //                       AppImages.closeImage,
  //                       height: 28,
  //                       color: AppColor.white,
  //                     ),
  //                     SizedBox(height: 2),
  //                     Text(
  //                       'Clear',
  //                       style: AppTextStyles.mulish(
  //                         color: AppColor.white,
  //                         fontWeight: FontWeight.w500,
  //                         fontSize: 12,
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ),
  //         ],
  //       ),
  //       if (hasError)
  //         Padding(
  //           padding: const EdgeInsets.only(top: 6, left: 5),
  //           child: Text(
  //             'Please add this image',
  //             style: AppTextStyles.mulish(
  //               color: Colors.red,
  //               fontWeight: FontWeight.w600,
  //               fontSize: 13,
  //             ),
  //           ),
  //         ),
  //     ],
  //   );
  // }

  bool get _isBlocked => !_isActiveLocal;

  Future<bool> _confirmDialog({
    required String title,
    required String message,
    required String yesText,
  }) async {
    final res = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  yesText,
                  style: AppTextStyles.mulish(
                    color: AppColor.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
    );
    return res ?? false;
  }

  Future<void> _onBlockUnblockTap() async {
    // if (_isBlockActionLoading) return;
    if (ref.read(heaterEmployeeEditNotifier).isBlockLoading) return;
    final isBlocked = _isBlocked;

    final ok = await _confirmDialog(
      title: isBlocked ? "Unblock employee?" : "Block employee?",
      message:
          isBlocked
              ? "This employee will regain normal access. Do you want to continue?"
              : "Blocked employees cannot be edited or used. Do you want to continue?",
      yesText: isBlocked ? "Unblock" : "Block",
    );

    if (!ok) return;

    if (isBlocked) {
      await ref
          .read(heaterEmployeeEditNotifier.notifier)
          .unblockEmployee(employeeId: widget.employeeId);
    } else {
      await ref
          .read(heaterEmployeeEditNotifier.notifier)
          .blockEmployee(employeeId: widget.employeeId);
    }

    final s = ref.read(heaterEmployeeEditNotifier);

    if (s.error != null) {
      AppSnackBar.error(context, s.error!);
      return;
    }

    //  Update local UI
    setState(() {
      _isActiveLocal = isBlocked ? true : false;
    });

    AppSnackBar.success(
      context,
      isBlocked ? "Employee unblocked" : "Employee blocked",
    );

    // OPTIONAL: list refresh notifier call here
    // ref.read(employeeListNotifier.notifier).fetchEmployees();
  }

  /*  Widget employeeHeaderCard({
    required String name,
    required String employeeCode,
    required String phoneNumber,
    required String? avatarUrl,
    required String totalAmount,
    required VoidCallback onCallTap,
    required VoidCallback onSecondActionTap,
    required Widget secondActionChild, // edit icon / block icon / loader
  }) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(image: AssetImage(AppImages.registerBCImage)),
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
                    (avatarUrl != null && avatarUrl.isNotEmpty)
                        ? Image.network(
                          avatarUrl,
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
                  name,
                  style: AppTextStyles.mulish(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: AppColor.darkBlue,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  employeeCode,
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
                  'Rs. $totalAmount',
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
                  onTap: onCallTap,
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
                      child: Image.asset(AppImages.callImage1, height: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                InkWell(
                  onTap: onSecondActionTap,
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
                      child: secondActionChild,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }*/

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(heaterEmployeeEditNotifier);
    final a = widget; // or just use widget.name, widget.avatarUrl, etc.

    if (state.isLoading) {
      return const Scaffold(
        body: Center(child: ThreeDotsLoader(dotColor: AppColor.darkBlue)),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await ref
                .read(heaterEmployeeEditNotifier.notifier)
                .editEmployee(employeeId: widget.employeeId);
          },
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
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
                SizedBox(height: 20),

                // employeeHeaderCard(
                //   name: a.name ?? '',
                //   employeeCode: a.employeeCode ?? '',
                //   phoneNumber: a.phoneNumber ?? '',
                //   avatarUrl: a.avatarUrl,
                //   totalAmount: a.totalAmount ?? '0',
                //   onCallTap: () {
                //     if ((a.phoneNumber ?? '').isNotEmpty)
                //       _launchDialer(a.phoneNumber!);
                //   },
                //   onSecondActionTap:
                //       state.isBlockLoading ? () {} : _onBlockUnblockTap,
                //   secondActionChild:
                //       state.isBlockLoading
                //           ? const SizedBox(
                //             height: 16,
                //             child: Center(
                //               child: ThreeDotsLoader(dotColor: AppColor.darkBlue),
                //             ),
                //           )
                //           : Image.asset(
                //             AppImages.personOff,
                //             color: _isBlocked ? Colors.red : AppColor.darkBlue,
                //             height: 16,
                //           ),
                // ),
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
                                (a.avatarUrl != null && a.avatarUrl!.isNotEmpty)
                                    ? Image.network(
                                      a.avatarUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (_, __, ___) => const Icon(
                                            Icons.person,
                                            size: 40,
                                          ),
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
                              a.name ?? '',
                              style: AppTextStyles.mulish(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                color: AppColor.darkBlue,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              a.employeeCode ?? '',
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
                              'Rs. ${a.totalAmount}',
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
                                if (a.phoneNumber != null &&
                                    a.phoneNumber!.isNotEmpty) {
                                  _launchDialer(a.phoneNumber!);
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
                              onTap:
                                  state.isBlockLoading
                                      ? null
                                      : _onBlockUnblockTap, //  HERE
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color:
                                        _isBlocked
                                            ? Colors.red
                                            : AppColor.black.withOpacity(0.1),
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12.5,
                                    vertical: 15.5,
                                  ),
                                  child:
                                      // _isBlockActionLoading
                                      state.isBlockLoading
                                          ? SizedBox(
                                            height: 16,
                                            child: Center(
                                              child: ThreeDotsLoader(
                                                dotColor:
                                                    _isBlocked
                                                        ? Colors.red
                                                        : AppColor.darkBlue,
                                              ), //  WHAT YOU ASKED FOR
                                            ),
                                          )
                                          : Image.asset(
                                            AppImages.personOff,
                                            color:
                                                _isBlocked
                                                    ? Colors.red
                                                    : AppColor.darkBlue,
                                            height: 16,
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
                    'Edit Employee Details',
                    style: AppTextStyles.mulish(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColor.darkBlue,
                    ),
                  ),
                ),
                SizedBox(height: 15),
                // IgnorePointer(
                //   ignoring: _isBlocked, //  blocked => no access
                //   child: Opacity(
                //     opacity: _isBlocked ? 0.45 : 1.0, //  low color
                //     child:
                //   ),
                // ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 21,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Name',
                            style: AppTextStyles.mulish(
                              color: AppColor.mildBlack,
                            ),
                          ),
                          SizedBox(height: 10),
                          CommonContainer.fillingContainer(
                            controller: englishNameController,
                            context: context,
                          ),
                          SizedBox(height: 30),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 400),
                            transitionBuilder:
                                (child, animation) => FadeTransition(
                                  opacity: animation,
                                  child: child,
                                ),
                            child: OwnerVerifyField(
                              key: const ValueKey("owner_verify_field"),
                              controller: mobileController,
                              isLoading: state.isSendingOtp,
                              isOtpVerifying: state.isVerifyingOtp,
                              onSendOtp: (mobile) {
                                return ref
                                    .read(heaterEmployeeEditNotifier.notifier)
                                    .employeeUpdateNumberRequest(
                                      phoneNumber: mobile,
                                    );
                              },
                              onVerifyOtp: (mobile, otp) {
                                return ref
                                    .read(heaterEmployeeEditNotifier.notifier)
                                    .employeeUpdateOtpRequest(
                                      phoneNumber: mobile,
                                      code: otp,
                                    );
                              },
                            ),
                          ),

                          SizedBox(height: 30),

                          Text(
                            'Email Id',
                            style: AppTextStyles.mulish(
                              color: AppColor.mildBlack,
                            ),
                          ),
                          SizedBox(height: 10),
                          CommonContainer.fillingContainer(
                            controller: emailIdController,
                            keyboardType: TextInputType.emailAddress,
                            context: context,
                          ),

                          SizedBox(height: 30),

                          Text(
                            'Emergency Contact Details',
                            style: AppTextStyles.mulish(
                              color: AppColor.mildBlack,
                            ),
                          ),
                          SizedBox(height: 10),

                          CommonContainer.fillingContainer(
                            text: 'Name',
                            verticalDivider: true,
                            controller: emergencyNameController,
                            context: context,
                          ),
                          SizedBox(height: 10),

                          CommonContainer.fillingContainer(
                            text: 'Relationship',
                            verticalDivider: true,
                            controller: emergencyRelationShipController,
                            context: context,
                          ),
                          SizedBox(height: 10),

                          CommonContainer.fillingContainer(
                            text: 'Mobile Number',
                            isMobile: true,
                            controller: emergencyMobileController,
                            context: context,
                          ),

                          SizedBox(height: 30),

                          Text(
                            'Aadhar No',
                            style: AppTextStyles.mulish(
                              color: AppColor.mildBlack,
                            ),
                          ),
                          SizedBox(height: 10),

                          CommonContainer.fillingContainer(
                            verticalDivider: false,
                            controller: aadharController,
                            context: context,
                            keyboardType: TextInputType.number,
                            isAadhaar: true,
                          ),

                          SizedBox(height: 30),
                          CommonContainer.containerTitle(
                            context: context,
                            title: 'Aadhar Photo',
                            image: AppImages.iImage,
                            infoMessage:
                                'Please upload a clear photo of your Aadhar.',
                          ),
                          SizedBox(height: 10),
                          _imageBox(index: 0),

                          SizedBox(height: 30),

                          CommonContainer.containerTitle(
                            context: context,
                            title: 'Profile Picture',
                            image: AppImages.iImage,
                            infoMessage:
                                'Please upload a clear profile picture.',
                          ),
                          SizedBox(height: 10),
                          _imageBox(index: 1),

                          SizedBox(height: 30),
                          CommonContainer.button(
                            buttonColor: AppColor.darkBlue,
                            imagePath:
                                state.isLoading
                                    ? null
                                    : AppImages.rightStickArrow,
                            text:
                                state.isLoading
                                    ? ThreeDotsLoader(
                                      dotColor: AppColor.darkBlue,
                                    )
                                    : Text('Save'),
                            onTap: () async {
                              if (state.isLoading) return;
                              final fullName =
                                  englishNameController.text.trim().isEmpty
                                      ? (widget.name ?? "")
                                      : englishNameController.text.trim();

                              // final phone =
                              //     mobileController.text.trim().isEmpty
                              //         ? (widget.phoneNumber ?? "")
                              //         : mobileController.text.trim();

                              final oldPhone = _normalizeIndianPhone(
                                widget.phoneNumber ?? "",
                              );
                              final newPhone = _normalizeIndianPhone(
                                mobileController.text,
                              );

                              final bool phoneChanged =
                                  newPhone.isNotEmpty && newPhone != oldPhone;
                              final phone = phoneChanged ? newPhone : oldPhone;

                              final email =
                                  emailIdController.text.trim().isEmpty
                                      ? (widget.email ?? "")
                                      : emailIdController.text.trim();

                              final emergencyName =
                                  emergencyNameController.text.trim().isEmpty
                                      ? (widget.emergencyContactName ?? "")
                                      : emergencyNameController.text.trim();

                              final emergencyRel =
                                  emergencyRelationShipController.text
                                          .trim()
                                          .isEmpty
                                      ? (widget.emergencyContactRelationship ??
                                          "")
                                      : emergencyRelationShipController.text
                                          .trim();

                              final emergencyPhone = _normalizeIndianPhone(
                                emergencyMobileController.text.trim().isEmpty
                                    ? (widget.emergencyContactPhone ?? "")
                                    : emergencyMobileController.text.trim(),
                              );

                              // final emergencyPhone =
                              //     emergencyMobileController.text.trim().isEmpty
                              //         ? (widget.emergencyContactPhone ?? "")
                              //         : emergencyMobileController.text.trim();

                              final aadhaarNo =
                                  aadharController.text.trim().isEmpty
                                      ? (widget.aadharNumber ?? "")
                                      : aadharController.text.trim();

                              await ref
                                  .read(heaterEmployeeEditNotifier.notifier)
                                  .editEmployee(
                                    employeeId: widget.employeeId,
                                    phoneNumber: phone,
                                    // phoneNumber: phoneChanged ? newPhone : oldPhone,
                                    fullName: fullName,
                                    email: email,
                                    emergencyContactName: emergencyName,
                                    emergencyContactRelationship: emergencyRel,
                                    emergencyContactPhone: emergencyPhone,
                                    aadhaarNumber: aadhaarNo,

                                    aadhaarFile: _pickedImages[0],
                                    ownerImageFile: _pickedImages[1],

                                    existingAvatarUrl: widget.avatarUrl ?? "",
                                    existingAadhaarUrl:
                                        widget.aadharDocumentUrl ?? "",
                                    // existingAadhaarUrl: _existingUrls[0] ?? "",
                                  );

                              final newState = ref.read(
                                heaterEmployeeEditNotifier,
                              );

                              if (newState.error != null) {
                                AppSnackBar.error(context, newState.error!);
                                return;
                              }

                              AppSnackBar.success(
                                context,
                                "Employee updated successfully",
                              );
                              Navigator.pop(context);
                            },

                            ///old///
                            // onTap: () async {
                            //   if (state.isLoading) return;
                            //
                            //   await ref
                            //       .read(heaterEmployeeEditNotifier.notifier)
                            //       .editEmployee(
                            //         employeeId: widget.employeeId,
                            //         phoneNumber: mobileController.text.trim(),
                            //         fullName: englishNameController.text.trim(),
                            //         email: emailIdController.text.trim(),
                            //         emergencyContactName:
                            //             emergencyNameController.text.trim(),
                            //         emergencyContactRelationship:
                            //             emergencyRelationShipController.text
                            //                 .trim(),
                            //         emergencyContactPhone:
                            //             emergencyMobileController.text.trim(),
                            //         aadhaarNumber: aadharController.text.trim(),
                            //
                            //         aadhaarFile: _pickedImages[0],
                            //         ownerImageFile: _pickedImages[1],
                            //
                            //         // fallback (at least avatar exists)
                            //         existingAvatarUrl: widget.avatarUrl ?? "",
                            //         existingAadhaarUrl:
                            //             _existingUrls[0] ?? "", // if you have it
                            //       );
                            //
                            //   final newState = ref.read(
                            //     heaterEmployeeEditNotifier,
                            //   );
                            //
                            //   if (newState.error != null) {
                            //     AppSnackBar.error(context, newState.error!);
                            //     return;
                            //   }
                            //
                            //   AppSnackBar.success(
                            //     context,
                            //     "Employee updated successfully",
                            //   );
                            //
                            //   // Don't push same page again
                            //   // context.pop();
                            //   Navigator.pop(context);
                            // },
                          ),

                          SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
