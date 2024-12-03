import 'package:flutter/material.dart';
import '../models/player_model.dart';

class DartsScorePage extends StatefulWidget {
  final List<Player> players;
  final int initialScore;

  const DartsScorePage({
    super.key,
    required this.players,
    required this.initialScore,
  });

  @override
  _DartsScorePageState createState() => _DartsScorePageState();
}

class _DartsScorePageState extends State<DartsScorePage> {
  late List<int> playerScores; // Liste des scores
  late int currentPlayer; // Index du joueur actif
  int throwsLeft = 3; // Nombre de fléchettes restantes pour le joueur actif

  @override
  void initState() {
    super.initState();
    playerScores = List.generate(widget.players.length, (_) => widget.initialScore);
    currentPlayer = 0;
  }

  void _updateScore(int score) {
    setState(() {
      playerScores[currentPlayer] -= score;
      if (playerScores[currentPlayer] < 0) {
        playerScores[currentPlayer] = 0; // Empêche le score négatif
      }
      throwsLeft--;
      if (throwsLeft == 0) {
        // Passe au joueur suivant
        throwsLeft = 3;
        currentPlayer = (currentPlayer + 1) % widget.players.length;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compteur de points'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Affiche les scores des joueurs
            ListView.builder(
              shrinkWrap: true,
              itemCount: widget.players.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Text(
                    widget.players[index].emoji,
                    style: const TextStyle(fontSize: 32),
                  ),
                  title: Text(
                    '${widget.players[index].name} : ${playerScores[index]} points',
                    style: TextStyle(
                      fontWeight: index == currentPlayer ? FontWeight.bold : FontWeight.normal,
                      color: index == currentPlayer ? Colors.blue : Colors.black,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            Text(
              'Joueur actuel : ${widget.players[currentPlayer].name}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Fléchettes restantes : $throwsLeft',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            // Boutons pour chaque score possible
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5, // 5 boutons par ligne
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: 22, // Scores possibles (1 à 20, 25, 50)
                itemBuilder: (context, index) {
                  final score = (index < 20) ? index + 1 : (index == 20 ? 25 : 50);
                  return ElevatedButton(
                    onPressed: () => _updateScore(score),
                    child: Text('$score'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
