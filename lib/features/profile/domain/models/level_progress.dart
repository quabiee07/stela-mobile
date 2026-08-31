/// Client-side XP → level curve used when the API omits level fields.
/// 100 XP per level keeps early progress snappy for kids.
abstract final class LevelProgress {
  static const xpPerLevel = 100;

  static int levelFromXp(int totalXp) =>
      (totalXp ~/ xpPerLevel).clamp(0, 999) + 1;

  static int xpIntoLevel(int totalXp) => totalXp % xpPerLevel;

  static int xpToNextLevel(int totalXp) =>
      xpPerLevel - xpIntoLevel(totalXp);

  static double fraction(int totalXp) => xpIntoLevel(totalXp) / xpPerLevel;

  /// Fallback XP when POST /sessions/log does not yet return [xpEarned].
  static int fallbackSessionXp({required bool isBookComplete}) =>
      isBookComplete ? 40 : 15;
}
