class SessionLogResult {
  final bool success;
  final int? currentStreak;
  final String? streakStatus;
  final List<String>? newBadges;
  final bool? alreadyLogged;
  final int? xpEarned;
  final int? totalXp;
  final int? level;
  final double? levelProgress;

  SessionLogResult({
    required this.success,
    this.currentStreak,
    this.streakStatus,
    this.newBadges,
    this.alreadyLogged,
    this.xpEarned,
    this.totalXp,
    this.level,
    this.levelProgress,
  });
}
