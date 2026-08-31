import 'package:json_annotation/json_annotation.dart';
import 'package:stela_mobile/features/profile/data/dto/api_timestamp_dto.dart';
import 'package:stela_mobile/features/profile/domain/models/streak_info.dart';

part 'streak_info_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class StreakInfoDto {
  final int currentStreak;
  final int longestStreak;
  final String? lastReadDate;
  final String streakStatus;
  final bool freezeAvailable;
  final bool freezeUsedThisMonth;
  final String? freezeActivatedDate;
  final ApiTimestampDto? lastUpdatedAt;

  /// Optional Mon–Sun session counts from the server.
  final List<int>? weeklySessionCounts;

  const StreakInfoDto({
    required this.currentStreak,
    required this.longestStreak,
    required this.lastReadDate,
    required this.streakStatus,
    required this.freezeAvailable,
    required this.freezeUsedThisMonth,
    required this.freezeActivatedDate,
    required this.lastUpdatedAt,
    this.weeklySessionCounts,
  });

  StreakInfo toDto() {
    return StreakInfo(
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      lastReadDate: lastReadDate,
      streakStatus: streakStatus,
      freezeAvailable: freezeAvailable,
      freezeUsedThisMonth: freezeUsedThisMonth,
      freezeActivatedDate: freezeActivatedDate,
      lastUpdatedAt: lastUpdatedAt?.toDto(),
      weeklySessionCounts: weeklySessionCounts,
    );
  }

  factory StreakInfoDto.fromJson(Map<String, dynamic> json) =>
      _$StreakInfoDtoFromJson(json);

  Map<String, dynamic> toJson() => _$StreakInfoDtoToJson(this);
}

@JsonSerializable()
class StreakFreezeResultDto {
  final bool success;
  final int currentStreak;

  const StreakFreezeResultDto({
    required this.success,
    required this.currentStreak,
  });

  StreakFreezeResult toDto() {
    return StreakFreezeResult(
      success: success,
      currentStreak: currentStreak,
    );
  }

  factory StreakFreezeResultDto.fromJson(Map<String, dynamic> json) =>
      _$StreakFreezeResultDtoFromJson(json);

  Map<String, dynamic> toJson() => _$StreakFreezeResultDtoToJson(this);
}
