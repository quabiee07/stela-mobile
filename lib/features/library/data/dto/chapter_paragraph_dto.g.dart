// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chapter_paragraph_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChapterParagraphDto _$ChapterParagraphDtoFromJson(Map<String, dynamic> json) =>
    ChapterParagraphDto(
      paragraphIndex: (json['paragraphIndex'] as num).toInt(),
      sentences: (json['sentences'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$ChapterParagraphDtoToJson(
  ChapterParagraphDto instance,
) => <String, dynamic>{
  'paragraphIndex': instance.paragraphIndex,
  'sentences': instance.sentences,
};
