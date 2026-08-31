import 'package:stela_mobile/core/domain/api_response/api_result.dart';
import 'package:stela_mobile/core/domain/use_case/use_case.dart';
import 'package:stela_mobile/features/library/domain/models/story_summary.dart';
import 'package:stela_mobile/features/library/domain/repository/stories_repository.dart';

class GetStoriesUseCase implements UseCase<List<StorySummary>, NoParams> {
  final StoriesRepository _repository;

  GetStoriesUseCase(this._repository);

  @override
  Future<ApiResult<List<StorySummary>>> invoke() {
    return _repository.getStories();
  }

  @override
  NoParams get param => const NoParams();
}
