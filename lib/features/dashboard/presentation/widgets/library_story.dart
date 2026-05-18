import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:stela_mobile/core/presentation/theme/colors/colors.dart';
import 'package:stela_mobile/core/presentation/widgets/custom_image.dart';
import 'package:stela_mobile/features/dashboard/domain/models/story.dart';

class LibraryStory extends StatelessWidget {
  const LibraryStory({
    super.key,
    required this.story,
    required this.onStoryTap,
    this.height,
    this.width,
  });
  final Story story;
  final Function(Story) onStoryTap;
  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onStoryTap(story),
      child: SizedBox(
        width: width ?? 140,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CustomImage(
                asset: story.coverImage,
                width: width ?? 140,
                height: height ?? 150,
                fit: BoxFit.cover,
              ),
            ),
            const Gap(8),
            Text(
              story.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w400),
            ),
            const Gap(4),
            Text(
              story.author,
              style: TextStyle(color: Color(0xFF62748E), fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const Gap(4),
            Row(
              children: List.generate(5, (index) {
                return Icon(Icons.star_rounded, color: amber, size: 14);
              }),
            ),
          ],
        ),
      ),
    );
  }
}
