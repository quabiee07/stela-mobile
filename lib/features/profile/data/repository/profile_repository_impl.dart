import 'package:injectable/injectable.dart';
import 'package:stela_mobile/core/domain/api_response/api_result.dart';
import 'package:stela_mobile/core/domain/errors/app_failure.dart';
import 'package:stela_mobile/core/domain/models/generic_model.dart';
import 'package:stela_mobile/features/profile/data/dto/daily_reminder_payload_dto.dart';
import 'package:stela_mobile/features/profile/data/services/profile_api_service.dart';
import 'package:stela_mobile/features/profile/domain/models/daily_reminder_payload.dart';
import 'package:stela_mobile/features/profile/domain/models/streak_info.dart';
import 'package:stela_mobile/features/profile/domain/models/user_badge.dart';
import 'package:stela_mobile/features/profile/domain/repository/profile_repository.dart';

@LazySingleton(as: ProfileRepository)
class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this._api);

  final ProfileApiService _api;

  @override
  Future<ApiResult<GenericModel>> setReminder(
    DailyReminderPayload payload,
  ) async {
    try {
      final payloadDto = DailyReminderPayloadDto(
        dailyReminderEnabled: payload.dailyReminderEnabled,
        reminderHour: payload.reminderHour,
      );

      final result = await _api.setReminder(payload: payloadDto);
      return ApiResult.success(result.toDto());
    } catch (e) {
      return ApiResult.failure(mapToAppFailure(e));
    }
  }

  @override
  Future<ApiResult<StreakInfo>> getStreak() async {
    try {
      final result = await _api.getStreak();
      return ApiResult.success(result.toDto());
    } catch (e) {
      return ApiResult.failure(mapToAppFailure(e));
    }
  }

  @override
  Future<ApiResult<StreakFreezeResult>> activateStreakFreeze() async {
    try {
      final result = await _api.activateStreakFreeze();
      return ApiResult.success(result.toDto());
    } catch (e) {
      return ApiResult.failure(mapToAppFailure(e));
    }
  }

  @override
  Future<ApiResult<List<UserBadge>>> getBadges() async {
    try {
      final result = await _api.getBadges();
      return ApiResult.success(result.map((badge) => badge.toDto()).toList());
    } catch (e) {
      return ApiResult.failure(mapToAppFailure(e));
    }
  }

  @override
  Future<ApiResult<GenericModel>> markBadgeSeen(String badgeId) async {
    try {
      final result = await _api.markBadgeSeen(badgeId: badgeId);
      return ApiResult.success(result.toDto());
    } catch (e) {
      return ApiResult.failure(mapToAppFailure(e));
    }
  }

  @override
  Future<ApiResult<GenericModel>> shareXp() async {
    try {
      final result = await _api.shareXp();
      return ApiResult.success(result.toDto());
    } catch (e) {
      return ApiResult.failure(mapToAppFailure(e));
    }
  }
}
