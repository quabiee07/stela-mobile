// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_timestamp_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiTimestampDto _$ApiTimestampDtoFromJson(Map<String, dynamic> json) =>
    ApiTimestampDto(
      seconds: (json['_seconds'] as num).toInt(),
      nanoseconds: (json['_nanoseconds'] as num).toInt(),
    );

Map<String, dynamic> _$ApiTimestampDtoToJson(ApiTimestampDto instance) =>
    <String, dynamic>{
      '_seconds': instance.seconds,
      '_nanoseconds': instance.nanoseconds,
    };
