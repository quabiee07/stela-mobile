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

  const StorySummary({
    required this.storyId,
    required this.title,
    required this.genre,
    required this.description,
    required this.coverImageUrl,
    required this.readingTime,
    required this.totalChapters,
    required this.ageRange,
  });

  String get tags => '${formatGenreLabel(genre)} · Ages ${ageRange.min}-${ageRange.max}';

  String get readTime => '$readingTime min read';
}
