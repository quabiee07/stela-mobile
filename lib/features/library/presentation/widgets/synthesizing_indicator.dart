import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:stela_mobile/core/presentation/theme/colors/colors.dart';
import 'package:stela_mobile/core/presentation/theme/theme_x.dart';

/// Compact narration-prep overlay. Progress is expected already bucketed by
/// the parent so this does not rebuild on every synthesis tick.
class SynthesizingIndicator extends StatelessWidget {
  const SynthesizingIndicator({
    super.key,
    required this.label,
    this.progress,
  });

  final String label;

  /// `null` shows an indeterminate track (chapter fetch).
  final double? progress;

  @override
  Widget build(BuildContext context) {
    final percent = progress == null
        ? null
        : (progress!.clamp(0.0, 1.0) * 100).round();

    return Semantics(
      liveRegion: true,
      label: percent == null
          ? label
          : '$label, $percent percent',
      child: ColoredBox(
        color: context.cardSurface.withValues(alpha: 0.92),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const _NarratorBars(),
              const Gap(18),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                child: Text(
                  label,
                  key: ValueKey(label),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              const Gap(16),
              _ProgressTrack(progress: progress),
              if (percent != null) ...[
                const Gap(8),
                Text(
                  '$percent%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: context.mutedText,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressTrack extends StatelessWidget {
  const _ProgressTrack({required this.progress});

  final double? progress;

  @override
  Widget build(BuildContext context) {
    final track = context.softBorder.withValues(alpha: 0.7);

    final value = progress;
    if (value == null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: LinearProgressIndicator(
          minHeight: 4,
          backgroundColor: track,
          color: orange,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(100),
      child: LinearProgressIndicator(
        value: value.clamp(0.0, 1.0),
        minHeight: 4,
        backgroundColor: track,
        color: orange,
      ),
    );
  }
}

class _NarratorBars extends StatefulWidget {
  const _NarratorBars();

  @override
  State<_NarratorBars> createState() => _NarratorBarsState();
}

class _NarratorBarsState extends State<_NarratorBars>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 28,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(5, (i) {
              final t = (_controller.value + i * 0.16) % 1.0;
              final height = 8.0 + math.sin(t * math.pi) * 20.0;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2.5),
                child: Container(
                  width: 3.5,
                  height: height,
                  decoration: BoxDecoration(
                    color: orange.withValues(alpha: 0.35 + (height / 28) * 0.65),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
