// To parse this JSON data, do
//
//     final voicesDto = voicesDtoFromJson(jsonString);

import 'package:json_annotation/json_annotation.dart';
import 'dart:convert';

import 'package:stela_mobile/features/library/domain/models/voices.dart';

part 'voices_dto.g.dart';

VoicesDto voicesDtoFromJson(String str) => VoicesDto.fromJson(json.decode(str));

String voicesDtoToJson(VoicesDto data) => json.encode(data.toJson());

@JsonSerializable()
class VoicesDto {
  @JsonKey(name: "voices")
  List<Voice> voices;

  VoicesDto({required this.voices});

  factory VoicesDto.fromJson(Map<String, dynamic> json) =>
      _$VoicesDtoFromJson(json);

  Map<String, dynamic> toJson() => _$VoicesDtoToJson(this);
}

@JsonSerializable()
class Voice {
  @JsonKey(name: "voice_id")
  String voiceId;
  @JsonKey(name: "name")
  String name;
  @JsonKey(name: "category")
  Category category;
  @JsonKey(name: "fine_tuning")
  FineTuning fineTuning;
  @JsonKey(name: "labels")
  Labels labels;
  @JsonKey(name: "description")
  String description;
  @JsonKey(name: "preview_url")
  String previewUrl;
  @JsonKey(name: "verified_languages")
  List<VerifiedLanguage> verifiedLanguages;

  Voice({
    required this.voiceId,
    required this.name,
    required this.category,
    required this.fineTuning,
    required this.labels,
    required this.description,
    required this.previewUrl,
    required this.verifiedLanguages,
  });

  factory Voice.fromJson(Map<String, dynamic> json) => _$VoiceFromJson(json);

  Map<String, dynamic> toJson() => _$VoiceToJson(this);

  VoiceModel toDomain() => VoiceModel(
    voiceId: voiceId,
    name: name,
    category: category.toDomain(),
    fineTuning: fineTuning.toDomain(),
    labels: labels.toDomain(),
    description: description,
    previewUrl: previewUrl,
    verifiedLanguages: verifiedLanguages.map((e) => e.toDomain()).toList(),
  );
}

enum Category {
  @JsonValue("premade")
  PREMADE,
  @JsonValue("professional")
  PROFESSIONAL,
}

extension CategoryExtension on Category {
  CategoryModel toDomain() {
    switch (this) {
      case Category.PREMADE:
        return CategoryModel.PREMADE;
      case Category.PROFESSIONAL:
        return CategoryModel.PROFESSIONAL;
    }
  }
}

final categoryValues = EnumValues({
  "premade": Category.PREMADE,
  "professional": Category.PROFESSIONAL,
});

@JsonSerializable()
class FineTuning {
  @JsonKey(name: "language")
  Language? language;

  FineTuning({required this.language});

  FineTuningModel toDomain() => FineTuningModel(language: language?.toDomain());

  factory FineTuning.fromJson(Map<String, dynamic> json) =>
      _$FineTuningFromJson(json);

  Map<String, dynamic> toJson() => _$FineTuningToJson(this);
}

enum Language {
  @JsonValue("en")
  EN,
}

extension LanguageExtension on Language {
  LanguageModel toDomain() {
    switch (this) {
      case Language.EN:
        return LanguageModel.EN;
    }
  }
}

final languageValues = EnumValues({"en": Language.EN});

@JsonSerializable()
class Labels {
  @JsonKey(name: "use_case")
  String useCase;
  @JsonKey(name: "gender")
  Gender gender;
  @JsonKey(name: "accent")
  Accent accent;
  @JsonKey(name: "age")
  Age age;
  @JsonKey(name: "language")
  Language language;
  @JsonKey(name: "descriptive")
  String? descriptive;
  @JsonKey(name: "locale")
  String? locale;

  Labels({
    required this.useCase,
    required this.gender,
    required this.accent,
    required this.age,
    required this.language,
    this.descriptive,
    this.locale,
  });

  LabelModel toDomain() => LabelModel(
    useCase: useCase,
    gender: gender.toDomain(),
    accent: accent.toDomain(),
    age: age.toDomain(),
    language: language.toDomain(),
    descriptive: descriptive,
    locale: locale,
  );

