import 'package:equatable/equatable.dart';
import 'package:stela_mobile/features/library/domain/models/chapter_summary.dart';
import 'package:stela_mobile/features/library/domain/models/story_reading_context.dart';

class StoryPlaybackState extends Equatable {
  const StoryPlaybackState({
    this.hasSession = false,
    this.isDetailExpanded = false,
    this.readingContext,
    this.chapterTitle = '',
    this.chapterNumber = 1,
    this.totalChapters = 1,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.isPlaying = false,
    this.isLoading = false,
    this.synthesisProgress = 0,
    this.synthesisStage = 'Preparing your story...',
    this.transitionMessage,
    this.isStoryComplete = false,
    this.autoAdvancing = false,
  });

  final bool hasSession;
  final bool isDetailExpanded;
  final StoryReadingContext? readingContext;
  final String chapterTitle;
  final int chapterNumber;
  final int totalChapters;
  final Duration position;
  final Duration duration;
  final bool isPlaying;
  final bool isLoading;
  final double synthesisProgress;
  final String synthesisStage;
  final String? transitionMessage;
  final bool isStoryComplete;
  final bool autoAdvancing;

  bool get showMiniPlayer =>
      hasSession &&
      !isDetailExpanded &&
      (isPlaying || isLoading || duration > Duration.zero);

  double get progressFraction {
    if (duration.inMilliseconds <= 0) return 0;
    return (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0);
  }

  String get storyTitle => readingContext?.storyTitle ?? '';

  String get coverImageUrl => readingContext?.coverImageUrl ?? '';

  String get chapterImageUrl => readingContext?.currentChapterImageUrl ?? coverImageUrl;

  List<ChapterSummary> get chapters => readingContext?.chapters ?? const [];

  String get chapterProgressLabel {
    if (totalChapters <= 1) return chapterTitle;
    return 'Chapter $chapterNumber · $chapterTitle';
  }

  String get miniPlayerSubtitle => chapterProgressLabel;

  String? get currentChapterId => readingContext?.chapterId;

  bool get isLastChapter {
    final context = readingContext;
    if (context == null) return true;
    return context.isLastChapter;
  }

  String get loadingMessage {
    if (transitionMessage != null) return transitionMessage!;
    if (autoAdvancing) return 'Loading next chapter...';
    if (isLoading) return synthesisStage;
    return 'Preparing your story...';
  }

  StoryPlaybackState copyWith({
    bool? hasSession,
    bool? isDetailExpanded,
    StoryReadingContext? readingContext,
    String? chapterTitle,
    int? chapterNumber,
    int? totalChapters,
    Duration? position,
    Duration? duration,
    bool? isPlaying,
    bool? isLoading,
    double? synthesisProgress,
    String? synthesisStage,
    String? transitionMessage,
    bool clearTransitionMessage = false,
    bool? isStoryComplete,
    bool? autoAdvancing,
    bool clearSession = false,
  }) {
    return StoryPlaybackState(
      hasSession: clearSession ? false : (hasSession ?? this.hasSession),
      isDetailExpanded: isDetailExpanded ?? this.isDetailExpanded,
      readingContext: clearSession ? null : (readingContext ?? this.readingContext),
      chapterTitle: clearSession ? '' : (chapterTitle ?? this.chapterTitle),
      chapterNumber: clearSession ? 1 : (chapterNumber ?? this.chapterNumber),
      totalChapters: clearSession ? 1 : (totalChapters ?? this.totalChapters),
      position: clearSession ? Duration.zero : (position ?? this.position),
      duration: clearSession ? Duration.zero : (duration ?? this.duration),
      isPlaying: clearSession ? false : (isPlaying ?? this.isPlaying),
      isLoading: clearSession ? false : (isLoading ?? this.isLoading),
      synthesisProgress:
          clearSession ? 0 : (synthesisProgress ?? this.synthesisProgress),
      synthesisStage:
          clearSession ? 'Preparing your story...' : (synthesisStage ?? this.synthesisStage),
      transitionMessage: clearTransitionMessage
          ? null
          : (transitionMessage ?? this.transitionMessage),
      isStoryComplete:
          clearSession ? false : (isStoryComplete ?? this.isStoryComplete),
      autoAdvancing: clearSession ? false : (autoAdvancing ?? this.autoAdvancing),
    );
  }

  @override
  List<Object?> get props => [
        hasSession,
        isDetailExpanded,
        readingContext,
        chapterTitle,
        chapterNumber,
        totalChapters,
        position,
        duration,
        isPlaying,
        isLoading,
        synthesisProgress,
        synthesisStage,
        transitionMessage,
        isStoryComplete,
        autoAdvancing,
      ];
}
