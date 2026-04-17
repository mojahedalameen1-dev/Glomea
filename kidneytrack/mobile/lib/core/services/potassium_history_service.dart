import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/food_item.dart';

class PotassiumHistoryService {
  static const String _key = 'potassium_history';

  static Future<void> saveToHistory(FoodItem food) async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList(_key) ?? [];

    // Check if food already exists (by name or id)
    history.removeWhere((item) {
      final decoded = jsonDecode(item);
      return decoded['name'] == food.name;
    });

    history.insert(0, jsonEncode(food.toJson()));

    // Keep only last 10
    if (history.length > 10) history.removeLast();

    await prefs.setStringList(_key, history);
  }

  static Future<List<FoodItem>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList(_key) ?? [];
    return history.map((e) => FoodItem.fromJson(jsonDecode(e))).toList();
  }
}
