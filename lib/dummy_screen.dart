import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

final internetStatusProvider = StreamProvider<bool>((ref) async* {
  final connectivity = Connectivity();
  final internet = InternetConnection();

  // initial
  yield await internet.hasInternetAccess;

  // changes
  await for (final _ in connectivity.onConnectivityChanged) {
    yield await internet.hasInternetAccess;
  }
});
