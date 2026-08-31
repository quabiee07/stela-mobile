import 'package:audioplayers/audioplayers.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stela_mobile/core/di/core_module_container.dart';
import 'package:stela_mobile/features/library/data/services/voice_preference_store.dart';
import 'package:stela_mobile/features/library/domain/models/narrator_voice.dart';
import 'package:stela_mobile/features/library/domain/repository/library_repository.dart';

class VoicePickerState extends Equatable {
  const VoicePickerState({
    this.selectedVoiceId = NarratorVoiceCatalog.defaultVoiceId,
    this.previewingVoiceId,
    this.previewProgress,
    this.isLoadingPreviews = false,
    this.voices = NarratorVoiceCatalog.all,
    this.genderFilter,
    this.errorMessage,
  });

  final String selectedVoiceId;
  final String? previewingVoiceId;

  /// 0–1 while a preview is playing; null means indeterminate / buffering.
  final double? previewProgress;
  final bool isLoadingPreviews;
  final List<NarratorVoice> voices;
  final NarratorGender? genderFilter;
  final String? errorMessage;

  List<NarratorVoice> get visibleVoices {
    if (genderFilter == null) return voices;
    return voices.where((v) => v.gender == genderFilter).toList();
  }

  VoicePickerState copyWith({
    String? selectedVoiceId,
    String? previewingVoiceId,
    bool clearPreviewing = false,
    double? previewProgress,
    bool clearPreviewProgress = false,
    bool? isLoadingPreviews,
    List<NarratorVoice>? voices,
    NarratorGender? genderFilter,
    bool clearGenderFilter = false,
    String? errorMessage,
    bool clearError = false,
  }) {
    return VoicePickerState(
      selectedVoiceId: selectedVoiceId ?? this.selectedVoiceId,
      previewingVoiceId:
          clearPreviewing ? null : (previewingVoiceId ?? this.previewingVoiceId),
      previewProgress: clearPreviewing || clearPreviewProgress
          ? null
          : (previewProgress ?? this.previewProgress),
      isLoadingPreviews: isLoadingPreviews ?? this.isLoadingPreviews,
      voices: voices ?? this.voices,
      genderFilter:
          clearGenderFilter ? null : (genderFilter ?? this.genderFilter),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        selectedVoiceId,
        previewingVoiceId,
        previewProgress,
        isLoadingPreviews,
        voices,
        genderFilter,
        errorMessage,
      ];
}

class VoicePickerCubit extends Cubit<VoicePickerState> {
  VoicePickerCubit({
    LibraryRepository? repository,
    VoicePreferenceStore? preferenceStore,
    AudioPlayer? previewPlayer,
  })  : _repository = repository ?? getIt.get<LibraryRepository>(),
        _preferenceStore =
            preferenceStore ?? getIt.get<VoicePreferenceStore>(),
        _previewPlayer = previewPlayer ?? AudioPlayer(),
        super(const VoicePickerState()) {
    _previewPlayer.onPositionChanged.listen(_onPreviewPosition);
    _previewPlayer.onDurationChanged.listen((duration) {
      _previewDuration = duration;
    });
    _bootstrap();
  }

  final LibraryRepository _repository;
  final VoicePreferenceStore _preferenceStore;
  final AudioPlayer _previewPlayer;
  Duration _previewDuration = Duration.zero;
  double _lastEmittedProgress = -1;

  void _safeEmit(VoicePickerState next) {
    if (!isClosed) emit(next);
  }

  void _onPreviewPosition(Duration position) {
    if (isClosed || state.previewingVoiceId == null) return;
    final totalMs = _previewDuration.inMilliseconds;
    if (totalMs <= 0) {
      if (state.previewProgress != null) {
        _safeEmit(state.copyWith(clearPreviewProgress: true));
      }
      return;
    }
    final progress = (position.inMilliseconds / totalMs).clamp(0.0, 1.0);
    // Bucket to ~2% steps to avoid rebuilding the grid every tick.
    if ((progress - _lastEmittedProgress).abs() < 0.02 && progress < 1.0) {
      return;
    }
    _lastEmittedProgress = progress;
    _safeEmit(state.copyWith(previewProgress: progress));
  }

