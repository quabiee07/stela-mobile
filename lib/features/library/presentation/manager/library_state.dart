import 'package:equatable/equatable.dart';
import 'package:stela_mobile/features/dashboard/presentation/utils/story_sections.dart';
import 'package:stela_mobile/features/library/domain/models/story_detail.dart';
import 'package:stela_mobile/features/library/domain/models/story_summary.dart';

class LibraryState extends Equatable {
  const LibraryState({
    this.stories = const [],
    this.selectedStory,
    this.searchQuery = '',
    this.selectedGenre = 'All',
    this.isLoading = false,
    this.isLoadingDetail = false,
  });

  final List<StorySummary> stories;
  final StoryDetail? selectedStory;
  final String searchQuery;
  final String selectedGenre;
  final bool isLoading;
  final bool isLoadingDetail;

  List<StorySummary> get filteredStories {
    final query = searchQuery.trim().toLowerCase();
    return stories.where((story) {
      final matchesSearch = query.isEmpty ||
          story.title.toLowerCase().contains(query) ||
          story.description.toLowerCase().contains(query) ||
          story.genre.toLowerCase().contains(query);
      final matchesGenre = selectedGenre == 'All' ||
          formatGenreLabel(story.genre) == selectedGenre;
      return matchesSearch && matchesGenre;
    }).toList();
  }

  List<String> get genres => extractGenres(stories);

  Map<String, List<StorySummary>> get storiesByGenre {
    final grouped = <String, List<StorySummary>>{};
    for (final story in filteredStories) {
      final genre = formatGenreLabel(story.genre);
      grouped.putIfAbsent(genre, () => []).add(story);
    }

    final sortedKeys = grouped.keys.toList()..sort();
    return {for (final key in sortedKeys) key: grouped[key]!};
  }

  bool get hasActiveFilters =>
      searchQuery.trim().isNotEmpty || selectedGenre != 'All';

  LibraryState copyWith({
    List<StorySummary>? stories,
    StoryDetail? selectedStory,
    bool clearSelectedStory = false,
    String? searchQuery,
    String? selectedGenre,
    bool? isLoading,
    bool? isLoadingDetail,
  }) {
    return LibraryState(
      stories: stories ?? this.stories,
      selectedStory:
          clearSelectedStory ? null : (selectedStory ?? this.selectedStory),
      searchQuery: searchQuery ?? this.searchQuery,
      selectedGenre: selectedGenre ?? this.selectedGenre,
      isLoading: isLoading ?? this.isLoading,
      isLoadingDetail: isLoadingDetail ?? this.isLoadingDetail,
    );
  }

  @override
  List<Object?> get props => [
        stories,
        selectedStory,
        searchQuery,
        selectedGenre,
        isLoading,
        isLoadingDetail,
      ];
}
