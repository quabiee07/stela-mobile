// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_setup_payload_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProfileSetupPayloadDto _$ProfileSetupPayloadDtoFromJson(
  Map<String, dynamic> json,
) => ProfileSetupPayloadDto(
  name: json['name'] as String,
  age: (json['age'] as num).toInt(),
  storyPreferences: (json['storyPreferences'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$ProfileSetupPayloadDtoToJson(
  ProfileSetupPayloadDto instance,
) => <String, dynamic>{
  'name': instance.name,
  'age': instance.age,
  'storyPreferences': instance.storyPreferences,
};
