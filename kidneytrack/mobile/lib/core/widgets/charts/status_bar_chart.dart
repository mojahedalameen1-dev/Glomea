import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

class StatusBarChart extends StatelessWidget {
  final Map<String, List<double>> weeklyData;
  final Map<String, Color> indicatorColors;

  const StatusBarChart({
    super.key,
    required this.weeklyData,
    required this.indicatorColors,
  });

  @override
  Widget build(BuildContext context) {
    if (weeklyData.isEmpty) return const SizedBox.shrink();

    final days = ['Sat', 'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
    final indicatorNames = weeklyData.keys.toList();

    return Column(
      children: [
        AspectRatio(
          aspectRatio: 1.5,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: 100, // Normalized for multiple indicators if needed, or scaled
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (_) => Colors.white,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      rod.toY.toStringAsFixed(1),
                      AppTextStyles.bodyS.copyWith(fontWeight: FontWeight.bold),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          days[value.toInt() % 7],
                          style: AppTextStyles.bodyS,
                        ),
                      );
                    },
                    reservedSize: 30,
                  ),
                ),
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              barGroups: List.generate(7, (dayIndex) {
                return BarChartGroupData(
                  x: dayIndex,
                  barRods: List.generate(indicatorNames.length, (indicatorIndex) {
                    final name = indicatorNames[indicatorIndex];
                    final values = weeklyData[name]!;
                    final value = dayIndex < values.length ? values[dayIndex] : 0.0;
                    return BarChartRodData(
                      toY: value,
                      color: indicatorColors[name] ?? AppColors.primary,
                      width: 12,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                    );
                  }),
                );
              }),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: indicatorNames.map((name) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: indicatorColors[name],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(name, style: AppTextStyles.bodyS),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}
