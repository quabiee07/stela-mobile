import 'package:stela_mobile/core/domain/api_response/api_result.dart';
import 'package:stela_mobile/core/domain/models/generic_model.dart';
import 'package:stela_mobile/features/profile/domain/models/daily_reminder_payload.dart';
import 'package:stela_mobile/features/profile/domain/models/streak_info.dart';
import 'package:stela_mobile/features/profile/domain/models/user_badge.dart';

abstract class ProfileRepository {
  Future<ApiResult<GenericModel>> setReminder(DailyReminderPayload payload);
  Future<ApiResult<StreakInfo>> getStreak();
  Future<ApiResult<StreakFreezeResult>> activateStreakFreeze();
  Future<ApiResult<List<UserBadge>>> getBadges();
  Future<ApiResult<GenericModel>> markBadgeSeen(String badgeId);
  Future<ApiResult<GenericModel>> shareXp();
}