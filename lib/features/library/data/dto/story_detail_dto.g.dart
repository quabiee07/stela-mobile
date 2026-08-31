// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'story_detail_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StoryDetailDto _$StoryDetailDtoFromJson(Map<String, dynamic> json) =>
    StoryDetailDto(
      storyId: json['storyId'] as String,
      title: json['title'] as String,
      genre: json['genre'] as String,
      description: json['description'] as String,
      coverImageUrl: json['coverImageUrl'] as String,
      readingTime: (json['readingTime'] as num).toInt(),
      totalChapters: (json['totalChapters'] as num).toInt(),
      ageRange: AgeRangeDto.fromJson(json['ageRange'] as Map<String, dynamic>),
      chapters: (json['chapters'] as List<dynamic>)
          .map((e) => ChapterSummaryDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$StoryDetailDtoToJson(StoryDetailDto instance) =>
    <String, dynamic>{
      'storyId': instance.storyId,
      'title': instance.title,
      'genre': instance.genre,
      'description': instance.description,
      'coverImageUrl': instance.coverImageUrl,
      'readingTime': instance.readingTime,
      'totalChapters': instance.totalChapters,
      'ageRange': instance.ageRange.toJson(),
      'chapters': instance.chapters.map((e) => e.toJson()).toList(),
    };
