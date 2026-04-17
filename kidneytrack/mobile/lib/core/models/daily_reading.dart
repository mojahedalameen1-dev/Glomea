class DailyReading {
  final String? patientId;
  final DateTime date;
  final double? weightKg;
  final int? systolic;
  final int? diastolic;
  final double? bloodSugar;
  final int? fluidIntakeMl;
  final String? notes;
  final int? potassiumMg;
  final int? sodiumMg;
  final double? proteinG;
  final int? phosphorusMg;

  int? get bloodSugarMgDl => bloodSugar?.toInt();

  DailyReading({
    this.patientId,
    required this.date,
    this.weightKg,
    this.systolic,
    this.diastolic,
    this.bloodSugar,
    this.fluidIntakeMl,
    this.notes,
    this.potassiumMg,
    this.sodiumMg,
    this.proteinG,
    this.phosphorusMg,
  });

  factory DailyReading.fromJson(Map<String, dynamic> json) {
    return DailyReading(
      patientId: json['patient_id'],
      date: DateTime.parse(json['reading_date']),
      weightKg: json['weight_kg']?.toDouble(),
      systolic: json['systolic']?.toInt(),
      diastolic: json['diastolic']?.toInt(),
      bloodSugar: json['blood_sugar']?.toDouble(),
      fluidIntakeMl: json['fluid_intake_ml']?.toInt(),
      notes: json['notes'],
      potassiumMg: json['potassium_mg']?.toInt(),
      sodiumMg: json['sodium_mg']?.toInt(),
      proteinG: json['protein_g']?.toDouble(),
      phosphorusMg: json['phosphorus_mg']?.toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'patient_id': patientId,
      'reading_date': date.toIso8601String().substring(0, 10),
      'weight_kg': weightKg,
      'systolic': systolic,
      'diastolic': diastolic,
      'blood_sugar': bloodSugar,
      'fluid_intake_ml': fluidIntakeMl,
      'notes': notes,
      'potassium_mg': potassiumMg,
      'sodium_mg': sodiumMg,
      'protein_g': proteinG,
      'phosphorus_mg': phosphorusMg,
    };
  }
}
