import 'package:json_annotation/json_annotation.dart';
import 'dart:convert';

import 'package:stela_mobile/features/library/domain/models/voices.dart';

part 'voices_dto.g.dart';

VoicesDto voicesDtoFromJson(String str) => VoicesDto.fromJson(json.decode(str));

String voicesDtoToJson(VoicesDto data) => json.encode(data.toJson());

@JsonSerializable()
class VoicesDto {
  @JsonKey(name: 'voices')
  List<Voice> voices;

  VoicesDto({required this.voices});

  factory VoicesDto.fromJson(Map<String, dynamic> json) =>
      _$VoicesDtoFromJson(json);

  Map<String, dynamic> toJson() => _$VoicesDtoToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Voice {
  @JsonKey(name: 'voice_id')
  String voiceId;
  @JsonKey(name: 'name')
  String name;
  @JsonKey(name: 'category', unknownEnumValue: Category.unknown)
  Category category;
  @JsonKey(name: 'fine_tuning')
  FineTuning? fineTuning;
  @JsonKey(name: 'labels')
  Labels? labels;
  @JsonKey(name: 'description')
  String? description;
  @JsonKey(name: 'preview_url')
  String? previewUrl;
  @JsonKey(name: 'verified_languages')
  List<VerifiedLanguage>? verifiedLanguages;

  Voice({
    required this.voiceId,
    required this.name,
    this.category = Category.unknown,
    this.fineTuning,
    this.labels,
    this.description,
    this.previewUrl,
    this.verifiedLanguages,
  });

  factory Voice.fromJson(Map<String, dynamic> json) => _$VoiceFromJson(json);

  Map<String, dynamic> toJson() => _$VoiceToJson(this);

  VoiceModel toDomain() => VoiceModel(
        voiceId: voiceId,
        name: name,
        category: category.toDomain(),
        fineTuning: fineTuning?.toDomain() ?? FineTuningModel(language: null),
        labels: labels?.toDomain() ??
            LabelModel(
              useCase: '',
              gender: GenderModel.NEUTRAL,
              accent: '',
              age: AgeModel.YOUNG,
              language: LanguageModel.EN,
            ),
        description: description ?? '',
        previewUrl: previewUrl ?? '',
        verifiedLanguages:
            verifiedLanguages?.map((e) => e.toDomain()).toList() ?? const [],
      );
}

enum Category {
  @JsonValue('premade')
  premade,
  @JsonValue('professional')
  professional,
  @JsonValue('cloned')
  cloned,
  @JsonValue('generated')
  generated,
  unknown,
}

extension CategoryExtension on Category {
  CategoryModel toDomain() {
    switch (this) {
      case Category.premade:
        return CategoryModel.PREMADE;
      case Category.professional:
        return CategoryModel.PROFESSIONAL;
      case Category.cloned:
      case Category.generated:
      case Category.unknown:
        return CategoryModel.UNKNOWN;
    }
  }
}

@JsonSerializable()
class FineTuning {
  @JsonKey(name: 'language', unknownEnumValue: Language.unknown)
  Language? language;

  FineTuning({this.language});

  FineTuningModel toDomain() => FineTuningModel(language: language?.toDomain());

  factory FineTuning.fromJson(Map<String, dynamic> json) =>
      _$FineTuningFromJson(json);

  Map<String, dynamic> toJson() => _$FineTuningToJson(this);
}

enum Language {
  @JsonValue('en')
  en,
  unknown,
}

extension LanguageExtension on Language {
  LanguageModel? toDomain() {
    switch (this) {
      case Language.en:
        return LanguageModel.EN;
      case Language.unknown:
        return LanguageModel.UNKNOWN;
    }
  }
}

@JsonSerializable()
class Labels {
  @JsonKey(name: 'use_case')
  String? useCase;
  @JsonKey(name: 'gender', unknownEnumValue: Gender.unknown)
  Gender? gender;
  /// Kept as String — ElevenLabs adds accents like "latin american" freely.
  @JsonKey(name: 'accent')
  String? accent;
  @JsonKey(name: 'age', unknownEnumValue: Age.unknown)
  Age? age;
  @JsonKey(name: 'language', unknownEnumValue: Language.unknown)
  Language? language;
  @JsonKey(name: 'descriptive')
  String? descriptive;
  @JsonKey(name: 'locale')
  String? locale;

  Labels({
    this.useCase,
    this.gender,
    this.accent,
    this.age,
    this.language,
    this.descriptive,
    this.locale,
  });

  LabelModel toDomain() => LabelModel(
        useCase: useCase ?? '',
        gender: (gender ?? Gender.unknown).toDomain(),
        accent: accent ?? '',
        age: (age ?? Age.unknown).toDomain(),
        language: (language ?? Language.unknown).toDomain() ?? LanguageModel.UNKNOWN,
        descriptive: descriptive,
        locale: locale,
      );

  factory Labels.fromJson(Map<String, dynamic> json) => _$LabelsFromJson(json);

  Map<String, dynamic> toJson() => _$LabelsToJson(this);
}

enum Age {
  @JsonValue('middle_aged')
  middleAged,
  @JsonValue('old')
  old,
  @JsonValue('young')
  young,
  unknown,
}

extension AgeExtension on Age {
  AgeModel toDomain() {
    switch (this) {
      case Age.middleAged:
        return AgeModel.MIDDLE_AGED;
      case Age.old:
        return AgeModel.OLD;
      case Age.young:
        return AgeModel.YOUNG;
      case Age.unknown:
        return AgeModel.UNKNOWN;
    }
  }
}

enum Gender {
  @JsonValue('female')
  female,
  @JsonValue('male')
  male,
  @JsonValue('neutral')
  neutral,
  unknown,
}

extension GenderExtension on Gender {
  GenderModel toDomain() {
    switch (this) {
      case Gender.female:
        return GenderModel.FEMALE;
      case Gender.male:
        return GenderModel.MALE;
      case Gender.neutral:
      case Gender.unknown:
        return GenderModel.NEUTRAL;
    }
  }
}

@JsonSerializable()
class VerifiedLanguage {
  @JsonKey(name: 'language')
  String language;
  @JsonKey(name: 'model_id')
  String modelId;
  @JsonKey(name: 'accent')
  String? accent;
  @JsonKey(name: 'locale')
  String? locale;
  @JsonKey(name: 'preview_url')
  String? previewUrl;

  VerifiedLanguage({
    required this.language,
    required this.modelId,
    this.accent,
    this.locale,
    this.previewUrl,
  });

  VerifiedLanguageModel toDomain() => VerifiedLanguageModel(
        language: language,
        modelId: modelId,
        accent: accent,
        locale: locale,
        previewUrl: previewUrl ?? '',
      );

  factory VerifiedLanguage.fromJson(Map<String, dynamic> json) =>
      _$VerifiedLanguageFromJson(json);

  Map<String, dynamic> toJson() => _$VerifiedLanguageToJson(this);
}
