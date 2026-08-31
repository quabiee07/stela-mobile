// To parse this JSON data, do
//
//     final dashboardPayloadDto = dashboardPayloadDtoFromJson(jsonString);

import 'package:json_annotation/json_annotation.dart';
import 'dart:convert';

part 'dashboard_payload_dto.g.dart';

DashboardPayloadDto dashboardPayloadDtoFromJson(String str) => DashboardPayloadDto.fromJson(json.decode(str));

String dashboardPayloadDtoToJson(DashboardPayloadDto data) => json.encode(data.toJson());

@JsonSerializable()
class DashboardPayloadDto {
    @JsonKey(name: "token")
    String token;
    @JsonKey(name: "timezone")
    String timezone;

    DashboardPayloadDto({
        required this.token,
        required this.timezone,
    });

    factory DashboardPayloadDto.fromJson(Map<String, dynamic> json) => _$DashboardPayloadDtoFromJson(json);

    Map<String, dynamic> toJson() => _$DashboardPayloadDtoToJson(this);
}
