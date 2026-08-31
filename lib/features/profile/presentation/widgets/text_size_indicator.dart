import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:stela_mobile/core/presentation/theme/theme_x.dart';
import 'package:stela_mobile/features/profile/presentation/manager/reading_preferences_cubit.dart';

class TextSizeIndicator extends StatelessWidget {
  const TextSizeIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final muted = context.mutedText;

    return BlocBuilder<ReadingPreferencesCubit, ReadingPreferencesState>(
      buildWhen: (prev, curr) => prev.textSizeScale != curr.textSizeScale,
      builder: (context, state) {
        return SizedBox(
          width: 160,
          child: Row(
            children: [
              Text(
                'aa',
                style: TextStyle(
                  fontSize: 12,
                  color: muted,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const Gap(6),
              Expanded(
                child: DoubleDividerSlider(
                  value: state.textSizeScale,
                  onChanged: (v) => context
                      .read<ReadingPreferencesCubit>()
                      .setTextSizeScale(v),
                ),
              ),
              const Gap(6),
              Text(
                'AA',
                style: TextStyle(
                  fontSize: 16,
                  color: muted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class DoubleDividerSlider extends StatelessWidget {
  const DoubleDividerSlider({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragUpdate: (d) {
        final box = context.findRenderObject() as RenderBox;
        final localX = d.localPosition.dx.clamp(0.0, box.size.width);
        onChanged((localX / box.size.width).clamp(0.0, 1.0));
      },
      onTapDown: (d) {
        final box = context.findRenderObject() as RenderBox;
        final localX = d.localPosition.dx.clamp(0.0, box.size.width);
        onChanged((localX / box.size.width).clamp(0.0, 1.0));
      },
      child: SizedBox(
        height: 40,
        child: CustomPaint(painter: _SliderPainter(value: value)),
      ),
    );
  }
}

class _SliderPainter extends CustomPainter {
  const _SliderPainter({required this.value});

  final double value;

  static const _trackColor = Color(0xFFF5AAAA);
  static const _dividerColor = Color(0xFFD05050);
  static const _dotColor = Color(0xFF444444);
  static const _trackHeight = 7.0;
  static const _dotRadius = 4.0;
  static const _dividerWidth = 2.5;
  static const _dividerGap = 3.5;
  static const _dividerHeight = 20.0;

  @override
  void paint(Canvas canvas, Size size) {
    final cy = size.height / 2;
    final trackLeft = _dotRadius;
    final trackRight = size.width - _dotRadius;
    final thumbX = trackLeft + value * (trackRight - trackLeft);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          trackLeft,
          cy - _trackHeight / 2,
          trackRight - trackLeft,
          _trackHeight,
        ),
        const Radius.circular(4),
      ),
      Paint()..color = _trackColor,
    );

    canvas.drawCircle(
      Offset(trackLeft, cy),
      _dotRadius,
      Paint()..color = _dotColor,
    );

    canvas.drawCircle(
      Offset(trackRight, cy),
      _dotRadius,
      Paint()..color = _dotColor,
    );

    final divPaint = Paint()
      ..color = _dividerColor
      ..strokeWidth = _dividerWidth
      ..strokeCap = StrokeCap.round;

    final halfGap = _dividerGap / 2;

    canvas.drawLine(
      Offset(thumbX - halfGap, cy - _dividerHeight / 2),
      Offset(thumbX - halfGap, cy + _dividerHeight / 2),
      divPaint,
    );
    canvas.drawLine(
      Offset(thumbX + halfGap, cy - _dividerHeight / 2),
      Offset(thumbX + halfGap, cy + _dividerHeight / 2),
      divPaint,
    );
  }

  @override
  bool shouldRepaint(_SliderPainter old) => old.value != value;
}
