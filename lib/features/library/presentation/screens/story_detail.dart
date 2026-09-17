import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
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
import 'package:stela_mobile/features/library/presentation/utils/playback_hero_tags.dart';
import 'package:stela_mobile/features/library/presentation/utils/reading_reward_ui.dart';
import 'package:stela_mobile/features/library/presentation/widgets/audio_player.dart';
import 'package:stela_mobile/features/library/presentation/widgets/chapter_selector_sheet.dart';
import 'package:stela_mobile/features/library/presentation/widgets/lyrics_widget.dart';
import 'package:stela_mobile/features/library/presentation/widgets/playback_cover_hero.dart';
import 'package:stela_mobile/features/library/presentation/widgets/synthesizing_indicator.dart';

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
          // Keep a single Hero outside AnimatedSwitcher — switching chapters
          // would otherwise mount two covers with the same playback-cover tag
          // (and collide when streak/success routes push).
          Hero(
            tag: PlaybackHeroTags.cover(storyId),
            child: Material(
              type: MaterialType.transparency,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: AspectRatio(
                  aspectRatio: 16 / 14,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    child: PlaybackCoverHero(
                      key: ValueKey('${state.chapterNumber}-$imageUrl'),
                      storyId: storyId,
                      imageUrl: imageUrl,
                      borderRadius: 24,
                      fit: BoxFit.cover,
                      useHero: false,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const Gap(16),
          Expanded(
            child: Container(
              width: double.infinity,
              clipBehavior: Clip.antiAlias,
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
                    child: Stack(
                      children: [
                        if (state.lyricsInitialized)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: LyricsWidget(
                              lines: state.lines,
                              lineKeys: cubit.lineKeys,
                              lineCueSecs: state.lineCueSecs,
                              currentLine: state.currentLine,
                              onSeek: cubit.seekTo,
                            ),
                          ),
                        if (state.showSynthesizingOverlay)
                          Positioned.fill(
                            child: BlocSelector<
                                StoryDetailCubit,
                                StoryDetailState,
                                ({int bucket, String label})>(
                              selector: (s) => (
                                bucket: s.isLoading
                                    ? (s.synthesisProgress * 20)
                                        .round()
                                        .clamp(0, 20)
                                    : -1,
                                label: s.isLoading
                                    ? s.synthesisStage
                                    : s.loadingMessage,
                              ),
                              builder: (context, view) {
                                return SynthesizingIndicator(
                                  label: view.label,
                                  progress: view.bucket < 0
                                      ? null
                                      : view.bucket / 20,
                                );
                              },
                            ),
                          ),
                      ],
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
