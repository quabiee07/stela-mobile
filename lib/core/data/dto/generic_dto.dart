import 'package:json_annotation/json_annotation.dart';
import 'dart:convert';

import 'package:stela_mobile/core/domain/models/generic_model.dart';

part 'generic_dto.g.dart';

GenericDto genericDtoFromJson(String str) => GenericDto.fromJson(json.decode(str));

String genericDtoToJson(GenericDto data) => json.encode(data.toJson());

@JsonSerializable()
class GenericDto {
    @JsonKey(name: "success")
    bool success;

    GenericDto({
        required this.success,
    });

    GenericModel toDto() {
      return GenericModel(success: success);
    }

    factory GenericDto.fromJson(Map<String, dynamic> json) => _$GenericDtoFromJson(json);

    Map<String, dynamic> toJson() => _$GenericDtoToJson(this);
}
