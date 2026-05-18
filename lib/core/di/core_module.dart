import 'package:awesome_dio_interceptor/awesome_dio_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stela_mobile/core/di/core_module_container.dart';
import 'package:stela_mobile/features/library/data/services/elevenlabs_tts_service.dart';

@module
abstract class CoreModule {
  Dio dio() {
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json', 'Accept': 'audio/mpeg'},
      ),
    );
    dio.interceptors.add(AwesomeDioInterceptor());

    return dio;
  }

  Future<SharedPreferences> preferences() {
    return SharedPreferences.getInstance();
  }

  FirebaseFirestore firestore() => FirebaseFirestore.instance;
  ElevenLabsTtsService get ttsService => ElevenLabsTtsService(getIt<Dio>());
}
