import 'package:flutter/material.dart';
import '../models/player_model.dart';
import '../pages/result_page.dart';

class DartsGameController {
  final List<Player> players;
  final int initialScore;
  final BuildContext context;
  
  late List<int> playerScores;
  late List<List<int?>> currentThrowsPerPlayer;
  late List<int> initialRoundScores;
  late List<bool> hasPlayedLastRound;
  
  int currentPlayer = 0;
  int throwsLeft = 3;
  bool isLastRound = false;
  int? firstFinisher;

  DartsGameController({
    required this.players,
    required this.initialScore,
    required this.context,
  }) {
    _initialize();
  }

  void _initialize() {
    playerScores = List.generate(players.length, (_) => initialScore);
    currentThrowsPerPlayer = List.generate(players.length, (_) => [null, null, null]);
    initialRoundScores = List.from(playerScores);
    hasPlayedLastRound = List.generate(players.length, (_) => false);
  }

  void addThrowScore(int score) {
    if (throwsLeft <= 0) return;

    final newScore = playerScores[currentPlayer] - score;
    if (newScore < 0) {
      _handleInvalidScore();
    } else if (newScore == 0) {
      _handleWinningScore(score);
    } else {
      _handleValidScore(score);
    }
  }

  void _handleInvalidScore() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Score trop haut !'),
          content: const Text('Il faut arriver à 0 pile. Votre tour est annulé.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resetCurrentPlayerTurn();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _handleWinningScore(int score) {
    currentThrowsPerPlayer[currentPlayer][3 - throwsLeft] = score;
    playerScores[currentPlayer] = 0;

    if (!isLastRound) {
      _handleFirstFinisher();
    } else {
      _handleLastRoundFinish();
    }
  }

  void _handleFirstFinisher() {
    final remainingPlayers = players
        .asMap()
        .entries
        .where((entry) => entry.key > currentPlayer)
        .map((entry) => entry.value.name)
        .join(', ');

    final hasRemainingPlayers = remainingPlayers.isNotEmpty;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Félicitations !'),
          content: Text(
            '${players[currentPlayer].name} est le premier à finir !\n\n'
            '${hasRemainingPlayers ? 'Les joueurs suivants ont encore une chance : $remainingPlayers' : 'Aucun autre joueur ne peut jouer dans ce tour.'}'
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                firstFinisher = currentPlayer;
                if (hasRemainingPlayers) {
                  _startLastRound();
                } else {
                  _showFinalScores();
                }
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _handleValidScore(int score) {
    currentThrowsPerPlayer[currentPlayer][3 - throwsLeft] = score;
    playerScores[currentPlayer] -= score;
    throwsLeft--;
  }

  void validateScore() {
    if (throwsLeft > 0) return;
    
    initialRoundScores[currentPlayer] = playerScores[currentPlayer];
    if (isLastRound) {
      _handleLastRoundValidation();
    } else {
      _moveToNextPlayer();
    }
  }

  void _handleLastRoundValidation() {
    hasPlayedLastRound[currentPlayer] = true;
    if (hasPlayedLastRound.every((played) => played)) {
      _showFinalScores();
    } else {
      currentPlayer = hasPlayedLastRound.indexWhere((played) => !played);
      _resetCurrentPlayerTurn();
    }
  }

  void _moveToNextPlayer() {
    currentPlayer = (currentPlayer + 1) % players.length;
    _resetCurrentPlayerTurn();
  }

  void _resetCurrentPlayerTurn() {
    currentThrowsPerPlayer[currentPlayer] = [null, null, null];
    throwsLeft = 3;
  }

  void _startLastRound() {
    isLastRound = true;
    hasPlayedLastRound = List.generate(players.length, (index) => index <= currentPlayer);
    _moveToNextPlayer();
  }

  void _showFinalScores() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultPage(
          players: players,
          scores: playerScores,
          winner: firstFinisher!,
          gameType: GameType.score,
        ),
      ),
    );
  }

  void _handleLastRoundFinish() {
    hasPlayedLastRound[currentPlayer] = true;
    if (hasPlayedLastRound.every((played) => played)) {
      _showFinalScores();
    } else {
      currentPlayer = hasPlayedLastRound.indexWhere((played) => !played);
      _resetCurrentPlayerTurn();
    }
  }
} 