import 'package:firebase_auth/firebase_auth.dart';
import 'package:stela_mobile/core/domain/api_response/api_result.dart';
import 'package:stela_mobile/features/auth/domain/models/login_payload.dart';
import 'package:stela_mobile/features/auth/domain/models/user_model.dart';
import 'package:stela_mobile/features/auth/domain/models/user_payload.dart';

abstract class AuthRepository {
  Future<ApiResult<UserCredential>> signInWithGoogle();
  Future<ApiResult<UserModel>> signUp(UserPayload payload);
  Future<ApiResult<UserCredential>> signInWithEmailAndPassword(LoginPayload payload);
  Future<ApiResult<void>> signOut();
}