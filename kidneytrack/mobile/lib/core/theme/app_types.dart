enum IndicatorStatus {
  safe,
  warning,
  critical,
}

enum MedicalSeverity {
  normal, // Class A
  info, // Class B
  warning, // Class C
  critical, // Class D
}

class ThresholdRange {
  final double safeMin;
  final double safeMax;
  final double warningMin;
  final double warningMax;
  final double? criticalMin;
  final double? criticalMax;

  const ThresholdRange({
    required this.safeMin,
    required this.safeMax,
    required this.warningMin,
    required this.warningMax,
    this.criticalMin,
    this.criticalMax,
  });
}
