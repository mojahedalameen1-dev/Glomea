import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/theme/app_types.dart';

final dashboardSummaryProvider = FutureProvider.autoDispose((ref) async {
  final authState = ref.watch(authNotifierProvider);
  final patient = authState.valueOrNull;

  if (patient == null) {
    throw Exception('المريض غير مسجل دخول');
  }

  final supabase = Supabase.instance.client;

  try {
    // 1. Fetch Lab Results
    final labResults = await supabase
        .from('LabResult')
        .select()
        .eq('patientId', patient.id)
        .order('recordedAt', ascending: false);

    final List<Map<String, dynamic>> metrics = [];
    final resultsList = labResults as List;

    void addMetric(String code, String name, double safeMin, double safeMax,
        double warningMin, double warningMax) {
      final relevant =
          resultsList.where((r) => r['indicatorCode'] == code).toList();
      if (relevant.isNotEmpty) {
        final latest = relevant.first;
        final dynamic rawValue = latest['value'];
        final double latestValue = rawValue != null ? (rawValue as num).toDouble() : 0.0;

        IndicatorStatus status = IndicatorStatus.safe;
        if (latestValue > warningMax) {
          status = IndicatorStatus.critical;
        } else if (latestValue > safeMax) {
          status = IndicatorStatus.warning;
        }

        metrics.add({
          'name': name,
          'value': latestValue,
          'code': code,
          'status': status.name,
          'sparkline': relevant
              .take(7)
              .map((r) => (r['value'] as num?)?.toDouble() ?? 0.0)
              .toList()
              .reversed
              .toList(),
          'thresholds': ThresholdRange(
            safeMin: safeMin,
            safeMax: safeMax,
            warningMin: warningMin,
            warningMax: warningMax,
          ),
        });
      }
    }

    addMetric('CREAT', 'الكرياتينين', 0.7, 1.2, 1.2, 1.5);
    addMetric('K', 'البوتاسيوم', 3.5, 5.1, 5.1, 5.5);

    // 2. Unread Alerts
    final alerts = await supabase
        .from('Alert')
        .select('id')
        .eq('patientId', patient.id)
        .eq('isRead', false);

    return {
      'metrics': metrics,
      'fluidLimitMl': patient.fluidLimitMl,
      'unreadAlertsCount': (alerts as List).length,
    };
  } catch (e) {
    debugPrint('Dashboard fetch error: $e');
    rethrow;
  }
});
