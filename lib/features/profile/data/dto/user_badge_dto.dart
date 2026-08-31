import 'package:json_annotation/json_annotation.dart';
import 'package:stela_mobile/features/profile/data/dto/api_timestamp_dto.dart';
import 'package:stela_mobile/features/profile/domain/models/user_badge.dart';

part 'user_badge_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class UserBadgeDto {
  final String badgeId;
  final ApiTimestampDto? unlockedAt;
  final bool seen;

  const UserBadgeDto({
    required this.badgeId,
    required this.unlockedAt,
    required this.seen,
  });

  UserBadge toDto() {
    return UserBadge(
      badgeId: badgeId,
      unlockedAt: unlockedAt?.toDto(),
      seen: seen,
    );
  }

  factory UserBadgeDto.fromJson(Map<String, dynamic> json) =>
      _$UserBadgeDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UserBadgeDtoToJson(this);
}
