/// Helpers for story narration text / lyric alignment.
class TtsAudioUtils {
  /// Lyric lines for karaoke UI (sentence-level splits).
  static List<String> splitLyricLines(String text) {
    return text
        .replaceAllMapped(
          RegExp(r'([.!?,])\s+'),
          (match) => '${match.group(1)}|~|',
        )
        .split('|~|')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();
  }
}
