import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:stela_mobile/core/di/core_module_container.dart';
import 'package:stela_mobile/features/library/domain/repository/stories_repository.dart';
import 'package:stela_mobile/features/library/domain/usecase/get_chapter_content_usecase.dart';
import 'package:stela_mobile/features/library/domain/usecase/get_stories_usecase.dart';
import 'package:stela_mobile/features/library/domain/usecase/get_story_detail_usecase.dart';
import 'package:stela_mobile/features/library/presentation/manager/library_state.dart';

sealed class LibraryEffect {
  const LibraryEffect();
}

final class LibraryErrorEffect extends LibraryEffect {
  const LibraryErrorEffect(this.message);
  final String message;
}

@lazySingleton
class LibraryCubit extends Cubit<LibraryState> {
  LibraryCubit(this._repo) : super(const LibraryState());

  final StoriesRepository _repo;
  final _effects = StreamController<LibraryEffect>.broadcast();

  Stream<LibraryEffect> get effects => _effects.stream;

  Future<void> loadStories() async {
    emit(state.copyWith(isLoading: true));
    final value = await GetStoriesUseCase(_repo).invoke();
    final result = value.getOrElse((error) {
      _effects.add(LibraryErrorEffect(error.toString()));
      return null;
    });

    emit(
      state.copyWith(
        stories: result ?? const [],
        isLoading: false,
      ),
    );
  }

  void setSearchQuery(String query) =>
      emit(state.copyWith(searchQuery: query));

  void setSelectedGenre(String genre) =>
      emit(state.copyWith(selectedGenre: genre));

  void clearFilters() => emit(
        state.copyWith(searchQuery: '', selectedGenre: 'All'),
      );

  Future<void> loadStoryDetail(String storyId) async {
    emit(state.copyWith(isLoadingDetail: true, clearSelectedStory: true));

    final useCase = GetStoryDetailUseCase(_repo)..param = storyId;
    final value = await useCase.invoke();
    final result = value.getOrElse((error) {
      _effects.add(LibraryErrorEffect(error.toString()));
      return null;
    });

    emit(
      state.copyWith(
        selectedStory: result,
        isLoadingDetail: false,
      ),
    );
  }

  Future<String?> loadChapterText({
    required String storyId,
    required String chapterId,
  }) async {
    final useCase = GetChapterContentUseCase(_repo)
      ..param = GetChapterContentParams(
        storyId: storyId,
        chapterId: chapterId,
      );

    final value = await useCase.invoke();
    final result = value.getOrElse((error) {
      _effects.add(LibraryErrorEffect(error.toString()));
      return null;
    });

    return result?.fullText;
  }

  @override
  Future<void> close() {
    _effects.close();
    return super.close();
  }
}

LibraryCubit get libraryCubit => getIt.get<LibraryCubit>();
