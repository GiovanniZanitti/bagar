import 'package:flutter/material.dart';
import '../models/player_model.dart';

class KillerPlayer extends Player {
  int lives;
  int? targetNumber;
  bool isKiller;
  bool hasReachedMaxLives;
  static const int maxLives = 5;
  int selfHits = 0;    // Nouveau : nombre de fois où il s'est touché
  int otherHits = 0;   // Nouveau : nombre de fois où il a touché les autres

  KillerPlayer({
    required Player player,
    this.lives = 1,
    this.targetNumber,
    this.isKiller = false,
    this.hasReachedMaxLives = false,
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
  bool isSelectingTargets = true;  // Phase de sélection des numéros
  int currentPlayer = 0;  // Index du joueur actuel

  @override
  void initState() {
    super.initState();
    killerPlayers = widget.players
        .map((player) => KillerPlayer(player: player))
        .toList();
  }

  void _nextTurn() {
    setState(() {
      do {
        if (currentPlayer < killerPlayers.length - 1) {
          currentPlayer++;
        } else {
          currentPlayer = 0;
          if (isSelectingTargets) {
            // Vérifier si tous les joueurs ont un numéro
            if (killerPlayers.every((player) => player.targetNumber != null)) {
              isSelectingTargets = false;
            }
          }
        }
        // Continue à chercher le prochain joueur tant que le joueur actuel est éliminé
        // et qu'il reste des joueurs en vie
      } while (
        killerPlayers[currentPlayer].lives == 0 && 
        killerPlayers.any((player) => player.lives > 0)
      );

      // Vérifier s'il ne reste qu'un joueur en vie
      if (killerPlayers.where((player) => player.lives > 0).length == 1) {
        // Trouver le gagnant
        final winner = killerPlayers.firstWhere((player) => player.lives > 0);
        
        // Afficher un dialogue de victoire
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Partie terminée !'),
              content: Text('${winner.name} remporte la partie ! 🎉'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Ferme le dialogue
                    Navigator.of(context).pop(); // Retourne à la page précédente
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    });
  }

  void _selectTargetNumber(int number) {
    // Vérifie si le numéro est déjà pris
    if (killerPlayers.any((player) => player.targetNumber == number)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ce numéro est déjà pris !'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      killerPlayers[currentPlayer].targetNumber = number;
      _nextTurn();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isSelectingTargets 
          ? 'Choisissez vos numéros' 
          : 'Killer - Tour de ${killerPlayers[currentPlayer].name}'),
      ),
      body: Column(
        children: [
          // Liste des joueurs (toujours visible)
          Expanded(
            flex: 2,  // Donne plus d'espace à la liste des joueurs
            child: ListView.builder(
              itemCount: killerPlayers.length,
              itemBuilder: (context, index) {
                final player = killerPlayers[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  color: player.lives == 0 
                      ? Colors.grey.shade200  // Gris clair pour les joueurs éliminés
                      : index == currentPlayer && !isSelectingTargets
                          ? Colors.blue.shade100
                          : null,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        // Emoji du joueur (grisé si éliminé)
                        Opacity(
                          opacity: player.lives == 0 ? 0.5 : 1.0,
                          child: Text(
                            player.emoji,
                            style: const TextStyle(fontSize: 32),
                          ),
                        ),
                        const SizedBox(width: 16),
                        
                        // Informations du joueur
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
                                      decoration: player.lives == 0 ? TextDecoration.lineThrough : null,
                                    ),
                                  ),
                                  if (player.lives == 0)
                                    const Text(
                                      ' (Éliminé)',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  // Numéro cible
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
                                  const SizedBox(width: 8),
                                  // Status Killer
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
                              // Stats du joueur
                              if (!isSelectingTargets) // On n'affiche les stats qu'une fois la partie commencée
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.self_improvement,
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
                        
                        // Vies restantes avec boutons + et -
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
                                // Bouton - : uniquement pour les Killers attaquant d'autres joueurs
                                if (killerPlayers[currentPlayer].isKiller && index != currentPlayer)
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle),
                                    color: Colors.red,
                                    onPressed: player.lives > 0
                                        ? () {
                                            setState(() {
                                              player.lives--;
                                              // Incrémente otherHits du Killer actuel
                                              killerPlayers[currentPlayer].otherHits++;
                                              if (player.lives == 0) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text('${player.name} est éliminé !'),
                                                    backgroundColor: Colors.red,
                                                  ),
                                                );
                                              }
                                            });
                                          }
                                        : null,
                                  ),
                                
                                // Bouton + : uniquement pour le joueur actuel sur lui-même
                                if (index == currentPlayer)
                                  IconButton(
                                    icon: const Icon(Icons.add_circle),
                                    color: Colors.green,
                                    onPressed: player.lives < KillerPlayer.maxLives
                                        ? () {
                                            setState(() {
                                              player.lives++;
                                              player.selfHits++;  // Incrémente selfHits
                                              
                                              if (player.lives == KillerPlayer.maxLives && !player.hasReachedMaxLives) {
                                                player.hasReachedMaxLives = true;
                                                player.isKiller = true;
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text('${player.name} devient Killer !'),
                                                    backgroundColor: Colors.purple,
                                                    duration: const Duration(seconds: 2),
                                                  ),
                                                );
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
                );
              },
            ),
          ),

          // Grille de numéros (visible uniquement pendant la sélection)
          if (isSelectingTargets) ...[
            // Texte d'instruction déplacé ici
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              color: Colors.grey.shade100,  // Fond légèrement coloré pour le distinguer
              child: Text(
                'Au tour de ${killerPlayers[currentPlayer].name} de choisir un numéro',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            // Clavier de numéros
            Container(
              height: 200,  // Hauteur fixe pour le clavier
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

          // Bouton "Tour suivant" (visible uniquement après la phase de sélection)
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