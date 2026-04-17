import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:gemini_nano_android/gemini_nano_android.dart';

class AiFoodAnalysisService {
  /// Builds the specific prompt for kidney patients nutrition assessment.
  static String _buildNutrientPrompt(Map<String, dynamic> n) => """
أنت مساعد غذائي متخصص لمرضى الفشل الكلوي.
بناءً على القيم الغذائية التالية لكل 100 جرام:
- الصوديوم: ${n['sodium'] ?? 'غير متوفر'} ملجم
- البوتاسيوم: ${n['potassium'] ?? 'غير متوفر'} ملجم
- الفوسفور: ${n['phosphorus'] ?? 'غير متوفر'} ملجم
- البروتين: ${n['protein'] ?? 'غير متوفر'} جم
- السعرات: ${n['calories'] ?? 'غير متوفر'} سعر

قدّم تقييمًا قصيرًا جداً (سطرين إلى 3 أسطر كحد أقصى) بالعربية.
القواعد الإلزامية:
- لا تذكر أرقامًا في الإجابة
- لا تستخدم مصطلحات طبية معقدة
- اكتب بلغة بسيطة تناسب كبار السن
- كن هادئًا وغير مخيف
- ابدأ مباشرةً بالتقييم بدون مقدمات
- إذا كانت قيم مفقودة، لا تذكر ذلك، قيّم بما هو متاح فقط
""";

  /// Analyzes food nutrients using Hybrid Cloud-Fallback pattern:
  /// 1. Try Gemini Nano (Offline, local)
  /// 2. If fails, fallback to Google AI (Cloud)
  /// 3. If both fail, return null silently.
  static Future<String?> analyzeFood(Map<String, dynamic> nutrients) async {
    final prompt = _buildNutrientPrompt(nutrients);
    try {
      // 1) Gemini Nano First (Offline, Free, Private)
      final gemini = GeminiNanoAndroid();
      final results = await gemini.generate(prompt: prompt);
      if (results.isNotEmpty) return results.first;
      throw Exception('Empty Nano results');
    } catch (_) {
      try {
        // 2) Google AI Logic fallback (Cloud)
        // Using existing google_generative_ai package
        final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
        final model = GenerativeModel(
          model: 'gemini-1.5-flash',
          apiKey: apiKey,
        );
        final response = await model.generateContent([Content.text(prompt)]);
        return response.text;
      } catch (_) {
        // 3) Silent failure: Hide the card
        return null;
      }
    }
  }
}
