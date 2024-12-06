import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../models/player_model.dart';

class DartsResultPage extends StatefulWidget {
  final List<Player> players;
  final List<int> scores;
  final int winner;

  const DartsResultPage({
    super.key,
    required this.players,
    required this.scores,
    required this.winner,
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
                const Text(
                  'Tu es le grand gagnant ! 🎉',
                  style: TextStyle(
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
                          trailing: Text(
                            '${widget.scores[index]} points',
                            style: TextStyle(
                              fontSize: 18,
                              color: isWinner ? Colors.purple : Colors.black,
                            ),
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