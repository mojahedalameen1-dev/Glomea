import 'package:flutter/material.dart';

class KidneyStageInfo {
  final String stage;
  final String label;
  final Color color;
  final String risk;

  KidneyStageInfo({
    required this.stage,
    required this.label,
    required this.color,
    required this.risk,
  });
}

enum FluidStatus { normal, mild, moderate, severe }

class FluidOverloadInfo {
  final double overloadKg;
  final double overloadMl;
  final FluidStatus status;
  final String message;

  FluidOverloadInfo({
    required this.overloadKg,
    required this.overloadMl,
    required this.status,
    required this.message,
  });
}

class BPReading {
  final int systolic;
  final int diastolic;
  final DateTime timestamp;

  BPReading({
    required this.systolic,
    required this.diastolic,
    required this.timestamp,
  });
}

class BloodPressureAnalysis {
  final double avgSystolic;
  final double avgDiastolic;
  final String trend; // 'rising' | 'falling' | 'stable'
  final double controlRate;
  final bool isControlled;

  BloodPressureAnalysis({
    required this.avgSystolic,
    required this.avgDiastolic,
    required this.trend,
    required this.controlRate,
    required this.isControlled,
  });

  factory BloodPressureAnalysis.empty() {
    return BloodPressureAnalysis(
      avgSystolic: 0,
      avgDiastolic: 0,
      trend: 'stable',
      controlRate: 0,
      isControlled: true,
    );
  }
}

class PotassiumDailyStatus {
  final double consumed;
  final int limit;
  final double percentage;
  final String status; // 'safe' | 'caution' | 'warning' | 'danger'
  final double remaining;

  PotassiumDailyStatus({
    required this.consumed,
    required this.limit,
    required this.percentage,
    required this.status,
    required this.remaining,
  });
}

class MedicalInsights {
  final double? egfr;
  final KidneyStageInfo? kidneyStage;
  final FluidOverloadInfo? fluidOverload;
  final BloodPressureAnalysis bpAnalysis;
  final PotassiumDailyStatus potassiumStatus;
  final bool isEarlyDeterioration;

  MedicalInsights({
    this.egfr,
    this.kidneyStage,
    this.fluidOverload,
    required this.bpAnalysis,
    required this.potassiumStatus,
    this.isEarlyDeterioration = false,
  });
}
