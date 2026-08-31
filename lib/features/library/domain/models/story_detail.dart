import 'package:stela_mobile/features/library/domain/models/chapter_summary.dart';
import 'package:stela_mobile/features/library/domain/models/story_summary.dart';

class StoryDetail extends StorySummary {
  final List<ChapterSummary> chapters;

  const StoryDetail({
    required super.storyId,
    required super.title,
    required super.genre,
    required super.description,
    required super.coverImageUrl,
    required super.readingTime,
    required super.totalChapters,
    required super.ageRange,
    required this.chapters,
  });
}
