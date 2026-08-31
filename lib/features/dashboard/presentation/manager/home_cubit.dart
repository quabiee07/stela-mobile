import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:stela_mobile/core/di/core_module_container.dart';
import 'package:stela_mobile/core/presentation/utils/helper_functions.dart';
import 'package:stela_mobile/core/presentation/utils/navigation_mixin.dart';
import 'package:stela_mobile/features/dashboard/domain/repository/home_repository.dart';
import 'package:stela_mobile/features/dashboard/domain/usecases/save_token_usecase.dart';
import 'package:stela_mobile/features/dashboard/presentation/manager/home_state.dart';
import 'package:stela_mobile/features/dashboard/presentation/utils/story_sections.dart';
import 'package:stela_mobile/features/library/data/services/reading_progress_service.dart';
import 'package:stela_mobile/features/library/domain/models/reading_progress.dart';
import 'package:stela_mobile/features/library/domain/models/story_reading_context.dart';
import 'package:stela_mobile/features/library/domain/models/story_summary.dart';
import 'package:stela_mobile/features/library/domain/repository/stories_repository.dart';
import 'package:stela_mobile/features/library/domain/usecase/get_stories_usecase.dart';
import 'package:stela_mobile/features/library/domain/usecase/get_story_detail_usecase.dart';
import 'package:stela_mobile/features/library/presentation/screens/story_description.dart';
import 'package:stela_mobile/features/library/presentation/screens/story_detail.dart';
import 'package:stela_mobile/features/library/presentation/widgets/mini_player_bar.dart';

sealed class HomeEffect {
  const HomeEffect();
}

final class HomeErrorEffect extends HomeEffect {
  const HomeErrorEffect(this.message);
  final String message;
}

final class HomeTokenSavedEffect extends HomeEffect {
  const HomeTokenSavedEffect(this.message);
  final String message;
}

@lazySingleton
class HomeCubit extends Cubit<HomeState> {
  HomeCubit(
    this._repo,
    this._storiesRepo,
  ) : super(const HomeState()) {
    _readingProgressService = ReadingProgressService();
  }

  final HomeRepository _repo;
  final StoriesRepository _storiesRepo;
  late final ReadingProgressService _readingProgressService;
  final _effects = StreamController<HomeEffect>.broadcast();

  Stream<HomeEffect> get effects => _effects.stream;

  void setIndex(int index) => emit(state.copyWith(selectedIndex: index));

  void openLibraryTab() => setIndex(1);

  Future<void> loadStories() async {
    emit(state.copyWith(isLoadingStories: true));

    try {
      final storiesResult = await GetStoriesUseCase(_storiesRepo).invoke();
      final stories = storiesResult.getOrElse((error) {
        _effects.add(HomeErrorEffect(error.toString()));
        return <StorySummary>[];
      }) ?? <StorySummary>[];

      final continueReading = await _readingProgressService.getAll();
      final featuredStories = pickFeaturedStories(stories);
      final newStories = pickNewStories(
        stories: stories,
        continueReading: continueReading,
        featured: featuredStories,
      );

      emit(
        state.copyWith(
          stories: stories,
          featuredStories: featuredStories,
          continueReading: _mergeContinueReading(continueReading, stories),
          newStories: newStories,
          genres: extractGenres(stories),
          isLoadingStories: false,
        ),
      );
    } catch (e) {
      _effects.add(HomeErrorEffect(e.toString()));
      emit(state.copyWith(isLoadingStories: false));
    }
  }

  /// Local-only refresh after leaving the reader / mini-player. Avoids
  /// re-hitting `/stories` and gamification endpoints on every minimize.
  Future<void> refreshContinueReading() async {
    final continueReading = await _readingProgressService.getAll();
    final merged = _mergeContinueReading(continueReading, state.stories);
    final newStories = pickNewStories(
      stories: state.stories,
      continueReading: continueReading,
      featured: state.featuredStories,
    );

    emit(
      state.copyWith(
        continueReading: merged,
        newStories: newStories,
      ),
    );
  }

  List<ReadingProgress> _mergeContinueReading(
    List<ReadingProgress> saved,
    List<StorySummary> stories,
  ) {
    final storyMap = {for (final story in stories) story.storyId: story};

    return saved
        .map((item) {
          final latest = storyMap[item.storyId];
          if (latest == null) return item;
          return ReadingProgress(
            storyId: item.storyId,
            title: latest.title,
            coverImageUrl: latest.coverImageUrl,
            genre: latest.genre,
            readingTime: latest.readingTime,
            totalChapters: latest.totalChapters,
            chapterId: item.chapterId,
            chapterTitle: item.chapterTitle,
            chapterNumber: item.chapterNumber,
            progress: item.progress,
            lastReadAtMs: item.lastReadAtMs,
          );
        })
        .where((item) => !item.isComplete)
        .toList();
  }

  Future<void> loadUserGreeting() async {
    try {
      final user = await getCachedUser();
      if (user != null) {
        emit(
          state.copyWith(
            firstName: user.name,
            profilePicture: user.avatarUrl,
          ),
        );
      }
    } catch (e) {
      _effects.add(HomeErrorEffect(e.toString()));
      logg(e.toString());
    }
  }

  Future<void> getFirestoreUser() => loadUserGreeting();

  Future<void> saveToken() async {
    if (state.isSavingToken) return;
    emit(state.copyWith(isSavingToken: true));

    final result = await SaveTokenUseCase(_repo, state.payload).invoke();
    final value = result.getOrElse((error) {
      _effects.add(HomeErrorEffect(error.toString()));
      return null;
    });

    if (value != null) {
      _effects.add(HomeTokenSavedEffect(value.toString()));
    }
    emit(state.copyWith(isSavingToken: false));
  }

  void openStory(BuildContext context, String storyId) {
    context.push(StoryDescriptionScreen(storyId: storyId));
  }

  Future<void> resumeReading(
    BuildContext context,
    ReadingProgress progress,
  ) async {
    if (state.isResumingStory) return;
    emit(state.copyWith(isResumingStory: true));

    try {
      final useCase = GetStoryDetailUseCase(_storiesRepo)
        ..param = progress.storyId;
      final value = await useCase.invoke();
      final detail = value.getOrElse((error) {
        _effects.add(HomeErrorEffect(error.toString()));
        return null;
      });

      if (detail == null || detail.chapters.isEmpty) {
        if (context.mounted) {
          openStory(context, progress.storyId);
        }
        return;
      }

      final chapter = detail.chapters.firstWhere(
        (item) => item.chapterId == progress.chapterId,
        orElse: () => detail.chapters.first,
      );

      if (!context.mounted) return;
      context.pushStoryDetail(
        StoryDetailScreen(
          readingContext: StoryReadingContext(
            storyId: detail.storyId,
            storyTitle: detail.title,
            genre: detail.genre,
            chapterId: chapter.chapterId,
            chapterTitle: chapter.title,
            chapterNumber: chapter.chapterNumber,
            totalChapters: detail.totalChapters,
            chapters: detail.chapters,
            coverImageUrl: detail.coverImageUrl,
            readingTime: detail.readingTime,
          ),
        ),
      );
    } catch (e) {
      _effects.add(HomeErrorEffect(e.toString()));
    } finally {
      emit(state.copyWith(isResumingStory: false));
    }
  }

  @override
  Future<void> close() {
    _effects.close();
    return super.close();
  }
}

HomeCubit get homeCubit => getIt.get<HomeCubit>();
