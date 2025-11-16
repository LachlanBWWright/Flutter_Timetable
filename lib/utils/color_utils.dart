import 'package:flutter/material.dart';

/// Utility helpers for handling colors
Color getContrastingForeground(Color background) {
  // If background is very light, return black; otherwise return white
  return background.computeLuminance() > 0.5 ? Colors.black : Colors.white;
}
