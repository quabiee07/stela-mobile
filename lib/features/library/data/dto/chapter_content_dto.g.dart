// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chapter_content_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChapterContentDto _$ChapterContentDtoFromJson(Map<String, dynamic> json) =>
    ChapterContentDto(
      storyId: json['storyId'] as String,
      chapterId: json['chapterId'] as String,
      chapterNumber: (json['chapterNumber'] as num).toInt(),
      title: json['title'] as String,
      wordCount: (json['wordCount'] as num).toInt(),
      paragraphs: (json['paragraphs'] as List<dynamic>)
          .map((e) => ChapterParagraphDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      imageUrl: json['imageUrl'] as String?,
    );

Map<String, dynamic> _$ChapterContentDtoToJson(ChapterContentDto instance) =>
    <String, dynamic>{
      'storyId': instance.storyId,
      'chapterId': instance.chapterId,
      'chapterNumber': instance.chapterNumber,
      'title': instance.title,
      'wordCount': instance.wordCount,
      'imageUrl': instance.imageUrl,
      'paragraphs': instance.paragraphs.map((e) => e.toJson()).toList(),
    };
