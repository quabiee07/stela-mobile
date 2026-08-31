import 'package:json_annotation/json_annotation.dart';
import 'package:stela_mobile/features/library/domain/models/session_log_result.dart';

part 'session_log_response_dto.g.dart';

@JsonSerializable()
class SessionLogResponseDto {
  final bool success;
  final int? currentStreak;
  final String? streakStatus;
  final List<String>? newBadges;
  final bool? alreadyLogged;
  final int? xpEarned;
  final int? totalXp;
  final int? level;
  final double? levelProgress;

  SessionLogResponseDto({
    required this.success,
    this.currentStreak,
    this.streakStatus,
    this.newBadges,
    this.alreadyLogged,
    this.xpEarned,
    this.totalXp,
    this.level,
    this.levelProgress,
  });

  SessionLogResult toDto() {
    return SessionLogResult(
      success: success,
      currentStreak: currentStreak,
      streakStatus: streakStatus,
      newBadges: newBadges,
      alreadyLogged: alreadyLogged,
      xpEarned: xpEarned,
      totalXp: totalXp,
      level: level,
      levelProgress: levelProgress,
    );
  }

  factory SessionLogResponseDto.fromJson(Map<String, dynamic> json) =>
      _$SessionLogResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SessionLogResponseDtoToJson(this);
}
