import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:stela_mobile/core/di/core_module_container.dart';
import 'package:stela_mobile/core/presentation/resources/app_icons.dart';
import 'package:stela_mobile/core/presentation/resources/drawables.dart';
import 'package:stela_mobile/core/presentation/theme/colors/colors.dart';
import 'package:stela_mobile/core/presentation/theme/theme_x.dart';
import 'package:stela_mobile/core/presentation/utils/snack_bar_utils.dart';
import 'package:stela_mobile/core/presentation/widgets/app_icon.dart';
import 'package:stela_mobile/core/presentation/widgets/app_playback_overlay.dart';
import 'package:stela_mobile/core/presentation/widgets/cached_image.dart';
import 'package:stela_mobile/core/presentation/widgets/clickable.dart';
import 'package:stela_mobile/core/presentation/widgets/custom_image.dart';
import 'package:stela_mobile/core/presentation/widgets/pop_widget.dart';
import 'package:stela_mobile/core/presentation/widgets/profile_avatar.dart';
import 'package:stela_mobile/core/presentation/widgets/slide_animation_wrapper.dart';
import 'package:stela_mobile/features/library/domain/models/story_reading_context.dart';
import 'package:stela_mobile/features/library/presentation/manager/library_cubit.dart';
import 'package:stela_mobile/features/library/presentation/manager/library_state.dart';
import 'package:stela_mobile/features/library/presentation/manager/story_playback_cubit.dart';
import 'package:stela_mobile/features/library/presentation/manager/story_playback_state.dart';
import 'package:stela_mobile/features/library/presentation/screens/story_detail.dart';
import 'package:stela_mobile/features/library/presentation/widgets/mini_player_bar.dart';

class StoryDescriptionScreen extends StatefulWidget {
  const StoryDescriptionScreen({super.key, required this.storyId});

  final String storyId;
  static const String id = '/story-description';

  @override
  State<StoryDescriptionScreen> createState() => _StoryDescriptionScreenState();
}

class _StoryDescriptionScreenState extends State<StoryDescriptionScreen> {
  StreamSubscription<LibraryEffect>? _effectsSub;

  @override
  void initState() {
    super.initState();
    final cubit = getIt.get<LibraryCubit>();
    _effectsSub = cubit.effects.listen((event) {
      if (event is LibraryErrorEffect && mounted) {
        showError(event.message);
      }
    });
    cubit.loadStoryDetail(widget.storyId);
  }

