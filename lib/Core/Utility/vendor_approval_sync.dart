import 'dart:async';

import '../Session/session_manager.dart';
import 'app_prefs.dart';

enum VendorPushEventType { approved, rejected, suspended }

class VendorPushEvent {
  const VendorPushEvent({required this.type, this.vendorId, this.message});

  final VendorPushEventType type;
  final String? vendorId;
  final String? message;
}

class VendorApprovalSync {
  VendorApprovalSync._();

  static final StreamController<VendorPushEvent> _eventsController =
      StreamController<VendorPushEvent>.broadcast();

  static Stream<VendorPushEvent> get events => _eventsController.stream;

  static Future<VendorPushEvent?> syncFromPushData(
    Map<String, dynamic> data,
  ) async {
    final eventType = (data['eventType'] ?? '').toString().trim().toUpperCase();
    final message = (data['message'] ?? data['body'] ?? '').toString().trim();

    switch (eventType) {
      case 'VENDOR_APPROVED':
        final vendorId = (data['vendorId'] ?? '').toString().trim();

        if (vendorId.isNotEmpty) {
          await AppPrefs.setVendorId(vendorId);
        }

        await AppPrefs.clearVendorAccessBlock();
        await AppPrefs.setVendorApproved(true);
        await AppPrefs.setVendorStatus('ACTIVE');
        await AppPrefs.setOnboardingStep('step-7');

        final event = VendorPushEvent(
          type: VendorPushEventType.approved,
          vendorId: vendorId.isEmpty ? null : vendorId,
          message: message.isEmpty ? null : message,
        );
        _eventsController.add(event);
        return event;
      case 'VENDOR_REJECTED':
        return _blockVendorAccess(
          type: VendorPushEventType.rejected,
          message:
              message.isEmpty
                  ? 'Your vendor account was not approved. Please contact support for the next steps.'
                  : message,
        );
      case 'VENDOR_SUSPENDED':
        return _blockVendorAccess(
          type: VendorPushEventType.suspended,
          message:
              message.isEmpty
                  ? 'Your vendor account has been suspended by the admin. Please contact support for help.'
                  : message,
        );
      default:
        return null;
    }
  }

  static Future<VendorPushEvent> _blockVendorAccess({
    required VendorPushEventType type,
    required String message,
  }) async {
    final blockType =
        type == VendorPushEventType.rejected ? 'REJECTED' : 'SUSPENDED';

    await SessionManager.forceVendorAccessBlocked(
      blockType: blockType,
      message: message,
    );

    final event = VendorPushEvent(type: type, message: message);
    _eventsController.add(event);
    return event;
  }
}
