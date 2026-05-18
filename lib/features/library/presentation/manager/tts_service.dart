import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  final FlutterTts _flutterTts = FlutterTts();

  Function()? onStart;
  Function()? onComplete;
  Function(String, int, int, String)? onProgress;
  Function(String)? onError;

  Future<void> initTts() async {
    try {
      await _flutterTts.stop();
      await _flutterTts.awaitSpeakCompletion(true);
      await _flutterTts.setLanguage("en-US");
      await _flutterTts.setSharedInstance(true);
      await _flutterTts.setIosAudioCategory(
        IosTextToSpeechAudioCategory.playback,
        [
          IosTextToSpeechAudioCategoryOptions.allowBluetooth,
          IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
          IosTextToSpeechAudioCategoryOptions.mixWithOthers,
        ],
        IosTextToSpeechAudioMode.defaultMode,
      );

      _flutterTts.setStartHandler(() {
        if (onStart != null) onStart!();
      });

      _flutterTts.setCompletionHandler(() {
        if (onComplete != null) onComplete!();
      });

      _flutterTts.setProgressHandler((text, start, end, word) {
        if (onProgress != null) onProgress!(text, start, end, word);
      });

      _flutterTts.setErrorHandler((msg) {
        if (onError != null) onError!(msg.toString());
      });

      // Default to female soft
      await setFemaleVoice();
    } catch (e) {
      debugPrint('Error initializing TTS: $e');
    }
  }

  Future<void> setMaleVoice() async {
    await _flutterTts.setPitch(0.8);
    await _flutterTts.setSpeechRate(0.4);
    try {
      await _flutterTts.setVoice({
        "name": "en-us-x-tpd-local",
        "locale": "en-US",
      });
    } catch (e) {
      debugPrint('Error setting male voice: $e');
    }
  }

  Future<void> setFemaleVoice() async {
    await _flutterTts.setPitch(1.2);
    await _flutterTts.setSpeechRate(0.5);
    try {
      await _flutterTts.setVoice({
        "name": "en-us-x-sfg-local",
        "locale": "en-US",
      });
    } catch (e) {
      debugPrint('Error setting female voice: $e');
    }
  }

  Future<void> play(String text) async {
    if (text.isNotEmpty) {
      await _flutterTts.speak(text);
    }
  }

  Future<void> pause() async {
    await _flutterTts.pause();
  }

  Future<void> stop() async {
    await _flutterTts.stop();
  }

  void dispose() {
    _flutterTts.stop();
  }
}
