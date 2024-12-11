import 'package:flutter/material.dart';
import '../models/player_model.dart';
import 'result_page.dart';
import 'dart:math';

// Énumération des catégories de score
enum YamsCategory {
  ones,
  twos,
  threes,
  fours,
  fives,
  sixes,
  threeOfAKind,
  fourOfAKind,
  fullHouse,
  smallStraight,
  largeStraight,
  yahtzee,
  chance,
}

// Extension pour obtenir le nom français et la description de chaque catégorie
extension YamsCategoryExtension on YamsCategory {
  String get name {
    switch (this) {
      case YamsCategory.ones: return '1 (As)';
      case YamsCategory.twos: return '2 (Deux)';
      case YamsCategory.threes: return '3 (Trois)';
      case YamsCategory.fours: return '4 (Quatre)';
      case YamsCategory.fives: return '5 (Cinq)';
      case YamsCategory.sixes: return '6 (Six)';
      case YamsCategory.threeOfAKind: return 'Brelan';
      case YamsCategory.fourOfAKind: return 'Carré';
      case YamsCategory.fullHouse: return 'Full';
      case YamsCategory.smallStraight: return 'Petite Suite';
      case YamsCategory.largeStraight: return 'Grande Suite';
      case YamsCategory.yahtzee: return 'Yams';
      case YamsCategory.chance: return 'Chance';
    }
  }

  String get description {
    switch (this) {
      case YamsCategory.ones: return 'Total des 1';
      case YamsCategory.twos: return 'Total des 2';
      case YamsCategory.threes: return 'Total des 3';
      case YamsCategory.fours: return 'Total des 4';
      case YamsCategory.fives: return 'Total des 5';
      case YamsCategory.sixes: return 'Total des 6';
      case YamsCategory.threeOfAKind: return '3 dés identiques';
      case YamsCategory.fourOfAKind: return '4 dés identiques';
      case YamsCategory.fullHouse: return '3 dés identiques + 2 dés identiques';
      case YamsCategory.smallStraight: return 'Suite de 4 dés';
      case YamsCategory.largeStraight: return 'Suite de 5 dés';
      case YamsCategory.yahtzee: return '5 dés identiques';
      case YamsCategory.chance: return 'Total de tous les dés';
    }
  }
}

class YamsScorePage extends StatefulWidget {
  final List<Player> players;

  const YamsScorePage({
    super.key,
    required this.players,
  });

  @override
  State<YamsScorePage> createState() => _YamsScorePageState();
}

class _YamsScorePageState extends State<YamsScorePage> {
  late Map<Player, Map<YamsCategory, int?>> scores;
  Set<Player> expandedPlayers = {};
  
  @override
  void initState() {
    super.initState();
    scores = {
      for (var player in widget.players)
        player: {
          for (var category in YamsCategory.values)
            category: null,
        },
    };
  }

  int getUpperSectionScore(Player player) {
    int sum = 0;
    for (var category in [
      YamsCategory.ones,
      YamsCategory.twos,
      YamsCategory.threes,
      YamsCategory.fours,
      YamsCategory.fives,
      YamsCategory.sixes,
    ]) {
      sum += scores[player]![category] ?? 0;
    }
    return sum;
  }

  int getBonus(Player player) {
    return getUpperSectionScore(player) >= 63 ? 35 : 0;
  }

  int getTotalScore(Player player) {
    int sum = 0;
    scores[player]!.forEach((category, score) {
      sum += score ?? 0;
    });
    return sum + getBonus(player);
  }

  // Vérifie si toutes les grilles sont remplies
  bool _isGameComplete() {
    for (var playerScores in scores.values) {
      for (var score in playerScores.values) {
        if (score == null) return false;
      }
    }
    return true;
  }

