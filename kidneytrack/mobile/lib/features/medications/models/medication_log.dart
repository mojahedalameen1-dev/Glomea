import 'medication.dart';

class MedicationLog {
  final String id;
  final String medicationId;
  final String patientId;
  final DateTime scheduledAt;
  final DateTime? takenAt;
  final String status;
  Medication? medication;

  MedicationLog({
    required this.id,
    required this.medicationId,
    required this.patientId,
    required this.scheduledAt,
    this.takenAt,
    required this.status,
  });

  factory MedicationLog.fromJson(Map<String, dynamic> json) {
    return MedicationLog(
      id: json['id'],
      medicationId: json['medication_id'],
      patientId: json['patient_id'],
      scheduledAt: DateTime.parse(json['scheduled_at']),
      takenAt:
          json['taken_at'] != null ? DateTime.parse(json['taken_at']) : null,
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'medication_id': medicationId,
      'patient_id': patientId,
      'scheduled_at': scheduledAt.toIso8601String(),
      'taken_at': takenAt?.toIso8601String(),
      'status': status,
    };
  }
}
