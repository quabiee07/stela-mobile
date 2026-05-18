// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tts_payload_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TtsPayloadDto _$TtsPayloadDtoFromJson(Map<String, dynamic> json) =>
    TtsPayloadDto(
      text: json['text'] as String,
      modelId: json['model_id'] as String? ?? 'eleven_turbo_v2_5',
      voiceSettings: json['voice_settings'] == null
          ? const VoiceSettingsDto()
          : VoiceSettingsDto.fromJson(
              json['voice_settings'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$TtsPayloadDtoToJson(TtsPayloadDto instance) =>
    <String, dynamic>{
      'text': instance.text,
      'model_id': instance.modelId,
      'voice_settings': instance.voiceSettings,
    };

VoiceSettingsDto _$VoiceSettingsDtoFromJson(Map<String, dynamic> json) =>
    VoiceSettingsDto(
      stability: (json['stability'] as num?)?.toDouble() ?? 0.5,
      similarityBoost: (json['similarity_boost'] as num?)?.toDouble() ?? 0.75,
      style: (json['style'] as num?)?.toDouble() ?? 0.3,
      useSpeakerBoost: json['use_speaker_boost'] as bool? ?? true,
    );

Map<String, dynamic> _$VoiceSettingsDtoToJson(VoiceSettingsDto instance) =>
    <String, dynamic>{
      'stability': instance.stability,
      'similarity_boost': instance.similarityBoost,
      'style': instance.style,
      'use_speaker_boost': instance.useSpeakerBoost,
    };
