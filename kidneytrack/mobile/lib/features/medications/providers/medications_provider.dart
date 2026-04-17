import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/medication.dart';
import '../models/medication_log.dart';
import '../../../core/services/notification_service.dart';

class MedicationsState {
  final List<Medication> medications;
  final List<MedicationLog> todayLogs;
  final bool isLoading;

  MedicationsState({
    this.medications = const [],
    this.todayLogs = const [],
    this.isLoading = false,
  });

  MedicationsState copyWith({
    List<Medication>? medications,
    List<MedicationLog>? todayLogs,
    bool? isLoading,
  }) {
    return MedicationsState(
      medications: medications ?? this.medications,
      todayLogs: todayLogs ?? this.todayLogs,
      isLoading: isLoading ?? this.isLoading,
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
    state = state.copyWith(isLoading: true);

    try {
      final medsData = await _supabase
          .from('medications')
          .select()
          .eq('patient_id', _userId!)
          .eq('is_active', true)
          .order('created_at');

      final medications = (medsData as List).map((m) => Medication.fromJson(m)).toList();

      // Load today's logs
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day).toIso8601String();
      final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59).toIso8601String();

      final logsData = await _supabase
          .from('medication_logs')
          .select()
          .eq('patient_id', _userId!)
          .gte('scheduled_at', startOfDay)
          .lte('scheduled_at', endOfDay);

      final todayLogs = (logsData as List).map((l) => MedicationLog.fromJson(l)).toList();

      state = state.copyWith(
        medications: medications,
        todayLogs: todayLogs,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> addMedication(Medication medication) async {
    try {
      final data = medication.toJson();
      final response = await _supabase.from('medications').insert(data).select().single();
      final newMed = Medication.fromJson(response);
      
      state = state.copyWith(medications: [...state.medications, newMed]);
      
      await _scheduleNotifications(newMed);
      await _generateInitialLogs(newMed);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> markAsTaken(String logId) async {
    try {
      await _supabase.from('medication_logs').update({
        'status': 'taken',
        'taken_at': DateTime.now().toIso8601String(),
      }).eq('id', logId);

      state = state.copyWith(
        todayLogs: state.todayLogs.map((l) => l.id == logId 
          ? MedicationLog.fromJson({
              ...l.toJson(), 
              'id': l.id, 
              'status': 'taken', 
              'taken_at': DateTime.now().toIso8601String()
            }) 
          : l).toList(),
      );
    } catch (e) {
      // Error marking as taken
    }
  }

  Future<void> _scheduleNotifications(Medication med) async {
    for (final time in med.times) {
      final parts = time.split(':');
      await NotificationService.scheduleDaily(
        id: med.id.hashCode + med.times.indexOf(time),
        title: '💊 وقت الدواء',
        body: '${med.name} — ${med.dose}',
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    }
  }

  Future<void> _generateInitialLogs(Medication med) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    final List<Map<String, dynamic>> logs = [];
    for (final timeStr in med.times) {
      final parts = timeStr.split(':');
      final scheduledAt = today.add(Duration(hours: int.parse(parts[0]), minutes: int.parse(parts[1])));
      
      logs.add({
        'medication_id': med.id,
        'patient_id': med.patientId,
        'scheduled_at': scheduledAt.toIso8601String(),
        'status': 'pending',
      });
    }

    if (logs.isNotEmpty) {
      await _supabase.from('medication_logs').insert(logs);
      await loadMedications(); // Refresh to get logs
    }
  }
}

final medicationsProvider = StateNotifierProvider<MedicationsNotifier, MedicationsState>((ref) {
  return MedicationsNotifier();
});
