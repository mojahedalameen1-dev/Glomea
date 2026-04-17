/// Conversion factors: mmol/L → mg/dL for each indicator.
/// Values are stored in Supabase always in mg/dL (or native unit).
/// Conversion happens only in the presentation layer.

library;

const Map<String, double> _mmolToMgFactors = {
  'creatinine': 88.42,
  'CREAT': 88.42,
  'urea': 2.801,
  'UREA': 2.801,
  'potassium': 39.1,
  'K': 39.1,
  'sodium': 23.0,
  'NA': 23.0,
  'hemoglobin': 1.611,
  'HGB': 1.611,
  'phosphorus': 3.097,
  'PHOS': 3.097,
  'phosphorus_blood': 3.097,
  'calcium': 4.008,
  'glucose': 18.02,
  'cholesterol': 38.67,
  'total_cholesterol': 38.67,
  'ldl': 38.67,
  'triglycerides': 88.57,
};

/// Convert a value from mmol/L → mg/dL.
double convertToMg(String indicatorCode, double mmolValue) {
  final factor = _mmolToMgFactors[indicatorCode] ?? 1.0;
  return mmolValue * factor;
}

/// Convert a value from mg/dL → mmol/L.
double convertToMmol(String indicatorCode, double mgValue) {
  final factor = _mmolToMgFactors[indicatorCode] ?? 1.0;
  if (factor == 0) return mgValue;
  return mgValue / factor;
}

/// Whether this indicator supports mmol ↔ mg conversion.
bool supportsConversion(String indicatorCode) {
  return _mmolToMgFactors.containsKey(indicatorCode);
}
