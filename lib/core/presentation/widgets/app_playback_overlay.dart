import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stela_mobile/core/di/core_module_container.dart';
import 'package:stela_mobile/core/presentation/utils/cover_page_route.dart';
import 'package:stela_mobile/features/library/presentation/manager/story_playback_cubit.dart';
import 'package:stela_mobile/features/library/presentation/manager/story_playback_state.dart';
import 'package:stela_mobile/features/library/presentation/utils/story_detail_route.dart';
import 'package:stela_mobile/features/library/presentation/widgets/mini_player_bar.dart';

/// True while a pushed page should show the floating mini player instead of
/// the dashboard dock's mini player — keeps a single bar on screen.
final ValueNotifier<bool> floatingMiniPlayerVisible = ValueNotifier(false);

final playbackOverlayObserver = PlaybackOverlayObserver();

/// Space to keep above the screen bottom so content/CTAs clear the floating bar.
///
/// Returns `0` when the overlay route is active but nothing is actually playing
/// (the overlay renders [SizedBox.shrink] in that case).
double floatingMiniPlayerClearance(BuildContext context) {
  if (!floatingMiniPlayerVisible.value) return 0;
  if (!getIt.isRegistered<StoryPlaybackCubit>()) return 0;
  if (!getIt.get<StoryPlaybackCubit>().state.showMiniPlayer) return 0;
  // AppPlaybackOverlay bottom offset + bar height + MiniPlayerBar outer pad.
  return MediaQuery.paddingOf(context).bottom + 8 + MiniPlayerBar.height + 8;
}

/// Tracks the top page route so the dock and overlay never both show a mini
/// player. Modal sheets / dialogs are ignored so they don't steal ownership.
class PlaybackOverlayObserver extends NavigatorObserver {
  void _sync({Route<dynamic>? top}) {
    // Bottom sheets and dialogs are not page routes — leave ownership alone.
    if (top != null && top is! PageRoute) return;

    final nav = navigator;
    final show =
        nav != null &&
        nav.canPop() &&
        top is PageRoute &&
        top is! StoryDetailPageRoute &&
        top is! CoverPageRoute;

    if (floatingMiniPlayerVisible.value != show) {
      floatingMiniPlayerVisible.value = show;
    }
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _sync(top: route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _sync(top: previousRoute);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _sync(top: previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    _sync(top: newRoute);
  }
}

/// Shows the mini player on page routes pushed above the dashboard shell.
class AppPlaybackOverlay extends StatelessWidget {
  const AppPlaybackOverlay({required this.child, super.key});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: floatingMiniPlayerVisible,
      builder: (context, showOnOverlay, _) {
        return Stack(
          children: [
            ?child,
            if (showOnOverlay)
              Positioned(
                left: 0,
                right: 0,
                bottom: MediaQuery.paddingOf(context).bottom + 8,
                child: BlocBuilder<StoryPlaybackCubit, StoryPlaybackState>(
                  buildWhen: (prev, curr) =>
                      prev.showMiniPlayer != curr.showMiniPlayer,
                  builder: (context, state) {
                    if (!state.showMiniPlayer) {
                      return const SizedBox.shrink();
                    }
                    return const MiniPlayerBar(useHero: false);
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}
