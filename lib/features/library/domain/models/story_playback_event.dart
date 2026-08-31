class StoryPlaybackEvent {
  final StoryPlaybackEventType type;
  final String? message;

  const StoryPlaybackEvent({
    required this.type,
    this.message,
  });
}

enum StoryPlaybackEventType {
  chapterTransition,
  storyComplete,
}
