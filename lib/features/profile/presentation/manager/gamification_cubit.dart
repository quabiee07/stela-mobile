import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:stela_mobile/core/domain/utils/constants.dart';
import 'package:stela_mobile/core/di/core_module_container.dart';
import 'package:stela_mobile/core/presentation/utils/helper_functions.dart';
import 'package:stela_mobile/features/auth/domain/models/user_model.dart';
import 'package:stela_mobile/features/library/domain/models/session_log_result.dart';
import 'package:stela_mobile/features/profile/data/services/weekly_activity_store.dart';
import 'package:stela_mobile/features/profile/domain/models/badge_definition.dart';
import 'package:stela_mobile/features/profile/domain/models/level_progress.dart';
import 'package:stela_mobile/features/profile/domain/models/streak_info.dart';
import 'package:stela_mobile/features/profile/domain/models/user_badge.dart';
import 'package:stela_mobile/features/profile/domain/repository/profile_repository.dart';
import 'package:stela_mobile/features/profile/domain/usecases/activate_streak_freeze_usecase.dart';
import 'package:stela_mobile/features/profile/domain/usecases/get_badges_usecase.dart';
import 'package:stela_mobile/features/profile/domain/usecases/get_streak_usecase.dart';
import 'package:stela_mobile/features/profile/domain/usecases/share_xp_usecase.dart';
import 'package:stela_mobile/features/profile/presentation/manager/gamification_state.dart';
import 'package:stela_mobile/features/profile/presentation/utils/gamification_display.dart';

sealed class GamificationEffect {
  const GamificationEffect();
}

final class GamificationErrorEffect extends GamificationEffect {
  const GamificationErrorEffect(this.message);
  final String message;
}

@lazySingleton
class GamificationCubit extends Cubit<GamificationState> {
  GamificationCubit(this._repo) : super(const GamificationState()) {
    _bootstrapFromCache();
    _weeklyActivity.load().then((counts) {
      emit(state.copyWith(sessionCountsByDay: counts));
    });
  }

  final ProfileRepository _repo;
  final _weeklyActivity = WeeklyActivityStore();
  final _locallySeenBadges = <String>{};
  final _effects = StreamController<GamificationEffect>.broadcast();

  Stream<GamificationEffect> get effects => _effects.stream;

  void _bootstrapFromCache() {
    final user = cachedUser;
    var totalXp = user?.stats.totalXp ?? 0;
    var level = user?.level ?? LevelProgress.levelFromXp(totalXp);
    StreakInfo? streakInfo;

    final local = user?.streakData;
    if (local != null && local.currentStreakDays > 0) {
      streakInfo = StreakInfo(
        currentStreak: local.currentStreakDays,
        longestStreak: local.currentStreakDays,
        lastReadDate: user?.lastReadDate?.toIso8601String().split('T').first,
        streakStatus: 'active',
        freezeAvailable: local.freezesAvailable > 0,
        freezeUsedThisMonth: local.lastFreezeUsedDate != null,
        freezeActivatedDate: local.lastFreezeUsedDate?.toIso8601String(),
        lastUpdatedAt: null,
      );
    }

    emit(
      state.copyWith(
        streakInfo: streakInfo,
        totalXp: totalXp,
        level: level,
        levelProgressFraction: LevelProgress.fraction(totalXp),
        storiesRead: user?.stats.storiesRead ?? 0,
        readTimeHours: user?.stats.readTimeHours ?? 0,
      ),
    );
  }

  int get freezesAvailable {
    if (state.streakInfo == null) {
      return cachedUser?.streakData.freezesAvailable ?? 0;
    }
    return state.streakInfo!.freezeAvailable ? 1 : 0;
  }

  List<BadgeProgress> get badgeProgress => BadgeCatalog.buildProgress(
        unlocked: state.badges,
        user: cachedUser,
        currentStreak: state.streakInfo?.currentStreak,
      );

  StreakDataModel? get streakDataForDisplay {
    return GamificationDisplay.streakDataForDisplay(
      currentStreak: state.streakInfo?.currentStreak,
      freezeAvailable: state.streakInfo?.freezeAvailable,
      freezeActivatedDate: state.streakInfo?.freezeActivatedDate,
      lastReadDate: state.streakInfo?.lastReadDate ??
          cachedUser?.lastReadDate?.toIso8601String().split('T').first,
      localFallback: cachedUser?.streakData,
      sessionCountsByDay: state.sessionCountsByDay,
      weeklySessionCounts: state.streakInfo?.weeklySessionCounts,
    );
  }

  String badgeIcon(String badgeId) =>
      BadgeCatalog.find(badgeId)?.icon ??
      GamificationDisplay.badgeIcon(badgeId);

