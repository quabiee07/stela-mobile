import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:stela_mobile/features/dashboard/domain/models/story.dart';
import 'package:stela_mobile/core/presentation/theme/colors/colors.dart';
import 'package:stela_mobile/features/dashboard/presentation/widgets/library_story.dart';

class NewStoriesSection extends StatefulWidget {
  final List<Story> stories;
  final Function(Story) onStoryTap;

  const NewStoriesSection({
    super.key,
    required this.stories,
    required this.onStoryTap,
  });

  @override
  State<NewStoriesSection> createState() => _NewStoriesSectionState();
}

class _NewStoriesSectionState extends State<NewStoriesSection> {
  String selectedCategory = 'All';
  final List<String> categories = ['All', 'Fantasy', 'Adventure', 'Ocean'];

  @override
  Widget build(BuildContext context) {
    // Filter stories based on selected category
    final filteredStories = selectedCategory == 'All'
        ? widget.stories
        : widget.stories.where((s) => s.category == selectedCategory).toList();

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
            Text('See all', style: TextStyle(color: orange, fontSize: 14)),
          ],
        ),
        const Gap(16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: categories.map((category) {
              final isSelected = category == selectedCategory;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedCategory = category;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: isSelected ? categoryGradient : greyGradient,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    category,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const Gap(16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          clipBehavior: Clip.none,
          child: Row(
            spacing: 16,
            children: filteredStories.map((story) {
              return LibraryStory(story: story, onStoryTap: widget.onStoryTap);
            }).toList(),
          ),
        ),
      ],
    );
  }
}
