import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:stela_mobile/features/library/data/dto/session_log_request_dto.dart';
import 'package:stela_mobile/features/library/data/dto/session_log_response_dto.dart';

part 'session_service.g.dart';

@RestApi()
abstract class SessionService {
  factory SessionService(Dio dio, {String baseUrl}) = _SessionService;

  @POST('sessions/log')
  Future<SessionLogResponseDto> logSession({
    @Body() required SessionLogRequestDto payload,
  });
}
