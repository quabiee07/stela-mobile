import 'package:stela_mobile/core/domain/api_response/api_result.dart';
import 'package:stela_mobile/features/library/domain/models/chapter_content.dart';
import 'package:stela_mobile/features/library/domain/models/story_detail.dart';
import 'package:stela_mobile/features/library/domain/models/story_summary.dart';

abstract class StoriesRepository {
  Future<ApiResult<List<StorySummary>>> getStories();
  Future<ApiResult<StoryDetail>> getStoryDetail(String storyId);
  Future<ApiResult<ChapterContent>> getChapterContent({
    required String storyId,
    required String chapterId,
  });
}
