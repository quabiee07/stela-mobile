// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_reminder_payload_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DailyReminderPayloadDto _$DailyReminderPayloadDtoFromJson(
  Map<String, dynamic> json,
) => DailyReminderPayloadDto(
  dailyReminderEnabled: json['dailyReminderEnabled'] as bool,
  reminderHour: (json['reminderHour'] as num).toInt(),
);

Map<String, dynamic> _$DailyReminderPayloadDtoToJson(
  DailyReminderPayloadDto instance,
) => <String, dynamic>{
  'dailyReminderEnabled': instance.dailyReminderEnabled,
  'reminderHour': instance.reminderHour,
};
