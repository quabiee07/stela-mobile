import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stela_mobile/core/di/core_module_container.dart';
import 'package:stela_mobile/core/presentation/utils/helper_functions.dart';
import 'package:stela_mobile/features/dashboard/domain/models/story.dart';
import 'package:stela_mobile/features/library/domain/models/chapter_summary.dart';
import 'package:stela_mobile/features/library/domain/models/story_reading_context.dart';
import 'package:stela_mobile/features/library/domain/models/synthesized_audio.dart';
import 'package:stela_mobile/features/library/presentation/manager/story_detail_state.dart';
import 'package:stela_mobile/features/library/presentation/manager/story_playback_cubit.dart';
import 'package:stela_mobile/features/library/presentation/manager/story_playback_state.dart';
import 'package:stela_mobile/features/library/presentation/manager/tts_audio_utils.dart';

class StoryDetailCubit extends Cubit<StoryDetailState> {
  StoryDetailCubit(this._playbackCubit) : super(const StoryDetailState()) {
    _playbackSub = _playbackCubit.stream.listen(_onPlaybackStateChanged);
    _effectsSub = _playbackCubit.effects.listen(_onPlaybackEffect);
    _onPlaybackStateChanged(_playbackCubit.state);
  }

  final StoryPlaybackCubit _playbackCubit;
  StreamSubscription<StoryPlaybackState>? _playbackSub;
  StreamSubscription<StoryPlaybackEffect>? _effectsSub;
  final _effects = StreamController<StoryDetailEffect>.broadcast();

  final ScrollController scrollController = ScrollController();
  final List<GlobalKey> lineKeys = [];
  Function(int index)? _scrollToLineCallback;

  Stream<StoryDetailEffect> get effects => _effects.stream;

  StoryPlaybackCubit get playbackCubit => _playbackCubit;

  void initStory(Story story, Function(int index) scrollCb) {
    _scrollToLineCallback = scrollCb;
    _playbackCubit.beginLegacyStory(story);
  }

  Future<void> initReading(
    StoryReadingContext context,
    Function(int index) scrollCb,
  ) async {
    _scrollToLineCallback = scrollCb;
    await _playbackCubit.beginReadingSession(context);
  }

  void _onPlaybackStateChanged(StoryPlaybackState playback) {
    var currentLine = state.currentLine;

    if (playback.duration > Duration.zero && state.lines.isNotEmpty) {
      final newLine = _lineIndexAtSec(
        state.lineCueSecs,
        playback.position.inMilliseconds / 1000.0,
      );
      if (newLine != currentLine) {
        currentLine = newLine;
        scrollToLine(currentLine);
      }
    }

    final next = state.copyWith(
      totalDuration: playback.duration,
      position: playback.position,
      isPlaying: playback.isPlaying,
      isLoading: playback.isLoading,
      isLoadingChapter: playback.autoAdvancing,
      synthesisProgress: playback.synthesisProgress,
      synthesisStage: playback.synthesisStage,
      chapterTitle: playback.chapterTitle,
      chapterNumber: playback.chapterNumber,
      totalChapters: playback.totalChapters,
      transitionMessage: playback.transitionMessage,
      clearTransitionMessage: playback.transitionMessage == null,
      isStoryComplete: playback.isStoryComplete,
      chapters: playback.chapters,
      chapterImageUrl: playback.chapterImageUrl,
      currentChapterId: playback.currentChapterId,
      loadingMessage: playback.loadingMessage,
      currentLine: currentLine,
    );

    // Equatable short-circuit — avoids notifying listeners when nothing moved.
    if (next == state) return;
    emit(next);
  }

  void _onPlaybackEffect(StoryPlaybackEffect effect) {
    switch (effect) {
      case StoryPlaybackError(:final message):
        _effects.add(StoryDetailErrorEffect(message));
      case StoryPlaybackChapterTransition(:final message):
        _effects.add(StoryDetailChapterTransitionEffect(message));
      case StoryPlaybackReward(:final event):
        _effects.add(StoryDetailRewardEffect(event));
      case StoryPlaybackAudioReady(:final audio):
        _applyAlignmentCues(audio);
      case StoryPlaybackChapterTextReady(:final text):
        _setupLyrics(text);
    }
  }

