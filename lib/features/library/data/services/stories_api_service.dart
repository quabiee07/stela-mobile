import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:stela_mobile/core/domain/utils/constants.dart';
import 'package:stela_mobile/features/library/data/dto/chapter_content_dto.dart';
import 'package:stela_mobile/features/library/data/dto/story_detail_dto.dart';
import 'package:stela_mobile/features/library/data/dto/story_summary_dto.dart';

part 'stories_api_service.g.dart';

@RestApi(baseUrl: stelaBaseUrl)
abstract class StoriesApiService {
  factory StoriesApiService(Dio dio, {String baseUrl}) = _StoriesApiService;

  @GET('stories')
  Future<List<StorySummaryDto>> getStories();

  @GET('stories/{storyId}')
  Future<StoryDetailDto> getStoryDetail({
    @Path('storyId') required String storyId,
  });

  @GET('stories/{storyId}/chapters/{chapterId}')
  Future<ChapterContentDto> getChapterContent({
    @Path('storyId') required String storyId,
    @Path('chapterId') required String chapterId,
  });
}
