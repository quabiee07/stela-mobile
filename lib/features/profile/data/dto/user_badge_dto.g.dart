// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_badge_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserBadgeDto _$UserBadgeDtoFromJson(Map<String, dynamic> json) => UserBadgeDto(
  badgeId: json['badgeId'] as String,
  unlockedAt: json['unlockedAt'] == null
      ? null
      : ApiTimestampDto.fromJson(json['unlockedAt'] as Map<String, dynamic>),
  seen: json['seen'] as bool,
);

Map<String, dynamic> _$UserBadgeDtoToJson(UserBadgeDto instance) =>
    <String, dynamic>{
      'badgeId': instance.badgeId,
      'unlockedAt': instance.unlockedAt?.toJson(),
      'seen': instance.seen,
    };
