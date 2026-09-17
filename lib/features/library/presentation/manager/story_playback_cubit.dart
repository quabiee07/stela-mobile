import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:stela_mobile/core/presentation/utils/helper_functions.dart';
import 'package:stela_mobile/features/dashboard/domain/models/story.dart';
import 'package:stela_mobile/features/library/data/services/reading_progress_service.dart';
import 'package:stela_mobile/features/library/data/services/voice_preference_store.dart';
import 'package:stela_mobile/features/library/domain/models/chapter_summary.dart';
import 'package:stela_mobile/features/library/domain/models/reading_progress.dart';
import 'package:stela_mobile/features/library/domain/models/reading_reward_event.dart';
import 'package:stela_mobile/features/library/domain/models/session_log_result.dart';
import 'package:stela_mobile/features/library/domain/models/story_reading_context.dart';
import 'package:stela_mobile/features/library/domain/models/synthesized_audio.dart';
import 'package:stela_mobile/features/library/domain/repository/library_repository.dart';
import 'package:stela_mobile/features/library/domain/repository/session_repository.dart';
import 'package:stela_mobile/features/library/domain/repository/stories_repository.dart';
import 'package:stela_mobile/features/library/domain/usecase/get_chapter_content_usecase.dart';
import 'package:stela_mobile/features/library/domain/usecase/log_session_usecase.dart';
import 'package:stela_mobile/features/library/domain/usecase/synthesize_story_usecase.dart';
import 'package:stela_mobile/core/di/core_module_container.dart';
import 'package:stela_mobile/features/library/presentation/manager/playback_media_service.dart';
import 'package:stela_mobile/features/library/presentation/manager/story_audio_handler.dart';
import 'package:stela_mobile/features/library/presentation/manager/story_playback_state.dart';
import 'package:stela_mobile/features/profile/presentation/manager/gamification_cubit.dart';
import 'package:stela_mobile/features/profile/presentation/manager/reading_preferences_cubit.dart';

/// Side effects for screens that are attached to playback (detail, rewards).
sealed class StoryPlaybackEffect {}

class StoryPlaybackError extends StoryPlaybackEffect {
  StoryPlaybackError(this.message);
  final String message;
}

class StoryPlaybackChapterTransition extends StoryPlaybackEffect {
  StoryPlaybackChapterTransition(this.message);
  final String message;
}

class StoryPlaybackReward extends StoryPlaybackEffect {
  StoryPlaybackReward(this.event);
  final ReadingRewardEvent event;
}

class StoryPlaybackAudioReady extends StoryPlaybackEffect {
  StoryPlaybackAudioReady(this.audio);
  final SynthesizedAudio audio;
}

class StoryPlaybackChapterTextReady extends StoryPlaybackEffect {
  StoryPlaybackChapterTextReady(this.text);
  final String text;
}

@lazySingleton
class StoryPlaybackCubit extends Cubit<StoryPlaybackState> {
  StoryPlaybackCubit(
    this._repo,
    this._storiesRepo,
    this._sessionRepo,
    this._voicePreferenceStore,
  ) : super(const StoryPlaybackState()) {
    _initPlayer();
    _attachMediaHandlerIfReady();
    _readingPrefsSub = getIt
        .get<ReadingPreferencesCubit>()
        .stream
        .listen((prefs) => unawaited(_applyPlaybackRate(prefs.textSpeed)));
  }

  final LibraryRepository _repo;
  final StoriesRepository _storiesRepo;
  final SessionRepository _sessionRepo;
  final VoicePreferenceStore _voicePreferenceStore;
  final _readingProgressService = ReadingProgressService();
  final _player = AudioPlayer();
  final _effectsController = StreamController<StoryPlaybackEffect>.broadcast();
  StoryAudioHandler? _mediaHandler;
  StreamSubscription<StoryPlaybackState>? _mediaSyncSub;
  StreamSubscription<ReadingPreferencesState>? _readingPrefsSub;

  Stream<StoryPlaybackEffect> get effects => _effectsController.stream;

