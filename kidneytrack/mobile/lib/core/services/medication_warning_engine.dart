import '../models/patient.dart';
import '../models/system_medication.dart';
import 'warning_text_mapper.dart';
import 'package:kidneytrack_mobile/l10n/app_localizations.dart';

enum Severity { info, warning, critical }

class MedicationRiskResult {
  final Severity severity;
  final WarningType warningType;
  final String riskKey;
  final String medicationName;

  /// UI-ready message. Built by WarningTextMapper.
  final String safetyMessage;

  const MedicationRiskResult({
    required this.severity,
    required this.warningType,
    required this.riskKey,
    required this.medicationName,
    required this.safetyMessage,
  });
}

class DrugNutrientInteractionResult {
  final Severity severity;
  final WarningType warningType;
  final String nutrientType;
  final String medicationNames;

  /// UI-ready message. Built by WarningTextMapper.
  final String safetyMessage;

  const DrugNutrientInteractionResult({
    required this.severity,
    required this.warningType,
    required this.nutrientType,
    required this.medicationNames,
    required this.safetyMessage,
  });
}

class MedicationWarningEngine {
  /// Evaluates static risks associated with a medication (nephrotoxicity, renal dose adjustments).
  /// Uses eGFR primarily, falling back to CKD Stage if eGFR is unknown.
  /// Returns pure domain results — all text is generated via WarningTextMapper.
  static List<MedicationRiskResult> evaluateMedicationRisks(
      SystemMedication med, Patient patient, AppLocalizations l10n) {
    final List<MedicationRiskResult> risks = [];

    // --- Rule a: Nephrotoxic Risk ---
    if (med.isNephrotoxic) {
      final message = WarningTextMapper.withDisclaimer(
        l10n,
        WarningTextMapper.getMedicationRiskMessage(
          l10n: l10n,
          type: WarningType.nephrotoxicRisk,
          severity: Severity.critical,
          entityName: l10n.localeName == 'ar' ? med.nameAr : med.nameEn,
        ),
      );
      risks.add(MedicationRiskResult(
        severity: Severity.critical,
        warningType: WarningType.nephrotoxicRisk,
        riskKey: 'nephrotoxic_risk',
        medicationName: l10n.localeName == 'ar' ? med.nameAr : med.nameEn,
        safetyMessage: message,
      ));
    }

    // --- Rule b+c: Renal Dose Adjustment (eGFR primary, CKD stage fallback) ---
    if (med.needsDoseAdj) {
      bool needsAdjustment = false;
      bool isCritical = false;

      final egfr = patient.egfrLevel;
      if (egfr != null) {
        // b. eGFR is primary
        if (egfr < 30) {
          needsAdjustment = true;
          isCritical = true;
        } else if (egfr < 60) {
          needsAdjustment = true;
        }
      } else {
        // c. CKD stage fallback only when eGFR is unavailable
        if (patient.ckdStage >= 4) {
          needsAdjustment = true;
          isCritical = true;
        } else if (patient.ckdStage == 3) {
          needsAdjustment = true;
        }
      }

      if (needsAdjustment) {
        final severity = isCritical ? Severity.critical : Severity.warning;
        final message = WarningTextMapper.withDisclaimer(
          l10n,
          WarningTextMapper.getMedicationRiskMessage(
            l10n: l10n,
            type: WarningType.doseAdjustmentRequired,
            severity: severity,
            entityName: l10n.localeName == 'ar' ? med.nameAr : med.nameEn,
          ),
        );
        risks.add(MedicationRiskResult(
          severity: severity,
          warningType: WarningType.doseAdjustmentRequired,
          riskKey: 'dose_adjustment_risk',
          medicationName: l10n.localeName == 'ar' ? med.nameAr : med.nameEn,
          safetyMessage: message,
        ));
      }
    }

    return risks;
  }

  /// Evaluates active interactions between patient's daily nutrient totals and their drug profile.
  /// Accepts projected totals (e.g. pre-save food values included) for pre-save warnings.
  /// Returns pure domain results — all text is generated via WarningTextMapper.
  static List<DrugNutrientInteractionResult> evaluateDrugNutrientInteractions(
      List<SystemMedication> activeMeds,
      Map<String, double> nutrientTotals,
      Patient patient,
      AppLocalizations l10n) {
    final List<DrugNutrientInteractionResult> interactions = [];

    // --- Rule d: Potassium-raising medication + projected daily potassium overload ---
    final currentPotassium = nutrientTotals['potassium'] ?? 0;
    if (currentPotassium > patient.potassiumLimitMg) {
      final potassiumRaisingMeds =
          activeMeds.where((m) => m.raisesPotassium).toList();
      if (potassiumRaisingMeds.isNotEmpty) {
        final medNames = potassiumRaisingMeds
            .map((e) => l10n.localeName == 'ar' ? e.nameAr : e.nameEn)
            .join(l10n.localeName == 'ar' ? ' و ' : ', ');
        final message = WarningTextMapper.withDisclaimer(
          l10n,
          WarningTextMapper.getMedicationRiskMessage(
            l10n: l10n,
            type: WarningType.potassiumInteraction,
            severity: Severity.critical,
            entityName: medNames,
          ),
        );
        interactions.add(DrugNutrientInteractionResult(
          severity: Severity.critical,
          warningType: WarningType.potassiumInteraction,
          nutrientType: 'potassium',
          medicationNames: medNames,
          safetyMessage: message,
        ));
      }
    }

    // Stub: Phosphorus binder interactions, Sodium retention — extensible here

    return interactions;
  }
}