  Future<void> _bootstrap() async {
    final selected = await _preferenceStore.getSelectedVoiceId();
    if (isClosed) return;
    _safeEmit(state.copyWith(selectedVoiceId: selected));
    await refreshPreviewUrls();
  }

  void setGenderFilter(NarratorGender? gender) {
    if (gender == null) {
      _safeEmit(state.copyWith(clearGenderFilter: true));
    } else {
      _safeEmit(state.copyWith(genderFilter: gender));
    }
  }

  Future<void> selectVoice(String voiceId) async {
    _safeEmit(state.copyWith(selectedVoiceId: voiceId, clearError: true));
    await _preferenceStore.setSelectedVoiceId(voiceId);
  }

  /// Selects the voice and starts (or stops) its preview sample.
  Future<void> selectAndPreview(NarratorVoice voice) async {
    await selectVoice(voice.id);
    await previewVoice(voice);
  }

  Future<void> refreshPreviewUrls() async {
    _safeEmit(state.copyWith(isLoadingPreviews: true, clearError: true));
    final result = await _repository.getAvailableVoices();
    if (isClosed) return;

    final remote = result.getOrElse((error) {
      _safeEmit(
        state.copyWith(
          isLoadingPreviews: false,
          errorMessage: error.toString(),
        ),
      );
      return null;
    });

    if (remote == null || isClosed) return;

    final byId = {for (final voice in remote) voice.voiceId: voice};
    final enriched = NarratorVoiceCatalog.all.map((voice) {
      final match = byId[voice.id];
      if (match == null || match.previewUrl.isEmpty) return voice;
      return voice.copyWith(previewUrl: match.previewUrl);
    }).toList(growable: false);

    _safeEmit(state.copyWith(voices: enriched, isLoadingPreviews: false));
  }

  Future<void> previewVoice(NarratorVoice voice) async {
    final url = voice.previewUrl;
    if (url == null || url.isEmpty) {
      _safeEmit(
        state.copyWith(
          errorMessage: 'Preview isn’t available for ${voice.name} yet.',
        ),
      );
      return;
    }

    try {
      if (state.previewingVoiceId == voice.id) {
        await _previewPlayer.stop();
        _previewDuration = Duration.zero;
        _lastEmittedProgress = -1;
        _safeEmit(state.copyWith(clearPreviewing: true));
        return;
      }

      _previewDuration = Duration.zero;
      _lastEmittedProgress = -1;
      _safeEmit(
        state.copyWith(
          previewingVoiceId: voice.id,
          clearPreviewProgress: true,
          clearError: true,
        ),
      );
      await _previewPlayer.stop();
      if (isClosed) return;
      await _previewPlayer.play(UrlSource(url));
      _previewPlayer.onPlayerComplete.first.then((_) {
        if (!isClosed && state.previewingVoiceId == voice.id) {
          _previewDuration = Duration.zero;
          _lastEmittedProgress = -1;
          _safeEmit(state.copyWith(clearPreviewing: true));
        }
      });
    } catch (e) {
      _previewDuration = Duration.zero;
      _lastEmittedProgress = -1;
      _safeEmit(
        state.copyWith(
          clearPreviewing: true,
          errorMessage: 'Couldn’t play preview. Check your connection.',
        ),
      );
    }
  }

  Future<void> stopPreview() async {
    await _previewPlayer.stop();
    _previewDuration = Duration.zero;
    _lastEmittedProgress = -1;
    _safeEmit(state.copyWith(clearPreviewing: true));
  }

  @override
  Future<void> close() async {
    await _previewPlayer.stop();
    await _previewPlayer.dispose();
    return super.close();
  }
}
