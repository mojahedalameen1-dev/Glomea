import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:kidneytrack_mobile/l10n/app_localizations.dart';
import 'package:kidneytrack_mobile/core/theme/app_colors.dart';
import 'package:kidneytrack_mobile/core/theme/app_text_styles.dart';
import 'package:kidneytrack_mobile/core/theme/app_shadows.dart';
import 'package:kidneytrack_mobile/core/theme/app_types.dart';
import 'package:kidneytrack_mobile/core/constants/health_constants.dart';
import 'package:kidneytrack_mobile/core/widgets/feedback/loading_skeleton.dart';
import 'package:kidneytrack_mobile/core/widgets/layout/section_header.dart';
import 'package:kidneytrack_mobile/core/widgets/cards/status_card.dart';
import 'package:kidneytrack_mobile/core/widgets/charts/fluid_cups_widget.dart';
import '../auth/providers/auth_provider.dart';
import '../history/providers/history_provider.dart';
import './providers/dashboard_provider.dart';
import './providers/fluid_provider.dart';
import './providers/medical_insights_provider.dart';
import './widgets/medical_insight_cards.dart';
import './widgets/empty_lab_state.dart';
import './widgets/premium/premium_header.dart';
import './widgets/premium/health_iq_card.dart';
import './widgets/premium/premium_status_card.dart';
import '../../core/providers/interaction_provider.dart';
import '../../core/providers/unified_alert_provider.dart';
import '../../core/services/unified_alert_service.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final summaryAsync = ref.watch(dashboardSummaryProvider);
    final insightsAsync = ref.watch(medicalInsightsProvider);
    final authState = ref.watch(authNotifierProvider);
    final patient = authState.valueOrNull;

    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: isDark ? AppColors.premiumBgDark : AppColors.premiumBg,
      body: summaryAsync.when(
        loading: () => const DashboardSkeleton(),
        error: (err, stack) => _buildErrorState(context, ref, l10n.dashboardLoadingSummary, () => ref.invalidate(dashboardSummaryProvider)),
        data: (data) => insightsAsync.when(
          loading: () => const DashboardSkeleton(),
          error: (err, stack) => _buildErrorState(context, ref, l10n.dashboardCalculatingMetrics, () => ref.invalidate(medicalInsightsProvider)),
          data: (insights) => _buildContent(context, ref, data, insights, patient),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, String task, VoidCallback onRetry) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, size: 64, color: AppColors.textCritical),
            const Gap(16),
            Text(l10n.errorLoadingData(task), style: AppTextStyles.h3, textAlign: TextAlign.center),
            const Gap(8),
            Text(
              l10n.checkInternetRetry,
              style: AppTextStyles.bodyM,
              textAlign: TextAlign.center,
            ),
            const Gap(24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.retry),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, dynamic data, dynamic insights, dynamic patient) {
    final metrics = data['metrics'] as List?;
    final isEmpty = metrics == null || metrics.isEmpty;
    final firstName = patient?.firstName?.trim();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        PremiumDashboardHeader(
          firstName: firstName,
          unreadCount: ref.watch(unreadAlertsCountProvider).valueOrNull ?? 0,
        ),
        
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(dashboardSummaryProvider);
              ref.invalidate(medicalInsightsProvider);
            },
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              physics: const BouncingScrollPhysics(),
              children: [
                const Gap(24),
                
                if (insights.isEarlyDeterioration) ...[
                  EarlyDeteriorationAlert(
                    message: l10n.deteriorationMessage,
                  ),
                  const Gap(20),
                ],

                // Medical Insights Stack
                HealthIQCard(egfr: insights.egfr, stage: insights.kidneyStage),
                const Gap(24),
                FluidOverloadCard(
                  overloadKg: insights.fluidOverload?.overloadKg,
                  dryWeight: patient?.dryWeightKg,
                  currentWeight: insights.fluidOverload != null 
                      ? (insights.fluidOverload.overloadKg + (patient?.dryWeightKg ?? 0)) 
                      : patient?.weightKg,
                ),
                const Gap(24),
                
                // Key Metrics Grid (Premium)
                _buildPremiumStatusGrid(context, insights, isDark),
                
                const Gap(16),
                PotassiumDailyCard(status: insights.potassiumStatus),

                const Gap(24),

                // Fluid Tracking
                FluidCupsWidget(
                  completedCups: ref.watch(todayFluidIntakeProvider) ~/ 250,
                  totalCups: (data['fluidLimitMl'] ?? 1500) ~/ 250,
                  onAddCup: (count) {
                    ref.read(fluidProvider.notifier).addIntake(250);
                  },
                ),

                const Gap(32),

                // Drug Interactions
                ref.watch(drugInteractionsProvider).maybeWhen(
                  data: (interactions) {
                    if (interactions.isEmpty) return const SizedBox.shrink();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: interactions.map((inter) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.bgCriticalDark : AppColors.bgCritical,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDark ? AppColors.borderCriticalDark : AppColors.borderCritical.withValues(alpha: 0.5),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.medical_information, 
                                    color: isDark ? AppColors.textCriticalDark : AppColors.textCritical,
                                  ),
                                  const Gap(8),
                                  Text(
                                    l10n.drugInteractionWarning, 
                                    style: AppTextStyles.label.copyWith(
                                      color: isDark ? AppColors.textCriticalDark : AppColors.textCritical,
                                    ),
                                  ),
                                ],
                              ),
                              const Gap(8),
                              Text(
                                inter.safetyMessage, 
                                style: AppTextStyles.bodyM.copyWith(
                                  fontWeight: FontWeight.bold, 
                                  color: isDark ? AppColors.textCriticalDark : AppColors.textCritical,
                                ),
                              ),
                              const Gap(12),
                              Divider(
                                color: isDark ? AppColors.borderBaseDark : AppColors.borderCritical.withValues(alpha: 0.3),
                                height: 1,
                              ),
                              const Gap(8),
                              Text(
                                l10n.medicalDisclaimer, 
                                style: AppTextStyles.bodyS.copyWith(
                                  color: isDark ? AppColors.textCriticalDark : AppColors.textCritical,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )).toList(),
                    );
                  },
                  orElse: () => const SizedBox.shrink(),
                ),

                // Unified Alerts
                ref.watch(unifiedAlertsProvider).maybeWhen(
                  data: (alerts) {
                    final unreadSafetyAlerts = alerts
                        .where((a) => !a.isRead && (a.severity == AlertSeverity.critical || a.severity == AlertSeverity.warning))
                        .take(2)
                        .toList();

                    if (unreadSafetyAlerts.isEmpty) return const SizedBox.shrink();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: unreadSafetyAlerts.map((alert) {
                        final isCritical = alert.severity == AlertSeverity.critical;
                        final bg = isCritical 
                            ? (isDark ? AppColors.bgCriticalDark : AppColors.bgCritical)
                            : (isDark ? AppColors.bgWarningDark : AppColors.bgWarning);
                        final border = isCritical
                            ? (isDark ? AppColors.borderCriticalDark : AppColors.borderCritical)
                            : (isDark ? AppColors.borderWarningDark : AppColors.borderWarning);
                        final text = isCritical
                            ? (isDark ? AppColors.textCriticalDark : AppColors.textCritical)
                            : (isDark ? AppColors.textWarningDark : AppColors.textWarning);

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: InkWell(
                            onTap: () => context.push('/alerts'),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: bg,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: border.withValues(alpha: 0.5)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        isCritical ? Icons.warning_amber_rounded : Icons.info_outline,
                                        color: text,
                                        size: 20,
                                      ),
                                      const Gap(8),
                                      Text(
                                        isCritical ? l10n.importantAlert : l10n.safetyAlert,
                                        style: AppTextStyles.label.copyWith(color: text),
                                      ),
                                    ],
                                  ),
                                  const Gap(8),
                                  Text(
                                    alert.messageAr,
                                    style: AppTextStyles.bodyM.copyWith(fontWeight: FontWeight.bold, color: text),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                  orElse: () => const SizedBox.shrink(),
                ),

                SectionHeader(title: l10n.todayNutrition),
                const Gap(16),
                const NutrientProgressCard(),

                const Gap(32),
                SectionHeader(title: l10n.quickGlance),
                _buildQuickGlanceRow(metrics, isDark),

                const Gap(24),
                SectionHeader(title: l10n.latestLabResults),
                if (isEmpty)
                  _buildEmptyLabState(context)
                else
                  GridView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: metrics.length,
                    itemBuilder: (context, index) {
                      final m = metrics[index];
                      return StatusCard(
                        indicatorName: m['name'],
                        value: (m['value'] as num).toDouble(),
                        unit: 'mmol/L',
                        status: IndicatorStatus.values.firstWhere((e) => e.name == m['status']),
                        sparklineData: (m['sparkline'] as List).cast<double>(),
                        thresholds: m['thresholds'] as ThresholdRange,
                        onTap: () => context.push('/history/${m['code']}'),
                      );
                    },
                  ),

                const Gap(24),
                _buildStreakCard(context, 7, isDark),
                const Gap(120),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPremiumStatusGrid(BuildContext context, dynamic insights, bool isDark) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Expanded(
          child: PremiumStatusCard(
            label: l10n.heartRate,
            value: (insights.heartRate ?? 72).toStringAsFixed(0),
            unit: l10n.unitBpm,
            iconPath: 'assets/icons/3d/heart.png',
            accentColor: AppColors.primary,
          ),
        ),
        const Gap(16),
        Expanded(
          child: PremiumStatusCard(
            label: l10n.bloodPressure,
            value: insights.bpAnalysis.avgSystolic.toStringAsFixed(0),
            unit: 'mmHg',
            iconPath: 'assets/icons/3d/stethoscope.png',
            accentColor: AppColors.accent,
            isWarning: insights.bpAnalysis.avgSystolic > 140,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickGlanceRow(List? metrics, bool isDark) {
    if (metrics == null || metrics.isEmpty) return const SizedBox.shrink();
    
    return Container(
      height: 70,
      margin: const EdgeInsets.only(top: 12),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: metrics.length,
        separatorBuilder: (_, __) => const Gap(12),
        itemBuilder: (context, index) {
          final m = metrics[index];
          final isCritical = m['status'] == 'critical';
          final color = isCritical ? AppColors.textCritical : AppColors.primary;
          
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? AppColors.bgSurfaceDark : AppColors.bgSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? AppColors.borderBaseDark : color.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Text(
                  m['name'], 
                  style: AppTextStyles.label.copyWith(
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                  ),
                ),
                const Gap(8),
                Icon(
                  isCritical ? Icons.trending_up : Icons.trending_flat,
                  color: isDark && isCritical ? AppColors.textCriticalDark : color,
                  size: 16,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStreakCard(BuildContext context, int days, bool isDark) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.bgWarningDark : AppColors.bgWarning,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.borderWarningDark : AppColors.borderWarning.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          const Text('🔥', style: TextStyle(fontSize: 32)),
          const Gap(16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.consecutiveDays(days), 
                  style: AppTextStyles.label.copyWith(
                    color: isDark ? AppColors.textWarningDark : AppColors.textWarning,
                    fontSize: 18,
                  ),
                ),
                const Gap(8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: 0.7,
                    minHeight: 8,
                    backgroundColor: isDark ? AppColors.borderBaseDark : Colors.white,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isDark ? AppColors.textWarningDark : const Color(0xFFF97316),
                    ),
                  ),
                ),
                const Gap(6),
                Text(
                  l10n.streakEncouragement, 
                  style: AppTextStyles.bodyS.copyWith(
                    color: isDark ? AppColors.textWarningDark : AppColors.textWarning,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyLabState(BuildContext context) {
    return EmptyLabState(
      onAction: () => context.push('/lab-entry'),
    );
  }
}

class NutrientProgressCard extends ConsumerWidget {
  const NutrientProgressCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authState = ref.watch(authNotifierProvider);
    final patient = authState.valueOrNull;
    final totals = ref.watch(dailyNutrientTotalsProvider);
    
    final potLimit = patient?.potassiumLimitMg ?? HealthConstants.defaultPotassiumLimitMg;
    final phoLimit = patient?.phosphorusLimitMg ?? HealthConstants.defaultPhosphorusLimitMg;
    final sodLimit = patient?.sodiumLimitMg ?? HealthConstants.defaultSodiumLimitMg;
    final proLimit = patient?.proteinLimitG ?? HealthConstants.defaultProteinLimitG;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.bgSurfaceDark : AppColors.bgSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? AppColors.borderBaseDark : AppColors.borderBase.withValues(alpha: 0.1),
        ),
        boxShadow: isDark ? null : AppShadows.elev1,
      ),
      child: Column(
        children: [
          _NutrientRow(
            label: l10n.nutrientPotassium,
            current: totals.asData?.value['potassium'] ?? 0,
            limit: potLimit.toDouble(),
            unit: l10n.unitMg,
            color: Colors.orange,
          ),
          const Gap(20),
          _NutrientRow(
            label: l10n.nutrientPhosphorus,
            current: totals.asData?.value['phosphorus'] ?? 0,
            limit: phoLimit.toDouble(),
            unit: l10n.unitMg,
            color: Colors.purple,
          ),
          const Gap(20),
          _NutrientRow(
            label: l10n.nutrientSodium,
            current: totals.asData?.value['sodium'] ?? 0,
            limit: sodLimit.toDouble(),
            unit: l10n.unitMg,
            color: Colors.blue,
          ),
          const Gap(20),
          _NutrientRow(
            label: l10n.nutrientProtein,
            current: totals.asData?.value['protein'] ?? 0,
            limit: proLimit.toDouble(),
            unit: l10n.unitG,
            color: Colors.green,
          ),
        ],
      ),
    );
  }
}

class _NutrientRow extends StatelessWidget {
  final String label;
  final double current;
  final double limit;
  final String unit;
  final Color color;

  const _NutrientRow({
    required this.label,
    required this.current,
    required this.limit,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ratio = (limit > 0) ? (current / limit).clamp(0.0, 1.0) : 0.0;
    
    final l10n = AppLocalizations.of(context)!;
    // Status Logic for No-Color-Only
    final isExceeded = current > limit;
    final isApproaching = !isExceeded && ratio >= 0.75;
    
    IconData statusIcon;
    String statusText;
    Color statusColor;
    
    if (isExceeded) {
      statusIcon = Icons.block_flipped;
      statusText = l10n.statusExceeded;
      statusColor = isDark ? AppColors.textCriticalDark : AppColors.textCritical;
    } else if (isApproaching) {
      statusIcon = Icons.warning_amber_rounded;
      statusText = l10n.statusApproaching;
      statusColor = isDark ? AppColors.textWarningDark : AppColors.textWarning;
    } else {
      statusIcon = Icons.check_circle_outline_rounded;
      statusText = l10n.statusWithin;
      statusColor = isDark ? AppColors.textSuccessDark : AppColors.textSuccess;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(statusIcon, size: 16, color: statusColor),
                const Gap(8),
                Text(label, style: AppTextStyles.label.copyWith(fontSize: 14)),
                const Gap(8),
                Text(
                  '($statusText)', 
                  style: AppTextStyles.bodyS.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            Text(
              '${current.toStringAsFixed(0)} / ${limit.toStringAsFixed(0)} $unit', 
              style: AppTextStyles.bodyS.copyWith(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const Gap(10),
        Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: ratio,
                backgroundColor: isDark ? AppColors.borderBaseDark : AppColors.borderBase.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation(isExceeded ? statusColor : color),
                minHeight: 10,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
