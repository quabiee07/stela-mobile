import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:stela_mobile/core/presentation/theme/theme_x.dart';
import 'package:stela_mobile/core/presentation/widgets/custom_image.dart';

class StatsCard extends StatelessWidget {
  const StatsCard({
    super.key,
    required this.asset,
    required this.value,
    required this.label,
  });
  final String asset;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Expanded(
      child: Column(
        children: [
          CustomImage(asset: asset, width: 35, height: 35, fit: BoxFit.cover),
          const Gap(6),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: onSurface,
            ),
          ),
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
