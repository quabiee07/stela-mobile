import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stela_mobile/core/presentation/utils/xp_toast_overlay.dart';
import 'package:stela_mobile/features/library/domain/models/reading_reward_event.dart';
import 'package:stela_mobile/features/library/presentation/screens/story_complete.dart';
import 'package:stela_mobile/features/profile/data/services/streak_celebration_store.dart';
import 'package:stela_mobile/features/profile/domain/models/badge_definition.dart';
import 'package:stela_mobile/features/profile/presentation/manager/gamification_cubit.dart';
import 'package:stela_mobile/features/profile/presentation/screens/badge_unlock.dart';
import 'package:stela_mobile/features/profile/presentation/screens/streak_celebration.dart';
import 'package:stela_mobile/features/profile/presentation/utils/gamification_display.dart';

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
      await gamification.applySessionResult(
        event.result,
        isBookComplete: event.isBookComplete,
        sessionMinutes: event.sessionMinutes,
      );

      if (!context.mounted) return;

      // Non-blocking — does not hold autoplay.
      final xp = gamification.state.lastXpEarned;
      if (xp != null && xp > 0) {
        XpToastOverlay.show(context, xp: xp);
      }

      if (event.isBookComplete) {
        await _showChapterRewards(context, event, gamification);
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

      await _showChapterRewards(context, event, gamification);
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
    GamificationCubit gamification,
  ) async {
    final streak =
        event.currentStreak ?? gamification.state.streakInfo?.currentStreak ?? 0;
    // First rewarded session of the day (if open didn't already celebrate).
    if (streak > 0 && context.mounted) {
      final store = StreakCelebrationStore();
      if (!await store.wasShownToday()) {
        await store.markShownToday();
        if (!context.mounted) return;
        final week = GamificationDisplay.thisWeekCompletedWithTodayChecked(
          currentStreak: streak,
          lastReadDate: gamification.state.streakInfo?.lastReadDate,
          sessionCountsByDay: gamification.state.sessionCountsByDay,
          weeklySessionCounts:
              gamification.state.streakInfo?.weeklySessionCounts,
        );
        await StreakCelebrationScreen.open(
          context,
          streakDays: streak,
          weekCompleted: week,
        );
      }
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
