class Game {
  final String name;
  final String image;
  final String goal;
  final String method;
  final String turn;

  Game({
    required this.name,
    required this.image,
    required this.goal,
    required this.method,
    required this.turn,
  });

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      name: json['name'],
      image: json['image'],
      goal: json['goal'],
      method: json['method'],
      turn: json['turn'],
    );
  }
}
