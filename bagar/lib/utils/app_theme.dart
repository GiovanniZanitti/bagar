import 'package:flutter/material.dart';

class AppTheme {
  // Couleurs fixes pour le gradient
  static const Color startColor = Colors.lightBlue;
  static const Color endColor = Colors.white;

  // Méthode pour obtenir la décoration du gradient
  static BoxDecoration get gradientDecoration {
    return const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [startColor, endColor],
      ),
    );
  }
} 