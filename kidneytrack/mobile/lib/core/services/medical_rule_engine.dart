import 'package:flutter/material.dart';
import '../models/patient.dart';
import '../models/food_nutrition.dart';

class MedicalRuleEngine {
  /// Defines recommended daily limits based on CKD stage.
  /// Protein is defined in g/kg of body weight.
  static Map<String, Map<String, num>> get stageDefaults => {
    'G1': {
      'sodium': 2300,
      'potassium': 3500, 
      'phosphorus': 1200,
      'protein': 0.8, 
      'fluid': 2000,
    },
    'G2': {
      'sodium': 2300,
      'potassium': 3500,
      'phosphorus': 1200,
      'protein': 0.8,
      'fluid': 2000,
    },
    'G3a': {
      'sodium': 2000,
      'potassium': 2500,
      'phosphorus': 1000,
      'protein': 0.6,
      'fluid': 1500,
    },
    'G3b': {
      'sodium': 1800,
      'potassium': 2000,
      'phosphorus': 800,
      'protein': 0.6,
      'fluid': 1500,
    },
    'G4': {
      'sodium': 1500,
      'potassium': 2000,
      'phosphorus': 800,
      'protein': 0.6,
      'fluid': 1200,
    },
    'G5': {
      'sodium': 1500,
      'potassium': 2000,
      'phosphorus': 800,
      'protein': 0.6,
      'fluid': 1000,
    },
  };

  /// Gets recommended limits for a specific patient based on their stage and weight.
  static Map<String, int> getRecommendedLimits(Patient patient) {
    final stage = patient.kidneyStage ?? 'G3a';
    final defaults = stageDefaults[stage] ?? stageDefaults['G3a']!;
    
    final weight = patient.weightKg ?? 70.0;
    final recommendedProtein = (defaults['protein']! * weight).round();
    
    return {
      'sodium': defaults['sodium']!.toInt(),
      'potassium': defaults['potassium']!.toInt(),
      'phosphorus': defaults['phosphorus']!.toInt(),
      'protein': recommendedProtein,
      'fluid': defaults['fluid']!.toInt(),
    };
  }

  /// Evaluates a single food serving against per-serving thresholds.
  /// These are safety nets to flag "super-foods" (e.g. extremely salty).
  static Map<String, IndicatorStatus> evaluateServing({
    required double sodium,
    required double potassium,
    required double phosphorus,
    required double protein,
  }) {
    return {
      'sodium': _statusFromThreshold(sodium, 100, 300),
      'potassium': _statusFromThreshold(potassium, 150, 250),
      'phosphorus': _statusFromThreshold(phosphorus, 100, 200),
      'protein': _statusFromThreshold(protein, 5, 15),
    };
  }

  /// Evaluates daily total consumption against patient limits.
  static Map<String, IndicatorStatus> evaluateDailyTotal(Patient patient, {
    required double sodium,
    required double potassium,
    required double phosphorus,
    required double protein,
    required double fluid,
  }) {
    return {
      'sodium': _statusFromLimit(sodium, patient.sodiumLimitMg.toDouble()),
      'potassium': _statusFromLimit(potassium, patient.potassiumLimitMg.toDouble()),
      'phosphorus': _statusFromLimit(phosphorus, patient.phosphorusLimitMg.toDouble()),
      'protein': _statusFromLimit(protein, patient.proteinLimitG.toDouble()),
      'fluid': _statusFromLimit(fluid, patient.fluidLimitMl.toDouble()),
    };
  }

  static IndicatorStatus _statusFromThreshold(double val, double low, double high) {
    if (val < low) return IndicatorStatus.safe;
    if (val < high) return IndicatorStatus.warning;
    return IndicatorStatus.critical;
  }

  static IndicatorStatus _statusFromLimit(double current, double limit) {
    if (limit <= 0) return IndicatorStatus.safe;
    final ratio = current / limit;
    if (ratio < 0.75) return IndicatorStatus.safe;
    if (ratio < 1.0) return IndicatorStatus.warning;
    return IndicatorStatus.critical;
  }

  /// Returns a colored-coded verdict for a general indicator value.
  static Color getStatusColor(IndicatorStatus status) {
    switch (status) {
      case IndicatorStatus.safe:
        return Colors.green;
      case IndicatorStatus.warning:
        return Colors.orange;
      case IndicatorStatus.critical:
        return Colors.red;
    }
  }
}
