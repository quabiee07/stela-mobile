import 'package:stela_mobile/core/domain/api_response/api_result.dart';
import 'package:stela_mobile/core/domain/models/generic_model.dart';
import 'package:stela_mobile/core/domain/use_case/use_case.dart';
import 'package:stela_mobile/features/auth/domain/models/profile_setup_payload.dart';
import 'package:stela_mobile/features/auth/domain/repository/auth_repository.dart';

class SetupProfileUseCase implements UseCase<GenericModel, ProfileSetupPayload>{
  late final AuthRepository authRepository;
  late final ProfileSetupPayload payload;
  SetupProfileUseCase(this.authRepository, this.payload);

  @override
  Future<ApiResult<GenericModel>> invoke() {
    return authRepository.completeOnboarding(payload);
  }
  
  @override
  ProfileSetupPayload get param => payload;
  
}