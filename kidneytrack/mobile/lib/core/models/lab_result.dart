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
      id: json['id'] as String?,
      patientId: json['patientId'] as String? ?? '',
      indicatorCode: json['indicatorCode'] as String? ?? '',
      value: (json['value'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit'] as String? ?? '',
      recordedAt: json['recordedAt'] != null
          ? DateTime.parse(json['recordedAt'] as String)
          : DateTime.now(),
      imageUrl: json['imageUrl'] as String?,
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
