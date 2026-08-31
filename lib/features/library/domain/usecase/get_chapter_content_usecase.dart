import 'package:stela_mobile/core/domain/api_response/api_result.dart';
import 'package:stela_mobile/core/domain/use_case/use_case.dart';
import 'package:stela_mobile/features/library/domain/models/chapter_content.dart';
import 'package:stela_mobile/features/library/domain/repository/stories_repository.dart';

class GetChapterContentUseCase
    implements UseCase<ChapterContent, GetChapterContentParams> {
  final StoriesRepository _repository;

  GetChapterContentUseCase(this._repository);

  @override
  Future<ApiResult<ChapterContent>> invoke() {
    return _repository.getChapterContent(
      storyId: param.storyId,
      chapterId: param.chapterId,
    );
  }

  @override
  late GetChapterContentParams param;
}

class GetChapterContentParams {
  final String storyId;
  final String chapterId;

  GetChapterContentParams({
    required this.storyId,
    required this.chapterId,
  });
}
