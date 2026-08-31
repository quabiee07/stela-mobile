import 'package:injectable/injectable.dart';
import 'package:stela_mobile/core/domain/api_response/api_result.dart';
import 'package:stela_mobile/core/domain/errors/app_failure.dart';
import 'package:stela_mobile/core/domain/models/generic_model.dart';
import 'package:stela_mobile/features/dashboard/data/dto/dashboard_payload_dto.dart';
import 'package:stela_mobile/features/dashboard/data/services/home_api_service.dart';
import 'package:stela_mobile/features/dashboard/domain/models/dashboard_payload.dart';
import 'package:stela_mobile/features/dashboard/domain/models/health_status.dart';
import 'package:stela_mobile/features/dashboard/domain/repository/home_repository.dart';

@LazySingleton(as: HomeRepository)
class HomeRepositoryImpl implements HomeRepository {
  HomeRepositoryImpl(this._api);

  final HomeApiService _api;

  @override
  Future<ApiResult<GenericModel>> saveFcmToken(DashboardPayload payload) async {
    try {
      final payloadDto = DashboardPayloadDto(
        token: payload.token,
        timezone: payload.timezone,
      );
      final result = await _api.saveFcmToken(payload: payloadDto);
      return ApiResult.success(result.toDto());
    } catch (e) {
      return ApiResult.failure(mapToAppFailure(e));
    }
  }

  @override
  Future<ApiResult<HealthStatus>> getHealth() async {
    try {
      final result = await _api.getHealth();
      return ApiResult.success(result.toDto());
    } catch (e) {
      return ApiResult.failure(mapToAppFailure(e));
    }
  }
}
