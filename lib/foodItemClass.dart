import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class FoodItem {
  final String name;
  final Map<String, bool> seasons;

  FoodItem({required this.name, required this.seasons});

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    Map<String, bool> seasons = {};
    if (json['vegetable'] != null) seasons.addAll(Map<String, bool>.from(json['vegetable']));
    if (json['fruit'] != null) seasons.addAll(Map<String, bool>.from(json['fruit']));
    if (json['seefood'] != null) seasons.addAll(Map<String, bool>.from(json['seefood']));
    return FoodItem(name: json['name'], seasons: seasons);
  }
}

Future<List<FoodItem>> loadFoodItems() async {
  String jsonString = await rootBundle.loadString('assets/data.json');
  List<dynamic> jsonList = json.decode(jsonString)['Info'];
  return jsonList.map((item) => FoodItem.fromJson(item)).toList();
}
