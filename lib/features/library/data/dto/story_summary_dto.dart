import 'package:json_annotation/json_annotation.dart';
import 'package:stela_mobile/features/library/data/dto/age_range_dto.dart';
import 'package:stela_mobile/features/library/domain/models/story_summary.dart';

part 'story_summary_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class StorySummaryDto {
  final String storyId;
  final String title;
  final String genre;
  final String description;
  final String coverImageUrl;
  final int readingTime;
  final int totalChapters;
  final AgeRangeDto ageRange;

  const StorySummaryDto({
    required this.storyId,
    required this.title,
    required this.genre,
    required this.description,
    required this.coverImageUrl,
    required this.readingTime,
    required this.totalChapters,
    required this.ageRange,
  });

  StorySummary toDto() {
    return StorySummary(
      storyId: storyId,
      title: title,
      genre: genre,
      description: description,
      coverImageUrl: coverImageUrl,
      readingTime: readingTime,
      totalChapters: totalChapters,
      ageRange: ageRange.toDto(),
    );
  }

  factory StorySummaryDto.fromJson(Map<String, dynamic> json) =>
      _$StorySummaryDtoFromJson(json);

  Map<String, dynamic> toJson() => _$StorySummaryDtoToJson(this);
}
