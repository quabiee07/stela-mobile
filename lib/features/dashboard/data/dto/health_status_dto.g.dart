// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_status_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HealthStatusDto _$HealthStatusDtoFromJson(Map<String, dynamic> json) =>
    HealthStatusDto(
      status: json['status'] as String,
      service: json['service'] as String,
      version: json['version'] as String,
    );

Map<String, dynamic> _$HealthStatusDtoToJson(HealthStatusDto instance) =>
    <String, dynamic>{
      'status': instance.status,
      'service': instance.service,
      'version': instance.version,
    };
