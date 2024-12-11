import 'package:flutter/material.dart';
import 'darts_button_style.dart';

class MultiplierButtons extends StatelessWidget {
  final String activeMultiplier;
  final Color primaryColor;
  final Function(String) onMultiplierChanged;

  const MultiplierButtons({
    super.key,
    required this.activeMultiplier,
    required this.primaryColor,
    required this.onMultiplierChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: ['Simple', 'Double', 'Triple'].map((label) {
        final isActive = activeMultiplier == label;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Container(
            decoration: isActive 
                ? DartsButtonStyle.getGradientDecoration(primaryColor)
                : BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(8),
                  ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
              onPressed: () => onMultiplierChanged(label),
              child: Text(
                label,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
} 