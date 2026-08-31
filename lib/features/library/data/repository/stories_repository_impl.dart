import 'package:injectable/injectable.dart';
import 'package:stela_mobile/core/domain/api_response/api_result.dart';
import 'package:stela_mobile/core/domain/errors/app_failure.dart';
import 'package:stela_mobile/features/library/data/services/stories_api_service.dart';
import 'package:stela_mobile/features/library/domain/models/chapter_content.dart';
import 'package:stela_mobile/features/library/domain/models/story_detail.dart';
import 'package:stela_mobile/features/library/domain/models/story_summary.dart';
import 'package:stela_mobile/features/library/domain/repository/stories_repository.dart';

@LazySingleton(as: StoriesRepository)
class StoriesRepositoryImpl implements StoriesRepository {
  StoriesRepositoryImpl(this._api);

  final StoriesApiService _api;

  @override
  Future<ApiResult<List<StorySummary>>> getStories() async {
    try {
      final result = await _api.getStories();
      return ApiResult.success(result.map((story) => story.toDto()).toList());
    } catch (e) {
      return ApiResult.failure(mapToAppFailure(e));
    }
  }

  @override
  Future<ApiResult<StoryDetail>> getStoryDetail(String storyId) async {
    try {
      final result = await _api.getStoryDetail(storyId: storyId);
      return ApiResult.success(result.toDto());
    } catch (e) {
      return ApiResult.failure(mapToAppFailure(e));
    }
  }

  @override
  Future<ApiResult<ChapterContent>> getChapterContent({
    required String storyId,
    required String chapterId,
  }) async {
    try {
      final result = await _api.getChapterContent(
        storyId: storyId,
        chapterId: chapterId,
      );
      return ApiResult.success(result.toDto());
    } catch (e) {
      return ApiResult.failure(mapToAppFailure(e));
    }
  }
}
