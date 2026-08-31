import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:injectable/injectable.dart';
import 'package:stela_mobile/core/di/core_module_container.dart';
import 'package:stela_mobile/core/domain/api_response/api_result.dart';
import 'package:stela_mobile/features/library/data/dto/tts_payload_dto.dart';
import 'package:stela_mobile/features/library/data/services/elevenlabs_tts_service.dart';
import 'package:stela_mobile/features/library/data/services/tts_audio_cache.dart';
import 'package:stela_mobile/features/library/domain/models/synthesized_audio.dart';
import 'package:stela_mobile/features/library/domain/models/tts_payload.dart';
import 'package:stela_mobile/features/library/domain/models/voices.dart';
import 'package:stela_mobile/features/library/domain/repository/library_repository.dart';

@LazySingleton(as: LibraryRepository)
class LibraryRepositoryImpl implements LibraryRepository {
  static const _modelId = 'eleven_turbo_v2_5';

  final _elevenLabsTtsService = getIt.get<ElevenLabsTtsService>();
  final _audioCache = getIt.get<TtsAudioCache>();

  String get _apiKey {
    final key = dotenv.env['ELEVENLABS_API_KEY'];
    if (key == null || key.trim().isEmpty) {
      throw Exception('ELEVENLABS_API_KEY is missing from assets/env/.env');
    }
    return key.trim();
  }

  @override
  Future<ApiResult<List<VoiceModel>>> getAvailableVoices() async {
    try {
      final result = await _elevenLabsTtsService.getVoices(apiKey: _apiKey);
      return ApiResult.success(result.voices.map((e) => e.toDomain()).toList());
    } catch (e) {
      return ApiResult.failure(e);
    }
  }

  @override
  Future<ApiResult<SynthesizedAudio>> synthesize(
    String text,
    String voiceId,
  ) async {
    try {
      final cached = await _audioCache.read(
        text: text,
        voiceId: voiceId,
        modelId: _modelId,
      );
      if (cached != null) {
        return ApiResult.success(cached);
      }

      final payload = TtsPayloadDto.fromDomain(
        TtsPayload(text: text, modelId: _modelId),
      );
      final response = await _elevenLabsTtsService.synthesizeWithTimestamps(
        apiKey: _apiKey,
        voiceId: voiceId,
        payload: payload,
      );
      final audio = response.toDomain();

      if (audio.bytes.isEmpty) {
        throw Exception('ElevenLabs returned empty audio.');
      }

      try {
        await _audioCache.write(
          text: text,
          voiceId: voiceId,
          modelId: _modelId,
          audio: audio,
        );
      } catch (_) {
        // Ignore cache save errors
      }

      return ApiResult.success(audio);
    } catch (e) {
      return ApiResult.failure(e);
    }
  }
}
