import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:stela_mobile/core/presentation/utils/helper_functions.dart';

class TextSizeIndicator extends StatefulWidget {
  const TextSizeIndicator({super.key});

  @override
  State<TextSizeIndicator> createState() => _TextSizeIndicatorState();
}

class _TextSizeIndicatorState extends State<TextSizeIndicator> {

  double _value = 0.5;

  // // Snap to named presets (optional – comment out to get a free slider)
  // static const List<({double size, String label})> _presets = [
  //   (size: 12, label: 'XS'),
  //   (size: 15, label: 'S'),
  //   (size: 18, label: 'M'),
  //   (size: 24, label: 'L'),
  //   (size: 30, label: 'XL'),
  //   (size: 36, label: 'XXL'),
  // ];

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Spacer(),
          const Text(
            'bell',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF9BA5B7),
              fontWeight: FontWeight.w400,
            ),
          ),
          const Gap(5),
          Expanded(
            flex: 3,
            child: DoubleDividerSlider(
              value: _value,
              onChanged: (v) => setState(() {
                _value = v;
                logg('$v');
              }),
            ),
          ),

          const Gap(5),
          const Text(
            'Bell',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF9BA5B7),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Slider row ───────────────────────────────────────────────────────────────

class SliderRow extends StatelessWidget {
  const SliderRow({
    super.key,
    required this.fontSize,
    required this.minSize,
    required this.maxSize,
    required this.onChanged,
  });

  final double fontSize;
  final double minSize;
  final double maxSize;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Spacer(),
        Text(
          'aa',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade400,
            fontWeight: FontWeight.w400,
          ),
        ),
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 3,
              activeTrackColor: const Color(0xFFF4A8A8),
              inactiveTrackColor: const Color(0xFFF0EEEE),
              thumbColor: Colors.white,
              thumbShape: _BorderedThumbShape(
                thumbRadius: 10,
                borderColor: const Color(0xFFD87070),
                borderWidth: 2,
              ),
              overlayColor: const Color(0x1AD87070),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
            ),
            child: Slider(
              value: fontSize,
              min: minSize,
              max: maxSize,

              divisions: ((maxSize - minSize)).round(),
              onChanged: onChanged,
            ),
          ),
        ),
        Text(
          'AA',
          style: TextStyle(
            fontSize: 20,
            color: Colors.grey.shade500,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ─── Custom thumb shape ───────────────────────────────────────────────────────

class _BorderedThumbShape extends SliderComponentShape {
  const _BorderedThumbShape({
    required this.thumbRadius,
    required this.borderColor,
    required this.borderWidth,
  });

  final double thumbRadius;
  final Color borderColor;
  final double borderWidth;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) =>
      Size.fromRadius(thumbRadius);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;

    // Shadow
    canvas.drawCircle(
      center + const Offset(0, 1),
      thumbRadius,
      Paint()
        ..color = Colors.black.withOpacity(0.12)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );

    // White fill
    canvas.drawCircle(center, thumbRadius, Paint()..color = Colors.white);

    // Border
    canvas.drawCircle(
      center,
      thumbRadius - borderWidth / 2,
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth,
    );
  }
}

// ─── Preset row ───────────────────────────────────────────────────────────────

// ─── Custom Slider with double-line divider thumb ─────────────────────────────

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

    // ── Full pink track ──────────────────────────────────────────────────────
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

    // ── Left endpoint dot ────────────────────────────────────────────────────
    canvas.drawCircle(
      Offset(trackLeft, cy),
      _dotRadius,
      Paint()..color = _dotColor,
    );

    // ── Right endpoint dot ───────────────────────────────────────────────────
    canvas.drawCircle(
      Offset(trackRight, cy),
      _dotRadius,
      Paint()..color = _dotColor,
    );

    // ── Double-line thumb ────────────────────────────────────────────────────
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