  // Affiche la page de résultats
  void _showResults() {
    // Créer la liste des scores finaux
    List<int> finalScores = widget.players.map((player) => getTotalScore(player)).toList();
    
    // Trouver l'index du gagnant (score le plus élevé)
    int winnerIndex = 0;
    int maxScore = finalScores[0];
    for (int i = 1; i < finalScores.length; i++) {
      if (finalScores[i] > maxScore) {
        maxScore = finalScores[i];
        winnerIndex = i;
      }
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => ResultPage(
          players: widget.players,
          scores: finalScores,
          winner: winnerIndex,
          gameType: GameType.yams,
        ),
      ),
    );
  }

  // Modification de la méthode existante pour vérifier si le jeu est terminé
  void _onScoreEntered(Player player, YamsCategory category, int score) {
    setState(() {
      scores[player]![category] = score;
      
      // Vérifie si le jeu est terminé après chaque entrée de score
      if (_isGameComplete()) {
        _showResults();
      }
    });
  }

  Widget _buildScoreGrid(Player player) {
    final items = [
      ...YamsCategory.values.map((category) => GridItem(
        title: category.name,
        description: category.description,
        value: scores[player]![category]?.toString() ?? '-',
        onTap: scores[player]![category] == null
            ? () async {
                final result = await showDialog<int>(
                  context: context,
                  builder: (context) => ScoreInputDialog(
                    category: category,
                    playerName: player.name,
                  ),
                );
                if (result != null) {
                  _onScoreEntered(player, category, result);  // Utilisation de la nouvelle méthode
                }
              }
            : null,
      )),
      GridItem(
        title: 'Bonus (≥63 pts = +35)',
        value: getBonus(player).toString(),
        isBonus: true,
      ),
      GridItem(
        title: 'TOTAL',
        value: getTotalScore(player).toString(),
        isTotal: true,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1.5,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return Card(
            color: item.isTotal 
                ? Colors.green.shade50 
                : item.isBonus 
                    ? Colors.blue.shade50 
                    : null,
            child: InkWell(
              onTap: item.onTap,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            item.title,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: item.isTotal ? 14 : 12,
                            ),
                          ),
                        ),
                        if (!item.isBonus && !item.isTotal) ...[
                          const SizedBox(width: 4),
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: const Icon(Icons.info_outline, size: 14),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text(item.title),
                                  content: Text(item.description ?? ''),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('OK'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.value,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: item.isTotal ? Colors.green.shade700 : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _togglePlayer(Player player) {
    setState(() {
      if (expandedPlayers.contains(player)) {
        expandedPlayers.clear();
      } else {
        expandedPlayers.clear();
        expandedPlayers.add(player);
      }
    });
  }

  // Méthode pour simuler une partie
  void _simulateGame() {
    setState(() {
      for (var player in widget.players) {
        // Section supérieure (1 à 6)
        scores[player]![YamsCategory.ones] = _generateScore(1 * 5);  // max 5 dés de 1
        scores[player]![YamsCategory.twos] = _generateScore(2 * 5);  // max 5 dés de 2
        scores[player]![YamsCategory.threes] = _generateScore(3 * 5);
        scores[player]![YamsCategory.fours] = _generateScore(4 * 5);
        scores[player]![YamsCategory.fives] = _generateScore(5 * 5);
        scores[player]![YamsCategory.sixes] = _generateScore(6 * 5);

        // Section inférieure
        scores[player]![YamsCategory.threeOfAKind] = _generateScore(30);
        scores[player]![YamsCategory.fourOfAKind] = _generateScore(30);
        scores[player]![YamsCategory.fullHouse] = _generateScore(25);
        scores[player]![YamsCategory.smallStraight] = _generateScore(30);
        scores[player]![YamsCategory.largeStraight] = _generateScore(40);
        scores[player]![YamsCategory.yahtzee] = _generateScore(50);
        scores[player]![YamsCategory.chance] = _generateScore(30);
      }
      
      // Vérifie si le jeu est terminé après la simulation
      if (_isGameComplete()) {
        _showResults();
      }
    });
  }

  // Génère un score aléatoire entre 0 et maxScore
  int _generateScore(int maxScore) {
    return (maxScore * (0.3 + 0.7 * (DateTime.now().millisecondsSinceEpoch % 100 + Random().nextInt(100)) / 200)).round();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Score du Yams'),
        actions: [
          // Ajout du bouton de simulation dans l'AppBar
          IconButton(
            icon: const Icon(Icons.casino),
            onPressed: _simulateGame,
            tooltip: 'Simuler une partie',
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: widget.players.length,
        itemBuilder: (context, index) {
          final player = widget.players[index];
          return Column(
            children: [
              Card(
                margin: const EdgeInsets.all(8),
                child: InkWell(
                  onTap: () => _togglePlayer(player),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Text(
                          player.emoji,
                          style: const TextStyle(fontSize: 32),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                player.name,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Score total: ${getTotalScore(player)}',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          expandedPlayers.contains(player)
                              ? Icons.expand_less
                              : Icons.expand_more,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (expandedPlayers.contains(player))
                _buildScoreGrid(player),
            ],
          );
        },
      ),
    );
  }
}

class ScoreInputDialog extends StatefulWidget {
  final YamsCategory category;
  final String playerName;

  const ScoreInputDialog({
    super.key,
    required this.category,
    required this.playerName,
  });

  @override
  State<ScoreInputDialog> createState() => _ScoreInputDialogState();
}

class _ScoreInputDialogState extends State<ScoreInputDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Score pour ${widget.playerName}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.category.name),
          Text(
            widget.category.description,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Score',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        TextButton(
          onPressed: () {
            final score = int.tryParse(_controller.text);
            if (score != null) {
              Navigator.pop(context, score);
            }
          },
          child: const Text('Valider'),
        ),
      ],
    );
  }
}

// Classe utilitaire pour représenter un élément de la grille
class GridItem {
  final String title;
  final String? description;
  final String value;
  final VoidCallback? onTap;
  final bool isBonus;
  final bool isTotal;

  GridItem({
    required this.title,
    this.description,
    required this.value,
    this.onTap,
    this.isBonus = false,
    this.isTotal = false,
  });
} 