import 'package:json_annotation/json_annotation.dart';
import 'package:stela_mobile/features/auth/domain/models/user_model.dart';
import 'package:stela_mobile/features/auth/domain/models/user_profile.dart';
import 'package:stela_mobile/features/profile/data/dto/api_timestamp_dto.dart';
import 'package:stela_mobile/features/profile/domain/models/daily_reminder_payload.dart';
import 'package:stela_mobile/features/profile/domain/models/level_progress.dart';
import 'package:stela_mobile/features/profile/domain/models/streak_info.dart';

part 'user_profile_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class UserProfileDto {
  final String uid;
  final String name;
  final String email;
  final String? avatarUrl;
  final String? age;
  final List<String>? storyPreferences;
  final String? timezone;
  final String? provider;
  final NotificationPreferencesDto? notificationPreferences;
  final DateTime? createdAt;
  @JsonKey(name: 'totalXP')
  final int? totalXp;
  final int? booksCompleted;
  final int? audioBooksCompleted;
  final int? currentStreak;
  final int? longestStreak;
  final String? streakStatus;
  final ProfileStatsDto? stats;
  final ProfileStreakDto? streak;

  const UserProfileDto({
    required this.uid,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.age,
    this.storyPreferences,
    this.timezone,
    this.provider,
    this.notificationPreferences,
    this.createdAt,
    this.totalXp,
    this.booksCompleted,
    this.audioBooksCompleted,
    this.currentStreak,
    this.longestStreak,
    this.streakStatus,
    this.stats,
    this.streak,
  });

  factory UserProfileDto.fromJson(Map<String, dynamic> json) =>
      _$UserProfileDtoFromJson(_normalize(json));

  static Map<String, dynamic> _normalize(Map<String, dynamic> json) {
    final stats = json['stats'];
    final statsXp = stats is Map
        ? stats['totalXP'] ?? stats['totalXp']
        : null;
    return {
      ...json,
      'totalXP': json['totalXP'] ?? json['totalXp'] ?? statsXp,
    };
  }

  Map<String, dynamic> toJson() => _$UserProfileDtoToJson(this);

  UserProfile toEntity({UserModel? existing}) {
    final xp = LevelProgress.preferXp(totalXp, existing?.stats.totalXp ?? 0);
    final books = LevelProgress.preferXp(
      booksCompleted ?? stats?.booksCompleted,
      existing?.stats.storiesRead ?? 0,
    );
    final audio = audioBooksCompleted ??
        stats?.audioBooksCompleted ??
        existing?.stats.audioBooksCompleted ??
        0;
    final streakCurrent =
        streak?.currentStreak ?? currentStreak ?? existing?.streakData.currentStreakDays ?? 0;
    final streakLongest = streak?.longestStreak ?? longestStreak ?? streakCurrent;
    final status = streak?.streakStatus ?? streakStatus ?? 'active';
    final lastRead = _parseDate(streak?.lastReadDate) ?? existing?.lastReadDate;
    final freezeAvailable = streak?.freezeAvailable ?? false;
    final freezeDate = _parseDate(streak?.freezeActivatedDate) ??
        existing?.streakData.lastFreezeUsedDate;

    final notification = notificationPreferences == null
        ? null
        : DailyReminderPayload(
            dailyReminderEnabled:
                notificationPreferences!.dailyReminderEnabled,
            reminderHour: notificationPreferences!.reminderHour,
          );

    final streakInfo = StreakInfo(
      currentStreak: streakCurrent,
      longestStreak: streakLongest,
      lastReadDate: streak?.lastReadDate,
      streakStatus: status,
      freezeAvailable: freezeAvailable,
      freezeUsedThisMonth: streak?.freezeUsedThisMonth ?? false,
      freezeActivatedDate: streak?.freezeActivatedDate,
      lastUpdatedAt: streak?.lastUpdatedAt?.toDto(),
    );

    final user = UserModel(
      id: uid,
      name: name,
      email: email,
      provider: provider ?? existing?.provider ?? 'password',
      avatarUrl: avatarUrl ?? existing?.avatarUrl ?? '',
      age: age ?? existing?.age ?? '',
      favoriteGenres: storyPreferences ?? existing?.favoriteGenres ?? const [],
      level: existing?.level ?? LevelProgress.levelFromXp(xp),
      title: existing?.title ?? 'New Reader',
      stats: StatsModel(
        storiesRead: books,
        readTimeHours: existing?.stats.readTimeHours ?? 0,
        totalBadges: existing?.stats.totalBadges ?? 0,
        fantasyBooksCompleted: existing?.stats.fantasyBooksCompleted ?? 0,
        audioBooksCompleted: audio,
        sessionsAfter8Pm:
            stats?.nightSessions ?? existing?.stats.sessionsAfter8Pm ?? 0,
        genresRead: stats?.genresRead ?? existing?.stats.genresRead ?? const [],
        chaptersAtSpeed:
            stats?.fastChapters ?? existing?.stats.chaptersAtSpeed ?? 0,
        oceanBooksCompleted: stats?.oceanBooksCompleted ??
            existing?.stats.oceanBooksCompleted ??
            0,
        scifiBooksCompleted: stats?.sciFiBooksCompleted ??
            existing?.stats.scifiBooksCompleted ??
            0,
        sharesCompleted: existing?.stats.sharesCompleted ?? 0,
        totalXp: xp,
      ),
      badges: existing?.badges ?? const [],
      streakData: StreakDataModel(
        currentStreakDays: streakCurrent,
        freezesAvailable: freezeAvailable ? 1 : 0,
        lastFreezeUsedDate: freezeDate,
        weeklyProgress: existing?.streakData.weeklyProgress ?? const [],
      ),
      createdAt: createdAt ?? existing?.createdAt ?? DateTime.now(),
      lastReadDate: lastRead,
    );

    return UserProfile(
      user: user,
      timezone: timezone,
      notificationPreferences: notification,
      streak: streakInfo,
      longestStreak: streakLongest,
      streakStatus: status,
    );
  }

  static DateTime? _parseDate(String? value) {
    if (value == null || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }
}

