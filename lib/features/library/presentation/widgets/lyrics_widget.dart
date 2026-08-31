import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stela_mobile/core/presentation/theme/theme_x.dart';
import 'package:stela_mobile/features/profile/presentation/manager/reading_preferences_cubit.dart';

class LyricsWidget extends StatefulWidget {
  const LyricsWidget({
    super.key,
    required this.lines,
    required this.lineKeys,
    required this.lineCueSecs,
    required this.currentLine,
    required this.onSeek,
  });
  final List<String> lines;
  final List<GlobalKey> lineKeys;
  final List<double> lineCueSecs;
  final int currentLine;
  final Function(double) onSeek;

  @override
  State<LyricsWidget> createState() => _LyricsWidgetState();
}

class _LyricsWidgetState extends State<LyricsWidget> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lineColor = Theme.of(context).colorScheme.onSurface;
    final baseStyle = Theme.of(context).textTheme.displayLarge!;
    // Match the card behind lyrics (not scaffold) for edge fades.
    final fadeColor = context.cardSurface;

    // Soft fades via overlays instead of ShaderMask (expensive on device GPUs).
    // Keep a Column so GlobalKey + ensureVisible can reach every line.
    return Stack(
      children: [
        RepaintBoundary(
          child: BlocBuilder<ReadingPreferencesCubit, ReadingPreferencesState>(
            buildWhen: (prev, curr) =>
                prev.textSizeScale != curr.textSizeScale,
            builder: (context, prefs) {
              return SingleChildScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(8, 28, 8, 36),
                child: Column(
                  children: [
                    for (var i = 0; i < widget.lines.length; i++)
                      _LyricLine(
                        key: widget.lineKeys[i],
                        text: widget.lines[i],
                        isCurrent: i == widget.currentLine,
                        distance: (i - widget.currentLine).abs(),
                        lineColor: lineColor,
                        baseStyle: baseStyle,
                        fontSize: prefs.lyricFontSize,
                        onTap: () => widget.onSeek(widget.lineCueSecs[i]),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 28,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [fadeColor, fadeColor.withValues(alpha: 0)],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 36,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [fadeColor, fadeColor.withValues(alpha: 0)],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LyricLine extends StatelessWidget {
  const _LyricLine({
    super.key,
    required this.text,
    required this.isCurrent,
    required this.distance,
    required this.lineColor,
    required this.baseStyle,
    required this.fontSize,
    required this.onTap,
  });

  final String text;
  final bool isCurrent;
  final int distance;
  final Color lineColor;
  final TextStyle baseStyle;
  final double fontSize;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final opacity = isCurrent
        ? 1.0
        : distance == 1
            ? 0.42
            : distance == 2
                ? 0.24
                : 0.12;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: GestureDetector(
        onTap: onTap,
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: baseStyle.copyWith(
            fontSize: fontSize,
            fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
            color: lineColor.withValues(alpha: opacity),
            height: 1.4,
            letterSpacing: -0.2,
          ),
        ),
      ),
    );
  }
}
