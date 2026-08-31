import 'package:json_annotation/json_annotation.dart';
import 'package:stela_mobile/features/profile/domain/models/api_timestamp.dart';

part 'api_timestamp_dto.g.dart';

@JsonSerializable()
class ApiTimestampDto {
  @JsonKey(name: '_seconds')
  final int seconds;

  @JsonKey(name: '_nanoseconds')
  final int nanoseconds;

  const ApiTimestampDto({
    required this.seconds,
    required this.nanoseconds,
  });

  ApiTimestamp toDto() {
    return ApiTimestamp(seconds: seconds, nanoseconds: nanoseconds);
  }

  factory ApiTimestampDto.fromJson(Map<String, dynamic> json) =>
      _$ApiTimestampDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ApiTimestampDtoToJson(this);
}
