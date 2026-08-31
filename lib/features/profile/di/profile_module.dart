import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:stela_mobile/core/di/core_module_container.dart';
import 'package:stela_mobile/features/profile/data/services/profile_api_service.dart';

@module
abstract class ProfileModule {
  ProfileApiService get api => ProfileApiService(getIt.get<Dio>());
}