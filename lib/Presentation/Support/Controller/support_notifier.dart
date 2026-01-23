import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../Api/DataSource/api_data_source.dart';
import '../../../Core/Utility/app_snackbar.dart';

import '../../Login Screen/Controller/login_notifier.dart';
import '../Model/chat_message_response.dart';
import '../Model/create_support_response.dart';
import '../Model/send_message_response.dart';
import '../Model/support_list_response.dart';

class SupportState {
  final bool isLoading;
  final bool isMsgSendingLoading;

  final String? error;
  final int refreshKey; // ✅ new field
  final SupportListResponse? supportListResponse;
  final CreateSupportResponse? createSupportResponse;
  final ChatMessageResponse? chatMessageResponse;
  final SendMessageResponse? sendMessageResponse;

  const SupportState({
    this.isLoading = false,
    this.isMsgSendingLoading = true,
    this.error,
    this.supportListResponse,
    this.createSupportResponse,
    this.chatMessageResponse,
    this.sendMessageResponse,
    this.refreshKey = 0, // default
  });

  factory SupportState.initial() => const SupportState();

  SupportState copyWith({
    bool? isLoading,
    bool? isMsgSendingLoading,

    String? error,
    int? refreshKey,
    SupportListResponse? supportListResponse,
    CreateSupportResponse? createSupportResponse,
    ChatMessageResponse? chatMessageResponse,
    SendMessageResponse? sendMessageResponse,
  }) {
    return SupportState(
      isLoading: isLoading ?? this.isLoading,
      isMsgSendingLoading: isMsgSendingLoading ?? this.isMsgSendingLoading,

      error: error,
      refreshKey: refreshKey ?? this.refreshKey + 1, // ✅ increment
      supportListResponse: supportListResponse ?? this.supportListResponse,
      chatMessageResponse: chatMessageResponse ?? this.chatMessageResponse,
      sendMessageResponse: sendMessageResponse ?? this.sendMessageResponse,
      createSupportResponse:
          createSupportResponse ?? this.createSupportResponse,

      // activeEnquiryId: activeEnquiryId,
    );
  }
}

class SupportNotifier extends Notifier<SupportState> {
  late final ApiDataSource api;

  @override
  SupportState build() {
    api = ref.read(apiDataSourceProvider);
    return SupportState.initial();
  }

  Future<void> supportList({required BuildContext context}) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await api.supportList();

    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        AppSnackBar.error(context, failure.message);
      },
      (response) {
        state = state.copyWith(
          isLoading: false,
          error: null,
          supportListResponse: response,
        );
      },
    );
  }

  Future<void> getChatMessage({required String id}) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await api.getChatMessages(id: id);

    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
      },
      (response) {
        state = state.copyWith(
          isLoading: false,
          error: null,
          chatMessageResponse: response,
        );
      },
    );
  }


  Future<String?> createSupportTicket({
    required String subject,
    required String description,
    File? ownerImageFile,
    required BuildContext context,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    String customerImageUrl = '';

    final hasValidImage = ownerImageFile != null &&
        ownerImageFile.path.isNotEmpty &&
        await ownerImageFile.exists();

    if (hasValidImage) {
      final uploadResult = await api.userProfileUpload(imageFile: ownerImageFile);

      customerImageUrl = uploadResult.fold(
            (failure) => '',
            (success) => success.message.toString(),
      );
    }

    final result = await api.createSupportTicket(
      attachments: customerImageUrl,
      description: description,
      imageUrl: customerImageUrl,
      subject: subject,
    );

    // ✅ IMPORTANT: capture fold value and return it
    final String? ticketId = result.fold(
          (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        AppSnackBar.error(context, failure.message);
        return null; // return ticketId as null on failure
      },
          (response) {
        state = state.copyWith(
          isLoading: false,
          error: null,
          createSupportResponse: response,
        );
        return response.data.id; // ✅ ticket id return
      },
    );

    return ticketId;
  }

  // Future<String?> createSupportTicket({
  //   required String subject,
  //   required String description,
  //
  //   File? ownerImageFile,
  //   required BuildContext context,
  // }) async {
  //   state = state.copyWith(isLoading: true, error: null);
  //
  //   String customerImageUrl = '';
  //
  //   final hasValidImage =
  //       ownerImageFile != null &&
  //       ownerImageFile.path.isNotEmpty &&
  //       await ownerImageFile.exists();
  //
  //   if (hasValidImage) {
  //     final uploadResult = await api.userProfileUpload(
  //       imageFile: ownerImageFile,
  //     );
  //
  //     customerImageUrl = uploadResult.fold(
  //       (failure) => '',
  //       (success) => success.message.toString(),
  //     );
  //   }
  //
  //   final result = await api.createSupportTicket(
  //     attachments: customerImageUrl,
  //     description: description,
  //     imageUrl: customerImageUrl,
  //     subject: subject,
  //   );
  //
  //   result.fold(
  //     (failure) {
  //       state = state.copyWith(isLoading: false, error: failure.message);
  //       AppSnackBar.error(context, failure.message);
  //       return failure.message;
  //     },
  //     (response) {
  //       state = state.copyWith(
  //         isLoading: false,
  //         error: null,
  //         createSupportResponse: response,
  //       );
  //       return response.data;
  //     },
  //   );
  //   return null;
  // }

  Future<String?> sendMessage({
    required String subject,
    required String ticketId,

    File? ownerImageFile,
    required BuildContext context,
  }) async {
    state = state.copyWith(isMsgSendingLoading: true, error: null);

    String customerImageUrl = '';

    final hasValidImage =
        ownerImageFile != null &&
        ownerImageFile.path.isNotEmpty &&
        await ownerImageFile.exists();

    if (hasValidImage) {
      final uploadResult = await api.userProfileUpload(
        imageFile: ownerImageFile,
      );

      customerImageUrl = uploadResult.fold(
        (failure) => '',
        (success) => success.message.toString(),
      );
    }

    final result = await api.sendMessage(
      ticketId: ticketId,
      attachments: customerImageUrl,

      imageUrl: customerImageUrl,
      subject: subject,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          isMsgSendingLoading: false,
          error: failure.message,
        );
        AppSnackBar.error(context, failure.message);
        return failure.message;
      },
      (response) {
        state = state.copyWith(
          isMsgSendingLoading: false,
          error: null,
          sendMessageResponse: response,
        );
        return response.data;
      },
    );
    return null;
  }
}

final supportNotifier = NotifierProvider<SupportNotifier, SupportState>(
  SupportNotifier.new,
);
