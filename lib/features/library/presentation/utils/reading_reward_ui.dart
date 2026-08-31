import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stela_mobile/core/presentation/utils/snack_bar_utils.dart';
import 'package:stela_mobile/core/presentation/widgets/animations/badge_unlock_overlay.dart';
import 'package:stela_mobile/core/presentation/widgets/animations/streak_notification_dialog.dart';
import 'package:stela_mobile/features/library/domain/models/reading_reward_event.dart';
import 'package:stela_mobile/features/library/presentation/widgets/story_complete_sheet.dart';
import 'package:stela_mobile/features/profile/presentation/manager/gamification_cubit.dart';

class ReadingRewardUi {
  static final Set<String> _shownBadgeIds = {};

  static Future<void> handle(
    BuildContext context,
    ReadingRewardEvent event,
  ) async {
    if (!context.mounted) return;

    if (event.result.alreadyLogged == true) {
      event.uiCompleter?.complete();
      return;
    }

    final gamification = context.read<GamificationCubit>();
    final previousStreak = gamification.state.streakInfo?.currentStreak;
    await gamification.applySessionResult(
      event.result,
      isBookComplete: event.isBookComplete,
      sessionMinutes: event.sessionMinutes,
    );

    if (!context.mounted) {
      event.uiCompleter?.complete();
      return;
    }

    final xp = gamification.state.lastXpEarned;
    if (xp != null && xp > 0) {
      context.showSuccess('+$xp XP');
    }

    if (event.isBookComplete) {
      await _showBadgeOverlays(context, event, gamification);
      if (!context.mounted) {
        event.uiCompleter?.complete();
        return;
      }

      await showStoryCompleteSheet(
        context,
        storyTitle: event.storyTitle ?? 'your story',
        chaptersCompleted: event.chapterNumber,
        currentStreak: event.currentStreak,
        xpEarned: xp,
        newBadges: event.newBadges,
        onShareXp: () => gamification.shareAchievement(),
      );
      event.uiCompleter?.complete();
      return;
    }

    await _showChapterRewards(
      context,
      event,
      gamification,
      previousStreak: previousStreak,
    );
    event.uiCompleter?.complete();
  }

  static Future<void> _showChapterRewards(
    BuildContext context,
    ReadingRewardEvent event,
    GamificationCubit gamification, {
    required int? previousStreak,
  }) async {
    final streak = event.currentStreak;
    final streakChanged =
        streak != null && streak > 1 && streak != previousStreak;
    if (streakChanged) {
      if (streak == 3 || streak == 7 || streak == 14 || streak == 30) {
        StreakNotificationDialog.show(
          context,
          "You're on a $streak-day streak! Keep it going.",
        );
      } else {
        context.showSuccess('Your streak is now $streak days!');
      }
    }

    await _showBadgeOverlays(context, event, gamification);
  }

  static Future<void> _showBadgeOverlays(
    BuildContext context,
    ReadingRewardEvent event,
    GamificationCubit gamification,
  ) async {
    for (final badgeId in event.newBadges.toSet()) {
      if (!_shownBadgeIds.add(badgeId)) continue;
      if (!context.mounted) return;
      await _showBadgeDialog(
        context,
        gamification.badgeIcon(badgeId),
        gamification.badgeName(badgeId),
      );
      await gamification.markBadgeSeen(badgeId);
    }
  }

  static Future<void> _showBadgeDialog(
    BuildContext context,
    String icon,
    String name,
  ) {
    final completer = Completer<void>();
    BadgeUnlockOverlay.show(context, icon, name);
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (context.mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      if (!completer.isCompleted) completer.complete();
    });
    return completer.future;
  }
}
