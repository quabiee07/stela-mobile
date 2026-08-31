import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:stela_mobile/core/data/dto/generic_dto.dart';
import 'package:stela_mobile/core/domain/utils/constants.dart';
import 'package:stela_mobile/features/auth/data/dto/profile_setup_payload_dto.dart';

part 'auth_api_service.g.dart';

@RestApi(baseUrl: stelaBaseUrl)
abstract class AuthApiService {
  factory AuthApiService(Dio dio, {String baseUrl}) = _AuthApiService;

  @POST("auth/onboarding")
  Future<GenericDto> completeOnboarding({
    @Body() required ProfileSetupPayloadDto payload,
  });
}
