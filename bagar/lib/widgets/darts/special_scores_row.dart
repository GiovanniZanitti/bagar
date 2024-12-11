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
      child: Container(
        decoration: DartsButtonStyle.getGradientDecoration(primaryColor),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          onPressed: throwsLeft > 0 ? () => onScoreSelected(score) : null,
          child: Text(
            '$score',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
} 