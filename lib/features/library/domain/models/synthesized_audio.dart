import 'dart:typed_data';

class SynthesizedAudio {
  final Uint8List bytes;
  final List<String> characters;
  final List<double> characterStartTimesSeconds;
  final List<double> characterEndTimesSeconds;

  const SynthesizedAudio({
    required this.bytes,
    this.characters = const [],
    this.characterStartTimesSeconds = const [],
    this.characterEndTimesSeconds = const [],
  });

  bool get hasAlignment =>
      characters.isNotEmpty &&
      characters.length == characterStartTimesSeconds.length &&
      characters.length == characterEndTimesSeconds.length;
}
