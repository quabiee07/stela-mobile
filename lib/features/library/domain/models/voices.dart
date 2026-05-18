class VoicesModel {
  List<VoiceModel> voices;

  VoicesModel({required this.voices});
}

class VoiceModel {
  String voiceId;
  String name;
  CategoryModel category;
  FineTuningModel fineTuning;
  LabelModel labels;
  String description;
  String previewUrl;
  List<VerifiedLanguageModel> verifiedLanguages;

  VoiceModel({
    required this.voiceId,
    required this.name,
    required this.category,
    required this.fineTuning,
    required this.labels,
    required this.description,
    required this.previewUrl,
    required this.verifiedLanguages,
  });
}

enum CategoryModel { PREMADE, PROFESSIONAL }

class FineTuningModel {
  LanguageModel? language;

  FineTuningModel({required this.language});
}

enum LanguageModel { EN }

class LabelModel {
  String useCase;
  GenderModel gender;
  AccentModel accent;
  AgeModel age;
  LanguageModel language;
  String? descriptive;
  String? locale;

  LabelModel({
    required this.useCase,
    required this.gender,
    required this.accent,
    required this.age,
    required this.language,
    this.descriptive,
    this.locale,
  });
}

enum AccentModel {
  AMERICAN,
  AUSTRALIAN,
  BRAZILIAN,
  BRITISH,
  CENTRAL,
  NORTHERN,
  PENINSULAR,
  SOUTHERN,
  STANDARD,
}

enum AgeModel { MIDDLE_AGED, OLD, YOUNG }

enum GenderModel { FEMALE, MALE, NEUTRAL }

class VerifiedLanguageModel {
  String language;
  String modelId;
  AccentModel? accent;
  String? locale;
  String previewUrl;

  VerifiedLanguageModel({
    required this.language,
    required this.modelId,
    required this.accent,
    required this.locale,
    required this.previewUrl,
  });
}
