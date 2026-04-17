import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/services/alert_triggers.dart';

final dailyEntryProvider = StateNotifierProvider<DailyEntryNotifier, AsyncValue<void>>((ref) {
  return DailyEntryNotifier(ref);
});

class DailyEntryNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;
  DailyEntryNotifier(this._ref) : super(const AsyncValue.data(null));

  Future<bool> saveReading({
    required String patientId,
    double? weightKg,
    int? systolic,
    int? diastolic,
    double? bloodSugar,
    int? fluidIntakeMl,
    String? notes,
    int? potassiumMg,
    int? sodiumMg,
    double? proteinG,
    int? phosphorusMg,
  }) async {
    state = const AsyncLoading();
    try {
      final supabase = Supabase.instance.client;
      
      await supabase
        .from('daily_readings')
        .upsert({
          'patient_id':      patientId,
          'reading_date':    DateTime.now().toIso8601String().substring(0, 10),
          'weight_kg':       weightKg,
          'systolic':        systolic,
          'diastolic':       diastolic,
          'blood_sugar':     bloodSugar,
          'fluid_intake_ml': fluidIntakeMl,
          'notes':           notes,
          'potassium_mg':    potassiumMg,
          'sodium_mg':       sodiumMg,
          'protein_g':       proteinG,
          'phosphorus_mg':   phosphorusMg,
        },
        onConflict: 'patient_id,reading_date',
      );

      // Trigger Alerts
      final patient = _ref.read(authNotifierProvider).value;
      if (patient != null) {
        // 1. Point-in-time alerts (BP, Sodium)
        AlertTriggers.checkAndNotify(
          patient: patient,
          systolic: systolic?.toDouble(),
          diastolic: diastolic?.toDouble(),
          dailySodiumMg: sodiumMg?.toDouble(),
        );

        // 2. Daily nutrient overload alerts
        await AlertTriggers.checkDailyNutrientsAndAlert(patient, {
          'potassium': potassiumMg?.toDouble() ?? 0,
          'sodium': sodiumMg?.toDouble() ?? 0,
          'protein': proteinG ?? 0,
          'phosphorus': phosphorusMg?.toDouble() ?? 0,
          'fluid': fluidIntakeMl?.toDouble() ?? 0,
        });
      }

      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }
}
