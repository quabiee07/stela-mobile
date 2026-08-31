import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:stela_mobile/core/di/core_module_container.dart';
import 'package:stela_mobile/core/presentation/resources/app_icons.dart';
import 'package:stela_mobile/core/presentation/resources/drawables.dart';
import 'package:stela_mobile/core/presentation/theme/colors/colors.dart';
import 'package:stela_mobile/core/presentation/theme/theme_x.dart';
import 'package:stela_mobile/core/presentation/utils/snack_bar_utils.dart';
import 'package:stela_mobile/core/presentation/widgets/app_icon.dart';
import 'package:stela_mobile/core/presentation/widgets/cached_image.dart';
import 'package:stela_mobile/core/presentation/widgets/clickable.dart';
import 'package:stela_mobile/core/presentation/widgets/custom_image.dart';
import 'package:stela_mobile/core/presentation/widgets/pop_widget.dart';
import 'package:stela_mobile/core/presentation/widgets/slide_animation_wrapper.dart';
import 'package:stela_mobile/features/library/domain/models/story_reading_context.dart';
import 'package:stela_mobile/features/library/presentation/manager/library_cubit.dart';
import 'package:stela_mobile/features/library/presentation/manager/library_state.dart';
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

                if (story == null) {
                  return const Center(
                    child: CircularProgressIndicator(color: orange),
                  );
                }

                final hasNetworkCover = story.coverImageUrl.startsWith('http');

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
                                  width: 220,
                                  height: 280,
                                  child: hasNetworkCover
                                      ? CachedImage(
                                          asset: story.coverImageUrl,
                                          width: 220,
                                          height: 280,
                                          fit: BoxFit.cover,
                                        )
                                      : CustomImage(
                                          asset: story.coverImageUrl.isNotEmpty
                                              ? story.coverImageUrl
                                              : boyDragon,
                                          width: 220,
                                          height: 280,
                                          fit: BoxFit.cover,
                                        ),
                                ),
                              ),
                            ),
                            const Gap(24),
                            Center(
                              child: Text(
                                story.title,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 26,
                                  color: onSurface,
                                  height: 1.25,
                                ),
                              ),
                            ),
                            const Gap(10),
                            Center(
                              child: Text(
                                story.tags,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: context.mutedText,
                                ),
                              ),
                            ),
                            const Gap(10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const AppIcon(
                                  AppIcons.star,
                                  color: amber,
                                  size: 16,
                                ),
                                const Gap(6),
                                Text(
                                  '4.5 (1.4k)',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: context.mutedText,
                                  ),
                                ),
                              ],
                            ),
                            const Gap(28),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Description',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: onSurface,
                                  ),
                                ),
                                Clickable(
                                  onPressed: () {},
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: context.popButtonFill,
                                    ),
                                    child: const AppIcon(
                                      AppIcons.favourite,
                                      color: orange,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
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
                            ),
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
        bottomNavigationBar: Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: SlideAnimationWrapper(
            index: 1,
            child: BlocBuilder<LibraryCubit, LibraryState>(
              builder: (context, state) {
                return Clickable(
                  onPressed: () {
                    final story = state.selectedStory;
                    if (story == null) return;

                    final firstChapter = story.chapters.isNotEmpty
                        ? story.chapters.first
                        : null;
                    if (firstChapter == null) return;

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
                    height: 80,
                    padding: const EdgeInsets.only(
                      top: 10,
                      bottom: 18,
                      left: 16,
                      right: 16,
                    ),
                    child: Container(
                      height: 54,
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        gradient: buttonGradient,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: orange,
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
        ),
      ),
    );
  }
}
