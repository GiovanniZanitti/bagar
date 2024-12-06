class Game {
  final String name;
  final String image;
  final String goal;
  final String method;
  final String turn;
  final bool scoreCounter;
  final int? initialScore;  // Pour les jeux de type score (301/401/501)

  Game({
    required this.name,
    required this.image,
    required this.goal,
    required this.method,
    required this.turn,
    required this.scoreCounter,
    this.initialScore,  // Optionnel car uniquement pour les jeux de type score
  });

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      name: json['name'],
      image: json['image'],
      goal: json['goal'],
      method: json['method'],
      turn: json['turn'],
      scoreCounter: json['scoreCounter'],
      initialScore: json['initialScore'],
    );
  }
}
