import 'package:stela_mobile/core/domain/api_response/api_result.dart';
import 'package:stela_mobile/core/domain/use_case/use_case.dart';
import 'package:stela_mobile/features/profile/domain/models/streak_info.dart';
import 'package:stela_mobile/features/profile/domain/repository/profile_repository.dart';

class GetStreakUseCase implements UseCase<StreakInfo, NoParams> {
  final ProfileRepository _repository;

  GetStreakUseCase(this._repository);

  @override
  Future<ApiResult<StreakInfo>> invoke() {
    return _repository.getStreak();
  }

  @override
  NoParams get param => const NoParams();
}
