import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

class DeviceIdHelper {
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  static Future<String> getDeviceId() async {
    try {
      if (Platform.isAndroid) {
        final android = await _deviceInfo.androidInfo;
        // ✅ stable id for Android device (not perfect, but commonly used)
        return android.id; // example: "QP1A.190711.020"
        // alternative: android.serial (deprecated), android.fingerprint, etc.
      }

      if (Platform.isIOS) {
        final ios = await _deviceInfo.iosInfo;
        return ios.identifierForVendor ?? '';
      }

      return '';
    } catch (e) {
      print(e);
      return '';
    }
  }
}