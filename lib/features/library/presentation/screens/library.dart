import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:stela_mobile/core/presentation/resources/drawables.dart';
import 'package:stela_mobile/core/presentation/theme/colors/colors.dart';
import 'package:stela_mobile/core/presentation/utils/navigation_mixin.dart';
import 'package:stela_mobile/core/presentation/widgets/input_field.dart';
import 'package:stela_mobile/core/presentation/widgets/provider_widget.dart';
import 'package:stela_mobile/core/presentation/widgets/svg_image.dart';
import 'package:stela_mobile/features/dashboard/presentation/manager/home_provider.dart';
import 'package:stela_mobile/features/library/presentation/screens/story_description.dart';
import 'package:stela_mobile/features/dashboard/presentation/widgets/library_story.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_animate/flutter_animate.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  HomeProvider? _provider;

  @override
  Widget build(BuildContext context) {
    return ProviderWidget(
      provider: HomeProvider(),
      children: (provider, state) {
        _provider ??= provider;
        final state = provider.state;

        return [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(top: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:
                    [
                          Center(
                            child: const Text(
                              'Library',
                              style: TextStyle(fontSize: 24),
                            ),
                          ),
                          const Gap(12),
                          Row(
                            spacing: 10,
                            children: [
                              Expanded(
                                child: InputField(
                                  prefixIcon: Padding(
                                    padding: const EdgeInsets.only(left: 16.0),
                                    child: SvgImage(asset: search),
                                  ),
                                  hint: 'Search your Library',
                                  onChange: (value) {},
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: grey100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: SvgImage(asset: filter),
                              ),
                            ],
                          ),
                          const Gap(16),
                          MasonryGridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            itemCount: state.mockStories.length,
                            itemBuilder: (context, index) {
                              final story = state.mockStories[index];
                              return LibraryStory(
                                    story: story,
                                    width: 175,
                                    height: 207,
                                    onStoryTap: (story) => context.pushNamed(
                                      StoryDescriptionScreen.id,
                                      args: story,
                                    ),
                                  )
                                  .animate(delay: (index * 50).ms)
                                  .fade(duration: 400.ms, curve: Curves.easeOut)
                                  .slideY(begin: 0.1, curve: Curves.easeOut);
                            },
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
