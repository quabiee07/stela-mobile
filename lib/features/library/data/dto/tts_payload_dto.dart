// data/remote/dto/tts_payload_dto.dart
import 'package:json_annotation/json_annotation.dart';

part 'tts_payload_dto.g.dart';

@JsonSerializable()
class TtsPayloadDto {
  final String text;

  @JsonKey(name: 'model_id')
  final String modelId;

  @JsonKey(name: 'voice_settings')
  final VoiceSettingsDto voiceSettings;

  const TtsPayloadDto({
    required this.text,
    this.modelId = 'eleven_turbo_v2_5', // best for interactive story playback
    this.voiceSettings = const VoiceSettingsDto(),
  });

  factory TtsPayloadDto.fromJson(Map<String, dynamic> json) =>
      _$TtsPayloadDtoFromJson(json);

  Map<String, dynamic> toJson() => _$TtsPayloadDtoToJson(this);
}

@JsonSerializable()
class VoiceSettingsDto {
  final double stability;
  @JsonKey(name: 'similarity_boost')
  final double similarityBoost;
  final double style;
  @JsonKey(name: 'use_speaker_boost')
  final bool useSpeakerBoost;

  const VoiceSettingsDto({
    this.stability = 0.5,
    this.similarityBoost = 0.75,
    this.style = 0.3,
    this.useSpeakerBoost = true,
  });

  factory VoiceSettingsDto.fromJson(Map<String, dynamic> json) =>
      _$VoiceSettingsDtoFromJson(json);

  Map<String, dynamic> toJson() => _$VoiceSettingsDtoToJson(this);
}
