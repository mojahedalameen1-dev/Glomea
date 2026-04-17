import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:kidneytrack_mobile/core/theme/app_colors.dart';
import 'package:kidneytrack_mobile/core/theme/app_text_styles.dart';
import 'package:kidneytrack_mobile/core/services/unified_alert_service.dart';
import 'package:kidneytrack_mobile/core/providers/unified_alert_provider.dart';

import 'package:kidneytrack_mobile/core/widgets/feedback/premium_empty_state.dart';
import 'package:kidneytrack_mobile/l10n/app_localizations.dart';

class AlertsScreen extends ConsumerStatefulWidget {
  const AlertsScreen({super.key});

  @override
  ConsumerState<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends ConsumerState<AlertsScreen> {
  String _filter = 'الكل';
  final List<String> _filters = ['الكل', 'حرجة', 'تحذير', 'معلومات'];

  @override
  Widget build(BuildContext context) {
    final alertsAsync = ref.watch(unifiedAlertsProvider);

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        title: Text('تنبيهات السلامة', style: AppTextStyles.h2),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            onPressed: () async {
              final user = ref
                  .read(unifiedAlertsProvider)
                  .valueOrNull
                  ?.firstOrNull
                  ?.patientId;
              if (user != null) {
                await UnifiedAlertService.markAllRead(user);
                ref.invalidate(unifiedAlertsProvider);
                ref.invalidate(unreadAlertsCountProvider);
              }
            },
            tooltip: 'تحديد الكل كمقروء',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterRow(),
          Expanded(
            child: alertsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) =>
                  Center(child: Text('خطأ في جلب التنبيهات: $err')),
              data: (alerts) {
                final filteredAlerts = alerts.where((a) {
                  if (_filter == 'الكل') return true;
                  if (_filter == 'حرجة') {
                    return a.severity == AlertSeverity.critical;
                  }
                  if (_filter == 'تحذير') {
                    return a.severity == AlertSeverity.warning;
                  }
                  if (_filter == 'معلومات') {
                    return a.severity == AlertSeverity.info;
                  }
                  return false;
                }).toList();

                if (filteredAlerts.isEmpty) return _buildEmptyState();

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredAlerts.length,
                  separatorBuilder: (context, index) => const Gap(12),
                  itemBuilder: (context, index) =>
                      _AlertCard(alert: filteredAlerts[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterRow() {
    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filters.length,
        itemBuilder: (context, i) {
          final isSelected = _filter == _filters[i];
          return GestureDetector(
            onTap: () => setState(() => _filter = _filters[i]),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(
                        color:
                            isSelected ? AppColors.primary : Colors.transparent,
                        width: 2)),
              ),
              child: Text(_filters[i],
                  style: AppTextStyles.bodyM.copyWith(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textSecondary)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return const PremiumEmptyState(
      icon: Icons.notifications_off_outlined,
      title: 'لا توجد تنبيهات جديدة',
      subtitle: 'كل شيء على ما يرام، استمر في اتباع خطتك العلاجية 💚',
      baseColor: AppColors.textSuccess,
    );
  }
}

class _AlertCard extends ConsumerWidget {
  final UnifiedAlert alert;

  const _AlertCard({required this.alert});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCritical = alert.severity == AlertSeverity.critical;
    final isWarning = alert.severity == AlertSeverity.warning;
    final color = isCritical
        ? AppColors.textCritical
        : (isWarning ? AppColors.textWarning : AppColors.textInfo);

    return InkWell(
      onTap: () async {
        if (!alert.isRead) {
          await UnifiedAlertService.markRead(alert.id);
          ref.invalidate(unifiedAlertsProvider);
          ref.invalidate(unreadAlertsCountProvider);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: alert.isRead
              ? AppColors.bgSurface
              : color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: alert.isRead
                ? AppColors.borderBase
                : color.withValues(alpha: 0.3),
            width: alert.isRead ? 1 : 2,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getIcon(alert.category),
                color: color,
                size: 24,
              ),
            ),
            const Gap(16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        _getCategoryLabel(alert.category),
                        style: AppTextStyles.bodyS.copyWith(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        DateFormat('yyyy/MM/dd HH:mm').format(alert.createdAt),
                        style: AppTextStyles.bodyS
                            .copyWith(color: Colors.grey[500]),
                      ),
                    ],
                  ),
                  const Gap(8),
                  Text(
                    alert.messageAr,
                    style: AppTextStyles.bodyM.copyWith(
                      fontWeight:
                          alert.isRead ? FontWeight.normal : FontWeight.bold,
                      height: 1.4,
                    ),
                  ),
                  if (!alert.isRead &&
                      alert.severity != AlertSeverity.info) ...[
                    const Gap(12),
                    Text(
                      AppLocalizations.of(context)!.medicalDisclaimer,
                      style: AppTextStyles.bodyS.copyWith(
                        color: color.withValues(alpha: 0.8),
                        fontStyle: FontStyle.italic,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.05, end: 0);
  }

  IconData _getIcon(AlertCategory category) {
    switch (category) {
      case AlertCategory.nutrition:
        return Icons.restaurant_rounded;
      case AlertCategory.medical:
        return Icons.medical_services_rounded;
      case AlertCategory.lab:
        return Icons.biotech_rounded;
      case AlertCategory.fluid:
        return Icons.water_drop_rounded;
      case AlertCategory.vital:
        return Icons.favorite_rounded;
    }
  }

  String _getCategoryLabel(AlertCategory category) {
    switch (category) {
      case AlertCategory.nutrition:
        return 'تنبيه تغذية';
      case AlertCategory.medical:
        return 'تنبيه دوائي';
      case AlertCategory.lab:
        return 'نتائج مخبرية';
      case AlertCategory.fluid:
        return 'إدارة السوائل';
      case AlertCategory.vital:
        return 'مؤشرات حيوية';
    }
  }
}
