import 'package:flutter/material.dart'; 
import '../models/game_model.dart';
import 'player_settings_page.dart';
import 'dart:math';
import '../widgets/gradient_background.dart';

class GameDetailsPage extends StatefulWidget {
  final Game game;

  const GameDetailsPage({super.key, required this.game});

  @override
  State<GameDetailsPage> createState() => _GameDetailsPageState();
}

class _GameDetailsPageState extends State<GameDetailsPage> with TickerProviderStateMixin {
  late AnimationController _goalController;
  late AnimationController _methodController;
  late AnimationController _turnController;
  late AnimationController _buttonController;
  
  late Animation<double> _goalOpacity;
  late Animation<double> _methodOpacity;
  late Animation<double> _turnOpacity;
  late Animation<double> _buttonOpacity; 
  @override
  void initState() {
    super.initState();
    
    // Configuration des animations
    _goalController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _methodController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _turnController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _goalOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _goalController, curve: Curves.easeIn),
    );

    _methodOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _methodController, curve: Curves.easeIn),
    );

    _turnOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _turnController, curve: Curves.easeIn),
    );

    _buttonOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeIn),
    );

    // Démarrage séquentiel des animations
    _goalController.forward();
    
    Future.delayed(const Duration(milliseconds: 500), () {
      _methodController.forward();
    });
    
    Future.delayed(const Duration(milliseconds: 1000), () {
      _turnController.forward();
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      _buttonController.forward();
    });
  }

  @override
  void dispose() {
    _goalController.dispose();
    _methodController.dispose();
    _turnController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  // Génère une couleur aléatoire de vert ou bleu
  Color _generateRandomColor(bool isGreen) {
    final random = Random();
    if (isGreen) {
      return Color.fromRGBO(
        0,
        150 + random.nextInt(106),  // Valeur de vert entre 150 et 255
        100 + random.nextInt(50),   // Un peu de bleu pour plus de profondeur
        1,
      );
    } else {
      return Color.fromRGBO(
        0,
        100 + random.nextInt(50),   // Un peu de vert pour plus de profondeur
        150 + random.nextInt(106),  // Valeur de bleu entre 150 et 255
        1,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(widget.game.name),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),  // Fond légèrement transparent
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FadeTransition(
                        opacity: _goalOpacity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Center(
                              child: Text(
                                'But du jeu',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(widget.game.goal, style: const TextStyle(fontSize: 16), textAlign: TextAlign.justify),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      FadeTransition(
                        opacity: _methodOpacity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Center(
                              child: Text(
                                'Moyen d\'y arriver',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              widget.game.method,
                              style: const TextStyle(fontSize: 16),
                              textAlign: TextAlign.justify,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      FadeTransition(
                        opacity: _turnOpacity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Center(
                              child: Text(
                                'Déroulement d\'un tour',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(widget.game.turn, style: const TextStyle(fontSize: 16), textAlign: TextAlign.justify),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                if (_isGameScoreCounter())
                  FadeTransition(
                    opacity: _buttonOpacity,
                    child: Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.9),
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PlayerSettingsPage(
                                initialScore: widget.game.initialScore,
                                gameName: widget.game.name,
                              ),
                            ),
                          );
                        },
                        child: const Text(
                          'Lancer une partie',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _isGameScoreCounter() {
    return widget.game.scoreCounter;
  }
}
