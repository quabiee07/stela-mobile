// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chapter_summary_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChapterSummaryDto _$ChapterSummaryDtoFromJson(Map<String, dynamic> json) =>
    ChapterSummaryDto(
      chapterId: json['chapterId'] as String,
      chapterNumber: (json['chapterNumber'] as num).toInt(),
      title: json['title'] as String,
      wordCount: (json['wordCount'] as num).toInt(),
      imageUrl: json['imageUrl'] as String?,
    );

Map<String, dynamic> _$ChapterSummaryDtoToJson(ChapterSummaryDto instance) =>
    <String, dynamic>{
      'chapterId': instance.chapterId,
      'chapterNumber': instance.chapterNumber,
      'title': instance.title,
      'wordCount': instance.wordCount,
      'imageUrl': instance.imageUrl,
    };
