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

enum CategoryModel { PREMADE, PROFESSIONAL, UNKNOWN }

class FineTuningModel {
  LanguageModel? language;

  FineTuningModel({required this.language});
}

enum LanguageModel { EN, UNKNOWN }

class LabelModel {
  String useCase;
  GenderModel gender;
  /// Free-form accent label from ElevenLabs (e.g. "american", "latin american").
  String accent;
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

enum AgeModel { MIDDLE_AGED, OLD, YOUNG, UNKNOWN }

enum GenderModel { FEMALE, MALE, NEUTRAL }

class VerifiedLanguageModel {
  String language;
  String modelId;
  String? accent;
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
