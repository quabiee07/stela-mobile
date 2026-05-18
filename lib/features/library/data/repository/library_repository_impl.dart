import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stela_mobile/core/di/core_module_container.dart';
import 'package:stela_mobile/core/domain/api_response/api_result.dart';
import 'package:stela_mobile/features/library/data/dto/tts_payload_dto.dart';
import 'package:stela_mobile/features/library/data/services/elevenlabs_tts_service.dart';
import 'package:stela_mobile/features/library/domain/models/voices.dart';
import 'package:stela_mobile/features/library/domain/repository/library_repository.dart';

@LazySingleton(as: LibraryRepository)
class LibraryRepositoryImpl implements LibraryRepository {
  final ttsService = getIt.get<ElevenLabsTtsService>();
  final _pref = getIt.getAsync<SharedPreferences>();

  String _cacheKey(String text, String voiceId) =>
      'tts_${voiceId}_${text.hashCode}';

  @override
  Future<ApiResult<List<VoiceModel>>> getAvailableVoices() async {
    try {
      final result = await ttsService.getVoices(
        apiKey: dotenv.env['ELEVENLABS_API_KEY']!,
      );
      return ApiResult.success(result.voices.map((e) => e.toDomain()).toList());
    } catch (e) {
      return ApiResult.failure(e);
    }
  }

  @override
  Future<ApiResult<Uint8List>> synthesize(String voiceId, String text) async {
    try {
      final pref = await _pref;
      final key = _cacheKey(text, voiceId);
      final cached = pref.getString(key);

      if (cached != null) {
        return ApiResult.success(base64Decode(cached));
      }

      final result = await ttsService.synthesize(
        apiKey: dotenv.get('ELEVENLABS_API_KEY'),
        voiceId: voiceId,
        payload: TtsPayloadDto(text: text, modelId: "eleven_turbo_v2_5"),
      );
      
      await pref.setString(key, base64Encode(result));
      return ApiResult.success(result);
    } catch (e) {
      return ApiResult.failure(e);
    }
  }
}
