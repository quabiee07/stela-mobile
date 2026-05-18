class TtsPayload {
  final String text;
  final String modelId;
  final VoiceSettings voiceSettings;

  const TtsPayload({
    required this.text,
    this.modelId = 'eleven_turbo_v2_5',
    this.voiceSettings = const VoiceSettings(),
  });
}

class VoiceSettings {
  final double stability;
  final double similarityBoost;
  final double style;
  final bool useSpeakerBoost;

  const VoiceSettings({
    this.stability = 0.5,
    this.similarityBoost = 0.75,
    this.style = 0.3,
    this.useSpeakerBoost = true,
  });
}
