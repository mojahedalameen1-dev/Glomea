import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/unified_alert_service.dart';
import '../../features/auth/providers/auth_provider.dart';

final unifiedAlertsProvider = FutureProvider<List<UnifiedAlert>>((ref) async {
  final patient = ref.watch(authNotifierProvider).valueOrNull;
  if (patient == null) return [];
  
  return await UnifiedAlertService.fetchAll(patient.id);
});

final unreadAlertsCountProvider = FutureProvider<int>((ref) async {
  final patient = ref.watch(authNotifierProvider).valueOrNull;
  if (patient == null) return 0;
  
  final unread = await UnifiedAlertService.fetchUnread(patient.id);
  return unread.length;
});
