// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'age_range_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AgeRangeDto _$AgeRangeDtoFromJson(Map<String, dynamic> json) => AgeRangeDto(
  min: (json['min'] as num).toInt(),
  max: (json['max'] as num).toInt(),
);

Map<String, dynamic> _$AgeRangeDtoToJson(AgeRangeDto instance) =>
    <String, dynamic>{'min': instance.min, 'max': instance.max};
