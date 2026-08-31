import 'package:json_annotation/json_annotation.dart';

part 'profile_setup_payload_dto.g.dart';

@JsonSerializable()
class ProfileSetupPayloadDto {
  @JsonKey(name: "name")
  String name;
  @JsonKey(name: "age")
  int age;
  @JsonKey(name: "storyPreferences")
  List<String> storyPreferences;

  ProfileSetupPayloadDto({
    required this.name,
    required this.age,
    required this.storyPreferences,
  });

  factory ProfileSetupPayloadDto.fromJson(Map<String, dynamic> json) =>
      _$ProfileSetupPayloadDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileSetupPayloadDtoToJson(this);
}
