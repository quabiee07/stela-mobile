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
  category:
      $enumDecodeNullable(
        _$CategoryEnumMap,
        json['category'],
        unknownValue: Category.unknown,
      ) ??
      Category.unknown,
  fineTuning: json['fine_tuning'] == null
      ? null
      : FineTuning.fromJson(json['fine_tuning'] as Map<String, dynamic>),
  labels: json['labels'] == null
      ? null
      : Labels.fromJson(json['labels'] as Map<String, dynamic>),
  description: json['description'] as String?,
  previewUrl: json['preview_url'] as String?,
  verifiedLanguages: (json['verified_languages'] as List<dynamic>?)
      ?.map((e) => VerifiedLanguage.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$VoiceToJson(Voice instance) => <String, dynamic>{
  'voice_id': instance.voiceId,
  'name': instance.name,
  'category': _$CategoryEnumMap[instance.category]!,
  'fine_tuning': instance.fineTuning?.toJson(),
  'labels': instance.labels?.toJson(),
  'description': instance.description,
  'preview_url': instance.previewUrl,
  'verified_languages': instance.verifiedLanguages
      ?.map((e) => e.toJson())
      .toList(),
};

const _$CategoryEnumMap = {
  Category.premade: 'premade',
  Category.professional: 'professional',
  Category.cloned: 'cloned',
  Category.generated: 'generated',
  Category.unknown: 'unknown',
};

FineTuning _$FineTuningFromJson(Map<String, dynamic> json) => FineTuning(
  language: $enumDecodeNullable(
    _$LanguageEnumMap,
    json['language'],
    unknownValue: Language.unknown,
  ),
);

Map<String, dynamic> _$FineTuningToJson(FineTuning instance) =>
    <String, dynamic>{'language': _$LanguageEnumMap[instance.language]};

const _$LanguageEnumMap = {Language.en: 'en', Language.unknown: 'unknown'};

Labels _$LabelsFromJson(Map<String, dynamic> json) => Labels(
  useCase: json['use_case'] as String?,
  gender: $enumDecodeNullable(
    _$GenderEnumMap,
    json['gender'],
    unknownValue: Gender.unknown,
  ),
  accent: json['accent'] as String?,
  age: $enumDecodeNullable(
    _$AgeEnumMap,
    json['age'],
    unknownValue: Age.unknown,
  ),
  language: $enumDecodeNullable(
    _$LanguageEnumMap,
    json['language'],
    unknownValue: Language.unknown,
  ),
  descriptive: json['descriptive'] as String?,
  locale: json['locale'] as String?,
);

Map<String, dynamic> _$LabelsToJson(Labels instance) => <String, dynamic>{
  'use_case': instance.useCase,
  'gender': _$GenderEnumMap[instance.gender],
  'accent': instance.accent,
  'age': _$AgeEnumMap[instance.age],
  'language': _$LanguageEnumMap[instance.language],
  'descriptive': instance.descriptive,
  'locale': instance.locale,
};

const _$GenderEnumMap = {
  Gender.female: 'female',
  Gender.male: 'male',
  Gender.neutral: 'neutral',
  Gender.unknown: 'unknown',
};

const _$AgeEnumMap = {
  Age.middleAged: 'middle_aged',
  Age.old: 'old',
  Age.young: 'young',
  Age.unknown: 'unknown',
};

VerifiedLanguage _$VerifiedLanguageFromJson(Map<String, dynamic> json) =>
    VerifiedLanguage(
      language: json['language'] as String,
      modelId: json['model_id'] as String,
      accent: json['accent'] as String?,
      locale: json['locale'] as String?,
      previewUrl: json['preview_url'] as String?,
    );

Map<String, dynamic> _$VerifiedLanguageToJson(VerifiedLanguage instance) =>
    <String, dynamic>{
      'language': instance.language,
      'model_id': instance.modelId,
      'accent': instance.accent,
      'locale': instance.locale,
      'preview_url': instance.previewUrl,
    };
