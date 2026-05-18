import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stela_mobile/core/di/core_module_container.dart';
import 'package:stela_mobile/core/domain/utils/constants.dart';
import 'package:stela_mobile/core/presentation/manager/custom_provider.dart';
import 'package:stela_mobile/core/presentation/utils/helper_functions.dart';
import 'package:stela_mobile/core/presentation/utils/navigation_mixin.dart';
import 'package:stela_mobile/features/auth/data/dto/user_model_dto.dart';
import 'package:stela_mobile/features/auth/domain/models/user_model.dart';
import 'package:stela_mobile/features/auth/presentation/screens/login.dart';
import 'package:stela_mobile/features/profile/presentation/manager/profile_state.dart';

class ProfileProvider extends CustomProvider {
  final _pref = getIt.getAsync<SharedPreferences>();
  final state = ProfileState();

  Future<void> updateReadingStats({
    required int durationInSeconds,
    String? category,
    List<String>? tags,
    bool isAudio = false,
    double playbackSpeed = 1.0,
    bool isChapterComplete = false,
    bool isBookComplete = false,
  }) async {
    if (cachedUser == null) return;

    final user = cachedUser!;
    final now = DateTime.now();
    final isSessionAfter8pm = now.hour >= 20;

    // 1. Update basic stats
    int newStoriesRead = user.stats.storiesRead + (isBookComplete ? 1 : 0);
    double newReadTimeHours =
        user.stats.readTimeHours + (durationInSeconds / 3600.0);

    int newFantasyBooks =
        user.stats.fantasyBooksCompleted +
        (isBookComplete && category?.toLowerCase() == 'fantasy' ? 1 : 0);
    int newAudioBooks =
        user.stats.audioBooksCompleted + (isBookComplete && isAudio ? 1 : 0);
    int newSessionsAfter8pm =
        user.stats.sessionsAfter8Pm + (isSessionAfter8pm ? 1 : 0);

    List<String> newGenresRead = List.from(user.stats.genresRead);
    if (category != null && !newGenresRead.contains(category)) {
      newGenresRead.add(category);
    }

    int newChaptersAtSpeed =
        user.stats.chaptersAtSpeed +
        (isChapterComplete && playbackSpeed >= 1.5 ? 1 : 0);

    bool isOcean =
        tags?.any(
          (t) => t.toLowerCase() == 'ocean' || t.toLowerCase() == 'water',
        ) ??
        false;
    int newOceanBooks =
        user.stats.oceanBooksCompleted + (isBookComplete && isOcean ? 1 : 0);

    bool isScifi =
        category?.toLowerCase() == 'sci-fi' ||
        (tags?.any((t) => t.toLowerCase() == 'space') ?? false);
    int newScifiBooks =
        user.stats.scifiBooksCompleted + (isBookComplete && isScifi ? 1 : 0);

    // 2. Streaks logic
    int currentStreak = user.streakData.currentStreakDays;
    final today = DateTime(now.year, now.month, now.day);

    if (isChapterComplete) {
      if (user.lastReadDate == null) {
        currentStreak = 1;
      } else {
        final lastRead = DateTime(
          user.lastReadDate!.year,
          user.lastReadDate!.month,
          user.lastReadDate!.day,
        );
        final diff = today.difference(lastRead).inDays;

        if (diff == 1) {
          currentStreak += 1;
        } else if (diff > 1) {
          currentStreak = 1;
        }
      }
    }

    // 3. Badges Engine
    List<BadgeModel> currentBadges = List.from(user.badges);
    bool newlyUnlocked = false;
    void grantBadge(String id, String emoji, String name) {
      if (!currentBadges.any((b) => b.id == id)) {
        currentBadges.add(BadgeModel(id: id, iconAsset: emoji, name: name));
        newlyUnlocked = true;
      }
    }

    // New Badge Rules
    if (newFantasyBooks >= 1) grantBadge('dragon_tamer', '🐉', 'Dragon Tamer');
    if (newStoriesRead >= 5) grantBadge('star_reader', '⭐', 'Star Reader');
    if (currentStreak >= 3) grantBadge('book_worm', '📚', 'Book Worm');
    if (newAudioBooks >= 3) grantBadge('audio_fan', '🎧', 'Audio Fan');
    if (newSessionsAfter8pm >= 1) grantBadge('night_owl', '🦉', 'Night Owl');
    if (currentStreak >= 7) grantBadge('streak_king', '👑', 'Streak King');
    if (newGenresRead.length >= 4) grantBadge('explorer', '🧭', 'Explorer');
    if (newChaptersAtSpeed >= 3)
      grantBadge('speed_reader', '⚡', 'Speed Reader');
    if (newOceanBooks >= 1)
      grantBadge('ocean_explorer', '🌊', 'Ocean Explorer');
    if (newScifiBooks >= 1) grantBadge('scifi_pioneer', '🚀', 'Sci-Fi Pioneer');
    if (newSessionsAfter8pm >= 5)
      grantBadge('midnight_reader', '🌙', 'Midnight Reader');

    // 4. Update Weekly Progress (Mock increment last week for now)
    List<WeeklyProgressModel> newWeekly = List.from(
      user.streakData.weeklyProgress,
    );
    if (newWeekly.isNotEmpty) {
      final last = newWeekly.last;
      newWeekly[newWeekly.length - 1] = WeeklyProgressModel(
        weekLabel: last.weekLabel,
        value: last.value + 10,
      );
    } else {
      newWeekly.add(WeeklyProgressModel(weekLabel: 'Week 1', value: 10));
    }

    // 5. Construct updated user
    final updatedUser = UserModel(
      id: user.id,
      name: user.name,
      email: user.email,
      provider: user.provider,
      avatarUrl: user.avatarUrl,
      level: user.level,

      age: user.age,
      favoriteGenres: user.favoriteGenres,
      title: user.title,
      stats: StatsModel(
        storiesRead: newStoriesRead,
        readTimeHours: newReadTimeHours,
        totalBadges: currentBadges.length,
        fantasyBooksCompleted: newFantasyBooks,
        audioBooksCompleted: newAudioBooks,
        sessionsAfter8Pm: newSessionsAfter8pm,
        genresRead: newGenresRead,
        chaptersAtSpeed: newChaptersAtSpeed,
        oceanBooksCompleted: newOceanBooks,
        scifiBooksCompleted: newScifiBooks,
        sharesCompleted: user.stats.sharesCompleted,
        totalXp: user.stats.totalXp,
      ),
      badges: currentBadges,
      streakData: StreakDataModel(
        currentStreakDays: currentStreak,
        freezesAvailable: user.streakData.freezesAvailable,
        lastFreezeUsedDate: user.streakData.lastFreezeUsedDate,
        weeklyProgress: newWeekly,
      ),
      createdAt: user.createdAt,
      lastReadDate: isChapterComplete ? now : user.lastReadDate,
    );

    await _saveUserAndUpdate(updatedUser);

    if (newlyUnlocked) {
      // Trigger unlock animation
      state.newBadgeUnlocked = true;
      notifyListeners();
    }
  }

