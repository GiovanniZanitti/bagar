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
    return ElevatedButton(
      style: DartsButtonStyle.getButtonStyle(primaryColor),
      onPressed: isEnabled ? onValidate : null,
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 32),
        child: Text(
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