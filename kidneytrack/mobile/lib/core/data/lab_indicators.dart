///   note        : extra clinical note shown in UI (optional)

library;

import 'package:kidneytrack_mobile/l10n/app_localizations.dart';

const Map<String, Map<String, dynamic>> labIndicators = {
  // ─── Existing indicators ───────────────────────────────────────────────────
  'CREAT': {
    'nameAr': 'الكرياتينين',
    'unit': 'mg/dL',
    'normalMin': 0.7,
    'normalMax': 1.3,
    'warningMax': 5.0,
    'criticalMax': 15.0,
  },
  'K': {
    'nameAr': 'البوتاسيوم',
    'unit': 'mEq/L',
    'normalMin': 3.5,
    'normalMax': 5.0,
    'warningMin': 3.0,
    'warningMax': 5.5,
    'criticalMin': 2.0,
    'criticalMax': 8.0,
  },
  'UREA': {
    'nameAr': 'اليوريا',
    'unit': 'mg/dL',
    'normalMin': 10.0,
    'normalMax': 50.0,
    'warningMax': 100.0,
    'criticalMax': 200.0,
  },
  'NA': {
    'nameAr': 'الصوديوم',
    'unit': 'mEq/L',
    'normalMin': 135.0,
    'normalMax': 145.0,
    'warningMin': 130.0,
    'warningMax': 150.0,
    'criticalMin': 110.0,
    'criticalMax': 170.0,
  },
  'HGB': {
    'nameAr': 'الهيموجلوبين',
    'unit': 'g/dL',
    'normalMin': 12.0,
    'normalMax': 16.0,
    'warningMin': 9.0,
    'warningMax': 18.0,
    'criticalMin': 5.0,
    'criticalMax': 20.0,
  },
  'PHOS': {
    'nameAr': 'الفوسفور',
    'unit': 'mg/dL',
    'normalMin': 3.0,
    'normalMax': 4.5,
    'warningMax': 5.5,
    'criticalMax': 15.0,
    'criticalMin': 1.0,
  },

  // ─── New indicators ────────────────────────────────────────────────────────
  'hba1c': {
    'nameAr': 'السكر التراكمي (HbA1c)',
    'unit': '%',
    'normalMin': 4.0,
    'normalMax': 7.0,
    'warningMax': 8.5,
    'note': 'مهم لمرضى الكلى السكريين',
  },
  'total_cholesterol': {
    'nameAr': 'الكوليسترول الكلي',
    'unit': 'mg/dL',
    'normalMax': 200.0,
    'warningMax': 239.0,
  },
  'ldl': {
    'nameAr': 'LDL الكوليسترول الضار',
    'unit': 'mg/dL',
    'normalMax': 100.0,
    'warningMax': 130.0,
  },
  'triglycerides': {
    'nameAr': 'الدهون الثلاثية',
    'unit': 'mg/dL',
    'normalMax': 150.0,
    'warningMax': 200.0,
  },
  'calcium': {
    'nameAr': 'الكالسيوم',
    'unit': 'mg/dL',
    'normalMin': 8.4,
    'normalMax': 10.2,
    'warningMin': 7.5,
    'warningMax': 11.0,
  },
  'vitamin_d': {
    'nameAr': 'فيتامين D',
    'unit': 'ng/mL',
    'normalMin': 30.0,
    'warningMin': 20.0,
    'criticalMin': 10.0,
  },
  'phosphorus_blood': {
    'nameAr': 'فوسفور الدم',
    'unit': 'mg/dL',
    'normalMin': 2.5,
    'normalMax': 4.5,
    'warningMax': 5.5,
  },
  'urine_acr': {
    'nameAr': 'ألبومين/كرياتينين البول',
    'unit': 'mg/g',
    'normalMax': 30.0,
    'warningMax': 300.0,
  },
};

String getLocalizedLabName(String indicatorCode, AppLocalizations l10n) {
  switch (indicatorCode) {
    case 'CREAT': return l10n.labCreatinine;
    case 'K': return l10n.labPotassium;
    case 'UREA': return l10n.labUrea;
    case 'NA': return l10n.labSodium;
    case 'HGB': return l10n.labHemoglobin;
    case 'PHOS': return l10n.labPhosphorus;
    case 'hba1c': return l10n.labHbA1c;
    case 'total_cholesterol': return l10n.labTotalCholesterol;
    case 'ldl': return l10n.labLDL;
    case 'triglycerides': return l10n.labTriglycerides;
    case 'calcium': return l10n.labCalcium;
    case 'vitamin_d': return l10n.labVitaminD;
    case 'phosphorus_blood': return l10n.labBloodPhosphorus;
    case 'urine_acr': return l10n.labUrineACR;
    default: return indicatorCode;
  }
}

/// Returns a user-facing localized warning message for [indicatorCode] at [value],
/// or null if the value is within the normal range.
String? getLabWarning(String indicatorCode, double value, AppLocalizations l10n) {
  final indicator = labIndicators[indicatorCode];
  if (indicator == null) return null;

  final warningMax = indicator['warningMax'] as double?;
  final normalMax = indicator['normalMax'] as double?;
  final warningMin = indicator['warningMin'] as double?;
  final normalMin = indicator['normalMin'] as double?;
  final name = getLocalizedLabName(indicatorCode, l10n);

  if (warningMax != null && value > warningMax) {
    return l10n.labWarningCriticalHigh(name);
  }
  if (normalMax != null && value > normalMax) {
    return l10n.labWarningHigh(name);
  }
  if (warningMin != null && value < warningMin) {
    return l10n.labWarningCriticalLow(name);
  }
  if (normalMin != null && value < normalMin) {
    return l10n.labWarningLow(name);
  }
  return null;
}

/// Returns the normal range as a readable string for display.
String getLabRangeLabel(String indicatorCode) {
  final ind = labIndicators[indicatorCode];
  if (ind == null) return '';
  final min = ind['normalMin'];
  final max = ind['normalMax'];
  final unit = ind['unit'] ?? '';
  if (min != null && max != null) return '$min – $max $unit';
  if (max != null) return '< $max $unit';
  if (min != null) return '> $min $unit';
  return '';
}
