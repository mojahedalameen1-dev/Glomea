class SystemMedication {
  final String id;
  final String key;
  final String nameAr;
  final String nameEn;
  final String category;
  final bool isNephrotoxic;
  final bool needsDoseAdj;
  final bool raisesPotassium;

  const SystemMedication({
    required this.id,
    required this.key,
    required this.nameAr,
    required this.nameEn,
    required this.category,
    required this.isNephrotoxic,
    required this.needsDoseAdj,
    required this.raisesPotassium,
  });

  factory SystemMedication.fromJson(Map<String, dynamic> json) {
    return SystemMedication(
      id: json['id'] as String? ?? '',
      key: json['key'] as String,
      nameAr: json['name_ar'] as String,
      nameEn: json['name_en'] as String,
      category: json['category'] as String,
      isNephrotoxic: json['is_nephrotoxic'] as bool? ?? false,
      needsDoseAdj: json['needs_dose_adj'] as bool? ?? false,
      raisesPotassium: json['raises_potassium'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'key': key,
      'name_ar': nameAr,
      'name_en': nameEn,
      'category': category,
      'is_nephrotoxic': isNephrotoxic,
      'needs_dose_adj': needsDoseAdj,
      'raises_potassium': raisesPotassium,
    };
  }
}
