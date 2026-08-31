import 'package:json_annotation/json_annotation.dart';
import 'package:stela_mobile/features/library/data/dto/age_range_dto.dart';
import 'package:stela_mobile/features/library/data/dto/chapter_summary_dto.dart';
import 'package:stela_mobile/features/library/domain/models/story_detail.dart';

part 'story_detail_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class StoryDetailDto {
  final String storyId;
  final String title;
  final String genre;
  final String description;
  final String coverImageUrl;
  final int readingTime;
  final int totalChapters;
  final AgeRangeDto ageRange;
  final List<ChapterSummaryDto> chapters;

  const StoryDetailDto({
    required this.storyId,
    required this.title,
    required this.genre,
    required this.description,
    required this.coverImageUrl,
    required this.readingTime,
    required this.totalChapters,
    required this.ageRange,
    required this.chapters,
  });

  StoryDetail toDto() {
    return StoryDetail(
      storyId: storyId,
      title: title,
      genre: genre,
      description: description,
      coverImageUrl: coverImageUrl,
      readingTime: readingTime,
      totalChapters: totalChapters,
      ageRange: ageRange.toDto(),
      chapters: chapters.map((chapter) => chapter.toDto()).toList(),
    );
  }

  factory StoryDetailDto.fromJson(Map<String, dynamic> json) =>
      _$StoryDetailDtoFromJson(json);

  Map<String, dynamic> toJson() => _$StoryDetailDtoToJson(this);
}
