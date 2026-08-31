import 'package:stela_mobile/core/domain/api_response/api_result.dart';
import 'package:stela_mobile/core/domain/use_case/use_case.dart';
import 'package:stela_mobile/features/library/domain/models/story_detail.dart';
import 'package:stela_mobile/features/library/domain/repository/stories_repository.dart';

class GetStoryDetailUseCase implements UseCase<StoryDetail, String> {
  final StoriesRepository _repository;

  GetStoryDetailUseCase(this._repository);

  @override
  Future<ApiResult<StoryDetail>> invoke() {
    return _repository.getStoryDetail(param);
  }

  @override
  late String param;
}
