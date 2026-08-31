import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:stela_mobile/core/presentation/resources/app_icons.dart';
import 'package:stela_mobile/core/presentation/theme/colors/colors.dart';
import 'package:stela_mobile/core/presentation/theme/theme_x.dart';
import 'package:stela_mobile/core/presentation/widgets/app_icon.dart';
import 'package:stela_mobile/core/presentation/widgets/clickable.dart';
import 'dart:math' as math;

class AudioPlayerWidget extends StatefulWidget {
  const AudioPlayerWidget({
    super.key,
    required this.current,
    required this.total,
    required this.onSeek,
    required this.onTogglePlay,
    required this.onNudge,
    required this.isPlaying,
    required this.currentDuration,
    required this.totalDuration,
    this.isLoading = false,
  });
  final double current;
  final double total;
  final Duration currentDuration;
  final Duration totalDuration;
  final Function(double) onSeek;
  final Function() onTogglePlay;
  final Function(int) onNudge;
  final bool isPlaying;
  final bool isLoading;

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget>
    with SingleTickerProviderStateMixin {
  double? _dragValue;
  AnimationController? _strokeWaveController;

  @override
  void initState() {
    super.initState();
    _syncWaveAnimation();
  }

  @override
  void didUpdateWidget(covariant AudioPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isPlaying != widget.isPlaying ||
        oldWidget.isLoading != widget.isLoading) {
      _syncWaveAnimation();
    }
  }

  void _syncWaveAnimation() {
    final shouldAnimate = widget.isPlaying || widget.isLoading;
    if (shouldAnimate) {
      _strokeWaveController ??= AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1800),
      );
      if (!_strokeWaveController!.isAnimating) {
        _strokeWaveController!.repeat();
      }
    } else {
      _strokeWaveController?.stop();
    }
  }

  @override
  void dispose() {
    _strokeWaveController?.dispose();
    super.dispose();
  }

  bool get _shouldAnimateWaves => widget.isPlaying || widget.isLoading;

  String _fmt(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  String _fmtLarge(Duration d) {
    final m = d.inMinutes.toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final muted = context.mutedText;
    final max = widget.total <= 0 ? 1.0 : widget.total;
    final value = (_dragValue ?? widget.current).clamp(0.0, max);

    return Container(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
      decoration: const BoxDecoration(color: Colors.transparent),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _fmtLarge(
              _dragValue != null
                  ? Duration(seconds: _dragValue!.toInt())
                  : widget.currentDuration,
            ),
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w600,
              color: onSurface,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SliderTheme(
              data: SliderThemeData(
                trackHeight: 4,
                thumbShape: const RoundSliderThumbShape(
                  enabledThumbRadius: 6,
                  elevation: 2,
                ),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                activeTrackColor: orange,
                inactiveTrackColor: context.softBorder,
                thumbColor: Colors.white,
                overlayColor: orange.withValues(alpha: 0.15),
              ),
              child: Slider(
                value: value,
                min: 0,
                max: max,
                onChanged: (val) {
                  setState(() => _dragValue = val);
                },
                onChangeEnd: (val) {
                  widget.onSeek(val);
                  setState(() => _dragValue = null);
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _fmt(
                    _dragValue != null
                        ? Duration(seconds: _dragValue!.toInt())
                        : widget.currentDuration,
                  ),
                  style: TextStyle(fontSize: 10, color: muted),
                ),
                Text(
                  _fmt(widget.totalDuration),
                  style: TextStyle(fontSize: 10, color: muted),
                ),
              ],
            ),
          ),
          // Single lightweight stroke painter (no WaveWidget + blur).
          RepaintBoundary(
            child: SizedBox(
              height: 64,
              width: double.infinity,
              child: AnimatedBuilder(
                animation: _strokeWaveController ?? kAlwaysCompleteAnimation,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _WaveStrokePainter(
                      phase: _strokeWaveController?.value ?? 0,
                      isAnimating: _shouldAnimateWaves,
                    ),
                  );
                },
              ),
            ),
          ),
          const Gap(8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              iconBtn(context, AppIcons.replay10, () => widget.onNudge(-15)),
              const Gap(16),
              iconBtn(context, null, () => widget.onSeek(0), isLeftArrow: true),
              const Gap(16),
              Clickable(
                onPressed: widget.onTogglePlay,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: orange,
                  ),
                  child: widget.isLoading
                      ? LoadingAnimationWidget.inkDrop(color: white, size: 24)
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AppIcon(
                              widget.isPlaying ? AppIcons.stop : AppIcons.play,
                              color: Colors.white,
                              size: 20,
                            ),
                            const Gap(6),
                            Text(
                              widget.isPlaying ? 'Stop' : 'Play',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const Gap(16),
              iconBtn(
                context,
                AppIcons.play,
                () => widget.onSeek(widget.total),
              ),
              const Gap(16),
              iconBtn(context, AppIcons.forward10, () => widget.onNudge(10)),
            ],
          ),
        ],
      ),
    );
  }
}

Widget iconBtn(
  BuildContext context,
  AppIconData? icon,
  VoidCallback onTap, {
  bool isLeftArrow = false,
}) {
  final onSurface = Theme.of(context).colorScheme.onSurface;
  return Clickable(
    onPressed: onTap,
    child: Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: context.elevatedSurface,
      ),
      child: Center(
        child: isLeftArrow
            ? Transform.rotate(
                angle: math.pi,
                child: AppIcon(
                  AppIcons.play,
                  color: context.mutedText,
                  size: 28,
                ),
              )
            : AppIcon(icon!, color: onSurface, size: 24),
      ),
    ),
  );
}

class _WaveStrokePainter extends CustomPainter {
  final bool isAnimating;
  final double phase;

  _WaveStrokePainter({required this.isAnimating, required this.phase});

  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()
      ..color = const Color(0xFFF19E7A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..isAntiAlias = true;

    final paint2 = Paint()
      ..color = const Color(0xFFECA386).withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..isAntiAlias = true;

    final path1 = Path();
    final path2 = Path();
    final animatedPhase = isAnimating ? phase * math.pi * 2 : 0.0;

    // Step by 3px — visually identical, ~3× fewer trig ops per frame.
    const step = 3.0;
    path1.moveTo(0, size.height * 0.4);
    path2.moveTo(0, size.height * 0.6);

    for (double i = 0; i <= size.width; i += step) {
      final normalizedX = i / size.width;
      final envelope = math.sin(normalizedX * math.pi);

      final y1 =
          size.height * 0.4 -
          math.sin(normalizedX * math.pi * 3 + animatedPhase) * 15 * envelope;
      path1.lineTo(i, y1);

      final y2 =
          size.height * 0.6 -
          math.cos(normalizedX * math.pi * 2.5 + animatedPhase * 0.8) *
              12 *
              envelope;
      path2.lineTo(i, y2);
    }

    canvas.drawPath(path2, paint2);
    canvas.drawPath(path1, paint1);
  }

  @override
  bool shouldRepaint(covariant _WaveStrokePainter oldDelegate) {
    return oldDelegate.isAnimating != isAnimating ||
        oldDelegate.phase != phase;
  }
}
