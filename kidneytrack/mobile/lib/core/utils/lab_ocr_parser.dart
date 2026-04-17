class LabOcrParser {
  /// Parses raw text from OCR to extract lab values for kidney patients.
  /// 
  /// Returns a map of indicator codes to their extracted double values (or null if not found).
  /// Indicator keys match the codes used in LabEntryScreen.
  static Map<String, double?> parseLabResults(String rawText) {
    // Normalize text: replace commas with dots and simplify whitespace
    final text = rawText.replaceAll('،', '.').replaceAll('\n', ' ');

    final results = <String, double?>{
      'CREAT': null,
      'UREA': null,
      'K': null,
      'NA': null,
      'HGB': null,
      'PHOS': null,
    };

    final patterns = {
      'CREAT': [
        RegExp(r'creatinine[:\s]+(\d+\.?\d*)', caseSensitive: false), // English
        RegExp(r'كرياتينين[:\s]+(\d+\.?\d*)'),                       // Arabic
      ],
      'UREA': [
        RegExp(r'(?:urea|bun)[:\s]+(\d+\.?\d*)', caseSensitive: false),
        RegExp(r'(?:يوريا|بولينا)[:\s]+(\d+\.?\d*)'),
      ],
      'K': [
        RegExp(r'(?:potassium|k\+?)[:\s]+(\d+\.?\d*)', caseSensitive: false),
        RegExp(r'بوتاسيوم[:\s]+(\d+\.?\d*)'),
      ],
      'NA': [
        RegExp(r'(?:sodium|na\+?)[:\s]+(\d+\.?\d*)', caseSensitive: false),
        RegExp(r'صوديوم[:\s]+(\d+\.?\d*)'),
      ],
      'HGB': [
        RegExp(r'(?:hemoglobin|hb|hgb)[:\s]+(\d+\.?\d*)', caseSensitive: false),
        RegExp(r'هيموجلوبين[:\s]+(\d+\.?\d*)'),
      ],
      'PHOS': [
        RegExp(r'(?:phosphorus|phos)[:\s]+(\d+\.?\d*)', caseSensitive: false),
        RegExp(r'فوسفور[:\s]+(\d+\.?\d*)'),
      ],
    };

    patterns.forEach((key, regexList) {
      for (final regex in regexList) {
        final match = regex.firstMatch(text);
        if (match != null && match.groupCount >= 1) {
          final val = double.tryParse(match.group(1)!);
          if (val != null) {
            results[key] = val;
            break; // Stop after first successful match for this indicator
          }
        }
      }
    });

    return results;
  }
}
