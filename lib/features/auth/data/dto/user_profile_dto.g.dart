// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserProfileDto _$UserProfileDtoFromJson(Map<String, dynamic> json) =>
    UserProfileDto(
      uid: json['uid'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      age: json['age'] as String?,
      storyPreferences: (json['storyPreferences'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      timezone: json['timezone'] as String?,
      provider: json['provider'] as String?,
      notificationPreferences: json['notificationPreferences'] == null
          ? null
          : NotificationPreferencesDto.fromJson(
              json['notificationPreferences'] as Map<String, dynamic>,
            ),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      totalXp: (json['totalXP'] as num?)?.toInt(),
      booksCompleted: (json['booksCompleted'] as num?)?.toInt(),
      audioBooksCompleted: (json['audioBooksCompleted'] as num?)?.toInt(),
      currentStreak: (json['currentStreak'] as num?)?.toInt(),
      longestStreak: (json['longestStreak'] as num?)?.toInt(),
      streakStatus: json['streakStatus'] as String?,
      stats: json['stats'] == null
          ? null
          : ProfileStatsDto.fromJson(json['stats'] as Map<String, dynamic>),
      streak: json['streak'] == null
          ? null
          : ProfileStreakDto.fromJson(json['streak'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UserProfileDtoToJson(UserProfileDto instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'name': instance.name,
      'email': instance.email,
      'avatarUrl': instance.avatarUrl,
      'age': instance.age,
      'storyPreferences': instance.storyPreferences,
      'timezone': instance.timezone,
      'provider': instance.provider,
      'notificationPreferences': instance.notificationPreferences?.toJson(),
      'createdAt': instance.createdAt?.toIso8601String(),
      'totalXP': instance.totalXp,
      'booksCompleted': instance.booksCompleted,
      'audioBooksCompleted': instance.audioBooksCompleted,
      'currentStreak': instance.currentStreak,
      'longestStreak': instance.longestStreak,
      'streakStatus': instance.streakStatus,
      'stats': instance.stats?.toJson(),
      'streak': instance.streak?.toJson(),
    };

NotificationPreferencesDto _$NotificationPreferencesDtoFromJson(
  Map<String, dynamic> json,
) => NotificationPreferencesDto(
  dailyReminderEnabled: json['dailyReminderEnabled'] as bool,
  reminderHour: (json['reminderHour'] as num).toInt(),
);

Map<String, dynamic> _$NotificationPreferencesDtoToJson(
  NotificationPreferencesDto instance,
) => <String, dynamic>{
  'dailyReminderEnabled': instance.dailyReminderEnabled,
  'reminderHour': instance.reminderHour,
};

ProfileStatsDto _$ProfileStatsDtoFromJson(Map<String, dynamic> json) =>
    ProfileStatsDto(
      oceanBooksCompleted: (json['oceanBooksCompleted'] as num?)?.toInt(),
      sciFiBooksCompleted: (json['sciFiBooksCompleted'] as num?)?.toInt(),
      genresRead: (json['genresRead'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      booksCompleted: (json['booksCompleted'] as num?)?.toInt(),
      audioBooksCompleted: (json['audioBooksCompleted'] as num?)?.toInt(),
      fastChapters: (json['fastChapters'] as num?)?.toInt(),
      nightSessions: (json['nightSessions'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ProfileStatsDtoToJson(ProfileStatsDto instance) =>
    <String, dynamic>{
      'oceanBooksCompleted': instance.oceanBooksCompleted,
      'sciFiBooksCompleted': instance.sciFiBooksCompleted,
      'genresRead': instance.genresRead,
      'booksCompleted': instance.booksCompleted,
      'audioBooksCompleted': instance.audioBooksCompleted,
      'fastChapters': instance.fastChapters,
      'nightSessions': instance.nightSessions,
    };

ProfileStreakDto _$ProfileStreakDtoFromJson(Map<String, dynamic> json) =>
    ProfileStreakDto(
      currentStreak: (json['currentStreak'] as num?)?.toInt(),
      longestStreak: (json['longestStreak'] as num?)?.toInt(),
      lastReadDate: json['lastReadDate'] as String?,
      streakStatus: json['streakStatus'] as String?,
      freezeAvailable: json['freezeAvailable'] as bool?,
      freezeUsedThisMonth: json['freezeUsedThisMonth'] as bool?,
      freezeActivatedDate: json['freezeActivatedDate'] as String?,
      lastUpdatedAt: json['lastUpdatedAt'] == null
          ? null
          : ApiTimestampDto.fromJson(
              json['lastUpdatedAt'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$ProfileStreakDtoToJson(ProfileStreakDto instance) =>
    <String, dynamic>{
      'currentStreak': instance.currentStreak,
      'longestStreak': instance.longestStreak,
      'lastReadDate': instance.lastReadDate,
      'streakStatus': instance.streakStatus,
      'freezeAvailable': instance.freezeAvailable,
      'freezeUsedThisMonth': instance.freezeUsedThisMonth,
      'freezeActivatedDate': instance.freezeActivatedDate,
      'lastUpdatedAt': instance.lastUpdatedAt?.toJson(),
    };
