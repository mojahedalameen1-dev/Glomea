import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'notification_service.dart';

/// Category of alert — maps to the `category` column in unified_alerts.
enum AlertCategory { nutrition, medical, lab, fluid, vital }

/// Severity of alert — maps to the `severity` column in unified_alerts.
enum AlertSeverity { info, warning, critical }

/// UnifiedAlertService — Phase 5.2
///
/// Single point of entry for creating, deduplicating, and querying
/// patient-owned alerts across ALL domains (nutrition, medication, vitals).
///
/// Insert rule: One alert per (patient_id, alert_type, related_entity_id, day_bucket).
/// Alerts are never auto-expired. Critical alerts persist until read/archived by patient.
class UnifiedAlertService {
  static const _table = 'unified_alerts';

  static SupabaseClient get _db => Supabase.instance.client;

  /// Logs a patient alert; silently skips if the dedupe index would reject a duplicate.
  ///
  /// [alertType] — machine-readable key, e.g. 'potassium_overload', 'nephrotoxicity_risk'
  /// [relatedEntityId] — optional: medication id, food item id, lab result id
  static Future<void> logAlert({
    required String patientId,
    required AlertCategory category,
    required AlertSeverity severity,
    required String alertType,
    required String messageAr,
    String? relatedEntityId,
    bool showNotification = true,
  }) async {
    try {
      await _db.from(_table).upsert(
        {
          'patient_id': patientId,
          'category': category.name,
          'severity': severity.name,
          'alert_type': alertType,
          'message_ar': messageAr,
          'related_entity_id': relatedEntityId,
          'is_read': false,
          'day_bucket': DateTime.now().toIso8601String().substring(0, 10),
        },
        onConflict:
            'patient_id, alert_type, COALESCE(related_entity_id, \'\'), day_bucket',
        ignoreDuplicates: true, // no-op if same key exists today — anti-spam
      );

      if (showNotification) {
        NotificationService.showNotification(
          id: '${patientId}_${alertType}_${DateTime.now().day}'.hashCode,
          title: _notificationTitle(severity),
          body: messageAr,
          channelId: 'glomea_channel',
        );
      }
    } catch (e) {
      debugPrint('[UnifiedAlertService] logAlert error: $e');
    }
  }

  /// Fetches all unread alerts for a patient, newest first.
  static Future<List<UnifiedAlert>> fetchUnread(String patientId) async {
    try {
      final response = await _db
          .from(_table)
          .select()
          .eq('patient_id', patientId)
          .eq('is_read', false)
          .order('created_at', ascending: false);
      return (response as List<dynamic>)
          .map((e) => UnifiedAlert.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('[UnifiedAlertService] fetchUnread error: $e');
      return [];
    }
  }

  /// Fetches full alert history for a patient (read + unread), newest first.
  static Future<List<UnifiedAlert>> fetchAll(String patientId,
      {int limit = 50}) async {
    try {
      final response = await _db
          .from(_table)
          .select()
          .eq('patient_id', patientId)
          .order('created_at', ascending: false)
          .limit(limit);
      return (response as List<dynamic>)
          .map((e) => UnifiedAlert.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('[UnifiedAlertService] fetchAll error: $e');
      return [];
    }
  }

  /// Marks a single alert as read.
  static Future<void> markRead(String alertId) async {
    try {
      await _db.from(_table).update({'is_read': true}).eq('id', alertId);
    } catch (e) {
      debugPrint('[UnifiedAlertService] markRead error: $e');
    }
  }

  /// Marks all unread alerts for a patient as read.
  static Future<void> markAllRead(String patientId) async {
    try {
      await _db
          .from(_table)
          .update({'is_read': true})
          .eq('patient_id', patientId)
          .eq('is_read', false);
    } catch (e) {
      debugPrint('[UnifiedAlertService] markAllRead error: $e');
    }
  }

  static String _notificationTitle(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.critical:
        return '🔴 تحذير طبي حرج — جلوميا';
      case AlertSeverity.warning:
        return '⚠️ تنبيه صحي — جلوميا';
      case AlertSeverity.info:
        return 'ℹ️ معلومة صحية — جلوميا';
    }
  }
}

/// Domain model for a persisted unified alert row.
class UnifiedAlert {
  final String id;
  final String patientId;
  final AlertCategory category;
  final AlertSeverity severity;
  final String alertType;
  final String messageAr;
  final String? relatedEntityId;
  final bool isRead;
  final DateTime createdAt;

  const UnifiedAlert({
    required this.id,
    required this.patientId,
    required this.category,
    required this.severity,
    required this.alertType,
    required this.messageAr,
    this.relatedEntityId,
    required this.isRead,
    required this.createdAt,
  });

  factory UnifiedAlert.fromJson(Map<String, dynamic> json) {
    return UnifiedAlert(
      id: json['id'] as String,
      patientId: json['patient_id'] as String,
      category: AlertCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => AlertCategory.nutrition,
      ),
      severity: AlertSeverity.values.firstWhere(
        (e) => e.name == json['severity'],
        orElse: () => AlertSeverity.info,
      ),
      alertType: json['alert_type'] as String,
      messageAr: json['message_ar'] as String,
      relatedEntityId: json['related_entity_id'] as String?,
      isRead: json['is_read'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
