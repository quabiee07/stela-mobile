
class UserProfile {
  final String id;
  final String name;
  final String email;
  final String provider;
  final String avatarUrl;
  final int level;
  final String title;
  final ProfileStats stats;
  final List<BadgeModel> badges;
  final StreakData streakData;
  final DateTime createdAt;
  final DateTime? lastReadDate;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.provider,
    required this.avatarUrl,
    required this.level,
    required this.title,
    required this.stats,
    required this.badges,
    required this.streakData,
    required this.createdAt,
    this.lastReadDate,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      provider: json['provider'] ?? '',
      avatarUrl: json['avatarUrl'] ?? '',
      level: json['level'] ?? 1,
      title: json['title'] ?? '',
      stats: ProfileStats.fromJson(json['stats'] ?? {}),
      badges:
          (json['badges'] as List<dynamic>?)
              ?.map((e) => BadgeModel.fromJson(e))
              .toList() ??
          [],
      streakData: StreakData.fromJson(json['streakData'] ?? {}),
      createdAt: DateTime.parse(json['createdAt']),
      lastReadDate: json['lastReadDate'] != null ? DateTime.parse(json['lastReadDate']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'provider': provider,
      'avatarUrl': avatarUrl,
      'level': level,
      'title': title,
      'stats': stats.toJson(),
      'badges': badges.map((e) => e.toJson()).toList(),
      'streakData': streakData.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'lastReadDate': lastReadDate?.toIso8601String(),
    };
  }
}

class ProfileStats {
  final int storiesRead;
  final double readTimeHours;
  final int totalBadges;
  final int fantasyBooksCompleted;
  final int audioBooksCompleted;
  final int sessionsAfter8pm;
  final List<String> genresRead;
  final int chaptersAtSpeed;
  final int oceanBooksCompleted;
  final int scifiBooksCompleted;
  final int sharesCompleted;
  final int totalXp;

  ProfileStats({
    required this.storiesRead,
    required this.readTimeHours,
    required this.totalBadges,
    this.fantasyBooksCompleted = 0,
    this.audioBooksCompleted = 0,
    this.sessionsAfter8pm = 0,
    this.genresRead = const [],
    this.chaptersAtSpeed = 0,
    this.oceanBooksCompleted = 0,
    this.scifiBooksCompleted = 0,
    this.sharesCompleted = 0,
    this.totalXp = 0,
  });

  factory ProfileStats.fromJson(Map<String, dynamic> json) {
    return ProfileStats(
      storiesRead: json['storiesRead'] ?? 0,
      readTimeHours: (json['readTimeHours'] ?? 0).toDouble(),
      totalBadges: json['totalBadges'] ?? 0,
      fantasyBooksCompleted: json['fantasyBooksCompleted'] ?? 0,
      audioBooksCompleted: json['audioBooksCompleted'] ?? 0,
      sessionsAfter8pm: json['sessionsAfter8pm'] ?? 0,
      genresRead: List<String>.from(json['genresRead'] ?? []),
      chaptersAtSpeed: json['chaptersAtSpeed'] ?? 0,
      oceanBooksCompleted: json['oceanBooksCompleted'] ?? 0,
      scifiBooksCompleted: json['scifiBooksCompleted'] ?? 0,
      sharesCompleted: json['sharesCompleted'] ?? 0,
      totalXp: json['totalXp'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'storiesRead': storiesRead,
      'readTimeHours': readTimeHours,
      'totalBadges': totalBadges,
      'fantasyBooksCompleted': fantasyBooksCompleted,
      'audioBooksCompleted': audioBooksCompleted,
      'sessionsAfter8pm': sessionsAfter8pm,
      'genresRead': genresRead,
      'chaptersAtSpeed': chaptersAtSpeed,
      'oceanBooksCompleted': oceanBooksCompleted,
      'scifiBooksCompleted': scifiBooksCompleted,
      'sharesCompleted': sharesCompleted,
      'totalXp': totalXp,
    };
  }
}

class BadgeModel {
  final String id;
  final String name;
  final String iconAsset;

  BadgeModel({required this.id, required this.name, required this.iconAsset});

  factory BadgeModel.fromJson(Map<String, dynamic> json) {
    return BadgeModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      iconAsset: json['iconAsset'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'iconAsset': iconAsset};
  }
}

class StreakData {
  final int currentStreakDays;
  final int freezesAvailable;
  final DateTime? lastFreezeUsedDate;
  final List<WeeklyProgress> weeklyProgress;

  StreakData({
    required this.currentStreakDays,
    this.freezesAvailable = 1,
    this.lastFreezeUsedDate,
    required this.weeklyProgress,
  });

  factory StreakData.fromJson(Map<String, dynamic> json) {
    return StreakData(
      currentStreakDays: json['currentStreakDays'] ?? 0,
      freezesAvailable: json['freezesAvailable'] ?? 1,
      lastFreezeUsedDate: json['lastFreezeUsedDate'] != null ? DateTime.parse(json['lastFreezeUsedDate']) : null,
      weeklyProgress:
          (json['weeklyProgress'] as List<dynamic>?)
              ?.map((e) => WeeklyProgress.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentStreakDays': currentStreakDays,
      'freezesAvailable': freezesAvailable,
      'lastFreezeUsedDate': lastFreezeUsedDate?.toIso8601String(),
      'weeklyProgress': weeklyProgress.map((e) => e.toJson()).toList(),
    };
  }
}

class WeeklyProgress {
  final String weekLabel;
  final int value;

  WeeklyProgress({required this.weekLabel, required this.value});

  factory WeeklyProgress.fromJson(Map<String, dynamic> json) {
    return WeeklyProgress(
      weekLabel: json['weekLabel'] ?? '',
      value: json['value'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'weekLabel': weekLabel, 'value': value};
  }
}
