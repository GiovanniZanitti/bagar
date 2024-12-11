import 'package:flutter/material.dart';
import 'darts_button_style.dart';

class SpecialScoresRow extends StatelessWidget {
  final Color primaryColor;
  final Function(int) onScoreSelected;
  final int throwsLeft;

  const SpecialScoresRow({
    super.key,
    required this.primaryColor,
    required this.onScoreSelected,
    required this.throwsLeft,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildSpecialButton(0),
        const SizedBox(width: 10),
        _buildSpecialButton(25),
        const SizedBox(width: 10),
        _buildSpecialButton(50),
      ],
    );
  }

  Widget _buildSpecialButton(int score) {
    return Expanded(
      child: ElevatedButton(
        style: DartsButtonStyle.getButtonStyle(primaryColor),
        onPressed: throwsLeft > 0 ? () => onScoreSelected(score) : null,
        child: Text(
          '$score',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
} 