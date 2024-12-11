import 'package:flutter/material.dart';
import '../models/player_model.dart';
import '../widgets/gradient_background.dart';
import 'result_page.dart';

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
  late List<int> playerScores;
  late int currentPlayer;
  List<List<int?>> currentThrowsPerPlayer = [];
  int throwsLeft = 3;
  String activeMultiplier = 'Simple';
  late List<int> initialRoundScores;
  bool isLastRound = false;
  int? firstFinisher;
  late List<bool> hasPlayedLastRound;

  @override
  void initState() {
    super.initState();
    playerScores = List.generate(widget.players.length, (_) => widget.initialScore);
    currentThrowsPerPlayer = List.generate(widget.players.length, (_) => [null, null, null]);
    currentPlayer = 0;
    initialRoundScores = List.from(playerScores);
    hasPlayedLastRound = List.generate(widget.players.length, (_) => false);
  }

  void _showFinalScores() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultPage(
          players: widget.players,
          scores: playerScores,
          winner: firstFinisher!,
          gameType: GameType.score,
        ),
      ),
    );
  }

  void _addThrowScore(int score) {
    if (throwsLeft > 0) {
      final newScore = playerScores[currentPlayer] - score;
      if (newScore < 0) {
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
                    setState(() {
                      currentThrowsPerPlayer[currentPlayer] = [null, null, null];
                      playerScores[currentPlayer] = initialRoundScores[currentPlayer];
                      if (isLastRound) {
                        hasPlayedLastRound[currentPlayer] = true;
                        if (hasPlayedLastRound.every((played) => played)) {
                          _showFinalScores();
                        } else {
                          currentPlayer = (currentPlayer + 1) % widget.players.length;
                        }
                      } else {
                        currentPlayer = (currentPlayer + 1) % widget.players.length;
                      }
                      currentThrowsPerPlayer[currentPlayer] = [null, null, null];
                      throwsLeft = 3;
                    });
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      } else if (newScore == 0) {
        setState(() {
          currentThrowsPerPlayer[currentPlayer][3 - throwsLeft] = score;
          playerScores[currentPlayer] = newScore;
        });

        if (!isLastRound) {
          final remainingPlayers = widget.players
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
                  '${widget.players[currentPlayer].name} est le premier à finir !\n\n'
                  '${hasRemainingPlayers ? 'Les joueurs suivants ont encore une chance : $remainingPlayers' : 'Aucun autre joueur ne peut jouer dans ce tour.'}'
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      setState(() {
                        firstFinisher = currentPlayer;
                        if (hasRemainingPlayers) {
                          isLastRound = true;
                          hasPlayedLastRound = List.generate(widget.players.length, (index) => index <= currentPlayer);
                          currentPlayer = (currentPlayer + 1) % widget.players.length;
                          currentThrowsPerPlayer[currentPlayer] = [null, null, null];
                          throwsLeft = 3;
                        } else {
                          _showFinalScores();
                        }
                      });
                    },
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          );
        } else {
          setState(() {
            hasPlayedLastRound[currentPlayer] = true;
            if (hasPlayedLastRound.every((played) => played)) {
              _showFinalScores();
            } else {
              currentPlayer = (currentPlayer + 1) % widget.players.length;
              currentThrowsPerPlayer[currentPlayer] = [null, null, null];
              throwsLeft = 3;
            }
          });
        }
      } else {
        setState(() {
          currentThrowsPerPlayer[currentPlayer][3 - throwsLeft] = score;
          playerScores[currentPlayer] -= score;
          throwsLeft--;
        });
      }
    }
  }

  void _validateScore() {
    setState(() {
      initialRoundScores[currentPlayer] = playerScores[currentPlayer];
      if (isLastRound) {
        hasPlayedLastRound[currentPlayer] = true;
        if (hasPlayedLastRound.every((played) => played)) {
          _showFinalScores();
        } else {
          currentPlayer = hasPlayedLastRound.indexWhere((played) => !played);
        }
      } else {
        currentPlayer = (currentPlayer + 1) % widget.players.length;
      }
      currentThrowsPerPlayer[currentPlayer] = [null, null, null];
      throwsLeft = 3;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Compteur de points'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Détails du joueur actif
              Column(
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
                            '${index + 1}',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          );
                        }),
                      ),
                      const SizedBox(height: 8),

                      // Deuxième Row : Scores associés (modifiables)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(3, (index) {
                          final throwScore = currentThrowsPerPlayer[currentPlayer][index];
                          return GestureDetector(
                            onTap: () async {
                              final result = await showDialog<int>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('Score de la fléchette ${index + 1}'),
                                  content: TextField(
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      hintText: 'Entrez le score',
                                    ),
                                    onSubmitted: (value) => Navigator.of(context).pop(int.tryParse(value)),
                                  ),
                                ),
                              );
                              if (result != null) {
                                setState(() {
                                  currentThrowsPerPlayer[currentPlayer][index] = result;
                                });
                              }
                            },
                            child: Text(
                              '${throwScore ?? '-'}',
                              style: const TextStyle(
                                fontSize: 18,
                                decoration: TextDecoration.underline,
                                color: Colors.blue,
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

              const SizedBox(height: 20),

              // Classement des joueurs
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Classement',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(
                          widget.players.length,
                          (index) => Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Card(
                              elevation: 2,
                              color: index == currentPlayer 
                                  ? Colors.blue.withOpacity(0.1) 
                                  : Colors.white,
                              child: Container(
                                width: 100,
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      widget.players[index].emoji,
                                      style: const TextStyle(fontSize: 24),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      widget.players[index].name,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: index == currentPlayer 
                                            ? FontWeight.bold 
                                            : FontWeight.normal,
                                      ),
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${playerScores[index]}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: index == currentPlayer 
                                            ? FontWeight.bold 
                                            : FontWeight.normal,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Partie inférieure (clavier de score) reste inchangée
              Expanded(
                child: Column(
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
                                _addThrowScore(0);
                              }
                            },
                            child: const Text('0'),
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