  String badgeName(String badgeId) =>
      BadgeCatalog.find(badgeId)?.name ??
      GamificationDisplay.badgeName(badgeId);

  Future<void> loadGamification() async {
    emit(state.copyWith(isLoading: true));

    final streakResult = await GetStreakUseCase(_repo).invoke();
    final streak = streakResult.getOrElse((error) {
      _effects.add(GamificationErrorEffect(error.toString()));
      return null;
    });

    final badgesResult = await GetBadgesUseCase(_repo).invoke();
    final items = badgesResult.getOrElse((error) {
      _effects.add(GamificationErrorEffect(error.toString()));
      return null;
    });

    final badges = items
            ?.map(
              (b) => UserBadge(
                badgeId: b.badgeId,
                unlockedAt: b.unlockedAt,
                seen: b.seen || _locallySeenBadges.contains(b.badgeId),
              ),
            )
            .toList() ??
        state.badges;

    final sessionCountsByDay = await _weeklyActivity.load();
    // Prefer the higher XP source so a fresh session result is never wiped by
    // a stale cached user (or vice versa).
    final cachedXp = cachedUser?.stats.totalXp ?? 0;
    final totalXp = cachedXp > state.totalXp ? cachedXp : state.totalXp;
    final cachedLevel = cachedUser?.level ?? 0;
    final derivedLevel = LevelProgress.levelFromXp(totalXp);
    final level = cachedLevel > derivedLevel ? cachedLevel : derivedLevel;
    final cachedStories = cachedUser?.stats.storiesRead ?? 0;
    final storiesRead =
        cachedStories > state.storiesRead ? cachedStories : state.storiesRead;
    final cachedReadHours = cachedUser?.stats.readTimeHours ?? 0;
    final readTimeHours = cachedReadHours > state.readTimeHours
        ? cachedReadHours
        : state.readTimeHours;
    final levelProgressFraction = totalXp == state.totalXp &&
            state.levelProgressFraction > 0
        ? state.levelProgressFraction
        : LevelProgress.fraction(totalXp);

    emit(
      state.copyWith(
        streakInfo: streak ?? state.streakInfo,
        badges: badges,
        sessionCountsByDay: sessionCountsByDay,
        totalXp: totalXp,
        level: level,
        levelProgressFraction: levelProgressFraction,
        storiesRead: storiesRead,
        readTimeHours: readTimeHours,
        isLoading: false,
      ),
    );
    _syncCachedUserXpAndStreak();
  }

  Future<void> applySessionResult(
    SessionLogResult result, {
    bool isBookComplete = false,
    int sessionMinutes = 1,
  }) async {
    if (result.alreadyLogged == true) return;

    final sessionCountsByDay = await _weeklyActivity.incrementToday();
    final today = GamificationDisplay.dayKey();
    final streak = result.currentStreak ?? state.streakInfo?.currentStreak ?? 0;
    final previousStreakInfo = state.streakInfo;

    final streakInfo = StreakInfo(
      currentStreak: streak,
      longestStreak: previousStreakInfo == null
          ? streak
          : (previousStreakInfo.longestStreak < streak
              ? streak
              : previousStreakInfo.longestStreak),
      lastReadDate: today,
      streakStatus:
          result.streakStatus ?? previousStreakInfo?.streakStatus ?? 'active',
      freezeAvailable: previousStreakInfo?.freezeAvailable ?? true,
      freezeUsedThisMonth: previousStreakInfo?.freezeUsedThisMonth ?? false,
      freezeActivatedDate: previousStreakInfo?.freezeActivatedDate,
      lastUpdatedAt: previousStreakInfo?.lastUpdatedAt,
      weeklySessionCounts: previousStreakInfo?.weeklySessionCounts,
    );

    final earned = result.xpEarned ??
        LevelProgress.fallbackSessionXp(isBookComplete: isBookComplete);
    final totalXp = result.totalXp ?? (state.totalXp + earned);
    final level = result.level ?? LevelProgress.levelFromXp(totalXp);
    final levelProgressFraction =
        result.levelProgress ?? LevelProgress.fraction(totalXp);
    final minutes = sessionMinutes.clamp(1, 240);
    final storiesRead = state.storiesRead + (isBookComplete ? 1 : 0);
    final readTimeHours =
        state.readTimeHours + (minutes / 60.0);

    emit(
      state.copyWith(
        lastRewardedStreak: result.currentStreak,
        lastUnlockedBadges: result.newBadges ?? const [],
        sessionCountsByDay: sessionCountsByDay,
        streakInfo: streakInfo,
        lastXpEarned: earned,
        totalXp: totalXp,
        level: level,
        levelProgressFraction: levelProgressFraction,
        storiesRead: storiesRead,
        readTimeHours: readTimeHours,
      ),
    );

    _syncCachedUserXpAndStreak();
    unawaited(loadGamification());
  }

