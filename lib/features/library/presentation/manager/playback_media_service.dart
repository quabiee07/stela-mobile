import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:stela_mobile/features/library/presentation/manager/story_audio_handler.dart';

/// Owns the singleton [StoryAudioHandler] used for lock-screen / notification
/// media controls while a story is playing in the background.
class PlaybackMediaService {
  PlaybackMediaService._();

  static StoryAudioHandler? _handler;
  static bool _interruptionListenersAttached = false;
  static bool _resumeAfterInterruption = false;

  static StoryAudioHandler? get handler => _handler;

  static Future<void> init() async {
    if (_handler != null) return;

    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());

    _handler = await AudioService.init(
      builder: StoryAudioHandler.new,
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.stela.playback',
        androidNotificationChannelName: 'Story playback',
        androidNotificationOngoing: true,
        androidStopForegroundOnPause: true,
        androidNotificationIcon: 'mipmap/ic_launcher',
        fastForwardInterval: Duration(seconds: 15),
        rewindInterval: Duration(seconds: 10),
      ),
    );

    _attachInterruptionListeners(session);
  }

  static void _attachInterruptionListeners(AudioSession session) {
    if (_interruptionListenersAttached) return;
    _interruptionListenersAttached = true;

    session.interruptionEventStream.listen((event) async {
      final handler = _handler;
      if (handler == null) return;

      if (event.begin) {
        switch (event.type) {
          case AudioInterruptionType.duck:
            break;
          case AudioInterruptionType.pause:
          case AudioInterruptionType.unknown:
            _resumeAfterInterruption = handler.playbackState.value.playing;
            await handler.pause();
        }
      } else if (_resumeAfterInterruption) {
        _resumeAfterInterruption = false;
        await handler.play();
      }
    });

    session.becomingNoisyEventStream.listen((_) async {
      _resumeAfterInterruption = false;
      await _handler?.pause();
    });
  }
}
