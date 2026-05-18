import 'package:stela_mobile/core/domain/api_response/api_result.dart';
import 'package:stela_mobile/core/domain/use_case/use_case.dart';
import 'package:stela_mobile/features/auth/domain/models/user_model.dart';
import 'package:stela_mobile/features/auth/domain/models/user_payload.dart';
import 'package:stela_mobile/features/auth/domain/repository/auth_repository.dart';

class CreateAccountUseCase implements UseCase<UserModel, UserPayload>{
  late final AuthRepository authRepository;
  late final UserPayload payload;
  CreateAccountUseCase(this.authRepository, this.payload);

  @override
  Future<ApiResult<UserModel>> invoke() {
    return authRepository.signUp(param);
  }
  
  @override
  UserPayload get param => payload;
  
}