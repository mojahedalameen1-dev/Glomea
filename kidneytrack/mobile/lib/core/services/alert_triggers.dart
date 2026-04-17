import 'package:kidneytrack_mobile/l10n/app_localizations.dart';
import '../models/patient.dart';
import '../data/lab_indicators.dart';
import 'notification_service.dart';
import 'unified_alert_service.dart';

class Alert {
  final String type;
  final String message;
  final String severity;

  const Alert({
    required this.type,
    required this.message,
    required this.severity,
  });
}

class AlertRule {
  final String name;
  final String condition;
  final String message;
  final String severity;

  const AlertRule({
    required this.name,
    required this.condition,
    required this.message,
    required this.severity,
  });
}

class AlertTriggers {
  // Mobile Alerts for Patient
  static const patientAlerts = [
    AlertRule(
      name: 'fluid_overload',
      condition: 'currentWeight - dryWeight > 2.5',
      message: '⚠️ وزنك زاد أكثر من 2.5 كيلو — احتباس سوائل خطير',
      severity: 'high',
    ),
    AlertRule(
      name: 'high_bp',
      condition: 'systolic > 180 || diastolic > 110',
      message: '🔴 ضغط الدم مرتفع جداً — اتصل بطبيبك فوراً',
      severity: 'critical',
    ),
    AlertRule(
      name: 'potassium_exceeded',
      condition: 'todayPotassium > potassiumLimit',
      message: '🫘 تجاوزت حد البوتاسيوم اليومي',
      severity: 'medium',
    ),
    AlertRule(
      name: 'creatinine_rising',
      condition: 'detectEarlyDeterioration(creatinineHistory)',
      message: '📈 الكرياتينين يرتفع — راجع طبيبك',
      severity: 'high',
    ),
  ];

  /// Checks various health parameters and generates alerts + notifications.
  static List<Alert> checkAndNotify({
    required Patient patient,
    double? systolic,
    double? diastolic,
    double? dailySodiumMg,
    String? indicatorCode,
    double? value,
    AppLocalizations? l10n,
  }) {
    final List<Alert> alerts = [];

    // 1. Custom Blood Pressure Warning
    if (systolic != null && diastolic != null) {
      if (systolic > patient.targetSystolic + 10 ||
          diastolic > patient.targetDiastolic + 10) {
        alerts.add(Alert(
          type: 'bp_above_target',
          message: 'ضغط دمك ($systolic/$diastolic) أعلى من هدفك '
                   '(${patient.targetSystolic}/${patient.targetDiastolic}) — '
                   'استرِح وقِس مجدداً بعد 10 دقائق، وأبلغ طبيبك إذا استمر',
          severity: 'high',
        ));
      }
    }

    // 2. Sodium Warning
    if (dailySodiumMg != null && dailySodiumMg > patient.sodiumLimitMg) {
      alerts.add(Alert(
        type: 'sodium_limit_exceeded',
        message: '⚠️ تجاوزت حد الصوديوم المسموح به اليوم (${patient.sodiumLimitMg} ملجم) — '
                 'تجنب الأطعمة المملحة لبقية اليوم للحفاظ على استقرار ضغطك سوائلك',
        severity: 'medium',
      ));
    }

    // 3. Lab Indicator Warning
    if (indicatorCode != null && value != null && l10n != null) {
      final warning = getLabWarning(indicatorCode, value, l10n);
      if (warning != null) {
        alerts.add(Alert(
          type: 'lab_warning',
          message: warning,
          severity: warning.contains('🔴') ? 'high' : 'medium',
        ));
      }
    }

    // Trigger local notifications for each alert
    for (final alert in alerts) {
      NotificationService.showNotification(
        id: alert.type.hashCode,
        title: 'تنبيه صحي من جلوميا',
        body: alert.message,
        channelId: 'glomea_channel',
      );
    }
    
    return alerts;
  }

  /// Checks nutrient overloads, records them via UnifiedAlertService once per day, and triggers notifications.
  static Future<List<String>> checkDailyNutrientsAndAlert(
      Patient patient, Map<String, double> totals) async {
    final List<String> activeOverloads = [];

    Future<void> evaluateLimit(String nutrientKey, String labelAr,
        double current, double limit) async {
      if (current > limit) {
        activeOverloads.add(nutrientKey);
        final alertType = '${nutrientKey.toUpperCase()}_OVERLOAD';
        final message = '⚠️ تجاوزت الحد المسموح به من $labelAr اليوم. يرجى الحذر! للتوعية فقط ولا يغني عن استشارة الطبيب.';

        // UnifiedAlertService handles deduplication via day_bucket unique index
        await UnifiedAlertService.logAlert(
          patientId: patient.id,
          category: nutrientKey == 'fluid' ? AlertCategory.fluid : AlertCategory.nutrition,
          severity: AlertSeverity.warning,
          alertType: alertType,
          messageAr: message,
          relatedEntityId: null,
          showNotification: true,
        );
      }
    }

    await evaluateLimit('potassium', 'البوتاسيوم', totals['potassium'] ?? 0, patient.potassiumLimitMg.toDouble());
    await evaluateLimit('phosphorus', 'الفوسفور', totals['phosphorus'] ?? 0, patient.phosphorusLimitMg.toDouble());
    await evaluateLimit('sodium', 'الصوديوم', totals['sodium'] ?? 0, patient.sodiumLimitMg.toDouble());
    await evaluateLimit('protein', 'البروتين', totals['protein'] ?? 0, patient.proteinLimitG.toDouble());
    await evaluateLimit('fluid', 'السوائل', totals['fluid'] ?? 0, patient.fluidLimitMl.toDouble());

    return activeOverloads;
  }

  // Web Alerts for Doctor
  static const doctorAlerts = [
    AlertRule(
      name: 'critical_egfr_drop',
      condition: 'egfr dropped > 25% in 30 days',
      message: 'تدهور سريع في وظائف الكلى للمريض',
      severity: 'critical',
    ),
    AlertRule(
      name: 'missed_medications',
      condition: 'adherence < 50% for 3 days',
      message: 'المريض لم يأخذ أدويته 3 أيام متتالية',
      severity: 'high',
    ),
    AlertRule(
      name: 'no_readings',
      condition: 'no readings for 3 days',
      message: 'المريض لم يسجّل أي قراءات منذ 3 أيام',
      severity: 'medium',
    ),
  ];
}

