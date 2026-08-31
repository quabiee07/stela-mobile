import 'package:json_annotation/json_annotation.dart';
import 'package:stela_mobile/features/library/domain/models/tts_payload.dart';

part 'tts_payload_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class TtsPayloadDto {
  final String text;

  @JsonKey(name: 'model_id')
  final String modelId;

  @JsonKey(name: 'voice_settings')
  final VoiceSettingsDto voiceSettings;

  const TtsPayloadDto({
    required this.text,
    this.modelId = 'eleven_turbo_v2_5',
    this.voiceSettings = const VoiceSettingsDto(),
  });

  factory TtsPayloadDto.fromDomain(TtsPayload payload) => TtsPayloadDto(
        text: payload.text,
        modelId: payload.modelId,
        voiceSettings: VoiceSettingsDto.fromDomain(payload.voiceSettings),
      );

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

  factory VoiceSettingsDto.fromDomain(VoiceSettings settings) =>
      VoiceSettingsDto(
        stability: settings.stability,
        similarityBoost: settings.similarityBoost,
        style: settings.style,
        useSpeakerBoost: settings.useSpeakerBoost,
      );

  factory VoiceSettingsDto.fromJson(Map<String, dynamic> json) =>
      _$VoiceSettingsDtoFromJson(json);

  Map<String, dynamic> toJson() => _$VoiceSettingsDtoToJson(this);
}
