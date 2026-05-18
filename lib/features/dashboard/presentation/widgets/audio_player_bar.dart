import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:stela_mobile/core/presentation/theme/colors/colors.dart';

class AudioPlayerBar extends StatelessWidget {
  const AudioPlayerBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 16, bottom: 40, left: 16, right: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              activeTrackColor: orange,
              inactiveTrackColor: Colors.grey[200],
              thumbColor: Colors.white,
              overlayColor: orange.withOpacity(0.2),
              thumbShape: const _CustomSliderThumbCircle(thumbRadius: 6, color: orange),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
            ),
            child: Slider(
              value: 0.2,
              onChanged: (val) {},
            ),
          ),
          // Timestamps
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '00:23:41',
                  style: TextStyle(color: Colors.grey, fontSize: 10),
                ),
                Text(
                  '01:58:41',
                  style: TextStyle(color: Colors.grey, fontSize: 10),
                ),
              ],
            ),
          ),
          const Gap(16),
          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {},
                icon: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.replay_10, size: 20, color: Colors.black87),
                ),
              ),
              const Gap(12),
              GestureDetector(
                onTap: () {},
                child: RotatedBox(
                  quarterTurns: 2,
                  child: const Icon(Icons.play_arrow, size: 36, color: Colors.black87),
                ),
              ),
              const Gap(24),
              GestureDetector(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: orange,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
              const Gap(24),
              GestureDetector(
                onTap: () {},
                child: const Icon(Icons.play_arrow, size: 36, color: Colors.black87),
              ),
              const Gap(12),
              IconButton(
                onPressed: () {},
                icon: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.forward_10, size: 20, color: Colors.black87),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CustomSliderThumbCircle extends SliderComponentShape {
  final double thumbRadius;
  final Color color;

  const _CustomSliderThumbCircle({
    required this.thumbRadius,
    required this.color,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(thumbRadius);
  }

  @override
  void paint(PaintingContext context, Offset center,
      {required Animation<double> activationAnimation,
      required Animation<double> enableAnimation,
      required bool isDiscrete,
      required TextPainter labelPainter,
      required RenderBox parentBox,
      required SliderThemeData sliderTheme,
      required TextDirection textDirection,
      required double value,
      required double textScaleFactor,
      required Size sizeWithOverflow}) {
    final Canvas canvas = context.canvas;

    final Paint borderPaint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final Paint fillPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, thumbRadius, fillPaint);
    canvas.drawCircle(center, thumbRadius, borderPaint);
  }
}
