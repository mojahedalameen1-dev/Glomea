import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/models/lab_result.dart';
import '../../../core/models/fluid_intake.dart';
import '../../../core/models/daily_reading.dart';
import '../../../core/models/food_consumption.dart';
import '../../medications/models/medication_log.dart';
import '../../auth/providers/auth_provider.dart';

enum HistoryFilter {
  week,    // last 7 days
  month,   // last 30 days
  threeMonths,
  sixMonths,
  year,
}

extension HistoryFilterX on HistoryFilter {
  DateTime get cutoffDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return switch (this) {
      HistoryFilter.week        => today.subtract(const Duration(days: 7)),
      HistoryFilter.month       => today.subtract(const Duration(days: 30)),
      HistoryFilter.threeMonths => today.subtract(const Duration(days: 90)),
      HistoryFilter.sixMonths   => today.subtract(const Duration(days: 180)),
      HistoryFilter.year        => today.subtract(const Duration(days: 365)),
    };
  }

  String get label {
    return switch (this) {
      HistoryFilter.week        => 'أسبوع',
      HistoryFilter.month       => 'شهر',
      HistoryFilter.threeMonths => '٣ أشهر',
      HistoryFilter.sixMonths   => '٦ أشهر',
      HistoryFilter.year        => 'سنة',
    };
  }
}

/// Provider for lab results (generic)
final labHistoryProvider = FutureProvider.family<List<LabResult>, ({String indicatorCode, HistoryFilter filter})>((ref, arg) async {
  final supabase = Supabase.instance.client;
  final patient = ref.read(authNotifierProvider).value;
  if (patient == null) return [];

  final data = await supabase
      .from('LabResult')
      .select()
      .eq('patientId', patient.id)
      .eq('indicatorCode', arg.indicatorCode)
      .gte('recordedAt', arg.filter.cutoffDate.toIso8601String())
      .order('recordedAt', ascending: true);

  return (data as List).map((json) => LabResult.fromJson(json)).toList();
});

/// Provider for daily readings (weight, BP, sugar)
final dailyReadingsHistoryProvider = FutureProvider.family<List<DailyReading>, HistoryFilter>((ref, filter) async {
  final supabase = Supabase.instance.client;
  final patient = ref.read(authNotifierProvider).value;
  if (patient == null) return [];

  final data = await supabase
      .from('daily_readings')
      .select()
      .eq('patient_id', patient.id)
      .gte('reading_date', filter.cutoffDate.toIso8601String().substring(0, 10))
      .order('reading_date', ascending: true);

  return (data as List).map((json) => DailyReading.fromJson(json)).toList();
});

/// Provider for fluid intake logs
final fluidIntakeHistoryProvider = FutureProvider.family<List<FluidIntake>, HistoryFilter>((ref, filter) async {
  final supabase = Supabase.instance.client;
  final patient = ref.read(authNotifierProvider).value;
  if (patient == null) return [];

  final data = await supabase
      .from('FluidIntake')
      .select()
      .eq('patientId', patient.id)
      .gte('loggedAt', filter.cutoffDate.toIso8601String())
      .order('loggedAt', ascending: true);

  return (data as List).map((json) => FluidIntake.fromJson(json)).toList();
});

/// Provider for medication logs history
final medicationHistoryProvider = FutureProvider.family<List<MedicationLog>, HistoryFilter>((ref, filter) async {
  final supabase = Supabase.instance.client;
  final patient = ref.read(authNotifierProvider).value;
  if (patient == null) return [];

  final data = await supabase
      .from('medication_logs')
      .select('*, medications(*)')
      .eq('patient_id', patient.id)
      .gte('scheduled_at', filter.cutoffDate.toIso8601String())
      .order('scheduled_at', ascending: false);

  return (data as List).map((json) => MedicationLog.fromJson(json)).toList();
});

/// Provider for food consumption history
final foodHistoryProvider = FutureProvider.family<List<FoodConsumption>, HistoryFilter>((ref, filter) async {
  final supabase = Supabase.instance.client;
  final patient = ref.read(authNotifierProvider).value;
  if (patient == null) return [];

  final data = await supabase
      .from('FoodConsumption')
      .select()
      .eq('patientId', patient.id)
      .gte('consumedAt', filter.cutoffDate.toIso8601String())
      .order('consumedAt', ascending: false);

  return (data as List).map((json) => FoodConsumption.fromJson(json)).toList();
});

/// Provider for daily aggregated fluid totals
final fluidIntakeTrendProvider = FutureProvider.family<Map<DateTime, double>, HistoryFilter>((ref, filter) async {
  final intake = await ref.watch(fluidIntakeHistoryProvider(filter).future);
  
  final Map<DateTime, double> aggregated = {};
  for (final entry in intake) {
    final date = DateTime(entry.consumedAt.year, entry.consumedAt.month, entry.consumedAt.day);
    aggregated[date] = (aggregated[date] ?? 0) + entry.amountMl;
  }
  return aggregated;
});

/// Provider to check if any nutrient data has ever been logged
final nutrientDataExistsProvider = FutureProvider<bool>((ref) async {
  final supabase = Supabase.instance.client;
  final patient = ref.read(authNotifierProvider).value;
  if (patient == null) return false;

  final response = await supabase
      .from('daily_readings')
      .select('id')
      .or('potassium_mg.not.is.null,sodium_mg.not.is.null,protein_g.not.is.null,phosphorus_mg.not.is.null')
      .limit(1)
      .maybeSingle();

  return response != null;
});

/// Provider for daily nutrient totals (used by Dashboard)
final dailyNutrientTotalsProvider = FutureProvider<Map<String, double>>((ref) async {
  final supabase = Supabase.instance.client;
  final patient = ref.read(authNotifierProvider).value;
  if (patient == null) return {};

  final today = DateTime.now().toIso8601String().substring(0, 10);
  final data = await supabase
      .from('daily_readings')
      .select('potassium_mg, sodium_mg, protein_g, phosphorus_mg')
      .eq('patient_id', patient.id)
      .eq('reading_date', today)
      .maybeSingle();

  if (data == null) {
    return {
      'potassium': 0.0,
      'sodium': 0.0,
      'protein': 0.0,
      'phosphorus': 0.0,
    };
  }

  return {
    'potassium': (data['potassium_mg'] as num?)?.toDouble() ?? 0.0,
    'sodium': (data['sodium_mg'] as num?)?.toDouble() ?? 0.0,
    'protein': (data['protein_g'] as num?)?.toDouble() ?? 0.0,
    'phosphorus': (data['phosphorus_mg'] as num?)?.toDouble() ?? 0.0,
  };
});

