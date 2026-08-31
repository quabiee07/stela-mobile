import 'package:json_annotation/json_annotation.dart';
import 'package:stela_mobile/features/library/domain/models/chapter_summary.dart';

part 'chapter_summary_dto.g.dart';

@JsonSerializable()
class ChapterSummaryDto {
  final String chapterId;
  final int chapterNumber;
  final String title;
  final int wordCount;
  final String? imageUrl;

  const ChapterSummaryDto({
    required this.chapterId,
    required this.chapterNumber,
    required this.title,
    required this.wordCount,
    this.imageUrl,
  });

  ChapterSummary toDto() {
    return ChapterSummary(
      chapterId: chapterId,
      chapterNumber: chapterNumber,
      title: title,
      wordCount: wordCount,
      imageUrl: imageUrl ?? '',
    );
  }

  factory ChapterSummaryDto.fromJson(Map<String, dynamic> json) =>
      _$ChapterSummaryDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ChapterSummaryDtoToJson(this);
}
