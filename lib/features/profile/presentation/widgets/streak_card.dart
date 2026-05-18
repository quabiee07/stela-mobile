import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:stela_mobile/core/presentation/theme/colors/colors.dart';
import 'package:stela_mobile/features/auth/domain/models/user_model.dart';

class StreakCard extends StatefulWidget {
  const StreakCard({super.key, required this.streakData});
  final StreakDataModel? streakData;

  @override
  State<StreakCard> createState() => _StreakCardState();
}

class _StreakCardState extends State<StreakCard> {
  static const _barColors = [
    Color(0xFFEB4C4C),
    Color(0xFF507CE9),
    Color(0xFF9E70F2),
    Color(0xFFEA5E3E),
    Color(0xFF507CE9),
  ];

  late final List<_BarData> _barData;

  @override
  void initState() {
    super.initState();

    final progress = widget.streakData?.weeklyProgress ?? [];

    // Map over the entries to get both index and weekly progress data
    _barData = progress.asMap().entries.map((entry) {
      final index = entry.key;
      final weekData = entry.value;
      // Assign colors cyclically based on the index
      final color = _barColors[index % _barColors.length];

      return _BarData(weekData.weekLabel, weekData.value.toDouble(), color);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
      decoration: BoxDecoration(
        color: white,
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
                  color: Colors.black,
                ),
              ),
              Text(
                '🔥 ${widget.streakData?.currentStreakDays} day streak!',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: orange,
                ),
              ),
            ],
          ),
          const Gap(20),
          SizedBox(
            height: 220,
            child: BarChart(
              BarChartData(
                maxY: 200,
                minY: 0,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      interval: 50,
                      getTitlesWidget: (value, meta) {
                        // Only show 0, 25, 50, 100, 150, 200
                        const labels = {0, 25, 50, 100, 150, 200};
                        // final labels = widget.streakData?.weeklyProgress.map((e) => e.value).toSet();
                        if (!labels.contains(value.toInt())) {
                          return const SizedBox.shrink();
                        }
                        return Text(
                          value.toInt() == 0 ? '0' : '${value.toInt()}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF999999),
                            fontWeight: FontWeight.w400,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= _barData.length)
                          return const SizedBox.shrink();
                        final label = _barData[index].label;
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            label,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF999999),
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
                  horizontalInterval: 50,
                  getDrawingHorizontalLine: (_) =>
                      FlLine(color: const Color(0xFFF0F0F0), strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(_barData.length, (i) {
                  final bar = _barData[i];
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: bar.value,
                        color: bar.color,
                        width: 36,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                        ),
                      ),
                    ],
                  );
                }),
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
