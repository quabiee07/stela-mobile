// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:cloud_firestore/cloud_firestore.dart' as _i974;
import 'package:dio/dio.dart' as _i361;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;
import 'package:stela_mobile/core/data/storage/secure_token_storage.dart'
    as _i490;
import 'package:stela_mobile/core/di/core_module.dart' as _i870;
import 'package:stela_mobile/features/auth/data/repository/auth_repository_impl.dart'
    as _i632;
import 'package:stela_mobile/features/auth/data/services/auth_api_service.dart'
    as _i537;
import 'package:stela_mobile/features/auth/data/services/firebase_auth_service.dart'
    as _i611;
import 'package:stela_mobile/features/auth/di/auth_module.dart' as _i835;
import 'package:stela_mobile/features/auth/domain/repository/auth_repository.dart'
    as _i576;
import 'package:stela_mobile/features/dashboard/data/repository/home_repository_impl.dart'
    as _i459;
import 'package:stela_mobile/features/dashboard/data/services/home_api_service.dart'
    as _i178;
import 'package:stela_mobile/features/dashboard/di/home_module.dart' as _i730;
import 'package:stela_mobile/features/dashboard/domain/repository/home_repository.dart'
    as _i844;
import 'package:stela_mobile/features/dashboard/presentation/manager/home_cubit.dart'
    as _i68;
import 'package:stela_mobile/features/library/data/repository/library_repository_impl.dart'
    as _i785;
import 'package:stela_mobile/features/library/data/repository/session_repository_impl.dart'
    as _i551;
import 'package:stela_mobile/features/library/data/repository/stories_repository_impl.dart'
    as _i904;
import 'package:stela_mobile/features/library/data/services/elevenlabs_tts_service.dart'
    as _i815;
import 'package:stela_mobile/features/library/data/services/session_id_store.dart'
    as _i986;
import 'package:stela_mobile/features/library/data/services/session_service.dart'
    as _i974;
import 'package:stela_mobile/features/library/data/services/stories_api_service.dart'
    as _i902;
import 'package:stela_mobile/features/library/data/services/tts_audio_cache.dart'
    as _i794;
import 'package:stela_mobile/features/library/data/services/voice_preference_store.dart'
    as _i376;
import 'package:stela_mobile/features/library/di/library_module.dart' as _i908;
import 'package:stela_mobile/features/library/domain/repository/library_repository.dart'
    as _i901;
import 'package:stela_mobile/features/library/domain/repository/session_repository.dart'
    as _i675;
import 'package:stela_mobile/features/library/domain/repository/stories_repository.dart'
    as _i149;
import 'package:stela_mobile/features/library/presentation/manager/library_cubit.dart'
    as _i258;
import 'package:stela_mobile/features/library/presentation/manager/story_playback_cubit.dart'
    as _i315;
import 'package:stela_mobile/features/profile/data/repository/profile_repository_impl.dart'
    as _i219;
import 'package:stela_mobile/features/profile/data/services/profile_api_service.dart'
    as _i481;
import 'package:stela_mobile/features/profile/data/services/profile_firebase_service.dart'
    as _i492;
import 'package:stela_mobile/features/profile/di/profile_module.dart' as _i471;
import 'package:stela_mobile/features/profile/domain/repository/profile_repository.dart'
    as _i571;
import 'package:stela_mobile/features/profile/presentation/manager/gamification_cubit.dart'
    as _i254;
