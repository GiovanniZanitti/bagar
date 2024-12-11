import 'package:flutter/material.dart';
import '../models/player_model.dart';
import 'result_page.dart';
class KillerPlayer extends Player {
  int lives;
  int? targetNumber;
  bool isKiller;
  bool hasReachedMaxLives;
  static const int maxLives = 5;
  int selfHits = 0;    // Nouveau : nombre de fois où il s'est touché
  int otherHits = 0;   // Nouveau : nombre de fois où il a touché les autres
  bool isEliminated = false;  // Nouvelle propriété
  bool isInLastChance = false;  // Add this new property

  KillerPlayer({
    required Player player,
    this.lives = 1,
    this.targetNumber,
    this.isKiller = false,
    this.hasReachedMaxLives = false,
    this.isEliminated = false,
    this.isInLastChance = false,  // Add to constructor
  }) : super(
          name: player.name,
          emoji: player.emoji,
        );
}

class KillerScorePage extends StatefulWidget {
  final List<Player> players;

  const KillerScorePage({
    super.key,
    required this.players,
  });

  @override
  State<KillerScorePage> createState() => _KillerScorePageState();
}

class _KillerScorePageState extends State<KillerScorePage> {
  late List<KillerPlayer> killerPlayers;
  bool isSelectingTargets = true;
  int _currentPlayerIndex = 0;
  late List<int> _lives;
  List<String> gameEvents = [];

  @override
  void initState() {
    super.initState();
    killerPlayers = widget.players
        .map((player) => KillerPlayer(player: player))
        .toList();
    _lives = List.filled(widget.players.length, 3);
  }


  void _nextTurn() {
    setState(() {
      final currentPlayer = killerPlayers[_currentPlayerIndex];
      
      if (currentPlayer.isInLastChance) {
        if (currentPlayer.lives == 0) {
          currentPlayer.isInLastChance = false;
          currentPlayer.isEliminated = true;
          _showGameEvent('${currentPlayer.name} est éliminé !');
        } else {
          currentPlayer.isInLastChance = false;
          _showGameEvent('${currentPlayer.name} s\'est sauvé !');
        }
      }

      do {
        _currentPlayerIndex = (_currentPlayerIndex + 1) % killerPlayers.length;
      } while (killerPlayers[_currentPlayerIndex].isEliminated);

      if (_checkGameOver()) {
        _showWinnerDialog();
      }
    });
  }

  void _selectTargetNumber(int number) {
    if (killerPlayers.any((player) => player.targetNumber == number)) {
      _showGameEvent('Ce numéro est déjà pris !');
      return;
    }

    setState(() {
      killerPlayers[_currentPlayerIndex].targetNumber = number;
      
      _currentPlayerIndex = (_currentPlayerIndex + 1) % widget.players.length;
      
      if (killerPlayers.every((player) => player.targetNumber != null)) {
        isSelectingTargets = false;
      }
    });
  }



  bool _checkGameOver() {
    int playersAlive = 0;
    for (KillerPlayer player in killerPlayers) {
      if (!player.isEliminated) {
        playersAlive++;
      }
    }
    return playersAlive == 1;
  }