  Future<void> shareAchievement() async {
    if (cachedUser == null) return;
    final user = cachedUser!;

    int newShares = user.stats.sharesCompleted + 1;
    List<BadgeModel> currentBadges = List.from(user.badges);

    if (newShares >= 3 &&
        !currentBadges.any((b) => b.id == 'social_butterfly')) {
      currentBadges.add(
        BadgeModel(
          id: 'social_butterfly',
          iconAsset: '🦋',
          name: 'Social Butterfly',
        ),
      );
    }

    final updatedUser = UserModel(
      id: user.id,
      name: user.name,
      email: user.email,
      provider: user.provider,
      avatarUrl: user.avatarUrl,
      level: user.level,
      title: user.title,

      age: user.age,
      favoriteGenres: user.favoriteGenres,
      stats: StatsModel(
        storiesRead: user.stats.storiesRead,
        readTimeHours: user.stats.readTimeHours,
        totalBadges: currentBadges.length,
        fantasyBooksCompleted: user.stats.fantasyBooksCompleted,
        audioBooksCompleted: user.stats.audioBooksCompleted,
        sessionsAfter8Pm: user.stats.sessionsAfter8Pm,
        genresRead: user.stats.genresRead,
        chaptersAtSpeed: user.stats.chaptersAtSpeed,
        oceanBooksCompleted: user.stats.oceanBooksCompleted,
        scifiBooksCompleted: user.stats.scifiBooksCompleted,
        sharesCompleted: newShares,
        totalXp: user.stats.totalXp + 50,
      ),
      badges: currentBadges,
      streakData: user.streakData,
      createdAt: user.createdAt,
      lastReadDate: user.lastReadDate,
    );

    await _saveUserAndUpdate(updatedUser);
  }

