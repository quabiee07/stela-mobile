import 'package:stela_mobile/features/library/domain/models/chapter_summary.dart';

class StoryReadingContext {
  final String storyId;
  final String storyTitle;
  final String genre;
  final String chapterId;
  final String chapterTitle;
  final int chapterNumber;
  final int totalChapters;
  final List<ChapterSummary> chapters;
  final String? prefetchedText;
  final String coverImageUrl;
  final int readingTime;

  const StoryReadingContext({
    required this.storyId,
    required this.storyTitle,
    required this.genre,
    required this.chapterId,
    required this.chapterTitle,
    required this.chapterNumber,
    required this.totalChapters,
    required this.chapters,
    this.prefetchedText,
    this.coverImageUrl = '',
    this.readingTime = 0,
  });

  int get currentChapterIndex {
    final index = chapters.indexWhere((chapter) => chapter.chapterId == chapterId);
    return index < 0 ? 0 : index;
  }

  ChapterSummary? get previousChapter {
    final prevIndex = currentChapterIndex - 1;
    if (prevIndex < 0) return null;
    return chapters[prevIndex];
  }

  ChapterSummary? get nextChapter {
    final nextIndex = currentChapterIndex + 1;
    if (nextIndex >= chapters.length) return null;
    return chapters[nextIndex];
  }

  bool get isLastChapter => currentChapterIndex >= chapters.length - 1;

  String get currentChapterImageUrl {
    if (chapters.isEmpty) return coverImageUrl;
    final url = chapters[currentChapterIndex].imageUrl;
    if (url != null && url.isNotEmpty) return url;
    return coverImageUrl;
  }

  StoryReadingContext copyWithChapter(ChapterSummary chapter) {
    return StoryReadingContext(
      storyId: storyId,
      storyTitle: storyTitle,
      genre: genre,
      chapterId: chapter.chapterId,
      chapterTitle: chapter.title,
      chapterNumber: chapter.chapterNumber,
      totalChapters: totalChapters,
      chapters: chapters,
      coverImageUrl: coverImageUrl,
      readingTime: readingTime,
    );
  }
}
