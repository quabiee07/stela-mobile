import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:stela_mobile/core/di/core_module_container.dart';
import 'package:stela_mobile/core/presentation/resources/app_icons.dart';
import 'package:stela_mobile/core/presentation/theme/colors/colors.dart';
import 'package:stela_mobile/core/presentation/theme/theme_x.dart';
import 'package:stela_mobile/core/presentation/utils/custom_state.dart';
import 'package:stela_mobile/core/presentation/utils/navigation_mixin.dart';
import 'package:stela_mobile/core/presentation/utils/snack_bar_utils.dart';
import 'package:stela_mobile/core/presentation/widgets/app_icon.dart';
import 'package:stela_mobile/core/presentation/widgets/clickable.dart';
import 'package:stela_mobile/core/presentation/widgets/input_field.dart';
import 'package:stela_mobile/features/dashboard/presentation/widgets/library_story.dart';
import 'package:stela_mobile/features/library/presentation/manager/library_cubit.dart';
import 'package:stela_mobile/features/library/presentation/manager/library_state.dart';
import 'package:stela_mobile/features/library/presentation/screens/story_description.dart';
import 'package:stela_mobile/features/library/presentation/widgets/library_screen_shimmer.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends CustomState<LibraryScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt.get<LibraryCubit>(),
      child: const _LibraryBody(),
    );
  }
}

class _LibraryBody extends StatefulWidget {
  const _LibraryBody();

  @override
  State<_LibraryBody> createState() => _LibraryBodyState();
}

class _LibraryBodyState extends State<_LibraryBody> {
  StreamSubscription<LibraryEffect>? _effectsSub;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<LibraryCubit>();
    _effectsSub = cubit.effects.listen((event) {
      if (event is LibraryErrorEffect && mounted) {
        showError(event.message);
      }
    });
    cubit.loadStories();
  }

  @override
  void dispose() {
    _effectsSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LibraryCubit, LibraryState>(
      builder: (context, state) {
        final cubit = context.read<LibraryCubit>();
        final filteredStories = state.filteredStories;
        final genres = state.genres;
        final isLoading = state.isLoading && state.stories.isEmpty;

        return SafeArea(
          child: Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  color: orange,
                  onRefresh: cubit.loadStories,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      slivers: [
                        SliverPadding(
                          padding: const EdgeInsets.only(top: 18),
                          sliver: SliverToBoxAdapter(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Center(
                                  child: Text(
                                    'Library',
                                    style: TextStyle(fontSize: 24),
                                  ),
                                ),
                                const Gap(12),
                                InputField(
                                  prefixIcon: const Padding(
                                    padding: EdgeInsets.only(left: 16.0),
                                    child: AppIcon(AppIcons.search, size: 22),
                                  ),
                                  hint: 'Search your Library',
                                  onChange: cubit.setSearchQuery,
                                ),
                                if (genres.isNotEmpty) ...[
                                  const Gap(12),
                                  SizedBox(
                                    height: 40,
                                    child: ListView.separated(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: genres.length,
                                      separatorBuilder: (_, __) => const Gap(8),
                                      itemBuilder: (context, index) {
                                        final genre = genres[index];
                                        final isSelected =
                                            state.selectedGenre == genre;
                                        return Clickable(
                                          onPressed: () =>
                                              cubit.setSelectedGenre(genre),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              gradient: isSelected
                                                  ? categoryGradient
                                                  : context
                                                        .inactiveChipGradient,
                                              borderRadius:
                                                  BorderRadius.circular(100),
                                              border: isSelected
                                                  ? null
                                                  : Border.all(
                                                      color: context.softBorder,
                                                    ),
                                            ),
                                            alignment: Alignment.center,
                                            child: Text(
                                              genre,
                                              style: TextStyle(
                                                color: isSelected
                                                    ? Colors.white
                                                    : Theme.of(
                                                        context,
                                                      ).colorScheme.onSurface,
                                                fontWeight: isSelected
                                                    ? FontWeight.w600
                                                    : FontWeight.normal,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                                const Gap(16),
                              ],
                            ),
                          ),
                        ),
                        if (isLoading)
                          const SliverToBoxAdapter(
                            child: LibraryScreenShimmer(),
                          )
                        else if (filteredStories.isEmpty)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 48),
                              child: Center(
                                child: Text(
                                  state.stories.isEmpty
                                      ? 'No stories available yet.'
                                      : 'No stories match your search.',
                                  style: TextStyle(color: context.mutedText),
                                ),
                              ),
                            ),
                          )
                        else
                          SliverPadding(
                            padding: const EdgeInsets.only(bottom: 120),
                            sliver: SliverGrid(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    mainAxisSpacing: 16,
                                    crossAxisSpacing: 16,
                                    childAspectRatio: 0.58,
                                  ),
                              delegate: SliverChildBuilderDelegate((
                                context,
                                index,
                              ) {
                                final story = filteredStories[index];
                                return LayoutBuilder(
                                  key: ValueKey(story.storyId),
                                  builder: (context, constraints) {
                                    final coverHeight =
                                        (constraints.maxHeight -
                                                LibraryStory.metaHeight)
                                            .clamp(
                                              120.0,
                                              constraints.maxHeight - 1,
                                            );
                                    return LibraryStory(
                                      key: ValueKey('story_${story.storyId}'),
                                      story: story,
                                      width: constraints.maxWidth,
                                      height: coverHeight,
                                      onStoryTap: (story) => context.push(
                                        StoryDescriptionScreen(
                                          storyId: story.storyId,
                                        ),
                                      ),
                                    );
                                  },
                                );
                              }, childCount: filteredStories.length),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
