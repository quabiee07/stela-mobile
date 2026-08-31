import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:stela_mobile/core/presentation/theme/theme_x.dart';

class HomeScreenShimmer extends StatelessWidget {
  const HomeScreenShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(top: 16, bottom: 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _box(context, width: 180, height: 32, radius: 10),
                  const Gap(8),
                  _box(context, width: 140, height: 14, radius: 8),
                ],
              ),
              _box(
                context,
                width: 48,
                height: 48,
                radius: 24,
                shape: BoxShape.circle,
              ),
            ],
          ),
          const Gap(24),
          _box(context, width: double.infinity, height: 220, radius: 24),
          const Gap(12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _box(context, width: 18, height: 6, radius: 100),
              const Gap(8),
              _box(context, width: 6, height: 6, radius: 100),
              const Gap(8),
              _box(context, width: 6, height: 6, radius: 100),
            ],
          ),
          const Gap(24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _box(context, width: 140, height: 18, radius: 8),
              _box(context, width: 48, height: 14, radius: 8),
            ],
          ),
          const Gap(16),
          _continueReadingCard(context),
          const Gap(12),
          _continueReadingCard(context),
          const Gap(12),
          _continueReadingCard(context),
          const Gap(12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _box(context, width: 110, height: 18, radius: 8),
              _box(context, width: 48, height: 14, radius: 8),
            ],
          ),
          const Gap(16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _chip(context),
                const Gap(8),
                _chip(context, width: 88),
                const Gap(8),
                _chip(context, width: 96),
                const Gap(8),
                _chip(context, width: 72),
              ],
            ),
          ),
          const Gap(16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            clipBehavior: Clip.none,
            child: Row(
              children: [
                _storyCard(context),
                const Gap(16),
                _storyCard(context),
                const Gap(16),
                _storyCard(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _continueReadingCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.cardSurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _box(context, width: 57, height: 73, radius: 12),
          const Gap(16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _box(context, width: double.infinity, height: 16, radius: 8),
                const Gap(8),
                _box(context, width: 120, height: 12, radius: 8),
                const Gap(10),
                _box(context, width: double.infinity, height: 6, radius: 100),
                const Gap(6),
                _box(context, width: 130, height: 10, radius: 8),
              ],
            ),
          ),
          const Gap(12),
          _box(context, width: 60, height: 36, radius: 10),
        ],
      ),
    );
  }

  Widget _chip(BuildContext context, {double width = 56}) {
    return _box(context, width: width, height: 36, radius: 100);
  }

  Widget _storyCard(BuildContext context) {
    return SizedBox(
      width: 140,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _box(context, width: 140, height: 150, radius: 16),
          const Gap(8),
          _box(context, width: 120, height: 14, radius: 8),
          const Gap(6),
          _box(context, width: 100, height: 12, radius: 8),
          const Gap(6),
          Row(
            children: List.generate(
              5,
              (index) => Padding(
                padding: EdgeInsets.only(right: index == 4 ? 0 : 2),
                child: _box(context, width: 14, height: 14, radius: 4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _box(
    BuildContext context, {
    required double height,
    double? width,
    double radius = 8,
    BoxShape shape = BoxShape.rectangle,
  }) {
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
