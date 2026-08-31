import 'package:json_annotation/json_annotation.dart';
import 'package:stela_mobile/features/library/domain/models/age_range.dart';

part 'age_range_dto.g.dart';

@JsonSerializable()
class AgeRangeDto {
  final int min;
  final int max;

  const AgeRangeDto({
    required this.min,
    required this.max,
  });

  AgeRange toDto() => AgeRange(min: min, max: max);

  factory AgeRangeDto.fromJson(Map<String, dynamic> json) =>
      _$AgeRangeDtoFromJson(json);

  Map<String, dynamic> toJson() => _$AgeRangeDtoToJson(this);
}
