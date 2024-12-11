import 'package:flutter/material.dart';

class CategoryColors {
  static Color getColor(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'fléchettes':
        return Colors.green.shade700;
      case 'dés':
        return Colors.red.shade700;
      case 'cartes':
        return Colors.blue.shade700;
      case 'jeux oraux':
        return Colors.yellow.shade700;
      default:
        return Colors.grey.shade700;
    }
  }
} 