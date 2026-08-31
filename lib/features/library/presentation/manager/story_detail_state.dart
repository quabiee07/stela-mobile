import 'package:equatable/equatable.dart';
import 'package:stela_mobile/features/library/domain/models/chapter_summary.dart';
import 'package:stela_mobile/features/library/domain/models/reading_reward_event.dart';

class StoryDetailState extends Equatable {
  const StoryDetailState({
    this.totalDuration = Duration.zero,
    this.position = Duration.zero,
    this.isPlaying = false,
    this.isLoading = false,
    this.isLoadingChapter = false,
    this.synthesisProgress = 0,
    this.synthesisStage = 'Preparing your story...',
    this.lyricsInitialized = false,
    this.fullText = '',
    this.lines = const [],
    this.lineCueSecs = const [],
    this.currentLine = 0,
    this.chapterTitle = '',
    this.chapterNumber = 1,
    this.totalChapters = 1,
    this.transitionMessage,
    this.isStoryComplete = false,
    this.chapters = const [],
    this.chapterImageUrl = '',
    this.currentChapterId,
    this.loadingMessage = 'Preparing your story...',
  });

  final Duration totalDuration;
  final Duration position;
  final bool isPlaying;
  final bool isLoading;
  final bool isLoadingChapter;
  final double synthesisProgress;
  final String synthesisStage;
  final bool lyricsInitialized;
  final String fullText;
  final List<String> lines;
  final List<double> lineCueSecs;
  final int currentLine;
  final String chapterTitle;
  final int chapterNumber;
  final int totalChapters;
  final String? transitionMessage;
  final bool isStoryComplete;
  final List<ChapterSummary> chapters;
  final String chapterImageUrl;
  final String? currentChapterId;
  final String loadingMessage;

  bool get showSynthesizingOverlay =>
      isLoadingChapter || isLoading;

  String get chapterProgressLabel {
    if (totalChapters <= 1) return chapterTitle;
    return 'Chapter $chapterNumber: $chapterTitle';
  }

  StoryDetailState copyWith({
    Duration? totalDuration,
    Duration? position,
    bool? isPlaying,
    bool? isLoading,
    bool? isLoadingChapter,
    double? synthesisProgress,
    String? synthesisStage,
    bool? lyricsInitialized,
    String? fullText,
    List<String>? lines,
    List<double>? lineCueSecs,
    int? currentLine,
    String? chapterTitle,
    int? chapterNumber,
    int? totalChapters,
    String? transitionMessage,
    bool clearTransitionMessage = false,
    bool? isStoryComplete,
    List<ChapterSummary>? chapters,
    String? chapterImageUrl,
    String? currentChapterId,
    String? loadingMessage,
  }) {
    return StoryDetailState(
      totalDuration: totalDuration ?? this.totalDuration,
      position: position ?? this.position,
      isPlaying: isPlaying ?? this.isPlaying,
      isLoading: isLoading ?? this.isLoading,
      isLoadingChapter: isLoadingChapter ?? this.isLoadingChapter,
      synthesisProgress: synthesisProgress ?? this.synthesisProgress,
      synthesisStage: synthesisStage ?? this.synthesisStage,
      lyricsInitialized: lyricsInitialized ?? this.lyricsInitialized,
      fullText: fullText ?? this.fullText,
      lines: lines ?? this.lines,
      lineCueSecs: lineCueSecs ?? this.lineCueSecs,
      currentLine: currentLine ?? this.currentLine,
      chapterTitle: chapterTitle ?? this.chapterTitle,
      chapterNumber: chapterNumber ?? this.chapterNumber,
      totalChapters: totalChapters ?? this.totalChapters,
      transitionMessage: clearTransitionMessage
          ? null
          : (transitionMessage ?? this.transitionMessage),
      isStoryComplete: isStoryComplete ?? this.isStoryComplete,
      chapters: chapters ?? this.chapters,
      chapterImageUrl: chapterImageUrl ?? this.chapterImageUrl,
      currentChapterId: currentChapterId ?? this.currentChapterId,
      loadingMessage: loadingMessage ?? this.loadingMessage,
    );
  }

  @override
  List<Object?> get props => [
        totalDuration,
        position,
        isPlaying,
        isLoading,
        isLoadingChapter,
        synthesisProgress,
        synthesisStage,
        lyricsInitialized,
        fullText,
        lines,
        lineCueSecs,
        currentLine,
        chapterTitle,
        chapterNumber,
        totalChapters,
        transitionMessage,
        isStoryComplete,
        chapters,
        chapterImageUrl,
        currentChapterId,
        loadingMessage,
      ];
}

sealed class StoryDetailEffect {
  const StoryDetailEffect();
}

final class StoryDetailErrorEffect extends StoryDetailEffect {
  const StoryDetailErrorEffect(this.message);
  final String message;
}

final class StoryDetailRewardEffect extends StoryDetailEffect {
  const StoryDetailRewardEffect(this.event);
  final ReadingRewardEvent event;
}

final class StoryDetailChapterTransitionEffect extends StoryDetailEffect {
  const StoryDetailChapterTransitionEffect(this.message);
  final String message;
}
