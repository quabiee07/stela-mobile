import 'package:equatable/equatable.dart';
import 'package:stela_mobile/features/auth/domain/models/user_model.dart';
import 'package:stela_mobile/features/profile/domain/models/badge_definition.dart';
import 'package:stela_mobile/features/profile/domain/models/streak_info.dart';
import 'package:stela_mobile/features/profile/domain/models/user_badge.dart';

class GamificationState extends Equatable {
  const GamificationState({
    this.streakInfo,
    this.badges = const [],
    this.totalXp = 0,
    this.level = 1,
    this.levelProgressFraction = 0,
    this.storiesRead = 0,
    this.readTimeHours = 0,
    this.lastRewardedStreak,
    this.lastXpEarned,
    this.lastUnlockedBadges = const [],
    this.sessionCountsByDay = const {},
    this.isLoading = false,
    this.isActivatingFreeze = false,
    this.isSharing = false,
  });

  final StreakInfo? streakInfo;
  final List<UserBadge> badges;
  final int totalXp;
  final int level;
  final double levelProgressFraction;
  final int storiesRead;
  final double readTimeHours;
  final int? lastRewardedStreak;
  final int? lastXpEarned;
  final List<String> lastUnlockedBadges;
  final Map<String, int> sessionCountsByDay;
  final bool isLoading;
  final bool isActivatingFreeze;
  final bool isSharing;

  bool get isStreakAtRisk => streakInfo?.isAtRisk ?? false;

  @override
  List<Object?> get props => [
        streakInfo,
        badges,
        totalXp,
        level,
        levelProgressFraction,
        storiesRead,
        readTimeHours,
        lastRewardedStreak,
        lastXpEarned,
        lastUnlockedBadges,
        sessionCountsByDay,
        isLoading,
        isActivatingFreeze,
        isSharing,
      ];

  GamificationState copyWith({
    StreakInfo? streakInfo,
    List<UserBadge>? badges,
    int? totalXp,
    int? level,
    double? levelProgressFraction,
    int? storiesRead,
    double? readTimeHours,
    int? lastRewardedStreak,
    int? lastXpEarned,
    List<String>? lastUnlockedBadges,
    Map<String, int>? sessionCountsByDay,
    bool? isLoading,
    bool? isActivatingFreeze,
    bool? isSharing,
  }) {
    return GamificationState(
      streakInfo: streakInfo ?? this.streakInfo,
      badges: badges ?? this.badges,
      totalXp: totalXp ?? this.totalXp,
      level: level ?? this.level,
      levelProgressFraction:
          levelProgressFraction ?? this.levelProgressFraction,
      storiesRead: storiesRead ?? this.storiesRead,
      readTimeHours: readTimeHours ?? this.readTimeHours,
      lastRewardedStreak: lastRewardedStreak ?? this.lastRewardedStreak,
      lastXpEarned: lastXpEarned ?? this.lastXpEarned,
      lastUnlockedBadges: lastUnlockedBadges ?? this.lastUnlockedBadges,
      sessionCountsByDay: sessionCountsByDay ?? this.sessionCountsByDay,
      isLoading: isLoading ?? this.isLoading,
      isActivatingFreeze: isActivatingFreeze ?? this.isActivatingFreeze,
      isSharing: isSharing ?? this.isSharing,
    );
  }
}

/// Derived display helpers kept off state for badge catalog access.
extension GamificationStateX on GamificationState {
  List<BadgeProgress> badgeProgress(UserModel? user, int? currentStreak) =>
      BadgeCatalog.buildProgress(
        unlocked: badges,
        user: user,
        currentStreak: currentStreak,
      );
}
