import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stela_mobile/core/data/storage/secure_token_storage.dart';
import 'package:stela_mobile/core/di/core_module_container.dart';
import 'package:stela_mobile/core/domain/utils/constants.dart';
import 'package:stela_mobile/core/presentation/utils/helper_functions.dart';

enum SplashDestination { onboarding, login, setup, dashboard }

class SplashCubit extends Cubit<SplashDestination?> {
  SplashCubit({
    Future<SharedPreferences>? preferences,
    SecureTokenStorage? tokenStorage,
  })  : _pref = preferences ?? getIt.getAsync<SharedPreferences>(),
        _tokenStorage = tokenStorage ?? getIt.get<SecureTokenStorage>(),
        super(null) {
    _bootstrap();
  }

  final Future<SharedPreferences> _pref;
  final SecureTokenStorage _tokenStorage;

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

      final loggedInUser = prefs.getString(userKey);
      final isOnboarded = prefs.getBool(isOnboardedKey) ?? false;
      final secureToken = await _tokenStorage.readToken();

      if (loggedInUser == null && !isOnboarded) {
        emit(SplashDestination.login);
        return;
      }
      if (!isOnboarded) {
        emit(SplashDestination.setup);
        return;
      }

      if (secureToken == null || secureToken.isEmpty) {
        // Onboarded flag without a session — send to login.
        emit(SplashDestination.login);
        return;
      }

      await getCachedUser();
      emit(SplashDestination.dashboard);
    } catch (e) {
      Logger().d(e);
      emit(SplashDestination.login);
    }
  }
}
