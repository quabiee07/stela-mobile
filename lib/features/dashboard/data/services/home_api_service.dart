import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:stela_mobile/core/data/dto/generic_dto.dart';
import 'package:stela_mobile/core/domain/utils/constants.dart';
import 'package:stela_mobile/features/dashboard/data/dto/dashboard_payload_dto.dart';
import 'package:stela_mobile/features/dashboard/data/dto/health_status_dto.dart';

part 'home_api_service.g.dart';

@RestApi(baseUrl: stelaBaseUrl)
abstract class HomeApiService {
  factory HomeApiService(Dio dio, {String baseUrl}) = _HomeApiService;

  @POST("auth/fcm-token")
  Future<GenericDto> saveFcmToken({
    @Body() required DashboardPayloadDto payload,
  });

  @GET("health")
  Future<HealthStatusDto> getHealth();
}
