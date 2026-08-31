class ChapterSummary {
  final String chapterId;
  final int chapterNumber;
  final String title;
  final int wordCount;
  final String? imageUrl;

  const ChapterSummary({
    required this.chapterId,
    required this.chapterNumber,
    required this.title,
    required this.wordCount,
    this.imageUrl,
  });
}
