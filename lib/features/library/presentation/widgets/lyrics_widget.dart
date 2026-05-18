import 'package:flutter/material.dart';

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
  final List<int> lineCueSecs;
  final int currentLine;
  final Function(double) onSeek;

  @override
  State<LyricsWidget> createState() => _LyricsWidgetState();
}

class _LyricsWidgetState extends State<LyricsWidget> {
  final ScrollController _scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          Colors.black,
          Colors.black,
          Colors.transparent,
        ],
        stops: [0.0, 0.12, 0.72, 1.0],
      ).createShader(bounds),
      blendMode: BlendMode.dstIn,
      child: SingleChildScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 96),
        child: Column(
          children: List.generate(widget.lines.length, (i) {
            final dist = (i - widget.currentLine).abs();
            final isCurrent = dist == 0;

            // Progressive fade & size based on distance from active line
            final double opacity = isCurrent
                ? 1.0
                : dist == 1
                ? 0.40
                : dist == 2
                ? 0.22
                : 0.10;

            final double fontSize = 32;

            final FontWeight weight = isCurrent
                ? FontWeight.w600
                : FontWeight.w400;

            return Padding(
              key: widget.lineKeys[i],
              padding: const EdgeInsets.symmetric(vertical: 9),
              child: GestureDetector(
                onTap: () {
                  // Tapping a line seeks to it (like YouTube Music)
                  widget.onSeek(widget.lineCueSecs[i].toDouble());
                },
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  style: Theme.of(context).textTheme.displayLarge!.copyWith(
                    fontSize: fontSize,
                    fontWeight: weight,
                    color: Colors.black.withValues(alpha: opacity),
                    height: 1.25,
                    letterSpacing: 0,
                  ),
                  child: Text(widget.lines[i], textAlign: TextAlign.center),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
