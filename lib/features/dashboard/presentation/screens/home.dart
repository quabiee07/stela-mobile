import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:stela_mobile/core/domain/utils/constants.dart';
import 'package:stela_mobile/core/presentation/resources/drawables.dart';
import 'package:stela_mobile/core/presentation/theme/colors/colors.dart';
import 'package:stela_mobile/core/presentation/theme/theme_x.dart';
import 'package:stela_mobile/core/presentation/utils/custom_state.dart';
import 'package:stela_mobile/core/presentation/utils/helper_functions.dart';
import 'package:stela_mobile/core/presentation/utils/navigation_mixin.dart';
import 'package:stela_mobile/core/presentation/utils/snack_bar_utils.dart';
import 'package:stela_mobile/core/presentation/widgets/clickable.dart';
import 'package:stela_mobile/features/dashboard/presentation/manager/home_cubit.dart';
import 'package:stela_mobile/features/dashboard/presentation/manager/home_state.dart';
import 'package:stela_mobile/features/dashboard/presentation/screens/continue_reading_screen.dart';
import 'package:stela_mobile/features/profile/presentation/manager/gamification_cubit.dart';
import 'package:stela_mobile/features/profile/presentation/manager/gamification_state.dart';
import 'package:stela_mobile/features/dashboard/presentation/widgets/continue_reading_list.dart';
import 'package:stela_mobile/features/dashboard/presentation/widgets/featured_stories_carousel.dart';
import 'package:stela_mobile/features/dashboard/presentation/widgets/home_screen_shimmer.dart';
import 'package:stela_mobile/features/dashboard/presentation/widgets/new_stories_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends CustomState<HomeScreen> {
  StreamSubscription<HomeEffect>? _effectsSub;

  @override
  void onStarted() {
    _effectsSub = context.read<HomeCubit>().effects.listen((event) {
      if (event is HomeErrorEffect) {
        showError(event.message);
      }
    });
    super.onStarted();
  }

  @override
  void dispose() {
    _effectsSub?.cancel();
    super.dispose();
  }

  @override
  void onPopNext() {
    // Only refresh local continue-reading — do not re-fetch stories /
    // gamification on every minimize of the story reader.
    if (mounted) {
      unawaited(context.read<HomeCubit>().refreshContinueReading());
    }
    super.onPopNext();
  }

    ImageProvider _avatarImage() {
    final avatarUrl = cachedUser?.avatarUrl ?? '';
    if (avatarUrl.isNotEmpty && !avatarUrl.startsWith('http')) {
      return AssetImage(avatarUrl);
    }
    return const AssetImage(femaleAvatar);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      buildWhen: (prev, curr) =>
          prev.isLoadingStories != curr.isLoadingStories ||
          prev.stories != curr.stories ||
          prev.featuredStories != curr.featuredStories ||
          prev.continueReading != curr.continueReading ||
          prev.newStories != curr.newStories ||
          prev.genres != curr.genres ||
          prev.firstName != curr.firstName ||
          prev.isResumingStory != curr.isResumingStory,
      builder: (context, state) {
        final name = cachedUser?.name ?? state.firstName;
        final isInitialLoading =
            state.isLoadingStories && state.stories.isEmpty;

        return SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: isInitialLoading
                ? const HomeScreenShimmer()
                : SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(top: 16, bottom: 120),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Hello, $name',
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Gap(4),
                                Text(
                                  greetingMessage(),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: context.mutedText,
                                  ),
                                ),
                                const _StreakChip(),
                              ],
                            ),
                             CircleAvatar(
                              radius: 24,
                              backgroundColor: Color(0xFFF3ABA7),
                              backgroundImage: _avatarImage(),
                            ),
                          ],
                        ),
                        const Gap(24),
                        const _StreakAtRiskBanner(),
                        FeaturedStoriesCarousel(
                          stories: state.featuredStories,
                          onTap: (story) => context
                              .read<HomeCubit>()
                              .openStory(context, story.storyId),
                        ),
                        const Gap(24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Continue reading',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Clickable(
                              onPressed: () {
                                context.push(const ContinueReadingScreen());
                              },
                              child: Text(
                                'See all',
                                style: TextStyle(
                                  color: orange,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Gap(16),
                        ContinueReadingList(
                          items: state.continueReading,
                          maxItems: 3,
                          onStoryTap: (item) => context
                              .read<HomeCubit>()
                              .resumeReading(context, item),
                        ),
                        const Gap(20),
                        NewStoriesSection(
                          stories: state.newStories,
                          genres: state.genres,
                          onStoryTap: (story) => context
                              .read<HomeCubit>()
                              .openStory(context, story.storyId),
                          onSeeAll: () =>
                              context.read<HomeCubit>().openLibraryTab(),
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

class _StreakChip extends StatelessWidget {
  const _StreakChip();

  @override
  Widget build(BuildContext context) {
    final streakDays = context.select(
      (GamificationCubit c) => c.state.streakInfo?.currentStreak,
    );
    if (streakDays == null || streakDays <= 0) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: orange.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          '🔥 $streakDays-day streak',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: orange,
          ),
        ),
      ),
    );
  }
}

class _StreakAtRiskBanner extends StatelessWidget {
  const _StreakAtRiskBanner();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GamificationCubit, GamificationState>(
      buildWhen: (prev, curr) =>
          prev.isStreakAtRisk != curr.isStreakAtRisk ||
          prev.streakInfo?.freezeAvailable !=
              curr.streakInfo?.freezeAvailable,
      builder: (context, gamification) {
        if (!gamification.isStreakAtRisk) {
          return const SizedBox.shrink();
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: orange.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Your streak is at risk — read a chapter today to keep it alive.',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: orange,
                    ),
                  ),
                ),
                if (gamification.streakInfo?.freezeAvailable == true)
                  Clickable(
                    onPressed: () =>
                        context.read<GamificationCubit>().activateFreeze(),
                    child: const Text(
                      'Freeze',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: orange,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
