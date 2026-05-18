import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:stela_mobile/core/presentation/theme/colors/colors.dart';
import 'package:stela_mobile/core/presentation/widgets/clickable.dart';

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

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  double? _dragValue;

  String _fmt(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 36),
      decoration: BoxDecoration(color: Colors.white),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Seek bar ────────────────────────────────────────────────────────
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
              activeTrackColor: orange,
              inactiveTrackColor: grey200,
              thumbColor: orange,
              overlayColor: orange.withValues(alpha: 0.15),
            ),
            child: Slider(
              value: _dragValue ?? widget.current,
              min: 0,
              max: widget.total,
              onChanged: (val) {
                setState(() => _dragValue = val);
              },
              onChangeEnd: (val) {
                widget.onSeek(val);
                setState(() => _dragValue = null);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _fmt(
                    _dragValue != null
                        ? Duration(seconds: _dragValue!.toInt())
                        : widget.currentDuration,
                  ),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF999999),
                  ),
                ),
                Text(
                  _fmt(widget.totalDuration),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF999999),
                  ),
                ),
              ],
            ),
          ),
          const Gap(12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              iconBtn(Icons.replay_10_rounded, () => widget.onNudge(-15)),
              const Gap(12),
              iconBtn(Icons.skip_previous_rounded, () => widget.onSeek(0)),
              const Gap(12),
              // Play / Pause
              Clickable(
                onPressed: widget.onTogglePlay,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: orange,
                  ),
                  child: widget.isLoading
                      ? LoadingAnimationWidget.inkDrop(color: white, size: 40)
                      : Icon(
                          widget.isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 30,
                        ),
                ),
              ),
              const Gap(12),
              iconBtn(
                Icons.skip_next_rounded,
                () => widget.onSeek(widget.total),
              ),
              const Gap(12),
              iconBtn(Icons.forward_10_rounded, () => widget.onNudge(10)),
            ],
          ),
        ],
      ),
    );
  }
}

Widget iconBtn(IconData icon, VoidCallback onTap) {
  return Clickable(
    onPressed: onTap,
    child: Container(
      width: 44,
      height: 44,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(shape: BoxShape.circle, color: grey200),
      child: Icon(icon, color: Colors.black, size: 24),
    ),
  );
}