import 'package:stela_mobile/features/profile/presentation/manager/reading_preferences_cubit.dart'
    as _i265;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final coreModule = _$CoreModule();
    final authModule = _$AuthModule();
    final homeModule = _$HomeModule();
    final libraryModule = _$LibraryModule();
    final profileModule = _$ProfileModule();
    gh.factory<_i974.SessionService>(() => coreModule.sessionService);
    gh.factoryAsync<_i460.SharedPreferences>(() => coreModule.preferences());
    gh.factory<_i974.FirebaseFirestore>(() => coreModule.firestore());
    gh.factory<_i537.AuthApiService>(() => authModule.api);
    gh.factory<_i178.HomeApiService>(() => homeModule.api);
    gh.factory<_i902.StoriesApiService>(() => libraryModule.storiesApi);
    gh.factory<_i481.ProfileApiService>(() => profileModule.api);
    gh.lazySingleton<_i558.FlutterSecureStorage>(
      () => coreModule.secureStorage(),
    );
    gh.lazySingleton<_i986.SessionIdStore>(() => _i986.SessionIdStore());
    gh.lazySingleton<_i794.TtsAudioCache>(() => _i794.TtsAudioCache());
    gh.lazySingleton<_i376.VoicePreferenceStore>(
      () => _i376.VoicePreferenceStore(),
    );
    gh.lazySingleton<_i492.ProfileFirebaseService>(
      () => _i492.ProfileFirebaseService(),
    );
    gh.lazySingleton<_i265.ReadingPreferencesCubit>(
      () => _i265.ReadingPreferencesCubit(),
    );
    gh.lazySingleton<_i490.SecureTokenStorage>(
      () => _i490.SecureTokenStorage(gh<_i558.FlutterSecureStorage>()),
    );
    gh.factory<_i361.Dio>(
      () => libraryModule.elevenLabsDio,
      instanceName: 'elevenLabsDio',
    );
    gh.lazySingleton<_i844.HomeRepository>(
      () => _i459.HomeRepositoryImpl(gh<_i178.HomeApiService>()),
    );
    gh.lazySingleton<_i901.LibraryRepository>(
      () => _i785.LibraryRepositoryImpl(),
    );
    gh.lazySingleton<_i675.SessionRepository>(
      () => _i551.SessionRepositoryImpl(
        gh<_i974.SessionService>(),
        gh<_i986.SessionIdStore>(),
      ),
    );
    gh.factory<_i815.ElevenLabsTtsService>(
      () => libraryModule.elevenLabsTtsService(
        gh<_i361.Dio>(instanceName: 'elevenLabsDio'),
      ),
    );
    gh.lazySingleton<_i571.ProfileRepository>(
      () => _i219.ProfileRepositoryImpl(gh<_i481.ProfileApiService>()),
    );
    gh.lazySingleton<_i611.FirebaseAuthService>(
      () => _i611.FirebaseAuthService(gh<_i490.SecureTokenStorage>()),
    );
    gh.lazySingleton<_i149.StoriesRepository>(
      () => _i904.StoriesRepositoryImpl(gh<_i902.StoriesApiService>()),
    );
    gh.lazySingleton<_i361.Dio>(
      () => coreModule.dio(gh<_i490.SecureTokenStorage>()),
    );
    gh.lazySingleton<_i576.AuthRepository>(
      () => _i632.AuthRepositoryImpl(
        gh<_i611.FirebaseAuthService>(),
        gh<_i537.AuthApiService>(),
      ),
    );
    gh.lazySingleton<_i254.GamificationCubit>(
      () => _i254.GamificationCubit(gh<_i571.ProfileRepository>()),
    );
    gh.lazySingleton<_i258.LibraryCubit>(
      () => _i258.LibraryCubit(gh<_i149.StoriesRepository>()),
    );
    gh.lazySingleton<_i68.HomeCubit>(
      () => _i68.HomeCubit(
        gh<_i844.HomeRepository>(),
        gh<_i149.StoriesRepository>(),
      ),
    );
    gh.lazySingleton<_i315.StoryPlaybackCubit>(
      () => _i315.StoryPlaybackCubit(
        gh<_i901.LibraryRepository>(),
        gh<_i149.StoriesRepository>(),
        gh<_i675.SessionRepository>(),
        gh<_i376.VoicePreferenceStore>(),
      ),
    );
    return this;
  }
}

class _$CoreModule extends _i870.CoreModule {}

class _$AuthModule extends _i835.AuthModule {}

class _$HomeModule extends _i730.HomeModule {}

class _$LibraryModule extends _i908.LibraryModule {}

class _$ProfileModule extends _i471.ProfileModule {}
