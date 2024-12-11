import 'package:flutter/material.dart';
import '../../models/category_model.dart';
import '../../models/game_model.dart';
import '../../utils/category_colors.dart';
import '../../pages/game_details_page.dart';

class TrendingCarousel extends StatelessWidget {
  final PageController controller;
  final List<Category> categories;
  final Function(int) onPageChanged;

  const TrendingCarousel({
    required this.controller,
    required this.categories,
    required this.onPageChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      margin: const EdgeInsets.only(bottom: 16),
      child: PageView.builder(
        controller: controller,
        onPageChanged: onPageChanged,
        itemCount: null,
        itemBuilder: (context, index) {
          final actualIndex = index % categories.length;
          final category = categories[actualIndex];
          final suggestedGame = category.games[0];
          
          return _TrendingCard(
            category: category,
            game: suggestedGame,
          );
        },
      ),
    );
  }
}

class _TrendingCard extends StatelessWidget {
  final Category category;
  final Game game;

  const _TrendingCard({
    required this.category,
    required this.game,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            CategoryColors.getColor(category.name),
            CategoryColors.getColor(category.name).withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GameDetailsPage(
                game: game,
                categoryName: category.name,
              ),
            ),
          ),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Image.asset(
                  game.image,
                  height: 80,
                  width: 80,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        game.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        game.goal,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 