  Story? _legacyStory;
  String _fullText = '';
  String? _audioFilePath;
  bool _isLoaded = false;
  /// Kept so lyric sync can be restored when reopening story detail.
  SynthesizedAudio? _cachedAudio;
  Timer? _synthesisStageTimer;
  int _expectedChunkCount = 0;
  int _chunksReceived = 0;
  final Set<String> _loggedChapterIds = {};
  Completer<void>? _rewardUiCompleter;
  DateTime? _sessionEnterTime;
  bool _detailAttached = false;
  /// Caps UI rebuilds from audioplayers (often fires 10–20+/sec on device).
  DateTime? _lastPositionEmitAt;
  static const _positionEmitInterval = Duration(milliseconds: 200);

  /// Bumped on each chapter load / synth so stale async completions are ignored.
  int _loadGen = 0;
  int _synthGen = 0;
  bool _handlingChapterComplete = false;

  StreamSubscription<void>? _completeSub;
  StreamSubscription<Duration>? _durationSub;
  StreamSubscription<Duration>? _positionSub;

  String get fullText => _fullText;

  int get _safeTotalChapters => math.max(state.totalChapters, 1);

  bool get isLoaded => _isLoaded;

  Future<void> _initPlayer() async {
    await _player.setPlayerMode(PlayerMode.mediaPlayer);
    await _player.setReleaseMode(ReleaseMode.stop);

    _completeSub = _player.onPlayerComplete.listen((_) {
      unawaited(_onChapterComplete());
    });

    _durationSub = _player.onDurationChanged.listen((dur) {
      if (!isClosed) emit(state.copyWith(duration: dur));
    });

    _positionSub = _player.onPositionChanged.listen((pos) {
      if (isClosed) return;
      if (state.duration == Duration.zero) return;
      final now = DateTime.now();
      final last = _lastPositionEmitAt;
      if (last != null && now.difference(last) < _positionEmitInterval) {
        return;
      }
      _lastPositionEmitAt = now;
      emit(state.copyWith(position: pos));
    });
  }

  void _attachMediaHandlerIfReady() {
    final handler = PlaybackMediaService.handler;
    if (handler == null) return;
    attachMediaHandler(handler);
  }

  /// Called once [PlaybackMediaService.init] completes (may be after cubit
  /// construction on cold start).
  void attachMediaHandler(StoryAudioHandler handler) {
    _mediaHandler = handler;
    handler.bind(this);
    _mediaSyncSub?.cancel();
    _mediaSyncSub = stream.listen((s) {
      unawaited(handler.sync(s));
    });
    unawaited(handler.sync(state));
  }

  void attachDetail() {
    _detailAttached = true;
    _sessionEnterTime ??= DateTime.now();
    emit(state.copyWith(isDetailExpanded: true));
  }

  void detachDetail() {
    _detailAttached = false;
    emit(state.copyWith(isDetailExpanded: false));
    if (state.isStoryComplete) {
      unawaited(stopSession());
    } else {
      unawaited(_saveReadingProgress());
    }
  }

  Future<void> beginReadingSession(StoryReadingContext context) async {
    final sameStory = state.readingContext?.storyId == context.storyId &&
        state.readingContext?.chapterId == context.chapterId;

    if (state.hasSession && sameStory) {
      attachDetail();
      if (_fullText.isNotEmpty) {
        _effectsController.add(StoryPlaybackChapterTextReady(_fullText));
      }
      // Re-apply ElevenLabs alignment so highlights match audio again.
      final cached = _cachedAudio;
      if (cached != null && cached.hasAlignment) {
        _effectsController.add(StoryPlaybackAudioReady(cached));
      }
      return;
    }

    await _resetPlaybackState();
    _loadGen++;
    _synthGen++;
    _sessionEnterTime = DateTime.now();
    _legacyStory = null;

    emit(
      state.copyWith(
        hasSession: true,
        readingContext: context,
        chapterTitle: context.chapterTitle,
        chapterNumber: context.chapterNumber,
        totalChapters: context.totalChapters,
        isStoryComplete: false,
      ),
    );
    attachDetail();

    if (context.prefetchedText != null && context.prefetchedText!.isNotEmpty) {
      _setChapterText(context.prefetchedText!);
      return;
    }

    await _loadChapterContent(context.storyId, context.chapterId);
  }

