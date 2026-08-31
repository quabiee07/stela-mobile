/// Curated ElevenLabs narrator voices for Stela (male + female storytellers).
enum NarratorGender { male, female }

class NarratorVoice {
  const NarratorVoice({
    required this.id,
    required this.name,
    required this.gender,
    required this.description,
    this.previewUrl,
    this.avatarAsset,
    this.accentColor = 0xFFF3ABA7,
  });

  final String id;
  final String name;
  final NarratorGender gender;
  final String description;

  /// Optional hosted sample. Filled/overridden when [GET /v1/voices] is loaded.
  final String? previewUrl;

  /// Optional onboarding/settings avatar asset path.
  final String? avatarAsset;

  /// ARGB color behind the avatar circle.
  final int accentColor;

  NarratorVoice copyWith({
    String? previewUrl,
    String? avatarAsset,
    int? accentColor,
  }) {
    return NarratorVoice(
      id: id,
      name: name,
      gender: gender,
      description: description,
      previewUrl: previewUrl ?? this.previewUrl,
      avatarAsset: avatarAsset ?? this.avatarAsset,
      accentColor: accentColor ?? this.accentColor,
    );
  }
}

/// Hand-picked Stela narrator voices (ElevenLabs voice IDs).
abstract final class NarratorVoiceCatalog {
  /// Default narrator — Noah.
  static const defaultVoiceId = 'GoGUcAZovo4MFeLxJdZd';

  static const List<NarratorVoice> all = [
    // ── Female ──────────────────────────────────────────────────────────────
    NarratorVoice(
      id: 'GZ4PpFJV8ikEGUtBrjK7',
      name: 'Laura',
      gender: NarratorGender.female,
      description: 'Calm and clear',
      avatarAsset: 'assets/images/avatar1.png',
      accentColor: 0xFFF3ABA7,
    ),
    NarratorVoice(
      id: 'hbB2qXyS2GMyyZIZyhAH',
      name: 'Bella',
      gender: NarratorGender.female,
      description: 'Warm and engaging',
      avatarAsset: 'assets/images/avatar5.png',
      accentColor: 0xFFB8D4F0,
    ),
    NarratorVoice(
      id: 'D9xwB6HNBJ9h4YvQFWuE',
      name: 'Tobi',
      gender: NarratorGender.female,
      description: 'Expressive and youthful',
      avatarAsset: 'assets/images/female_avatar.png',
      accentColor: 0xFFE8C9A8,
    ),
    // ── Male ────────────────────────────────────────────────────────────────
    NarratorVoice(
      id: 'iLzHtPh0bW6RGWRG0Xo5',
      name: 'John',
      gender: NarratorGender.male,
      description: 'Deep and steady',
      avatarAsset: 'assets/images/avatar4.png',
      accentColor: 0xFFC5B6E8,
    ),
    NarratorVoice(
      id: defaultVoiceId,
      name: 'Noah',
      gender: NarratorGender.male,
      description: 'Well rounded narrator',
      avatarAsset: 'assets/images/avatar2.png',
      accentColor: 0xFFB8E0C8,
    ),
    NarratorVoice(
      id: 'L1aJrPa7pLJEyYlh3Ilq',
      name: 'Oliver',
      gender: NarratorGender.male,
      description: 'Calm and clear',
      avatarAsset: 'assets/images/avatar3.png',
      accentColor: 0xFF8BA3C7,
    ),
  ];

  static List<NarratorVoice> byGender(NarratorGender gender) =>
      all.where((voice) => voice.gender == gender).toList(growable: false);

  static NarratorVoice? findById(String id) {
    for (final voice in all) {
      if (voice.id == id) return voice;
    }
    return null;
  }

  static NarratorVoice get defaultVoice =>
      findById(defaultVoiceId) ?? all.first;
}
