import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stela_mobile/core/presentation/theme/colors/colors.dart';
import 'package:stela_mobile/core/presentation/theme/theme_x.dart';
import 'package:stela_mobile/core/presentation/widgets/bottom_nav_bar.dart';
import 'package:stela_mobile/features/library/presentation/manager/story_playback_cubit.dart';
import 'package:stela_mobile/features/library/presentation/manager/story_playback_state.dart';
import 'package:stela_mobile/features/library/presentation/widgets/mini_player_bar.dart';

/// Unified bottom shell: mini player + navigation in one card so they don't
/// feel like two stacked floating bars.
class PlaybackDock extends StatelessWidget {
  const PlaybackDock({
    required this.selectedIndex,
    required this.currentIndex,
    required this.onTabSelected,
    super.key,
  });

  final int selectedIndex;
  final int currentIndex;
  final ValueChanged<int> onTabSelected;

  static const _animDuration = Duration(milliseconds: 280);

  /// Ignore high-frequency position ticks — progress bar listens separately.
  static bool _chromeChanged(
    StoryPlaybackState prev,
    StoryPlaybackState curr,
  ) {
    return prev.showMiniPlayer != curr.showMiniPlayer ||
        prev.storyTitle != curr.storyTitle ||
        prev.miniPlayerSubtitle != curr.miniPlayerSubtitle ||
        prev.coverImageUrl != curr.coverImageUrl ||
        prev.isPlaying != curr.isPlaying ||
        prev.isLoading != curr.isLoading;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surface =
        context.isDarkTheme ? darkSurface : theme.colorScheme.surface;

    return BlocBuilder<StoryPlaybackCubit, StoryPlaybackState>(
      buildWhen: _chromeChanged,
      builder: (context, playbackState) {
        final showMini = playbackState.showMiniPlayer;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: AnimatedContainer(
              duration: _animDuration,
              curve: Curves.easeOutCubic,
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(showMini ? 22 : 40),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: context.isDarkTheme ? 0.38 : 0.1,
                    ),
                    blurRadius: 22,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedSize(
                    duration: _animDuration,
                    curve: Curves.easeOutCubic,
                    alignment: Alignment.topCenter,
                    child: showMini
                        ? MiniPlayerBar(
                            docked: true,
                            state: playbackState,
                          )
                        : const SizedBox.shrink(),
                  ),
                  if (showMini)
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: context.softBorder.withValues(alpha: 0.45),
                    ),
                  BottomNavBar(
                    embedded: true,
                    selectedIndex: selectedIndex,
                    currentIndex: currentIndex,
                    onTabSelected: onTabSelected,
                    items: BottomNavBarItem.items,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