  void _setupLyrics(String text) {
    logg('[StoryDetailCubit] Setting up lyrics...');

    final lines = TtsAudioUtils.splitLyricLines(text);
    lineKeys
      ..clear()
      ..addAll(List.generate(lines.length, (_) => GlobalKey()));

    // Temporary cues until real alignment is re-applied (same-session reopen)
    // or first synthesized. Prefer character-proportion over flat 3s steps.
    var lineCueSecs = _playbackCubit.state.duration.inMilliseconds > 0
        ? _charProportionCues(
            lines,
            _playbackCubit.state.duration.inMilliseconds / 1000.0,
          )
        : List.generate(lines.length, (i) => i * 3.0);

    final positionSec =
        _playbackCubit.state.position.inMilliseconds / 1000.0;
    final currentLine = lines.isEmpty
        ? 0
        : _lineIndexAtSec(lineCueSecs, positionSec);

    emit(
      state.copyWith(
        lyricsInitialized: true,
        fullText: text,
        lines: lines,
        lineCueSecs: lineCueSecs,
        currentLine: currentLine,
      ),
    );

    // Keep the reader on the active line when returning mid-playback.
    if (positionSec > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        scrollToLine(currentLine, animated: false);
      });
    } else if (scrollController.hasClients) {
      scrollController.jumpTo(0);
    }
  }

  List<double> _charProportionCues(List<String> lines, double totalSecs) {
    final cues = List.generate(lines.length, (i) => i * 3.0);
    final totalChars = lines.fold<int>(0, (sum, line) => sum + line.length);
    if (totalChars <= 0) return cues;

    var currentSec = 0.0;
    for (var i = 0; i < lines.length; i++) {
      cues[i] = currentSec;
      currentSec += (lines[i].length / totalChars) * totalSecs;
    }
    return cues;
  }

  bool _applyAlignmentCues(SynthesizedAudio audio) {
    if (!audio.hasAlignment || state.lines.isEmpty) return false;

    final alignedText = audio.characters.join();
    final cues = <double>[];
    var searchFrom = 0;

    for (final line in state.lines) {
      final index = alignedText.indexOf(line, searchFrom);
      if (index < 0 || index >= audio.characterStartTimesSeconds.length) {
        return false;
      }

      cues.add(audio.characterStartTimesSeconds[index]);
      searchFrom = index + line.length;
    }

    final positionSec = state.position.inMilliseconds / 1000.0;
    final currentLine = _lineIndexAtSec(cues, positionSec);

    emit(
      state.copyWith(
        lineCueSecs: cues,
        currentLine: currentLine,
      ),
    );
    scrollToLine(currentLine, animated: false);
    return true;
  }

  Future<void> jumpToChapter(
    ChapterSummary chapter, {
    bool autoPlay = true,
    bool announce = false,
  }) async {
    if (_playbackCubit.state.autoAdvancing) return;
    emit(state.copyWith(lyricsInitialized: false));
    await _playbackCubit.jumpToChapter(
      chapter,
      autoPlay: autoPlay,
      announce: announce,
    );
  }

  Future<void> togglePlay() => _playbackCubit.togglePlay();

  Future<void> seekTo(double seconds) async {
    await _playbackCubit.seekTo(seconds);
    final target = seconds.clamp(
      0.0,
      state.totalDuration.inMilliseconds > 0
          ? state.totalDuration.inMilliseconds / 1000.0
          : seconds,
    );
    final currentLine = _lineIndexAtSec(state.lineCueSecs, target);
    scrollToLine(currentLine, animated: false);
    emit(state.copyWith(currentLine: currentLine));
  }

  void nudge(int deltaSecs) => _playbackCubit.nudge(deltaSecs);

  void scrollToLine(int index, {bool animated = true}) {
    _scrollToLineCallback?.call(index);
  }

  Future<void> onScreenDisposed() async {
    await _playbackCubit.onDetailDisposed();
  }

  int _lineIndexAtSec(List<double> lineCueSecs, double seconds) {
    var idx = 0;
    for (var i = 0; i < lineCueSecs.length; i++) {
      if (lineCueSecs[i] <= seconds) {
        idx = i;
      } else {
        break;
      }
    }
    return idx;
  }

  @override
  Future<void> close() async {
    await onScreenDisposed();
    await _playbackSub?.cancel();
    await _effectsSub?.cancel();
    scrollController.dispose();
    await _effects.close();
    return super.close();
  }
}

StoryDetailCubit createStoryDetailCubit() =>
    StoryDetailCubit(getIt.get<StoryPlaybackCubit>());
