import 'package:stela_mobile/core/domain/api_response/api_result.dart';
import 'package:stela_mobile/core/domain/use_case/use_case.dart';
import 'package:stela_mobile/features/profile/domain/models/user_badge.dart';
import 'package:stela_mobile/features/profile/domain/repository/profile_repository.dart';

class GetBadgesUseCase implements UseCase<List<UserBadge>, NoParams> {
  final ProfileRepository _repository;

  GetBadgesUseCase(this._repository);

  @override
  Future<ApiResult<List<UserBadge>>> invoke() {
    return _repository.getBadges();
  }

  @override
  NoParams get param => const NoParams();
}
