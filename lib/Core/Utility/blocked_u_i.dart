import 'package:flutter/material.dart';

class BlockedUI {
  static const List<double> _grayMatrix = <double>[
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0,      0,      0,      1, 0,
  ];

  static Widget wrap({
    required bool blocked,
    required Widget child,
    bool disableTap = false,
  }) {
    // disableTap=true -> card click / action buttons disable ஆகும்
    return IgnorePointer(
      ignoring: blocked && disableTap,
      child: Opacity(
        opacity: blocked ? 0.55 : 1.0,
        child: child,
      ),
    );
  }

  static Widget grayImageIfBlocked({
    required bool blocked,
    required Widget image,
  }) {
    if (!blocked) return image;
    return ColorFiltered(
      colorFilter: const ColorFilter.matrix(_grayMatrix),
      child: image,
    );
  }

  static Color cardBg(bool blocked, Color normalBg) =>
      blocked ? Colors.grey.shade200 : normalBg;

  static Color text(bool blocked, Color normal) =>
      blocked ? Colors.grey.shade700 : normal;

  static Color subText(bool blocked, Color normal) =>
      blocked ? Colors.grey.shade600 : normal;

  static Color border(bool blocked, Color normal) =>
      blocked ? Colors.grey.shade400 : normal;
}