  void beginLegacyStory(Story story) {
    _legacyStory = story;
    _sessionEnterTime = DateTime.now();
    emit(
      state.copyWith(
        hasSession: true,
        chapterTitle: story.currentChapter,
        chapterNumber: 1,
        totalChapters: 1,
        isStoryComplete: false,
      ),
    );
    attachDetail();
    _setChapterText(story.fullText);
  }

  Future<void> _loadChapterContent(String storyId, String chapterId) async {
    final gen = ++_loadGen;
    emit(state.copyWith(isLoading: true, synthesisStage: 'Loading chapter...'));

    final useCase = GetChapterContentUseCase(_storiesRepo)
      ..param = GetChapterContentParams(storyId: storyId, chapterId: chapterId);

    final value = await useCase.invoke();
    if (gen != _loadGen || isClosed) return;

    final result = value.getOrElse((error) {
      _effectsController.add(StoryPlaybackError(error.toString()));
      return null;
    });

    emit(state.copyWith(isLoading: false));

    if (result == null) return;

    final text = result.fullText.trim();
    if (text.isEmpty) {
      _fullText = '';
      _effectsController.add(
        StoryPlaybackError('This chapter has no text to read.'),
      );
      return;
    }

    _setChapterText(text);
  }

  void _setChapterText(String text) {
    _fullText = text;
    _effectsController.add(StoryPlaybackChapterTextReady(text));
  }

  Future<void> togglePlay() async {
    if (state.isLoading || state.isCelebrating) return;

    if (state.isPlaying) {
      logg('[StoryPlayback] Pausing at ${state.position.inSeconds}s');
      emit(state.copyWith(isPlaying: false));
      await _player.pause();
      return;
    }

    if (state.duration > Duration.zero &&
        state.position >= state.duration) {
      emit(state.copyWith(position: Duration.zero));
    }

    if (_isLoaded && _audioFilePath != null) {
      logg('[StoryPlayback] Resuming from ${state.position.inSeconds}s');
      emit(state.copyWith(isPlaying: true));

      final playerState = _player.state;
      if (playerState == PlayerState.stopped ||
          playerState == PlayerState.completed) {
        await _player.play(
          DeviceFileSource(_audioFilePath!),
          position: state.position,
        );
      } else {
        await _safeSeek(state.position);
        await _player.resume();
      }
      await _applyPlaybackRate();
      return;
    }

    await synthesizeAndPlay();
  }

  Future<void> synthesizeAndPlay() async {
    if (state.isLoading || state.isCelebrating) return;
    if (_fullText.isEmpty) {
      _effectsController.add(
        StoryPlaybackError('This chapter has no text to read.'),
      );
      return;
    }

    final gen = ++_synthGen;
    logg('[StoryPlayback] Synthesizing chapter via ElevenLabs...');
    emit(
      state.copyWith(
        isLoading: true,
        isPlaying: false,
        synthesisProgress: 0,
      ),
    );
    _startSynthesisProgressSimulation();

    final voiceId = await _voicePreferenceStore.getSelectedVoiceId();
    if (gen != _synthGen || isClosed) return;

    final value = await SynthesizeStoryUseCase(
      _repo,
      SynthesizeStoryPayload(text: _fullText, voiceId: voiceId),
    ).invoke();

    if (gen != _synthGen || isClosed) return;

    final result = value.getOrElse((error) {
      _effectsController.add(StoryPlaybackError(error.toString()));
      return null;
    });

    if (result != null) {
      await _loadAndPlay(result, synthGen: gen);
    } else {
      _stopSynthesisProgressSimulation(complete: false);
      if (gen == _synthGen && !isClosed) {
        emit(state.copyWith(isLoading: false));
      }
    }
  }

