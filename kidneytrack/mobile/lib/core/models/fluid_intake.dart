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
      id: json['id'],
      patientId: json['patientId'],
      amountMl: json['amountMl'] as int,
      consumedAt: DateTime.parse(json['loggedAt'] ?? json['consumedAt']),
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
