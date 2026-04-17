import 'dart:math';
import 'package:flutter/material.dart';
import '../models/medical_models.dart';

class MedicalCalculatorService {
  // 1. eGFR (CKD-EPI Formula)
  static double calculateEGFR({
    required double creatinineMgDl,
    required int ageYears,
    required String gender, // 'male' or 'female'
  }) {
    final k = gender.toLowerCase() == 'female' ? 0.7 : 0.9;
    final a = gender.toLowerCase() == 'female' ? -0.241 : -0.302;
    final creatRatio = creatinineMgDl / k;

    double egfr = (142 *
        pow(min(creatRatio, 1.0), a) *
        pow(max(creatRatio, 1.0), -1.200) *
        pow(0.9938, ageYears.toDouble())).toDouble();

    if (gender.toLowerCase() == 'female') egfr *= 1.012;
    return egfr;
  }

  // 2. Kidney Stage from eGFR
  static KidneyStageInfo getKidneyStage(double egfr) {
    if (egfr >= 90) {
      return KidneyStageInfo(
          stage: 'G1', label: 'طبيعي أو مرتفع', color: Colors.green, risk: 'low');
    }
    if (egfr >= 60) {
      return KidneyStageInfo(
          stage: 'G2', label: 'انخفاض خفيف', color: Colors.lightGreen, risk: 'low');
    }
    if (egfr >= 45) {
      return KidneyStageInfo(
          stage: 'G3a', label: 'انخفاض خفيف-متوسط', color: Colors.yellow, risk: 'moderate');
    }
    if (egfr >= 30) {
      return KidneyStageInfo(
          stage: 'G3b', label: 'انخفاض متوسط-شديد', color: Colors.orange, risk: 'high');
    }
    if (egfr >= 15) {
      return KidneyStageInfo(
          stage: 'G4', label: 'انخفاض شديد', color: Colors.deepOrange, risk: 'very_high');
    }
    return KidneyStageInfo(
        stage: 'G5', label: 'فشل كلوي', color: Colors.red, risk: 'critical');
  }

  // 3. Fluid Overload
  static FluidOverloadInfo calculateFluidOverload({
    required double currentWeightKg,
    required double dryWeightKg,
  }) {
    final overloadKg = currentWeightKg - dryWeightKg;
    final overloadMl = overloadKg * 1000;

    FluidStatus status;
    if (overloadKg <= 0.5) {
      status = FluidStatus.normal;
    } else if (overloadKg <= 1.5) {
      status = FluidStatus.mild;
    } else if (overloadKg <= 2.5) {
      status = FluidStatus.moderate;
    } else {
      status = FluidStatus.severe;
    }

    return FluidOverloadInfo(
      overloadKg: overloadKg,
      overloadMl: overloadMl,
      status: status,
      message: _getFluidMessage(status, overloadKg),
    );
  }

  static String _getFluidMessage(FluidStatus status, double kg) {
    switch (status) {
      case FluidStatus.normal:
        return 'وضع السوائل طبيعي';
      case FluidStatus.mild:
        return 'زيادة طفيفة في السوائل (+${kg.toStringAsFixed(1)} كجم)';
      case FluidStatus.moderate:
        return 'احتباس سوائل متوسط (+${kg.toStringAsFixed(1)} كجم)';
      case FluidStatus.severe:
        return 'احتباس سوائل شديد! (+${kg.toStringAsFixed(1)} كجم)';
    }
  }

  // 4. Weekly Blood Pressure Analysis
  static BloodPressureAnalysis analyzeBP({
    required List<BPReading> weeklyReadings,
    required int targetSystolic,
    required int targetDiastolic,
  }) {
    if (weeklyReadings.isEmpty) return BloodPressureAnalysis.empty();

    final avgSystolic =
        weeklyReadings.map((r) => r.systolic).reduce((a, b) => a + b) /
            weeklyReadings.length;
    final avgDiastolic =
        weeklyReadings.map((r) => r.diastolic).reduce((a, b) => a + b) /
            weeklyReadings.length;

    final trend = _calculateTrend(
        weeklyReadings.map((r) => r.systolic.toDouble()).toList());

    final controlRate = weeklyReadings.where((r) =>
            r.systolic <= targetSystolic && r.diastolic <= targetDiastolic).length /
        weeklyReadings.length *
        100;

    return BloodPressureAnalysis(
      avgSystolic: avgSystolic,
      avgDiastolic: avgDiastolic,
      trend: trend,
      controlRate: controlRate,
      isControlled: controlRate >= 70,
    );
  }

  static String _calculateTrend(List<double> values) {
    if (values.length < 2) return 'stable';
    final first = values.first;
    final last = values.last;
    final diff = last - first;
    if (diff > 5) return 'rising';
    if (diff < -5) return 'falling';
    return 'stable';
  }

  // 5. Daily Potassium Status
  static PotassiumDailyStatus calculatePotassiumStatus({
    required double consumedMg,
    required int limitMg,
  }) {
    final percentage = (consumedMg / limitMg * 100).clamp(0.0, 150.0);

    return PotassiumDailyStatus(
      consumed: consumedMg,
      limit: limitMg,
      percentage: percentage,
      status: percentage < 70
          ? 'safe'
          : percentage < 90
              ? 'caution'
              : percentage < 100
                  ? 'warning'
                  : 'danger',
      remaining: max(0, limitMg - consumedMg).toDouble(),
    );
  }

  // 6. Medication Adherence
  static double calculateMedicationAdherence({
    required int takenDoses,
    required int totalDoses,
  }) {
    if (totalDoses == 0) return 100.0;
    return (takenDoses / totalDoses * 100).clamp(0, 100);
  }

  // 7. Early Deterioration Detection
  static bool detectEarlyDeterioration(List<double> readings) {
    if (readings.length < 3) return false;
    final last3 = readings.sublist(readings.length - 3);
    return last3[0] < last3[1] && last3[1] < last3[2]; // Rising creatinine
  }
}
