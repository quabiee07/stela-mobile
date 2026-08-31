import 'package:json_annotation/json_annotation.dart';
import 'package:stela_mobile/features/library/data/dto/chapter_paragraph_dto.dart';
import 'package:stela_mobile/features/library/domain/models/chapter_content.dart';

part 'chapter_content_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class ChapterContentDto {
  final String storyId;
  final String chapterId;
  final int chapterNumber;
  final String title;
  final int wordCount;
  final String? imageUrl;
  final List<ChapterParagraphDto> paragraphs;

  const ChapterContentDto({
    required this.storyId,
    required this.chapterId,
    required this.chapterNumber,
    required this.title,
    required this.wordCount,
    required this.paragraphs,
    this.imageUrl,
  });

  ChapterContent toDto() {
    return ChapterContent(
      storyId: storyId,
      chapterId: chapterId,
      chapterNumber: chapterNumber,
      title: title,
      wordCount: wordCount,
      imageUrl: imageUrl ?? '',
      paragraphs: paragraphs.map((paragraph) => paragraph.toDto()).toList(),
    );
  }

  factory ChapterContentDto.fromJson(Map<String, dynamic> json) =>
      _$ChapterContentDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ChapterContentDtoToJson(this);
}
