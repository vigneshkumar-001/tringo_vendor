import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Future<bool> requestCorePermissionsWithDialog(BuildContext context) async {
    if (!Platform.isAndroid) return true;

    final phone = await Permission.phone.request();      // READ_PHONE_STATE (+ group)
    final contacts = await Permission.contacts.request();

    PermissionStatus notif = PermissionStatus.granted;
    if (await Permission.notification.isDenied || await Permission.notification.isRestricted) {
      notif = await Permission.notification.request();
    }

    final ok = phone.isGranted && contacts.isGranted;
    if (ok) return true;

    if (!context.mounted) return false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("Permissions Required"),
        content: const Text(
          "To show Caller ID popup after call cut, Tringo needs:\n\n"
              "• Phone permission\n"
              "• Contacts permission\n\n"
              "Tap Settings → Permissions → Allow.",
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await openAppSettings();
            },
            child: const Text("Open Settings"),
          ),
        ],
      ),
    );

    return false;
  }

  static Future<void> requestOverlayIfNeeded() async {
    if (!Platform.isAndroid) return;
    final status = await Permission.systemAlertWindow.status;
    if (!status.isGranted) {
      await Permission.systemAlertWindow.request();
    }
  }
}
