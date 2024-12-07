import 'package:flutter/material.dart'; 
import 'darts_settings_page.dart';
import '../models/game_model.dart';

class GameDetailsPage extends StatelessWidget {
  final Game game;

  const GameDetailsPage({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(game.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  border: Border.all(color: Colors.orange, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'But du jeu :',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text(game.goal, style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 20),
                    const Text(
                      'Moyen d\'y arriver :',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text(game.method, style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 20),
                    const Text(
                      'Déroulement d\'un tour :',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text(game.turn, style: const TextStyle(fontSize: 16)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Bouton pour les jeux de type score (301, 401, 501)
              if (_isGameScoreCounter())
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DartsSettingsPage(
                          initialScore: game.initialScore,
                          gameName: game.name,
                        ),
                      ),
                    );
                  },
                  child: const Text('Lancer une partie'),
                ),
            ],
          ),
        ),
      ),
    );
  }


  bool _isGameScoreCounter() {
    return game.scoreCounter;
  }

}
