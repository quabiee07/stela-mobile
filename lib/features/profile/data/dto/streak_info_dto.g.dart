// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'streak_info_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StreakInfoDto _$StreakInfoDtoFromJson(Map<String, dynamic> json) =>
    StreakInfoDto(
      currentStreak: (json['currentStreak'] as num).toInt(),
      longestStreak: (json['longestStreak'] as num).toInt(),
      lastReadDate: json['lastReadDate'] as String?,
      streakStatus: json['streakStatus'] as String,
      freezeAvailable: json['freezeAvailable'] as bool,
      freezeUsedThisMonth: json['freezeUsedThisMonth'] as bool,
      freezeActivatedDate: json['freezeActivatedDate'] as String?,
      lastUpdatedAt: json['lastUpdatedAt'] == null
          ? null
          : ApiTimestampDto.fromJson(
              json['lastUpdatedAt'] as Map<String, dynamic>,
            ),
      weeklySessionCounts: (json['weeklySessionCounts'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
    );

Map<String, dynamic> _$StreakInfoDtoToJson(StreakInfoDto instance) =>
    <String, dynamic>{
      'currentStreak': instance.currentStreak,
      'longestStreak': instance.longestStreak,
      'lastReadDate': instance.lastReadDate,
      'streakStatus': instance.streakStatus,
      'freezeAvailable': instance.freezeAvailable,
      'freezeUsedThisMonth': instance.freezeUsedThisMonth,
      'freezeActivatedDate': instance.freezeActivatedDate,
      'lastUpdatedAt': instance.lastUpdatedAt?.toJson(),
      'weeklySessionCounts': instance.weeklySessionCounts,
    };

StreakFreezeResultDto _$StreakFreezeResultDtoFromJson(
  Map<String, dynamic> json,
) => StreakFreezeResultDto(
  success: json['success'] as bool,
  currentStreak: (json['currentStreak'] as num).toInt(),
);

Map<String, dynamic> _$StreakFreezeResultDtoToJson(
  StreakFreezeResultDto instance,
) => <String, dynamic>{
  'success': instance.success,
  'currentStreak': instance.currentStreak,
};
