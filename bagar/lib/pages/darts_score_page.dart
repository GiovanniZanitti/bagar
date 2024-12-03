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
            // Partie supérieure : Liste des joueurs et détails du joueur actif
            Expanded(
              flex: 4, // Partie supérieure (60 % de l'écran)
              child: Row(
                children: [
                  // Liste des joueurs
                  Expanded(
                    flex: 3,
                    child: SizedBox(
                      height: double.infinity,
                      child: ListView.builder(
                        itemCount: widget.players.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: ListTile(
                              title: Text(
                                widget.players[index].name,
                                style: const TextStyle(fontSize: 14),
                              ),
                              subtitle: Text(
                                'Score restant : ${playerScores[index]}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: index == currentPlayer ? Colors.blue : Colors.black,
                                  fontWeight: index == currentPlayer ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                              leading: Text(
                                widget.players[index].emoji,
                                style: const TextStyle(fontSize: 24),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // Détails du joueur actif
                  Expanded(
                    flex: 7,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Nom du joueur actif
                          Text(
                            widget.players[currentPlayer].name,
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),

                          // Score total
                          Text(
                            'Score total : ${playerScores[currentPlayer]}',
                            style: const TextStyle(fontSize: 20),
                          ),
                          const SizedBox(height: 16),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Première Row : Numéros des fléchettes
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: List.generate(3, (index) {
                                  return Text(
                                    'Fléchette ${index + 1}',
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  );
                                }),
                              ),
                              const SizedBox(height: 8), // Espacement entre les deux Row

                              // Deuxième Row : Scores associés (modifiables)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: List.generate(3, (index) {
                                  final throwScore = currentThrowsPerPlayer[currentPlayer][index];
                                  return GestureDetector(
                                    onTap: () => _editThrowScore(index), // Appelle la fonction pour modifier le score
                                    child: Text(
                                      '${throwScore ?? '-'}',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        decoration: TextDecoration.underline, // Met en évidence que le texte est cliquable
                                        color: Colors.blue, // Utilise une couleur différente pour les rendre identifiables
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ],
                          ),



                          // Score du tour
                          Text(
                            'Score du tour : ${currentThrowsPerPlayer[currentPlayer].where((score) => score != null).fold(0, (a, b) => a + (b ?? 0))}',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            Expanded(
              flex: 6,
              child:Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: ['Simple', 'Double', 'Triple'].map((label) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: activeMultiplier == label ? Colors.blue : Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              activeMultiplier = label;
                            });
                          },
                          child: Text(label),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 20),

                  // Ligne des scores spéciaux (25, 50)
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: () {
                            if (throwsLeft > 0) {
                              _addThrowScore(25);
                            }
                          },
                          child: const Text('25'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
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

                  // Grille des scores
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 5, // 5 boutons par ligne
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: 20,
                      itemBuilder: (context, index) {
                        final baseScore = index + 1;
                        final score = (activeMultiplier == 'Simple')
                            ? baseScore
                            : (activeMultiplier == 'Double')
                                ? baseScore * 2
                                : baseScore * 3;

                        return ElevatedButton(
                          onPressed: () {
                            if (throwsLeft > 0) {
                              _addThrowScore(score);
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

                ]
              )
            )
            // Ligne de boutons (Simple, Double, Triple)
            
          ],
        ),
      ),
    );
  }
}