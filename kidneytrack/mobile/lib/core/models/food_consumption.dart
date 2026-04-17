class FoodConsumption {
  final String id;
  final String patientId;
  final String foodName;
  final String brand;
  final double gramsConsumed;

  // Nutrients for this specific consumption (calculated based on grams)
  final double potassium;
  final double phosphorus;
  final double sodium;
  final double protein;
  final double calories;

  final double? calcium;
  final double? sugars;
  final double? carbohydrates;
  final double? totalFat;

  final String dataSource; // 'sfda', 'off', 'manual'
  final DateTime consumedAt;

  FoodConsumption({
    required this.id,
    required this.patientId,
    required this.foodName,
    required this.brand,
    required this.gramsConsumed,
    required this.potassium,
    required this.phosphorus,
    required this.sodium,
    required this.protein,
    required this.calories,
    this.calcium,
    this.sugars,
    this.carbohydrates,
    this.totalFat,
    required this.dataSource,
    required this.consumedAt,
  });

  factory FoodConsumption.fromJson(Map<String, dynamic> json) {
    return FoodConsumption(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      foodName: json['foodName'] as String,
      brand: json['brand'] as String,
      gramsConsumed: (json['gramsConsumed'] as num).toDouble(),
      potassium: (json['potassium'] as num).toDouble(),
      phosphorus: (json['phosphorus'] as num).toDouble(),
      sodium: (json['sodium'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      calories: (json['calories'] as num).toDouble(),
      calcium: (json['calcium'] as num?)?.toDouble(),
      sugars: (json['sugars'] as num?)?.toDouble(),
      carbohydrates: (json['carbohydrates'] as num?)?.toDouble(),
      totalFat: (json['totalFat'] as num?)?.toDouble(),
      dataSource: json['dataSource'] as String? ?? 'off',
      consumedAt: DateTime.parse(json['consumedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'foodName': foodName,
      'brand': brand,
      'gramsConsumed': gramsConsumed,
      'potassium': potassium,
      'phosphorus': phosphorus,
      'sodium': sodium,
      'protein': protein,
      'calories': calories,
      if (calcium != null) 'calcium': calcium,
      if (sugars != null) 'sugars': sugars,
      if (carbohydrates != null) 'carbohydrates': carbohydrates,
      if (totalFat != null) 'totalFat': totalFat,
      'dataSource': dataSource,
      'consumedAt': consumedAt.toIso8601String(),
    };
  }
}
