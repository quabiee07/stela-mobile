import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:stela_mobile/core/data/dto/generic_dto.dart';
import 'package:stela_mobile/core/domain/utils/constants.dart';
import 'package:stela_mobile/features/profile/data/dto/daily_reminder_payload_dto.dart';
import 'package:stela_mobile/features/profile/data/dto/streak_info_dto.dart';
import 'package:stela_mobile/features/profile/data/dto/user_badge_dto.dart';

part 'profile_api_service.g.dart';

@RestApi(baseUrl: stelaBaseUrl)
abstract class ProfileApiService {
  factory ProfileApiService(Dio dio, {String baseUrl}) = _ProfileApiService;

  @PUT("auth/notification-preferences")
  Future<GenericDto> setReminder({
    @Body() required DailyReminderPayloadDto payload,
  });

  @GET("streak")
  Future<StreakInfoDto> getStreak();

  @POST("streak/freeze")
  Future<StreakFreezeResultDto> activateStreakFreeze();

  @GET("badges")
  Future<List<UserBadgeDto>> getBadges();

  @POST("badges/{badgeId}/seen")
  Future<GenericDto> markBadgeSeen({@Path("badgeId") required String badgeId});

  @POST("xp/share")
  Future<GenericDto> shareXp();
}
