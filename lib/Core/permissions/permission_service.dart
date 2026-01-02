import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Future<void> requestOverlayAndContacts() async {
    await Permission.contacts.request();

    // Overlay permission (Android only)
    if (!await Permission.systemAlertWindow.isGranted) {
      await Permission.systemAlertWindow.request();
    }
    await Permission.notification.request();
  }
}