  void _showWinnerDialog() {
    int winner = 0;
    for (int i = 0; i < killerPlayers.length; i++) {
      if (!killerPlayers[i].isEliminated) {
        winner = i;
        break;
      }
    }

    List<int> killerHits = killerPlayers.map((p) => p.otherHits).toList();
    List<int> selfHits = killerPlayers.map((p) => p.selfHits).toList();

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => ResultPage(
          players: widget.players,
          scores: _lives,
          winner: winner,
          gameType: GameType.killer,
          killerHits: killerHits,
          selfHits: selfHits,
        ),
      ),
    );
  }

  void _showGameEvent(String message) {
    setState(() {
      gameEvents.add(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isSelectingTargets 
          ? 'Choisissez vos numéros' 
          : 'Killer - Tour de ${killerPlayers[_currentPlayerIndex].name}'),
      ),
      body: Column(
        children: [
          Container(
            height: 150,
            margin: const EdgeInsets.all(8),
            child: Card(
              color: Colors.blue.shade50,
              child: gameEvents.isEmpty
                  ? const Center(
                      child: Text(
                        'Les événements de la partie apparaîtront ici',
                        style: TextStyle(
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    )
                  : ListView.builder(
                      reverse: true,
                      itemCount: gameEvents.length,
                      itemBuilder: (context, index) {
                        final event = gameEvents[gameEvents.length - 1 - index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.event_note, 
                                color: Colors.blue,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  event,
                                  style: const TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ),
          
          Expanded(
            flex: 2,
            child: ListView.builder(
              itemCount: killerPlayers.length,
              itemBuilder: (context, index) {
                final player = killerPlayers[index];
                final isCurrentPlayer = index == _currentPlayerIndex && !isSelectingTargets;
                return Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * (isCurrentPlayer ? 1.0 : 0.8),
                    child: Card(
                      margin: const EdgeInsets.all(8),
                      color: player.lives == 0 
                          ? Colors.grey.shade200
                          : isCurrentPlayer
                              ? Colors.blue.shade100
                              : null,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Opacity(
                              opacity: player.lives == 0 ? 0.5 : 1.0,
                              child: Text(
                                player.emoji,
                                style: const TextStyle(fontSize: 32),
                              ),
                            ),
                            const SizedBox(width: 16),
                            
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        player.name,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: player.lives == 0 ? Colors.grey : Colors.black,
                                          decoration: player.isEliminated ? TextDecoration.lineThrough : null,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: player.isEliminated 
                                          ? Colors.red.shade100
                                          : player.isInLastChance 
                                              ? Colors.orange.shade100
                                              : Colors.green.shade100,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      player.isEliminated
                                          ? 'Éliminé'
                                          : player.isInLastChance
                                              ? 'Dernière chance !'
                                              : 'En jeu',
                                      style: TextStyle(
                                        color: player.isEliminated
                                            ? Colors.red
                                            : player.isInLastChance
                                                ? Colors.deepOrange
                                                : Colors.green,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: player.lives == 0 
                                              ? Colors.grey.shade300 
                                              : Colors.blue.shade100,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          'Numéro: ${player.targetNumber ?? "?"}',
                                          style: TextStyle(
                                            color: player.lives == 0 ? Colors.grey : Colors.black,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: player.lives == 0 
                                              ? Colors.grey.shade300
                                              : player.isKiller
                                                  ? Colors.red.shade100
                                                  : Colors.grey.shade200,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          player.isKiller ? 'Killer' : 'Non Killer',
                                          style: TextStyle(
                                            color: player.lives == 0 ? Colors.grey : Colors.black,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (!isSelectingTargets)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.favorite,
                                            size: 16,
                                            color: player.lives == 0 ? Colors.grey : Colors.blue,
                                          ),
                                          Text(
                                            ' ${player.selfHits}',
                                            style: TextStyle(
                                              color: player.lives == 0 ? Colors.grey : Colors.blue,
                                              fontSize: 12,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Icon(
                                            Icons.gps_fixed,
                                            size: 16,
                                            color: player.lives == 0 ? Colors.grey : Colors.red,
                                          ),
                                          Text(
                                            ' ${player.otherHits}',
                                            style: TextStyle(
                                              color: player.lives == 0 ? Colors.grey : Colors.red,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  children: List.generate(
                                    KillerPlayer.maxLives,
                                    (lifeIndex) => Icon(
                                      Icons.favorite,
                                      color: lifeIndex < player.lives
                                          ? Colors.red
                                          : Colors.grey.shade300,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (killerPlayers[_currentPlayerIndex].isKiller && index != _currentPlayerIndex)
                                      IconButton(
                                        icon: const Icon(Icons.remove_circle),
                                        color: Colors.red,
                                        onPressed: player.lives > 0
                                            ? () {
                                                setState(() {
                                                  player.lives--;
                                                  killerPlayers[_currentPlayerIndex].otherHits++;
                                                  if (player.lives == 0 && !player.isInLastChance) {
                                                    player.isInLastChance = true;
                                                    _showGameEvent('${player.name} a une dernière chance !');
                                                  }
                                                });
                                              }
                                            : null,
                                      ),
                                    
                                    if (index == _currentPlayerIndex)
                                      IconButton(
                                        icon: const Icon(Icons.add_circle),
                                        color: Colors.green,
                                        onPressed: player.lives < KillerPlayer.maxLives
                                            ? () {
                                                setState(() {
                                                  player.lives++;
                                                  player.selfHits++;
                                                  
                                                  if (player.lives == KillerPlayer.maxLives && !player.hasReachedMaxLives) {
                                                    player.hasReachedMaxLives = true;
                                                    player.isKiller = true;
                                                    _showGameEvent('${player.name} devient Killer !');
                                                  }
                                                });
                                              }
                                            : null,
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          if (isSelectingTargets) ...[
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              color: Colors.grey.shade100,
              child: Text(
                'Au tour de ${killerPlayers[_currentPlayerIndex].name} de choisir un numéro',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            Container(
              height: 200,
              padding: const EdgeInsets.all(8),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                  childAspectRatio: 1.5,
                ),
                itemCount: 20,
                itemBuilder: (context, index) {
                  final number = index + 1;
                  final isUsed = killerPlayers.any((player) => player.targetNumber == number);
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isUsed ? Colors.grey : Colors.blue,
                      padding: EdgeInsets.zero,
                    ),
                    onPressed: isUsed ? null : () => _selectTargetNumber(number),
                    child: Text(
                      '$number',
                      style: const TextStyle(fontSize: 14),
                    ),
                  );
                },
              ),
            ),
          ],

          if (!isSelectingTargets)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: _nextTurn,
                child: const Text('Tour suivant',style: TextStyle(color: Colors.white)),
              ),
            ),
        ],
      ),
    );
  }
} 