import 'medication_warning_engine.dart';
import 'package:kidneytrack_mobile/l10n/app_localizations.dart';

enum WarningType {
  nephrotoxicRisk,
  doseAdjustmentRequired,
  potassiumInteraction,
  phosphorusInteraction,
  sodiumInteraction,
}

class WarningTextMapper {
  /// Returns the localized message for a given [WarningType] and [Severity].
  /// Caller injects medication name or nutrient name via [entityName].
  static String getMedicationRiskMessage({
    required AppLocalizations l10n,
    required WarningType type,
    required Severity severity,
    required String entityName,
  }) {
    switch (type) {
      case WarningType.nephrotoxicRisk:
        return l10n.nephrotoxicWarning(entityName);
      case WarningType.doseAdjustmentRequired:
        if (severity == Severity.critical) {
          return l10n.doseAdjustmentCritical(entityName);
        }
        return l10n.doseAdjustmentWarning(entityName);
      case WarningType.potassiumInteraction:
        return l10n.potassiumInteractionWarning(entityName);
      case WarningType.phosphorusInteraction:
        return l10n.phosphorusInteractionWarning(entityName);
      case WarningType.sodiumInteraction:
        return l10n.sodiumInteractionWarning(entityName);
    }
  }

  /// Returns the title shown in warning banners based on [Severity].
  static String getBannerTitle(AppLocalizations l10n, Severity severity) {
    switch (severity) {
      case Severity.critical:
        return l10n.medicalBannerTitleCritical;
      case Severity.warning:
        return l10n.medicalBannerTitleWarning;
      case Severity.info:
        return l10n.medicalBannerTitleInfo;
    }
  }

  /// Returns the standard disclaimer.
  static String getDisclaimer(AppLocalizations l10n) => l10n.medicalDisclaimer;

  /// Appends the mandatory CKD disclaimer to any warning message.
  static String withDisclaimer(AppLocalizations l10n, String message) =>
      '$message ${l10n.medicalDisclaimer}.';

  /// Returns true if a disclaimer must be shown for this severity level.
  static bool requiresDisclaimer(Severity severity) =>
      severity == Severity.warning || severity == Severity.critical;
}
