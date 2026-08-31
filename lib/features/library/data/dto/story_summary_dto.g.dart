// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'story_summary_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StorySummaryDto _$StorySummaryDtoFromJson(Map<String, dynamic> json) =>
    StorySummaryDto(
      storyId: json['storyId'] as String,
      title: json['title'] as String,
      genre: json['genre'] as String,
      description: json['description'] as String,
      coverImageUrl: json['coverImageUrl'] as String,
      readingTime: (json['readingTime'] as num).toInt(),
      totalChapters: (json['totalChapters'] as num).toInt(),
      ageRange: AgeRangeDto.fromJson(json['ageRange'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$StorySummaryDtoToJson(StorySummaryDto instance) =>
    <String, dynamic>{
      'storyId': instance.storyId,
      'title': instance.title,
      'genre': instance.genre,
      'description': instance.description,
      'coverImageUrl': instance.coverImageUrl,
      'readingTime': instance.readingTime,
      'totalChapters': instance.totalChapters,
      'ageRange': instance.ageRange.toJson(),
    };
