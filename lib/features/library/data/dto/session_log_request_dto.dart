import 'package:json_annotation/json_annotation.dart';

part 'session_log_request_dto.g.dart';

@JsonSerializable()
class SessionLogRequestDto {
  final String sessionId;
  final String bookId;
  final String bookTitle;
  final String genre;
  final String chapterId;
  final bool isAudioSession;
  final bool isBookComplete;
  final double speedMultiplier;

  SessionLogRequestDto({
    required this.sessionId,
    required this.bookId,
    required this.bookTitle,
    required this.genre,
    required this.chapterId,
    required this.isAudioSession,
    required this.isBookComplete,
    required this.speedMultiplier,
  });

  factory SessionLogRequestDto.fromJson(Map<String, dynamic> json) =>
      _$SessionLogRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SessionLogRequestDtoToJson(this);
}
