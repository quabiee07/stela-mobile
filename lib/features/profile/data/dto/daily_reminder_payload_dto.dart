// To parse this JSON data, do
//
//     final dailyReminderPayloadDto = dailyReminderPayloadDtoFromJson(jsonString);

import 'package:json_annotation/json_annotation.dart';
import 'dart:convert';

part 'daily_reminder_payload_dto.g.dart';

DailyReminderPayloadDto dailyReminderPayloadDtoFromJson(String str) =>
    DailyReminderPayloadDto.fromJson(json.decode(str));

String dailyReminderPayloadDtoToJson(DailyReminderPayloadDto data) =>
    json.encode(data.toJson());

@JsonSerializable()
class DailyReminderPayloadDto {
  @JsonKey(name: "dailyReminderEnabled")
  bool dailyReminderEnabled;
  @JsonKey(name: "reminderHour")
  int reminderHour;

  DailyReminderPayloadDto({
    required this.dailyReminderEnabled,
    required this.reminderHour,
  });

  factory DailyReminderPayloadDto.fromJson(Map<String, dynamic> json) =>
      _$DailyReminderPayloadDtoFromJson(json);

  Map<String, dynamic> toJson() => _$DailyReminderPayloadDtoToJson(this);
}
