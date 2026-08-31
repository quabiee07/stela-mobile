import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:stela_mobile/features/library/domain/models/synthesized_audio.dart';

/// Durable on-device cache that prevents repeated paid TTS requests.
///
/// Audio is stored as an MP3 in application support storage. Keychain-backed
/// secure storage is intentionally not used because it is designed for small
/// secrets, not multi-megabyte audio blobs.
@lazySingleton
class TtsAudioCache {
  static const _cacheVersion = 'el_timestamps_v1';

  Future<SynthesizedAudio?> read({
    required String text,
    required String voiceId,
    required String modelId,
  }) async {
    try {
      final paths = await _paths(text, voiceId, modelId);
      if (!await paths.audio.exists() || !await paths.metadata.exists()) {
        return null;
      }

      final metadata =
          jsonDecode(await paths.metadata.readAsString())
              as Map<String, dynamic>;
      final bytes = await paths.audio.readAsBytes();
      if (bytes.isEmpty) return null;

      return SynthesizedAudio(
        bytes: bytes,
        characters: _stringList(metadata['characters']),
        characterStartTimesSeconds: _doubleList(
          metadata['characterStartTimesSeconds'],
        ),
        characterEndTimesSeconds: _doubleList(
          metadata['characterEndTimesSeconds'],
        ),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> write({
    required String text,
    required String voiceId,
    required String modelId,
    required SynthesizedAudio audio,
  }) async {
    final paths = await _paths(text, voiceId, modelId);
    await paths.directory.create(recursive: true);

    final audioTemp = File('${paths.audio.path}.tmp');
    final metadataTemp = File('${paths.metadata.path}.tmp');
    await audioTemp.writeAsBytes(audio.bytes, flush: true);
    await metadataTemp.writeAsString(
      jsonEncode({
        'characters': audio.characters,
        'characterStartTimesSeconds': audio.characterStartTimesSeconds,
        'characterEndTimesSeconds': audio.characterEndTimesSeconds,
      }),
      flush: true,
    );

    if (await paths.audio.exists()) await paths.audio.delete();
    if (await paths.metadata.exists()) await paths.metadata.delete();
    await audioTemp.rename(paths.audio.path);
    await metadataTemp.rename(paths.metadata.path);
  }

  Future<_CachePaths> _paths(
    String text,
    String voiceId,
    String modelId,
  ) async {
    final root = await getApplicationSupportDirectory();
    final directory = Directory(
      '${root.path}${Platform.pathSeparator}tts_audio_cache',
    );
    final digest = sha256
        .convert(utf8.encode('$_cacheVersion|$modelId|$voiceId|$text'))
        .toString();
    return _CachePaths(
      directory: directory,
      audio: File('${directory.path}${Platform.pathSeparator}$digest.mp3'),
      metadata: File('${directory.path}${Platform.pathSeparator}$digest.json'),
    );
  }

  static List<String> _stringList(Object? value) =>
      value is List ? value.whereType<String>().toList() : const [];

  static List<double> _doubleList(Object? value) => value is List
      ? value.whereType<num>().map((item) => item.toDouble()).toList()
      : const [];
}

class _CachePaths {
  final Directory directory;
  final File audio;
  final File metadata;

  const _CachePaths({
    required this.directory,
    required this.audio,
    required this.metadata,
  });
}
