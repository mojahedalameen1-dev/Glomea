import 'package:dio/dio.dart';
import 'package:kidneytrack_mobile/core/models/food_item.dart';
import 'sfda_nutrition_service.dart';

class FoodNutritionService {
  final Dio _dio = Dio();
  final SfdaNutritionService _sfdaService = SfdaNutritionService();

  static const String _offBaseUrl =
      'https://world.openfoodfacts.org/api/v2/product/';

  double? _safeDouble(dynamic value) =>
      value == null ? null : double.tryParse(value.toString());

  Future<FoodItem?> fetchByBarcode(String barcode) async {
    return getByBarcode(barcode);
  }

  Future<FoodItem?> getByBarcode(String barcode) async {
    // 1. Try SFDA (Official Saudi Government Data)
    try {
      final sfdaProduct = await _sfdaService.fetchByBarcode(barcode);
      if (sfdaProduct != null) {
        return sfdaProduct;
      }
    } catch (e) {
      // Logic for fallback
    }

    // 2. Fallback to Open Food Facts (Global Open Data)
    try {
      final response = await _dio.get('$_offBaseUrl$barcode.json');
      if (response.statusCode == 200 && response.data['status'] == 1) {
        final product = response.data['product'];
        final nutrients = product['nutriments'] ?? {};

        return _mapProductToFoodItem(barcode, product, nutrients);
      }
    } catch (e) {
      // Handle error
    }
    return null;
  }

  Future<List<FoodItem>> searchByName(String name) async {
    // Fire both requests in parallel for maximum speed
    final futures = [
      _sfdaService.searchByName(name),
      _fetchOffSearchResults(name),
    ];

    try {
      final resultsList = await Future.wait(futures);
      final List<FoodItem> sfdaResults = resultsList[0];
      final List<FoodItem> offResults = resultsList[1];

      final List<FoodItem> combined = [...sfdaResults];

      // Deduplicate: Add OFF results only if they don't exist in SFDA (by name/ID)
      for (var item in offResults) {
        if (!combined.any((res) =>
            res.id == item.id ||
            res.name.toLowerCase() == item.name.toLowerCase())) {
          combined.add(item);
        }
      }

      return combined;
    } catch (e) {
      return [];
    }
  }

  Future<List<FoodItem>> _fetchOffSearchResults(String name) async {
    try {
      final response = await _dio.get(
        'https://world.openfoodfacts.org/cgi/search.pl',
        queryParameters: {
          'search_terms': name,
          'search_simple': 1,
          'action': 'process',
          'json': 1,
          'page_size': 12, // Increased for Grid
        },
      );

      if (response.statusCode == 200) {
        final products = response.data['products'] as List;
        return products.map((p) {
          final nutrients = p['nutriments'] ?? {};
          return _mapProductToFoodItem(p['_id'] ?? '', p, nutrients);
        }).toList();
      }
    } catch (e) {
      // Handle error
    }
    return [];
  }

  FoodItem _mapProductToFoodItem(String id, Map product, Map nutrients) {
    // Open Food Facts API returns most nutrients in grams per 100g.
    // For kidney patients, we need Sodium, Potassium, and Phosphorus in milligrams (mg).
    double? sodiumGrams = _safeDouble(nutrients['sodium_100g']);

    return FoodItem(
      id: id,
      name: product['product_name']?.toString() ?? 'منتج غير معروف',
      brand: product['brands']?.toString() ?? '',
      imageUrl: product['image_url']?.toString(),
      potassium: _safeDouble(nutrients['potassium_100g']),
      phosphorus: _safeDouble(nutrients['phosphorus_100g']),
      sodium:
          sodiumGrams != null ? sodiumGrams * 1000 : null, // Convert g to mg
      calcium: _safeDouble(nutrients['calcium_100g']) != null
          ? _safeDouble(nutrients['calcium_100g'])! * 1000
          : null, // Convert g to mg
      protein: _safeDouble(nutrients['proteins_100g']),
      sugars: _safeDouble(nutrients['sugars_100g']),
      calories: _safeDouble(nutrients['energy-kcal_100g']),
      carbohydrates: _safeDouble(nutrients['carbohydrates_100g']),
      totalFat: _safeDouble(nutrients['fat_100g']),
      servingSize: _safeDouble(product['serving_quantity']),
      dataSource: 'off',
    );
  }
}
