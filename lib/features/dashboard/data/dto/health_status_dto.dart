import 'package:json_annotation/json_annotation.dart';
import 'package:stela_mobile/features/dashboard/domain/models/health_status.dart';

part 'health_status_dto.g.dart';

@JsonSerializable()
class HealthStatusDto {
  final String status;
  final String service;
  final String version;

  const HealthStatusDto({
    required this.status,
    required this.service,
    required this.version,
  });

  HealthStatus toDto() {
    return HealthStatus(
      status: status,
      service: service,
      version: version,
    );
  }

  factory HealthStatusDto.fromJson(Map<String, dynamic> json) =>
      _$HealthStatusDtoFromJson(json);

  Map<String, dynamic> toJson() => _$HealthStatusDtoToJson(this);
}
