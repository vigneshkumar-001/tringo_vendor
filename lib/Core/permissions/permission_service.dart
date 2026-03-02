import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static bool _isRequesting = false;

  static Future<bool> requestCorePermissionsWithDialog(
    BuildContext context,
  ) async {
    if (!Platform.isAndroid) return true;

    // ✅ Prevent parallel requests
    if (_isRequesting) return false;
    _isRequesting = true;

    try {
      // ✅ Request ALL needed permissions in ONE call
      final statuses =
          await <Permission>[
            Permission.phone,
            Permission.contacts,
            Permission.notification, // Android 13+
          ].request();

      final phoneGranted = statuses[Permission.phone]?.isGranted ?? false;
      final contactsGranted = statuses[Permission.contacts]?.isGranted ?? false;

      // notification can be denied; don't block app if you don't need it
      // final notifGranted = statuses[Permission.notification]?.isGranted ?? true;

      final ok = phoneGranted && contactsGranted;
      if (ok) return true;

      if (!context.mounted) return false;

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (_) => AlertDialog(
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
    } finally {
      _isRequesting = false;
    }
  }

  static bool _overlayRequesting = false;

  static Future<void> requestOverlayIfNeeded() async {
    if (!Platform.isAndroid) return;

    if (_overlayRequesting) return;
    _overlayRequesting = true;

    try {
      final status = await Permission.systemAlertWindow.status;
      if (!status.isGranted) {
        await Permission.systemAlertWindow.request();
      }
    } finally {
      _overlayRequesting = false;
    }
  }
}

// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:permission_handler/permission_handler.dart';
//
// class PermissionService {
//   static Future<bool> requestCorePermissionsWithDialog(BuildContext context) async {
//     if (!Platform.isAndroid) return true;
//
//     final phone = await Permission.phone.request();      // READ_PHONE_STATE (+ group)
//     final contacts = await Permission.contacts.request();
//
//     PermissionStatus notif = PermissionStatus.granted;
//     if (await Permission.notification.isDenied || await Permission.notification.isRestricted) {
//       notif = await Permission.notification.request();
//     }
//
//     final ok = phone.isGranted && contacts.isGranted;
//     if (ok) return true;
//
//     if (!context.mounted) return false;
//
//     await showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (_) => AlertDialog(
//         title: const Text("Permissions Required"),
//         content: const Text(
//           "To show Caller ID popup after call cut, Tringo needs:\n\n"
//               "• Phone permission\n"
//               "• Contacts permission\n\n"
//               "Tap Settings → Permissions → Allow.",
//         ),
//         actions: [
//           TextButton(
//             onPressed: () async {
//               Navigator.pop(context);
//               await openAppSettings();
//             },
//             child: const Text("Open Settings"),
//           ),
//         ],
//       ),
//     );
//
//     return false;
//   }
//
//   static Future<void> requestOverlayIfNeeded() async {
//     if (!Platform.isAndroid) return;
//     final status = await Permission.systemAlertWindow.status;
//     if (!status.isGranted) {
//       await Permission.systemAlertWindow.request();
//     }
//   }
// }
