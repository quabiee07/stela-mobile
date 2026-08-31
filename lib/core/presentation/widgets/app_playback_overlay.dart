import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stela_mobile/core/presentation/utils/custom_state.dart';
import 'package:stela_mobile/features/library/presentation/manager/story_playback_cubit.dart';
import 'package:stela_mobile/features/library/presentation/manager/story_playback_state.dart';
import 'package:stela_mobile/features/library/presentation/widgets/mini_player_bar.dart';

/// Shows the mini player on routes pushed above the dashboard shell.
class AppPlaybackOverlay extends StatelessWidget {
  const AppPlaybackOverlay({required this.child, super.key});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final nav = navigator.currentState;
    final showOnOverlay = nav?.canPop() ?? false;

    return Stack(
      children: [
        if (child != null) child!,
        if (showOnOverlay)
          Positioned(
            left: 0,
            right: 0,
            bottom: MediaQuery.paddingOf(context).bottom + 8,
            child: BlocBuilder<StoryPlaybackCubit, StoryPlaybackState>(
              buildWhen: (prev, curr) =>
                  prev.showMiniPlayer != curr.showMiniPlayer,
              builder: (context, state) {
                if (!state.showMiniPlayer) return const SizedBox.shrink();
                return const MiniPlayerBar();
              },
            ),
          ),
      ],
    );
  }
}
