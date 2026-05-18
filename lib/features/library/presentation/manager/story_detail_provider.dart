// import 'package:stela_mobile/core/presentation/utils/helper_functions.dart';
// import 'package:flutter/material.dart';
// import 'package:stela_mobile/core/presentation/manager/custom_provider.dart';
// import 'package:stela_mobile/features/profile/presentation/manager/profile_provider.dart';
// import 'package:provider/provider.dart';
// import 'package:stela_mobile/features/library/presentation/manager/tts_service.dart';

// class StoryDetailProvider extends CustomProvider {
//   // ── Playback state ──────────────────────────────────────────────────────────
//   final Duration totalDuration = const Duration(hours: 0, minutes: 2);
//   Duration position = const Duration(minutes: 0, seconds: 0);
//   bool isPlaying = false;
//   bool lyricsInitialized = false;

//   // ── TTS state ────────────────────────────────────────────────────────────
//   late final TtsService ttsService;
//   bool isMaleVoice = false;
//   String fullText = "";

//   // ── Lyrics state ────────────────────────────────────────────────────────────
//   List<String> lines = [];
//   List<GlobalKey> lineKeys = [];
//   List<int> lineCueSecs = []; // playback-second at which each line starts
//   List<int> lineStartOffsets = [];
//   int currentLine = 0;
//   int _currentTtsSubstringOffset = 0;

//   final ScrollController scrollController = ScrollController();

//   late final DateTime _enterTime;
//   Function(int index)? _scrollToLineCallback;

//   StoryDetailProvider() {
//     _enterTime = DateTime.now();
//     ttsService = TtsService();

//     ttsService.onStart = () {
//       isPlaying = true;
//       notifyListeners();
//     };

//     ttsService.onComplete = () {
//       logg('[StoryDetailProvider] Playback completed automatically.');
//       isPlaying = false;
//       position = totalDuration;
//       notifyListeners();
//     };

//     ttsService.onProgress = (text, start, end, word) {
//       final int absoluteStart = start + _currentTtsSubstringOffset;
//       final newLine = _lineIndexAtChar(absoluteStart);
//       final double progress = absoluteStart / fullText.length;

//       position = Duration(seconds: (totalDuration.inSeconds * progress).toInt());

//       if (newLine != currentLine) {
//         currentLine = newLine;
//         scrollToLine(currentLine);
//       }
//       notifyListeners();
//     };

//     ttsService.initTts();
//   }

//   void initLyrics(String text, Function(int index) scrollCb) {
//     if (lyricsInitialized) return;
//     logg('[StoryDetailProvider] Initializing Lyrics and TTS duration...');
//     lyricsInitialized = true;
//     _scrollToLineCallback = scrollCb;
//     fullText = text;

//     // Split on sentence-ending punctuation or commas followed by whitespace
//     lines = fullText
//         .split(RegExp(r'(?<=[.!?,])\s+'))
//         .map((l) => l.trim())
//         .where((l) => l.isNotEmpty)
//         .toList();

//     lineKeys = List.generate(lines.length, (_) => GlobalKey());

//     // Compute char offsets for each line
//     lineStartOffsets = [];
//     int currentOffset = 0;
//     for (String line in lines) {
//       int idx = fullText.indexOf(line, currentOffset);
//       if (idx == -1) idx = currentOffset; // fallback
//       lineStartOffsets.add(idx);
//       currentOffset = idx + line.length;
//     }

//     // Mock duration spread for manual seeks
//     const secsPerLine = 3;
//     lineCueSecs = List.generate(lines.length, (i) => i * secsPerLine);
//     currentLine = 0;
//     notifyListeners();
//   }

//   int _lineIndexAtChar(int charOffset) {
//     int idx = 0;
//     for (int i = 0; i < lineStartOffsets.length; i++) {
//       if (lineStartOffsets[i] <= charOffset) idx = i;
//     }
//     return idx;
//   }

//   int _lineIndexAtSec(int seconds) {
//     int idx = 0;
//     for (int i = 0; i < lineCueSecs.length; i++) {
//       if (lineCueSecs[i] <= seconds) idx = i;
//     }
//     return idx;
//   }

//   Future<void> togglePlay() async {
//     if (isPlaying) {
//       logg('[StoryDetailProvider] Pausing playback at ${position.inSeconds}s');
//       isPlaying = false;
//       notifyListeners();
//       await ttsService.pause();
//     } else {
//       if (position >= totalDuration) {
//         logg('[StoryDetailProvider] Re-starting playback from the beginning.');
//         position = Duration.zero;
//         currentLine = 0;
//         scrollToLine(currentLine, animated: true);
//       }