  Future<void> _loadAndPlay(
    SynthesizedAudio audio, {
    required int synthGen,
  }) async {
    if (synthGen != _synthGen || isClosed) return;

    try {
      _clearSynthFile();
      await _player.stop();
      if (synthGen != _synthGen || isClosed) return;

      _expectedChunkCount = 1;
      _startSynthesisProgressSimulation();

      if (audio.bytes.isEmpty) {
        _stopSynthesisProgressSimulation(complete: false);
        emit(state.copyWith(isLoading: false));
        _effectsController.add(
          StoryPlaybackError('Narration audio was empty. Please try again.'),
        );
        return;
      }
      _onSynthesisChunkReceived();

      emit(
        state.copyWith(
          synthesisProgress: 0.95,
          synthesisStage: 'Finalizing audio...',
        ),
      );

      final audioFile = File(
        '${Directory.systemTemp.path}/stela_tts_${DateTime.now().millisecondsSinceEpoch}.mp3',
      );
      await audioFile.writeAsBytes(audio.bytes);
      if (synthGen != _synthGen || isClosed) {
        try {
          audioFile.deleteSync();
        } catch (_) {}
        return;
      }

      _audioFilePath = audioFile.path;
      _cachedAudio = audio;
      _effectsController.add(StoryPlaybackAudioReady(audio));

      _stopSynthesisProgressSimulation();
      await _player.play(DeviceFileSource(audioFile.path));
      await _applyPlaybackRate();

      if (synthGen != _synthGen || isClosed) return;

      _isLoaded = true;
      emit(
        state.copyWith(
          isPlaying: true,
          isLoading: false,
          synthesisProgress: 1,
          synthesisStage: 'Ready to play',
        ),
      );
    } catch (e) {
      if (synthGen != _synthGen || isClosed) return;
      _stopSynthesisProgressSimulation(complete: false);
      emit(state.copyWith(isLoading: false, isPlaying: false));
      _isLoaded = false;
      _effectsController.add(StoryPlaybackError(e.toString()));
    }
  }

  Future<void> seekTo(double seconds) async {
    logg('[StoryPlayback] Seeking to ${seconds.toStringAsFixed(1)}s');
    final maxSecs = state.duration.inMilliseconds > 0
        ? state.duration.inMilliseconds / 1000.0
        : seconds;
    final target = seconds.clamp(0.0, maxSecs);

    emit(
      state.copyWith(
        position: Duration(milliseconds: (target * 1000).round()),
      ),
    );
    // Allow the next player tick through immediately after an intentional seek.
    _lastPositionEmitAt = null;

    if (!_isLoaded || _audioFilePath == null) return;

    await _safeSeek(Duration(milliseconds: (target * 1000).round()));
  }

  Future<void> _safeSeek(Duration target) async {
    final path = _audioFilePath;
    if (path == null) return;

    try {
      final playerState = _player.state;
      if (playerState == PlayerState.stopped ||
          playerState == PlayerState.completed) {
        final shouldPlay = state.isPlaying;
        await _player.play(DeviceFileSource(path), position: target);
        await _applyPlaybackRate();
        if (!shouldPlay) {
          await _player.pause();
        }
        return;
      }

      await _player.seek(target).timeout(const Duration(seconds: 2));
    } on TimeoutException {
      logg('[StoryPlayback] seek timed out — UI position kept');
    } catch (e) {
      logg('[StoryPlayback] seek failed: $e');
    }
  }

  void nudge(int deltaSecs) {
    final maxSecs = state.duration.inMilliseconds / 1000.0;
    final raw = state.position.inMilliseconds / 1000.0 + deltaSecs;
    unawaited(seekTo(raw.clamp(0.0, maxSecs)));
  }

