import 'package:flutter/material.dart';

class DartsButtonStyle {
  static ButtonStyle getButtonStyle(Color primaryColor) {
    return ElevatedButton.styleFrom(
      backgroundColor: primaryColor,
      elevation: 3,
      padding: const EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
} 