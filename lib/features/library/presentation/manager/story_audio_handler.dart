import 'package:audio_service/audio_service.dart';
import 'package:stela_mobile/features/library/presentation/manager/story_playback_cubit.dart';
import 'package:stela_mobile/features/library/presentation/manager/story_playback_state.dart';

/// Bridges system media controls (notification / lock screen / headset) to
/// [StoryPlaybackCubit]. Actual audio still plays via audioplayers.
class StoryAudioHandler extends BaseAudioHandler with SeekHandler {
  StoryPlaybackCubit? _cubit;

  void bind(StoryPlaybackCubit cubit) {
    _cubit = cubit;
  }

  void unbind() {
    _cubit = null;
  }

  Future<void> sync(StoryPlaybackState state) async {
    if (!state.hasSession ||
        (!state.isPlaying &&
            !state.isLoading &&
            state.duration == Duration.zero)) {
      await clear();
      return;
    }

    final storyId = state.readingContext?.storyId ?? 'story';
    final artUri = _artUri(state.coverImageUrl);

    mediaItem.add( 
      MediaItem(
        id: '$storyId-${state.currentChapterId ?? state.chapterNumber}',
        title: state.storyTitle.isEmpty ? 'Stela Story' : state.storyTitle,
        album: 'Stela',
        artist: state.miniPlayerSubtitle,
        duration: state.duration > Duration.zero ? state.duration : null,
        artUri: artUri,
        playable: true,
      ),
    );

    playbackState.add(
      PlaybackState(
        controls: [
          MediaControl.rewind,
          if (state.isPlaying) MediaControl.pause else MediaControl.play,
          MediaControl.stop,
          MediaControl.fastForward,
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
          MediaAction.play,
          MediaAction.pause,
          MediaAction.stop,
        },
        androidCompactActionIndices: const [0, 1, 2],
        processingState: state.isLoading
            ? AudioProcessingState.loading
            : state.isStoryComplete
                ? AudioProcessingState.completed
                : AudioProcessingState.ready,
        playing: state.isPlaying,
        updatePosition: state.position,
        bufferedPosition: state.duration,
        speed: 1.0,
        queueIndex: 0,
      ),
    );
  }

  Future<void> clear() async {
    mediaItem.add(null);
    playbackState.add(
      PlaybackState(
        controls: const [],
        processingState: AudioProcessingState.idle,
        playing: false,
      ),
    );
  }

  Uri? _artUri(String url) {
    if (url.isEmpty) return null;
    if (url.startsWith('http')) return Uri.tryParse(url);
    return null;
  }

  @override
  Future<void> play() async {
    final cubit = _cubit;
    if (cubit == null) return;
    if (!cubit.state.isPlaying) {
      await cubit.togglePlay();
    }
  }

  @override
  Future<void> pause() async {
    final cubit = _cubit;
    if (cubit == null) return;
    if (cubit.state.isPlaying) {
      await cubit.togglePlay();
    }
  }

  @override
  Future<void> stop() async {
    await _cubit?.stopSession();
    await clear();
    await super.stop();
  }

  @override
  Future<void> seek(Duration position) async {
    await _cubit?.seekTo(position.inMilliseconds / 1000.0);
  }

  @override
  Future<void> fastForward() async {
    _cubit?.nudge(15);
  }

  @override
  Future<void> rewind() async {
    _cubit?.nudge(-10);
  }
}
