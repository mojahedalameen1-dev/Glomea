import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import '../../theme/app_colors.dart';

class TrendLineChart extends StatelessWidget {
  final List<LineChartBarData> lines;
  final List<HorizontalLine>? targetLines;
  final bool showAreaFill;
  final Color? areaFillColor;
  final String yAxisLabel;
  final bool showAllDots;
  final String Function(double) tooltipValueFormatter;
  final double? minY;
  final double? maxY;

  const TrendLineChart({
    super.key,
    required this.lines,
    this.targetLines,
    this.showAreaFill = false,
    this.areaFillColor,
    required this.yAxisLabel,
    this.showAllDots = true,
    required this.tooltipValueFormatter,
    this.minY,
    this.maxY,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (lines.isEmpty || lines.every((l) => l.spots.isEmpty)) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40.0),
          child: Text('لا توجد بيانات كافية للرسم البياني',
              style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    // Calculate dynamic range if not provided
    double calculatedMinX = double.infinity;
    double calculatedMaxX = double.negativeInfinity;
    double calculatedMinY = double.infinity;
    double calculatedMaxY = double.negativeInfinity;

    for (final line in lines) {
      for (final spot in line.spots) {
        calculatedMinX = math.min(calculatedMinX, spot.x);
        calculatedMaxX = math.max(calculatedMaxX, spot.x);
        calculatedMinY = math.min(calculatedMinY, spot.y);
        calculatedMaxY = math.max(calculatedMaxY, spot.y);
      }
    }

    // Add some padding to Y axis
    final rangeY = calculatedMaxY - calculatedMinY;
    final finalMinY =
        minY ?? (calculatedMinY - (rangeY > 0 ? rangeY * 0.2 : 10));
    final finalMaxY =
        maxY ?? (calculatedMaxY + (rangeY > 0 ? rangeY * 0.2 : 10));

    // Area Fill logic (using betweenBarsData for better accuracy)
    final List<BetweenBarsData> betweenBarsData = [];
    if (showAreaFill && lines.length >= 2) {
      betweenBarsData.add(BetweenBarsData(
        fromIndex: 0,
        toIndex: 1,
        color: areaFillColor ?? AppColors.primary.withValues(alpha: 0.15),
      ));
    }

    return AspectRatio(
      aspectRatio: 1.7,
      child: LineChart(
        LineChartData(
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => isDark
                  ? Theme.of(context).colorScheme.surfaceContainerHighest
                  : const Color(0xFF2E3440),
              tooltipRoundedRadius: 8,
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  final date =
                      DateTime.fromMillisecondsSinceEpoch(spot.x.toInt());
                  final formattedDate = intl.DateFormat('d/M').format(date);
                  return LineTooltipItem(
                    '$formattedDate\n',
                    const TextStyle(color: Colors.white70, fontSize: 10),
                    children: [
                      TextSpan(
                        text: tooltipValueFormatter(spot.y),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      TextSpan(
                        text: ' $yAxisLabel',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 10),
                      ),
                    ],
                  );
                }).toList();
              },
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: (finalMaxY - finalMinY) / 5,
            getDrawingHorizontalLine: (value) => FlLine(
              color: isDark
                  ? Theme.of(context).colorScheme.outlineVariant
                  : const Color(0xFFE5E9F0),
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value == meta.min || value == meta.max) {
                    return const SizedBox.shrink();
                  }
                  return Text(
                    value.toStringAsFixed(0),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 10,
                    ),
                    textAlign: TextAlign.center,
                  );
                },
                reservedSize: 32,
              ),
            ),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final date =
                      DateTime.fromMillisecondsSinceEpoch(value.toInt());
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      intl.DateFormat('d/M').format(date),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 10,
                      ),
                    ),
                  );
                },
                reservedSize: 28,
                interval: (calculatedMaxX - calculatedMinX) / 5,
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          minX: calculatedMinX,
          maxX: calculatedMaxX,
          minY: finalMinY,
          maxY: finalMaxY,
          extraLinesData: ExtraLinesData(
            horizontalLines: targetLines ?? [],
          ),
          lineBarsData: lines
              .map((line) => line.copyWith(
                    dotData: FlDotData(show: showAllDots),
                  ))
              .toList(),
          betweenBarsData: betweenBarsData,
        ),
      ),
    );
  }
}
