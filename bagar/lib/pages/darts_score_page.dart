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
  late List<int> playerScores; // Liste des scores de chaque joueur
  late int currentPlayer; // Index du joueur actif
  List<List<int?>> currentThrowsPerPlayer = [];
  int throwsLeft = 3; // Nombre de fléchettes restantes pour le joueur actif
  String activeMultiplier = 'Simple';

  @override
  void initState() {
    super.initState();
    playerScores = List.generate(widget.players.length, (_) => widget.initialScore);
    currentThrowsPerPlayer = List.generate(widget.players.length, (_) => [null, null, null]); // Initialisation
    currentPlayer = 0;
  }

  void _addThrowScore(int score) {
    if (throwsLeft > 0) {
      setState(() {
        currentThrowsPerPlayer[currentPlayer][3 - throwsLeft] = score; // Ajoute ou remplace le score
        throwsLeft--;

        // Recalcule le score total en fonction des fléchettes actuelles
        final roundScore = currentThrowsPerPlayer[currentPlayer]
            .where((score) => score != null)
            .fold(0, (a, b) => a + (b ?? 0));
        playerScores[currentPlayer] = widget.initialScore - roundScore;
      });
    }
  }

  void _validateScore() {
    setState(() {
      // Passe au joueur suivant
      currentPlayer = (currentPlayer + 1) % widget.players.length;

      // Réinitialise les fléchettes pour le joueur suivant
      currentThrowsPerPlayer[currentPlayer] = [null, null, null];
      throwsLeft = 3;
    });
  }

  void _editThrowScore(int index) {
    final TextEditingController controller = TextEditingController();

    showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Modifier le score de la fléchette ${index + 1}'),
          content: TextField(
            controller: controller, // Utilise un contrôleur pour récupérer la saisie
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Nouveau score'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Ferme la boîte de dialogue sans valider
              },
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                final newScore = int.tryParse(controller.text); // Convertit la saisie en entier
                Navigator.pop(context, newScore); // Retourne le score à la fonction appelante
              },
              child: const Text('Valider'),
            ),
          ],
        );
      },
    ).then((newScore) {
      if (newScore != null) {
        setState(() {
          currentThrowsPerPlayer[currentPlayer][index] = newScore;

          // Recalcule le score total en fonction des fléchettes actuelles
          final roundScore = currentThrowsPerPlayer[currentPlayer]
              .where((score) => score != null)
              .fold(0, (a, b) => a + (b ?? 0));
          playerScores[currentPlayer] = widget.initialScore - roundScore;
        });
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
            // Tableau des scores
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Joueur')),
                    DataColumn(label: Text('1')),
                    DataColumn(label: Text('2')),
                    DataColumn(label: Text('3')),
                    DataColumn(label: Text('Score du tour')),
                    DataColumn(label: Text('Score total')),
                  ],
                  rows: List<DataRow>.generate(
                    widget.players.length,
                    (index) {
                      final isCurrentPlayer = index == currentPlayer;

                      return DataRow(
                        cells: [
                          DataCell(
                            Row(
                              children: [
                                Text(widget.players[index].emoji,
                                    style: const TextStyle(fontSize: 20)),
                                const SizedBox(width: 8),
                                Text(widget.players[index].name),
                              ],
                            ),
                          ),
                          DataCell(_editableThrowCell(0, isCurrentPlayer)),
                          DataCell(_editableThrowCell(1, isCurrentPlayer)),
                          DataCell(_editableThrowCell(2, isCurrentPlayer)),
                          DataCell(Text(
                            isCurrentPlayer
                                ? '${currentThrowsPerPlayer[currentPlayer].where((score) => score != null).fold(0, (a, b) => a + (b ?? 0))}'
                                : '-',
                          )),
                          DataCell(Text('${playerScores[index]}')),
                        ],
                      );
                    },
                  ),
                )
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center, // Centre la ligne de boutons
              children: ['Simple', 'Double', 'Triple'].map((label) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0), // Espacement entre les boutons
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: activeMultiplier == label ? Colors.blue : Colors.grey, // Change la couleur du bouton actif
                    ),
                    onPressed: () {
                      setState(() {
                        activeMultiplier = label; // Met à jour le bouton actif
                      });
                    },
                    child: Text(label),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16), // Ajuste la hauteur du bouton
                    ),
                    onPressed: () {
                      if (throwsLeft > 0) {
                        _addThrowScore(25);
                      }
                    },
                    child: const Text('25'),
                  ),
                ),
                const SizedBox(width: 10), // Espace entre les boutons
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16), // Ajuste la hauteur du bouton
                    ),
                    onPressed: () {
                      if (throwsLeft > 0) {
                        _addThrowScore(50);
                      }
                    },
                    child: const Text('50'),
                  ),
                ),
              ],
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
                itemCount: 20, // Scores possibles (1 à 20, 25, 50)
                itemBuilder: (context, index) {
                  final baseScore =  index + 1;
                  final score = (activeMultiplier == 'Simple')
                      ? baseScore
                      : (activeMultiplier == 'Double')
                          ? baseScore * 2
                          : baseScore * 3;

                  return ElevatedButton(
                    onPressed: () {
                      if (throwsLeft > 0) {
                        _addThrowScore(score); // Ajoute le score modifié
                      }
                    },
                    child: Text('$score'),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // Bouton Valider
            ElevatedButton(
              onPressed: () {
                if (throwsLeft == 0) {
                  _validateScore();
                }
              },
              child: const Text('Valider'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _editableThrowCell(int index, bool isCurrentPlayer) {
    // Retourne un tiret pour les joueurs non actifs
    if (!isCurrentPlayer) {
      return const Text('-');
    }

    final score = currentThrowsPerPlayer[currentPlayer][index];
    return GestureDetector(
      onTap: () => _editThrowScore(index), // Permet d'éditer uniquement pour le joueur actif
      child: Text(
        score != null ? '$score' : '-',
        style: TextStyle(
          color: Colors.blue,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

}
