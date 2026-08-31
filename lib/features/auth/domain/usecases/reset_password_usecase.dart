import 'package:stela_mobile/core/domain/api_response/api_result.dart';
import 'package:stela_mobile/core/domain/use_case/use_case.dart';
import 'package:stela_mobile/features/auth/domain/repository/auth_repository.dart';

class ResetPasswordUseCase implements UseCase<bool, String> {
  final AuthRepository repository;
  final String email;

  ResetPasswordUseCase(this.repository, this.email);

  @override
  Future<ApiResult<bool>> invoke() async {
    return repository.resetPassword(email);
  }

  @override
  String get param => email;
}
