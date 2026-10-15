import 'package:flutter/material.dart';
import 'package:stela_mobile/core/presentation/resources/drawables.dart';
import 'package:stela_mobile/core/presentation/widgets/custom_image.dart';

/// Pill-shaped XP earned banner matching the reading-reward mock.
///
/// Visual-only — presentation / feedback live in [XpToastOverlay].
class XpToast extends StatelessWidget {
  const XpToast({super.key, required this.xp});

  final int xp;

  static const double height = 52;
  static const double _outerRadius = 14;
  static const double _innerRadius = 12;
  static const double _border = 2;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: height,
      padding: const EdgeInsets.all(_border),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFFFFC658),
        borderRadius: BorderRadius.circular(_outerRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_innerRadius),
        child: ColoredBox(
          color: const Color(0xFFFF7A16),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(width: 16),
              Text(
                '+$xp XP',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              const CustomImage(asset: diamond, height: 18, width: 18),
              const SizedBox(width: 4),
              // Tall enough to peek into the frame; clipped by parents above.
              const CustomImage(
                asset: logoBunny,
                height: height - _border * 2,
                width: 48,
                fit: BoxFit.cover,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
