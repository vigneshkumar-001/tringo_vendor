import 'package:flutter/material.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class AppSnackBar {
  AppSnackBar._();

  static void _show(
      BuildContext context, {
        required Color background,
        required Widget icon,
        required String message,
        Duration duration = const Duration(seconds: 3),
      }) {
    final overlay = Overlay.of(context);
    if (overlay == null) return;

    showTopSnackBar(
      overlay,
      // Use Material so text style and elevation match platform
      Material(
        color: Colors.transparent,
        child: SafeArea(
          minimum: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
          child: Container(
            // full width minus horizontal margin
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  margin: const EdgeInsets.only(right: 12),
                  child: icon,
                ),

                // message: allow wrapping
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      displayDuration: duration,
    );
  }

  static void success(BuildContext context, String message) {
    _show(
      context,
      background: Colors.green.shade600,
      icon: const Icon(Icons.check_circle, color: Colors.white, size: 26),
      message: message,
    );
  }

  static void error(BuildContext context, String message) {
    _show(
      context,
      background: Colors.red.shade700,
      icon: const Icon(Icons.error_outline, color: Colors.white, size: 26),
      message: message,
    );
  }

  static void info(BuildContext context, String message) {
    _show(
      context,
      background: Colors.blue.shade700,
      icon: const Icon(Icons.info_outline, color: Colors.white, size: 26),
      message: message,
    );
  }
}
