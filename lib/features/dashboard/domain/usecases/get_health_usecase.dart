import 'package:stela_mobile/core/domain/api_response/api_result.dart';
import 'package:stela_mobile/core/domain/use_case/use_case.dart';
import 'package:stela_mobile/features/dashboard/domain/models/health_status.dart';
import 'package:stela_mobile/features/dashboard/domain/repository/home_repository.dart';

class GetHealthUseCase implements UseCase<HealthStatus, NoParams> {
  final HomeRepository _repository;

  GetHealthUseCase(this._repository);

  @override
  Future<ApiResult<HealthStatus>> invoke() {
    return _repository.getHealth();
  }

  @override
  NoParams get param => const NoParams();
}
