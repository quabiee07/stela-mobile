import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:stela_mobile/core/presentation/theme/theme_x.dart';

class StatsCard extends StatelessWidget {
  const StatsCard({
    super.key,
    required this.emoji,
    required this.value,
    required this.label,
  });
  final String emoji;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Expanded(
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const Gap(6),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: onSurface,
            ),
          ),
          const Gap(2),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: context.mutedText,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
