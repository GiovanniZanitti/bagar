import 'package:flutter/material.dart';
import '../models/game_model.dart';
import '../widgets/grid_item.dart';
import '../widgets/gradient_background.dart';
import '../utils/category_colors.dart';
import 'game_details_page.dart';

class GameGridPage extends StatelessWidget {
  final String categoryName;
  final List<Game> games;

  const GameGridPage({super.key, required this.categoryName, required this.games});

  @override
  Widget build(BuildContext context) {
    final categoryColor = CategoryColors.getColor(categoryName);

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          title: Text(
            categoryName,
            style: const TextStyle(color: Colors.white),
          ),
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
              primaryColor: categoryColor,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GameDetailsPage(
                      game: game,
                      categoryName: categoryName,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