@JsonSerializable()
class NotificationPreferencesDto {
  final bool dailyReminderEnabled;
  final int reminderHour;

  const NotificationPreferencesDto({
    required this.dailyReminderEnabled,
    required this.reminderHour,
  });

  factory NotificationPreferencesDto.fromJson(Map<String, dynamic> json) =>
      _$NotificationPreferencesDtoFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationPreferencesDtoToJson(this);
}

@JsonSerializable()
class ProfileStatsDto {
  final int? oceanBooksCompleted;
  final int? sciFiBooksCompleted;
  final List<String>? genresRead;
  final int? booksCompleted;
  final int? audioBooksCompleted;
  final int? fastChapters;
  final int? nightSessions;

  const ProfileStatsDto({
    this.oceanBooksCompleted,
    this.sciFiBooksCompleted,
    this.genresRead,
    this.booksCompleted,
    this.audioBooksCompleted,
    this.fastChapters,
    this.nightSessions,
  });

  factory ProfileStatsDto.fromJson(Map<String, dynamic> json) =>
      _$ProfileStatsDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileStatsDtoToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ProfileStreakDto {
  final int? currentStreak;
  final int? longestStreak;
  final String? lastReadDate;
  final String? streakStatus;
  final bool? freezeAvailable;
  final bool? freezeUsedThisMonth;
  final String? freezeActivatedDate;
  final ApiTimestampDto? lastUpdatedAt;

  const ProfileStreakDto({
    this.currentStreak,
    this.longestStreak,
    this.lastReadDate,
    this.streakStatus,
    this.freezeAvailable,
    this.freezeUsedThisMonth,
    this.freezeActivatedDate,
    this.lastUpdatedAt,
  });

  factory ProfileStreakDto.fromJson(Map<String, dynamic> json) =>
      _$ProfileStreakDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileStreakDtoToJson(this);
}
