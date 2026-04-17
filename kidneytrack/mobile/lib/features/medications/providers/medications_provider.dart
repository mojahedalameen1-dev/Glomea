import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/medication.dart';
import '../models/medication_log.dart';
import '../../../core/services/notification_service.dart';

class MedicationsState {
  final List<Medication> medications;
  final List<MedicationLog> todayLogs;
  final bool isLoading;
  final String? error;

  MedicationsState({
    this.medications = const [],
    this.todayLogs = const [],
    this.isLoading = false,
    this.error,
  });

  MedicationsState copyWith({
    List<Medication>? medications,
    List<MedicationLog>? todayLogs,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return MedicationsState(
      medications: medications ?? this.medications,
      todayLogs: todayLogs ?? this.todayLogs,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class MedicationsNotifier extends StateNotifier<MedicationsState> {
  final SupabaseClient _supabase = Supabase.instance.client;

  MedicationsNotifier() : super(MedicationsState()) {
    loadMedications();
  }

  String? get _userId => _supabase.auth.currentUser?.id;

  Future<void> loadMedications() async {
    if (_userId == null) return;
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final medsData = await _supabase
          .from('medications')
          .select()
          .eq('patient_id', _userId!)
          .eq('is_active', true)
          .order('created_at');

      final medications =
          (medsData as List).map((m) => Medication.fromJson(m)).toList();

      final today = DateTime.now();
      final startOfDay =
          DateTime(today.year, today.month, today.day).toIso8601String();
      final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59)
          .toIso8601String();

      final logsData = await _supabase
          .from('medication_logs')
          .select()
          .eq('patient_id', _userId!)
          .gte('scheduled_at', startOfDay)
          .lte('scheduled_at', endOfDay);

      final todayLogs =
          (logsData as List).map((l) => MedicationLog.fromJson(l)).toList();

      state = state.copyWith(
        medications: medications,
        todayLogs: todayLogs,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'failed_to_load_medications',
      );
    }
  }

  Future<void> addMedication(Medication medication) async {
    try {
      final data = medication.toJson();
      final response =
          await _supabase.from('medications').insert(data).select().single();
      final newMed = Medication.fromJson(response);

      state = state.copyWith(medications: [...state.medications, newMed]);

      await _scheduleNotifications(newMed);
      await _generateInitialLogs(newMed);
    } catch (e) {
      rethrow;
    }
  }

  /// Marks a dose as taken.
  /// Optimistic UI update is applied immediately.
  /// On failure: UI is ROLLED BACK to prevent silent medical errors.
  Future<void> markAsTaken(String logId) async {
    // Save previous state for rollback
    final previousLogs = state.todayLogs;
    final takenAt = DateTime.now().toIso8601String();

    // Optimistic update
    state = state.copyWith(
      todayLogs: state.todayLogs
          .map((l) => l.id == logId
              ? MedicationLog.fromJson({
                  ...l.toJson(),
                  'status': 'taken',
                  'taken_at': takenAt,
                })
              : l)
          .toList(),
    );

    try {
      await _supabase.from('medication_logs').update({
        'status': 'taken',
        'taken_at': takenAt,
      }).eq('id', logId);
    } catch (e) {
      // Rollback UI — do NOT leave a false "taken" state
      state = state.copyWith(
        todayLogs: previousLogs,
        error: 'failed_to_mark_taken',
      );
    }
  }

  /// Stable notification ID derived from medication UUID bytes.
  /// Uses first 4 bytes of UUID to produce a consistent int per medication.
  int _stableNotificationId(String medId, int timeIndex) {
    final hex = medId.replaceAll('-', '');
    final base = int.parse(hex.substring(0, 8), radix: 16);
    return (base + timeIndex).abs() % 2147483647;
  }

  Future<void> _scheduleNotifications(Medication med) async {
    for (int i = 0; i < med.times.length; i++) {
      final time = med.times[i];
      final parts = time.split(':');
      await NotificationService.scheduleDaily(
        id: _stableNotificationId(med.id, i),
        title:
            '\u{1F48A} \u0648\u0642\u062a \u0627\u0644\u062f\u0648\u0627\u0621',
        body: '${med.name} \u2014 ${med.dose}',
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    }
  }

  Future<void> _generateInitialLogs(Medication med) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startOfDay = today.toIso8601String();
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59)
        .toIso8601String();

    // Check for existing logs today to prevent duplicates on retry
    final existing = await _supabase
        .from('medication_logs')
        .select('scheduled_at')
        .eq('medication_id', med.id)
        .gte('scheduled_at', startOfDay)
        .lte('scheduled_at', endOfDay);

    final existingTimes =
        (existing as List).map((e) => e['scheduled_at'] as String).toSet();

    final List<Map<String, dynamic>> logs = [];
    for (final timeStr in med.times) {
      final parts = timeStr.split(':');
      final scheduledAt = today.add(Duration(
        hours: int.parse(parts[0]),
        minutes: int.parse(parts[1]),
      ));
      final isoTime = scheduledAt.toIso8601String();

      // Only insert if this scheduled_at doesn't already exist
      if (!existingTimes.contains(isoTime)) {
        logs.add({
          'medication_id': med.id,
          'patient_id': med.patientId,
          'scheduled_at': isoTime,
          'status': 'pending',
        });
      }
    }

    if (logs.isNotEmpty) {
      await _supabase.from('medication_logs').insert(logs);
      await loadMedications();
    }
  }
}

final medicationsProvider =
    StateNotifierProvider<MedicationsNotifier, MedicationsState>((ref) {
  return MedicationsNotifier();
});
