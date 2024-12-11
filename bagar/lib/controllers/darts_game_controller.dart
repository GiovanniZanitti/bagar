import 'package:flutter/material.dart';
import '../models/player_model.dart';
import '../pages/result_page.dart';

class DartsGameController {
  final List<Player> players;
  final int initialScore;
  final BuildContext context;
  final VoidCallback onStateChanged;
  
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
    required this.onStateChanged,
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
                // Restaurer le score du début du tour
                playerScores[currentPlayer] = initialRoundScores[currentPlayer];
                _resetCurrentPlayerTurn();
                
                // Si c'est le dernier tour, marquer le joueur comme ayant joué
                if (isLastRound) {
                  hasPlayedLastRound[currentPlayer] = true;
                  // Vérifier si c'était le dernier joueur
                  if (hasPlayedLastRound.every((played) => played)) {
                    _showFinalScores();
                    return;
                  }
                }
                
                // Passer au joueur suivant
                _moveToNextPlayer();
                onStateChanged();
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
      firstFinisher = currentPlayer;
      _startLastRound();
    } else {
      hasPlayedLastRound[currentPlayer] = true;
      if (hasPlayedLastRound.every((played) => played)) {
        _showFinalScores();
      } else {
        _moveToNextPlayer();
      }
    }
    onStateChanged();
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
    onStateChanged();
  }

  void _handleLastRoundValidation() {
    hasPlayedLastRound[currentPlayer] = true;
    
    if (hasPlayedLastRound.every((played) => played)) {
      _showFinalScores();
    } else {
      int nextPlayer = (currentPlayer + 1) % players.length;
      while (hasPlayedLastRound[nextPlayer]) {
        nextPlayer = (nextPlayer + 1) % players.length;
      }
      currentPlayer = nextPlayer;
      _resetCurrentPlayerTurn();
    }
  }

  void _moveToNextPlayer() {
    currentPlayer = (currentPlayer + 1) % players.length;
    initialRoundScores[currentPlayer] = playerScores[currentPlayer];
    _resetCurrentPlayerTurn();
  }

  void _resetCurrentPlayerTurn() {
    currentThrowsPerPlayer[currentPlayer] = [null, null, null];
    throwsLeft = 3;
  }

  void _startLastRound() {
    isLastRound = true;
    
    // Initialiser tous les joueurs comme ayant déjà joué
    hasPlayedLastRound = List.generate(players.length, (_) => true);
    
    // Donner un dernier tour uniquement aux joueurs qui suivent le firstFinisher
    for (int i = currentPlayer + 1; i < players.length; i++) {
      hasPlayedLastRound[i] = false;  // Ces joueurs n'ont pas encore joué leur dernier tour
    }
    
    final remainingPlayers = players
        .asMap()
        .entries
        .where((entry) => entry.key > currentPlayer)
        .map((entry) => entry.value.name)
        .join(', ');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Dernier tour !'),
          content: Text(
            remainingPlayers.isNotEmpty
                ? '${players[currentPlayer].name} est arrivé à 0 !\n\n'
                  'Les joueurs suivants ont une dernière chance : $remainingPlayers'
                : '${players[currentPlayer].name} est arrivé à 0 !\n\n'
                  'Aucun autre joueur ne peut jouer dans ce tour.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (remainingPlayers.isNotEmpty) {
                  _moveToNextPlayer();
                } else {
                  _showFinalScores();
                }
                onStateChanged();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showFinalScores() {
    // Créer une liste de tuples (joueur, score, index) pour le tri
    final playerScoresList = List.generate(
      players.length,
      (index) => (
        player: players[index], 
        score: playerScores[index],
        originalIndex: index,
      ),
    );

    // Trier la liste par score croissant
    playerScoresList.sort((a, b) => a.score.compareTo(b.score));

    // Créer les listes triées
    final sortedPlayers = playerScoresList.map((e) => e.player).toList();
    final sortedScores = playerScoresList.map((e) => e.score).toList();

    // Trouver le nouvel index du gagnant dans la liste triée
    final newWinnerIndex = playerScoresList.indexWhere((p) => p.originalIndex == firstFinisher);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultPage(
          players: sortedPlayers,
          scores: sortedScores,
          winner: newWinnerIndex,  // Utilisation du nouvel index
          gameType: GameType.score,
        ),
      ),
    );
  }

  void updateThrowScore(int throwIndex, int newScore) {
    currentThrowsPerPlayer[currentPlayer][throwIndex] = newScore;
    
    // Recalculer le score total du joueur
    playerScores[currentPlayer] = initialRoundScores[currentPlayer];
    for (int i = 0; i <= throwIndex; i++) {
      final score = currentThrowsPerPlayer[currentPlayer][i];
      if (score != null) {
        playerScores[currentPlayer] -= score;
      }
    }
    
    onStateChanged();
  }
} 