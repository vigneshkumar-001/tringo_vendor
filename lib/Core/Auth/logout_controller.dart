import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../Api/Repository/auth_repository.dart';

class LogoutController extends Notifier<bool> {
  @override
  bool build() => false;

  Future<void> logout() async {
    if (state) return;
    state = true;
    try {
      await ref.read(authRepositoryProvider).logout();
    } finally {
      state = false;
    }
  }
}

final logoutControllerProvider = NotifierProvider<LogoutController, bool>(
  LogoutController.new,
);
