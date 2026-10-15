import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stela_mobile/core/presentation/utils/celebration_feedback.dart';
import 'package:stela_mobile/core/presentation/utils/cover_page_route.dart';
import 'package:stela_mobile/core/presentation/utils/xp_toast_overlay.dart';
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

class _BadgeHero extends StatefulWidget {
  const _BadgeHero({required this.definition});

  final BadgeDefinition definition;

  @override
  State<_BadgeHero> createState() => _BadgeHeroState();
}

class _BadgeHeroState extends State<_BadgeHero> {
  var _routeSettled = false;
  var _listening = false;
  Animation<double>? _routeAnimation;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final animation = ModalRoute.of(context)?.animation;
    if (animation == null || identical(animation, _routeAnimation)) return;

    _routeAnimation?.removeStatusListener(_onRouteStatus);
    _routeAnimation = animation;

    if (animation.status == AnimationStatus.completed) {
      _onRouteSettled();
    } else if (!_listening) {
      _listening = true;
      animation.addStatusListener(_onRouteStatus);
    }
  }

  @override
  void dispose() {
    _routeAnimation?.removeStatusListener(_onRouteStatus);
    super.dispose();
  }

  void _onRouteStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _onRouteSettled();
    }
  }

  void _onRouteSettled() {
    if (!mounted || _routeSettled) return;
    setState(() => _routeSettled = true);
    unawaited(CelebrationFeedback.badge());
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 270,
      height: 270,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          if (_routeSettled)
            const CustomPaint(
                  size: Size(250, 250),
                  painter: _BadgeGlowPainter(),
                )
                .animate()
                .fadeIn(duration: 400.ms),
          // Invisible placeholder keeps layout stable while waiting.
          if (!_routeSettled)
            const SizedBox(width: 200, height: 200)
          else
            BadgeImage(definition: widget.definition, size: 200)
                .animate(delay: 80.ms)
                .fadeIn(duration: 200.ms, curve: Curves.easeInCubic)
                .slideY(
                  begin: 1.15,
                  end: 0,
                  duration: 780.ms,
                  curve: Curves.easeOutBack,
                )
                .scale(
                  begin: const Offset(0.55, 0.55),
                  end: const Offset(1, 1),
                  duration: 900.ms,
                  curve: Curves.elasticOut,
                )
                .animate(
                  delay: 850.ms,
                  onPlay: (controller) => controller.repeat(reverse: true),
                )
                .moveY(
                  begin: 0,
                  end: -8,
                  duration: 1100.ms,
                  curve: Curves.easeInOut,
                )
                .scale(
                  begin: const Offset(1, 1),
                  end: const Offset(1.04, 1.04),
                  duration: 1100.ms,
                  curve: Curves.easeInOut,
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
