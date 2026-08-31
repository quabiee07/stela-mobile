import 'package:stela_mobile/features/dashboard/domain/models/story.dart';
import 'package:stela_mobile/features/library/domain/models/age_range.dart';
import 'package:stela_mobile/features/library/domain/models/story_summary.dart';

StorySummary mapStoryToSummary(Story story) {
  return StorySummary(
    storyId: story.id,
    title: story.title,
    genre: story.category,
    description: story.fullText,
    coverImageUrl: story.coverImage,
    readingTime: _parseReadingTime(story.readTime),
    totalChapters: 1,
    ageRange: const AgeRange(min: 5, max: 12),
  );
}

int _parseReadingTime(String readTime) {
  final match = RegExp(r'\d+').firstMatch(readTime);
  return int.tryParse(match?.group(0) ?? '') ?? 5;
}
