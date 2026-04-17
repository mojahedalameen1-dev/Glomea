import 'package:dio/dio.dart';
import 'package:kidneytrack_mobile/core/models/food_item.dart';

class SfdaNutritionService {
  final Dio _dio = Dio();

  // SFDA API Credentials
  static const String _consumerKey = 'VvRXiZUcU0xAzctmlMNcO8SAwDAnjXy8SdtmrTMBxH8pmR5R';
  static const String _consumerSecret = 'Cb3QlvNioSf9ddR7Cwt3VyiYNAwGsY8ssxVxM3Ql3v88PAHKcxCUUoxqEXOHOSnA';

  // SFDA API Endpoints from Documentation
  static const String _baseUrl = 'https://api.sfda.gov.sa';
  static const String _tokenPath = '/token';
  // Note: Using the specific environment path from the screenshot
  static const String _barcodePath = '/food/v1/Food-Products-environment/products/barcode/';
  static const String _searchPath = '/food/v1/Food-Products-environment/products/search/';

  String? _accessToken;
  DateTime? _tokenExpiry;

  Future<void> _refreshAccessToken() async {
    try {
      final response = await _dio.post(
        '$_baseUrl$_tokenPath',
        data: {
          'grant_type': 'client_credentials',
          'client_id': _consumerKey,
          'client_secret': _consumerSecret,
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ),
      );

      if (response.statusCode == 200) {
        _accessToken = response.data['access_token'];
        final expiresIn = response.data['expires_in'] as int;
        _tokenExpiry = DateTime.now().add(Duration(seconds: expiresIn));
      }
    } catch (e) {
      // Auth error
    }
  }

  Future<String?> _getToken() async {
    if (_accessToken == null || _tokenExpiry == null || DateTime.now().isAfter(_tokenExpiry!)) {
      await _refreshAccessToken();
    }
    return _accessToken;
  }

  Future<FoodItem?> fetchByBarcode(String barcode) async {
    try {
      final token = await _getToken();
      if (token == null) return null;

      final response = await _dio.get(
        '$_baseUrl$_barcodePath$barcode',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        // The API returns a response object, usually with a 'data' or 'product' field
        // Based on the screenshot, we look for the Product info
        final productData = data['data'] ?? data; 

        return FoodItem(
          id: barcode,
          name: productData['product_name_ar'] ?? productData['product_name_en'] ?? 'منتج غير معروف',
          brand: productData['brand_name_ar'] ?? productData['brand_name_en'] ?? '',
          imageUrl: productData['image_url'],
          // Detailed mapping for kidney patients from SFDA fields
          potassium: _toDouble(productData['potassium_content']),
          phosphorus: _toDouble(productData['phosphorus_content']),
          sodium: _toDouble(productData['sodium_content']),
          calcium: _toDouble(productData['calcium_content']),
          protein: _toDouble(productData['protein_content']),
          sugars: _toDouble(productData['sugar_content']),
          calories: _toDouble(productData['calories']) ?? _toDouble(productData['energy']),
          carbohydrates: _toDouble(productData['carbohydrate_content']),
          totalFat: _toDouble(productData['fat_content']),
          servingSize: _toDouble(productData['serving_size']) ?? 100.0,
          dataSource: 'sfda',
        );
      }
    } catch (e) {
      // API error
    }
    return null;
  }

  Future<List<FoodItem>> searchByName(String name, {int page = 1}) async {
    try {
      final token = await _getToken();
      if (token == null) return [];

      final response = await _dio.get(
        '$_baseUrl$_searchPath$name/$page',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final List products = response.data['data'] ?? [];
        return products.map((p) => _mapToFoodItem(p['_id'] ?? '', p)).toList();
      }
    } catch (e) {
      // Search error
    }
    return [];
  }

  FoodItem _mapToFoodItem(String id, Map productData) {
    return FoodItem(
      id: id,
      name: productData['product_name_ar'] ?? productData['product_name_en'] ?? 'منتج غير معروف',
      brand: productData['brand_name_ar'] ?? productData['brand_name_en'] ?? '',
      imageUrl: productData['image_url'],
      potassium: _toDouble(productData['potassium_content']),
      phosphorus: _toDouble(productData['phosphorus_content']),
      sodium: _toDouble(productData['sodium_content']),
      calcium: _toDouble(productData['calcium_content']),
      protein: _toDouble(productData['protein_content']),
      sugars: _toDouble(productData['sugar_content']),
      calories: _toDouble(productData['calories']) ?? _toDouble(productData['energy']),
      carbohydrates: _toDouble(productData['carbohydrate_content']),
      totalFat: _toDouble(productData['fat_content']),
      servingSize: _toDouble(productData['serving_size']) ?? 100.0,
      dataSource: 'sfda',
    );
  }

  double? _toDouble(dynamic val) {
    if (val == null) return null;
    return double.tryParse(val.toString());
  }
}
