class DashboardSummary {
  final List<IndicatorMetric> metrics;
  final List<FluidIntakeRecord> fluidHistory;
  final List<LabResultSummary> latestLabResults;
  final int unreadAlerts;

  DashboardSummary({
    required this.metrics,
    required this.fluidHistory,
    required this.latestLabResults,
    required this.unreadAlerts,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      metrics: (json['metrics'] as List?)
              ?.map((m) => IndicatorMetric.fromJson(m))
              .toList() ??
          [],
      fluidHistory: (json['fluidHistory'] as List?)
              ?.map((f) => FluidIntakeRecord.fromJson(f))
              .toList() ??
          [],
      latestLabResults: (json['latestLabResults'] as List?)
              ?.map((l) => LabResultSummary.fromJson(l))
              .toList() ??
          [],
      unreadAlerts: json['unreadAlerts'] ?? 0,
    );
  }
}

class IndicatorMetric {
  final String name;
  final double value;
  final String unit;
  final double delta;
  final List<double> sparkline;

  IndicatorMetric(
      {required this.name,
      required this.value,
      required this.unit,
      required this.delta,
      required this.sparkline});

  factory IndicatorMetric.fromJson(Map<String, dynamic> json) {
    return IndicatorMetric(
      name: json['name'] ?? '',
      value: (json['value'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit'] ?? '',
      delta: (json['delta'] as num?)?.toDouble() ?? 0.0,
      sparkline: (json['sparkline'] as List?)
              ?.map((s) => (s as num).toDouble())
              .toList() ??
          [],
    );
  }
}

class FluidIntakeRecord {
  final DateTime date;
  final int amountMl;

  FluidIntakeRecord({required this.date, required this.amountMl});

  factory FluidIntakeRecord.fromJson(Map<String, dynamic> json) {
    return FluidIntakeRecord(
      date: DateTime.parse(json['date']),
      amountMl: json['amountMl'],
    );
  }
}

class LabResultSummary {
  final String indicatorCode;
  final String indicatorNameAr;
  final double value;
  final String status;
  final List<double> sparkline;

  LabResultSummary({
    required this.indicatorCode,
    required this.indicatorNameAr,
    required this.value,
    required this.status,
    required this.sparkline,
  });

  factory LabResultSummary.fromJson(Map<String, dynamic> json) {
    return LabResultSummary(
      indicatorCode: json['indicatorCode'] ?? '',
      indicatorNameAr: json['indicatorNameAr'] ?? '',
      value: (json['value'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? '',
      sparkline: (json['sparkline'] as List?)
              ?.map((s) => (s as num).toDouble())
              .toList() ??
          [],
    );
  }
}
