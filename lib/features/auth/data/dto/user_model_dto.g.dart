// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModelDto _$UserModelDtoFromJson(Map<String, dynamic> json) => UserModelDto(
  id: json['id'] as String,
  name: json['name'] as String,
  email: json['email'] as String,
  provider: json['provider'] as String,
  avatarUrl: json['avatarUrl'] as String,
  age: json['age'] as String,
  favoriteGenres: (json['favoriteGenres'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  level: (json['level'] as num).toInt(),
  title: json['title'] as String,
  stats: StatsDto.fromJson(json['stats'] as Map<String, dynamic>),
  badges: (json['badges'] as List<dynamic>)
      .map((e) => BadgeDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  streakData: StreakDataDto.fromJson(
    json['streakData'] as Map<String, dynamic>,
  ),
  createdAt: DateTime.parse(json['createdAt'] as String),
  lastReadDate: json['lastReadDate'] == null
      ? null
      : DateTime.parse(json['lastReadDate'] as String),
);

Map<String, dynamic> _$UserModelDtoToJson(UserModelDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'provider': instance.provider,
      'avatarUrl': instance.avatarUrl,
      'age': instance.age,
      'favoriteGenres': instance.favoriteGenres,
      'level': instance.level,
      'title': instance.title,
      'stats': instance.stats.toJson(),
      'badges': instance.badges.map((e) => e.toJson()).toList(),
      'streakData': instance.streakData.toJson(),
      'createdAt': instance.createdAt.toIso8601String(),
      'lastReadDate': instance.lastReadDate?.toIso8601String(),
    };

BadgeDto _$BadgeDtoFromJson(Map<String, dynamic> json) => BadgeDto(
  id: json['id'] as String,
  name: json['name'] as String,
  iconAsset: json['iconAsset'] as String,
);

Map<String, dynamic> _$BadgeDtoToJson(BadgeDto instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'iconAsset': instance.iconAsset,
};

StatsDto _$StatsDtoFromJson(Map<String, dynamic> json) => StatsDto(
  storiesRead: (json['storiesRead'] as num).toInt(),
  readTimeHours: (json['readTimeHours'] as num).toDouble(),
  totalBadges: (json['totalBadges'] as num).toInt(),
  fantasyBooksCompleted: (json['fantasyBooksCompleted'] as num).toInt(),
  audioBooksCompleted: (json['audioBooksCompleted'] as num).toInt(),
  sessionsAfter8Pm: (json['sessionsAfter8pm'] as num).toInt(),
  genresRead: (json['genresRead'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  chaptersAtSpeed: (json['chaptersAtSpeed'] as num).toInt(),
  oceanBooksCompleted: (json['oceanBooksCompleted'] as num).toInt(),
  scifiBooksCompleted: (json['scifiBooksCompleted'] as num).toInt(),
  sharesCompleted: (json['sharesCompleted'] as num).toInt(),
  totalXp: (json['totalXp'] as num).toInt(),
);

Map<String, dynamic> _$StatsDtoToJson(StatsDto instance) => <String, dynamic>{
  'storiesRead': instance.storiesRead,
  'readTimeHours': instance.readTimeHours,
  'totalBadges': instance.totalBadges,
  'fantasyBooksCompleted': instance.fantasyBooksCompleted,
  'audioBooksCompleted': instance.audioBooksCompleted,
  'sessionsAfter8pm': instance.sessionsAfter8Pm,
  'genresRead': instance.genresRead,
  'chaptersAtSpeed': instance.chaptersAtSpeed,
  'oceanBooksCompleted': instance.oceanBooksCompleted,
  'scifiBooksCompleted': instance.scifiBooksCompleted,
  'sharesCompleted': instance.sharesCompleted,
  'totalXp': instance.totalXp,
};

StreakDataDto _$StreakDataDtoFromJson(Map<String, dynamic> json) =>
    StreakDataDto(
      currentStreakDays: (json['currentStreakDays'] as num).toInt(),
      freezesAvailable: (json['freezesAvailable'] as num).toInt(),
      lastFreezeUsedDate: json['lastFreezeUsedDate'] == null
          ? null
          : DateTime.parse(json['lastFreezeUsedDate'] as String),
      weeklyProgress: (json['weeklyProgress'] as List<dynamic>)
          .map((e) => WeeklyProgressDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$StreakDataDtoToJson(StreakDataDto instance) =>
    <String, dynamic>{
      'currentStreakDays': instance.currentStreakDays,
      'freezesAvailable': instance.freezesAvailable,
      'lastFreezeUsedDate': instance.lastFreezeUsedDate?.toIso8601String(),
      'weeklyProgress': instance.weeklyProgress.map((e) => e.toJson()).toList(),
    };

WeeklyProgressDto _$WeeklyProgressDtoFromJson(Map<String, dynamic> json) =>
    WeeklyProgressDto(
      weekLabel: json['weekLabel'] as String,
      value: (json['value'] as num).toInt(),
    );

Map<String, dynamic> _$WeeklyProgressDtoToJson(WeeklyProgressDto instance) =>
    <String, dynamic>{'weekLabel': instance.weekLabel, 'value': instance.value};
