import 'package:flutter/material.dart';

class CategoriesHeader extends StatelessWidget {
  const CategoriesHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('🎮 🎲 🎯', style: TextStyle(fontSize: 20)),
          Text(
            'Catégories',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text('🎯 🎲 🎮', style: TextStyle(fontSize: 20)),
        ],
      ),
    );
  }
} 