  Future<void> jumpToChapter(
    ChapterSummary chapter, {
    bool autoPlay = true,
    bool announce = false,
  }) async {
    if (state.isCelebrating) {
      logg('[StoryPlayback] Ignoring jumpToChapter while celebrating');
      return;
    }
    final context = state.readingContext;
    if (context == null || state.autoAdvancing) return;
    if (chapter.chapterId == context.chapterId) return;

    emit(
      state.copyWith(
        autoAdvancing: true,
        transitionMessage: announce
            ? 'Up next · ${chapter.title}'
            : 'Loading · ${chapter.title}',
      ),
    );
    _effectsController.add(
      StoryPlaybackChapterTransition(
        announce ? 'Up next · ${chapter.title}' : 'Loading · ${chapter.title}',
      ),
    );

    try {
      await _resetPlaybackState();
      _loadGen++;
      _synthGen++;

      final updated = context.copyWithChapter(chapter);
      emit(
        state.copyWith(
          readingContext: updated,
          chapterTitle: chapter.title,
          chapterNumber: chapter.chapterNumber,
          clearTransitionMessage: true,
        ),
      );

      await _loadChapterContent(context.storyId, chapter.chapterId);

      unawaited(
        _saveReadingProgress(
          overrideProgress:
              (chapter.chapterNumber - 1) / _safeTotalChapters,
        ),
      );

      if (!isClosed) {
        emit(state.copyWith(clearTransitionMessage: true));
      }
      if (autoPlay && _fullText.isNotEmpty) {
        await synthesizeAndPlay();
      }
    } finally {
      if (!isClosed) {
        emit(
          state.copyWith(autoAdvancing: false, clearTransitionMessage: true),
        );
      }
    }
  }

  Future<void> _onChapterComplete() async {
    if (_handlingChapterComplete || !state.hasSession) return;
    _handlingChapterComplete = true;

    logg('[StoryPlayback] Chapter playback completed.');
    _isLoaded = false;

    final finishingBook = state.isLastChapter;

    // Hard pause — celebration (if any) owns the gate before auto-advance.
    // Mark the book complete immediately so the mini player never reappears
    // when the reader is popped under the celebration screens.
    try {
      await _player.pause();
    } catch (_) {}
    emit(
      state.copyWith(
        isPlaying: false,
        position: state.duration,
        isCelebrating: true,
        isStoryComplete: finishingBook,
      ),
    );

    try {
      final context = state.readingContext;
      if (finishingBook && context != null) {
        await _readingProgressService.markComplete(context.storyId);
      }

      await _logChapterSession(isBookComplete: finishingBook);
      await _awaitCelebrationGate();

      if (isClosed) return;
      emit(state.copyWith(isCelebrating: false));

      if (!finishingBook && context != null) {
        await _saveReadingProgress(
          overrideProgress: state.chapterNumber / _safeTotalChapters,
        );
        final next = context.nextChapter;
        if (next != null) {
          await jumpToChapter(next, autoPlay: true, announce: true);
        }
        return;
      }

      if (finishingBook) {
        await stopSession();
      }
    } finally {
      _handlingChapterComplete = false;
    }
  }

  /// Waits until [ReadingRewardUi] finishes (or there was nothing to show).
  /// Does not time out into autoplay under a visible celebration screen.
  Future<void> _awaitCelebrationGate() async {
    final gate = _rewardUiCompleter;
    if (gate == null) return;

    try {
      await gate.future;
    } catch (_) {
      // Completer should not error; ignore if it does.
    } finally {
      if (identical(_rewardUiCompleter, gate)) {
        _rewardUiCompleter = null;
      }
    }
  }

  void _releaseCelebrationGate() {
    final gate = _rewardUiCompleter;
    if (gate != null && !gate.isCompleted) {
      gate.complete();
    }
    _rewardUiCompleter = null;
    if (!isClosed && state.isCelebrating) {
      emit(state.copyWith(isCelebrating: false));
    }
  }

  Future<void> stopSession() async {
    _releaseCelebrationGate();
    if (!state.hasSession) {
      await _mediaHandler?.clear();
      return;
    }
    await _finalizeSessionOnStop();
    await _resetPlaybackState();
    emit(state.copyWith(clearSession: true));
    await _mediaHandler?.clear();
  }

  /// Tear down playback on logout without posting a session (auth is ending).
  /// Still persists local progress so same-account restore stays accurate.
  Future<void> clearForLogout() async {
    _sessionEnterTime = null;
    _releaseCelebrationGate();
    try {
      if (state.hasSession && !state.isStoryComplete) {
        await _saveReadingProgress();
      }
    } catch (_) {}
    await _resetPlaybackState();
    if (!isClosed) emit(state.copyWith(clearSession: true));
    await _mediaHandler?.clear();
  }

