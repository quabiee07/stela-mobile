import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:stela_mobile/features/library/domain/models/synthesized_audio.dart';

part 'tts_audio_response_dto.g.dart';

@JsonSerializable()
class TtsAudioResponseDto {
  @JsonKey(name: 'audio_base64')
  final String audioBase64;
  final TtsAlignmentDto? alignment;
  @JsonKey(name: 'normalized_alignment')
  final TtsAlignmentDto? normalizedAlignment;

  const TtsAudioResponseDto({
    required this.audioBase64,
    this.alignment,
    this.normalizedAlignment,
  });

  factory TtsAudioResponseDto.fromJson(Map<String, dynamic> json) =>
      _$TtsAudioResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$TtsAudioResponseDtoToJson(this);

  SynthesizedAudio toDomain() {
    final timing = alignment ?? normalizedAlignment;
    return SynthesizedAudio(
      bytes: base64Decode(audioBase64),
      characters: timing?.characters ?? const [],
      characterStartTimesSeconds:
          timing?.characterStartTimesSeconds ?? const [],
      characterEndTimesSeconds: timing?.characterEndTimesSeconds ?? const [],
    );
  }
}

@JsonSerializable()
class TtsAlignmentDto {
  final List<String> characters;
  @JsonKey(name: 'character_start_times_seconds')
  final List<double> characterStartTimesSeconds;
  @JsonKey(name: 'character_end_times_seconds')
  final List<double> characterEndTimesSeconds;

  const TtsAlignmentDto({
    required this.characters,
    required this.characterStartTimesSeconds,
    required this.characterEndTimesSeconds,
  });

  factory TtsAlignmentDto.fromJson(Map<String, dynamic> json) =>
      _$TtsAlignmentDtoFromJson(json);

  Map<String, dynamic> toJson() => _$TtsAlignmentDtoToJson(this);
}
