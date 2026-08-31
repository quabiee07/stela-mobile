class ReadingProgress {
  final String storyId;
  final String title;
  final String coverImageUrl;
  final String genre;
  final int readingTime;
  final int totalChapters;
  final String chapterId;
  final String chapterTitle;
  final int chapterNumber;
  final double progress;
  final int lastReadAtMs;

  const ReadingProgress({
    required this.storyId,
    required this.title,
    required this.coverImageUrl,
    required this.genre,
    required this.readingTime,
    required this.totalChapters,
    required this.chapterId,
    required this.chapterTitle,
    required this.chapterNumber,
    required this.progress,
    required this.lastReadAtMs,
  });

  bool get isComplete =>
      progress >= 1.0 ||
      (totalChapters > 0 &&
          chapterNumber >= totalChapters &&
          progress >= 0.99);

  int get progressPercent => (progress * 100).clamp(0, 100).round();

  int get minutesLeft {
    final remaining = ((1 - progress) * readingTime).round();
    return remaining < 1 ? 1 : remaining;
  }

  String get timeLabel => '$minutesLeft min left';

  Map<String, dynamic> toJson() => {
        'storyId': storyId,
        'title': title,
        'coverImageUrl': coverImageUrl,
        'genre': genre,
        'readingTime': readingTime,
        'totalChapters': totalChapters,
        'chapterId': chapterId,
        'chapterTitle': chapterTitle,
        'chapterNumber': chapterNumber,
        'progress': progress,
        'lastReadAtMs': lastReadAtMs,
      };

  factory ReadingProgress.fromJson(Map<String, dynamic> json) {
    return ReadingProgress(
      storyId: json['storyId'] as String,
      title: json['title'] as String,
      coverImageUrl: json['coverImageUrl'] as String? ?? '',
      genre: json['genre'] as String? ?? '',
      readingTime: (json['readingTime'] as num?)?.toInt() ?? 0,
      totalChapters: (json['totalChapters'] as num?)?.toInt() ?? 1,
      chapterId: json['chapterId'] as String,
      chapterTitle: json['chapterTitle'] as String? ?? '',
      chapterNumber: (json['chapterNumber'] as num?)?.toInt() ?? 1,
      progress: (json['progress'] as num?)?.toDouble() ?? 0,
      lastReadAtMs: (json['lastReadAtMs'] as num?)?.toInt() ?? 0,
    );
  }
}