  Future<void> _finalizeSessionOnStop() async {
    if (_sessionEnterTime != null) {
      final elapsed = DateTime.now().difference(_sessionEnterTime!).inSeconds;
      final chapterId = state.currentChapterId;
      if (elapsed >= 60 &&
          chapterId != null &&
          !_loggedChapterIds.contains(chapterId) &&
          (_isLoaded || state.position > Duration.zero)) {
        unawaited(_logChapterSession(isBookComplete: false));
      }
    }

    if (!state.isStoryComplete) {
      await _saveReadingProgress();
    }
    _sessionEnterTime = null;
  }

  Future<void> onDetailDisposed() async {
    // If the reader leaves while a gate is open, don't leave playback stuck.
    _releaseCelebrationGate();
    detachDetail();
  }

  Future<void> _resetPlaybackState() async {
    _stopSynthesisProgressSimulation(complete: false);
    // Invalidate any in-flight chapter load / TTS so stale completions no-op.
    _loadGen++;
    _synthGen++;
    _clearSynthFile();
    _cachedAudio = null;
    _isLoaded = false;
    _fullText = '';
    await _player.stop();
    if (isClosed) return;
    emit(
      state.copyWith(
        position: Duration.zero,
        duration: Duration.zero,
        isPlaying: false,
        isLoading: false,
        synthesisProgress: 0,
        synthesisStage: 'Preparing your story...',
      ),
    );
  }

  void _clearSynthFile() {
    if (_audioFilePath != null) {
      try {
        File(_audioFilePath!).deleteSync();
      } catch (_) {}
    }
    _audioFilePath = null;
  }

  void _startSynthesisProgressSimulation() {
    _synthesisStageTimer?.cancel();
    _chunksReceived = 0;
    _updateSynthesisStage(0);

    _synthesisStageTimer = Timer.periodic(const Duration(milliseconds: 350), (_) {
      if (isClosed || !state.isLoading) return;

      final chunkTarget = _expectedChunkCount > 0
          ? (_chunksReceived / _expectedChunkCount * 0.92).clamp(0.0, 0.92)
          : 0.06;

      var progress = state.synthesisProgress;
      if (progress < chunkTarget) {
        progress = (progress + 0.015).clamp(0.0, chunkTarget);
      } else if (_chunksReceived == 0 && progress < 0.1) {
        progress = (progress + 0.008).clamp(0.0, 0.1);
      }

      _emitSynthesis(progress);
    });
  }

  void _stopSynthesisProgressSimulation({bool complete = true}) {
    _synthesisStageTimer?.cancel();
    _synthesisStageTimer = null;
    if (complete) {
      emit(
        state.copyWith(
          synthesisProgress: 1,
          synthesisStage: 'Ready to play',
        ),
      );
    }
  }

  void _onSynthesisChunkReceived() {
    _chunksReceived++;
    if (_expectedChunkCount <= 0) return;
    _emitSynthesis(
      (_chunksReceived / _expectedChunkCount * 0.92).clamp(0.0, 0.92),
    );
  }

  void _updateSynthesisStage(double p) {
    _emitSynthesis(p);
  }

  void _emitSynthesis(double progress) {
    if (isClosed) return;
    final stage = _stageForProgress(progress);
    if (state.synthesisProgress == progress && state.synthesisStage == stage) {
      return;
    }
    emit(
      state.copyWith(
        synthesisProgress: progress,
        synthesisStage: stage,
      ),
    );
  }

  static String _stageForProgress(double p) {
    if (p < 0.12) return 'Warming up the narrator...';
    if (p < 0.32) return 'Phonemizing your chapter...';
    if (p < 0.58) return 'Generating voice audio...';
    if (p < 0.82) return 'Blending audio together...';
    return 'Almost ready...';
  }

