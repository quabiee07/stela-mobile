/// Client-side XP → level curve used when the API omits level fields.
/// 100 XP per level keeps early progress snappy for kids. Cap is level 100.
abstract final class LevelProgress {
  static const xpPerLevel = 100;
  static const maxLevel = 100;

  static const _romans = [
    'I',
    'II',
    'III',
    'IV',
    'V',
    'VI',
    'VII',
    'VIII',
    'IX',
    'X',
  ];

  /// Decade tiers (levels 1–99). Level 100 is [titleForLevel] → Stelar.
  static const _tierNames = [
    'Hatchling', // 1–10
    'Page Turner', // 11–20
    'Story Scout', // 21–30
    'Book Voyager', // 31–40
    'Voice Seeker', // 41–50
    'Quest Rider', // 51–60
    'Myth Maker', // 61–70
    'Lore Keeper', // 71–80
    'Star Reader', // 81–90
    'Legend', // 91–99
  ];

  static int levelFromXp(int totalXp) {
    if (totalXp <= 0) return 1;
    return (totalXp ~/ xpPerLevel).clamp(0, maxLevel - 1) + 1;
  }

  static int xpIntoLevel(int totalXp) {
    if (levelFromXp(totalXp) >= maxLevel) return xpPerLevel;
    return totalXp % xpPerLevel;
  }

  static int xpToNextLevel(int totalXp) {
    if (levelFromXp(totalXp) >= maxLevel) return 0;
    return xpPerLevel - xpIntoLevel(totalXp);
  }

  static double fraction(int totalXp) {
    if (levelFromXp(totalXp) >= maxLevel) return 1;
    return xpIntoLevel(totalXp) / xpPerLevel;
  }

  /// Display title for a level (e.g. `Hatchling I`, `Voice Seeker VII`, `Stelar`).
  static String titleForLevel(int level) {
    if (level >= maxLevel) return 'Stelar';
    final clamped = level.clamp(1, maxLevel - 1);
    final tierIndex = (clamped - 1) ~/ 10;
    final romanIndex = (clamped - 1) % 10;
    return '${_tierNames[tierIndex]} ${_romans[romanIndex]}';
  }

  /// XP awarded by `POST /xp/share`.
  static const shareXpReward = 20;

  /// Fallback XP when POST /sessions/log does not yet return [xpEarned].
  static int fallbackSessionXp({required bool isBookComplete}) =>
      isBookComplete ? 40 : 15;

  /// Profile/session payloads can lag behind a just-logged chapter. Never let
  /// a stale remote total replace a higher local total.
  static int preferXp(int? remote, int local) {
    final value = remote ?? 0;
    return value > local ? value : local;
  }
}