  Future<void> evaluateStreakOnOpen(BuildContext context) async {
    if (cachedUser == null) return;
    final user = cachedUser!;

    if (user.lastReadDate == null) return;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastRead = DateTime(
      user.lastReadDate!.year,
      user.lastReadDate!.month,
      user.lastReadDate!.day,
    );

    final diff = today.difference(lastRead).inDays;

    int freezes = user.streakData.freezesAvailable;
    if (user.streakData.lastFreezeUsedDate != null) {
      if (now.month != user.streakData.lastFreezeUsedDate!.month ||
          now.year != user.streakData.lastFreezeUsedDate!.year) {
        freezes = 1;
      }
    }

    String? message;
    int currentStreak = user.streakData.currentStreakDays;

    if (diff == 1) {
      message =
          "Your streak is at risk. Read a chapter today to keep it alive.";
    } else if (diff > 1) {
      if (freezes > 0 && currentStreak > 0) {
        freezes -= 1;
        message =
            "Streak Freeze activated! Your $currentStreak-day streak is safe.";

        final updatedUser = UserModel(
          id: user.id,
          name: user.name,
          email: user.email,
          provider: user.provider,
          avatarUrl: user.avatarUrl,
          level: user.level,
          title: user.title,
          stats: user.stats,

          age: user.age,
          favoriteGenres: user.favoriteGenres,
          badges: user.badges,
          streakData: StreakDataModel(
            currentStreakDays: currentStreak,
            freezesAvailable: freezes,
            lastFreezeUsedDate: now,
            weeklyProgress: user.streakData.weeklyProgress,
          ),
          createdAt: user.createdAt,
          lastReadDate: today.subtract(const Duration(days: 1)),
        );
        await _saveUserAndUpdate(updatedUser);
      } else {
        if (currentStreak > 0) {
          message =
              "Your streak ended. But every great reader starts fresh — begin again today.";
          currentStreak = 0;

          final updatedUser = UserModel(
            id: user.id,
            name: user.name,
            email: user.email,
            provider: user.provider,
            avatarUrl: user.avatarUrl,
            level: user.level,
            title: user.title,
            stats: user.stats,
            badges: user.badges,
            streakData: StreakDataModel(
              currentStreakDays: currentStreak,
              freezesAvailable: freezes,
              lastFreezeUsedDate: user.streakData.lastFreezeUsedDate,
              weeklyProgress: user.streakData.weeklyProgress,
            ),
            createdAt: user.createdAt,
            lastReadDate: user.lastReadDate,
            age: user.age,
            favoriteGenres: user.favoriteGenres,
          );
          await _saveUserAndUpdate(updatedUser);
        } else {
          message = "Welcome back! Start a new streak today.";
        }
      }
    } else if (diff == 0 && currentStreak > 0) {
      if (currentStreak == 7 || currentStreak == 14 || currentStreak == 30) {
        message =
            "$currentStreak-day streak! You're on fire 🔥 Share it and earn XP.";
      } else {
        message = "You're on a 🔥 $currentStreak-day streak! Keep it going.";
      }
    }

    if (message != null) {
      state.streakMessage = message;
      notifyListeners();
    }
  }

  Future<void> _saveUserAndUpdate(UserModel updatedUser) async {
    cachedUser = updatedUser;
    notifyListeners();

    try {
      final prefs = await getIt.getAsync<SharedPreferences>();
      final data = UserModelDto.fromEntity(updatedUser).toJson();
      await prefs.setString(userKey, jsonEncode(data));

      await FirebaseFirestore.instance
          .collection('users')
          .doc(updatedUser.id)
          .update(data);
    } catch (e) {
      logg('Error syncing stats: $e');
    }
  }

  void clearUserSession(BuildContext context) async {
    final pref = await _pref;
    await logout().then((value) {
      pref.remove(userKey);
      pref.remove(tokenKey);

      accessToken = '';
      context.pushNamedAndClear(LoginScreen.id);
    });

    logg('Session cleared');
  }

  Future<void> logout() async {
    try {
      onLoad();
      // await FirebaseAuthService.signOut();
      onLoad();
      add(null);
    } catch (e) {
      onLoad();
      add(e.toString());
    }
  }
}
