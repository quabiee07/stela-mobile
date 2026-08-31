import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:stela_mobile/features/library/presentation/manager/story_audio_handler.dart';

/// Owns the singleton [StoryAudioHandler] used for lock-screen / notification
/// media controls while a story is playing in the background.
class PlaybackMediaService {
  PlaybackMediaService._();

  static StoryAudioHandler? _handler;

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
  }
}
