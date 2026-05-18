import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:stela_mobile/features/dashboard/domain/models/story.dart';
import 'package:stela_mobile/core/presentation/theme/colors/colors.dart';

class ContinueReadingList extends StatelessWidget {
  final List<Story> stories;
  final Function(Story) onStoryTap;

  const ContinueReadingList({
    super.key,
    required this.stories,
    required this.onStoryTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: stories.map((story) {
        return GestureDetector(
          onTap: () => onStoryTap(story),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.05),
                  blurRadius: 10,
                  spreadRadius: 0,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    story.coverImage,
                    width: 57,
                    height: 73,
                    fit: BoxFit.cover,
                  ),
                ),
                const Gap(16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        story.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const Gap(4),
                      Text(
                        story.author,
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      const Gap(8),
                      // Progress bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: LinearProgressIndicator(
                          value: story.readPercentage,
                          backgroundColor: grey300,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            orange,
                          ),
                          minHeight: 6,
                        ),
                      ),
                      const Gap(4),
                      Text(
                        '${(story.readPercentage * 100).toInt()}% complete · ${story.readTime}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 10),
                      ),
                    ],
                  ),
                ),
                const Gap(12),
                Container(
                  width: 60,
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    gradient: buttonGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: orange,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Center(
                      child: Text(
                        'Read',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
