import 'package:json_annotation/json_annotation.dart';
import 'dart:convert';

import 'package:stela_mobile/features/auth/domain/models/user_model.dart';

part 'user_model_dto.g.dart';

UserModelDto userModelDtoFromJson(String str) =>
    UserModelDto.fromJson(json.decode(str));

String userModelDtoToJson(UserModelDto data) => json.encode(data.toJson());

@JsonSerializable(explicitToJson: true)
class UserModelDto {
  @JsonKey(name: "id")
  String id;
  @JsonKey(name: "name")
  String name;
  @JsonKey(name: "email")
  String email;
  @JsonKey(name: "provider")
  String provider;
  @JsonKey(name: "avatarUrl")
  String avatarUrl;
  @JsonKey(name: "age")
  String age;
  @JsonKey(name: "favoriteGenres")
  List<String> favoriteGenres;
  @JsonKey(name: "level")
  int level;
  @JsonKey(name: "title")
  String title;
  @JsonKey(name: "stats")
  StatsDto stats;
  @JsonKey(name: "badges")
  List<BadgeDto> badges;
  @JsonKey(name: "streakData")
  StreakDataDto streakData;
  @JsonKey(name: "createdAt")
  DateTime createdAt;
  @JsonKey(name: "lastReadDate")
  DateTime? lastReadDate;