  @override
  void dispose() {
    _effectsSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocProvider.value(
      value: getIt.get<LibraryCubit>(),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: BlocBuilder<LibraryCubit, LibraryState>(
              builder: (context, state) {
                final story = state.selectedStory;
                final onSurface = theme.colorScheme.onSurface;
                final hasNetworkCover =
                    story?.coverImageUrl.startsWith('http') ?? false;

                if (state.isLoadingDetail) {
                  return const Center(
                    child: CircularProgressIndicator(color: orange),
                  );
                }

                if (state.detailError != null || story == null) {
                  return Column(
                    children: [
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: PopWidget(),
                      ),
                      Expanded(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  state.detailError ??
                                      'Could not load this story. Please try again.',
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: onSurface,
                                  ),
                                ),
                                const Gap(20),
                                Clickable(
                                  onPressed: () {
                                    context
                                        .read<LibraryCubit>()
                                        .loadStoryDetail(
                                          widget.storyId,
                                          force: true,
                                        );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: orange,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      'Retry',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }

                return Column(
                  children: [
                    Row(
                      children: [
                        const PopWidget(),
                        const Spacer(),
                        Clickable(
                          onPressed: () {},
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: context.popButtonFill,
                            ),
                            child: AppIcon(
                              AppIcons.menu,
                              size: 22,
                              color: onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Gap(20),
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: SizedBox(
                                      width: double.infinity,
                                      height: 280,
                                      child: hasNetworkCover
                                          ? CachedImage(
                                              asset: story.coverImageUrl,
                                              width: double.infinity,
                                              height: 280,
                                              fit: BoxFit.cover,
                                            )
                                          : CustomImage(
                                              asset:
                                                  story.coverImageUrl.isNotEmpty
                                                  ? story.coverImageUrl
                                                  : boyDragon,
                                              width: double.infinity,
                                              height: 280,
                                              fit: BoxFit.cover,
                                            ),
                                    ),
                                  ),
                                )
                                .animate()
                                .fadeIn(duration: 350.ms)
                                .scale(
                                  begin: const Offset(0.96, 0.96),
                                  end: const Offset(1, 1),
                                  duration: 450.ms,
                                  curve: Curves.easeOutCubic,
                                ),
                            const Gap(24),
                            Text(
                                  story.title,
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.displayLarge?.copyWith(
                                    // fontWeight: FontWeight.w500,
                                    fontSize: 20,
                                    color: onSurface,
                                  ),
                                )
                                .animate()
                                .fadeIn(delay: 80.ms, duration: 300.ms)
                                .slideY(
                                  begin: 0.12,
                                  end: 0,
                                  delay: 80.ms,
                                  duration: 350.ms,
                                  curve: Curves.easeOutCubic,
                                ),
                            const Gap(8),
                            Row(
                              children: [
                                if (story.hasAuthor) ...[
                                  Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          ProfileAvatar(
                                            avatarUrl:
                                                story.authorPhotoUrl ?? '',
                                            radius: 18,
                                          ),
                                          const Gap(10),
                                          Text(
                                            story.authorName,
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w400,
                                                ),
                                          ),
                                        ],
                                      )
                                      .animate()
                                      .fadeIn(delay: 160.ms, duration: 320.ms)
                                      .slideY(
                                        begin: 0.15,
                                        end: 0,
                                        delay: 160.ms,
                                        duration: 380.ms,
                                        curve: Curves.easeOutCubic,
                                      ),
                                ],
                                const Gap(8),
                                if (story.tags.isNotEmpty) ...[
                                  const Gap(8),
                                  Center(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: orange.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(
                                          100,
                                        ),
                                      ),
                                      child: Text(
                                        story.tags,
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: orange,
                                            ),
                                      ),
                                    ),
                                  ).animate().fadeIn(
                                    delay: 120.ms,
                                    duration: 300.ms,
                                  ),
                                ],
                              ],
                            ),
                            const Gap(8),
                            Row(
                              spacing: 8,
                              children: [
                                Row(
                                  children: [
                                    AppIcon(
                                      AppIcons.bookOpen,
                                      size: 20,
                                      color: orange,
                                    ),
                                    const Gap(5),

                                    Text(
                                      '${story.totalChapters} Chapters',
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w400,
                                            fontSize: 15,
                                            color: grey500,
                                          ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    AppIcon(
                                      AppIcons.clock,
                                      size: 20,
                                      color: orange,
                                    ),
                                    const Gap(5),

                                    Text(
                                      '${story.readingTime} mins',
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w400,
                                            fontSize: 15,
                                            color: grey500,
                                          ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const Gap(25),
                            Text(
                              'Description',
                              style: theme.textTheme.displayLarge?.copyWith(
                                fontSize: 20,
                                color: onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const Gap(14),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: context.cardSurface,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                story.description,
                                style: TextStyle(
                                  fontSize: 15,
                                  height: 1.6,
                                  fontWeight: FontWeight.w400,
                                  color: onSurface.withValues(alpha: 0.85),
                                ),
                              ),
                            ).animate().fadeIn(delay: 280.ms, duration: 350.ms),
                            const Gap(32),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        bottomNavigationBar: ValueListenableBuilder<bool>(
          valueListenable: floatingMiniPlayerVisible,
          builder: (context, floatingMini, _) {
            return BlocBuilder<StoryPlaybackCubit, StoryPlaybackState>(
              buildWhen: (prev, curr) =>
                  prev.showMiniPlayer != curr.showMiniPlayer,
              builder: (context, playback) {
                return BlocBuilder<LibraryCubit, LibraryState>(
                  builder: (context, state) {
                    if (state.isLoadingDetail ||
                        state.detailError != null ||
                        state.selectedStory == null) {
                      return const SizedBox.shrink();
                    }

                    final miniClearance =
                        floatingMini && playback.showMiniPlayer
                        ? floatingMiniPlayerClearance(context)
                        : 0.0;
                    final safeBottom = MediaQuery.paddingOf(context).bottom;
                    final bottomPad = miniClearance > 0
                        ? miniClearance
                        : safeBottom;

                    return Padding(
                      padding: MediaQuery.of(
                        context,
                      ).viewInsets.add(EdgeInsets.only(bottom: bottomPad)),
                      child: SlideAnimationWrapper(
                        index: 1,
                        child: Builder(
                          builder: (context) {
                            final story = state.selectedStory!;
                            final hasChapters = story.chapters.isNotEmpty;
                            final enabled = hasChapters;

                            return Clickable(
                              isEnabled: enabled,
                              onPressed: () {
                                if (story.chapters.isEmpty) {
                                  showError('This story has no chapters yet.');
                                  return;
                                }

                                final firstChapter = story.chapters.first;

                                context.pushStoryDetail(
                                  StoryDetailScreen(
                                    readingContext: StoryReadingContext(
                                      storyId: story.storyId,
                                      storyTitle: story.title,
                                      genre: story.genre,
                                      chapterId: firstChapter.chapterId,
                                      chapterTitle: firstChapter.title,
                                      chapterNumber: firstChapter.chapterNumber,
                                      totalChapters: story.totalChapters,
                                      chapters: story.chapters,
                                      coverImageUrl: story.coverImageUrl,
                                      readingTime: story.readingTime,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  10,
                                  16,
                                  10,
                                ),
                                child: Container(
                                  height: 54,
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    gradient: enabled
                                        ? buttonGradient
                                        : disabledButtonGradient,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      color: enabled
                                          ? orange
                                          : const Color(0xFF8C7B77),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        'Start Reading',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
