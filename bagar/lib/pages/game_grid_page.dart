import 'package:flutter/material.dart';
import '../models/game_model.dart';
import '../widgets/grid_item.dart';
import 'game_details_page.dart';

class GameGridPage extends StatelessWidget {
  final String categoryName;
  final List<Game> games;

  const GameGridPage({super.key, required this.categoryName, required this.games});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(categoryName),
      ),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: games.length,
        padding: const EdgeInsets.all(10),
        itemBuilder: (context, index) {
          final game = games[index];
          return GridItem(
            title: game.name,
            image: game.image,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GameDetailsPage(game: game),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
