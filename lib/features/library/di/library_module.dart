import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:stela_mobile/core/di/core_module_container.dart';
import 'package:stela_mobile/features/library/data/services/elevenlabs_tts_service.dart';
import 'package:stela_mobile/features/library/data/services/stories_api_service.dart';

@module
abstract class LibraryModule {
  StoriesApiService get storiesApi => StoriesApiService(getIt.get<Dio>());

  @Named('elevenLabsDio')
  Dio get elevenLabsDio {
    final dio = Dio(
      BaseOptions(
        baseUrl: 'https://api.elevenlabs.io/v1/',
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 120),
        sendTimeout: const Duration(seconds: 60),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
    // dio.interceptors.add(InterceptorsInterceptor());
    return dio;
  }

  ElevenLabsTtsService elevenLabsTtsService(@Named('elevenLabsDio') Dio dio) =>
      ElevenLabsTtsService(dio);
}
