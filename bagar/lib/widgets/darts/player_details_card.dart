import 'package:flutter/material.dart';
import '../../models/player_model.dart';

class PlayerDetailsCard extends StatelessWidget {
  final Player player;
  final int score;
  final List<int?> currentThrows;
  final Color primaryColor;
  final Function(int, int) onThrowTap;

  const PlayerDetailsCard({
    super.key,
    required this.player,
    required this.score,
    required this.currentThrows,
    required this.primaryColor,
    required this.onThrowTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            player.name,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Score total : $score',
            style: TextStyle(
              fontSize: 20,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          _buildThrowsGrid(),
          const SizedBox(height: 16),
          Text(
            'Score du tour : ${_calculateRoundScore()}',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThrowsGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(3, (index) {
            return Text(
              '${index + 1}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(3, (index) {
            return GestureDetector(
              onTap: () => onThrowTap(index, currentThrows[index] ?? 0),
              child: Text(
                '${currentThrows[index] ?? '-'}',
                style: TextStyle(
                  fontSize: 18,
                  decoration: TextDecoration.underline,
                  color: primaryColor,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  int _calculateRoundScore() {
    return currentThrows.where((score) => score != null).fold(0, (a, b) => a + (b ?? 0));
  }
} 