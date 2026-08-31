import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:stela_mobile/core/presentation/resources/app_icons.dart';
import 'package:stela_mobile/core/presentation/theme/colors/colors.dart';
import 'package:stela_mobile/core/presentation/theme/theme_x.dart';
import 'package:stela_mobile/core/presentation/widgets/app_icon.dart';
import 'package:stela_mobile/core/presentation/widgets/clickable.dart';
import 'package:stela_mobile/features/library/presentation/manager/story_playback_cubit.dart';
import 'package:stela_mobile/features/library/presentation/manager/story_playback_state.dart';
import 'package:stela_mobile/features/library/presentation/screens/story_detail.dart';
import 'package:stela_mobile/features/library/presentation/utils/story_detail_route.dart';
import 'package:stela_mobile/features/library/presentation/widgets/playback_cover_hero.dart';

/// Compact now-playing bar. Use [docked: true] inside [PlaybackDock].
class MiniPlayerBar extends StatelessWidget {
  const MiniPlayerBar({
    super.key,
    this.docked = false,
    this.state,
  });

  /// When true, renders without outer margin/shadow (parent dock owns chrome).
  final bool docked;

  /// Optional pre-built state to avoid an extra [BlocBuilder] in the dock.
  final StoryPlaybackState? state;

  static const height = 72.0;

  @override
  Widget build(BuildContext context) {
    if (state != null) {
      return _MiniPlayerBody(docked: docked, state: state!);
    }

    return BlocBuilder<StoryPlaybackCubit, StoryPlaybackState>(
      buildWhen: (prev, curr) =>
          prev.showMiniPlayer != curr.showMiniPlayer ||
          prev.storyTitle != curr.storyTitle ||
          prev.miniPlayerSubtitle != curr.miniPlayerSubtitle ||
          prev.coverImageUrl != curr.coverImageUrl ||
          prev.isPlaying != curr.isPlaying ||
          prev.isLoading != curr.isLoading,
      builder: (context, playbackState) {
        if (!playbackState.showMiniPlayer) {
          return const SizedBox.shrink();
        }
        return _MiniPlayerBody(docked: docked, state: playbackState);
      },
    );
  }
}

class _MiniPlayerBody extends StatelessWidget {
  const _MiniPlayerBody({
    required this.docked,
    required this.state,
  });

  final bool docked;
  final StoryPlaybackState state;

  @override
  Widget build(BuildContext context) {
    final storyId = state.readingContext?.storyId ?? '';

    Widget content = SizedBox(
      height: MiniPlayerBar.height,
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Clickable(
                    onPressed: () => _openStoryDetail(context, state),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        docked ? 12 : 10,
                        8,
                        4,
                        8,
                      ),
                      child: Row(
                        children: [
                          PlaybackCoverHero(
                            storyId: storyId,
                            imageUrl: state.coverImageUrl,
                            width: 48,
                            height: 48,
                            borderRadius: 10,
                          ),
                          const Gap(12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  state.storyTitle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface,
                                  ),
                                ),
                                const Gap(2),
                                Text(
                                  state.miniPlayerSubtitle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: context.mutedText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                _PlayPauseButton(
                  isPlaying: state.isPlaying,
                  isLoading: state.isLoading,
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    context.read<StoryPlaybackCubit>().togglePlay();
                  },
                ),
                const Gap(6),
              ],
            ),
          ),
          SizedBox(
            height: 3,
            child: BlocSelector<StoryPlaybackCubit, StoryPlaybackState, double?>(
              selector: (s) {
                if (!s.showMiniPlayer) return null;
                if (s.isLoading) return -1;
                // Bucket to ~2% steps so the bar doesn't rebuild every tick.
                return ((s.progressFraction * 50).round() / 50)
                    .clamp(0.0, 1.0);
              },
              builder: (context, progress) {
                if (progress == null) return const SizedBox.shrink();
                return LinearProgressIndicator(
                  value: progress < 0 ? null : progress,
                  minHeight: 3,
                  backgroundColor:
                      context.softBorder.withValues(alpha: 0.35),
                  color: orange,
                );
              },
            ),
          ),
        ],
      ),
    );

    if (docked) return content;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Material(
        color: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              color: context.isDarkTheme
                  ? darkSurface
                  : Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: context.isDarkTheme ? 0.4 : 0.1,
                  ),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: content,
          ),
        ),
      ),
    );
  }

  void _openStoryDetail(BuildContext context, StoryPlaybackState state) {
    final readingContext = state.readingContext;
    if (readingContext == null) return;

    context.pushStoryDetail(
      StoryDetailScreen(readingContext: readingContext),
    );
  }
}

class _PlayPauseButton extends StatelessWidget {
  const _PlayPauseButton({
    required this.isPlaying,
    required this.isLoading,
    required this.onPressed,
  });

  final bool isPlaying;
  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Clickable(
      onPressed: onPressed,
      isEnabled: !isLoading,
      child: Container(
        width: 44,
        height: 44,
        margin: const EdgeInsets.only(right: 6),
        decoration: BoxDecoration(
          color: orange.withValues(alpha: 0.14),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: orange,
                  ),
                )
              : AppIcon(
                  isPlaying ? AppIcons.pause : AppIcons.play,
                  size: 22,
                  color: orange,
                ),
        ),
      ),
    );
  }
}

extension StoryDetailNavigation on BuildContext {
  Future<T?> pushStoryDetail<T>(Widget screen) {
    return Navigator.of(this).push<T>(StoryDetailPageRoute<T>(screen: screen));
  }
}