  UserModelDto({
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

  factory UserModelDto.fromJson(Map<String, dynamic> json) =>
      _$UserModelDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelDtoToJson(this);

  static UserModelDto fromEntity(UserModel entity) {
    return UserModelDto(
      id: entity.id,
      name: entity.name,
      email: entity.email,
      provider: entity.provider,
      avatarUrl: entity.avatarUrl,
      age: entity.age,
      favoriteGenres: entity.favoriteGenres,
      level: entity.level,
      title: entity.title,
      stats: StatsDto.fromEntity(entity.stats),
      badges: entity.badges.map((e) => BadgeDto.fromEntity(e)).toList(),
      streakData: StreakDataDto.fromEntity(entity.streakData),
      createdAt: entity.createdAt,
      lastReadDate: entity.lastReadDate,
    );
  }

  UserModel toEntity() {
    return UserModel(
      id: id,
      name: name,
      email: email,
      provider: provider,
      avatarUrl: avatarUrl,
      age: age,
      favoriteGenres: favoriteGenres,
      level: level,
      title: title,
      stats: stats.toEntity(),
      badges: badges.map((e) => e.toEntity()).toList(),
      streakData: streakData.toEntity(),
      createdAt: createdAt,
      lastReadDate: lastReadDate,
    );
  }
}


@JsonSerializable()
class BadgeDto {
  @JsonKey(name: "id")
  String id;
  @JsonKey(name: "name")
  String name;
  @JsonKey(name: "iconAsset")
  String iconAsset;

  BadgeDto({required this.id, required this.name, required this.iconAsset});

  factory BadgeDto.fromJson(Map<String, dynamic> json) =>
      _$BadgeDtoFromJson(json);

  Map<String, dynamic> toJson() => _$BadgeDtoToJson(this);

  static BadgeDto fromEntity(BadgeModel entity) {
    return BadgeDto(
      id: entity.id,
      name: entity.name,
      iconAsset: entity.iconAsset,
    );
  }

  BadgeModel toEntity() {
    return BadgeModel(id: id, name: name, iconAsset: iconAsset);
  }
}

@JsonSerializable(explicitToJson: true)
class StatsDto {
  @JsonKey(name: "storiesRead")
  int storiesRead;
  @JsonKey(name: "readTimeHours")
  double readTimeHours;
  @JsonKey(name: "totalBadges")
  int totalBadges;
  @JsonKey(name: "fantasyBooksCompleted")
  int fantasyBooksCompleted;
  @JsonKey(name: "audioBooksCompleted")
  int audioBooksCompleted;
  @JsonKey(name: "sessionsAfter8pm")
  int sessionsAfter8Pm;
  @JsonKey(name: "genresRead")
  List<String> genresRead;
  @JsonKey(name: "chaptersAtSpeed")
  int chaptersAtSpeed;
  @JsonKey(name: "oceanBooksCompleted")
  int oceanBooksCompleted;
  @JsonKey(name: "scifiBooksCompleted")
  int scifiBooksCompleted;
  @JsonKey(name: "sharesCompleted")
  int sharesCompleted;
  @JsonKey(name: "totalXp")
  int totalXp;

  StatsDto({
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

  factory StatsDto.fromJson(Map<String, dynamic> json) =>
      _$StatsDtoFromJson(json);

  Map<String, dynamic> toJson() => _$StatsDtoToJson(this);

  static StatsDto fromEntity(StatsModel entity) {
    return StatsDto(
      storiesRead: entity.storiesRead,
      readTimeHours: entity.readTimeHours,
      totalBadges: entity.totalBadges,
      fantasyBooksCompleted: entity.fantasyBooksCompleted,
      audioBooksCompleted: entity.audioBooksCompleted,
      sessionsAfter8Pm: entity.sessionsAfter8Pm,
      genresRead: entity.genresRead,
      chaptersAtSpeed: entity.chaptersAtSpeed,
      oceanBooksCompleted: entity.oceanBooksCompleted,
      scifiBooksCompleted: entity.scifiBooksCompleted,
      sharesCompleted: entity.sharesCompleted,
      totalXp: entity.totalXp,
    );
  }

  StatsModel toEntity() {
    return StatsModel(
      storiesRead: storiesRead,
      readTimeHours: readTimeHours,
      totalBadges: totalBadges,
      fantasyBooksCompleted: fantasyBooksCompleted,
      audioBooksCompleted: audioBooksCompleted,
      sessionsAfter8Pm: sessionsAfter8Pm,
      genresRead: genresRead,
      chaptersAtSpeed: chaptersAtSpeed,
      oceanBooksCompleted: oceanBooksCompleted,
      scifiBooksCompleted: scifiBooksCompleted,
      sharesCompleted: sharesCompleted,
      totalXp: totalXp,
    );
  }
}

@JsonSerializable(explicitToJson: true)
class StreakDataDto {
  @JsonKey(name: "currentStreakDays")
  int currentStreakDays;
  @JsonKey(name: "freezesAvailable")
  int freezesAvailable;
  @JsonKey(name: "lastFreezeUsedDate")
  DateTime? lastFreezeUsedDate;
  @JsonKey(name: "weeklyProgress")
  List<WeeklyProgressDto> weeklyProgress;

  StreakDataDto({
    required this.currentStreakDays,
    required this.freezesAvailable,
    required this.lastFreezeUsedDate,
    required this.weeklyProgress,
  });

  static StreakDataDto fromEntity(StreakDataModel entity) {
    return StreakDataDto(
      currentStreakDays: entity.currentStreakDays,
      freezesAvailable: entity.freezesAvailable,
      lastFreezeUsedDate: entity.lastFreezeUsedDate,
      weeklyProgress: entity.weeklyProgress.map((e) => WeeklyProgressDto.fromEntity(e)).toList(),
    );
  }

  StreakDataModel toEntity() {
    return StreakDataModel(
      currentStreakDays: currentStreakDays,
      freezesAvailable: freezesAvailable,
      lastFreezeUsedDate: lastFreezeUsedDate,
      weeklyProgress: weeklyProgress.map((e) => e.toEntity()).toList(),
    );
  }

  factory StreakDataDto.fromJson(Map<String, dynamic> json) =>
      _$StreakDataDtoFromJson(json);

  Map<String, dynamic> toJson() => _$StreakDataDtoToJson(this);
}

@JsonSerializable()
class WeeklyProgressDto {
  @JsonKey(name: "weekLabel")
  String weekLabel;
  @JsonKey(name: "value")
  int value;

  WeeklyProgressDto({required this.weekLabel, required this.value});

  static WeeklyProgressDto fromEntity(WeeklyProgressModel entity) {
    return WeeklyProgressDto(
      weekLabel: entity.weekLabel,
      value: entity.value,
    );
  }

  WeeklyProgressModel toEntity() {
    return WeeklyProgressModel(weekLabel: weekLabel, value: value);
  }

  factory WeeklyProgressDto.fromJson(Map<String, dynamic> json) =>
      _$WeeklyProgressDtoFromJson(json);

  Map<String, dynamic> toJson() => _$WeeklyProgressDtoToJson(this);
}
