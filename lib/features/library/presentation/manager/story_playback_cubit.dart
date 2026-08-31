import 'dart:async';
import 'dart:io';

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

  String get fullText => _fullText;

  bool get isLoaded => _isLoaded;

  Future<void> _initPlayer() async {
    await _player.setPlayerMode(PlayerMode.mediaPlayer);
    await _player.setReleaseMode(ReleaseMode.stop);

    _player.onPlayerComplete.listen((_) {
      unawaited(_onChapterComplete());
    });

    _player.onDurationChanged.listen((dur) {
      emit(state.copyWith(duration: dur));
    });

    _player.onPositionChanged.listen((pos) {
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
    if (!state.isStoryComplete) {
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
    emit(state.copyWith(isLoading: true, synthesisStage: 'Loading chapter...'));

    final useCase = GetChapterContentUseCase(_storiesRepo)
      ..param = GetChapterContentParams(storyId: storyId, chapterId: chapterId);

    final value = await useCase.invoke();
    final result = value.getOrElse((error) {
      _effectsController.add(StoryPlaybackError(error.toString()));
      return null;
    });

    emit(state.copyWith(isLoading: false));

    if (result != null) {
      _setChapterText(result.fullText);
    }
  }

  void _setChapterText(String text) {
    _fullText = text;
    _effectsController.add(StoryPlaybackChapterTextReady(text));
  }

  Future<void> togglePlay() async {
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
    if (_fullText.isEmpty) return;

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

    final value = await SynthesizeStoryUseCase(
      _repo,
      SynthesizeStoryPayload(text: _fullText, voiceId: voiceId),
    ).invoke();

    final result = value.getOrElse((error) {
      _effectsController.add(StoryPlaybackError(error.toString()));
      return null;
    });

    if (result != null) {
      await _loadAndPlay(result);
    } else {
      _stopSynthesisProgressSimulation(complete: false);
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> _loadAndPlay(SynthesizedAudio audio) async {
    try {
      _clearSynthFile();
      await _player.stop();

      _expectedChunkCount = 1;
      _startSynthesisProgressSimulation();

      if (audio.bytes.isEmpty) {
        _stopSynthesisProgressSimulation(complete: false);
        emit(state.copyWith(isLoading: false));
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

      _audioFilePath = audioFile.path;
      _cachedAudio = audio;
      _effectsController.add(StoryPlaybackAudioReady(audio));

      _stopSynthesisProgressSimulation();
      await _player.play(DeviceFileSource(audioFile.path));
      await _applyPlaybackRate();

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
          overrideProgress: (chapter.chapterNumber - 1) / state.totalChapters,
        ),
      );

      emit(state.copyWith(clearTransitionMessage: true));
      if (autoPlay && _fullText.isNotEmpty) {
        await synthesizeAndPlay();
      }
    } finally {
      emit(state.copyWith(autoAdvancing: false, clearTransitionMessage: true));
    }
  }

  Future<void> _onChapterComplete() async {
    logg('[StoryPlayback] Chapter playback completed.');
    _isLoaded = false;
    emit(
      state.copyWith(
        isPlaying: false,
        position: state.duration,
      ),
    );

    await _logChapterSession(isBookComplete: state.isLastChapter);

    if (_rewardUiCompleter != null) {
      try {
        await _rewardUiCompleter!.future.timeout(const Duration(seconds: 8));
      } catch (_) {}
      _rewardUiCompleter = null;
    }

    final context = state.readingContext;
    if (context != null) {
      if (state.isLastChapter) {
        await _readingProgressService.markComplete(context.storyId);
      } else {
        await _saveReadingProgress(
          overrideProgress: state.chapterNumber / state.totalChapters,
        );
      }
    }

    if (context != null && !state.isLastChapter) {
      final next = context.nextChapter;
      if (next != null) {
        await jumpToChapter(next, autoPlay: true, announce: true);
      }
      return;
    }

    emit(state.copyWith(isStoryComplete: true));
  }

  Future<void> stopSession() async {
    await _finalizeSessionOnStop();
    await _resetPlaybackState();
    emit(state.copyWith(clearSession: true));
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
    detachDetail();
  }

  Future<void> _resetPlaybackState() async {
    _stopSynthesisProgressSimulation(complete: false);
    _clearSynthFile();
    _cachedAudio = null;
    _isLoaded = false;
    await _player.stop();
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
      if (!state.isLoading) return;

      final chunkTarget = _expectedChunkCount > 0
          ? (_chunksReceived / _expectedChunkCount * 0.92).clamp(0.0, 0.92)
          : 0.06;

      var progress = state.synthesisProgress;
      if (progress < chunkTarget) {
        progress = (progress + 0.015).clamp(0.0, chunkTarget);
      } else if (_chunksReceived == 0 && progress < 0.1) {
        progress = (progress + 0.008).clamp(0.0, 0.1);
      }

      _updateSynthesisStage(progress);
      emit(state.copyWith(synthesisProgress: progress));
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
    if (_expectedChunkCount > 0) {
      emit(
        state.copyWith(
          synthesisProgress: (_chunksReceived / _expectedChunkCount * 0.92)
              .clamp(0.0, 0.92),
        ),
      );
    }
    _updateSynthesisStage(state.synthesisProgress);
  }

  void _updateSynthesisStage(double p) {
    String stage;
    if (p < 0.12) {
      stage = 'Warming up the narrator...';
    } else if (p < 0.32) {
      stage = 'Phonemizing your chapter...';
    } else if (p < 0.58) {
      stage = 'Generating voice audio...';
    } else if (p < 0.82) {
      stage = 'Blending audio together...';
    } else {
      stage = 'Almost ready...';
    }
    emit(state.copyWith(synthesisStage: stage));
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

    double progress;
    if (overrideProgress != null) {
      progress = overrideProgress;
    } else if (state.duration > Duration.zero) {
      final chapterFraction =
          state.position.inSeconds / state.duration.inSeconds;
      progress =
          ((state.chapterNumber - 1) + chapterFraction) / state.totalChapters;
    } else {
      progress = (state.chapterNumber - 1) / state.totalChapters;
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
    _mediaHandler?.unbind();
    _stopSynthesisProgressSimulation(complete: false);
    _clearSynthFile();
    await _mediaHandler?.clear();
    await _player.dispose();
    await _effectsController.close();
    return super.close();
  }
}
