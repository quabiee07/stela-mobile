import 'package:flutter_test/flutter_test.dart';
import 'package:stela_mobile/core/data/services/reminder_banners.dart';

void main() {
  group('ReminderBanners', () {
    test('personalizes the welcome banner', () {
      final banner = ReminderBanners.yearRound(firstName: 'Maya').first;
      expect(banner.title, 'Welcome back, Maya');
      expect(banner.body, "I've been expecting you");
    });

    test('falls back when the name is missing', () {
      final banner = ReminderBanners.yearRound(firstName: '  ').first;
      expect(banner.title, 'Welcome back');
    });

    test('uses Christmas copy from Dec 20 through New Year’s Day', () {
      expect(ReminderBanners.isChristmasPeriod(DateTime(2026, 12, 20)), isTrue);
      expect(ReminderBanners.isChristmasPeriod(DateTime(2027, 1, 1)), isTrue);
      expect(
        ReminderBanners.isChristmasPeriod(DateTime(2026, 12, 19)),
        isFalse,
      );

      final banner = ReminderBanners.forDate(DateTime(2026, 12, 25));
      expect(
        ReminderBanners.christmas.map((item) => item.title),
        contains(banner.title),
      );
    });

    test('rotates year-round copy by day of year', () {
      final first = ReminderBanners.forDate(DateTime(2026, 6, 1));
      final next = ReminderBanners.forDate(DateTime(2026, 6, 2));
      expect(first.title, isNot(next.title));
    });
  });
}
