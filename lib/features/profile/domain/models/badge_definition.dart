import 'package:stela_mobile/core/presentation/resources/drawables.dart';
import 'package:stela_mobile/features/auth/domain/models/user_model.dart';
import 'package:stela_mobile/features/profile/domain/models/user_badge.dart';

class BadgeDefinition {
  const BadgeDefinition({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
    required this.target,
    this.asset = '',
    this.requirementLabel = '',
  });

  final String id;
  final String name;
  final String icon;
  final String description;

  /// Hexagonal illustration asset. Empty when only the emoji fallback exists.
  final String asset;

  /// Small caption shown above the name on the profile grid (e.g. "5 Books").
  final String requirementLabel;

  /// Progress target for the related stat (1 = binary unlock).
  final int target;
}

class BadgeProgress {
  const BadgeProgress({
    required this.definition,
    required this.current,
    required this.unlocked,
    required this.seen,
    this.unlockedAt,
  });

  final BadgeDefinition definition;
  final int current;
  final bool unlocked;
  final bool seen;
  final DateTime? unlockedAt;

  double get fraction {
    if (definition.target <= 0) return unlocked ? 1 : 0;
    return (current / definition.target).clamp(0.0, 1.0);
  }

  int get remaining =>
      (definition.target - current).clamp(0, definition.target);
}

/// Full catalog — locked badges stay visible with progress toward unlock.
abstract final class BadgeCatalog {
  static const List<BadgeDefinition> all = [
    BadgeDefinition(
      id: 'dragon_tamer',
      name: 'Dragon Tamer',
      icon: '🐉',
      asset: badgeDragonTamer,
      requirementLabel: '1 Fantasy',
      description:
          'You finished a fantasy story. The dragons have officially accepted you.',
      target: 1,
    ),
    BadgeDefinition(
      id: 'night_owl',
      name: 'Night Owl',
      icon: '🦉',
      asset: badgeNightOwl,
      requirementLabel: 'After 8pm',
      description: 'You read after 8pm. The moon is keeping you company.',
      target: 1,
    ),
    BadgeDefinition(
      id: 'book_worm',
      name: 'Book Worm',
      icon: '📚',
      asset: badgeBookWorm,
      requirementLabel: '5 Books',
      description:
          '5 books down! Your brain is officially leveling up. Worms everywhere are proud of you.',
      target: 5,
    ),
    BadgeDefinition(
      id: 'audio_fan',
      name: 'Audio Fan',
      icon: '🎧',
      asset: badgeAudioFan,
      requirementLabel: '3 Audio',
      description:
          'You finished 3 stories with audio. Your ears are in on the adventure too.',
      target: 3,
    ),
    BadgeDefinition(
      id: 'explorer',
      name: 'Explorer',
      icon: '🧭',
      asset: badgeExplorer,
      requirementLabel: '4 Genres',
      description:
          'You tried 4 different genres. The map keeps getting bigger.',
      target: 4,
    ),
    BadgeDefinition(
      id: 'sci_fi_reader',
      name: 'Sci-Fi Reader',
      icon: '🚀',
      asset: badgeSciFiReader,
      requirementLabel: '1 Sci-Fi',
      description:
          'You finished a sci-fi story. Space is now part of your bookshelf.',
      target: 1,
    ),
    BadgeDefinition(
      id: 'streak_king',
      name: 'Streak King',
      icon: '👑',
      asset: badgeStreakKing,
      requirementLabel: '7 Days',
      description: 'Seven days in a row. The crown fits — keep showing up.',
      target: 7,
    ),
    BadgeDefinition(
      id: 'first_light',
      name: 'First Light',
      icon: '☀️',
      asset: badgeFirstLight,
      requirementLabel: '1 Story',
      description: 'You started your first story. Every reader begins here.',
      target: 1,
    ),
    BadgeDefinition(
      id: 'fast_reader',
      name: 'Fast Reader',
      icon: '⚡',
      asset: badgeFastReader,
      requirementLabel: '3 Fast',
      description: 'You finished 3 chapters at 1.5x or faster. Zoom!',
      target: 3,
    ),
    BadgeDefinition(
      id: 'one_sitting',
      name: 'One Sitting',
      icon: '📖',
      asset: badgeOneSitting,
      requirementLabel: '1 Sitting',
      description:
          'You finished a whole story in one go. No cliffhangers left behind.',
      target: 1,
    ),
    BadgeDefinition(
      id: 'passport',
      name: 'Passport',
      icon: '🌊',
      asset: badgePassport,
      requirementLabel: '1 Ocean',
      description:
          'You finished an ocean story. Stamps collected, horizons widened.',
      target: 1,
    ),
    BadgeDefinition(
      id: 'night_reader',
      name: 'Night Reader',
      icon: '🌙',
      asset: badgeNightReader,
      requirementLabel: '5 Nights',
      description: 'Five late-night sessions. The stars saved you a seat.',
      target: 5,
    ),
  ];

  /// Legacy API ids → current catalog ids.
  static const Map<String, String> _aliases = {
    'scifi_pioneer': 'sci_fi_reader',
    'sci_fi_pioneer': 'sci_fi_reader',
    'midnight_reader': 'night_reader',
    'speed_reader': 'fast_reader',
    'star_reader': 'book_worm',
    'ocean_explorer': 'passport',
    'social_butterfly': 'explorer',
  };

  static String canonicalId(String id) {
    final normalized = id.trim().replaceAll('-', '_');
    return _aliases[normalized] ?? normalized;
  }

  static BadgeDefinition? find(String id) {
    final canonical = canonicalId(id);
    for (final badge in all) {
      if (badge.id == canonical) return badge;
    }
    return null;
  }

  static int progressFor(String id, UserModel? user, {int? currentStreak}) {
    if (user == null) return 0;
    final stats = user.stats;
    switch (canonicalId(id)) {
      case 'book_worm':
        return stats.storiesRead;
      case 'streak_king':
        return currentStreak ?? user.streakData.currentStreakDays;
      case 'dragon_tamer':
        return stats.fantasyBooksCompleted;
      case 'audio_fan':
        return stats.audioBooksCompleted;
      case 'night_owl':
        return stats.sessionsAfter8Pm > 0 ? 1 : 0;
      case 'night_reader':
        return stats.sessionsAfter8Pm;
      case 'explorer':
        return stats.genresRead.length;
      case 'fast_reader':
        return stats.chaptersAtSpeed;
      case 'passport':
        return stats.oceanBooksCompleted;
      case 'sci_fi_reader':
        return stats.scifiBooksCompleted;
      case 'first_light':
      case 'one_sitting':
        return stats.storiesRead;
      default:
        return 0;
    }
  }

  static List<BadgeProgress> buildProgress({
    required List<UserBadge> unlocked,
    UserModel? user,
    int? currentStreak,
  }) {
    final byId = <String, UserBadge>{};
    for (final badge in unlocked) {
      byId[canonicalId(badge.badgeId)] = badge;
    }
    return all
        .map((def) {
          final earned = byId[def.id];
          final current = progressFor(
            def.id,
            user,
            currentStreak: currentStreak,
          );
          final isUnlocked = earned != null || current >= def.target;
          return BadgeProgress(
            definition: def,
            current: current.clamp(0, def.target),
            unlocked: isUnlocked,
            seen: earned?.seen ?? false,
            unlockedAt: earned?.unlockedAt?.toDateTime(),
          );
        })
        .toList(growable: false);
  }
}
