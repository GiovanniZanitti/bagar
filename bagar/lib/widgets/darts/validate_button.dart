import 'package:flutter/material.dart';
import 'darts_button_style.dart';

class ValidateButton extends StatelessWidget {
  final Color primaryColor;
  final VoidCallback onValidate;
  final bool isEnabled;

  const ValidateButton({
    super.key,
    required this.primaryColor,
    required this.onValidate,
    required this.isEnabled,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: DartsButtonStyle.getGradientDecoration(primaryColor),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        ),
        onPressed: isEnabled ? onValidate : null,
        child: const Text(
          'Valider',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
} 