//       logg('[StoryDetailProvider] Resuming playback from ${position.inSeconds}s');
//       String textToPlay = fullText;
//       _currentTtsSubstringOffset = 0;
//       if (position.inSeconds > 0 && currentLine < lineStartOffsets.length) {
//          _currentTtsSubstringOffset = lineStartOffsets[currentLine];
//          textToPlay = fullText.substring(_currentTtsSubstringOffset);
//       }
//       isPlaying = true;
//       notifyListeners();
//       await ttsService.play(textToPlay);
//     }
//   }

//   Future<void> seekTo(double seconds) async {
//     logg('[StoryDetailProvider] Seeking to ${seconds.toInt()}s');
//     position = Duration(seconds: seconds.toInt());
//     currentLine = _lineIndexAtSec(position.inSeconds);
//     scrollToLine(currentLine, animated: false);

//     if (isPlaying) {
//       isPlaying = false;
//       notifyListeners();
//       await ttsService.stop();
//       await togglePlay();
//     } else {
//       notifyListeners();
//     }
//   }

//   void nudge(int deltaSecs) {
//     final raw = position.inSeconds + deltaSecs;
//     seekTo(raw.clamp(0, totalDuration.inSeconds).toDouble());
//   }

//   Future<void> changeVoice(bool isMale) async {
//     logg('[StoryDetailProvider] Changing voice... isMale: $isMale');
//     isMaleVoice = isMale;
//     notifyListeners();

//     if (isMale) {
//       await ttsService.setMaleVoice();
//     } else {
//       await ttsService.setFemaleVoice();
//     }

//     if (isPlaying) {
//       logg('[StoryDetailProvider] Stopping current TTS to apply new voice.');
//       isPlaying = false;
//       notifyListeners();
//       await ttsService.stop();
//       await togglePlay();
//     }
//   }

//   void scrollToLine(int index, {bool animated = true}) {
//     if (_scrollToLineCallback != null) {
//       _scrollToLineCallback!(index);
//     }
//   }

//   void disposeProvider(BuildContext context) {
//     final elapsedSeconds = DateTime.now().difference(_enterTime).inSeconds;
//     if (elapsedSeconds >= 60) {
//       if (context.mounted) {
//         logg('Updating reading stats: $elapsedSeconds seconds');
//         Provider.of<ProfileProvider>(context, listen: false).updateReadingStats(durationInSeconds: elapsedSeconds);
//       }
//     }

//     ttsService.dispose();
//     scrollController.dispose();
//   }
// }

// features/library/presentation/manager/story_detail_provider.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:stela_mobile/core/di/core_module_container.dart';
import 'package:stela_mobile/core/presentation/manager/custom_provider.dart';
import 'package:stela_mobile/core/presentation/utils/helper_functions.dart';
import 'package:stela_mobile/features/library/domain/repository/library_repository.dart';
import 'package:stela_mobile/features/library/domain/usecase/get_voices_usecase.dart';
import 'package:stela_mobile/features/library/domain/usecase/synthesize_story_usecase.dart';
import 'package:stela_mobile/features/profile/presentation/manager/profile_provider.dart';

class StoryDetailProvider extends CustomProvider {
  final _repo = getIt.get<LibraryRepository>();
  final _player = AudioPlayer();

  // Swap these from your ElevenLabs dashboard.
  static const _femaleVoiceId = 'yM93hbw8Qtvdma2wCnJG';
  static const _maleVoiceId = 'MFZUKuGQUsGJPQjTS4wC';

  // ── Playback state ──────────────────────────────────────────────────────────
  Duration totalDuration = Duration.zero;
  Duration position = Duration.zero;
  bool isPlaying = false;
  bool isLoading = false;
  bool lyricsInitialized = false;
  bool _isLoaded = false;

  // ── TTS state ───────────────────────────────────────────────────────────────
  bool isMaleVoice = true;
  String fullText = '';

  // ── Lyrics state ────────────────────────────────────────────────────────────
  List<String> lines = [];
  List<GlobalKey> lineKeys = [];
  List<int> lineCueSecs = [];
  int currentLine = 0;

  final ScrollController scrollController = ScrollController();
  late final DateTime _enterTime;
  Function(int index)? _scrollToLineCallback;

  StoryDetailProvider() {
    _enterTime = DateTime.now();
    _initPlayerListeners();
  }

