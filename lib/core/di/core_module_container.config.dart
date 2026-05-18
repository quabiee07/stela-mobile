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
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;
import 'package:stela_mobile/core/di/core_module.dart' as _i870;
import 'package:stela_mobile/features/auth/data/repository/auth_repository_impl.dart'
    as _i632;
import 'package:stela_mobile/features/auth/data/services/firebase_auth_service.dart'
    as _i611;
import 'package:stela_mobile/features/auth/domain/repository/auth_repository.dart'
    as _i576;
import 'package:stela_mobile/features/library/data/repository/library_repository_impl.dart'
    as _i785;
import 'package:stela_mobile/features/library/data/services/elevenlabs_tts_service.dart'
    as _i815;
import 'package:stela_mobile/features/library/domain/repository/library_repository.dart'
    as _i901;
import 'package:stela_mobile/features/profile/data/services/profile_firebase_service.dart'
    as _i492;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final coreModule = _$CoreModule();
    gh.factory<_i815.ElevenLabsTtsService>(() => coreModule.ttsService);
    gh.factory<_i361.Dio>(() => coreModule.dio());
    gh.factoryAsync<_i460.SharedPreferences>(() => coreModule.preferences());
    gh.factory<_i974.FirebaseFirestore>(() => coreModule.firestore());
    gh.lazySingleton<_i611.FirebaseAuthService>(
      () => _i611.FirebaseAuthService(),
    );
    gh.lazySingleton<_i492.ProfileFirebaseService>(
      () => _i492.ProfileFirebaseService(),
    );
    gh.lazySingleton<_i576.AuthRepository>(() => _i632.AuthRepositoryImpl());
    gh.lazySingleton<_i901.LibraryRepository>(
      () => _i785.LibraryRepositoryImpl(),
    );
    return this;
  }
}

class _$CoreModule extends _i870.CoreModule {}
