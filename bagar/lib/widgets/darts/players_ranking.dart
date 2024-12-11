import 'package:flutter/material.dart';
import '../../models/player_model.dart';

class PlayersRanking extends StatelessWidget {
  final List<Player> players;
  final List<int> scores;
  final int currentPlayer;
  final Color primaryColor;

  const PlayersRanking({
    super.key,
    required this.players,
    required this.scores,
    required this.currentPlayer,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Classement',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(
                players.length,
                (index) => _buildPlayerCard(index),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerCard(int index) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Card(
        elevation: 2,
        color: index == currentPlayer 
            ? primaryColor.withOpacity(0.1)
            : Colors.white,
        child: Container(
          width: 100,
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                players[index].emoji,
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 4),
              Text(
                players[index].name,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: index == currentPlayer 
                      ? FontWeight.bold 
                      : FontWeight.normal,
                  color: primaryColor,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                '${scores[index]}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: index == currentPlayer 
                      ? FontWeight.bold 
                      : FontWeight.normal,
                  color: primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 