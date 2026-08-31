// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_log_request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SessionLogRequestDto _$SessionLogRequestDtoFromJson(
  Map<String, dynamic> json,
) => SessionLogRequestDto(
  sessionId: json['sessionId'] as String,
  bookId: json['bookId'] as String,
  bookTitle: json['bookTitle'] as String,
  genre: json['genre'] as String,
  chapterId: json['chapterId'] as String,
  isAudioSession: json['isAudioSession'] as bool,
  isBookComplete: json['isBookComplete'] as bool,
  speedMultiplier: (json['speedMultiplier'] as num).toDouble(),
);

Map<String, dynamic> _$SessionLogRequestDtoToJson(
  SessionLogRequestDto instance,
) => <String, dynamic>{
  'sessionId': instance.sessionId,
  'bookId': instance.bookId,
  'bookTitle': instance.bookTitle,
  'genre': instance.genre,
  'chapterId': instance.chapterId,
  'isAudioSession': instance.isAudioSession,
  'isBookComplete': instance.isBookComplete,
  'speedMultiplier': instance.speedMultiplier,
};
