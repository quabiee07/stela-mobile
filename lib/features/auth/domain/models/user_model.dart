class UserModel {
    String id;
    String name;
    String email;
    String provider;
    String avatarUrl;
    String age;
    List<String> favoriteGenres;
    int level;
    String title;
    StatsModel stats;
    List<BadgeModel> badges;
    StreakDataModel streakData;
    DateTime createdAt;
    DateTime? lastReadDate;

    UserModel({
        required this.id,
        required this.name,
        required this.email,
        required this.provider,
        required this.avatarUrl,
        required this.age,
        required this.favoriteGenres,
        required this.level,
        required this.title,
        required this.stats,
        required this.badges,
        required this.streakData,
        required this.createdAt,
        required this.lastReadDate,
    });

}

class BadgeModel {
    String id;
    String name;
    String iconAsset;

    BadgeModel({
        required this.id,
        required this.name,
        required this.iconAsset,
    });

}

class StatsModel {
    int storiesRead;
    double readTimeHours;
    int totalBadges;
    int fantasyBooksCompleted;
    int audioBooksCompleted;
    int sessionsAfter8Pm;
    List<String> genresRead;
    int chaptersAtSpeed;
    int oceanBooksCompleted;
    int scifiBooksCompleted;
    int sharesCompleted;
    int totalXp;

    StatsModel({
        required this.storiesRead,
        required this.readTimeHours,
        required this.totalBadges,
        required this.fantasyBooksCompleted,
        required this.audioBooksCompleted,
        required this.sessionsAfter8Pm,
        required this.genresRead,
        required this.chaptersAtSpeed,
        required this.oceanBooksCompleted,
        required this.scifiBooksCompleted,
        required this.sharesCompleted,
        required this.totalXp,
    });

}

class StreakDataModel {
    int currentStreakDays;
    int freezesAvailable;
    DateTime? lastFreezeUsedDate;
    List<WeeklyProgressModel> weeklyProgress;

    StreakDataModel({
        required this.currentStreakDays,
        required this.freezesAvailable,
        required this.lastFreezeUsedDate,
        required this.weeklyProgress,
    });

}

class WeeklyProgressModel {
    String weekLabel;
    int value;

    WeeklyProgressModel({
        required this.weekLabel,
        required this.value,
    });

}
