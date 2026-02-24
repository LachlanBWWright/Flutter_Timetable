import 'package:flutter/material.dart';
import 'color_utils.dart';

/// Shared ButtonStyle helpers which preserve background (e.g., transport colors)
/// while ensuring the foreground color has sufficient contrast.
class ButtonStyles {
  /// Returns an ElevatedButton style with the specified background color and
  /// optional padding and elevation. Foreground color is chosen for contrast.
  static ButtonStyle elevated(
    Color background, {
    EdgeInsetsGeometry? padding,
    double? elevation,
    Size? minimumSize,
  }) {
    return ElevatedButton.styleFrom(
      backgroundColor: background,
      foregroundColor: getContrastingForeground(background),
      padding: padding ?? const EdgeInsets.symmetric(vertical: 12),
      elevation: elevation,
      minimumSize: minimumSize,
    );
  }

  /// Small variation used for smaller buttons like dialog actions
  static ButtonStyle elevatedSmall(Color background) => elevated(
    background,
    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
    minimumSize: const Size(64, 36),
  );
}
