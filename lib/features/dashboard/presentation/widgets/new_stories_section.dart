import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:stela_mobile/core/presentation/theme/colors/colors.dart';
import 'package:stela_mobile/core/presentation/theme/theme_x.dart';
import 'package:stela_mobile/core/presentation/widgets/clickable.dart';
import 'package:stela_mobile/features/dashboard/presentation/utils/story_sections.dart';
import 'package:stela_mobile/features/dashboard/presentation/widgets/library_story.dart';
import 'package:stela_mobile/features/library/domain/models/story_summary.dart';

class NewStoriesSection extends StatefulWidget {
  final List<StorySummary> stories;
  final List<String> genres;
  final ValueChanged<StorySummary> onStoryTap;
  final VoidCallback onSeeAll;

  const NewStoriesSection({
    super.key,
    required this.stories,
    required this.genres,
    required this.onStoryTap,
    required this.onSeeAll,
  });

  @override
  State<NewStoriesSection> createState() => _NewStoriesSectionState();
}

class _NewStoriesSectionState extends State<NewStoriesSection> {
  String selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    final filteredStories = selectedCategory == 'All'
        ? widget.stories
        : widget.stories
            .where(
              (story) => formatGenreLabel(story.genre) == selectedCategory,
            )
            .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'New Stories',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Clickable(
              onPressed: widget.onSeeAll,
              child: Text(
                'See all',
                style: TextStyle(color: orange, fontSize: 14),
              ),
            ),
          ],
        ),
        const Gap(16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: widget.genres.map((category) {
              final isSelected = category == selectedCategory;
              return GestureDetector(
                onTap: () => setState(() => selectedCategory = category),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? categoryGradient
                        : context.inactiveChipGradient,
                    borderRadius: BorderRadius.circular(100),
                    border: isSelected
                        ? null
                        : Border.all(color: context.softBorder),
                  ),
                  child: Text(
                    category,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : Theme.of(context).colorScheme.onSurface,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const Gap(16),
        filteredStories.isEmpty
            ? Text(
                'No stories in this category yet.',
                style: TextStyle(color: context.mutedText, fontSize: 13),
              )
            : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                clipBehavior: Clip.none,
                child: Row(
                  spacing: 16,
                  children: filteredStories.map((story) {
                    return LibraryStory(
                      story: story,
                      onStoryTap: (_) => widget.onStoryTap(story),
                    );
                  }).toList(),
                ),
              ),
      ],
    );
  }
}
