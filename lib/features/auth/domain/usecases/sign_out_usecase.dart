import 'package:stela_mobile/core/domain/api_response/api_result.dart';
import 'package:stela_mobile/core/domain/use_case/use_case.dart';
import 'package:stela_mobile/features/auth/domain/repository/auth_repository.dart';

class SignOutUseCase implements UseCase<void, void>{
  late final AuthRepository authRepository;
  SignOutUseCase(this.authRepository);

  @override
  Future<ApiResult<void>> invoke() {
    return authRepository.signOut();
  }
  
  @override
  void get param => throw UnimplementedError();
  
}