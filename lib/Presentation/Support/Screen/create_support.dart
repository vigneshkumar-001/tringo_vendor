import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tringo_vendor_new/Core/Const/app_logger.dart';
import 'package:tringo_vendor_new/Core/Utility/app_textstyles.dart';

import '../../../../../Core/Widgets/common_container.dart';

import '../../../Core/Const/app_color.dart';
import '../../../Core/Const/app_images.dart';
import '../../../Core/Utility/app_loader.dart';
import '../../../Core/Utility/app_snackbar.dart';
import '../Controller/support_notifier.dart';
import 'support_chat_screen.dart';

class CreateSupport extends ConsumerStatefulWidget {
  const CreateSupport({super.key});

  @override
  ConsumerState<CreateSupport> createState() => _CreateSupportState();
}

class _CreateSupportState extends ConsumerState<CreateSupport>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  final _subjectCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  final _picker = ImagePicker();
  XFile? _picked;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    _subjectCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final x = await _picker.pickImage(source: ImageSource.gallery);
    if (!mounted) return;
    setState(() => _picked = x);
  }

  InputDecoration _fieldDeco() {
    return InputDecoration(
      filled: true,
      fillColor: const Color(0xFFF2F2F2),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    );
  }

  Future<void> _showPickOptions() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: AppColor.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt_outlined),
                  title: Text('Camera', style: AppTextStyles.mulish()),
                  onTap: () async {
                    Navigator.pop(context);
                    await _pickFromCamera();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_outlined),
                  title: Text('Gallery', style:AppTextStyles.mulish()),
                  onTap: () async {
                    Navigator.pop(context);
                    await _pickFromGallery();
                  },
                ),
                const SizedBox(height: 6),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickFromCamera() async {
    final x = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    if (!mounted) return;
    setState(() => _picked = x);
  }

  Future<void> _pickFromGallery() async {
    final x = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (!mounted) return;
    setState(() => _picked = x);
  }

  void _removeImage() {
    setState(() => _picked = null);
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(supportNotifier.notifier);
    final state = ref.watch(supportNotifier);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 16),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: CommonContainer.topLeftArrow(
                        onTap: () => Navigator.pop(context),
                      ),
                    ),
                    Text(
                      'Create Support',
                      style: AppTextStyles.mulish(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: AppColor.mildBlack,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 25),
                Text(
                  'Subject',
                  style: AppTextStyles.mulish(color: AppColor.mildBlack),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _subjectCtrl,
                  maxLines: 2,
                  textInputAction: TextInputAction.next,
                  decoration: _fieldDeco(),
                ),
                SizedBox(height: 25),
                Text(
                  'Description',
                  style: AppTextStyles.mulish(color: AppColor.mildBlack),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _descCtrl,
                  maxLines: 8,
                  decoration: _fieldDeco(),
                ),

                SizedBox(height: 25),

                CommonContainer.containerTitle(
                  context: context,
                  title: 'Upload Photo',
                  image: AppImages.iImage,
                  infoMessage:
                  'Please upload a clear photo of your shop signboard.',
                ),
                SizedBox(height: 10),

                InkWell(
                  onTap: _showPickOptions,
                  borderRadius: BorderRadius.circular(16),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    width: double.infinity,
                    height: _picked == null ? 70 : 200, // ✅ auto height change
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F2F2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: (_picked == null)
                        ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(AppImages.galleryImage, height: 20),
                        const SizedBox(width: 10),
                        Text(
                          'Upload Image',
                          style: AppTextStyles.mulish(
                            color: Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    )
                        : Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(
                            File(_picked!.path),
                            width: double.infinity,
                            height:
                            double.infinity, // ✅ fill the container
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          right: 8,
                          top: 8,
                          child: InkWell(
                            onTap: _removeImage,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.55),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 40),

                CommonContainer.button(
                  buttonColor: AppColor.darkBlue,
                  imagePath: state.isLoading ? null : AppImages.rightStickArrow,

                  onTap: () async {
                    final notifier = ref.read(supportNotifier.notifier);

                    final File? imageFile = (_picked != null && _picked!.path.isNotEmpty)
                        ? File(_picked!.path)
                        : null;

                    final ticketId = await notifier.createSupportTicket(
                      subject: _subjectCtrl.text.trim(),
                      description: _descCtrl.text.trim(),
                      ownerImageFile: imageFile,
                      context: context,
                    );

                    if (!context.mounted) return;

                    if (ticketId != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SupportChatScreen(id: ticketId),
                        ),
                      );
                    }
                  },

                  // onTap: () async {
                  //   // Prepare image file if picked
                  //   final File? imageFile =
                  //   (_picked != null && _picked!.path.isNotEmpty)
                  //       ? File(_picked!.path)
                  //       : null;
                  //
                  //   AppLogger.log.w(imageFile);
                  //
                  //   // Call API to create support ticket
                  //   final err = await data.createSupportTicket(
                  //     subject: _subjectCtrl.text.trim(),
                  //     description: _descCtrl.text.trim(),
                  //     ownerImageFile: imageFile,
                  //     context: context,
                  //   );
                  //
                  //   if (!context.mounted) return;
                  //
                  //   if (err == null) {
                  //     AppLogger.log.i("Navigation to home called");
                  //     // ✅ Navigate to home safely using GoRouter
                  //     Navigator.pop(context);
                  //   } else {
                  //     // Show error
                  //     AppSnackBar.error(context, err);
                  //   }
                  // },

                  text: state.isLoading
                      ? AppLoader.circularLoader()
                      : Text('Create Ticket'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
