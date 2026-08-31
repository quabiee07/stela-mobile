import 'package:equatable/equatable.dart';
import 'package:stela_mobile/core/domain/utils/constants.dart';
import 'package:stela_mobile/features/dashboard/domain/models/dashboard_payload.dart';
import 'package:stela_mobile/features/library/domain/models/reading_progress.dart';
import 'package:stela_mobile/features/library/domain/models/story_summary.dart';

class HomeState extends Equatable {
  const HomeState({
    this.selectedIndex = 0,
    this.firstName = '',
    this.profilePicture = '',
    this.stories = const [],
    this.featuredStories = const [],
    this.continueReading = const [],
    this.newStories = const [],
    this.genres = const ['All'],
    this.isLoadingStories = true,
    this.isSavingToken = false,
    this.isResumingStory = false,
  });

  final int selectedIndex;
  final String firstName;
  final String profilePicture;
  final List<StorySummary> stories;
  final List<StorySummary> featuredStories;
  final List<ReadingProgress> continueReading;
  final List<StorySummary> newStories;
  final List<String> genres;
  final bool isLoadingStories;
  final bool isSavingToken;
  final bool isResumingStory;

  DashboardPayload get payload =>
      DashboardPayload(token: fcmToken ?? '', timezone: region);

  HomeState copyWith({
    int? selectedIndex,
    String? firstName,
    String? profilePicture,
    List<StorySummary>? stories,
    List<StorySummary>? featuredStories,
    List<ReadingProgress>? continueReading,
    List<StorySummary>? newStories,
    List<String>? genres,
    bool? isLoadingStories,
    bool? isSavingToken,
    bool? isResumingStory,
  }) {
    return HomeState(
      selectedIndex: selectedIndex ?? this.selectedIndex,
      firstName: firstName ?? this.firstName,
      profilePicture: profilePicture ?? this.profilePicture,
      stories: stories ?? this.stories,
      featuredStories: featuredStories ?? this.featuredStories,
      continueReading: continueReading ?? this.continueReading,
      newStories: newStories ?? this.newStories,
      genres: genres ?? this.genres,
      isLoadingStories: isLoadingStories ?? this.isLoadingStories,
      isSavingToken: isSavingToken ?? this.isSavingToken,
      isResumingStory: isResumingStory ?? this.isResumingStory,
    );
  }

  @override
  List<Object?> get props => [
        selectedIndex,
        firstName,
        profilePicture,
        stories,
        featuredStories,
        continueReading,
        newStories,
        genres,
        isLoadingStories,
        isSavingToken,
        isResumingStory,
      ];
}
