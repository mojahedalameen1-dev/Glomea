import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/health_constants.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/models/medical_models.dart';
import '../../../core/models/lab_result.dart';
import '../../../core/services/medical_calculator_service.dart';

final medicalInsightsProvider = FutureProvider<MedicalInsights>((ref) async {
  final authState = ref.watch(authNotifierProvider);
  final patient = authState.valueOrNull;
  if (patient == null || patient.fullName == null) {
    return MedicalInsights(
      bpAnalysis: BloodPressureAnalysis.empty(),
      potassiumStatus: PotassiumDailyStatus(
        consumed: 0,
        limit: HealthConstants.defaultPotassiumLimitMg,
        percentage: 0,
        status: 'safe',
        remaining: HealthConstants.defaultPotassiumLimitMg.toDouble(),
      ),
      isEarlyDeterioration: false,
    );
  }

  final supabase = Supabase.instance.client;

  // Fetch recent readings (last 7 days for common indicators)
  final sevenDaysAgo =
      DateTime.now().subtract(const Duration(days: 7)).toIso8601String();

  final labData = await supabase
      .from('LabResult')
      .select()
      .eq('patientId', patient.id)
      .gte('recordedAt', sevenDaysAgo)
      .order('recordedAt', ascending: false);

  final List<LabResult> readings =
      (labData as List).map((json) => LabResult.fromJson(json)).toList();

  // Helper to get latest value for a code
  double? getLatest(String code) {
    try {
      return readings.firstWhere((r) => r.indicatorCode == code).value;
    } catch (_) {
      return null;
    }
  }

  // 1. eGFR Calculation
  final latestCreatinine = getLatest('CREAT');
  final egfr = latestCreatinine != null
      ? MedicalCalculatorService.calculateEGFR(
          creatinineMgDl: latestCreatinine,
          ageYears: patient.ageYears,
          gender: patient.gender ?? 'male',
        )
      : null;

  // 2. Fluid Overload
  final latestWeight = getLatest('WEIGHT') ?? patient.weightKg;
  final fluidOverload = (latestWeight != null && patient.dryWeightKg != null)
      ? MedicalCalculatorService.calculateFluidOverload(
          currentWeightKg: latestWeight,
          dryWeightKg: patient.dryWeightKg!,
        )
      : null;

  // 3. Blood Pressure Analysis
  // Need to fetch BP specifically if not in LabResult or structured differently
  // Assuming BP is stored in LabResult with codes 'SYS' and 'DIA' for this implementation
  final sysReadings = readings.where((r) => r.indicatorCode == 'SYS').toList();
  final diaReadings = readings.where((r) => r.indicatorCode == 'DIA').toList();

  List<BPReading> bpReadings = [];
  for (var sys in sysReadings) {
    // Find matching diastolic by timestamp (approximate or exact)
    try {
      final dia =
          diaReadings.firstWhere((d) => d.recordedAt.day == sys.recordedAt.day);
      bpReadings.add(BPReading(
        systolic: sys.value.toInt(),
        diastolic: dia.value.toInt(),
        timestamp: sys.recordedAt,
      ));
    } catch (_) {}
  }

  final bpAnalysis = MedicalCalculatorService.analyzeBP(
    weeklyReadings: bpReadings,
    targetSystolic: patient.targetSystolic,
    targetDiastolic: patient.targetDiastolic,
  );

  // 4. Potassium Status
  final todayPotassium = readings
      .where((r) =>
          r.indicatorCode == 'K' && r.recordedAt.day == DateTime.now().day)
      .fold(0.0, (sum, r) => sum + r.value);

  final potassiumStatus = MedicalCalculatorService.calculatePotassiumStatus(
    consumedMg: todayPotassium,
    limitMg: patient.potassiumLimitMg,
  );

  // 5. Early Deterioration (Creatinine trend)
  final creatinineHistory = readings
      .where((r) => r.indicatorCode == 'CREAT')
      .map((r) => r.value)
      .toList()
      .reversed
      .toList();

  final isDeterioration =
      MedicalCalculatorService.detectEarlyDeterioration(creatinineHistory);

  return MedicalInsights(
    egfr: egfr,
    kidneyStage:
        egfr != null ? MedicalCalculatorService.getKidneyStage(egfr) : null,
    fluidOverload: fluidOverload,
    bpAnalysis: bpAnalysis,
    potassiumStatus: potassiumStatus,
    isEarlyDeterioration: isDeterioration,
  );
});
