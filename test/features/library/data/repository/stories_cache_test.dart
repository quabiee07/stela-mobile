import 'package:flutter_test/flutter_test.dart';
import 'package:stela_mobile/features/library/data/repository/stories_repository_impl.dart';

void main() {
  group('StoriesRepositoryImpl.isStoriesCacheFresh', () {
    final now = DateTime(2026, 9, 17, 12);

    test('is false when nothing is cached', () {
      expect(
        StoriesRepositoryImpl.isStoriesCacheFresh(cachedAt: null, now: now),
        isFalse,
      );
    });

    test('is true inside the TTL', () {
      expect(
        StoriesRepositoryImpl.isStoriesCacheFresh(
          cachedAt: now.subtract(const Duration(seconds: 10)),
          now: now,
        ),
        isTrue,
      );
    });

    test('is false after the TTL', () {
      expect(
        StoriesRepositoryImpl.isStoriesCacheFresh(
          cachedAt: now.subtract(const Duration(seconds: 31)),
          now: now,
        ),
        isFalse,
      );
    });
  });
}
