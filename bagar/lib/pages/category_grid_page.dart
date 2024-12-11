import 'package:flutter/material.dart';
import 'dart:async';
import '../models/category_model.dart';
import '../services/data_loader.dart';
import '../widgets/gradient_background.dart';
import '../widgets/grid_item.dart';
import '../widgets/category/trending_header.dart';
import '../widgets/category/categories_header.dart';
import '../widgets/category/trending_carousel.dart';
import '../utils/category_colors.dart';
import 'game_grid_page.dart';
class CategoryGridPage extends StatefulWidget {
  const CategoryGridPage({super.key});

  @override
  _CategoryGridPageState createState() => _CategoryGridPageState();
}

class _CategoryGridPageState extends State<CategoryGridPage> {
  late Future<List<Category>> _categoriesFuture;
  late PageController _pageController;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _categoriesFuture = DataLoader.loadCategories();
    _pageController = PageController(viewportFraction: 0.93);
    _startAutoSlide();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
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
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'BAGAR',
            style: TextStyle(
              color: Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: FutureBuilder<List<Category>>(
          future: _categoriesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(child: Text('Erreur de chargement des données'));
            }

            final categories = snapshot.data!;
            final validCategories = categories.where((cat) => cat.games.isNotEmpty).toList();

            return Column(
              children: [
                const TrendingHeader(),
                TrendingCarousel(
                  controller: _pageController,
                  categories: validCategories,
                  onPageChanged: (page) {
                    setState(() {
                      _startAutoSlide();
                    });
                  },
                ),
                const CategoriesHeader(),
                _buildCategoriesGrid(categories),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCategoriesGrid(List<Category> categories) {
    return Expanded(
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        padding: const EdgeInsets.all(10),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return GridItem(
            title: category.name,
            image: category.image,
            primaryColor: CategoryColors.getColor(category.name),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GameGridPage(
                  categoryName: category.name,
                  games: category.games,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
