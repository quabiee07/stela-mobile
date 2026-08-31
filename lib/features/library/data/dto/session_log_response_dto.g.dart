// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_log_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SessionLogResponseDto _$SessionLogResponseDtoFromJson(
  Map<String, dynamic> json,
) => SessionLogResponseDto(
  success: json['success'] as bool,
  currentStreak: (json['currentStreak'] as num?)?.toInt(),
  streakStatus: json['streakStatus'] as String?,
  newBadges: (json['newBadges'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  alreadyLogged: json['alreadyLogged'] as bool?,
  xpEarned: (json['xpEarned'] as num?)?.toInt(),
  totalXp: (json['totalXp'] as num?)?.toInt(),
  level: (json['level'] as num?)?.toInt(),
  levelProgress: (json['levelProgress'] as num?)?.toDouble(),
);

Map<String, dynamic> _$SessionLogResponseDtoToJson(
  SessionLogResponseDto instance,
) => <String, dynamic>{
  'success': instance.success,
  'currentStreak': instance.currentStreak,
  'streakStatus': instance.streakStatus,
  'newBadges': instance.newBadges,
  'alreadyLogged': instance.alreadyLogged,
  'xpEarned': instance.xpEarned,
  'totalXp': instance.totalXp,
  'level': instance.level,
  'levelProgress': instance.levelProgress,
};
