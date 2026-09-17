import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stela_mobile/core/data/storage/secure_token_storage.dart';
import 'package:stela_mobile/core/di/core_module_container.dart';
import 'package:stela_mobile/core/domain/utils/constants.dart';
import 'package:stela_mobile/core/presentation/utils/helper_functions.dart';
import 'package:stela_mobile/features/auth/domain/repository/auth_repository.dart';
import 'package:stela_mobile/features/auth/domain/usecases/get_profile_usecase.dart';
import 'package:stela_mobile/features/dashboard/presentation/manager/home_cubit.dart';
import 'package:stela_mobile/features/library/domain/repository/session_repository.dart';
import 'package:stela_mobile/features/profile/presentation/manager/gamification_cubit.dart';
import 'package:stela_mobile/features/profile/presentation/manager/profile_cubit.dart';

enum SplashDestination { onboarding, login, setup, dashboard }

class SplashCubit extends Cubit<SplashDestination?> {
  SplashCubit({
    Future<SharedPreferences>? preferences,
    SecureTokenStorage? tokenStorage,
    FirebaseAuth? firebaseAuth,
    AuthRepository? authRepository,
  })  : _pref = preferences ?? getIt.getAsync<SharedPreferences>(),
        _tokenStorage = tokenStorage ?? getIt.get<SecureTokenStorage>(),
        _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _authRepository = authRepository ?? getIt.get<AuthRepository>(),
        super(null) {
    _bootstrap();
  }

  final Future<SharedPreferences> _pref;
  final SecureTokenStorage _tokenStorage;
  final FirebaseAuth _firebaseAuth;
  final AuthRepository _authRepository;

  Future<void> _bootstrap() async {
    await Future<void>.delayed(const Duration(seconds: 4));
    try {
      final prefs = await _pref;

      // Migrate legacy plaintext token out of SharedPreferences if present.
      final legacyToken = prefs.getString(tokenKey);
      if (legacyToken != null && legacyToken.isNotEmpty) {
        await _tokenStorage.saveToken(legacyToken);
        await prefs.remove(tokenKey);
      }

      if (prefs.getBool(onboardingKey) == null) {
        emit(SplashDestination.onboarding);
        return;
      }

      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) {
        emit(SplashDestination.login);
        return;
      }

      final isOnboarded = prefs.getBool(isOnboardedKey) ?? false;
      if (!isOnboarded) {
        emit(SplashDestination.setup);
        return;
      }

      await getCachedUser();
      final profileResult = await GetProfileUseCase(_authRepository).invoke();
      if (profileResult.isSuccess && profileResult.data != null) {
        getIt.get<ProfileCubit>().hydrateFromCache();
        getIt.get<GamificationCubit>().applyFromProfile(profileResult.data!);
        unawaited(getIt.get<HomeCubit>().loadUserGreeting());
      } else {
        Logger().d('Profile refresh failed: ${profileResult.error}');
        getIt.get<ProfileCubit>().hydrateFromCache();
        getIt.get<GamificationCubit>().hydrateFromCache();
        unawaited(getIt.get<HomeCubit>().loadUserGreeting());
      }
      emit(SplashDestination.dashboard);
      unawaited(getIt.get<SessionRepository>().flushPending());
    } catch (e) {
      Logger().d(e);
      emit(SplashDestination.login);
    }
  }
}
