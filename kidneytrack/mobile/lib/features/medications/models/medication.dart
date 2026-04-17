class Medication {
  final String id;
  final String patientId;
  final String name;
  final String dose;
  final String frequency;
  final List<String> times;
  final DateTime startDate;
  final DateTime? endDate;
  final String? notes;
  final bool isActive;
  final String? medicationKey;
  final bool isNephrotoxic;
  final bool needsDoseAdjustment;
  final String? renalWarning;

  Medication({
    required this.id,
    required this.patientId,
    required this.name,
    required this.dose,
    required this.frequency,
    required this.times,
    required this.startDate,
    this.endDate,
    this.notes,
    this.isActive = true,
    this.medicationKey,
    this.isNephrotoxic = false,
    this.needsDoseAdjustment = false,
    this.renalWarning,
  });

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      id: json['id'],
      patientId: json['patient_id'],
      name: json['name'],
      dose: json['dose'],
      frequency: json['frequency'],
      times: List<String>.from(json['times']),
      startDate: DateTime.parse(json['start_date']),
      endDate:
          json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
      notes: json['notes'],
      isActive: json['is_active'] ?? true,
      medicationKey: json['medication_key'],
      isNephrotoxic: json['is_nephrotoxic'] ?? false,
      needsDoseAdjustment: json['needs_dose_adjustment'] ?? false,
      renalWarning: json['renal_warning'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'patient_id': patientId,
      'name': name,
      'dose': dose,
      'frequency': frequency,
      'times': times,
      'start_date': startDate.toIso8601String().split('T')[0],
      'end_date': endDate?.toIso8601String().split('T')[0],
      'notes': notes,
      'is_active': isActive,
      'medication_key': medicationKey,
      'is_nephrotoxic': isNephrotoxic,
      'needs_dose_adjustment': needsDoseAdjustment,
      'renal_warning': renalWarning,
    };
  }

  String get nextDoseTime {
    if (times.isEmpty) return '--:--';
    final now = DateTime.now();
    final currentTime =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    final sortedTimes = List<String>.from(times)..sort();
    for (final time in sortedTimes) {
      if (time.compareTo(currentTime) > 0) {
        return time;
      }
    }
    return sortedTimes.first;
  }
}
