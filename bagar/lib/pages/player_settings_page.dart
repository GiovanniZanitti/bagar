import 'package:flutter/material.dart';
import '../models/player_model.dart';
import '../widgets/gradient_background.dart';
import 'darts_score_page.dart';
import 'killer_score_page.dart'; // Classe Player (voir étape suivante)
import 'yams_score_page.dart';
import '../utils/category_colors.dart';
class PlayerSettingsPage extends StatefulWidget {
  final int? initialScore;
  final String gameName;
  final String categoryName; 

  const PlayerSettingsPage({
    super.key,
    this.initialScore,
    required this.gameName,
    required this.categoryName,
  });

  @override
  _PlayerSettingsPageState createState() => _PlayerSettingsPageState();
}

class _PlayerSettingsPageState extends State<PlayerSettingsPage> {
  List<Player> players = [
    Player(name: 'Joueur 1', emoji: '🙂'),
  ]; // Par défaut, un joueur

  void _addPlayer() {
    setState(() {
      players.add(Player(name: 'Joueur ${players.length + 1}', emoji: '🙂'));
    });
  }

  void _removePlayer(int index) {
    if (players.length > 1) {
      setState(() {
        players.removeAt(index);
      });
    }
  }

  void _startGame() {
    if (widget.gameName == 'Killer') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => KillerScorePage(players: players),
        ),
      );
    } else if (widget.gameName == 'Yams') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => YamsScorePage(players: players),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DartsScorePage(
            players: players,
            initialScore: widget.initialScore ?? 501,
            gameName: widget.gameName,
            categoryName: widget.categoryName,
          ),
        ),
      );
    }
  }

@override
Widget build(BuildContext context) {
  final categoryColor = CategoryColors.getColor(widget.categoryName);

  return GradientBackground(
    child: Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Paramètres des joueurs'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    categoryColor,
                    categoryColor.withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.categoryName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.gameName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${players.length} joueur${players.length > 1 ? 's' : ''}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                  itemCount: players.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: GestureDetector(
                        onTap: () async {
                          final emoji = await showDialog<String>(
                            context: context,
                            builder: (context) => EmojiPickerDialog(
                              initialEmoji: players[index].emoji,
                            ),
                          );
                          if (emoji != null) {
                            setState(() {
                              players[index].emoji = emoji;
                            });
                          }
                        },
                        child: Text(
                          players[index].emoji,
                          style: const TextStyle(fontSize: 32),
                        ),
                      ),
                      title: TextField(
                        decoration: const InputDecoration(labelText: 'Nom du joueur'),
                        onChanged: (value) {
                          setState(() {
                            players[index].name = value;
                          });
                        },
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _removePlayer(index),
                      ),
                    );
                  },
                ),
              ),
              ElevatedButton.icon(
                onPressed: _addPlayer,
                icon: const Icon(Icons.add),
                label: const Text('Ajouter un joueur'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _startGame();
                },
                child: const Text('Jouer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EmojiPickerDialog extends StatelessWidget {
  final String initialEmoji;

  const EmojiPickerDialog({super.key, required this.initialEmoji});

  @override
  Widget build(BuildContext context) {
    final emojis = ['🙂', '😎', '🤓', '🥳', '😇', '😡', '🤖', '👻', '🐶', '🐱'];
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          shrinkWrap: true,
          itemCount: emojis.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                Navigator.pop(context, emojis[index]);
              },
              child: Text(
                emojis[index],
                style: const TextStyle(fontSize: 32),
              ),
            );
          },
        ),
      ),
    );
  }
}
