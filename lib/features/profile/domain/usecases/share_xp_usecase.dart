import 'package:stela_mobile/core/domain/api_response/api_result.dart';
import 'package:stela_mobile/core/domain/models/generic_model.dart';
import 'package:stela_mobile/core/domain/use_case/use_case.dart';
import 'package:stela_mobile/features/profile/domain/repository/profile_repository.dart';

class ShareXpUseCase implements UseCase<GenericModel, NoParams> {
  final ProfileRepository _repository;

  ShareXpUseCase(this._repository);

  @override
  Future<ApiResult<GenericModel>> invoke() {
    return _repository.shareXp();
  }

  @override
  NoParams get param => const NoParams();
}
