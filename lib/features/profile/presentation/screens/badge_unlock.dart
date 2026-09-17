import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stela_mobile/core/presentation/utils/cover_page_route.dart';
import 'package:stela_mobile/core/presentation/utils/snack_bar_utils.dart';
import 'package:stela_mobile/features/dashboard/presentation/screens/success_screen.dart';
import 'package:stela_mobile/features/profile/domain/models/badge_definition.dart';
import 'package:stela_mobile/features/profile/domain/models/level_progress.dart';
import 'package:stela_mobile/features/profile/presentation/manager/gamification_cubit.dart';
import 'package:stela_mobile/features/profile/presentation/manager/gamification_state.dart';
import 'package:stela_mobile/features/profile/presentation/widgets/badge_image.dart';

class BadgeUnlockScreen extends StatefulWidget {
  const BadgeUnlockScreen({super.key, required this.definition});

  static const String id = '/badge-unlock';

  final BadgeDefinition definition;

  static Future<void> open(BuildContext context, BadgeDefinition definition) {
    return Navigator.of(context).push<void>(
      CoverPageRoute(
        settings: const RouteSettings(name: id),
        builder: (_) => BadgeUnlockScreen(definition: definition),
      ),
    );
  }

  @override
  State<BadgeUnlockScreen> createState() => _BadgeUnlockScreenState();
}

class _BadgeUnlockScreenState extends State<BadgeUnlockScreen> {
  var _shared = false;

  Future<void> _share() async {
    if (_shared) return;
    final success = await context.read<GamificationCubit>().shareAchievement();
    if (!mounted) return;
    if (success) {
      setState(() => _shared = true);
      context.showSuccess(
        'Shared! +${LevelProgress.shareXpReward} XP added to your profile.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GamificationCubit, GamificationState>(
      buildWhen: (prev, curr) => prev.isSharing != curr.isSharing,
      builder: (context, state) {
        return SuccessScreen(
          illustration: _BadgeHero(definition: widget.definition),
          title: 'Badge\nUnlocked!',
          description: widget.definition.description,
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

class _BadgeHero extends StatelessWidget {
  const _BadgeHero({required this.definition});

  final BadgeDefinition definition;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const CustomPaint(size: Size(220, 220), painter: _BadgeGlowPainter()),
          BadgeImage(definition: definition, size: 168)
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .scale(
                begin: const Offset(1, 1),
                end: const Offset(1.06, 1.06),
                duration: 900.ms,
              )
              .animate()
              .fade(duration: 400.ms)
              .scale(
                begin: const Offset(0.6, 0.6),
                curve: Curves.easeOutBack,
                duration: 500.ms,
              ),
        ],
      ),
    );
  }
}

class _BadgeGlowPainter extends CustomPainter {
  const _BadgeGlowPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final glow = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withValues(alpha: 0.22),
          Colors.white.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: 110));
    canvas.drawCircle(center, 110, glow);

    final ray = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 10; i++) {
      final angle = (math.pi * 2 / 10) * i;
      final inner = i.isEven ? 36.0 : 28.0;
      canvas.drawLine(
        Offset(
          center.dx + inner * math.cos(angle),
          center.dy + inner * math.sin(angle),
        ),
        Offset(
          center.dx + 108 * math.cos(angle),
          center.dy + 108 * math.sin(angle),
        ),
        ray,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
