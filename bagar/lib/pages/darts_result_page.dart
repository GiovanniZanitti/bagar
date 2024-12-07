import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../models/player_model.dart';

enum GameType { score, killer }

class DartsResultPage extends StatefulWidget {
  final List<Player> players;
  final List<int> scores;  // Pour les jeux de score (301/401/501)
  final int winner;
  final GameType gameType;
  final List<int>? killerHits;    // Pour le Killer (nombre de kills)
  final List<int>? selfHits;      // Pour le Killer (nombre de self-hits)

  const DartsResultPage({
    super.key,
    required this.players,
    required this.scores,
    required this.winner,
    required this.gameType,
    this.killerHits,
    this.selfHits,
  });

  @override
  _DartsResultPageState createState() => _DartsResultPageState();
}

class _DartsResultPageState extends State<DartsResultPage> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 10));
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  String _getTrailingText(int index) {
    if (widget.gameType == GameType.score) {
      return '${widget.scores[index]} points';
    } else {
      return '${widget.killerHits![index]}  ${const Icon(Icons.gps_fixed, size: 16)} - ${widget.selfHits![index]} ${const Icon(Icons.favorite, size: 16)}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final winnerPlayer = widget.players[widget.winner];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Résultats'),
        backgroundColor: Colors.purple,
      ),
      body: Stack(
        children: [
          // Confetti animation
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: true,
              colors: const [Colors.red, Colors.blue, Colors.green, Colors.yellow, Colors.purple],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  'Félicitations ${winnerPlayer.name} !',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Text(
                  widget.gameType == GameType.score
                      ? 'Tu es le grand gagnant ! 🎉'
                      : 'Tu es le dernier survivant ! 💀',
                  style: const TextStyle(
                    fontSize: 24,
                    color: Colors.orange,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                Expanded(
                  child: ListView.builder(
                    itemCount: widget.players.length,
                    itemBuilder: (context, index) {
                      final isWinner = index == widget.winner;
                      return Card(
                        elevation: isWinner ? 8 : 2,
                        color: isWinner ? Colors.orange.shade100 : Colors.white,
                        child: ListTile(
                          leading: Text(
                            widget.players[index].emoji,
                            style: const TextStyle(fontSize: 24),
                          ),
                          title: Text(
                            widget.players[index].name,
                            style: TextStyle(
                              fontWeight: isWinner ? FontWeight.bold : FontWeight.normal,
                              color: isWinner ? Colors.purple : Colors.black,
                            ),
                          ),
                          trailing: widget.gameType == GameType.score
                              ? Text(
                                  '${widget.scores[index]} points',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: isWinner ? Colors.purple : Colors.black,
                                  ),
                                )
                              : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${widget.killerHits![index]}',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: isWinner ? Colors.purple : Colors.black,
                                      ),
                                    ),
                                    Icon(Icons.gps_fixed, size: 16, color: isWinner ? Colors.purple : Colors.black),
                                    Text(
                                      ' - ${widget.selfHits![index]}',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: isWinner ? Colors.purple : Colors.black,
                                      ),
                                    ),
                                    Icon(Icons.favorite, size: 16, color: isWinner ? Colors.purple : Colors.black),
                                  ],
                                ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                  ),
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  child: const Text(
                    'Retour au menu principal',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 