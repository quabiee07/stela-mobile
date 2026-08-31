import 'package:json_annotation/json_annotation.dart';
import 'package:stela_mobile/features/library/domain/models/chapter_paragraph.dart';

part 'chapter_paragraph_dto.g.dart';

@JsonSerializable()
class ChapterParagraphDto {
  final int paragraphIndex;
  final List<String> sentences;

  const ChapterParagraphDto({
    required this.paragraphIndex,
    required this.sentences,
  });

  ChapterParagraph toDto() {
    return ChapterParagraph(
      paragraphIndex: paragraphIndex,
      sentences: sentences,
    );
  }

  factory ChapterParagraphDto.fromJson(Map<String, dynamic> json) =>
      _$ChapterParagraphDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ChapterParagraphDtoToJson(this);
}
