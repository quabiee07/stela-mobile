class Story {
  final String id;
  final String title;
  final String author;
  final String coverImage;
  final String tags;
  final String readTime;
  final String category;
  final double readPercentage;
  final String fullText;
  final String currentChapter;
  final String pageInfo;

  const Story({
    required this.id,
    required this.title,
    required this.author,
    required this.coverImage,
    required this.tags,
    required this.readTime,
    required this.category,
    this.readPercentage = 0.0,
    required this.fullText,
    required this.currentChapter,
    required this.pageInfo,
  });
}

