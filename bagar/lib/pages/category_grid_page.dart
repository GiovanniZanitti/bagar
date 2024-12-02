import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../services/data_loader.dart';
import '../widgets/grid_item.dart';
import 'game_grid_page.dart';

class CategoryGridPage extends StatefulWidget {
  const CategoryGridPage({super.key});

  @override
  _CategoryGridPageState createState() => _CategoryGridPageState();
}

class _CategoryGridPageState extends State<CategoryGridPage> {
  late Future<List<Category>> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _categoriesFuture = DataLoader.loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catégories de Jeux'),
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
            return GridView.builder(
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
            );
          }
        },
      ),
    );
  }
}
