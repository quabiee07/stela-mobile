import 'package:stela_mobile/core/domain/api_response/api_result.dart';
import 'package:stela_mobile/core/domain/models/generic_model.dart';
import 'package:stela_mobile/features/dashboard/domain/models/dashboard_payload.dart';
import 'package:stela_mobile/features/dashboard/domain/models/health_status.dart';

abstract class HomeRepository {
  Future<ApiResult<GenericModel>> saveFcmToken(DashboardPayload payload);
  Future<ApiResult<HealthStatus>> getHealth();
}