import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../services/data_loader.dart';
import '../widgets/grid_item.dart';
import 'game_grid_page.dart';
import '../widgets/gradient_background.dart';
import 'game_details_page.dart';
import 'dart:async';

class CategoryGridPage extends StatefulWidget {
  const CategoryGridPage({super.key});

  @override
  _CategoryGridPageState createState() => _CategoryGridPageState();
}

class _CategoryGridPageState extends State<CategoryGridPage> {
  late Future<List<Category>> _categoriesFuture;
  late PageController _pageController;
  Timer? _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _categoriesFuture = DataLoader.loadCategories();
    _pageController = PageController(
      viewportFraction: 0.93,
      initialPage: 0,
    );
    _startAutoSlide();
  }

  void _startAutoSlide() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (_pageController.hasClients) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeIn,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('BAGAR', 
            style: TextStyle(
              color: Colors.white, 
              fontSize: 40, 
              fontWeight: FontWeight.bold
            )
          ),
        ),
        body: FutureBuilder<List<Category>>(
          future: _categoriesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text('Erreur de chargement des données'));
            } else {
              final categories = snapshot.data!;
              final validCategories = categories.where((cat) => cat.games.isNotEmpty).toList();
              
              return Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '🔥 🔥 🔥',
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                        Text(
                          'Tendances',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '🔥 🔥 🔥',
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 120,
                    margin: const EdgeInsets.only(bottom: 16),
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (int page) {
                        setState(() {
                          _currentPage = page;
                          _startAutoSlide();
                        });
                      },
                      itemCount: null,
                      itemBuilder: (context, index) {
                        final actualIndex = index % validCategories.length;
                        final category = validCategories[actualIndex];
                        final suggestedGame = category.games[0];
                        
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                _getCategoryColor(category.name),
                                _getCategoryColor(category.name).withOpacity(0.7),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => GameDetailsPage(game: suggestedGame),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Image.asset(
                                      suggestedGame.image,
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
                                            suggestedGame.name,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            suggestedGame.goal,
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
                      },
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '🎮 🎲 🎯',
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                        Text(
                          'Catégories',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '🎯 🎲 🎮',
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: categories.length,
                      padding: const EdgeInsets.all(10),
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        return GridItem(
                          title: category.name,
                          image: category.image,
                          primaryColor: _getCategoryColor(category.name),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    GameGridPage(categoryName: category.name, games: category.games),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Color _getCategoryColor(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'fléchettes':
        return Colors.green.shade700;
      case 'dés':
        return Colors.red.shade700;
      case 'cartes':
        return Colors.blue.shade700;
      case 'jeux oraux':
        return Colors.yellow.shade700;
      default:
        return Colors.grey.shade700;
    }
  }
}
