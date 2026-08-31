import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:stela_mobile/core/presentation/theme/theme_x.dart';

/// Simple theme-aware loading skeleton (replaces AI image placeholder).
class ImageShimmer extends StatelessWidget {
  const ImageShimmer({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 12,
  });

  final double? width;
  final double? height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final base = context.isDarkTheme
        ? const Color(0xFF2A2A2A)
        : const Color(0xFFE8E8EC);
    final highlight = context.isDarkTheme
        ? const Color(0xFF3A3A3A)
        : const Color(0xFFF5F5F7);

    return Container(
      width: width ?? double.infinity,
      height: height ?? double.infinity,
      decoration: BoxDecoration(
        color: base,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    )
        .animate(onPlay: (c) => c.repeat())
        .shimmer(
          duration: 1200.ms,
          color: highlight,
        );
  }
}
