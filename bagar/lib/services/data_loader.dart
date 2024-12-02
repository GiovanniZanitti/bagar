import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/category_model.dart';

class DataLoader {
  static Future<List<Category>> loadCategories() async {
    final String response =
        await rootBundle.loadString('assets/games_data.json');
    final data = json.decode(response);
    return (data['categories'] as List)
        .map((categoryJson) => Category.fromJson(categoryJson))
        .toList();
  }
}
