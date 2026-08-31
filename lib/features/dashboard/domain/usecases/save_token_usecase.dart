import 'package:stela_mobile/core/domain/api_response/api_result.dart';
import 'package:stela_mobile/core/domain/models/generic_model.dart';
import 'package:stela_mobile/core/domain/use_case/use_case.dart';
import 'package:stela_mobile/features/dashboard/domain/models/dashboard_payload.dart';
import 'package:stela_mobile/features/dashboard/domain/repository/home_repository.dart';

class SaveTokenUseCase implements UseCase<GenericModel, DashboardPayload>{
  late final HomeRepository homeRepository;
  late final DashboardPayload payload;
  SaveTokenUseCase(this.homeRepository, this.payload);

  @override
  Future<ApiResult<GenericModel>> invoke() {
    return homeRepository.saveFcmToken(payload);
  }
  
  @override
  DashboardPayload get param => payload;
  
}