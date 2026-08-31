import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:stela_mobile/core/presentation/theme/colors/colors.dart';
import 'package:stela_mobile/core/presentation/theme/theme_x.dart';
import 'package:stela_mobile/core/presentation/widgets/clickable.dart';
import 'package:stela_mobile/features/auth/domain/models/user_model.dart';

class StreakCard extends StatelessWidget {
  const StreakCard({
    super.key,
    required this.streakData,
    this.freezeAvailable = false,
    this.isFrozen = false,
    this.onActivateFreeze,
  });
  final StreakDataModel? streakData;
  final bool freezeAvailable;
  final bool isFrozen;
  final VoidCallback? onActivateFreeze;

  static const _barColors = [
    Color(0xFFEB4C4C),
    Color(0xFF507CE9),
    Color(0xFF9E70F2),
    Color(0xFFEA5E3E),
    Color(0xFF507CE9),
    Color(0xFFEB4C4C),
    Color(0xFF9E70F2),
  ];

  List<_BarData> _mapBars(StreakDataModel? data) {
    final progress = data?.weeklyProgress ?? const <WeeklyProgressModel>[];
    if (progress.isEmpty) {
      return [
        for (var i = 0; i < 7; i++)
          _BarData(
            const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][i],
            0,
            _barColors[i],
          ),
      ];
    }

    return [
      for (var i = 0; i < progress.length; i++)
        _BarData(
          progress[i].weekLabel,
          progress[i].value.toDouble(),
          _barColors[i % _barColors.length],
        ),
    ];
  }

  double _maxY(List<_BarData> bars) {
    final peak = bars.fold<double>(0, (max, bar) => math.max(max, bar.value));
    if (peak <= 0) return 50;
    // Headroom so a full day doesn't clip the rounded top.
    final padded = peak * 1.25;
    if (padded <= 50) return 50;
    if (padded <= 100) return 100;
    if (padded <= 150) return 150;
    return (padded / 50).ceil() * 50.0;
  }

  @override
  Widget build(BuildContext context) {
    final streakDays = streakData?.currentStreakDays ?? 0;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final muted = context.mutedText;
    final gridColor = context.softBorder;
    final trackColor = context.softBorder.withValues(alpha: 0.45);
    final barData = _mapBars(streakData);
    final maxY = _maxY(barData);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
      decoration: BoxDecoration(
        color: context.cardSurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'This week',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: onSurface,
                ),
              ),
              Text(
                streakDays > 0
                    ? '$streakDays day streak!'
                    : 'Start a streak today',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: orange,
                ),
              ),
            ],
          ),
          if (freezeAvailable || isFrozen) ...[
            const Gap(12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    isFrozen
                        ? 'Streak freeze is active today'
                        : 'Streak freeze ready',
                    style: TextStyle(
                      fontSize: 13,
                      color: muted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (freezeAvailable && !isFrozen && onActivateFreeze != null)
                  Clickable(
                    onPressed: onActivateFreeze!,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: orange.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: const Text(
                        'Use freeze',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: orange,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
          const Gap(20),
          SizedBox(
            width: double.infinity,
            height: 220,
            child: BarChart(
              BarChartData(
                maxY: maxY,
                minY: 0,
                alignment: BarChartAlignment.spaceAround,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      interval: maxY / 4,
                      getTitlesWidget: (value, meta) {
                        if (value == 0 || value == maxY) {
                          return Text(
                            value.toInt().toString(),
                            style: TextStyle(
                              fontSize: 11,
                              color: muted,
                              fontWeight: FontWeight.w400,
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= barData.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            barData[index].label,
                            style: TextStyle(
                              fontSize: 11,
                              color: muted,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxY / 4,
                  getDrawingHorizontalLine: (_) =>
                      FlLine(color: gridColor, strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                barGroups: [
                  for (var i = 0; i < barData.length; i++)
                    BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          fromY: 0,
                          toY: barData[i].value,
                          color: barData[i].color,
                          width: 28,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8),
                            topRight: Radius.circular(8),
                          ),
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            fromY: 0,
                            toY: maxY,
                            color: trackColor,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BarData {
  final String label;
  final double value;
  final Color color;
  const _BarData(this.label, this.value, this.color);
}
