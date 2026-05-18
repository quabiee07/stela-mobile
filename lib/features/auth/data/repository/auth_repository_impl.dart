import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';
import 'package:stela_mobile/core/domain/api_response/api_result.dart';
import 'package:stela_mobile/features/auth/data/services/firebase_auth_service.dart';
import 'package:stela_mobile/features/auth/domain/models/login_payload.dart';
import 'package:stela_mobile/features/auth/domain/models/user_model.dart';
import 'package:stela_mobile/features/auth/domain/models/user_payload.dart';
import 'package:stela_mobile/features/auth/domain/repository/auth_repository.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final api = FirebaseAuthService();

  @override
  Future<ApiResult<UserCredential>> signInWithEmailAndPassword(
    LoginPayload payload,
  ) async {
    try {
      final result = await api.signInWithEmailAndPassword(
        email: payload.email,
        password: payload.password,
      );
      return ApiResult.success(result!);
    } catch (e) {
      return ApiResult.failure(e);
    }
  }

  @override
  Future<ApiResult<UserCredential>> signInWithGoogle() async {
    try {
      final result = await api.signInWithGoogle();
      return ApiResult.success(result!);
    } catch (e) {
      return ApiResult.failure(e);
    }
  }

  @override
  Future<ApiResult<void>> signOut() async {
    try {
      await api.signOut();
      return ApiResult.success(null);
    } catch (e) {
      return ApiResult.failure(e);
    }
  }

  @override
  Future<ApiResult<UserModel>> signUp(UserPayload payload) async {
    try {
      final result = await api.createAccount(payload);
      return ApiResult.success(result);
    } catch (e) {
      return ApiResult.failure(e);
    }
  }
}
