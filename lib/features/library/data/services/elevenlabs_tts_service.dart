import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:stela_mobile/features/library/data/dto/tts_payload_dto.dart';
import 'package:stela_mobile/features/library/data/dto/voices_dto.dart';

part 'elevenlabs_tts_service.g.dart';

@RestApi(baseUrl: 'https://api.elevenlabs.io/v1/')
abstract class ElevenLabsTtsService {
  factory ElevenLabsTtsService(Dio dio, {String baseUrl}) =
      _ElevenLabsTtsService;

  static const authentication = 'xi-api-key';

  @POST('text-to-speech/{voiceId}')
  // @DioResponseType(ResponseType.bytes)
  Future<Uint8List> synthesize({
    @Header(authentication) required String apiKey,
    @Path('voiceId') required String voiceId,
    @Body() required TtsPayloadDto payload,
  });

  // Streaming — audio chunks returned as they are generated.
  // Best for live read-along playback in Stela without waiting for full download.
  // @POST('text-to-speech/{voiceId}/stream')
  // @DioResponseType(ResponseType.stream)
  // Future<HttpResponse<ResponseBody>> synthesizeStream({
  //   @Header(authentication) required String apiKey,
  //   @Path('voiceId') required String voiceId,
  //   @Body() required TtsPayloadDto payload,
  // });

  // Fetch all available voices — use this to populate voice selector UI.
  @GET('voices')
  Future<VoicesDto> getVoices({@Header(authentication) required String apiKey});
}
