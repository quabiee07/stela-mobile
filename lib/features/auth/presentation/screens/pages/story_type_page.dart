import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:gif_view/gif_view.dart';
import 'package:provider/provider.dart';
import 'package:stela_mobile/core/presentation/resources/drawables.dart';
import 'package:stela_mobile/core/presentation/theme/colors/colors.dart';
import 'package:stela_mobile/core/presentation/utils/custom_state.dart';
import 'package:stela_mobile/core/presentation/widgets/clickable.dart';
import 'package:stela_mobile/features/auth/domain/models/story_type.dart';
import 'package:stela_mobile/features/auth/presentation/manager/auth_provider.dart';

class StoryTypePage extends StatefulWidget {
  const StoryTypePage({super.key});

  @override
  State<StoryTypePage> createState() => _StoryTypePageState();
}

class _StoryTypePageState extends CustomState<StoryTypePage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      child: Column(
        children: [
          const Gap(20),
          GifView.asset(ageGif, height: 150, width: 102, frameRate: 60),
          const Gap(8),
          Text(
            "Favourite story types",
            style: theme.textTheme.bodyLarge?.copyWith(fontSize: 24),
          ),
          const Gap(36),
          Consumer<AuthProvider>(
            builder: (context, provider, _) {
              final List<Widget> chips = [];

              for (int i = 0; i < StoryType.storyTypes.length; i++) {
                final type = StoryType.storyTypes[i];
                final isSelected = provider.state.selectedStoryTypes.contains(
                  type,
                );

                chips.add(
                  Clickable(
                    onPressed: () {
                      provider.toggleStoryType(type);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? orange : Colors.white,
                        border: Border.all(
                          color: isSelected ? orange : grey300,
                        ),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            type.asset,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: 16,
                            ),
                          ),
                          const Gap(4),
                          Text(
                            type.name,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: 16,
                              color: isSelected ? Colors.white : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              return Wrap(spacing: 12, runSpacing: 12, children: chips);
            },
          ),
        ],
      ),
    );
  }
}
