class LabResult {
  final String? id;
  final String patientId;
  final String indicatorCode;
  final double value;
  final String unit;
  final DateTime recordedAt;
  final String? imageUrl;

  LabResult({
    this.id,
    required this.patientId,
    required this.indicatorCode,
    required this.value,
    required this.unit,
    required this.recordedAt,
    this.imageUrl,
  });

  factory LabResult.fromJson(Map<String, dynamic> json) {
    return LabResult(
      id: json['id'],
      patientId: json['patientId'],
      indicatorCode: json['indicatorCode'],
      value: (json['value'] as num).toDouble(),
      unit: json['unit'],
      recordedAt: DateTime.parse(json['recordedAt']),
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'patientId': patientId,
      'indicatorCode': indicatorCode,
      'value': value,
      'unit': unit,
      'recordedAt': recordedAt.toIso8601String(),
      if (imageUrl != null) 'imageUrl': imageUrl,
    };
  }
}
