import 'package:awesome_dio_interceptor/awesome_dio_interceptor.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stela_mobile/core/data/storage/secure_token_storage.dart';
import 'package:stela_mobile/core/di/core_module_container.dart';
import 'package:stela_mobile/core/domain/utils/constants.dart';
import 'package:stela_mobile/core/network/auth_interceptor.dart';
import 'package:stela_mobile/features/library/data/services/session_service.dart';

@module
abstract class CoreModule {
  @lazySingleton
  FlutterSecureStorage secureStorage() => const FlutterSecureStorage();

  @lazySingleton
  Dio dio(SecureTokenStorage tokenStorage) {
    final dio = Dio(
      BaseOptions(
        baseUrl: stelaBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
    dio.interceptors.add(AuthInterceptor(tokenStorage: tokenStorage));
    dio.interceptors.add(AwesomeDioInterceptor());
    return dio;
  }

  Future<SharedPreferences> preferences() {
    return SharedPreferences.getInstance();
  }

  FirebaseFirestore firestore() => FirebaseFirestore.instance;

  SessionService get sessionService =>
      SessionService(getIt.get<Dio>(), baseUrl: stelaBaseUrl);
}
