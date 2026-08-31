import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:stela_mobile/core/presentation/theme/theme_x.dart';

class LibraryScreenShimmer extends StatelessWidget {
  const LibraryScreenShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(child: _box(context, width: 90, height: 28, radius: 8)),
        const Gap(12),
        Row(
          children: [
            Expanded(child: _box(context, height: 52, radius: 12)),
            const Gap(10),
            _box(context, width: 48, height: 48, radius: 12),
          ],
        ),
        const Gap(16),
        const _GenreSectionShimmer(cardCount: 1),
        const Gap(16),
        const _GenreSectionShimmer(cardCount: 2),
        const Gap(16),
        const _GenreSectionShimmer(cardCount: 2),
      ],
    );
  }

  Widget _box(
    BuildContext context, {
    required double height,
    double? width,
    double radius = 8,
    BoxShape shape = BoxShape.rectangle,
  }) {
    return _ShimmerBox(
      width: width,
      height: height,
      radius: radius,
      shape: shape,
    );
  }
}

class _GenreSectionShimmer extends StatelessWidget {
  const _GenreSectionShimmer({required this.cardCount});

  final int cardCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ShimmerBox(width: 110, height: 18, radius: 8),
        const Gap(8),
        LayoutBuilder(
          builder: (context, constraints) {
            const spacing = 16.0;
            final itemWidth = (constraints.maxWidth - spacing) / 2;

            return Wrap(
              spacing: spacing,
              runSpacing: 12,
              children: List.generate(cardCount, (index) {
                return SizedBox(
                  width: itemWidth,
                  child: _storyCard(itemWidth),
                );
              }),
            );
          },
        ),
      ],
    );
  }

  Widget _storyCard(double width) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ShimmerBox(width: width, height: 207, radius: 16),
        const Gap(8),
        _ShimmerBox(width: width * 0.8, height: 14, radius: 8),
        const Gap(6),
        _ShimmerBox(width: width * 0.65, height: 12, radius: 8),
        const Gap(6),
        Row(
          children: List.generate(
            5,
            (index) => Padding(
              padding: EdgeInsets.only(right: index == 4 ? 0 : 2),
              child: const _ShimmerBox(width: 14, height: 14, radius: 4),
            ),
          ),
        ),
      ],
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  const _ShimmerBox({
    required this.height,
    this.width,
    this.radius = 8,
    this.shape = BoxShape.rectangle,
  });

  final double height;
  final double? width;
  final double radius;
  final BoxShape shape;

  @override
  Widget build(BuildContext context) {
    final base = context.isDarkTheme
        ? const Color(0xFF2A2A2A)
        : const Color(0xFFF7F4FB);
    final highlight =
        context.isDarkTheme ? const Color(0xFF3A3A3A) : const Color(0xFFE0DCE8);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: base,
        borderRadius:
            shape == BoxShape.circle ? null : BorderRadius.circular(radius),
        shape: shape,
      ),
    )
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .shimmer(
          delay: 400.ms,
          duration: 1800.ms,
          color: highlight,
        );
  }
}
