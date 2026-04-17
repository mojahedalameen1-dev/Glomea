import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:kidneytrack_mobile/core/models/food_nutrition.dart';

class GeminiService {
  late final GenerativeModel _model;
  
  GeminiService() {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    _model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
  }

  Future<FoodNutrition?> analyzeFoodLabel(List<int> imageBytes) async {
    try {
      const prompt = 'Extract the following nutrition values per 100g from this food label. '
          'Return ONLY a JSON object with these keys: '
          '{"name": "product name", "potassium": value_in_mg, "phosphorus": value_in_mg, "sodium": value_in_mg, "protein": value_in_g}. '
          'If a value is not found, use 0. Respond in JSON format only.';

      final content = [
        Content.multi([
          TextPart(prompt),
          DataPart('image/jpeg', Uint8List.fromList(imageBytes)),
        ])
      ];

      final response = await _model.generateContent(content);
      final text = response.text;
      
      if (text != null) {
        // Clean markdown JSON if present
        final jsonStr = text.replaceAll('```json', '').replaceAll('```', '').trim();
        final Map<String, dynamic> data = jsonDecode(jsonStr);
        
        final potassium = (data['potassium'] ?? 0.0).toDouble();
        final phosphorus = (data['phosphorus'] ?? 0.0).toDouble();
        final sodium = (data['sodium'] ?? 0.0).toDouble();
        final protein = (data['protein'] ?? 0.0).toDouble();

        return FoodNutrition(
          id: 'gemini_${DateTime.now().millisecondsSinceEpoch}',
          name: data['name'] ?? 'من الملصق الغذائي',
          potassiumPer100g: potassium,
          phosphorusPer100g: phosphorus,
          sodiumPer100g: sodium,
          proteinPer100g: protein,
          potassiumLevel: FoodNutrition.calculatePotassiumLevel(potassium),
          phosphorusLevel: FoodNutrition.calculatePhosphorusLevel(phosphorus),
          sodiumLevel: FoodNutrition.calculateSodiumLevel(sodium),
          proteinLevel: FoodNutrition.calculateProteinLevel(protein),
        );
      }
    } catch (e) {
      // Handle error
    }
    return null;
  }
}

