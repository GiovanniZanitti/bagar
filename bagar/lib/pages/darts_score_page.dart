import 'package:flutter/material.dart';
import '../models/player_model.dart';
import '../widgets/gradient_background.dart';
import '../widgets/darts/player_details_card.dart';
import '../widgets/darts/players_ranking.dart';
import '../widgets/darts/multiplier_buttons.dart';
import '../widgets/darts/score_grid.dart';
import '../widgets/darts/validate_button.dart';
import '../widgets/darts/special_scores_row.dart';
import '../utils/category_colors.dart';
import '../controllers/darts_game_controller.dart';

class DartsScorePage extends StatefulWidget {
  final List<Player> players;
  final int initialScore;
  final String gameName;
  final String categoryName;

  const DartsScorePage({
    super.key,
    required this.players,
    required this.initialScore,
    required this.gameName,
    required this.categoryName,
  });

  @override
  State<DartsScorePage> createState() => _DartsScorePageState();
}

class _DartsScorePageState extends State<DartsScorePage> {
  late DartsGameController _gameController;
  String _activeMultiplier = 'Simple';

  @override
  void initState() {
    super.initState();
    _gameController = DartsGameController(
      players: widget.players,
      initialScore: widget.initialScore,
      context: context,
      onStateChanged: () {
        setState(() {});
      },
    );
  }

  void _handleThrowTap(int throwIndex) {
    final currentThrows = _gameController.currentThrowsPerPlayer[_gameController.currentPlayer];
    final currentScore = currentThrows[throwIndex];
    
    if (currentScore == null) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        int? newScore = currentScore;
        
        return AlertDialog(
          title: const Text('Modifier le score'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Nouveau score',
                ),
                onChanged: (value) {
                  newScore = int.tryParse(value);
                },
                autofocus: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: CategoryColors.getColor(widget.categoryName),
              ),
              onPressed: () {
                if (newScore != null) {
                  setState(() {
                    _gameController.updateThrowScore(throwIndex, newScore!);
                  });
                }
                Navigator.of(context).pop();
              },
              child: const Text(
                'Valider',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = CategoryColors.getColor(widget.categoryName);

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            'Compteur de points',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              PlayerDetailsCard(
                player: widget.players[_gameController.currentPlayer],
                score: _gameController.playerScores[_gameController.currentPlayer],
                currentThrows: _gameController.currentThrowsPerPlayer[_gameController.currentPlayer],
                primaryColor: categoryColor,
                onThrowTap: (index, score) => _handleThrowTap(index),
              ),
              const SizedBox(height: 20),
              PlayersRanking(
                players: widget.players,
                scores: _gameController.playerScores,
                currentPlayer: _gameController.currentPlayer,
                primaryColor: categoryColor,
              ),
              const SizedBox(height: 20),
              MultiplierButtons(
                activeMultiplier: _activeMultiplier,
                primaryColor: categoryColor,
                onMultiplierChanged: (multiplier) {
                  setState(() {
                    _activeMultiplier = multiplier;
                  });
                },
              ),
              const SizedBox(height: 20),
              SpecialScoresRow(
                primaryColor: categoryColor,
                throwsLeft: _gameController.throwsLeft,
                onScoreSelected: (score) {
                  setState(() {
                    _gameController.addThrowScore(score);
                  });
                },
              ),
              const SizedBox(height: 10),
              ScoreGrid(
                activeMultiplier: _activeMultiplier,
                primaryColor: categoryColor,
                throwsLeft: _gameController.throwsLeft,
                onScoreSelected: (score) {
                  setState(() {
                    _gameController.addThrowScore(score);
                  });
                },
              ),
              const SizedBox(height: 20),
              ValidateButton(
                primaryColor: categoryColor,
                isEnabled: _gameController.throwsLeft == 0,
                onValidate: () {
                  setState(() {
                    _gameController.validateScore();
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
