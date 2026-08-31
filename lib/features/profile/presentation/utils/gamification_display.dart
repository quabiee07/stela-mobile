import 'package:stela_mobile/features/auth/domain/models/user_model.dart';

class GamificationDisplay {
  static const badgeIcons = {
    'book_worm': '📚',
    'dragon_tamer': '🐉',
    'star_reader': '⭐',
    'audio_fan': '🎧',
    'night_owl': '🦉',
    'streak_king': '👑',
    'explorer': '🧭',
    'speed_reader': '⚡',
    'ocean_explorer': '🌊',
    'scifi_pioneer': '🚀',
    'midnight_reader': '🌙',
    'social_butterfly': '🦋',
  };

  static const _weekdayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  /// Visual height for a single session on the streak chart.
  static const dayActiveValue = 40;

  static String badgeIcon(String badgeId) =>
      badgeIcons[badgeId] ?? '🏅';

  static String badgeName(String badgeId) {
    return badgeId
        .split('_')
        .map(
          (word) => word.isEmpty
              ? word
              : '${word[0].toUpperCase()}${word.substring(1)}',
        )
        .join(' ');
  }

  static StreakDataModel? streakDataForDisplay({
    required int? currentStreak,
    required bool? freezeAvailable,
    required String? freezeActivatedDate,
    String? lastReadDate,
    StreakDataModel? localFallback,
    Map<String, int>? sessionCountsByDay,
    List<int>? weeklySessionCounts,
  }) {
    if (currentStreak == null && localFallback == null) return null;

    final streak = currentStreak ?? localFallback?.currentStreakDays ?? 0;

    return StreakDataModel(
      currentStreakDays: streak,
      freezesAvailable: (freezeAvailable ?? false)
          ? 1
          : (localFallback?.freezesAvailable ?? 0),
      lastFreezeUsedDate: freezeActivatedDate == null
          ? localFallback?.lastFreezeUsedDate
          : DateTime.tryParse(freezeActivatedDate),
      // Prefer GET /streak weeklySessionCounts — do not require local storage.
      weeklyProgress: weeklyProgressFromApi(weeklySessionCounts) ??
          buildThisWeekProgress(
            currentStreak: streak,
            lastReadDate: lastReadDate,
            sessionCountsByDay: sessionCountsByDay,
          ),
    );
  }

  /// Maps Mon–Sun session counts from the streak API into chart bar values.
  static List<WeeklyProgressModel>? weeklyProgressFromApi(
    List<int>? weeklySessionCounts,
  ) {
    if (weeklySessionCounts == null || weeklySessionCounts.isEmpty) {
      return null;
    }

    return List.generate(_weekdayLabels.length, (i) {
      final sessions =
          i < weeklySessionCounts.length ? weeklySessionCounts[i] : 0;
      return WeeklyProgressModel(
        weekLabel: _weekdayLabels[i],
        value: sessions > 0
            ? (sessions * dayActiveValue).clamp(dayActiveValue, 200)
            : 0,
      );
    });
  }

  /// Builds Mon–Sun bars for the current calendar week from the active streak
  /// window when the streak API omits [weeklySessionCounts].
  static List<WeeklyProgressModel> buildThisWeekProgress({
    required int currentStreak,
    String? lastReadDate,
    DateTime? now,
    Map<String, int>? sessionCountsByDay,
  }) {
    final today = _dateOnly(now ?? DateTime.now());
    final monday = today.subtract(Duration(days: today.weekday - DateTime.monday));

    DateTime? lastRead = lastReadDate == null
        ? null
        : DateTime.tryParse(lastReadDate);
    if (lastRead != null) {
      lastRead = _dateOnly(lastRead);
    } else if (currentStreak > 0) {
      // Seeded/local streaks may lack a last-read date; assume today so the
      // active window is still visible on the chart.
      lastRead = today;
    }

    DateTime? streakStart;
    if (lastRead != null && currentStreak > 0) {
      streakStart = lastRead.subtract(Duration(days: currentStreak - 1));
    }

    return List.generate(_weekdayLabels.length, (index) {
      final day = monday.add(Duration(days: index));
      final key = _dayKey(day);
      final sessions = sessionCountsByDay?[key] ?? 0;
      final inStreak = streakStart != null &&
          !day.isBefore(streakStart) &&
          !day.isAfter(lastRead!) &&
          !day.isAfter(today);

      final value = inStreak
          ? (sessions > 0
              ? (sessions * dayActiveValue).clamp(dayActiveValue, 200).toInt()
              : dayActiveValue)
          : (sessions > 0
              ? (sessions * dayActiveValue).clamp(dayActiveValue, 200).toInt()
              : 0);

      return WeeklyProgressModel(
        weekLabel: _weekdayLabels[index],
        value: value,
      );
    });
  }

  static String dayKey([DateTime? date]) => _dayKey(_dateOnly(date ?? DateTime.now()));

  static DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  static String _dayKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}
