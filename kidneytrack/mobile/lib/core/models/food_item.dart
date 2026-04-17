class FoodItem {
  final String id;
  final String name;
  final String brand;
  final String? imageUrl;
  final double? servingSize;

  final double? potassium;
  final double? phosphorus;
  final double? sodium;
  final double? calcium;
  final double? protein;
  final double? sugars;
  final double? calories;
  final double? carbohydrates;
  final double? totalFat;

  final String dataSource; // 'sfda', 'off', 'manual'
  final Map<String, double?>? labelValues; // For conflict detection

  FoodItem({
    required this.id,
    required this.name,
    required this.brand,
    this.imageUrl,
    this.servingSize,
    this.potassium,
    this.phosphorus,
    this.sodium,
    this.calcium,
    this.protein,
    this.sugars,
    this.calories,
    this.carbohydrates,
    this.totalFat,
    this.dataSource = 'off',
    this.labelValues,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'brand': brand,
        'imageUrl': imageUrl,
        'servingSize': servingSize,
        'potassium': potassium,
        'phosphorus': phosphorus,
        'sodium': sodium,
        'calcium': calcium,
        'protein': protein,
        'sugars': sugars,
        'calories': calories,
        'carbohydrates': carbohydrates,
        'totalFat': totalFat,
        'dataSource': dataSource,
        'labelValues': labelValues,
      };

  factory FoodItem.fromJson(Map<String, dynamic> json) => FoodItem(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        brand: json['brand'] as String? ?? '',
        imageUrl: json['imageUrl'] as String?,
        servingSize: (json['servingSize'] as num?)?.toDouble(),
        potassium: (json['potassium'] as num?)?.toDouble(),
        phosphorus: (json['phosphorus'] as num?)?.toDouble(),
        sodium: (json['sodium'] as num?)?.toDouble(),
        calcium: (json['calcium'] as num?)?.toDouble(),
        protein: (json['protein'] as num?)?.toDouble(),
        sugars: (json['sugars'] as num?)?.toDouble(),
        calories: (json['calories'] as num?)?.toDouble(),
        carbohydrates: (json['carbohydrates'] as num?)?.toDouble(),
        totalFat: (json['totalFat'] as num?)?.toDouble(),
        dataSource: json['dataSource'] as String? ?? 'off',
        labelValues: (json['labelValues'] as Map?)?.cast<String, double?>(),
      );

  FoodItem copyWith({
    String? id,
    String? name,
    String? brand,
    String? imageUrl,
    double? servingSize,
    double? potassium,
    double? phosphorus,
    double? sodium,
    double? calcium,
    double? protein,
    double? sugars,
    double? calories,
    double? carbohydrates,
    double? totalFat,
    String? dataSource,
    Map<String, double?>? labelValues,
  }) {
    return FoodItem(
      id: id ?? this.id,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      imageUrl: imageUrl ?? this.imageUrl,
      servingSize: servingSize ?? this.servingSize,
      potassium: potassium ?? this.potassium,
      phosphorus: phosphorus ?? this.phosphorus,
      sodium: sodium ?? this.sodium,
      calcium: calcium ?? this.calcium,
      protein: protein ?? this.protein,
      sugars: sugars ?? this.sugars,
      calories: calories ?? this.calories,
      carbohydrates: carbohydrates ?? this.carbohydrates,
      totalFat: totalFat ?? this.totalFat,
      dataSource: dataSource ?? this.dataSource,
      labelValues: labelValues ?? this.labelValues,
    );
  }
}
