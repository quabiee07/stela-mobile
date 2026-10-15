class ReminderBanner {
  const ReminderBanner({required this.title, this.body});

  final String title;
  final String? body;
}

/// Daily reminder lock-screen / notification-banner copy.
class ReminderBanners {
  const ReminderBanners._();

  static List<ReminderBanner> yearRound({String? firstName}) {
    final name = firstName?.trim();
    final welcome = (name == null || name.isEmpty)
        ? 'Welcome back'
        : 'Welcome back, $name';

    return [
      ReminderBanner(title: welcome, body: "I've been expecting you"),
      const ReminderBanner(
        title: 'Not to be clingy, but…',
        body: 'your book is waiting.',
      ),
      const ReminderBanner(
        title: 'Your streak is one chapter away from being proud of you.',
      ),
      const ReminderBanner(
        title: 'We could let you scroll in peace.',
        body: "But where's the character development in that?",
      ),
      const ReminderBanner(title: "Can't wait to read you to bed tonight. 🌙"),
      const ReminderBanner(
        title: 'Tonight, you and I have a date.',
        body: 'See you before bed.',
      ),
      const ReminderBanner(
        title: "IT'S TIMEEEEEE.",
        body: 'Open Stela. I have something for you.',
      ),
    ];
  }

  static const christmas = [
    ReminderBanner(
      title: "IT'S TIMEEEEEE 🎁🎄",
      body: 'Forget the presents. I found you a story.',
    ),
    ReminderBanner(
      title: 'Jingle bells, jingle bell rock 🔔🎄',
      body: 'Open Stela. I have something for you.',
    ),
  ];

  /// Dec 20 through Jan 1, inclusive.
  static bool isChristmasPeriod(DateTime date) {
    return (date.month == 12 && date.day >= 20) ||
        (date.month == 1 && date.day == 1);
  }

  static ReminderBanner forDate(DateTime date, {String? firstName}) {
    if (isChristmasPeriod(date)) {
      return christmas[date.day % christmas.length];
    }
    final pool = yearRound(firstName: firstName);
    final dayOfYear = date.difference(DateTime(date.year)).inDays;
    return pool[dayOfYear % pool.length];
  }
}
