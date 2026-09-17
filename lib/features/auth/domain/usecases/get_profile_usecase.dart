import 'package:stela_mobile/core/domain/api_response/api_result.dart';
import 'package:stela_mobile/core/domain/use_case/use_case.dart';
import 'package:stela_mobile/features/auth/domain/models/user_profile.dart';
import 'package:stela_mobile/features/auth/domain/repository/auth_repository.dart';

class GetProfileUseCase implements UseCase<UserProfile, NoParams> {
  GetProfileUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<ApiResult<UserProfile>> invoke() {
    return _repository.getProfile();
  }

  @override
  NoParams get param => const NoParams();
}
