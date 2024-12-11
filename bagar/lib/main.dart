import 'package:flutter/material.dart';
import 'pages/category_grid_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Jeux par catégories',
      theme: ThemeData(
        primarySwatch: Colors.blue, 
        fontFamily: 'ConcertOne',
        scaffoldBackgroundColor: Colors.transparent,
      ),
      home: const CategoryGridPage(),
    );
  }
}
