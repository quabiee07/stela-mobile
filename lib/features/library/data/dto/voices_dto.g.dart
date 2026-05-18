// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'voices_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VoicesDto _$VoicesDtoFromJson(Map<String, dynamic> json) => VoicesDto(
  voices: (json['voices'] as List<dynamic>)
      .map((e) => Voice.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$VoicesDtoToJson(VoicesDto instance) => <String, dynamic>{
  'voices': instance.voices,
};

Voice _$VoiceFromJson(Map<String, dynamic> json) => Voice(
  voiceId: json['voice_id'] as String,
  name: json['name'] as String,
  category: $enumDecode(_$CategoryEnumMap, json['category']),
  fineTuning: FineTuning.fromJson(json['fine_tuning'] as Map<String, dynamic>),
  labels: Labels.fromJson(json['labels'] as Map<String, dynamic>),
  description: json['description'] as String,
  previewUrl: json['preview_url'] as String,
  verifiedLanguages: (json['verified_languages'] as List<dynamic>)
      .map((e) => VerifiedLanguage.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$VoiceToJson(Voice instance) => <String, dynamic>{
  'voice_id': instance.voiceId,
  'name': instance.name,
  'category': _$CategoryEnumMap[instance.category]!,
  'fine_tuning': instance.fineTuning,
  'labels': instance.labels,
  'description': instance.description,
  'preview_url': instance.previewUrl,
  'verified_languages': instance.verifiedLanguages,
};

const _$CategoryEnumMap = {
  Category.PREMADE: 'premade',
  Category.PROFESSIONAL: 'professional',
};

FineTuning _$FineTuningFromJson(Map<String, dynamic> json) => FineTuning(
  language: $enumDecodeNullable(_$LanguageEnumMap, json['language']),
);

Map<String, dynamic> _$FineTuningToJson(FineTuning instance) =>
    <String, dynamic>{'language': _$LanguageEnumMap[instance.language]};

const _$LanguageEnumMap = {Language.EN: 'en'};

Labels _$LabelsFromJson(Map<String, dynamic> json) => Labels(
  useCase: json['use_case'] as String,
  gender: $enumDecode(_$GenderEnumMap, json['gender']),
  accent: $enumDecode(_$AccentEnumMap, json['accent']),
  age: $enumDecode(_$AgeEnumMap, json['age']),
  language: $enumDecode(_$LanguageEnumMap, json['language']),
  descriptive: json['descriptive'] as String?,
  locale: json['locale'] as String?,
);

Map<String, dynamic> _$LabelsToJson(Labels instance) => <String, dynamic>{
  'use_case': instance.useCase,
  'gender': _$GenderEnumMap[instance.gender]!,
  'accent': _$AccentEnumMap[instance.accent]!,
  'age': _$AgeEnumMap[instance.age]!,
  'language': _$LanguageEnumMap[instance.language]!,
  'descriptive': instance.descriptive,
  'locale': instance.locale,
};

const _$GenderEnumMap = {
  Gender.FEMALE: 'female',
  Gender.MALE: 'male',
  Gender.NEUTRAL: 'neutral',
};

const _$AccentEnumMap = {
  Accent.AMERICAN: 'american',
  Accent.AUSTRALIAN: 'australian',
  Accent.BRAZILIAN: 'brazilian',
  Accent.BRITISH: 'british',
  Accent.CENTRAL: 'central',
  Accent.NORTHERN: 'northern',
  Accent.PENINSULAR: 'peninsular',
  Accent.SOUTHERN: 'southern',
  Accent.STANDARD: 'standard',
};

const _$AgeEnumMap = {
  Age.MIDDLE_AGED: 'middle_aged',
  Age.OLD: 'old',
  Age.YOUNG: 'young',
};

VerifiedLanguage _$VerifiedLanguageFromJson(Map<String, dynamic> json) =>
    VerifiedLanguage(
      language: json['language'] as String,
      modelId: json['model_id'] as String,
      accent: $enumDecodeNullable(_$AccentEnumMap, json['accent']),
      locale: json['locale'] as String?,
      previewUrl: json['preview_url'] as String,
    );

Map<String, dynamic> _$VerifiedLanguageToJson(VerifiedLanguage instance) =>
    <String, dynamic>{
      'language': instance.language,
      'model_id': instance.modelId,
      'accent': _$AccentEnumMap[instance.accent],
      'locale': instance.locale,
      'preview_url': instance.previewUrl,
    };
