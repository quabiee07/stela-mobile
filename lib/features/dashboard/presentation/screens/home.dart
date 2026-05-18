import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:stela_mobile/core/domain/utils/constants.dart';
import 'package:stela_mobile/core/presentation/resources/drawables.dart';
import 'package:stela_mobile/core/presentation/theme/colors/colors.dart';
import 'package:stela_mobile/core/presentation/utils/custom_state.dart';
import 'package:stela_mobile/core/presentation/utils/helper_functions.dart';
import 'package:stela_mobile/core/presentation/utils/navigation_mixin.dart';
import 'package:stela_mobile/core/presentation/widgets/provider_widget.dart';
import 'package:stela_mobile/features/dashboard/domain/models/story.dart';
import 'package:stela_mobile/features/dashboard/presentation/manager/home_provider.dart';
import 'package:stela_mobile/features/library/presentation/screens/story_description.dart';
import 'package:stela_mobile/features/library/presentation/screens/story_detail.dart';
import 'package:stela_mobile/features/dashboard/presentation/widgets/continue_reading_list.dart';
import 'package:stela_mobile/features/dashboard/presentation/widgets/featured_story_card.dart';
import 'package:stela_mobile/features/dashboard/presentation/widgets/new_stories_section.dart';
import 'package:flutter_animate/flutter_animate.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends CustomState<HomeScreen> {
  HomeProvider? _provider;

  void _navigateToStory(BuildContext context, Story story) {
    context.pushNamed(StoryDetailScreen.id, args: story);
  }

  @override
  Widget build(BuildContext context) {
    return ProviderWidget(
      padding: 0,
      provider: HomeProvider(),
      children: (provider, state) {
        _provider ??= provider;
        final state = provider.state;
        final featuredStory = state.mockStories.firstWhere((s) => s.id == '1');
        final continueReadingStories = state.mockStories
            .where((s) => s.id == '2' || s.id == '3')
            .toList();
        final newStories = state.mockStories.where((s) {
          final id = int.tryParse(s.id) ?? 0;
          return id >= 4 && id <= 6;
        }).toList();
        // duplicated to show more items in grid
        final extendedNewStories = [
          ...newStories,
          ...newStories,
          ...newStories,
        ];
        final name = cachedUser?.name ?? '';
        return [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: 120,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:
                    [
                          // Header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Hello, $name',
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Gap(4),
                                  Text(
                                    greetingMessage(),
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.blueGrey[400],
                                    ),
                                  ),
                                ],
                              ),
                              const CircleAvatar(
                                radius: 24,
                                backgroundColor: Color(0xFFF3ABA7),
                                backgroundImage: AssetImage(femaleAvatar),
                              ),
                            ],
                          ),
                          const Gap(24),
                          FeaturedStoryCard(
                            story: featuredStory,
                            onTap: () =>
                                _navigateToStory(context, featuredStory),
                            // context.push(
                            //   SuccessScreen(
                            //     image: bunny,
                            //     title: 'Badge\nUnlocked!',
                            //     description:
                            //         '5 books down! Your brain is officially leveling up. Worms everywhere are proud of you.',
                            //     buttonText: 'SHARE +20 XP',
                            //     onPressed: () {
                            //       context.pop();
                            //     },
                            //   ),
                            // );
                            // },
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
                              Text(
                                'See all',
                                style: TextStyle(color: orange, fontSize: 14),
                              ),
                            ],
                          ),
                          const Gap(16),
                          ContinueReadingList(
                            stories: continueReadingStories,
                            onStoryTap: (story) =>
                                _navigateToStory(context, story),
                          ),
                          const Gap(12),
                          NewStoriesSection(
                            stories: extendedNewStories,
                            onStoryTap: (story) => context.pushNamed(
                              StoryDescriptionScreen.id,
                              args: story,
                            ),
                          ),
                        ]
                        .animate(interval: 50.ms)
                        .fade(duration: 400.ms, curve: Curves.easeOut)
                        .slideY(begin: 0.1, curve: Curves.easeOut),
              ),
            ),
          ),
        ];
      },
    );
  }
}
