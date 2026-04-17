enum IndicatorStatus { safe, warning, critical }

class FoodNutrition {
  final String id;
  final String name;
  final double potassiumPer100g;
  final double phosphorusPer100g;
  final double sodiumPer100g;
  final double proteinPer100g;
  
  final IndicatorStatus potassiumLevel;
  final IndicatorStatus phosphorusLevel;
  final IndicatorStatus sodiumLevel;
  final IndicatorStatus proteinLevel;

  FoodNutrition({
    required this.id,
    required this.name,
    required this.potassiumPer100g,
    required this.phosphorusPer100g,
    required this.sodiumPer100g,
    required this.proteinPer100g,
    required this.potassiumLevel,
    required this.phosphorusLevel,
    required this.sodiumLevel,
    required this.proteinLevel,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'potassiumPer100g': potassiumPer100g,
      'phosphorusPer100g': phosphorusPer100g,
      'sodiumPer100g': sodiumPer100g,
      'proteinPer100g': proteinPer100g,
      'potassiumLevel': potassiumLevel.name,
      'phosphorusLevel': phosphorusLevel.name,
      'sodiumLevel': sodiumLevel.name,
      'proteinLevel': proteinLevel.name,
    };
  }

  factory FoodNutrition.fromJson(Map<String, dynamic> json) {
    return FoodNutrition(
      id: json['id'] ?? '',
      name: json['name'] ?? 'غير معروف',
      potassiumPer100g: (json['potassiumPer100g'] as num?)?.toDouble() ?? 0.0,
      phosphorusPer100g: (json['phosphorusPer100g'] as num?)?.toDouble() ?? 0.0,
      sodiumPer100g: (json['sodiumPer100g'] as num?)?.toDouble() ?? 0.0,
      proteinPer100g: (json['proteinPer100g'] as num?)?.toDouble() ?? 0.0,
      potassiumLevel: _parseStatus(json['potassiumLevel']),
      phosphorusLevel: _parseStatus(json['phosphorusLevel']),
      sodiumLevel: _parseStatus(json['sodiumLevel']),
      proteinLevel: _parseStatus(json['proteinLevel']),
    );
  }

  static IndicatorStatus _parseStatus(String? status) {
    return IndicatorStatus.values.firstWhere(
      (e) => e.name == status, 
      orElse: () => IndicatorStatus.safe
    );
  }

  static IndicatorStatus calculatePotassiumLevel(double val) {
    if (val < 150) return IndicatorStatus.safe;
    if (val < 250) return IndicatorStatus.warning;
    return IndicatorStatus.critical;
  }

  static IndicatorStatus calculatePhosphorusLevel(double val) {
    if (val < 100) return IndicatorStatus.safe;
    if (val < 200) return IndicatorStatus.warning;
    return IndicatorStatus.critical;
  }

  static IndicatorStatus calculateSodiumLevel(double val) {
    if (val < 100) return IndicatorStatus.safe;
    if (val < 300) return IndicatorStatus.warning;
    return IndicatorStatus.critical;
  }

  static IndicatorStatus calculateProteinLevel(double val) {
    if (val < 5) return IndicatorStatus.safe;
    if (val < 15) return IndicatorStatus.warning;
    return IndicatorStatus.critical;
  }
}

class ResultConfig {
  final String lottieAsset;
  final String label;
  final String medicalTip;
  final dynamic color; 

  ResultConfig({
    required this.lottieAsset,
    required this.label,
    required this.medicalTip,
    required this.color,
  });
}
