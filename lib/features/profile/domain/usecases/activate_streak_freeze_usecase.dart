import 'package:stela_mobile/core/domain/api_response/api_result.dart';
import 'package:stela_mobile/core/domain/use_case/use_case.dart';
import 'package:stela_mobile/features/profile/domain/models/streak_info.dart';
import 'package:stela_mobile/features/profile/domain/repository/profile_repository.dart';

class ActivateStreakFreezeUseCase
    implements UseCase<StreakFreezeResult, NoParams> {
  final ProfileRepository _repository;

  ActivateStreakFreezeUseCase(this._repository);

  @override
  Future<ApiResult<StreakFreezeResult>> invoke() {
    return _repository.activateStreakFreeze();
  }

  @override
  NoParams get param => const NoParams();
}
