// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tts_audio_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TtsAudioResponseDto _$TtsAudioResponseDtoFromJson(Map<String, dynamic> json) =>
    TtsAudioResponseDto(
      audioBase64: json['audio_base64'] as String,
      alignment: json['alignment'] == null
          ? null
          : TtsAlignmentDto.fromJson(json['alignment'] as Map<String, dynamic>),
      normalizedAlignment: json['normalized_alignment'] == null
          ? null
          : TtsAlignmentDto.fromJson(
              json['normalized_alignment'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$TtsAudioResponseDtoToJson(
  TtsAudioResponseDto instance,
) => <String, dynamic>{
  'audio_base64': instance.audioBase64,
  'alignment': instance.alignment,
  'normalized_alignment': instance.normalizedAlignment,
};

TtsAlignmentDto _$TtsAlignmentDtoFromJson(Map<String, dynamic> json) =>
    TtsAlignmentDto(
      characters: (json['characters'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      characterStartTimesSeconds:
          (json['character_start_times_seconds'] as List<dynamic>)
              .map((e) => (e as num).toDouble())
              .toList(),
      characterEndTimesSeconds:
          (json['character_end_times_seconds'] as List<dynamic>)
              .map((e) => (e as num).toDouble())
              .toList(),
    );

Map<String, dynamic> _$TtsAlignmentDtoToJson(TtsAlignmentDto instance) =>
    <String, dynamic>{
      'characters': instance.characters,
      'character_start_times_seconds': instance.characterStartTimesSeconds,
      'character_end_times_seconds': instance.characterEndTimesSeconds,
    };
