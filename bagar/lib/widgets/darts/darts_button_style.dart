import 'package:flutter/material.dart';

class DartsButtonStyle {
  static Decoration getGradientDecoration(Color primaryColor) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [
          primaryColor,
          primaryColor.withOpacity(0.7),
        ],
      ),
      borderRadius: BorderRadius.circular(8),
    );
  }
} 