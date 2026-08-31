import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:stela_mobile/core/di/core_module_container.dart'; 
import 'package:stela_mobile/features/auth/data/services/auth_api_service.dart';

@module
abstract class AuthModule {
  AuthApiService get api => AuthApiService(getIt.get<Dio>());
}