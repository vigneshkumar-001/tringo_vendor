import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:tringo_vendor_new/Core/Utility/app_textstyles.dart';


import '../../../Core/Const/app_color.dart';
import '../../../Core/Const/app_images.dart';
import '../../../Core/Widgets/common_container.dart';
import '../Model/chat_message_response.dart' as api;
import '../controller/support_notifier.dart';

class SupportChatScreen extends ConsumerStatefulWidget {
  final String id;
  const SupportChatScreen({super.key, required this.id});

  @override
  ConsumerState<SupportChatScreen> createState() => _SupportChatScreenState();
}

class _SupportChatScreenState extends ConsumerState<SupportChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<LocalChatMessage> _localMessages = [];
  XFile? _pickedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(supportNotifier.notifier).getChatMessage(id: widget.id);
    });
  }
  String formatTime(DateTime time) {
    return DateFormat.jm().format(time); // e.g., 4:13 PM
  }
  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (!mounted || picked == null) return;
    setState(() => _pickedImage = picked);
  }
  Future<void> _sendMessage() async {
    final notifier = ref.read(supportNotifier.notifier);

    if (_messageController.text.trim().isEmpty && _pickedImage == null) return;

    final tempId = DateTime.now().millisecondsSinceEpoch.toString();

    final localMessage = LocalChatMessage(
      id: tempId,
      message: _messageController.text.trim(),
      isMine: true,
      time: DateTime.now(),
      isSending: true,
      isFailed: false,
      localImagePath: _pickedImage?.path,
    );

    // Add local message immediately
    setState(() => _localMessages.add(localMessage));

    // Clear input
    final text = _messageController.text.trim();
    final File? imageFile = _pickedImage != null ? File(_pickedImage!.path) : null;
    _messageController.clear();
    setState(() => _pickedImage = null);

    // Scroll to bottom after adding
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    try {
      // Send message to API
      await notifier.sendMessage(
        context: context,
        ticketId: widget.id,
        subject: text,
        ownerImageFile: imageFile,
      );

      // Mark as sent
      setState(() {
        final i = _localMessages.indexWhere((e) => e.id == tempId);
        if (i != -1) _localMessages[i] = _localMessages[i].copyWith(isSending: false);
      });

      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    } catch (e) {
      // Mark as failed
      setState(() {
        final i = _localMessages.indexWhere((e) => e.id == tempId);
        if (i != -1) _localMessages[i] =
            _localMessages[i].copyWith(isSending: false, isFailed: true);
      });
    }
  }
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Widget _chatBubble({
    required bool isMine,
    String? text,
    String? imageUrl,
    String? localImagePath,
    required String time,
    bool isSending = false,
    bool isFailed = false,
  }) {
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
        decoration: BoxDecoration(
          color: isMine ? AppColor.textWhite : AppColor.midnightBlue,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (localImagePath != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(File(localImagePath), width: 150, height: 150, fit: BoxFit.cover),
              ),
            if (imageUrl != null && imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(imageUrl, width: 150, height: 150, fit: BoxFit.cover),
              ),
            if (text != null && text.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  text,
                  style:AppTextStyles.mulish(color: isMine ? Colors.black : Colors.white),
                ),
              ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(time, style: const TextStyle(fontSize: 10)),
                if (isSending)
                  const Padding(
                    padding: EdgeInsets.only(left: 4),
                    child: Icon(Icons.schedule, size: 12),
                  ),
                if (isFailed)
                  const Padding(
                    padding: EdgeInsets.only(left: 4),
                    child: Icon(Icons.error, color: Colors.red, size: 12),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildInputBar(SupportState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      color: Colors.white,
      child: Column(
        children: [
          if (_pickedImage != null)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              height: 120,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(File(_pickedImage!.path), width: 180, height: 180, fit: BoxFit.cover),
                  ),
                  Positioned(
                    top: 5,
                    right: 5,
                    child: InkWell(
                      onTap: () => setState(() => _pickedImage = null),
                      child: CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.black.withOpacity(0.6),
                        child: const Icon(Icons.close, size: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: "Type here",
                    filled: true,
                    fillColor: Colors.grey[200],
                    suffixIcon: InkWell(
                      onTap: _pickImage,
                      borderRadius: BorderRadius.circular(15),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Image.asset(AppImages.galleryImage, width: 22, color: AppColor.darkBlue),
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              InkWell(
                onTap: _sendMessage,
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColor.black,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Image.asset(AppImages.sendImage, height: 20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(SupportState state) {
    final ticket = state.chatMessageResponse?.data.ticket;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          SizedBox(
            height: 56,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: CommonContainer.topLeftArrow(
                    onTap: () => Navigator.pop(context),
                  ),
                ),
                Text(
                  'Support Chat',
                  style: AppTextStyles.mulish(fontSize: 16, fontWeight: FontWeight.w400, color: AppColor.mildBlack),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(ticket?.status ?? 'OPEN',
                          style: AppTextStyles.mulish(fontSize: 14, fontWeight: FontWeight.w600, color: AppColor.blue)),
                      const SizedBox(height: 9),
                      Text(ticket?.subject ?? 'Loading subject...',
                          maxLines: 2, overflow: TextOverflow.ellipsis, style: AppTextStyles.mulish(color: AppColor.black)),
                      const SizedBox(height: 9),
                      Text('Created on ${ticket?.createdOn ?? ''}',
                          style: AppTextStyles.mulish(fontSize: 12, color: AppColor.black.withOpacity(0.4))),
                    ],
                  ),
                ),
                const SizedBox(width: 40),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    decoration: BoxDecoration(color: AppColor.black, borderRadius: BorderRadius.circular(15)),
                    child: Column(
                      children: [
                        Text("Close", style: AppTextStyles.mulish(fontSize: 12, color: Colors.white)),
                        Text("Ticket", style: AppTextStyles.mulish(fontSize: 12, color: Colors.white)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(supportNotifier);

    // Merge all messages (API + local) and sort by time ascending
    final List<_ChatItem> allMessages = [];

    if (state.chatMessageResponse != null) {
      for (var group in state.chatMessageResponse!.data.messageGroups) {
        for (var msg in group.messages) {
          allMessages.add(_ChatItem(
            isMine: msg.senderRole != "ADMIN",
            text: msg.message,
            imageUrl: msg.attachments.isNotEmpty ? msg.attachments.first.url : null,
            localImagePath: null,
            time: _parseTimeLabel(msg.timeLabel),
          ));
        }
      }
    }

    // Add local messages
    allMessages.addAll(_localMessages.map((m) => _ChatItem(
      isMine: m.isMine,
      text: m.message,
      imageUrl: null,
      localImagePath: m.localImagePath,
      time: m.time,
      isSending: m.isSending,
      isFailed: m.isFailed,
    )));

    // Sort messages by time ascending (oldest first)
    allMessages.sort((a, b) => a.time.compareTo(b.time));

    return Scaffold(
      backgroundColor: AppColor.white,
      body: SafeArea(
        child: Skeletonizer(
          enabled: state.isLoading,
          child: Column(
            children: [
              _buildHeader(state),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  itemCount: allMessages.length,
                  itemBuilder: (context, index) {
                    final msg = allMessages[index];
                    return _chatBubble(
                      isMine: msg.isMine,
                      text: msg.text,
                      imageUrl: msg.imageUrl,
                      localImagePath: msg.localImagePath,
                      time: formatTime(msg.time),

                      isSending: msg.isSending,
                      isFailed: msg.isFailed,
                    );
                  },
                ),
              ),
              _buildInputBar(state),
            ],
          ),
        ),
      ),
    );
  }

  DateTime _parseTimeLabel(String label) {
    // Assuming label like "6:21 pm"
    try {
      final parts = label.split(' ');
      final hm = parts[0].split(':');
      int hour = int.parse(hm[0]);
      int minute = int.parse(hm[1]);
      if (parts[1].toLowerCase() == 'pm' && hour != 12) hour += 12;
      if (parts[1].toLowerCase() == 'am' && hour == 12) hour = 0;
      return DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, hour, minute);
    } catch (_) {
      return DateTime.now();
    }
  }
}

// Helper class for merged messages
class _ChatItem {
  final bool isMine;
  final String? text;
  final String? imageUrl;
  final String? localImagePath;
  final DateTime time;
  final bool isSending;
  final bool isFailed;

  _ChatItem({
    required this.isMine,
    this.text,
    this.imageUrl,
    this.localImagePath,
    required this.time,
    this.isSending = false,
    this.isFailed = false,
  });
}

// ---------------- LOCAL MESSAGE MODEL ----------------
class LocalChatMessage {
  final String id;
  final String message;
  final bool isMine;
  final DateTime time;
  final bool isSending;
  final bool isFailed;
  final String? localImagePath;

  LocalChatMessage({
    required this.id,
    required this.message,
    required this.isMine,
    required this.time,
    this.isSending = false,
    this.isFailed = false,
    this.localImagePath,
  });

  LocalChatMessage copyWith({bool? isSending, bool? isFailed}) {
    return LocalChatMessage(
      id: id,
      message: message,
      isMine: isMine,
      time: time,
      localImagePath: localImagePath,
      isSending: isSending ?? this.isSending,
      isFailed: isFailed ?? this.isFailed,
    );
  }
}



