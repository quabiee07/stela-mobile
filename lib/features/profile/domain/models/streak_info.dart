import 'package:stela_mobile/features/profile/domain/models/api_timestamp.dart';

class StreakInfo {
  final int currentStreak;
  final int longestStreak;
  final String? lastReadDate;
  final String streakStatus;
  final bool freezeAvailable;
  final bool freezeUsedThisMonth;
  final String? freezeActivatedDate;
  final ApiTimestamp? lastUpdatedAt;

  /// Optional Mon–Sun session counts from the server (preferred over local).
  final List<int>? weeklySessionCounts;

  const StreakInfo({
    required this.currentStreak,
    required this.longestStreak,
    required this.lastReadDate,
    required this.streakStatus,
    required this.freezeAvailable,
    required this.freezeUsedThisMonth,
    required this.freezeActivatedDate,
    required this.lastUpdatedAt,
    this.weeklySessionCounts,
  });

  /// True when the user read yesterday (or earlier) but not today and streak > 0.
  bool get isAtRisk {
    if (currentStreak <= 0) return false;
    if (streakStatus == 'broken') return false;
    if (streakStatus == 'frozen') return false;
    final last = lastReadDate;
    if (last == null) return false;
    final lastDay = DateTime.tryParse(last);
    if (lastDay == null) return false;
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    final lastOnly = DateTime(lastDay.year, lastDay.month, lastDay.day);
    return todayOnly.difference(lastOnly).inDays == 1;
  }
}

class StreakFreezeResult {
  final bool success;
  final int currentStreak;

  const StreakFreezeResult({
    required this.success,
    required this.currentStreak,
  });
}
