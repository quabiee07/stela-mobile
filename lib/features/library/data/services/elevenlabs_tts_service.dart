import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:stela_mobile/features/library/data/dto/tts_audio_response_dto.dart';
import 'package:stela_mobile/features/library/data/dto/tts_payload_dto.dart';
import 'package:stela_mobile/features/library/data/dto/voices_dto.dart';

part 'elevenlabs_tts_service.g.dart';

@RestApi(baseUrl: 'https://api.elevenlabs.io/v1/')
abstract class ElevenLabsTtsService {
  factory ElevenLabsTtsService(Dio dio, {String baseUrl}) =
      _ElevenLabsTtsService;

  static const authentication = 'xi-api-key';

  @POST('text-to-speech/{voiceId}/with-timestamps')
  Future<TtsAudioResponseDto> synthesizeWithTimestamps({
    @Header(authentication) required String apiKey,
    @Header('Accept') String accept = 'application/json',
    @Path('voiceId') required String voiceId,
    @Body() required TtsPayloadDto payload,
  });

  @GET('voices')
  Future<VoicesDto> getVoices({@Header(authentication) required String apiKey});
}
