import 'package:flutter_test/flutter_test.dart';
import 'package:stela_mobile/features/library/data/services/tts_audio_cache.dart';

void main() {
  group('TtsAudioCache.cacheKey', () {
    test('is stable for the same inputs', () {
      final first = TtsAudioCache.cacheKey(
        text: 'Once upon a time',
        voiceId: 'voice-a',
        modelId: 'eleven_turbo_v2_5',
      );
      final second = TtsAudioCache.cacheKey(
        text: 'Once upon a time',
        voiceId: 'voice-a',
        modelId: 'eleven_turbo_v2_5',
      );

      expect(first, second);
      expect(first, hasLength(64));
    });

    test('changes when text, voice, or model changes', () {
      final base = TtsAudioCache.cacheKey(
        text: 'Once upon a time',
        voiceId: 'voice-a',
        modelId: 'eleven_turbo_v2_5',
      );

      expect(
        TtsAudioCache.cacheKey(
          text: 'A different story',
          voiceId: 'voice-a',
          modelId: 'eleven_turbo_v2_5',
        ),
        isNot(base),
      );
      expect(
        TtsAudioCache.cacheKey(
          text: 'Once upon a time',
          voiceId: 'voice-b',
          modelId: 'eleven_turbo_v2_5',
        ),
        isNot(base),
      );
      expect(
        TtsAudioCache.cacheKey(
          text: 'Once upon a time',
          voiceId: 'voice-a',
          modelId: 'other_model',
        ),
        isNot(base),
      );
    });
  });
}
