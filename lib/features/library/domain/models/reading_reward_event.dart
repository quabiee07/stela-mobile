import 'dart:async';

import 'package:stela_mobile/features/library/domain/models/session_log_result.dart';
class ReadingRewardEvent {
  final SessionLogResult result;
  final bool isBookComplete;
  final String? storyTitle;
  final int chapterNumber;
  final int sessionMinutes;
  final Completer<void>? uiCompleter;

  ReadingRewardEvent({
    required this.result,
    required this.isBookComplete,
    this.storyTitle,
    required this.chapterNumber,
    this.sessionMinutes = 1,
    this.uiCompleter,
  });

  int? get currentStreak => result.currentStreak;

  List<String> get newBadges => result.newBadges ?? const [];
}
