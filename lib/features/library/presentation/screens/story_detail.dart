import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:stela_mobile/core/presentation/utils/custom_state.dart';
import 'package:stela_mobile/core/presentation/utils/navigation_mixin.dart';
import 'package:stela_mobile/core/presentation/utils/snack_bar_utils.dart';
import 'package:stela_mobile/core/presentation/widgets/pop_widget.dart';
import 'package:stela_mobile/core/presentation/widgets/provider_widget.dart';
import 'package:stela_mobile/features/dashboard/domain/models/story.dart';
import 'package:stela_mobile/features/library/presentation/manager/story_detail_provider.dart';
import 'package:stela_mobile/features/library/presentation/widgets/audio_player.dart';
import 'package:stela_mobile/features/library/presentation/widgets/lyrics_widget.dart';

class StoryDetailScreen extends StatefulWidget {
  const StoryDetailScreen({super.key});
  static const String id = "/story-detail-screen";

  @override
  State<StoryDetailScreen> createState() => _StoryDetailScreenState();
}

class _StoryDetailScreenState extends CustomState<StoryDetailScreen> {
  StoryDetailProvider? _provider;

  // Cached once so context.getArgs is not called on every build.
  late final Story story;

  @override
  void didChangeDependencies() {
    story = context.getArgs<Story>();
    super.didChangeDependencies();
  }

  @override
  void onStarted() {
    _provider?.listen((event) {
      if (event is String) {
        showError(event);
      }
    });

    if (mounted) {
      _provider?.initLyrics(story.fullText, _handleScroll);
    }
    // _provider?.getAvailableVoices();
    super.onStarted();
  }

  @override
  void dispose() {
    // context is still valid here because we call before super.dispose().
    _provider?.disposeProvider(context);
    super.dispose();
  }

  void _handleScroll(int index) {
    if (index >= _provider!.lineKeys.length) return;
    final ctx = _provider!.lineKeys[index].currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeInOut,
      alignment: 0.38,
    );
  }

  @override
  Widget build(BuildContext context) {
    // final story = context.getArgs<Story>();
    // // Init lyrics gracefully without triggering state rebuild during build
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   _provider?.initLyrics(story.fullText, _handleScroll);
    // });

    return ProviderWidget(
      provider: StoryDetailProvider(),
      padding: 16,
      children: (provider, theme) {
        _provider ??= provider;

        return [
          Row(
            spacing: 10,
            children: [
              PopWidget(),
              Expanded(
                child: Text(
                  story.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 20,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                height: 36,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<bool>(
                    value: provider.isMaleVoice,
                    icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                    items: const [
                      DropdownMenuItem(
                        value: false,
                        child: Text(
                          "Female (Soft)",
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                      DropdownMenuItem(
                        value: true,
                        child: Text(
                          "Male (Soft)",
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) provider.changeVoice(val);
                    },
                  ),
                ),
              ),
            ],
          ),
          // const Gap(20),
          // Padding(
          //   padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
          //   child: ClipRRect(
          //     borderRadius: BorderRadius.circular(12),
          //     child: CustomImage(
          //       asset: story.coverImage,
          //       width: double.infinity,
          //       height: 200,
          //       fit: BoxFit.contain,
          //     ),
          //   ),
          // ),
          // const Gap(20),
          provider.loading
              ? Expanded(child: _SynthesizingIndicator())
              : Expanded(
                  child: LyricsWidget(
                    lines: provider.lines,
                    lineKeys: provider.lineKeys,
                    lineCueSecs: provider.lineCueSecs,
                    currentLine: provider.currentLine,
                    onSeek: provider.seekTo,
                  ),
                ),
          AudioPlayerWidget(
            current: provider.position.inSeconds.toDouble(),
            total: provider.totalDuration.inSeconds.toDouble(),
            onSeek: provider.seekTo,
            onTogglePlay: provider.togglePlay,
            onNudge: provider.nudge,
            isPlaying: provider.isPlaying,
            currentDuration: provider.position,
            totalDuration: provider.totalDuration,
            isLoading: provider.isLoading,
          ),
        ];
      },
    );
  }
}

class _SynthesizingIndicator extends StatelessWidget {
  const _SynthesizingIndicator();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(),
        Gap(16),
        Text('Preparing your story...', style: TextStyle(fontSize: 14)),
      ],
    );
  }
}
