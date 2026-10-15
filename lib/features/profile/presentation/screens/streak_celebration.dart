import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:stela_mobile/core/presentation/resources/drawables.dart';
import 'package:stela_mobile/core/presentation/utils/celebration_feedback.dart';
import 'package:stela_mobile/core/presentation/utils/cover_page_route.dart';
import 'package:stela_mobile/core/presentation/utils/navigation_mixin.dart';
import 'package:stela_mobile/core/presentation/utils/xp_toast_overlay.dart';
import 'package:stela_mobile/core/presentation/widgets/custom_image.dart';
import 'package:stela_mobile/features/dashboard/presentation/screens/success_screen.dart';
import 'package:stela_mobile/features/profile/domain/models/level_progress.dart';
import 'package:stela_mobile/features/profile/presentation/manager/gamification_cubit.dart';
import 'package:stela_mobile/features/profile/presentation/manager/gamification_state.dart';
import 'package:stela_mobile/features/profile/presentation/widgets/streak_week_row.dart';

class StreakCelebrationScreen extends StatefulWidget {
  const StreakCelebrationScreen({
    super.key,
    required this.streakDays,
    required this.weekCompleted,
  });

  static const String id = '/streak-celebration';

  final int streakDays;
  final List<bool> weekCompleted;

  static Future<void> open(
    BuildContext context, {
    required int streakDays,
    required List<bool> weekCompleted,
  }) {
    return Navigator.of(context).push<void>(
      CoverPageRoute(
        settings: const RouteSettings(name: id),
        builder: (_) => StreakCelebrationScreen(
          streakDays: streakDays,
          weekCompleted: weekCompleted,
        ),
      ),
    );
  }

  @override
  State<StreakCelebrationScreen> createState() =>
      _StreakCelebrationScreenState();
}

class _StreakCelebrationScreenState extends State<StreakCelebrationScreen> {
  var _shared = false;

  @override
  void initState() {
    super.initState();
    unawaited(CelebrationFeedback.streak());
  }

  Future<void> _share() async {
    if (_shared) return;
    final success = await context.read<GamificationCubit>().shareAchievement();
    if (!mounted) return;
    if (success) {
      setState(() => _shared = true);
      context.pop();
      HapticFeedback.mediumImpact();
      XpToastOverlay.show(context, xp: LevelProgress.shareXpReward);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GamificationCubit, GamificationState>(
      buildWhen: (prev, curr) => prev.isSharing != curr.isSharing,
      builder: (context, state) {
        return SuccessScreen(
          illustration: const _StreakMascot(),
          title: '${widget.streakDays}',
          titleStyle: const TextStyle(
            fontSize: 96,
            height: 1,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
          description: 'day streak',
          footer: StreakWeekRow(
            completed: widget.weekCompleted,
            onAccent: true,
          ),
          buttonText: _shared
              ? 'SHARED +${LevelProgress.shareXpReward} XP'
              : 'SHARE +${LevelProgress.shareXpReward} XP',
          isButtonLoading: state.isSharing,
          isButtonEnabled: !_shared,
          onPressed: _share,
          secondaryText: 'Continue',
          onSecondaryPressed: () => Navigator.of(context).pop(),
        );
      },
    );
  }
}

class _StreakMascot extends StatelessWidget {
  const _StreakMascot();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      width: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const CustomPaint(
            size: Size(220, 220),
            painter: _FlameBurstPainter(),
          ),
          const CustomImage(
                asset: successBunny,
                height: 350,
                fit: BoxFit.contain,
              )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .moveY(
                begin: 0,
                end: -10,
                duration: 900.ms,
                curve: Curves.easeInOut,
              )
              .scale(
                begin: const Offset(1, 1),
                end: const Offset(1.04, 1.04),
                duration: 900.ms,
              ),
        ],
      ),
    );
  }
}

class _FlameBurstPainter extends CustomPainter {
  const _FlameBurstPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 + 8);
    final rays = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < 12; i++) {
      final angle = (math.pi * 2 / 12) * i;
      final inner = Offset(
        center.dx + math.cos(angle) * 28,
        center.dy + math.sin(angle) * 28,
      );
      final outer = Offset(
        center.dx + math.cos(angle) * 108,
        center.dy + math.sin(angle) * 108,
      );
      canvas.drawLine(inner, outer, rays);
    }

    final glow = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFFF3A0).withValues(alpha: 0.9),
          const Color(0xFFFFC14A).withValues(alpha: 0.7),
          const Color(0xFFFF8A3D).withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: 110));
    canvas.drawCircle(center, 110, glow);

    final flamePaint = Paint()..style = PaintingStyle.fill;
    const flames = [
      (0.0, 92.0, 0.55),
      (-0.38, 78.0, 0.42),
      (0.38, 78.0, 0.42),
      (-0.72, 62.0, 0.3),
      (0.72, 62.0, 0.3),
    ];
    for (final flame in flames) {
      flamePaint.shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          const Color(0xFFFF8A2A),
          const Color(0xFFFFD24A),
          const Color(0xFFFFF6B0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: flame.$2));
      // _drawFlame(canvas, center, flame.$1, flame.$2, flame.$3, flamePaint);
    }

    final spark = Paint()..color = const Color(0xFFFFF4B0);
    canvas.drawCircle(center + const Offset(-62, -28), 3.5, spark);
    canvas.drawCircle(center + const Offset(70, -18), 2.8, spark);
    canvas.drawCircle(center + const Offset(-48, 48), 2.2, spark);
    canvas.drawCircle(center + const Offset(54, 40), 3, spark);
  }

  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
