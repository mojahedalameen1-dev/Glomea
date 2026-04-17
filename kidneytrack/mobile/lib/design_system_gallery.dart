import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_gradients.dart';
import 'core/theme/app_types.dart';
import 'core/animations/micro_interactions.dart';
import 'core/widgets/cards/glass_card.dart';
import 'core/widgets/cards/status_card.dart';
import 'core/widgets/charts/fluid_ring_chart.dart';
import 'core/widgets/charts/trend_line_chart.dart';
import 'core/widgets/indicators/status_badge.dart';
import 'core/widgets/indicators/health_gauge.dart';
import 'core/widgets/layout/app_scaffold.dart';
import 'core/widgets/layout/section_header.dart';
import 'core/widgets/inputs/app_text_field.dart';
import 'core/widgets/inputs/numeric_stepper.dart';

class DesignSystemGallery extends StatelessWidget {
  const DesignSystemGallery({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'معرض التصميم (Design System)',
      showBackButton: false,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(title: 'البطاقات والحالة (Cards)'),
            StatusCard(
              indicatorName: 'بوتاسيوم',
              value: 5.8,
              unit: 'mmol/L',
              status: IndicatorStatus.critical,
              sparklineData: const <double>[4.2, 4.5, 4.8, 5.2, 5.5, 5.6, 5.8],
              thresholds: const ThresholdRange(safeMin: 3.5, safeMax: 5.0, warningMin: 5.1, warningMax: 5.5, criticalMax: 6.0),
              delta: 12.5,
              onTap: () {},
            ),
            const SizedBox(height: 16),
            const GlassCard(
              child: Column(
                children: [
                  Text('بطاقة زجاجية (Glass Card)', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('تستخدم للملخصات والمعلومات الإضافية مع تأثير ضبابي.'),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            const SectionHeader(title: 'الرسوم البيانية (Charts)'),
            const Center(
              child: FluidRingChart(
                currentMl: 1200,
                limitMl: 1500,
              ),
            ),
            const SizedBox(height: 24),
            TrendLineChart(
              lines: [
                LineChartBarData(
                  color: AppColors.primary,
                  spots: [
                    const FlSpot(0, 72.0),
                    const FlSpot(1, 72.5),
                    const FlSpot(2, 73.0),
                    const FlSpot(3, 72.8),
                    const FlSpot(4, 73.5),
                    const FlSpot(5, 74.2),
                    const FlSpot(6, 75.0),
                  ],
                ),
              ],
              yAxisLabel: 'kg',
              tooltipValueFormatter: (v) => v.toStringAsFixed(1),
            ),

            const SizedBox(height: 32),
            const SectionHeader(title: 'المؤشرات (Indicators)'),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                StatusBadge(status: IndicatorStatus.safe, isLarge: true),
                StatusBadge(status: IndicatorStatus.warning, isLarge: true),
                StatusBadge(status: IndicatorStatus.critical, isLarge: true),
              ],
            ),
            const SizedBox(height: 16),
            const Center(
              child: HealthGauge(
                value: 75,
                status: IndicatorStatus.warning,
              ),
            ),

            const SizedBox(height: 32),
            const SectionHeader(title: 'المدخلات (Inputs)'),
            const AppTextField(
              label: 'الاسم الكامل',
              hint: 'أدخل اسمك هنا',
            ),
            const SizedBox(height: 16),
            NumericStepper(
              label: 'كمية السوائل',
              value: 250,
              unit: 'مل',
              onChanged: (val) {},
            ),
            
            const SizedBox(height: 32),
            const SectionHeader(title: 'التفاعلات (Interactions)'),
            Center(
              child: TapScale(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: AppGradients.headerGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('اضغط هنا للتفاعل', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
            const SizedBox(height: 64),
          ],
        ),
      ),
    );
  }
}
