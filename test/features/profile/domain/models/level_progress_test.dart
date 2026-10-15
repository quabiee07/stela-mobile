import 'package:flutter_test/flutter_test.dart';
import 'package:stela_mobile/features/profile/domain/models/level_progress.dart';

void main() {
  group('LevelProgress.preferXp', () {
    test('keeps the higher local total when remote is stale or zero', () {
      expect(LevelProgress.preferXp(0, 45), 45);
      expect(LevelProgress.preferXp(null, 45), 45);
    });

    test('accepts a higher remote total after share or sync', () {
      expect(LevelProgress.preferXp(80, 45), 80);
    });

    test('returns zero when both sides are empty', () {
      expect(LevelProgress.preferXp(null, 0), 0);
    });
  });

  group('LevelProgress.levelFromXp', () {
    test('uses 100 XP per level and caps at 100', () {
      expect(LevelProgress.levelFromXp(0), 1);
      expect(LevelProgress.levelFromXp(99), 1);
      expect(LevelProgress.levelFromXp(100), 2);
      expect(LevelProgress.levelFromXp(9900), 100);
      expect(LevelProgress.levelFromXp(20000), 100);
    });
  });

  group('LevelProgress.titleForLevel', () {
    test('maps the branded decade titles', () {
      expect(LevelProgress.titleForLevel(1), 'Hatchling I');
      expect(LevelProgress.titleForLevel(10), 'Hatchling X');
      expect(LevelProgress.titleForLevel(11), 'Page Turner I');
      expect(LevelProgress.titleForLevel(47), 'Voice Seeker VII');
      expect(LevelProgress.titleForLevel(73), 'Lore Keeper III');
      expect(LevelProgress.titleForLevel(88), 'Star Reader VIII');
      expect(LevelProgress.titleForLevel(99), 'Legend IX');
      expect(LevelProgress.titleForLevel(100), 'Stelar');
    });
  });
}
