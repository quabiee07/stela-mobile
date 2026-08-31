import 'package:stela_mobile/features/library/domain/models/reading_progress.dart';
import 'package:stela_mobile/features/library/domain/models/story_summary.dart';

String formatGenreLabel(String genre) {
  if (genre.isEmpty) return 'Stories';
  return genre
      .split(RegExp(r'[-_\s]+'))
      .where((part) => part.isNotEmpty)
      .map(
        (part) =>
            '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}',
      )
      .join(' ');
}

List<StorySummary> pickFeaturedStories(List<StorySummary> stories) {
  if (stories.isEmpty) return [];
  if (stories.length <= 3) return stories;

  final sorted = List<StorySummary>.from(stories)
    ..sort((a, b) => a.storyId.compareTo(b.storyId));

  final daySeed = DateTime.now().day + DateTime.now().month * 31;
  final start = daySeed % (sorted.length - 2);
  return sorted.sublist(start, start + 3);
}

List<StorySummary> pickNewStories({
  required List<StorySummary> stories,
  required List<ReadingProgress> continueReading,
  required List<StorySummary> featured,
}) {
  if (stories.isEmpty) return [];

  final featuredIds = featured.map((story) => story.storyId).toSet();
  final startedIds = continueReading.map((item) => item.storyId).toSet();

  final untouched = stories
      .where(
        (story) =>
            !startedIds.contains(story.storyId) &&
            !featuredIds.contains(story.storyId),
      )
      .toList()
    ..sort((a, b) => a.readingTime.compareTo(b.readingTime));

  if (untouched.length >= 4) return untouched;

  final fallback = stories
      .where((story) => !featuredIds.contains(story.storyId))
      .toList()
    ..sort((a, b) => b.totalChapters.compareTo(a.totalChapters));

  final merged = <StorySummary>[];
  final seen = <String>{};

  for (final story in [...untouched, ...fallback]) {
    if (seen.add(story.storyId)) {
      merged.add(story);
    }
  }

  return merged;
}

List<String> extractGenres(List<StorySummary> stories) {
  final genres = stories.map((story) => formatGenreLabel(story.genre)).toSet();
  final sorted = genres.toList()..sort();
  return ['All', ...sorted];
}
