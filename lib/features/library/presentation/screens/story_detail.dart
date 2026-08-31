import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:stela_mobile/core/presentation/resources/app_icons.dart';
import 'package:stela_mobile/core/presentation/theme/colors/colors.dart';
import 'package:stela_mobile/core/presentation/theme/theme_x.dart';
import 'package:stela_mobile/core/presentation/utils/custom_state.dart';
import 'package:stela_mobile/core/presentation/utils/navigation_mixin.dart';
import 'package:stela_mobile/core/presentation/utils/snack_bar_utils.dart';
import 'package:stela_mobile/core/presentation/widgets/app_icon.dart';
import 'package:stela_mobile/core/presentation/widgets/clickable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stela_mobile/core/presentation/widgets/cubit_scaffold.dart';
import 'package:stela_mobile/features/library/presentation/manager/story_detail_cubit.dart';
import 'package:stela_mobile/features/library/presentation/manager/story_detail_state.dart';
import 'package:stela_mobile/features/dashboard/domain/models/story.dart';
import 'package:stela_mobile/features/library/domain/models/story_reading_context.dart';
import 'package:stela_mobile/features/library/presentation/utils/reading_reward_ui.dart';
import 'package:stela_mobile/features/library/presentation/widgets/audio_player.dart';
import 'package:stela_mobile/features/library/presentation/widgets/chapter_selector_sheet.dart';
import 'package:stela_mobile/features/library/presentation/widgets/lyrics_widget.dart';
import 'package:stela_mobile/features/library/presentation/widgets/playback_cover_hero.dart';

class StoryDetailScreen extends StatefulWidget {
  const StoryDetailScreen({super.key, this.story, this.readingContext})
    : assert(story != null || readingContext != null);

  final Story? story;
  final StoryReadingContext? readingContext;
  static const String id = "/story-detail-screen";

  @override
  State<StoryDetailScreen> createState() => _StoryDetailScreenState();
}

class _StoryDetailScreenState extends CustomState<StoryDetailScreen> {
  StoryDetailCubit? _cubit;
  StreamSubscription<StoryDetailEffect>? _effectsSub;

  void _handleScroll(int index) {
    final cubit = _cubit;
    if (cubit == null || index >= cubit.lineKeys.length) return;
    final ctx = cubit.lineKeys[index].currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeInOut,
      alignment: 0.35,
    );
  }

  Future<void> _openChapterSelector(StoryDetailCubit cubit) async {
    if (cubit.state.chapters.length <= 1) return;

    final selected = await showChapterSelectorSheet(
      context,
      chapters: cubit.state.chapters,
      currentChapterId: cubit.state.currentChapterId ?? '',
      fallbackImageUrl:
          widget.readingContext?.coverImageUrl ?? cubit.state.chapterImageUrl,
    );

    if (selected == null || !mounted) return;
    await cubit.jumpToChapter(selected);
  }

  /// Shell ignores high-frequency [position] ticks — player/lyrics own those.
  static bool _shellChanged(StoryDetailState prev, StoryDetailState curr) {
    return prev.isPlaying != curr.isPlaying ||
        prev.isLoading != curr.isLoading ||
        prev.isLoadingChapter != curr.isLoadingChapter ||
        prev.lyricsInitialized != curr.lyricsInitialized ||
        prev.lines != curr.lines ||
        prev.lineCueSecs != curr.lineCueSecs ||
        prev.currentLine != curr.currentLine ||
        prev.chapterTitle != curr.chapterTitle ||
        prev.chapterNumber != curr.chapterNumber ||
        prev.totalChapters != curr.totalChapters ||
        prev.transitionMessage != curr.transitionMessage ||
        prev.isStoryComplete != curr.isStoryComplete ||
        prev.chapters != curr.chapters ||
        prev.chapterImageUrl != curr.chapterImageUrl ||
        prev.currentChapterId != curr.currentChapterId ||
        prev.loadingMessage != curr.loadingMessage ||
        prev.totalDuration != curr.totalDuration ||
        prev.fullText != curr.fullText ||
        prev.showSynthesizingOverlay != curr.showSynthesizingOverlay;
  }

  @override
  Widget build(BuildContext context) {
    return CubitScaffold<StoryDetailCubit, StoryDetailState>(
      create: (context) {
        final cubit = createStoryDetailCubit();
        _cubit = cubit;
        _effectsSub?.cancel();
        _effectsSub = cubit.effects.listen((event) {
          if (!mounted) return;
          switch (event) {
            case StoryDetailErrorEffect(:final message):
              showError(message);
            case StoryDetailRewardEffect(:final event):
              unawaited(ReadingRewardUi.handle(context, event));
            case StoryDetailChapterTransitionEffect():
              break;
          }
        });

        if (widget.readingContext != null) {
          unawaited(cubit.initReading(widget.readingContext!, _handleScroll));
        } else if (widget.story != null) {
          cubit.initStory(widget.story!, _handleScroll);
        }
        return cubit;
      },
      buildWhen: _shellChanged,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      children: (context, cubit, state, theme) {
        _cubit ??= cubit;
        final canSelectChapter = state.chapters.length > 1;
        final imageUrl = state.chapterImageUrl;
        final onSurface = theme.colorScheme.onSurface;

        final storyId =
            widget.readingContext?.storyId ?? widget.story?.id ?? '';

        return [
          Row(
            spacing: 10,
            children: [
              Clickable(
                onPressed: () => context.pop(),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: context.popButtonFill,
                  ),
                  child: AppIcon(
                    AppIcons.arrowDown,
                    size: 22,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  widget.readingContext?.storyTitle ??
                      widget.story?.title ??
                      '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    color: onSurface,
                  ),
                ),
              ),
              if (canSelectChapter)
                Clickable(
                  onPressed: () => _openChapterSelector(cubit),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    height: 36,
                    decoration: BoxDecoration(
                      color: context.cardSurface,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Chapters',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: onSurface,
                          ),
                        ),
                        const Gap(4),
                        AppIcon(AppIcons.arrowDown, size: 16, color: onSurface),
                      ],
                    ),
                  ),
                )
              else
                const SizedBox(width: 36),
            ],
          ),
          const Gap(12),
          if (state.totalChapters > 1)
            Text(
              state.chapterProgressLabel,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: context.mutedText,
              ),
            ),
          const Gap(12),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            child: ClipRRect(
              key: ValueKey('${state.chapterNumber}-$imageUrl'),
              borderRadius: BorderRadius.circular(24),
              child: AspectRatio(
                aspectRatio: 16 / 14,
                child: PlaybackCoverHero(
                  storyId: storyId,
                  imageUrl: imageUrl,
                  borderRadius: 24,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const Gap(16),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: context.cardSurface,
                borderRadius: BorderRadius.circular(32),
              ),
              child: Column(
                children: [
                  if (state.transitionMessage != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                      child: _ChapterTransitionBanner(
                        message: state.transitionMessage!,
                      ),
                    ),
                  const Gap(12),
                  Expanded(
                    child: state.showSynthesizingOverlay
                        ? BlocBuilder<StoryDetailCubit, StoryDetailState>(
                            buildWhen: (p, c) =>
                                p.synthesisProgress != c.synthesisProgress ||
                                p.synthesisStage != c.synthesisStage ||
                                p.loadingMessage != c.loadingMessage ||
                                p.isLoading != c.isLoading ||
                                p.showSynthesizingOverlay !=
                                    c.showSynthesizingOverlay,
                            builder: (context, loadingState) {
                              return _SynthesizingIndicator(
                                message: loadingState.loadingMessage,
                                progress: loadingState.isLoading
                                    ? loadingState.synthesisProgress
                                    : null,
                                stage: loadingState.isLoading
                                    ? loadingState.synthesisStage
                                    : null,
                              );
                            },
                          )
                        : Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: LyricsWidget(
                              lines: state.lines,
                              lineKeys: cubit.lineKeys,
                              lineCueSecs: state.lineCueSecs,
                              currentLine: state.currentLine,
                              onSeek: cubit.seekTo,
                            ),
                          ),
                  ),
                  BlocBuilder<StoryDetailCubit, StoryDetailState>(
                    buildWhen: (p, c) =>
                        p.position != c.position ||
                        p.totalDuration != c.totalDuration ||
                        p.isPlaying != c.isPlaying ||
                        p.isLoading != c.isLoading,
                    builder: (context, playerState) {
                      return AudioPlayerWidget(
                        current: playerState.position.inSeconds.toDouble(),
                        total: playerState.totalDuration.inSeconds.toDouble(),
                        onSeek: cubit.seekTo,
                        onTogglePlay: cubit.togglePlay,
                        onNudge: cubit.nudge,
                        isPlaying: playerState.isPlaying,
                        currentDuration: playerState.position,
                        totalDuration: playerState.totalDuration,
                        isLoading: playerState.isLoading,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const Gap(24),
        ];
      },
    );
  }

  @override
  void dispose() {
    _effectsSub?.cancel();
    super.dispose();
  }
}

class _ChapterTransitionBanner extends StatelessWidget {
  const _ChapterTransitionBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: orange.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: orange),
              ),
              const Gap(10),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: orange,
                  ),
                ),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: 250.ms)
        .slideY(
          begin: -0.15,
          end: 0,
          duration: 300.ms,
          curve: Curves.easeOutCubic,
        );
  }
}

