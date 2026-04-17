import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class SparklineChart extends StatelessWidget {
  final List<double> values;
  final Color color;
  final bool showDots;

  const SparklineChart({
    super.key,
    required this.values,
    required this.color,
    this.showDots = false,
  });

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) return const SizedBox.shrink();

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: (values.length - 1).toDouble(),
        minY: values.reduce((a, b) => a < b ? a : b) * 0.9,
        maxY: values.reduce((a, b) => a > b ? a : b) * 1.1,
        lineBarsData: [
          LineChartBarData(
            spots: values.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
            isCurved: true,
            color: color,
            barWidth: 2.5,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: showDots,
              getDotPainter: (spot, percent, barData, index) {
                // Show dot only on last point if showDots is false but we want to highlight last point
                if (index == values.length - 1) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: color,
                    strokeWidth: 0,
                  );
                }
                return FlDotCirclePainter(radius: 0);
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: color.withValues(alpha: 0.05),
            ),
          ),
        ],
      ),
    );
  }
}