  factory Labels.fromJson(Map<String, dynamic> json) => _$LabelsFromJson(json);

  Map<String, dynamic> toJson() => _$LabelsToJson(this);
}

enum Accent {
  @JsonValue("american")
  AMERICAN,
  @JsonValue("australian")
  AUSTRALIAN,
  @JsonValue("brazilian")
  BRAZILIAN,
  @JsonValue("british")
  BRITISH,
  @JsonValue("central")
  CENTRAL,
  @JsonValue("northern")
  NORTHERN,
  @JsonValue("peninsular")
  PENINSULAR,
  @JsonValue("southern")
  SOUTHERN,
  @JsonValue("standard")
  STANDARD,
}

extension AccentExtension on Accent {
  AccentModel toDomain() {
    switch (this) {
      case Accent.AMERICAN:
        return AccentModel.AMERICAN;
      case Accent.AUSTRALIAN:
        return AccentModel.AUSTRALIAN;
      case Accent.BRAZILIAN:
        return AccentModel.BRAZILIAN;
      case Accent.BRITISH:
        return AccentModel.BRITISH;
      case Accent.CENTRAL:
        return AccentModel.CENTRAL;
      case Accent.NORTHERN:
        return AccentModel.NORTHERN;
      case Accent.PENINSULAR:
        return AccentModel.PENINSULAR;
      case Accent.SOUTHERN:
        return AccentModel.SOUTHERN;
      case Accent.STANDARD:
        return AccentModel.STANDARD;
    }
  }
}

final accentValues = EnumValues({
  "american": Accent.AMERICAN,
  "australian": Accent.AUSTRALIAN,
  "brazilian": Accent.BRAZILIAN,
  "british": Accent.BRITISH,
  "central": Accent.CENTRAL,
  "northern": Accent.NORTHERN,
  "peninsular": Accent.PENINSULAR,
  "southern": Accent.SOUTHERN,
  "standard": Accent.STANDARD,
});

enum Age {
  @JsonValue("middle_aged")
  MIDDLE_AGED,
  @JsonValue("old")
  OLD,
  @JsonValue("young")
  YOUNG,
}

extension AgeExtension on Age {
  AgeModel toDomain() {
    switch (this) {
      case Age.MIDDLE_AGED:
        return AgeModel.MIDDLE_AGED;
      case Age.OLD:
        return AgeModel.OLD;
      case Age.YOUNG:
        return AgeModel.YOUNG;
    }
  }
}

final ageValues = EnumValues({
  "middle_aged": Age.MIDDLE_AGED,
  "old": Age.OLD,
  "young": Age.YOUNG,
});

enum Gender {
  @JsonValue("female")
  FEMALE,
  @JsonValue("male")
  MALE,
  @JsonValue("neutral")
  NEUTRAL,
}

extension GenderExtension on Gender {
  GenderModel toDomain() {
    switch (this) {
      case Gender.FEMALE:
        return GenderModel.FEMALE;
      case Gender.MALE:
        return GenderModel.MALE;
      case Gender.NEUTRAL:
        return GenderModel.NEUTRAL;
    }
  }
}

final genderValues = EnumValues({
  "female": Gender.FEMALE,
  "male": Gender.MALE,
  "neutral": Gender.NEUTRAL,
});

@JsonSerializable()
class VerifiedLanguage {
  @JsonKey(name: "language")
  String language;
  @JsonKey(name: "model_id")
  String modelId;
  @JsonKey(name: "accent")
  Accent? accent;
  @JsonKey(name: "locale")
  String? locale;
  @JsonKey(name: "preview_url")
  String previewUrl;

  VerifiedLanguage({
    required this.language,
    required this.modelId,
    required this.accent,
    required this.locale,
    required this.previewUrl,
  });

  VerifiedLanguageModel toDomain() => VerifiedLanguageModel(
    language: language,
    modelId: modelId,
    accent: accent?.toDomain(),
    locale: locale,
    previewUrl: previewUrl,
  );

  factory VerifiedLanguage.fromJson(Map<String, dynamic> json) =>
      _$VerifiedLanguageFromJson(json);

  Map<String, dynamic> toJson() => _$VerifiedLanguageToJson(this);
}

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