  void _syncCachedUserStreak() {
    final user = cachedUser;
    final streak = state.streakInfo;
    if (user == null || streak == null) return;
    cachedUser = UserModel(
      id: user.id,
      name: user.name,
      email: user.email,
      provider: user.provider,
      avatarUrl: user.avatarUrl,
      age: user.age,
      favoriteGenres: user.favoriteGenres,
      level: state.level,
      title: user.title,
      stats: user.stats,
      badges: user.badges,
      streakData: StreakDataModel(
        currentStreakDays: streak.currentStreak,
        freezesAvailable: streak.freezeAvailable ? 1 : 0,
        lastFreezeUsedDate: streak.freezeActivatedDate == null
            ? user.streakData.lastFreezeUsedDate
            : DateTime.tryParse(streak.freezeActivatedDate!),
        weeklyProgress:
            GamificationDisplay.weeklyProgressFromApi(
              streak.weeklySessionCounts,
            ) ??
            user.streakData.weeklyProgress,
      ),
      createdAt: user.createdAt,
      lastReadDate: streak.lastReadDate == null
          ? user.lastReadDate
          : DateTime.tryParse(streak.lastReadDate!),
    );
  }

  void _syncCachedUserXpAndStreak() {
    final user = cachedUser;
    if (user == null) return;
    cachedUser = UserModel(
      id: user.id,
      name: user.name,
      email: user.email,
      provider: user.provider,
      avatarUrl: user.avatarUrl,
      age: user.age,
      favoriteGenres: user.favoriteGenres,
      level: state.level,
      title: user.title,
      stats: StatsModel(
        storiesRead: state.storiesRead,
        readTimeHours: state.readTimeHours,
        totalBadges: user.stats.totalBadges,
        fantasyBooksCompleted: user.stats.fantasyBooksCompleted,
        audioBooksCompleted: user.stats.audioBooksCompleted,
        sessionsAfter8Pm: user.stats.sessionsAfter8Pm,
        genresRead: user.stats.genresRead,
        chaptersAtSpeed: user.stats.chaptersAtSpeed,
        oceanBooksCompleted: user.stats.oceanBooksCompleted,
        scifiBooksCompleted: user.stats.scifiBooksCompleted,
        sharesCompleted: user.stats.sharesCompleted,
        totalXp: state.totalXp,
      ),
      badges: user.badges,
      streakData: user.streakData,
      createdAt: user.createdAt,
      lastReadDate: user.lastReadDate,
    );
    _syncCachedUserStreak();
    unawaited(persistCachedUser());
  }

  Future<void> markBadgeSeen(String badgeId) async {
    _locallySeenBadges.add(badgeId);
    emit(
      state.copyWith(
        badges: state.badges
            .map(
              (b) => b.badgeId == badgeId
                  ? UserBadge(
                      badgeId: b.badgeId,
                      unlockedAt: b.unlockedAt,
                      seen: true,
                    )
                  : b,
            )
            .toList(),
      ),
    );
    await _repo.markBadgeSeen(badgeId);
  }

  Future<bool> activateFreeze() async {
    if (state.isActivatingFreeze) return false;
    emit(state.copyWith(isActivatingFreeze: true));

    final result = await ActivateStreakFreezeUseCase(_repo).invoke();
    final freeze = result.getOrElse((error) {
      _effects.add(GamificationErrorEffect(error.toString()));
      return null;
    });

    emit(state.copyWith(isActivatingFreeze: false));
    if (freeze == null || !freeze.success) return false;
    await loadGamification();
    return true;
  }

  Future<bool> shareAchievement() async {
    if (state.isSharing) return false;
    emit(state.copyWith(isSharing: true));

    final apiResult = await ShareXpUseCase(_repo).invoke();
    final shareResult = apiResult.getOrElse((error) {
      _effects.add(GamificationErrorEffect(error.toString()));
      return null;
    });

    emit(state.copyWith(isSharing: false));
    if (shareResult == null || !shareResult.success) return false;

    final totalXp = state.totalXp + 25;
    emit(
      state.copyWith(
        totalXp: totalXp,
        lastXpEarned: 25,
        level: LevelProgress.levelFromXp(totalXp),
        levelProgressFraction: LevelProgress.fraction(totalXp),
      ),
    );
    _syncCachedUserXpAndStreak();
    await loadGamification();
    return true;
  }

  @override
  Future<void> close() {
    _effects.close();
    return super.close();
  }
}

GamificationCubit get gamificationCubit => getIt.get<GamificationCubit>();
