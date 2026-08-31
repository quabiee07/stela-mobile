import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:stela_mobile/core/di/core_module_container.dart'; 
import 'package:stela_mobile/features/dashboard/data/services/home_api_service.dart';

@module
abstract class HomeModule {
  HomeApiService get api => HomeApiService(getIt.get<Dio>());
}