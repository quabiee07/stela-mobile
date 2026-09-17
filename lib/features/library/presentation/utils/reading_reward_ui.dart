import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stela_mobile/core/presentation/utils/snack_bar_utils.dart';
import 'package:stela_mobile/features/library/domain/models/reading_reward_event.dart';
import 'package:stela_mobile/features/library/presentation/screens/story_complete.dart';
import 'package:stela_mobile/features/profile/domain/models/badge_definition.dart';
import 'package:stela_mobile/features/profile/presentation/manager/gamification_cubit.dart';
import 'package:stela_mobile/features/profile/presentation/screens/badge_unlock.dart';
import 'package:stela_mobile/features/profile/presentation/screens/streak_celebration.dart';

class ReadingRewardUi {
  static final Set<String> _shownBadgeIds = {};

  /// Applies gamification, shows blocking celebration screens when earned,
  /// and **always** completes [ReadingRewardEvent.uiCompleter] so playback
  /// can auto-advance. XP toast alone does not hold the gate.
  static Future<void> handle(
    BuildContext context,
    ReadingRewardEvent event,
  ) async {
    final gate = event.uiCompleter;
    try {
      if (!context.mounted) return;

      if (event.result.alreadyLogged == true) return;

      final gamification = context.read<GamificationCubit>();
      final previousStreak = gamification.state.streakInfo?.currentStreak;
      await gamification.applySessionResult(
        event.result,
        isBookComplete: event.isBookComplete,
        sessionMinutes: event.sessionMinutes,
      );

      if (!context.mounted) return;

      // Non-blocking — does not hold autoplay.
      final xp = gamification.state.lastXpEarned;
      if (xp != null && xp > 0) {
        context.showSuccess('+$xp XP');
      }

      if (event.isBookComplete) {
        await _showChapterRewards(
          context,
          event,
          gamification,
          previousStreak: previousStreak,
        );
        if (!context.mounted) return;

        await StoryCompleteScreen.open(
          context,
          storyTitle: event.storyTitle ?? 'your story',
          chaptersCompleted: event.chapterNumber,
          currentStreak: event.currentStreak,
          xpEarned: xp,
        );
        return;
      }

      await _showChapterRewards(
        context,
        event,
        gamification,
        previousStreak: previousStreak,
      );
    } finally {
      _completeGate(gate);
    }
  }

  static void _completeGate(Completer<void>? gate) {
    if (gate != null && !gate.isCompleted) {
      gate.complete();
    }
  }

  static Future<void> _showChapterRewards(
    BuildContext context,
    ReadingRewardEvent event,
    GamificationCubit gamification, {
    required int? previousStreak,
  }) async {
    final streak = event.currentStreak;
    final streakIncreased =
        streak != null &&
        streak > 0 &&
        (previousStreak == null || streak > previousStreak);
    if (streakIncreased && context.mounted) {
      await StreakCelebrationScreen.open(
        context,
        streakDays: streak,
        weekCompleted: gamification.thisWeekCompleted,
      );
    }

    if (!context.mounted) return;
    await _showBadgeScreens(context, event, gamification);
  }

  static Future<void> _showBadgeScreens(
    BuildContext context,
    ReadingRewardEvent event,
    GamificationCubit gamification,
  ) async {
    for (final badgeId in event.newBadges.toSet()) {
      if (!_shownBadgeIds.add(badgeId)) continue;
      if (!context.mounted) return;
      final definition =
          BadgeCatalog.find(badgeId) ??
          BadgeDefinition(
            id: badgeId,
            name: gamification.badgeName(badgeId),
            icon: gamification.badgeIcon(badgeId),
            asset: gamification.badgeAsset(badgeId),
            description: gamification.badgeDescription(badgeId),
            target: 1,
          );
      await BadgeUnlockScreen.open(context, definition);
      await gamification.markBadgeSeen(badgeId);
    }
  }
}
