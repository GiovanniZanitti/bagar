import 'package:flutter/material.dart';
import 'darts_button_style.dart';

class ScoreGrid extends StatelessWidget {
  final String activeMultiplier;
  final Color primaryColor;
  final Function(int) onScoreSelected;
  final int throwsLeft;

  const ScoreGrid({
    super.key,
    required this.activeMultiplier,
    required this.primaryColor,
    required this.onScoreSelected,
    required this.throwsLeft,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: 20,
        itemBuilder: (context, index) {
          final baseScore = index + 1;
          final score = _calculateScore(baseScore);
          return _buildScoreButton(score);
        },
      ),
    );
  }

  Widget _buildScoreButton(int score) {
    return Container(
      decoration: DartsButtonStyle.getGradientDecoration(primaryColor),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        onPressed: throwsLeft > 0 ? () => onScoreSelected(score) : null,
        child: Text(
          '$score',
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  int _calculateScore(int baseScore) {
    switch (activeMultiplier) {
      case 'Double':
        return baseScore * 2;
      case 'Triple':
        return baseScore * 3;
      default:
        return baseScore;
    }
  }
} 