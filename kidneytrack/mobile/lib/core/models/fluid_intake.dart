class FluidIntake {
  final String? id;
  final String patientId;
  final int amountMl;
  final DateTime consumedAt;

  FluidIntake({
    this.id,
    required this.patientId,
    required this.amountMl,
    required this.consumedAt,
  });

  factory FluidIntake.fromJson(Map<String, dynamic> json) {
    return FluidIntake(
      id: json['id'] as String?,
      patientId: json['patientId'] as String? ?? '',
      amountMl: json['amountMl'] as int? ?? 0,
      consumedAt: json['loggedAt'] != null 
          ? DateTime.parse(json['loggedAt'] as String)
          : json['consumedAt'] != null
              ? DateTime.parse(json['consumedAt'] as String)
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'patientId': patientId,
      'amountMl': amountMl,
      'loggedAt': consumedAt.toIso8601String(),
    };
  }
}