  void _initPlayerListeners() {
    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        logg('[StoryDetailProvider] Playback completed.');
        _isLoaded = false;
        isPlaying = false;
        position = totalDuration;
        notifyListeners();
      }
    });

    _player.positionStream.listen((pos) {
      final total = _player.duration ?? Duration.zero;
      if (total == Duration.zero) return;

      position = pos;
      totalDuration = total;

      final newLine = _lineIndexAtSec(pos.inSeconds);
      if (newLine != currentLine) {
        currentLine = newLine;
        scrollToLine(currentLine);
      }
      notifyListeners();
    });
  }

  void initLyrics(String text, Function(int index) scrollCb) {
    if (lyricsInitialized) return;
    logg('[StoryDetailProvider] Initializing lyrics...');

    lyricsInitialized = true;
    _scrollToLineCallback = scrollCb;
    fullText = text;

    lines = fullText
        .split(RegExp(r'(?<=[.!?,])\s+'))
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    lineKeys = List.generate(lines.length, (_) => GlobalKey());
    lineCueSecs = List.generate(lines.length, (i) => i * 3);
    currentLine = 0;
    notifyListeners();
  }

  Future<void> togglePlay() async {
    if (isPlaying) {
      logg('[StoryDetailProvider] Pausing at ${position.inSeconds}s');
      isPlaying = false;
      notifyListeners();
      await _player.pause();
      return;
    }

    if (position >= totalDuration && totalDuration > Duration.zero) {
      logg('[StoryDetailProvider] Restarting from beginning.');
      position = Duration.zero;
      currentLine = 0;
      scrollToLine(currentLine, animated: true);
    }

    // Audio already in player (paused mid-story) → just resume.
    if (_isLoaded) {
      logg('[StoryDetailProvider] Resuming from ${position.inSeconds}s');
      isPlaying = true;
      notifyListeners();
      await _player.play();
      return;
    }

    // First play or after voice change → call ElevenLabs.
    _synthesizeAndPlay();
  }

  void _synthesizeAndPlay() {
    logg('[StoryDetailProvider] Synthesizing via ElevenLabs...');
    isLoading = true;
    notifyListeners();

    final voiceId = isMaleVoice ? _maleVoiceId : _femaleVoiceId;

    SynthesizeStoryUseCase(
      _repo,
      SynthesizeStoryPayload(text: fullText, voiceId: voiceId),
    ).invoke().then((value) {
      final result = value.getOrElse((error) {
        add(error);
        return null;
      });

      if (result != null) {
        _loadAndPlay(result);
      }
      isLoading = false;
      notifyListeners();
    });
  }

  void getAvailableVoices() {
    GetVoicesUseCase(_repo).invoke().then((value) {
      final result = value.getOrElse((error) {
        add(error);
        return null;
      });

      if (result != null) {
        add(result);
        // result.map((voice){
        //   logg(voice.name);
        // }).toList();
        // _availableVoices = result;
      }
    });
  }

  Future<void> _loadAndPlay(Uint8List bytes) async {
    try {
      await _player.setAudioSource(_BytesAudioSource(bytes));
      _isLoaded = true;
      isLoading = false;
      isPlaying = true;
      notifyListeners();
      await _player.play();
    } catch (e) {
      isLoading = false;
      isPlaying = false;
      _isLoaded = false;
      add(e.toString());
      notifyListeners();
    }
  }

  Future<void> seekTo(double seconds) async {
    logg('[StoryDetailProvider] Seeking to ${seconds.toInt()}s');
    final target = Duration(seconds: seconds.toInt());
    position = target;
    currentLine = _lineIndexAtSec(target.inSeconds);
    scrollToLine(currentLine, animated: false);
    await _player.seek(target);
    notifyListeners();
  }

  void nudge(int deltaSecs) {
    final raw = position.inSeconds + deltaSecs;
    seekTo(raw.clamp(0, totalDuration.inSeconds).toDouble());
  }

  Future<void> changeVoice(bool isMale) async {
    logg('[StoryDetailProvider] Changing voice. isMale: $isMale');
    isMaleVoice = isMale;

    if (isPlaying) {
      isPlaying = false;
      notifyListeners();
      await _player.stop();
    }

    // Force re-synthesis with the new voice on next togglePlay.
    _isLoaded = false;
    position = Duration.zero;
    currentLine = 0;
    notifyListeners();

    await togglePlay();
  }

  void scrollToLine(int index, {bool animated = true}) {
    _scrollToLineCallback?.call(index);
  }

  void disposeProvider(BuildContext context) {
    final elapsed = DateTime.now().difference(_enterTime).inSeconds;
    if (elapsed >= 60 && context.mounted) {
      logg('Updating reading stats: $elapsed seconds');
      Provider.of<ProfileProvider>(
        context,
        listen: false,
      ).updateReadingStats(durationInSeconds: elapsed);
    }
    _player.dispose();
    scrollController.dispose();
  }

  int _lineIndexAtSec(int seconds) {
    int idx = 0;
    for (int i = 0; i < lineCueSecs.length; i++) {
      if (lineCueSecs[i] <= seconds) idx = i;
    }
    return idx;
  }
}

// just_audio needs a StreamAudioSource to play in-memory bytes.
class _BytesAudioSource extends StreamAudioSource {
  final Uint8List _bytes;
  _BytesAudioSource(this._bytes);

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    start ??= 0;
    end ??= _bytes.length;
    return StreamAudioResponse(
      sourceLength: _bytes.length,
      contentLength: end - start,
      offset: start,
      stream: Stream.value(_bytes.sublist(start, end)),
      contentType: 'audio/mpeg',
    );
  }
}