class _SynthesizingIndicator extends StatelessWidget {
  const _SynthesizingIndicator({
    required this.message,
    this.progress,
    this.stage,
  });

  final String message;
  final double? progress;
  final String? stage;

  static const _steps = [
    'Warming up the narrator',
    'Phonemizing your chapter',
    'Generating voice audio',
    'Blending audio together',
  ];

  int get _activeStep {
    final p = progress ?? 0;
    if (p < 0.25) return 0;
    if (p < 0.5) return 1;
    if (p < 0.75) return 2;
    return 3;
  }

  @override
  Widget build(BuildContext context) {
    final showSteps = progress != null;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final muted = context.mutedText;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                LoadingAnimationWidget.staggeredDotsWave(
                  color: orange,
                  size: 48,
                ),
                const Gap(20),
                Text(
                  stage ?? message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: onSurface,
                  ),
                ),
                const Gap(8),
                Text(
                  'Hang tight — your story is being readied for you.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: muted, height: 1.4),
                ),
                if (showSteps) ...[
                  const Gap(20),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: LinearProgressIndicator(
                      value: progress!.clamp(0.0, 1.0),
                      minHeight: 6,
                      backgroundColor: context.softBorder,
                      color: orange,
                    ),
                  ),
                  const Gap(8),
                  Text(
                    '${(progress!.clamp(0.0, 1.0) * 100).round()}%',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: muted,
                    ),
                  ),
                  const Gap(16),
                  ...List.generate(_steps.length, (i) {
                    final isDone = i < _activeStep;
                    final isActive = i == _activeStep;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDone || isActive
                                  ? orange
                                  : context.softBorder,
                            ),
                            child: isDone
                                ? const AppIcon(
                                    AppIcons.check,
                                    size: 14,
                                    color: Colors.white,
                                  )
                                : isActive
                                ? const Padding(
                                    padding: EdgeInsets.all(5),
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : null,
                          ),
                          const Gap(12),
                          Expanded(
                            child: Text(
                              _steps[i],
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: isActive
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color: isDone || isActive ? onSurface : muted,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ] else ...[
                  const Gap(16),
                  SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: orange,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
