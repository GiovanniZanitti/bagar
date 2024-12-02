import 'game_model.dart';

class Category {
  final String name;
  final String image;
  final List<Game> games;

  Category({required this.name, required this.image, required this.games});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      name: json['name'],
      image: json['image'],
      games: (json['games'] as List)
          .map((gameJson) => Game.fromJson(gameJson))
          .toList(),
    );
  }
}
