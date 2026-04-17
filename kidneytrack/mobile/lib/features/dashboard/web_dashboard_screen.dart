import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../core/constants/health_constants.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'providers/dashboard_provider.dart';
import 'providers/fluid_provider.dart';
import 'providers/medical_insights_provider.dart';
import 'widgets/medical_insight_cards.dart';
import 'package:kidneytrack_mobile/core/theme/app_colors.dart';
import 'package:kidneytrack_mobile/core/theme/app_text_styles.dart';
import 'package:kidneytrack_mobile/core/widgets/web/web_stat_card.dart';
import 'package:kidneytrack_mobile/core/widgets/charts/fluid_cups_widget.dart';

class WebDashboardScreen extends ConsumerWidget {
  const WebDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(dashboardSummaryProvider);
    final insightsAsync = ref.watch(medicalInsightsProvider);
    
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: summaryAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (data) => insightsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
          data: (insights) => _buildWebLayout(context, ref, data, insights),
        ),
      ),
    );
  }

  Widget _buildWebLayout(BuildContext context, WidgetRef ref, dynamic data, dynamic insights) {
    final metrics = data['metrics'] as List? ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('لوحة التحكم الرئيسية', style: AppTextStyles.h1.copyWith(fontSize: 32)),
                  const Gap(8),
                  Text('مرحباً بك مجدداً في جلوميا. إليك ملخص حالتك الصحية اليوم.', style: AppTextStyles.bodyM.copyWith(color: AppColors.textSecondary)),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add),
                label: const Text('إضافة تحليل جديد'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          
          const Gap(40),
          
          // Stats Row
          GridView.count(
            crossAxisCount: 4,
            crossAxisSpacing: 24,
            mainAxisSpacing: 24,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              WebStatCard(
                label: 'الكرياتينين',
                value: metrics.isNotEmpty ? metrics.firstWhere((m) => m['code'] == 'CREAT', orElse: () => {'value': '0'})['value'].toString() : '0',
                unit: 'mg/dL',
                icon: Icons.science_outlined,
                color: AppColors.primary,
              ),
              WebStatCard(
                label: 'البوتاسيوم',
                value: metrics.isNotEmpty ? metrics.firstWhere((m) => m['code'] == 'K', orElse: () => {'value': '0'})['value'].toString() : '0',
                unit: 'mmol/L',
                icon: Icons.bloodtype_outlined,
                color: AppColors.textCritical,
              ),
              WebStatCard(
                label: 'معدل الترشيح (eGFR)',
                value: insights.egfr?.toStringAsFixed(1) ?? '--',
                unit: 'ml/min',
                icon: Icons.speed_outlined,
                color: AppColors.textSuccess,
              ),
              WebStatCard(
                label: 'السوائل اليومية',
                value: '${ref.watch(todayFluidIntakeProvider)} / ${data['fluidLimitMl'] ?? HealthConstants.defaultFluidLimitMl}',
                unit: 'ml',
                icon: Icons.water_drop_outlined,
                color: AppColors.accent,
              ),
            ],
          ),

          const Gap(40),
          
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main charts or detailed info
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: AppColors.bgSurface,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 20)],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('تتبع السوائل', style: AppTextStyles.h2),
                          const Gap(24),
                          FluidCupsWidget(
                            completedCups: ref.watch(todayFluidIntakeProvider) ~/ 250,
                            totalCups: (data['fluidLimitMl'] ?? HealthConstants.defaultFluidLimitMl) ~/ HealthConstants.mlPerCup,
                            onAddCup: (count) {
                              ref.read(fluidProvider.notifier).addIntake(250);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const Gap(24),
              
              // Insights and Alerts Sidebar area
              Expanded(
                child: Column(
                   children: [
                     EGFRCard(egfr: insights.egfr, stage: insights.kidneyStage),
                     const Gap(16),
                     BloodPressureCard(
                       avg: insights.bpAnalysis.avgSystolic, 
                       trend: insights.bpAnalysis.trend, 
                       controlRate: insights.bpAnalysis.controlRate
                     ),
                   ],
                ),
              ),
            ],
          ),
        ],
      ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.1, end: 0),
    );
  }
}
