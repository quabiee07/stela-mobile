import 'package:flutter/material.dart';
import 'package:stela_mobile/core/presentation/resources/drawables.dart';
import 'package:stela_mobile/core/presentation/theme/colors/colors.dart';
import 'package:stela_mobile/core/presentation/theme/theme_x.dart';
import 'package:stela_mobile/core/presentation/widgets/svg_image.dart';
import 'package:stela_mobile/features/profile/presentation/utils/gamification_display.dart';

class StreakWeekRow extends StatelessWidget {
  const StreakWeekRow({
    super.key,
    required this.completed,
    this.onAccent = false,
  });

  /// Monday–Sunday completion flags.
  final List<bool> completed;
  final bool onAccent;

  @override
  Widget build(BuildContext context) {
    final labels = GamificationDisplay.weekdayLabels;
    final count = labels.length;

    return Row(
      children: [
        for (var i = 0; i < count; i++)
          Expanded(
            child: _DayCell(
              label: labels[i],
              done: i < completed.length && completed[i],
              onAccent: onAccent,
            ),
          ),
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.label,
    required this.done,
    required this.onAccent,
  });

  final String label;
  final bool done;
  final bool onAccent;

  @override
  Widget build(BuildContext context) {
    final labelColor = onAccent ? Colors.white : context.mutedText;
    final circleColor = onAccent
        ? (done ? Colors.white : Colors.white.withValues(alpha: 0.28))
        : (done ? orange : context.softBorder);
    final checkColor = onAccent ? const Color(0xFF2B2B2B) : Colors.white;

    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: labelColor,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(color: circleColor, shape: BoxShape.circle),
          child: done
              ? Center(child: SvgImage(asset: tick, width: 16, height: 16, color: checkColor))
              : null,
        ),
      ],
    );
  }
}
