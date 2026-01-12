import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkUtil {
  static Future<bool> hasInternet() async {
    final result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }
}
