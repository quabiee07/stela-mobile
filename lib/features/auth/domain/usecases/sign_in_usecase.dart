import 'package:firebase_auth/firebase_auth.dart';
import 'package:stela_mobile/core/domain/api_response/api_result.dart';
import 'package:stela_mobile/core/domain/use_case/use_case.dart';
import 'package:stela_mobile/features/auth/domain/models/login_payload.dart';
import 'package:stela_mobile/features/auth/domain/repository/auth_repository.dart';

class SignInUseCase implements UseCase<UserCredential?, LoginPayload>{
  late final AuthRepository authRepository;
  late final LoginPayload payload;
  SignInUseCase(this.authRepository, this.payload);

  @override
  Future<ApiResult<UserCredential?>> invoke() {
    return authRepository.signInWithEmailAndPassword(param);
  }
  
  @override
  LoginPayload get param => payload;
  
}


class SignInWithGoogleUseCase implements UseCase<UserCredential?, void>{
  late final AuthRepository authRepository;
  SignInWithGoogleUseCase(this.authRepository);

  @override
  Future<ApiResult<UserCredential?>> invoke() {
    return authRepository.signInWithGoogle();
  }
  
  @override
  void get param => {};
  
}
