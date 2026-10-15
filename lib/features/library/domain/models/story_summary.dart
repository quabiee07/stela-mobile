import 'package:stela_mobile/features/dashboard/presentation/utils/story_sections.dart';
import 'package:stela_mobile/features/library/domain/models/age_range.dart';

class StorySummary {
  final String storyId;
  final String title;
  final String genre;
  final String description;
  final String coverImageUrl;
  final int readingTime;
  final int totalChapters;
  final AgeRange ageRange;
  final String authorName;
  final String? authorPhotoUrl;

  const StorySummary({
    required this.storyId,
    required this.title,
    required this.genre,
    required this.description,
    required this.coverImageUrl,
    required this.readingTime,
    required this.totalChapters,
    required this.ageRange,
    this.authorName = '',
    this.authorPhotoUrl,
  });

  String get tags => formatGenreLabel(genre);

  String get readTime =>
      readingTime <= 0 ? 'Quick read' : '$readingTime min read';

  String get chaptersLabel {
    if (totalChapters <= 0) return 'Chapters coming soon';
    if (totalChapters == 1) return '1 chapter';
    return '$totalChapters chapters';
  }

  bool get hasAuthor => authorName.trim().isNotEmpty;
}
