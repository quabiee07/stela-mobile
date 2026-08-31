import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stela_mobile/core/data/storage/account_local_store.dart';
import 'package:stela_mobile/core/di/core_module_container.dart';
import 'package:stela_mobile/core/domain/api_response/api_result.dart';
import 'package:stela_mobile/core/domain/errors/app_failure.dart';
import 'package:stela_mobile/core/domain/models/generic_model.dart';
import 'package:stela_mobile/core/domain/utils/constants.dart';
import 'package:stela_mobile/core/presentation/utils/helper_functions.dart';
import 'package:stela_mobile/features/auth/data/dto/profile_setup_payload_dto.dart';
import 'package:stela_mobile/features/auth/data/dto/user_model_dto.dart';
import 'package:stela_mobile/features/auth/data/services/auth_api_service.dart';
import 'package:stela_mobile/features/auth/data/services/firebase_auth_service.dart';
import 'package:stela_mobile/features/auth/domain/models/login_payload.dart';
import 'package:stela_mobile/features/auth/domain/models/profile_setup_payload.dart';
import 'package:stela_mobile/features/auth/domain/models/user_payload.dart';
import 'package:stela_mobile/features/auth/domain/repository/auth_repository.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._firebaseAuth, this._authApi);

  final FirebaseAuthService _firebaseAuth;
  final AuthApiService _authApi;
  final _accountLocal = AccountLocalStore();

  @override
  Future<ApiResult<UserCredential>> signInWithEmailAndPassword(
    LoginPayload payload,
  ) async {
    try {
      final result = await _firebaseAuth.signInWithEmailAndPassword(
        email: payload.email,
        password: payload.password,
      );
      await _syncUserProfileIfExists();
      return ApiResult.success(result!);
    } catch (e) {
      return ApiResult.failure(mapToAppFailure(e));
    }
  }

  @override
  Future<ApiResult<UserCredential>> signInWithGoogle() async {
    try {
      final result = await _firebaseAuth.signInWithGoogle();
      await _syncUserProfileIfExists();
      return ApiResult.success(result!);
    } catch (e) {
      return ApiResult.failure(mapToAppFailure(e));
    }
  }

  @override
  Future<ApiResult<void>> signOut() async {
    try {
      await _firebaseAuth.signOut();
      return ApiResult.success(null);
    } catch (e) {
      return ApiResult.failure(mapToAppFailure(e));
    }
  }

  @override
  Future<ApiResult<UserCredential>> signUp(UserPayload payload) async {
    try {
      final result = await _firebaseAuth.createAccount(
        email: payload.email,
        password: payload.password,
      );
      final uid = result.user?.uid;
      if (uid != null) {
        // New account — do not restore another account's local snapshot.
        await _accountLocal.bindAccount(uid);
        await _accountLocal.markOnboarded(uid, onboarded: false);
      }
      return ApiResult.success(result);
    } catch (e) {
      return ApiResult.failure(mapToAppFailure(e));
    }
  }

  @override
  Future<ApiResult<GenericModel>> completeOnboarding(
    ProfileSetupPayload payload,
  ) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return ApiResult.failure(const UnauthorizedFailure());
      }

      final param = ProfileSetupPayloadDto(
        name: payload.name,
        age: payload.age,
        storyPreferences: payload.storyPreferences,
      );
      final result = await _authApi.completeOnboarding(payload: param);
      return ApiResult.success(result.toDto());
    } catch (e) {
      return ApiResult.failure(mapToAppFailure(e));
    }
  }

  @override
  Future<ApiResult<void>> saveUserProfile(ProfileSetupPayload payload) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return ApiResult.failure(const UnauthorizedFailure());
      }

      final prefs = await getIt.getAsync<SharedPreferences>();
      final firestore = getIt.get<FirebaseFirestore>();

      final userModel = UserModelDto(
        id: user.uid,
        name: payload.name,
        email: user.email ?? "",
        provider: user.providerData.isNotEmpty
            ? user.providerData.first.providerId
            : "email",
        avatarUrl: user.photoURL ?? "",
        age: payload.age.toString(),
        favoriteGenres: payload.storyPreferences,
        level: 1,
        title: "New Reader",
        stats: StatsDto(
          storiesRead: 0,
          readTimeHours: 0,
          totalBadges: 0,
          fantasyBooksCompleted: 0,
          audioBooksCompleted: 0,
          genresRead: [],
          chaptersAtSpeed: 0,
          oceanBooksCompleted: 0,
          scifiBooksCompleted: 0,
          sharesCompleted: 0,
          totalXp: 0,
          sessionsAfter8Pm: 0,
        ),
        badges: [],
        streakData: StreakDataDto(
          currentStreakDays: 0,
          freezesAvailable: 1,
          lastFreezeUsedDate: null,
          weeklyProgress: [],
        ),
        createdAt: DateTime.now(),
        lastReadDate: null,
      );

      await firestore.collection("users").doc(user.uid).set(userModel.toJson());

      final userString = jsonEncode(userModel.toJson());
      await prefs.setString(userKey, userString);
      cachedUser = userModel.toEntity();
      await _accountLocal.markOnboarded(user.uid, onboarded: true);

      logg("User profile saved to Firestore + SharedPreferences");
      return ApiResult.success(null);
    } catch (e) {
      logg("Error saving user profile: $e");
      return ApiResult.failure(mapToAppFailure(e));
    }
  }

  @override
  Future<ApiResult<bool>> resetPassword(String email) async {
    try {
      await _firebaseAuth.resetPassword(email: email);
      return ApiResult.success(true);
    } catch (e) {
      return ApiResult.failure(mapToAppFailure(e));
    }
  }

  Future<void> _syncUserProfileIfExists() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Restore this uid's local snapshot when logging back into the same
      // account; wipe active prefs when switching accounts.
      await _accountLocal.bindAccount(user.uid);

      final firestore = getIt.get<FirebaseFirestore>();
      final prefs = await getIt.getAsync<SharedPreferences>();

      final docSnapshot =
          await firestore.collection("users").doc(user.uid).get();

      if (docSnapshot.exists && docSnapshot.data() != null) {
        final existingUser = UserModelDto.fromJson(docSnapshot.data()!);
        final userString = jsonEncode(existingUser.toJson());

        await prefs.setString(userKey, userString);
        await _accountLocal.markOnboarded(user.uid, onboarded: true);
        cachedUser = existingUser.toEntity();

        logg("Existing user profile synced from Firestore");
      } else {
        // No cloud profile — keep restored local onboarded flag if same
        // account; otherwise require setup.
        final localOnboarded = await _accountLocal.isOnboardedFor(user.uid);
        if (!localOnboarded) {
          await prefs.remove(userKey);
          await _accountLocal.markOnboarded(user.uid, onboarded: false);
          cachedUser = null;
          logg("No Firestore profile — setup required");
        } else {
          // Same account with local cache but missing remote doc — still
          // treat as onboarded from local snapshot; hydrate cachedUser.
          await getCachedUser();
          logg("No Firestore profile — using restored local account data");
        }
      }
    } catch (e) {
      logg("Error syncing user profile: $e");
    }
  }
}
