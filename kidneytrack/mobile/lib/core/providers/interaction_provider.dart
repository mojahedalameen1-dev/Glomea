import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'system_medications_provider.dart';
import '../../features/history/providers/history_provider.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/medications/providers/medications_provider.dart';
import '../services/medication_warning_engine.dart';
import '../models/system_medication.dart';
import 'localization_provider.dart';

final activeSystemMedicationsProvider = FutureProvider<List<SystemMedication>>((ref) async {
  final systemMedsAsync = ref.watch(systemMedicationsProvider);
  if (systemMedsAsync.valueOrNull == null) return [];
  final systemMeds = systemMedsAsync.value!;

  final userMedsState = ref.watch(medicationsProvider);
  final userMeds = userMedsState.medications;

  if (userMeds.isEmpty) return [];

  List<SystemMedication> activeSystemMeds = [];
  for (var uMed in userMeds) {
    if (uMed.medicationKey != null) {
      final match = systemMeds.where((sm) => sm.key == uMed.medicationKey).firstOrNull;
      if (match != null) {
        activeSystemMeds.add(match);
      }
    }
  }
  return activeSystemMeds;
});

final drugInteractionsProvider = FutureProvider<List<DrugNutrientInteractionResult>>((ref) async {
  final patientAsync = ref.watch(authNotifierProvider);
  if (patientAsync.valueOrNull == null) return [];
  final patient = patientAsync.value!;

  final activeSystemMedsAsync = ref.watch(activeSystemMedicationsProvider);
  if (activeSystemMedsAsync.valueOrNull == null) return [];
  final activeSystemMeds = activeSystemMedsAsync.value!;

  if (activeSystemMeds.isEmpty) return [];

  final totals = await ref.watch(dailyNutrientTotalsProvider.future);
  final l10n = ref.watch(appLocalizationsProvider);

  return MedicationWarningEngine.evaluateDrugNutrientInteractions(activeSystemMeds, totals, patient, l10n);
});

final medicationRisksProvider = FutureProvider<Map<String, List<MedicationRiskResult>>>((ref) async {
  final patientAsync = ref.watch(authNotifierProvider);
  if (patientAsync.valueOrNull == null) return {};
  final patient = patientAsync.value!;

  final systemMedsAsync = ref.watch(systemMedicationsProvider);
  if (systemMedsAsync.valueOrNull == null) return {};
  final systemMeds = systemMedsAsync.value!;

  final userMedsState = ref.watch(medicationsProvider);
  final userMeds = userMedsState.medications;
  final l10n = ref.watch(appLocalizationsProvider);

  if (userMeds.isEmpty) return {};

  final Map<String, List<MedicationRiskResult>> risks = {};

  for (var uMed in userMeds) {
    if (uMed.medicationKey != null) {
      final match = systemMeds.where((sm) => sm.key == uMed.medicationKey).firstOrNull;
      if (match != null) {
        final riskList = MedicationWarningEngine.evaluateMedicationRisks(match, patient, l10n);
        if (riskList.isNotEmpty) {
          risks[uMed.id] = riskList; // Mapped by user medication ID
        }
      }
    }
  }

  return risks;
});
