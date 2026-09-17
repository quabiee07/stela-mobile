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
}