  Future<SessionLogResult?> _logChapterSession({
    required bool isBookComplete,
  }) async {
    final chapterId = state.currentChapterId;
    if (chapterId == null || _loggedChapterIds.contains(chapterId)) return null;

    final readingContext = state.readingContext;
    final story = _legacyStory;
    if (readingContext == null && story == null) return null;

    final genre = _normalizeGenre(readingContext?.genre ?? story!.category);

    final useCase = LogSessionUseCase(_sessionRepo)
      ..param = LogSessionParams(
        bookId: readingContext?.storyId ?? story!.id,
        bookTitle: readingContext?.storyTitle ?? story!.title,
        genre: genre,
        chapterId: chapterId,
        isAudioSession: _isLoaded || state.duration > Duration.zero,
        isBookComplete: isBookComplete,
        speedMultiplier:
            getIt.get<ReadingPreferencesCubit>().state.textSpeed,
      );

    final value = await useCase.invoke();
    final result = value.getOrElse((error) {
      if (_detailAttached) {
        _effectsController.add(StoryPlaybackError(error.toString()));
      }
      return null;
    });

    if (result == null || !result.success) return null;

    _loggedChapterIds.add(chapterId);

    if (result.alreadyLogged == true) return result;

    final sessionMinutes = _sessionMinutesForLog();

    _rewardUiCompleter = Completer<void>();
    if (_detailAttached) {
      _effectsController.add(
        StoryPlaybackReward(
          ReadingRewardEvent(
            result: result,
            isBookComplete: isBookComplete,
            storyTitle: readingContext?.storyTitle ?? story?.title,
            chapterNumber: state.chapterNumber,
            sessionMinutes: sessionMinutes,
            uiCompleter: _rewardUiCompleter,
          ),
        ),
      );
    } else {
      unawaited(
        getIt.get<GamificationCubit>().applySessionResult(
          result,
          isBookComplete: isBookComplete,
          sessionMinutes: sessionMinutes,
        ),
      );
      _rewardUiCompleter!.complete();
    }

    return result;
  }

  int _sessionMinutesForLog() {
    if (_sessionEnterTime != null) {
      return DateTime.now()
          .difference(_sessionEnterTime!)
          .inMinutes
          .clamp(1, 240);
    }
    if (state.duration > Duration.zero) {
      return (state.position.inSeconds / 60).ceil().clamp(1, 240);
    }
    return 1;
  }

  Future<void> _saveReadingProgress({double? overrideProgress}) async {
    final context = state.readingContext;
    if (context == null || state.isStoryComplete) return;
    if (state.totalChapters <= 0 && overrideProgress == null) return;

    final total = _safeTotalChapters;
    double progress;
    if (overrideProgress != null) {
      progress = overrideProgress;
    } else if (state.duration > Duration.zero) {
      final chapterFraction =
          state.position.inSeconds / state.duration.inSeconds;
      progress = ((state.chapterNumber - 1) + chapterFraction) / total;
    } else {
      progress = (state.chapterNumber - 1) / total;
    }

    progress = progress.clamp(0.0, 0.99);

    await _readingProgressService.save(
      ReadingProgress(
        storyId: context.storyId,
        title: context.storyTitle,
        coverImageUrl: context.coverImageUrl,
        genre: context.genre,
        readingTime: context.readingTime,
        totalChapters: context.totalChapters,
        chapterId: context.chapterId,
        chapterTitle: context.chapterTitle,
        chapterNumber: context.chapterNumber,
        progress: progress,
        lastReadAtMs: DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  String _normalizeGenre(String genre) {
    final value = genre.trim().toLowerCase();
    const supportedGenres = {
      'fantasy',
      'sci-fi',
      'romance',
      'thriller',
      'mystery',
      'ocean',
      'history',
      'biography',
      'other',
    };

    return supportedGenres.contains(value) ? value : 'other';
  }

  Future<void> _applyPlaybackRate([double? speed]) async {
    final rate = speed ??
        getIt.get<ReadingPreferencesCubit>().state.textSpeed;
    try {
      await _player.setPlaybackRate(rate);
    } catch (e) {
      logg('[StoryPlayback] Failed to set playback rate: $e');
    }
  }

  @override
  Future<void> close() async {
    await _readingPrefsSub?.cancel();
    _mediaSyncSub?.cancel();
    await _completeSub?.cancel();
    await _durationSub?.cancel();
    await _positionSub?.cancel();
    _mediaHandler?.unbind();
    _stopSynthesisProgressSimulation(complete: false);
    _clearSynthFile();
    await _mediaHandler?.clear();
    await _player.dispose();
    await _effectsController.close();
    return super.close();
  }
}
