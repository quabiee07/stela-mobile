import 'package:stela_mobile/core/domain/api_response/api_result.dart';
import 'package:stela_mobile/core/domain/use_case/use_case.dart';
import 'package:stela_mobile/features/library/domain/models/story_summary.dart';
import 'package:stela_mobile/features/library/domain/repository/stories_repository.dart';

class GetStoriesParams {
  const GetStoriesParams({this.force = false});
  final bool force;
}

class GetStoriesUseCase implements UseCase<List<StorySummary>, GetStoriesParams> {
  GetStoriesUseCase(this._repository, {bool force = false})
      : param = GetStoriesParams(force: force);

  final StoriesRepository _repository;

  @override
  final GetStoriesParams param;

  @override
  Future<ApiResult<List<StorySummary>>> invoke() {
    return _repository.getStories(force: param.force);
  }
}
