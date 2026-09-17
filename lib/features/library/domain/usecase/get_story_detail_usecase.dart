import 'package:stela_mobile/core/domain/api_response/api_result.dart';
import 'package:stela_mobile/core/domain/use_case/use_case.dart';
import 'package:stela_mobile/features/library/domain/models/story_detail.dart';
import 'package:stela_mobile/features/library/domain/repository/stories_repository.dart';

class GetStoryDetailUseCase implements UseCase<StoryDetail, String> {
  GetStoryDetailUseCase(this._repository, {this.force = false});

  final StoriesRepository _repository;
  final bool force;

  @override
  Future<ApiResult<StoryDetail>> invoke() {
    return _repository.getStoryDetail(param, force: force);
  }

  @override
  late String param;
}
