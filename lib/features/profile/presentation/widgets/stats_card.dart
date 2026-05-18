
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:stela_mobile/core/presentation/theme/colors/colors.dart';

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
    return Expanded(
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const Gap(6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const Gap(2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: grey500,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
