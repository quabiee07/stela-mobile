import 'package:stela_mobile/features/auth/domain/models/user_model.dart';
import 'package:stela_mobile/features/profile/domain/models/user_badge.dart';

class BadgeDefinition {
  const BadgeDefinition({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
    required this.target,
  });

  final String id;
  final String name;
  final String icon;
  final String description;

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
      id: 'book_worm',
      name: 'Book Worm',
      icon: '📚',
      description: 'Read 3 days in a row',
      target: 3,
    ),
    BadgeDefinition(
      id: 'streak_king',
      name: 'Streak King',
      icon: '👑',
      description: 'Keep a 7-day streak',
      target: 7,
    ),
    BadgeDefinition(
      id: 'star_reader',
      name: 'Star Reader',
      icon: '⭐',
      description: 'Finish 5 stories',
      target: 5,
    ),
    BadgeDefinition(
      id: 'dragon_tamer',
      name: 'Dragon Tamer',
      icon: '🐉',
      description: 'Finish a fantasy story',
      target: 1,
    ),
    BadgeDefinition(
      id: 'audio_fan',
      name: 'Audio Fan',
      icon: '🎧',
      description: 'Finish 3 stories with audio',
      target: 3,
    ),
    BadgeDefinition(
      id: 'night_owl',
      name: 'Night Owl',
      icon: '🦉',
      description: 'Read after 8pm',
      target: 1,
    ),
    BadgeDefinition(
      id: 'midnight_reader',
      name: 'Midnight Reader',
      icon: '🌙',
      description: 'Read after 8pm five times',
      target: 5,
    ),
    BadgeDefinition(
      id: 'explorer',
      name: 'Explorer',
      icon: '🧭',
      description: 'Try 4 different genres',
      target: 4,
    ),
    BadgeDefinition(
      id: 'speed_reader',
      name: 'Speed Reader',
      icon: '⚡',
      description: 'Finish 3 chapters at 1.5x+',
      target: 3,
    ),
    BadgeDefinition(
      id: 'ocean_explorer',
      name: 'Ocean Explorer',
      icon: '🌊',
      description: 'Finish an ocean story',
      target: 1,
    ),
    BadgeDefinition(
      id: 'scifi_pioneer',
      name: 'Sci-Fi Pioneer',
      icon: '🚀',
      description: 'Finish a sci-fi story',
      target: 1,
    ),
    BadgeDefinition(
      id: 'social_butterfly',
      name: 'Social Butterfly',
      icon: '🦋',
      description: 'Share your progress 3 times',
      target: 3,
    ),
  ];

  static BadgeDefinition? find(String id) {
    for (final badge in all) {
      if (badge.id == id) return badge;
    }
    return null;
  }

  static int progressFor(String id, UserModel? user, {int? currentStreak}) {
    if (user == null) return 0;
    final stats = user.stats;
    switch (id) {
      case 'book_worm':
        return currentStreak ?? user.streakData.currentStreakDays;
      case 'streak_king':
        return currentStreak ?? user.streakData.currentStreakDays;
      case 'star_reader':
        return stats.storiesRead;
      case 'dragon_tamer':
        return stats.fantasyBooksCompleted;
      case 'audio_fan':
        return stats.audioBooksCompleted;
      case 'night_owl':
      case 'midnight_reader':
        return stats.sessionsAfter8Pm;
      case 'explorer':
        return stats.genresRead.length;
      case 'speed_reader':
        return stats.chaptersAtSpeed;
      case 'ocean_explorer':
        return stats.oceanBooksCompleted;
      case 'scifi_pioneer':
        return stats.scifiBooksCompleted;
      case 'social_butterfly':
        return stats.sharesCompleted;
      default:
        return 0;
    }
  }

  static List<BadgeProgress> buildProgress({
    required List<UserBadge> unlocked,
    UserModel? user,
    int? currentStreak,
  }) {
    final byId = {for (final b in unlocked) b.badgeId: b};
    return all.map((def) {
      final earned = byId[def.id];
      final current = progressFor(def.id, user, currentStreak: currentStreak);
      final isUnlocked = earned != null || current >= def.target;
      return BadgeProgress(
        definition: def,
        current: current.clamp(0, def.target),
        unlocked: isUnlocked,
        seen: earned?.seen ?? false,
        unlockedAt: earned?.unlockedAt?.toDateTime(),
      );
    }).toList(growable: false);
  }
}
